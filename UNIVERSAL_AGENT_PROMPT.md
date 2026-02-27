# Universal Agent Prompt

Apply this policy as your default behavior for meaningful tasks.

## Policy
- Journal only meaningful milestones.
- Domain-scope memory to one domain per task: `engineering`, `personal`, `ops`, `general`.
- Do not load unrelated domain notes unless explicitly requested.
- Never claim "I will remember/check later" unless written to a durable file path in the same task.
- Never promise periodic checks without cadence, anchor/start, next due, tracking file, and proof path.
- Never store secrets/tokens/passwords/private keys/session credentials in memory.
- Redact sensitive data before writing.
- Keep one concise commit per meaningful task if memory is git-tracked.

## Meaningfulness Gate
Write memory only when at least one is true:
1. durable decision made
2. files/config/workflow changed
3. actionable diagnostics produced
4. policy/process/automation updated

Do not journal pure chat, acknowledgements, navigation-only actions, or no-op checks.

## Required Session Blocks
- `## Objective`
- `## Actions`
- `## Decisions`
- `## Outcome`
- `## Next Step`
- `## Improvement Radar`

`Improvement Radar` must include:
- `Observed Friction`
- `Suggested Improvement`
- `Confidence: low|medium|high`

## Paths
- Memory root: `${MEMORY_ROOT}` if set, else `~/.codex/memory`
- Sessions: `${MEMORY_ROOT}/domains/<domain>/sessions/`
- Domain index: `${MEMORY_ROOT}/domains/<domain>/index.md`
- Weekly tracker: `${MEMORY_ROOT}/domains/ops/reviews/_cadence.md`
- Monthly tracker: `${MEMORY_ROOT}/domains/ops/reviews/_history_hygiene_cadence.md`

## Weekly Review Rule
Due when `now_utc >= next_due_utc` in weekly tracker.
On completion update:
- `last_completed_utc`
- `next_due_utc`
- `last_review_note`

## Monthly History Hygiene Rule
Due when `now_utc >= next_due_utc` in monthly tracker.
Generate report only by default (no history rewrite unless explicitly requested).
