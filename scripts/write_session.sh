#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_ROOT="$("$SCRIPT_DIR/resolve_memory_root.sh")"

usage() {
  cat <<'USAGE'
Usage:
  write_session.sh --domain <engineering|personal|ops|general> --title "<task title>" --summary "<index summary>" [--date YYYY-MM-DD]

Behavior:
  - Creates or reuses domains/<domain>/sessions/YYYY-MM-DD--<slug>.md
  - Enforces required session sections in the session file
  - Inserts a markdown link entry in domains/<domain>/index.md if missing
USAGE
}

DOMAIN=""
TITLE=""
SUMMARY=""
DATE_STR="$(date +%F)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain)
      DOMAIN="${2:-}"
      shift 2
      ;;
    --title)
      TITLE="${2:-}"
      shift 2
      ;;
    --summary)
      SUMMARY="${2:-}"
      shift 2
      ;;
    --date)
      DATE_STR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "write_session: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$DOMAIN" || -z "$TITLE" || -z "$SUMMARY" ]]; then
  usage >&2
  exit 2
fi

case "$DOMAIN" in
  engineering|personal|ops|general)
    ;;
  *)
    echo "write_session: invalid --domain '$DOMAIN'" >&2
    exit 2
    ;;
esac

if ! [[ "$DATE_STR" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "write_session: invalid --date '$DATE_STR' (expected YYYY-MM-DD)" >&2
  exit 2
fi

slugify() {
  python3 - "$1" <<'PY'
import re
import sys
text = sys.argv[1].strip().lower()
text = re.sub(r'[^a-z0-9]+', '-', text)
text = re.sub(r'-+', '-', text).strip('-')
if not text:
    text = "session"
print(text[:80])
PY
}

SLUG="$(slugify "$TITLE")"
SESSIONS_DIR="$MEMORY_ROOT/domains/$DOMAIN/sessions"
INDEX_FILE="$MEMORY_ROOT/domains/$DOMAIN/index.md"
SESSION_FILE="$SESSIONS_DIR/${DATE_STR}--${SLUG}.md"
SESSION_BASENAME="$(basename "$SESSION_FILE")"

mkdir -p "$SESSIONS_DIR"

if [[ ! -f "$INDEX_FILE" ]]; then
  DOMAIN_TITLE="$(tr '[:lower:]' '[:upper:]' <<< "${DOMAIN:0:1}")${DOMAIN:1}"
  printf '# %s Memory Index\n\n' "$DOMAIN_TITLE" > "$INDEX_FILE"
fi

if [[ ! -f "$SESSION_FILE" ]]; then
  cat > "$SESSION_FILE" <<EOF
# Session

Date: $DATE_STR
Domain: $DOMAIN
Task: $TITLE

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
Confidence: medium
EOF
fi

ensure_header() {
  local header="$1"
  if ! rg -q "^${header}$" "$SESSION_FILE"; then
    cat >> "$SESSION_FILE" <<EOF

$header
- 
EOF
  fi
}

ensure_header "## Objective"
ensure_header "## Actions"
ensure_header "## Decisions"
ensure_header "## Outcome"
ensure_header "## Next Step"
if ! rg -q "^## Improvement Radar$" "$SESSION_FILE"; then
  cat >> "$SESSION_FILE" <<'EOF'

## Improvement Radar
Observed Friction: 
Suggested Improvement: 
Confidence: medium
EOF
fi
if ! rg -q '^Observed Friction:' "$SESSION_FILE"; then
  echo "Observed Friction: " >> "$SESSION_FILE"
fi
if ! rg -q '^Suggested Improvement:' "$SESSION_FILE"; then
  echo "Suggested Improvement: " >> "$SESSION_FILE"
fi
if ! rg -q '^Confidence: (low|medium|high)$' "$SESSION_FILE"; then
  echo "Confidence: medium" >> "$SESSION_FILE"
fi

python3 - "$INDEX_FILE" "$DATE_STR" "$SUMMARY" "$SESSION_BASENAME" <<'PY'
from pathlib import Path
import sys

index_file = Path(sys.argv[1])
date_str = sys.argv[2]
summary = sys.argv[3].replace("]", r"\]")
session_name = sys.argv[4]
entry = f"- {date_str}: [{summary}](./sessions/{session_name})"

lines = index_file.read_text().splitlines()
needle = f"(./sessions/{session_name})"
if any(needle in line for line in lines):
    print("index entry already exists")
    raise SystemExit(0)

if not lines:
    lines = ["# Engineering Memory Index", ""]

insert_at = 1 if lines[0].startswith("# ") else 0
if len(lines) >= 2 and lines[1].strip() == "":
    insert_at = 2

lines.insert(insert_at, entry)
index_file.write_text("\n".join(lines) + "\n")
print("index entry added")
PY

echo "memory_root=$MEMORY_ROOT"
echo "session_file=$SESSION_FILE"
echo "index_file=$INDEX_FILE"
