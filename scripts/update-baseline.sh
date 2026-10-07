#!/usr/bin/env bash
# Regenerates <image-dir>/.docksec-baseline.json from a fresh docksec scan, for the PR pipeline's ratchet gate
# (--baseline + --fail-on high). Findings suppressed by <image-dir>/.docksec-ignore.yml are left out of the baseline,
# so an ignore entry expiring fails the gate. Never modifies the ignore file.
#
# The image is re-tagged to a fixed ref (docksec/<image>:scan) before scanning: Trivy puts the scanned ref in
# the Target of OS findings, which is part of the baseline fingerprint, so the PR pipeline must scan the same ref.
#
# Usage: scripts/update-baseline.sh <image-dir> [image-ref]   # e.g. dockerfiles/python/python310
#        scripts/update-baseline.sh --all     # every dockerfiles/<group>/<image> directory, in parallel
#   image-ref defaults to the published :latest image; pulled unless already present locally
#   OFFLINE=1 to scan with the local Trivy DB only (CI)
#   JOBS=N for the number of parallel scans with --all (default 4)
set -euo pipefail

usage="usage: $0 <image-dir> [image-ref] | --all"

update_baseline() {
  local image_dir="${1%/}"
  local image_name="${image_dir##*/}"
  local image_ref="${2:-jx3mqubebuild.azurecr.io/spring-financial-group/${image_name}:latest}"
  local scan_ref="docksec/${image_name}:scan"
  local baseline="${image_dir}/.docksec-baseline.json"
  local ignore_file="${image_dir}/.docksec-ignore.yml"
  local before after
  local args=()

  if ! docker image inspect "$image_ref" >/dev/null 2>&1; then
    docker pull --quiet "$image_ref" >/dev/null || return 1
  fi
  docker tag "$image_ref" "$scan_ref" || return 1

  before=$(yq -p json -oy '.fingerprints[]' "$baseline" 2>/dev/null | sort || true)

  # --no-cache: the cache is keyed on image ID, so a hit would return Targets naming whatever ref was scanned before.
  args=(-i "$scan_ref" --image-only --no-color --severity CRITICAL,HIGH --format json
    --output-dir "$image_dir" --baseline "$baseline" --update-baseline)
  [ -f "$ignore_file" ] && args+=(--ignore-file "$ignore_file")
  [ "${OFFLINE:-}" = "1" ] && args+=(--offline)
  docksec "${args[@]}" >/dev/null || return 1

  if [ ! -s "$baseline" ]; then
    echo "Baseline not written: $baseline" >&2
    return 1
  fi

  after=$(yq -p json -oy '.fingerprints[]' "$baseline" | sort)
  echo "Wrote $(printf '%s' "$after" | grep -c . || true) fingerprints to $baseline" \
    "(+$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after") | grep -c . || true)" \
    "-$(comm -23 <(printf '%s\n' "$before") <(printf '%s\n' "$after") | grep -c . || true))"
}

if [ "${1:-}" = "--all" ]; then
  # Update the Trivy DB once up front, then stop the parallel scans racing on the shared cache.
  [ "${OFFLINE:-}" = "1" ] || trivy image --download-db-only --quiet
  export TRIVY_SKIP_DB_UPDATE=true TRIVY_CACHE_BACKEND=memory
  export -f update_baseline

  failed_file=$(mktemp)
  trap 'rm -f "$failed_file"' EXIT
  printf '%s\n' dockerfiles/*/*/Dockerfile | sed 's|/Dockerfile$||' |
    xargs -P "${JOBS:-4}" -I{} bash -c '
      update_baseline "$1" 2>&1 | sed "s|^|[$1] |"
      [ "${PIPESTATUS[0]}" -eq 0 ] || echo "$1" >> "$2"
    ' _ {} "$failed_file"

  if [ -s "$failed_file" ]; then
    echo "Failed: $(sort "$failed_file" | tr '\n' ' ')" >&2
    exit 1
  fi
else
  update_baseline "${1:?$usage}" "${2:-}"
fi
