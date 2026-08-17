# Dispatch template — non-plan work

For research, gathering, investigation, and debugging fan-out — the regime
`superpowers:subagent-driven-development` doesn't cover. (Plan execution → SDD with the
overrides in SKILL.md §3.)

> **`model:` is REQUIRED on every Claude Agent dispatch.** Omitted = inherits fable-5 =
> silently defeats the whole mode. Codex dispatches pin model+effort EXPLICITLY per
> SKILL.md §6/§7 — `gpt-5.6-sol` medium for nearly everything; sol high only when the
> task itself is a hard dig, or as the escalation rung. There is no safe unpinned default
> (user's config default = sol+high — unpinned burns `high` effort on routine work).

Fill every section; a dispatch prompt is self-contained or it is wrong.

---

## Task
One concrete job per dispatch. State what "done" looks like — the artifact or answer, not
the activity.

## Context
Self-contained: the subagent inherits **nothing** from this conversation. Repo and absolute
paths, relevant background, definitions of project-specific terms. Hand bulk inputs as file
paths, never pasted text.

## Scope + constraints
What NOT to touch. **Read-only unless explicitly stated otherwise** — `codex:codex-rescue`
defaults to `--write`, so for pure diagnosis say "read-only, do not edit any files" in the
request text. Budget/time bounds if any.

## Method
Starting points (files, commands, URLs). Allowed commands. Stop conditions — when to stop
digging and report what you have.

## Evidence contract
Your report MUST contain all 8 fields (missing any → rejected and re-dispatched):
1. Status: `DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED`
2. Every factual claim cited `path:line` (or URL); uncited claims labeled hypotheses
3. Commands run: exact command + actual trimmed output (failures included), pasted not paraphrased
4. Test results (write tasks): for YOUR new/changed tests only — command, pass/fail
   counts, failing names; RED→GREEN if TDD. Do NOT run full suites/verification tiers;
   the overseer runs those personally
5. Files changed (write tasks): list + one-line rationale each; commit SHAs if committed
6. Not verified / assumptions / concerns — may be "none", never omitted
7. QA hooks: the 1–2 commands the overseer should re-run to spot-check
8. Full detail → the report file below; inline return ≤15 lines

## Report
Write the full report to: `<absolute path>/report-<task>.md`. For Claude-subagent
dispatches use the session scratchpad; for **codex** dispatches the scratchpad is NOT
sandbox-writable — use a gitignored path inside the repo working tree, or accept the
report inline via stdout. Return only the ≤15-line inline summary (status, headline
findings, report path, QA hooks).

## Escalation
`BLOCKED` and `NEEDS_CONTEXT` are acceptable outcomes — bad work is worse than no work. If
you cannot meet the evidence contract, say so and stop rather than guessing.
