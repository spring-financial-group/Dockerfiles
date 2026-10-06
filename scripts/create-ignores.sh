#!/usr/bin/env bash
# Updates <image-dir>/.docksec-ignore.yml from a fresh, unfiltered docksec scan of the image:
#   - entries for findings that are no longer reported (fixed, withdrawn) are dropped
#   - existing entries keep their reason and expiry
#   - new findings are added with a generated reason (unless --prune)
# Never touches .docksec-baseline.json - see scripts/update-baseline.sh.
#
# The image is re-tagged to the same fixed ref the PR pipeline scans (docksec/<image>:scan).
#
# Usage: scripts/create-ignores.sh [--prune] <image-dir> [image-ref]   # e.g. dockerfiles/frontend/node
#        scripts/create-ignores.sh [--prune] --all     # every dockerfiles/<group>/<image> directory, in parallel
#   --prune to only drop stale entries, never add new ones
#   image-ref defaults to the published :latest image; pulled unless already present locally
#   EXPIRES=YYYY-MM-DD to override the expiry date of new entries (default 2026-12-31)
#   OFFLINE=1 to scan with the local Trivy DB only (CI)
#   JOBS=N for the number of parallel scans with --all (default 4)
set -euo pipefail

usage="usage: $0 [--prune] <image-dir> [image-ref] | [--prune] --all"
expires="${EXPIRES:-2026-12-31}"
prune=false
if [ "${1:-}" = "--prune" ]; then
  prune=true
  shift
fi

create_ignores() {
  local image_dir="${1%/}"
  local image_name="${image_dir##*/}"
  local image_ref="${2:-jx3mqubebuild.azurecr.io/spring-financial-group/${image_name}:latest}"
  local scan_ref="docksec/${image_name}:scan"
  local report="${image_dir}/docksec_${image_name//[.-]/_}_scan_scan_results.json"
  local out="${image_dir}/.docksec-ignore.yml"
  local no_ignores existing
  local args=()

  if ! docker image inspect "$image_ref" >/dev/null 2>&1; then
    docker pull --quiet "$image_ref" >/dev/null || return 1
  fi
  docker tag "$image_ref" "$scan_ref" || return 1

  # Scan with an empty ignore file so already-ignored findings still show up in the report and aren't pruned.
  no_ignores=$(mktemp)
  echo 'ignores: []' > "$no_ignores"
  args=(-i "$scan_ref" --image-only --no-color --no-cache --severity CRITICAL,HIGH --format json
    --output-dir "$image_dir" --ignore-file "$no_ignores")
  [ "${OFFLINE:-}" = "1" ] && args+=(--offline)
  docksec "${args[@]}" >/dev/null || { rm -f "$no_ignores"; return 1; }
  rm -f "$no_ignores"

  if [ ! -s "$report" ]; then
    echo "Report not found: $report" >&2
    return 1
  fi

  if [ -f "$out" ]; then
    existing=$(yq -o json '.ignores // []' "$out") || return 1
  else
    existing='[]'
  fi

  jq -r --arg expires "$expires" --argjson prune "$prune" --argjson existing "$existing" '
    def clean: gsub("\""; "'"'"'");
    ( .vulnerabilities // [] | group_by(.VulnerabilityID)
      | map({ key: .[0].VulnerabilityID, value: {
          id: .[0].VulnerabilityID,
          reason: "\([.[].PkgName] | unique | join(", ") | clean) in \([.[].Target] | unique | join(", ") | clean) - \(
              [.[].FixedVersion | select(. != null and . != "")] | unique
              | if length == 0 then "No fix reported" else "fixed in " + join(", ") end)",
          expires: $expires } })
      | from_entries ) as $found
    | ( $existing | map(select(.id != null and $found[.id | tostring] != null)) ) as $kept
    | ( $kept | map(.id | tostring) ) as $kept_ids
    | ( if $prune then [] else $found | to_entries | map(select(.key as $k | $kept_ids | index($k) | not) | .value) end ) as $added
    | ( $kept + $added | sort_by(.id | tostring) ) as $entries
    | if ($entries | length) == 0 then empty else
        "ignores:",
        ( $entries[]
          | "- id: \(.id)",
            ( if .reason != null then "  reason: \"\(.reason | tostring | clean)\"" else empty end ),
            ( if .expires != null then "  expires: \(.expires)" else empty end ) )
      end
  ' "$report" > "$out.tmp" || { rm -f "$out.tmp"; return 1; }

  if [ -s "$out.tmp" ]; then
    mv "$out.tmp" "$out"
    echo "Wrote $(grep -c '^- id:' "$out") ignores to $out"
  else
    rm -f "$out.tmp" "$out"
    echo "No ignores needed for $image_ref - removed $out"
  fi
}

if [ "${1:-}" = "--all" ]; then
  # Update the Trivy DB once up front, then stop the parallel scans racing on the shared cache.
  [ "${OFFLINE:-}" = "1" ] || trivy image --download-db-only --quiet
  export TRIVY_SKIP_DB_UPDATE=true TRIVY_CACHE_BACKEND=memory
  export -f create_ignores
  export expires prune

  failed_file=$(mktemp)
  trap 'rm -f "$failed_file"' EXIT
  printf '%s\n' dockerfiles/*/*/Dockerfile | sed 's|/Dockerfile$||' |
    xargs -P "${JOBS:-4}" -I{} bash -c '
      create_ignores "$1" 2>&1 | sed "s|^|[$1] |"
      [ "${PIPESTATUS[0]}" -eq 0 ] || echo "$1" >> "$2"
    ' _ {} "$failed_file"

  if [ -s "$failed_file" ]; then
    echo "Failed: $(sort "$failed_file" | tr '\n' ' ')" >&2
    exit 1
  fi
else
  create_ignores "${1:?$usage}" "${2:-}"
fi
