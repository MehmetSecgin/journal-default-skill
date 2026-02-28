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

## Open Source Collaboration
- Anyone can open an issue: https://github.com/MehmetSecgin/journal-default-skill/issues
- Anyone can submit a pull request: https://github.com/MehmetSecgin/journal-default-skill/pulls

Ask your agent to contribute with this prompt:

```text
Read this repo, propose one concrete improvement, open a GitHub issue describing the change, implement it in a branch, and open a PR with rationale and before/after behavior.
```

## Quick Start (Any Agent)
1. Clone this repo.
2. Set optional memory path:
- `export MEMORY_ROOT=~/agent-memory`
- or `export OBSIDIAN_MEMORY_ROOT=~/memory-root`
3. Bootstrap storage:
- `./scripts/bootstrap_memory.sh`
  - add `--force` only when intentionally resetting baseline files
4. Use policy docs:
- `SKILL.md`
- `UNIVERSAL_AGENT_PROMPT.md`
5. Run periodic checks:
- `./scripts/weekly_memory_review.sh`
- `./scripts/monthly_memory_history_review.sh`
6. Prefer deterministic session operations:
- `./scripts/write_session.sh --domain engineering --title "..." --summary "..."`
- `./scripts/check_index_consistency.sh`

## Prerequisites
- `bash`
- `python3`
- `rg` (ripgrep)
- `git` (recommended for memory history checks/lint)
- `obsidian-cli` (optional; used when available for vault discovery)

## Update Skill From Repo
When an agent is asked to "update the skill from its repo", run:
1. `git fetch --all --prune`
2. `git pull --ff-only`
3. `bash -n scripts/*.sh`
4. `./scripts/check_index_consistency.sh --help`
5. Re-read `SKILL.md` and `UNIVERSAL_AGENT_PROMPT.md` and apply the new policy.

If this repo is copied into another tool-specific skills folder, sync these files exactly:
- `SKILL.md`
- `UNIVERSAL_AGENT_PROMPT.md`
- `references/domain-routing.md`
- `scripts/*.sh`

## Files
- `SKILL.md`: core policy
- `UNIVERSAL_AGENT_PROMPT.md`: copy-paste policy for non-Codex agents
- `references/domain-routing.md`: routing hints
- `scripts/bootstrap_memory.sh`: deterministic memory layout + trackers
- `scripts/memory_lint.sh`: commit-blocking linter for memory repos
- `scripts/weekly_memory_review.sh`: weekly review generator
- `scripts/monthly_memory_history_review.sh`: monthly history hygiene report
- `scripts/resolve_memory_root.sh`: shared memory-root resolver
- `scripts/write_session.sh`: deterministic session write + index append
- `scripts/check_index_consistency.sh`: verify/fix session index links

## Storage Path
All scripts use `MEMORY_ROOT` when set.
Then `OBSIDIAN_MEMORY_ROOT` if set.
Fallback default is `~/memory-root`.

## Codex-Specific Install
Copy this folder into `$CODEX_HOME/skills/journal-default`.
