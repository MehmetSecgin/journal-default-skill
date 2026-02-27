#!/usr/bin/env bash
set -euo pipefail

MEMORY_DIR="${MEMORY_ROOT:-$HOME/.codex/memory}"
OUT_DIR="$MEMORY_DIR/domains/ops/reviews/history"
WEEKLY_TRACKER="$MEMORY_DIR/domains/ops/reviews/_history_hygiene_cadence.md"

mkdir -p "$OUT_DIR"

MONTH_ID="$(date -u +%Y-%m)"
TODAY="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OUT_FILE="$OUT_DIR/${MONTH_ID}--history-hygiene-review.md"

cd "$MEMORY_DIR"

TOTAL_COMMITS="$(git log --since='30 days ago' --pretty=oneline | wc -l | tr -d ' ')"
LOW_VALUE="$(git log --since='30 days ago' --pretty='format:%h %s' | rg -ni '(switch|worktree|branch|wip|typo|minor|tmp|test only)' || true)"

cat > "$OUT_FILE" <<REPORT
# Monthly Memory History Hygiene Review

created_utc: $TODAY
window: last 30 days

## Commit Snapshot
- total_commits: $TOTAL_COMMITS

## Potential Low-Value Commit Messages (review manually)
$LOW_VALUE

## Recommendation
- Keep history as-is by default.
- If noise is high, prepare a cleanup plan in a separate clone/archive branch.
- Do not rewrite canonical history unless explicitly requested.
REPORT

echo "$OUT_FILE"
