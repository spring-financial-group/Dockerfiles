#!/usr/bin/env bash
# Generates <image-dir>/.docksec-ignore.yml covering every finding in the image's docksec JSON report.
# Runs docksec first if the report doesn't exist yet. Skips writing the file if there are no findings.
#
# Usage: scripts/create-ignores.sh [--build] [--trivydb] <image-dir> [image-ref]   # e.g. dockerfiles/frontend/node
#        scripts/create-ignores.sh [--build] [--trivydb] --all     # every dockerfiles/<group>/<image> directory, in parallel
#   --build builds the image from the local Dockerfile and scans that, instead of the published :latest.
#     The report is always regenerated, and image-ref (if given) is the local tag to build.
#   --trivydb scans offline against the vulns DB from the pipeline's trivydb image, instead of downloading
#     the latest DB, so results match what the pipeline sees.
#   EXPIRES=YYYY-MM-DD to override the expiry date (default 2026-12-31)
#   JOBS=N for the number of parallel scans with --all (default 4)
#   PLATFORM=os/arch for the --build platform (default linux/amd64, matching the pipeline)
#   TRIVYDB_IMAGE=ref for the --trivydb image (default jx3mqubebuild.azurecr.io/ghcr-io/jenkins-x/trivydb:latest)
set -euo pipefail

usage="usage: $0 [--build] [--trivydb] <image-dir> [image-ref] | [--build] [--trivydb] --all"
expires="${EXPIRES:-2026-12-31}"
platform="${PLATFORM:-linux/amd64}"
trivydb_image="${TRIVYDB_IMAGE:-jx3mqubebuild.azurecr.io/ghcr-io/jenkins-x/trivydb:latest}"
build=false
trivydb=false
while :; do
  case "${1:-}" in
    --build) build=true; shift ;;
    --trivydb) trivydb=true; shift ;;
    *) break ;;
  esac
done

docksec_flags=""
if [ "$trivydb" = true ]; then
  # Same as the pipeline's copy-vulns-db step: the image ships the DB under /trivydb, laid out as a Trivy cache dir.
  TRIVY_CACHE_DIR=$(mktemp -d)
  trap 'rm -rf "$TRIVY_CACHE_DIR"' EXIT
  docker pull --quiet "$trivydb_image" >/dev/null
  trivydb_container=$(docker create "$trivydb_image" true)
  docker cp "$trivydb_container:/trivydb/." "$TRIVY_CACHE_DIR/" >/dev/null || { docker rm "$trivydb_container" >/dev/null; exit 1; }
  docker rm "$trivydb_container" >/dev/null
  export TRIVY_CACHE_DIR TRIVY_SKIP_DB_UPDATE=true
  docksec_flags="--offline"
fi

create_ignores() {
  local image_dir="${1%/}"
  local image_ref safe_name report out count

  if [ "$build" = true ]; then
    image_ref="${2:-create-ignores/${image_dir##*/}:local}"
  else
    image_ref="${2:-jx3mqubebuild.azurecr.io/spring-financial-group/${image_dir##*/}:latest}"
  fi
  safe_name=$(printf '%s' "$image_ref" | tr ':/.-' '_')
  report="${image_dir}/${safe_name}_scan_results.json"
  out="${image_dir}/.docksec-ignore.yml"

  if [ "$build" = true ]; then
    docker build --platform "$platform" -t "$image_ref" "$image_dir" || return 1
    rm -f "$report"
  fi

  if [ ! -s "$report" ]; then
    # shellcheck disable=SC2086 # docksec_flags is deliberately word-split
    docksec -i "$image_ref" --image-only $docksec_flags --format json --output-dir "$image_dir" || return 1
  fi
  if [ ! -s "$report" ]; then
    echo "Report not found: $report" >&2
    return 1
  fi

  count=$(jq '.vulnerabilities // [] | length' "$report") || return 1
  if [ "$count" -eq 0 ]; then
    echo "No findings for $image_ref - skipping $out"
    return
  fi

  jq -r --arg expires "$expires" '
    def clean: gsub("\""; "'"'"'");
    "ignores:",
    ( .vulnerabilities | group_by(.VulnerabilityID)[]
      | "- id: \(.[0].VulnerabilityID)",
        "  reason: \"\([.[].PkgName] | unique | join(", ") | clean) in \([.[].Target] | unique | join(", ") | clean) - \(
            [.[].FixedVersion | select(. != null and . != "")] | unique
            | if length == 0 then "No fix reported" else "fixed in " + join(", ") end)\"",
        "  expires: \($expires)" )
  ' "$report" > "$out" || return 1

  echo "Wrote $(grep -c '^- id:' "$out") ignores to $out"
}

if [ "${1:-}" = "--all" ]; then
  # Update the Trivy DB once up front (--trivydb already supplied it), then stop the parallel scans racing on the shared cache.
  [ "$trivydb" = true ] || trivy image --download-db-only --quiet
  export TRIVY_SKIP_DB_UPDATE=true TRIVY_CACHE_BACKEND=memory
  export -f create_ignores
  export expires build platform docksec_flags

  failed_file=$(mktemp)
  trap 'rm -rf "$failed_file" ${TRIVY_CACHE_DIR:+"$TRIVY_CACHE_DIR"}' EXIT
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
