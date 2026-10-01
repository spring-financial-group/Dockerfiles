#!/usr/bin/env bash
# Generates <image-dir>/.docksec-ignore.yml covering every finding in the image's docksec JSON report.
# Runs docksec first if the report doesn't exist yet. Skips writing the file if there are no findings.
#
# Usage: scripts/create-ignores.sh <image-dir> [image-ref]
#        scripts/create-ignores.sh --all     # every directory containing a Dockerfile, in parallel
#   EXPIRES=YYYY-MM-DD to override the expiry date (default 2026-12-31)
#   JOBS=N for the number of parallel scans with --all (default 4)
set -euo pipefail

usage="usage: $0 <image-dir> [image-ref] | --all"
expires="${EXPIRES:-2026-12-31}"

create_ignores() {
  local image_dir="${1%/}"
  local image_ref="${2:-jx3mqubebuild.azurecr.io/spring-financial-group/${image_dir}:latest}"
  local safe_name report out count

  safe_name=$(printf '%s' "$image_ref" | tr ':/.-' '_')
  report="${image_dir}/${safe_name}_scan_results.json"
  out="${image_dir}/.docksec-ignore.yml"

  if [ ! -s "$report" ]; then
    docksec -i "$image_ref" --image-only --format json --output-dir "$image_dir" || return 1
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
  # Update the Trivy DB once up front, then stop the parallel scans racing on the shared cache.
  trivy image --download-db-only --quiet
  export TRIVY_SKIP_DB_UPDATE=true TRIVY_CACHE_BACKEND=memory
  export -f create_ignores
  export expires

  failed_file=$(mktemp)
  trap 'rm -f "$failed_file"' EXIT
  printf '%s\n' */Dockerfile | sed 's|/Dockerfile$||' |
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
