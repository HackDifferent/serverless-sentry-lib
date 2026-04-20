#!/usr/bin/env bash
# Prune .context/tasks/ folders whose last git commit is older than 3 months (90 days).
# Designed to run as a git post-commit hook or standalone script.
#
# Pruning is intentionally skipped on non-integration branches (feature, hotfix,
# release, etc.) to preserve task context when working from old release checkpoints.
#
# INTEGRATION_BRANCHES is set by the initialize-repo skill based on git history
# analysis. Update it here if your branch conventions change.
#
# Usage:
#   ./prune-old-tasks.sh              # from project root
#   bash .context/workflows/prune-old-tasks.sh

set -euo pipefail

# Customize to match this repository's integration branch names.
# Updated by initialize-repo based on git log / git branch analysis.
INTEGRATION_BRANCHES="^(master)$"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TASKS_DIR="$REPO_ROOT/.context/tasks"

if [ ! -d "$TASKS_DIR" ]; then
  exit 0
fi

# Only prune on integration branches. When working on a hotfix from an old
# release tag, task context should be preserved regardless of folder age.
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "")"
if [[ ! "$CURRENT_BRANCH" =~ $INTEGRATION_BRANCHES ]]; then
  exit 0
fi

NOW="$(date +%s)"
CUTOFF_DAYS=90
CUTOFF_SECONDS=$(( CUTOFF_DAYS * 86400 ))
PRUNED=()

while IFS= read -r -d '' dir; do
  # Use the last git commit date for this path, not filesystem mtime.
  # Filesystem mtime is reset to "now" by git checkout, making age checks
  # unreliable when working from old release branches or tags. Git commit
  # history is stable across checkouts.
  LAST_COMMIT="$(git log -1 --format="%ct" -- "$dir" 2>/dev/null || echo "")"

  if [ -z "$LAST_COMMIT" ]; then
    # Folder is untracked (never committed). Fall back to mtime.
    LAST_COMMIT="$(stat -c %Y "$dir" 2>/dev/null || stat -f %m "$dir" 2>/dev/null || echo "$NOW")"
  fi

  AGE=$(( NOW - LAST_COMMIT ))
  if [ "$AGE" -gt "$CUTOFF_SECONDS" ]; then
    PRUNED+=("$dir")
    rm -rf "$dir"
  fi
done < <(find "$TASKS_DIR" -maxdepth 1 -mindepth 1 -type d -print0)

if [ ${#PRUNED[@]} -gt 0 ]; then
  echo "prune-old-tasks: removed ${#PRUNED[@]} task folder(s) with no commits in ${CUTOFF_DAYS}+ days:"
  printf '  %s\n' "${PRUNED[@]##*/}"
fi
