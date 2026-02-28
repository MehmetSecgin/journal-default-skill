#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_ROOT="$("$SCRIPT_DIR/resolve_memory_root.sh")"

DOMAIN_FILTER=""
FIX_MODE=0

usage() {
  cat <<'USAGE'
Usage:
  check_index_consistency.sh [--domain <engineering|personal|ops|general>] [--fix]

Checks:
  - every index link target exists under sessions/
  - every sessions/*.md file appears in index.md

Options:
  --fix   add missing sessions to index with fallback summaries
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain)
      DOMAIN_FILTER="${2:-}"
      shift 2
      ;;
    --fix)
      FIX_MODE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "check_index_consistency: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -n "$DOMAIN_FILTER" ]]; then
  case "$DOMAIN_FILTER" in
    engineering|personal|ops|general)
      ;;
    *)
      echo "check_index_consistency: invalid --domain '$DOMAIN_FILTER'" >&2
      exit 2
      ;;
  esac
fi

python3 - "$MEMORY_ROOT" "$DOMAIN_FILTER" "$FIX_MODE" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

memory_root = Path(sys.argv[1])
domain_filter = sys.argv[2]
fix_mode = sys.argv[3] == "1"

domains_root = memory_root / "domains"
if not domains_root.exists():
    print(f"FAIL: domains root not found: {domains_root}")
    raise SystemExit(1)

domains = [domain_filter] if domain_filter else sorted(
    p.name for p in domains_root.iterdir() if p.is_dir()
)

link_re = re.compile(r"\]\(\./sessions/([^)]+\.md)\)")
task_re = re.compile(r"^Task:\s*(.+?)\s*$", re.MULTILINE)

had_error = False

for domain in domains:
    base = domains_root / domain
    index_path = base / "index.md"
    sessions_dir = base / "sessions"

    if not index_path.exists():
        print(f"FAIL [{domain}] missing index: {index_path}")
        had_error = True
        continue

    sessions_files = sorted(p.name for p in sessions_dir.glob("*.md")) if sessions_dir.exists() else []
    index_text = index_path.read_text()
    linked_files = sorted(set(link_re.findall(index_text)))

    missing_targets = sorted(name for name in linked_files if not (sessions_dir / name).exists())
    unindexed = sorted(name for name in sessions_files if name not in linked_files)

    if missing_targets:
        had_error = True
        print(f"FAIL [{domain}] index links with missing targets:")
        for name in missing_targets:
            print(f"  - ./sessions/{name}")

    if unindexed:
        had_error = True
        print(f"FAIL [{domain}] session files missing from index:")
        for name in unindexed:
            print(f"  - {name}")

    if fix_mode and unindexed:
        lines = index_text.splitlines()
        insert_at = 1 if lines and lines[0].startswith("# ") else 0
        if len(lines) >= 2 and lines[1].strip() == "":
            insert_at = 2
        additions = []
        for name in unindexed:
            file_path = sessions_dir / name
            text = file_path.read_text()
            m = task_re.search(text)
            summary = (m.group(1).strip() if m else name.removesuffix(".md").replace("--", " "))
            date_part = name[:10] if re.match(r"^\d{4}-\d{2}-\d{2}", name) else "0000-00-00"
            additions.append(f"- {date_part}: [{summary}](./sessions/{name})")
        lines[insert_at:insert_at] = additions
        index_path.write_text("\n".join(lines) + "\n")
        print(f"FIX [{domain}] added {len(additions)} missing index entries")

if had_error and not fix_mode:
    raise SystemExit(1)
if had_error and fix_mode:
    print("RESULT: fixed what was safe to add; rerun without --fix to confirm clean state")
    raise SystemExit(0)

print("OK: index/session consistency checks passed")
PY
