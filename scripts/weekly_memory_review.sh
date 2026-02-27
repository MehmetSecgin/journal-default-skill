#!/usr/bin/env bash
set -euo pipefail

MEMORY_ROOT="$HOME/.codex/memory"
REVIEWS_DIR="$MEMORY_ROOT/domains/ops/reviews"
TODAY="$(date +%F)"
WEEK_ID="$(date +%G-W%V)"
OUT_FILE="$REVIEWS_DIR/${WEEK_ID}--weekly-memory-review.md"

mkdir -p "$REVIEWS_DIR"

count_recent() {
  local domain="$1"
  find "$MEMORY_ROOT/domains/$domain/sessions" -type f -mtime -7 2>/dev/null | wc -l | tr -d ' '
}

ENG_COUNT="$(count_recent engineering)"
PERSONAL_COUNT="$(count_recent personal)"
OPS_COUNT="$(count_recent ops)"
GENERAL_COUNT="$(count_recent general)"

STALE_CANDIDATES="$(find "$MEMORY_ROOT/domains" -path '*/sessions/*.md' -type f -mtime +60 2>/dev/null | sed "s|$HOME|~|" | head -n 30)"

cat > "$OUT_FILE" <<REPORT
# Weekly Memory Review

Date: $TODAY
Week: $WEEK_ID

## Activity Snapshot (last 7 days)
- engineering sessions: $ENG_COUNT
- personal sessions: $PERSONAL_COUNT
- ops sessions: $OPS_COUNT
- general sessions: $GENERAL_COUNT

## Repeated Friction Patterns
- 

## Suggested Improvements
- 

## Stale Note Candidates (>60 days, no deletion)
$STALE_CANDIDATES

## Follow-ups
1. 
2. 
3. 
REPORT

echo "$OUT_FILE"
