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

## Paths
- Memory root: `${MEMORY_ROOT}` if set, else `~/.codex/memory`
- Domain indexes: `<memory_root>/domains/<domain>/index.md`
- Sessions: `<memory_root>/domains/<domain>/sessions/`
- Weekly reviews: `<memory_root>/domains/ops/reviews/`
- Monthly history reviews: `<memory_root>/domains/ops/reviews/history/`
- Templates: `<memory_root>/templates/`
- Triage fallback: `<memory_root>/inbox/triage.md`

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

## Style
- Brief, factual, decision-focused.
