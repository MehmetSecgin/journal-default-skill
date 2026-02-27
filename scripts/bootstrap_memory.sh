#!/usr/bin/env bash
set -euo pipefail

MEMORY_ROOT="${MEMORY_ROOT:-$HOME/.codex/memory}"
NOW_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
NEXT_WEEK="$(date -u -v+7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '+7 days' +%Y-%m-%dT%H:%M:%SZ)"
NEXT_MONTH="$(date -u -v+1m +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '+30 days' +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$MEMORY_ROOT/domains/engineering/sessions"
mkdir -p "$MEMORY_ROOT/domains/personal/sessions"
mkdir -p "$MEMORY_ROOT/domains/ops/sessions"
mkdir -p "$MEMORY_ROOT/domains/ops/reviews/history"
mkdir -p "$MEMORY_ROOT/domains/general/sessions"
mkdir -p "$MEMORY_ROOT/templates"
mkdir -p "$MEMORY_ROOT/inbox"

cat > "$MEMORY_ROOT/domains/engineering/index.md" <<'MD'
# Engineering Memory Index
MD

cat > "$MEMORY_ROOT/domains/personal/index.md" <<'MD'
# Personal Memory Index
MD

cat > "$MEMORY_ROOT/domains/ops/index.md" <<'MD'
# Ops Memory Index
MD

cat > "$MEMORY_ROOT/domains/general/index.md" <<'MD'
# General Memory Index
MD

cat > "$MEMORY_ROOT/inbox/triage.md" <<'MD'
# Triage Inbox
MD

cat > "$MEMORY_ROOT/templates/session.md" <<'MD'
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

cat > "$MEMORY_ROOT/domains/ops/reviews/_cadence.md" <<EOF2
# Weekly Review Cadence Tracker

cadence: weekly
anchor_utc: $NOW_UTC
last_completed_utc: [not set]
next_due_utc: $NEXT_WEEK
last_review_note: [not set]
status: active
notes: Due when now_utc >= next_due_utc.
EOF2

cat > "$MEMORY_ROOT/domains/ops/reviews/_history_hygiene_cadence.md" <<EOF2
# Monthly History Hygiene Cadence Tracker

cadence: monthly
anchor_utc: $NOW_UTC
last_completed_utc: [not set]
next_due_utc: $NEXT_MONTH
last_review_note: [not set]
status: active
notes: Due when now_utc >= next_due_utc.
EOF2

echo "$MEMORY_ROOT"
