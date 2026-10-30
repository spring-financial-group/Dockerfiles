#!/usr/bin/env bash
# Scans the image with docksec --update-baseline to (re)write <image-dir>/.docksec-baseline.json (ratchet mode), so the
# pipeline's --fail-on gate only trips on findings that aren't in the baseline. Findings waived by the image's
# .docksec-ignore.yml are left out, so an expired waiver resurfaces as a new finding.
# The image is scanned as <image>:baseline, matching the pipeline: Trivy puts the scanned ref into OS-package targets,
# so both sides must scan the same ref for the fingerprints to line up.
#
# Usage: scripts/create-baselines.sh [--build] [--trivydb] <image-dir> [image-ref]   # e.g. dockerfiles/frontend/node
#        scripts/create-baselines.sh [--build] [--trivydb] --all     # every dockerfiles/<group>/<image> directory, in parallel
#   --build builds the image from the local Dockerfile and scans that, instead of the published :latest.
#     image-ref (if given) is the local tag to build.
#   --trivydb scans offline against the vulns DB from the pipeline's trivydb image, instead of downloading
#     the latest DB, so results match what the pipeline sees.
#   JOBS=N for the number of parallel scans with --all (default 4)
#   PLATFORM=os/arch to build or pull (default linux/amd64, matching the pipeline)
#   TRIVYDB_IMAGE=ref for the --trivydb image (default jx3mqubebuild.azurecr.io/ghcr-io/jenkins-x/trivydb:latest)
set -euo pipefail

usage="usage: $0 [--build] [--trivydb] <image-dir> [image-ref] | [--build] [--trivydb] --all"
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
  local image_ref scan_ref out

  if [ "$build" = true ]; then
    image_ref="${2:-create-ignores/${image_dir##*/}:local}"
  else
    image_ref="${2:-jx3mqubebuild.azurecr.io/spring-financial-group/${image_dir##*/}:latest}"
  fi
  scan_ref="${image_dir##*/}:baseline"
  out="${image_dir}/.docksec-baseline.json"

  if [ "$build" = true ]; then
    docker build --platform "$platform" -t "$image_ref" "$image_dir" || return 1
  else
    docker pull --quiet --platform "$platform" "$image_ref" >/dev/null || return 1
  fi
  docker tag "$image_ref" "$scan_ref" || return 1

  # shellcheck disable=SC2086 # docksec_flags is deliberately word-split
  docksec -i "$scan_ref" --image-only $docksec_flags --format json --output-dir "$image_dir" --no-cache \
    --ignore-file "${image_dir}/.docksec-ignore.yml" --baseline "$out" --update-baseline || return 1

  echo "Wrote $(jq '.fingerprints | length' "$out") fingerprints to $out"
}

if [ "${1:-}" = "--all" ]; then
  # Update the Trivy DB once up front (--trivydb already supplied it), then stop the parallel scans racing on the shared cache.
  [ "$trivydb" = true ] || trivy image --download-db-only --quiet
  export TRIVY_SKIP_DB_UPDATE=true TRIVY_CACHE_BACKEND=memory
  export -f create_ignores
  export build platform docksec_flags

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
