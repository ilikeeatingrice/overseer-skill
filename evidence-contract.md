# Evidence contract — every dispatch report carries all 8 fields

Applied to **every** overseer dispatch, and layered on top of
`superpowers:subagent-driven-development` reports when executing a plan. Reports are
verifiable evidence — citations, real command output, test results — not vibes.

**Enforcement rule: a report missing any field is rejected and re-dispatched with the gap
named. The overseer never patches an incomplete report by filling the gaps personally.**

## The 8 fields

1. **Status** — exactly one of `DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED`
   (subagent-driven-development vocabulary). Silent uncertainty is forbidden: if unsure,
   report `DONE_WITH_CONCERNS` or `NEEDS_CONTEXT`, never a bare `DONE`.
2. **Claims → citations** — every factual claim carries a `path:line` citation (or URL for
   external sources). Anything uncited must be explicitly labeled a hypothesis.
3. **Commands run** — the exact command plus its actual trimmed output, **pasted, not
   paraphrased**. Failures included — a command that errored is evidence too.
4. **Test results** (write tasks) — for the tests the dispatch itself added or changed
   ONLY: the test command, pass/fail counts, names of failing tests. When TDD applies:
   RED→GREEN evidence (failing output first, passing after). Full verification tiers
   (smoke set, `make ci-local`, `make up-e2e`, repo-wide suites) are NOT the dispatch's
   job — the overseer runs those personally after the report returns.
5. **Files changed** (write tasks) — list of files + one-line rationale each; commit SHAs
   if anything was committed.
6. **Not verified / assumptions / concerns** — an explicit section. "None" is an
   acceptable value; omitting the section is not.
7. **QA hooks** — the 1–2 commands the overseer should re-run to spot-check the work.
8. **Report file + inline summary** — full detail goes to a named report file (absolute
   path stated in the return); the inline return is ≤15 lines. Bulk detail stays out of
   the overseer's context; bulk artifacts are handed as file paths, never pasted text.

## Overseer side

- Missing field → reject, re-dispatch naming the gap. Don't fix it yourself.
- Empty return (especially from `codex:codex-rescue`) = **failure**, never success.
- Every report is unverified claims until personally validated — see SKILL.md §5.
