#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${MEMORY_ROOT:-}" ]]; then
  echo "$MEMORY_ROOT"
  exit 0
fi

if [[ -n "${OBSIDIAN_MEMORY_ROOT:-}" ]]; then
  echo "$OBSIDIAN_MEMORY_ROOT"
  exit 0
fi

if [[ -n "${CODEX_MEMORY_ROOT:-}" ]]; then
  echo "$CODEX_MEMORY_ROOT"
  exit 0
fi

vault_path=""
if command -v obsidian-cli >/dev/null 2>&1; then
  vault_path="$(obsidian-cli print-default --path-only 2>/dev/null || true)"
fi

if [[ -z "$vault_path" ]]; then
  config_path="$HOME/Library/Application Support/obsidian/obsidian.json"
  if [[ -f "$config_path" ]]; then
    vault_path="$(
      python3 - "$config_path" <<'PY'
import json
import sys
from pathlib import Path

cfg = Path(sys.argv[1])
try:
    data = json.loads(cfg.read_text())
except Exception:
    print("")
    raise SystemExit(0)

vaults = data.get("vaults", {})
if not vaults:
    print("")
    raise SystemExit(0)

opened = [v for v in vaults.values() if isinstance(v, dict) and v.get("open")]
pick = None
if opened:
    pick = sorted(opened, key=lambda v: v.get("ts", 0), reverse=True)[0]
else:
    all_vaults = [v for v in vaults.values() if isinstance(v, dict)]
    pick = sorted(all_vaults, key=lambda v: v.get("ts", 0), reverse=True)[0]

print(pick.get("path", ""))
PY
    )"
  fi
fi

if [[ -n "$vault_path" ]]; then
  echo "$vault_path"
  exit 0
fi

echo "$HOME/memory-root"
