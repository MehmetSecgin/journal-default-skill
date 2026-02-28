#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_ROOT="$("$SCRIPT_DIR/resolve_memory_root.sh")"
NOW_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
NEXT_WEEK="$(date -u -v+7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '+7 days' +%Y-%m-%dT%H:%M:%SZ)"
NEXT_MONTH="$(date -u -v+1m +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '+30 days' +%Y-%m-%dT%H:%M:%SZ)"
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  bootstrap_memory.sh [--force]

Behavior:
  - Creates baseline memory layout.
  - By default, does not overwrite existing files.
  - Use --force to overwrite managed baseline files.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "bootstrap_memory: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

write_file() {
  local path="$1"
  local content="$2"
  if [[ "$FORCE" -eq 0 && -f "$path" ]]; then
    echo "skip_existing=$path"
    return
  fi
  printf '%s\n' "$content" > "$path"
  echo "wrote=$path"
}

mkdir -p "$MEMORY_ROOT/domains/engineering/sessions"
mkdir -p "$MEMORY_ROOT/domains/personal/sessions"
mkdir -p "$MEMORY_ROOT/domains/ops/sessions"
mkdir -p "$MEMORY_ROOT/domains/ops/reviews/history"
mkdir -p "$MEMORY_ROOT/domains/general/sessions"
mkdir -p "$MEMORY_ROOT/templates"
mkdir -p "$MEMORY_ROOT/inbox"

write_file "$MEMORY_ROOT/domains/engineering/index.md" "# Engineering Memory Index"
write_file "$MEMORY_ROOT/domains/personal/index.md" "# Personal Memory Index"
write_file "$MEMORY_ROOT/domains/ops/index.md" "# Ops Memory Index"
write_file "$MEMORY_ROOT/domains/general/index.md" "# General Memory Index"
write_file "$MEMORY_ROOT/inbox/triage.md" "# Triage Inbox"

write_file "$MEMORY_ROOT/templates/session.md" "$(cat <<'MD'
# Session

Date:
Domain:
Task:

## Objective
-

## Actions
-

## Decisions
-

## Outcome
-

## Next Step
-

## Improvement Radar
Observed Friction:
Suggested Improvement:
Confidence: low|medium|high
MD
)"

write_file "$MEMORY_ROOT/domains/ops/reviews/_cadence.md" "$(cat <<EOF2
# Weekly Review Cadence Tracker

cadence: weekly
anchor_utc: $NOW_UTC
last_completed_utc: [not set]
next_due_utc: $NEXT_WEEK
last_review_note: [not set]
status: active
notes: Due when now_utc >= next_due_utc.
EOF2
)"

write_file "$MEMORY_ROOT/domains/ops/reviews/_history_hygiene_cadence.md" "$(cat <<EOF2
# Monthly History Hygiene Cadence Tracker

cadence: monthly
anchor_utc: $NOW_UTC
last_completed_utc: [not set]
next_due_utc: $NEXT_MONTH
last_review_note: [not set]
status: active
notes: Due when now_utc >= next_due_utc.
EOF2
)"

echo "$MEMORY_ROOT"
