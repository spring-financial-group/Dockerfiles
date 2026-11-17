#!/usr/bin/env bash
# Final step of the update-baselines pipeline (.lighthouse/jenkins-x/update-baselines.yaml). Run after the
# .docksec-baseline.json files have been rescanned (scripts/create-baselines.sh): if any changed, commits them to a
# single rolling branch and opens or updates a PR for review. If nothing changed, any open PR from an earlier run is
# closed as stale. Run from the root of a clone of the repo, with the rescanned baselines in the working tree.
#
# Env:
#   GIT_TOKEN            GitHub token for pushing and the PR API (required unless DRY_RUN=true)
#   FAILED_FILE          file listing image dirs that failed to scan, one per line (optional)
#   REPO                 owner/name (default spring-financial-group/Dockerfiles)
#   BASE_BRANCH          branch to compare against and open the PR into (default main)
#   PR_BRANCH            rolling PR branch (default chore/update-docksec-baselines)
#   DRY_RUN=true         print the PR body, but don't push or call the GitHub API
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

# 1. Images that failed to scan kept their old baseline. They're reported, but don't stop the others being published.
failed=""
if [ -n "${FAILED_FILE:-}" ] && [ -s "$FAILED_FILE" ]; then
  failed=$(sort -u "$FAILED_FILE" | sed '/^$/d')
fi
[ -z "$failed" ] || log "Failed images: $(echo "$failed" | tr '\n' ' ')"

body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

# 2. Work out what changed against the base branch.
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

# 3. PR body: per-image added/removed fingerprint counts, with the added ones listed.
{
  echo "Automated refresh of \`.docksec-baseline.json\` from the \`update-baselines\` pipeline."
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
    echo "These images kept their existing baseline. Check the pipeline logs."
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

# 4. Commit onto a fresh branch from the base, and push only if the content differs from what's already there.
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

# 5. Open or update the PR.
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
