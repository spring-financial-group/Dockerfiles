#!/usr/bin/env bash
# Entrypoint for the dockerfiles-baseline-updater CronJob (charts/dockerfiles-baseline-updater).
# Rescans every published :latest image against the pipeline's trivydb (scripts/create-baselines.sh --trivydb --all)
# and, if any .docksec-baseline.json changed, force-pushes them to a single rolling branch and opens or updates a PR
# for review. If nothing changed, any open PR from an earlier run is closed as stale.
# Run from the root of a clone of the repo, with a Docker daemon reachable (DOCKER_HOST).
#
# Env:
#   GIT_TOKEN            GitHub token for pushing and the PR API (required unless DRY_RUN=true)
#   REPO                 owner/name (default spring-financial-group/Dockerfiles)
#   BASE_BRANCH          branch to compare against and open the PR into (default main)
#   PR_BRANCH            rolling PR branch (default chore/update-docksec-baselines)
#   JOBS                 parallel scans (default 2)
#   DOCKER_WAIT_SECONDS  how long to wait for the Docker daemon (default 180)
#   DRY_RUN=true         scan and print the PR body, but don't push or call the GitHub API
set -euo pipefail

repo="${REPO:-spring-financial-group/Dockerfiles}"
base_branch="${BASE_BRANCH:-main}"
pr_branch="${PR_BRANCH:-chore/update-docksec-baselines}"
dry_run="${DRY_RUN:-false}"
max_listed=50
api="https://api.github.com/repos/${repo}"
baseline_glob='dockerfiles/*/*/.docksec-baseline.json'

log() { echo "[update-baselines-pr] $*" >&2; }

if [ "$dry_run" != true ] && [ -z "${GIT_TOKEN:-}" ]; then
  log "GIT_TOKEN is required (or set DRY_RUN=true)"
  exit 1
fi

gh_api() {
  local method="$1" path="$2" data="${3:-}"
  local args=(-fsS -X "$method" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GIT_TOKEN}"
    -H "X-GitHub-Api-Version: 2022-11-28")
  [ -z "$data" ] || args+=(-d "$data")
  curl "${args[@]}" "${api}${path}"
}

open_pr_number() {
  gh_api GET "/pulls?state=open&base=${base_branch}&head=${repo%%/*}:${pr_branch}" | jq -r '.[0].number // empty'
}

# 1. Wait for the dind sidecar.
deadline=$(( $(date +%s) + ${DOCKER_WAIT_SECONDS:-180} ))
until docker info >/dev/null 2>&1; do
  if [ "$(date +%s)" -ge "$deadline" ]; then
    log "Docker daemon not reachable at ${DOCKER_HOST:-default socket}"
    exit 1
  fi
  sleep 2
done

# 2. Rescan everything. Failed images keep their old baseline and are reported, but don't stop the others.
failed_file=$(mktemp)
body_file=$(mktemp)
trap 'rm -f "$failed_file" "$body_file"' EXIT
scan_rc=0
PRUNE=true JOBS="${JOBS:-2}" FAILED_FILE="$failed_file" scripts/create-baselines.sh --trivydb --all || scan_rc=$?
failed=$(sort -u "$failed_file" | sed '/^$/d')
[ -z "$failed" ] || log "Failed images: $(echo "$failed" | tr '\n' ' ')"
# Treat a non-zero exit with no recorded image failures (e.g. the trivydb pull failed) as fatal.
if [ "$scan_rc" -ne 0 ] && [ -z "$failed" ]; then
  log "create-baselines.sh failed before scanning (exit $scan_rc)"
  exit "$scan_rc"
fi

# 3. Work out what changed against the base branch.
# Newline-separated list of changed or new baseline files. The glob is a git pathspec, so it's quoted to stop the
# shell expanding it. (No mapfile/arrays, so this also runs on macOS's bash 3.2 for DRY_RUN.)
changed=$( { git diff --name-only -- "$baseline_glob"; git ls-files --others --exclude-standard -- "$baseline_glob"; } \
  | sort -u)

if [ -z "$changed" ]; then
  log "No baseline changes"
  if [ "$dry_run" != true ] && pr=$(open_pr_number) && [ -n "$pr" ]; then
    log "Closing stale PR #$pr"
    gh_api POST "/issues/${pr}/comments" \
      "$(jq -n --arg b "$base_branch" '{body: "Baselines on `\($b)` are up to date with the latest scan, closing."}')" >/dev/null
    gh_api PATCH "/pulls/${pr}" '{"state":"closed"}' >/dev/null
  fi
  [ -z "$failed" ] || exit 1
  exit 0
fi

# 4. PR body: per-image added/removed fingerprint counts, with the added ones listed.
{
  echo "Automated refresh of \`.docksec-baseline.json\` from the \`dockerfiles-baseline-updater\` CronJob."
  echo
  echo "Each published \`:latest\` image was rescanned against \`trivydb:latest\`. Merging accepts the **added**"
  echo "fingerprints into the baseline, so the PR gate stops failing on them. Review them before approving."
  echo
  echo "| Image | Added | Removed |"
  echo "| --- | ---: | ---: |"
} > "$body_file"

details=""
while IFS= read -r f; do
  image_dir="${f%/.docksec-baseline.json}"
  old=$(git show "HEAD:$f" 2>/dev/null | jq -r '.fingerprints[]?' | sort || true)
  new=$(jq -r '.fingerprints[]?' "$f" | sort)
  added=$(comm -13 <(echo "$old" | sed '/^$/d') <(echo "$new" | sed '/^$/d'))
  removed=$(comm -23 <(echo "$old" | sed '/^$/d') <(echo "$new" | sed '/^$/d'))
  n_added=$(echo "$added" | sed '/^$/d' | wc -l | tr -d ' ')
  n_removed=$(echo "$removed" | sed '/^$/d' | wc -l | tr -d ' ')
  echo "| \`${image_dir#dockerfiles/}\` | ${n_added} | ${n_removed} |" >> "$body_file"
  if [ "$n_added" -gt 0 ]; then
    details+=$'\n'"<details><summary><code>${image_dir#dockerfiles/}</code>: ${n_added} added</summary>"$'\n\n```\n'
    details+="$(echo "$added" | sed '/^$/d' | head -n "$max_listed")"$'\n'
    [ "$n_added" -le "$max_listed" ] || details+="... and $((n_added - max_listed)) more"$'\n'
    details+=$'```\n</details>\n'
  fi
done <<< "$changed"
echo "$details" >> "$body_file"

if [ -n "$failed" ]; then
  {
    echo "### Failed to scan"
    echo "These images kept their existing baseline. Check the CronJob logs."
    echo
    # shellcheck disable=SC2016 # literal markdown backticks
    echo "$failed" | sed 's|^|- `|; s|$|`|'
  } >> "$body_file"
fi

if [ "$dry_run" = true ]; then
  log "DRY_RUN: would push $(echo "$changed" | wc -l | tr -d ' ') baseline(s) to ${pr_branch} with this PR body:"
  cat "$body_file"
  [ -z "$failed" ] || exit 1
  exit 0
fi

# 5. Commit onto a fresh branch from the base, and push only if the content differs from what's already there.
git config --local user.name "${GIT_AUTHOR_NAME:-mqube-bot}"
git config --local user.email "${GIT_AUTHOR_EMAIL:-mqube-bot@mqube.com}"
# Read the token from the environment at call time, so it never lands in a URL, the git config or the logs.
# shellcheck disable=SC2016
git config --local credential.helper '!f() { echo username=x-access-token; echo "password=${GIT_TOKEN}"; }; f'

git checkout -B "$pr_branch"
echo "$changed" | xargs git add --
git commit -m "chore: update docksec baselines"

if git fetch --quiet origin "refs/heads/${pr_branch}" 2>/dev/null \
    && [ "$(git rev-parse 'HEAD^{tree}')" = "$(git rev-parse 'FETCH_HEAD^{tree}')" ]; then
  log "${pr_branch} already has these baselines, not pushing"
else
  git push --force origin "HEAD:refs/heads/${pr_branch}"
fi

# 6. Open or update the PR.
title="chore: update docksec baselines"
if pr=$(open_pr_number) && [ -n "$pr" ]; then
  log "Updating PR #$pr"
  gh_api PATCH "/pulls/${pr}" "$(jq -n --arg title "$title" --rawfile body "$body_file" '{title: $title, body: $body}')" >/dev/null
else
  url=$(gh_api POST "/pulls" "$(jq -n --arg title "$title" --arg head "$pr_branch" --arg base "$base_branch" \
    --rawfile body "$body_file" '{title: $title, head: $head, base: $base, body: $body}')" | jq -r '.html_url')
  log "Opened $url"
fi

[ -z "$failed" ] || exit 1
