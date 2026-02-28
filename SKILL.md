---
name: journal-default
description: Default scoped journaling workflow. Use for meaningful tasks to keep concise logs, decisions, outcomes, proactive improvements, and safe redaction while isolating context by domain.
---

# Journal Default

## Goals
- Keep concise, readable memory for meaningful work.
- Prevent cross-topic pollution through domain scoping.
- Surface durable improvements from recurring friction.
- Keep memory safe by default with redaction-first logging.

## Runtime Prerequisites
- `bash`
- `python3`
- `rg` (ripgrep)
- `obsidian-cli` optional (for vault-aware root resolution)

## Memory Root (Agent-Agnostic)
Resolve memory root in this order:
1. `MEMORY_ROOT`
2. `OBSIDIAN_MEMORY_ROOT`
3. `CODEX_MEMORY_ROOT` (legacy compatibility)
4. `obsidian-cli print-default --path-only`
5. open vault from `~/Library/Application Support/obsidian/obsidian.json`
6. `~/memory-root`

Use these paths under the resolved root:
- Domain indexes: `<memory_root>/domains/<domain>/index.md`
- Sessions: `<memory_root>/domains/<domain>/sessions/`
- Weekly reviews: `<memory_root>/domains/ops/reviews/`
- Monthly history reviews: `<memory_root>/domains/ops/reviews/history/`
- Templates: `<memory_root>/templates/`
- Triage fallback: `<memory_root>/inbox/triage.md`

## Obsidian CLI Usage
Prefer `obsidian-cli` for vault-aware operations:
- locate vault: `obsidian-cli print-default --path-only`
- search notes: `obsidian-cli search-content "<query>"`
- create notes: `obsidian-cli create "domains/<domain>/sessions/<file>" --content "<content>"`
- move/rename notes: `obsidian-cli move "<old>" "<new>"`

Direct markdown edits are acceptable for deterministic updates when path is already known.

If `obsidian-cli` is missing and the user is using Obsidian-managed memory, explicitly ask the user to install it before continuing with vault-aware operations.

## Deterministic Workflow (Preferred)
Use scripts first instead of ad-hoc note edits:
- initialize baseline structure safely:
  - `scripts/bootstrap_memory.sh`
  - use `scripts/bootstrap_memory.sh --force` only to intentionally reset baseline files
- write/update session + index entry:
  - `scripts/write_session.sh --domain <domain> --title "<task title>" --summary "<index summary>"`
- verify index/session connectivity:
  - `scripts/check_index_consistency.sh`
- repair missing index entries:
  - `scripts/check_index_consistency.sh --fix`

## Domain Routing
Choose one domain per task:
- `engineering`: code/CI/tooling/architecture/bugs
- `personal`: life/admin/non-work
- `ops`: incidents/runbooks/reliability/process ops
- `general`: unclear/mixed

If unclear, use `general`. See `references/domain-routing.md` for hints.

## Meaningfulness Gate
Write/update memory only if at least one is true:
1. durable decision made,
2. files/config/workflow changed,
3. actionable diagnostic findings produced,
4. policy/process/automation updated.

Do not log pure chat, acknowledgements, navigation-only steps, or no-op checks.
Batch micro-steps into one entry per meaningful milestone.

## Session Convention
- File: `YYYY-MM-DD--short-title.md`
- Location: selected domain `sessions/`
- Reuse same file for same task/day when practical.

## Session Naming Constraints
- Use lowercase ASCII kebab-case for `short-title` (`a-z`, `0-9`, `-` only).
- Keep slugs stable and task-specific; avoid generic names like `notes` or `update`.
- Keep filenames deterministic: same task + same day should resolve to the same slug.
- Do not include agent/model names in filenames.

## Required Session Blocks
1. `## Objective`
2. `## Actions`
3. `## Decisions`
4. `## Outcome`
5. `## Next Step`
6. `## Improvement Radar`

`Improvement Radar` must include:
- `Observed Friction`
- `Suggested Improvement`
- `Confidence: low|medium|high`

## Sensitive Data Rule
Never store secrets/auth/sensitive tokens/passwords/private keys/session credentials.
Redact before writing (example: `[REDACTED_TOKEN]`).

## Index Update
After meaningful progress, append a short summary link to the domain index.

## Weekly Review
- Due when `now_utc >= next_due_utc` in `domains/ops/reviews/_cadence.md`.
- Generate with `scripts/weekly_memory_review.sh`.
- On completion update cadence fields:
  - `last_completed_utc`
  - `next_due_utc`
  - `last_review_note`

## Monthly History Hygiene (Advisory)
- Due when `now_utc >= next_due_utc` in `domains/ops/reviews/_history_hygiene_cadence.md`.
- Generate report with `scripts/monthly_memory_history_review.sh`.
- Report-only by default; no history rewrite unless explicitly requested.

## Scope Safety
- Never auto-load unrelated domain notes.
- Cross-reference domains only on explicit user request.
- Keep note structure agent-neutral (no agent-specific markers).

## Style
- Brief, factual, decision-focused.
