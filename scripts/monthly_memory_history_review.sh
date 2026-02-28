#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$("$SCRIPT_DIR/resolve_memory_root.sh")"
OUT_DIR="$MEMORY_DIR/domains/ops/reviews/history"
WEEKLY_TRACKER="$MEMORY_DIR/domains/ops/reviews/_history_hygiene_cadence.md"

mkdir -p "$OUT_DIR"

MONTH_ID="$(date -u +%Y-%m)"
TODAY="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OUT_FILE="$OUT_DIR/${MONTH_ID}--history-hygiene-review.md"

SNAPSHOT_TITLE="## Commit Snapshot"
SNAPSHOT_METRIC="- total_commits: 0"
LOW_VALUE_TITLE="## Potential Low-Value Commit Messages (review manually)"
LOW_VALUE_ITEMS="- (none detected)"

if [[ -d "$MEMORY_DIR/.git" ]]; then
  cd "$MEMORY_DIR"
  TOTAL_COMMITS="$(git log --since='30 days ago' --pretty=oneline | wc -l | tr -d ' ')"
  LOW_VALUE="$(git log --since='30 days ago' --pretty='format:%h %s' | rg -ni '(switch|worktree|branch|wip|typo|minor|tmp|test only)' || true)"
  SNAPSHOT_METRIC="- total_commits: $TOTAL_COMMITS"
  if [[ -n "$LOW_VALUE" ]]; then
    LOW_VALUE_ITEMS="$LOW_VALUE"
  fi
else
  TOTAL_NOTES="$(find "$MEMORY_DIR/domains" -path '*/sessions/*.md' -type f 2>/dev/null | wc -l | tr -d ' ')"
  RECENT_NOTES="$(find "$MEMORY_DIR/domains" -path '*/sessions/*.md' -type f -mtime -30 2>/dev/null | wc -l | tr -d ' ')"
  LOW_VALUE="$(find "$MEMORY_DIR/domains" -path '*/sessions/*.md' -type f -mtime -30 2>/dev/null | rg -ni '(wip|tmp|scratch|quick-note|test)' || true)"

  SNAPSHOT_TITLE="## Note Snapshot"
  SNAPSHOT_METRIC="- total_session_notes: $TOTAL_NOTES"$'\n'"- session_notes_last_30d: $RECENT_NOTES"
  LOW_VALUE_TITLE="## Potential Low-Value Session Note Names (review manually)"
  if [[ -n "$LOW_VALUE" ]]; then
    LOW_VALUE_ITEMS="$LOW_VALUE"
  fi
fi

cat > "$OUT_FILE" <<REPORT
# Monthly Memory History Hygiene Review

created_utc: $TODAY
window: last 30 days

$SNAPSHOT_TITLE
$SNAPSHOT_METRIC

$LOW_VALUE_TITLE
$LOW_VALUE_ITEMS

## Recommendation
- Keep history as-is by default.
- If noise is high, prepare a cleanup plan in a separate clone/archive branch.
- Do not rewrite canonical history unless explicitly requested.
REPORT

echo "$OUT_FILE"
