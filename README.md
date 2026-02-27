# journal-default-skill

Agent-agnostic journaling policy for AI assistants.

This repo works with Codex, Claude, Cursor agents, and any agent that can read Markdown instructions and run shell scripts.

## What It Enforces
- domain-scoped memory
- meaningfulness gate (no noisy logs)
- promise integrity (no fake "I will remember")
- sensitive-data redaction
- weekly review cadence
- monthly history hygiene report

## Send This Repo To Any Agent
Share this repo URL and say:

```text
Install and use this repo as my default journaling policy. Run scripts/bootstrap_memory.sh, then enforce SKILL.md + UNIVERSAL_AGENT_PROMPT.md rules on meaningful tasks.
```

## Quick Start (Any Agent)
1. Clone this repo.
2. Set optional memory path:
- `export MEMORY_ROOT=~/agent-memory`
3. Bootstrap storage:
- `./scripts/bootstrap_memory.sh`
4. Use policy docs:
- `SKILL.md`
- `UNIVERSAL_AGENT_PROMPT.md`
5. Run periodic checks:
- `./scripts/weekly_memory_review.sh`
- `./scripts/monthly_memory_history_review.sh`

## Files
- `SKILL.md`: core policy
- `UNIVERSAL_AGENT_PROMPT.md`: copy-paste policy for non-Codex agents
- `references/domain-routing.md`: routing hints
- `scripts/bootstrap_memory.sh`: deterministic memory layout + trackers
- `scripts/memory_lint.sh`: commit-blocking linter for memory repos
- `scripts/weekly_memory_review.sh`: weekly review generator
- `scripts/monthly_memory_history_review.sh`: monthly history hygiene report

## Storage Path
All scripts use `MEMORY_ROOT` when set.
Fallback default is `~/.codex/memory`.

## Codex-Specific Install
Copy this folder into `$CODEX_HOME/skills/journal-default`.
