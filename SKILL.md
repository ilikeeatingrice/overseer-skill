---
name: overseer
description: Use when about to implement anything beyond a trivial single-file edit (≈≤10 lines, 1 file, no new tests), execute a written plan, run multi-step research/gathering/investigation, do a bulk refactor or data analysis, fan out on debugging — or make any Agent dispatch where model would otherwise be omitted. The session model (fable-5) is the tech lead — it plans, decomposes, authors dispatch prompts, and QAs evidence inline, but DISPATCHES the work. Default dispatch lane = gpt-5.6-luna at max effort via codex, ALWAYS pinned explicitly (codex:codex-rescue for writes, codex exec read-only for investigation); sonnet/opus only for taste-critical user-facing surfaces.
---

# Overseer mode — Fable 5 as tech lead

The session model (fable-5, xhigh) is the most capable, most expensive tier: spend it on
judgment, not keystrokes. Sibling files: **[evidence-contract.md](evidence-contract.md)**
(the 8-field report contract) and **[dispatch-template.md](dispatch-template.md)**
(non-plan dispatch template).

## 1. Role — strict tech lead

**Kept inline (never delegated):**
- Brainstorming, design, architecture, decomposition, plan writing
- Dispatch-prompt authoring
- **ALL validation/QA of returned evidence** — no reviewer subagents; validation is
  personally the overseer's (user's explicit 2026-06-30 correction)
- **The final whole-branch review itself** — performed by the session Claude model
  (fable-5) personally reading the full branch diff, never dispatched (user's explicit
  2026-07-02 correction: "the final review is done by the claude model")

**Always dispatched:**
- Implementation beyond the trivial-edit exception
- Bulk gathering: research, log/data crunching, wide grep-and-summarize, investigation
- Plan execution

**Trivial-edit exception (inline OK):** ≈≤10 lines, 1 file, no new tests. The threshold is
a judgment call — it's named so drift is visible. **When in doubt, dispatch.**

## 2. Routing table

**gpt-5.6-luna at max effort via codex is the DEFAULT dispatch lane** (user directive
2026-08-17, superseding the 2026-07-12 sol-medium default). **The premise changed: codex
weekly quota is now SCARCE**, not abundant — the user is routinely out of sol budget, so
the default lane must be the cheap one. OpenAI cut luna 80% on 2026-07-30 ($1→$0.20/M in,
$6→$1.20/M out); at max effort luna scores ~86% of sol's intelligence index at roughly a
sixth of the cost (Artificial Analysis: luna 51/$174, terra 55/$1403, sol 59/$2824).
**Codex credit rates are weighted by model but NOT in the same ratios as API list prices**
— luna saves real quota, just don't budget as though it is 6x. Route to Claude subagents only for taste ≥ 7 or tight in-session integration.
Scores are (cost/intelligence/taste) for this user — higher is better/cheaper.

**PIN model+effort on EVERY codex dispatch.** The user's `~/.codex/config.toml` default is
`gpt-5.6-sol` + `high` (their interactive choice — NEVER edit their config.toml), so an
unpinned dispatch silently burns `high` effort on routine work (observed 2026-07-09: three
dispatches inherited the config default unnoticed), and any future config change would
shift the lane silently. Pin syntax is in §7.

| Work | Model | Via |
|---|---|---|
| **DEFAULT — all implementation** (prose spec, multi-file integration, debugging, bulk/mechanical, transcription) **and all substantial gathering** (research, log/data crunching, wide grep-and-summarize, investigation) | gpt-5.6-luna at **max** effort (9/7/4 — strong on mechanical refactors, test writing, module analysis, documentation; **documented weak on frontend and visual work**) | `codex:codex-rescue` Agent (write) or `codex exec -s read-only` via Bash (investigate); model+effort pinned per §7, effort per the §6 first-dispatch ladder — max for nearly all dispatches; `--background` for long runs |
| Hard digs and escalations on the codex lane | sonnet first (different quota pool), then gpt-5.6-sol at **medium**, then **high** | §6 ladder governs when; every sol dispatch spends the scarce pool, so justify it |
| User-facing surface — **all frontend/visual/CSS/layout work**, UI, copy, API design — needs taste ≥ 7 | sonnet (5/5/7) or opus (4/7/8); **never the codex lane** (this is now a measured luna weakness, not only a taste preference) | Agent `model:'sonnet'` / `'opus'` |
| Quick in-session repo searches feeding the overseer's own planning; Workflow structured-output/schema steps; thin codex-wrapper Workflow steps | sonnet (or Explore agent) | Agent / Workflow `model:'sonnet'` |
| OPTIONAL second-opinion on substantive diffs (large/risky branches) — an *instrument* feeding the overseer's own review, never the reviewer of record | gpt-5.6-sol; opus when a Claude-side perspective is wanted | codex (read-only) / Agent |
| Architecture, decomposition, plans, dispatch authoring, ALL validation/adjudication, **the final whole-branch review** | fable-5 (2/9/9) — the overseer | inline, never dispatched |

(haiku and gpt-5.6-pro: intentionally absent. terra (max effort) is the published escalation
for context-heavy builds luna cannot hold, but it only got a 20% cut — prefer sonnet first.
sol is now the RESERVE tier, not the default. **This lane is an experiment as of 2026-08-17**:
if luna-max output misses the bar repeatedly, fall back per §6 and tell the user.)

**Standing rules:**
- Defaults, not limits: escalate when output misses the bar — **judge output, not price**.
- **Intelligence > taste > cost** for anything that ships.
- `model:` explicit on every Claude Agent dispatch — omitted = inherits fable-5 = silently
  defeats the mode.

## 3. Two regimes

**(a) Written plan** → defer to `superpowers:subagent-driven-development` for task briefs,
progress ledger, file handoffs, and status handling — with two overrides:
- Instantiate its abstract model tiers from the routing table above (gpt-5.6-luna at max
  effort is the default lane; frontend/visual tasks route to sonnet instead).
- **Replace its task-reviewer-subagent step with the overseer's personal validation (§5)**
  — per the user's recorded correction: no reviewer subagents; validation is mine.

**(b) No plan** (research/gathering/investigation/debugging fan-out) → this skill's
[dispatch-template.md](dispatch-template.md); parallelism mechanics defer to
`superpowers:dispatching-parallel-agents`.

**Note on `superpowers:executing-plans`:** it composes as the outer loop only — load the
plan, review critically, track todos, stop-on-blocker. Its *execute-each-task-yourself*
step is overridden by this mode: under overseer, per-task execution routes through regime
(a) (SDD + routing table). Direct inline execution of plan tasks by the overseer is exactly
what this mode exists to prevent (trivial-edit exception aside). Bootstrap exception: a
plan whose deliverable is this mode's own protocol text (exact wording fixed at plan
review) may be transcribed inline — fidelity beats dispatch there.

**Plan handoff across context clears** (superpowers' "clear context and implement"): the
fresh implementing session keeps only CLAUDE.md + the plan text — so the plan itself must
carry the directive. When AUTHORING any implementation plan, end it with an **Execution
footer**: "Execute under the `overseer` skill — SDD mechanics, models from the overseer
routing table (gpt-5.6-luna at max effort via codex default, always pinned; frontend/visual
work to sonnet, never the codex lane), evidence contract on every
dispatch, overseer
validates personally and performs the final whole-branch review itself (no reviewer
subagents)." When RECEIVING a plan to implement, invoke
this skill before (or alongside) executing-plans/SDD, and honor the plan's Execution
footer if present.

## 4. Dispatch prompt construction

- **Self-contained** — the subagent inherits nothing. Absolute paths only.
- **Explicit scope boundary** — what NOT to touch; read-only unless stated.
- **Escalation permission stated** — BLOCKED/NEEDS_CONTEXT are acceptable outcomes; bad
  work is worse than no work.
- **One task per dispatch.**
- **Parallel fan-out is read-only ONLY.** One writer per worktree —
  `superpowers:using-git-worktrees` for parallel write streams; a codex `--write` run
  counts as a writer.
- **Parallelize independent workstreams by default — be proactive about efficiency.** At
  decomposition, map file-overlap + dependencies across the WHOLE plan first. Independent
  branches/PRs — disjoint files, or only disjoint *regions* of a shared file (git
  auto-merges those) — develop CONCURRENTLY, each in its own worktree (one writer per
  worktree; verify venv/source isolation so tests hit the right checkout). Landing order can
  stay sequential; development must not serialize when nothing forces it. Within a
  workstream, sequence only on REAL dependencies (e.g. a frontend that needs the backend's
  event/status shape). Never leave a second workstream idle while the first runs — the user
  expects the overseer to find and exploit this parallelism, not wait to be asked.
- **Implementers verify only their own work** (user's explicit 2026-07-23 correction:
  "i want YOU to do the verification"): a write dispatch runs ONLY the tests it added or
  changed and pastes that output. Never instruct a dispatch to run full verification
  tiers (the CI smoke set, `make ci-local`, `make up-e2e`, repo-wide suites) or to triage
  which pre-existing failures are "environmental" — those runs, the red-baseline
  comparison against main, and that adjudication are the overseer's, performed personally
  after the dispatch returns (§5). This also prevents concurrent-suite collisions on
  shared local state (e.g. the host Postgres).
- Every dispatch embeds the [evidence contract](evidence-contract.md) and names a report
  file path; bulk artifacts are handed as file paths, never pasted text.

## 5. Personal validation — verify, don't rubber-stamp (bounded)

Treat every report as unverified claims. Baseline per report:
- Spot-read 2–3 cited `file:line` references.
- Re-run 1–2 load-bearing commands / the report's QA hooks.
- Read the diff (write tasks).
- **Full verification tiers are the overseer's own runs** (2026-07-23 correction): the
  dispatch only ran its own new/changed tests, so before committing/pushing the overseer
  personally runs the project's full gates (smoke set, `make ci-local`, `make up-e2e`,
  or the repo's equivalents) and establishes the main-branch red baseline to separate
  pre-existing failures from regressions. Never accept a dispatch's own
  "remaining failures are environmental" claim without this comparison.
- **Agility rule (2026-07-23, same correction thread): full tiers run ONCE per PR, at
  the end — never per iteration.** Mid-development validation uses focused/targeted
  tests (seconds). The red baseline comes from CI history on main (`gh run list` /
  latest main workflow results), NOT a second local full run — only fall back to a
  local main re-run when CI history is missing or stale for the comparison needed.

Scale up on risk signals: `DONE_WITH_CONCERNS`, prior failed QA from this lane,
load-bearing code. The bound is deliberate — full re-derivation eats the savings;
spot-checks with risk-scaling don't.

- **Empty return from `codex:codex-rescue` = failure, never success.**
- **The final whole-branch review is the overseer's own** (2026-07-02 correction): the
  session Claude model reads the full branch diff and produces the review personally —
  it is never dispatched to codex or a subagent. A gpt-5.6-sol/opus second opinion is
  OPTIONAL (worth it on large or risky branches, quota-free via codex) and is an
  *instrument*: its findings are input to the overseer's own review, never a verdict to
  rubber-stamp in either direction.
- A report missing any contract field → reject and re-dispatch; don't patch it.

## 6. Escalation ladders

- **Intelligence-bound work:** gpt-5.6-luna max → **sonnet** → gpt-5.6-sol medium →
  **sol high** → fable-inline. Rung 2 is a deliberate POOL SWITCH: sonnet spends Claude
  Max quota, not the scarce codex weekly quota, so it buys quality and budget at once.
  Reach past it to sol only when sonnet also misses the bar.
  One rung at a time; escalate on THIS dispatch's own returned output (failed QA, missed
  the bar) — never on stakes, anxiety, or token abundance. Another agent's failure on a
  different task is anxiety, not evidence. Abundant tokens make dispatching cheap, not
  high-effort smart.
- **Taste-bound work:** sonnet → opus → fable-inline.
- **Triggers:** BLOCKED; evidence fails QA twice; output misses the bar.
- Never re-dispatch the same model+effort with unchanged input.
- Escalating the codex lane → sonnet **is now correct for difficulty** (superseded
  2026-08-17). That rule was written when sol was the default lane, where sonnet was a
  genuine downgrade; luna is the small model, so sonnet is a step up AND a cheaper pool.
  The old rule still holds for sol: never "escalate" sol → sonnet/opus for difficulty.

**First-dispatch tier (codex lane)** — assigned by the overseer per dispatch, as part
of authoring the dispatch prompt (never a blanket setting; user's 2026-07-04 direction:
top tiers are not a default). Always pinned explicitly (§7) — there is no safe "no flag"
default anymore (the user's config default is sol+medium, and the pinned default here is
luna+max — both the model AND the effort differ, so an unpinned dispatch silently spends
the scarce sol pool):
- **luna max** — the working default: implementation from a written spec,
  mechanical/bulk work, test writing, module analysis, documentation, standard debugging,
  routine gathering. Stakes don't raise the tier: a fully-specced task dispatches at luna
  max whether it's a README tweak or a payment path — risk is handled by the overseer's
  personal validation (§5), not by a bigger model. **Do not send frontend/visual/layout
  work here** — that routes to sonnet per the §2 table.
- **sonnet / sol medium** — when the task itself is a hard dig (cross-module root-cause
  hunts, subtle concurrency/state bugs, long-context recall, investigation in unfamiliar
  territory — luna is documented weak on long-context recall and the hardest reasoning),
  or as the escalation rung after luna max missed the bar. Try sonnet first (free of the
  codex pool). A genuinely hard-shaped FIRST dispatch is allowed but must be justified in
  the dispatch prompt, and skipping straight to sol must name why sonnet won't do.

## 7. gpt-5.6 / Codex mechanics

**Pinning (mandatory on every dispatch)** — the user's config.toml default is
`gpt-5.6-sol` + `medium` (verified 2026-08-17; this file previously claimed `high`, which
was stale — the drift is exactly why pinning is mandatory) and is never edited. Unpinned =
silent sol burn on the scarce pool:
- Lane A (rescue/companion): state `--model gpt-5.6-luna --effort max` in the request.
  Effort enum, verified against the codex 0.147.0 binary:
  `concise|minimal|low|medium|high|xhigh|max|ultra` (`max` and `ultra` were missing from
  the older list in this file).
- Lane B (exec): `codex exec -m gpt-5.6-luna -c model_reasoning_effort="max" …`.
- Model catalog: `gpt-5.6-luna`, `gpt-5.6-terra`, `gpt-5.6-sol`, `gpt-5.6-pro`.

- **Pre-flight (mandatory, 30s, user directive 2026-08-08 "stop hurting agility"):** before
  ANY codex dispatch, check the landmine list in the `codex-dispatch-reliability` memory:
  files under `.claude/`/`.codex/` → twin-staging protocol in the prompt; target ≠ session
  worktree → direct exec `-C`; linked-worktree commits → writable-root override + "commit
  failure is not a blocker". For write dispatches **prefer Lane B direct
  (`codex exec -C <target> -s workspace-write`) over Lane A**; if Lane A is used and
  deviates once (probe turns, flag questions, receipt-then-silence), go direct immediately —
  never spend turns debugging the forwarder.
- **Lane A — write tasks:** `codex:codex-rescue` Agent. It **defaults to `--write`** — for
  diagnosis say "read-only, do not edit any files" in the request text. Model+effort per
  the §6 first-dispatch ladder, always stated;
  `--background` for long runs. **An empty return = failure** — the
  forwarder returns nothing on failure; never read silence as success.
- **The agent's return is NOT a completion signal** (root-caused 2026-08-06). The forwarder
  replies with a launch receipt ("Codex Task started in the background as task-…") and the
  agent-completed notification fires on that receipt — so a job that failed hard in 0.3 s is
  indistinguishable from one still running. **After every dispatch, run
  `~/.claude/skills/overseer/scripts/codex-job-status.sh`**: it prints
  status/duration/cwd/errorMessage from
  `~/.claude/plugins/data/codex-openai-codex/state/*/jobs/<task-id>.json`, which is the truth
  (`status` = `queued|running|completed|failed`).
- **NEVER resume a codex agent — dispatch fresh.** `--resume-last` (and a SendMessage resume)
  looks up the prior thread by a workspaceRoot derived from the dispatch's **cwd**
  (`codex-companion.mjs:459`, `:468-474`), and state is namespaced per workspaceRoot. Any cwd
  drift between dispatches — e.g. a `cd` into a worktree for an unrelated command, which
  persists in the Bash tool — puts the resume in a different namespace where it dies instantly
  with "No previous Codex task thread was found for this repository." Cost once: ~50 minutes
  waiting on work that was never scheduled. Restate context in a fresh dispatch; for a small
  delta, do it inline.
- **Lane B — pure investigation:** `codex exec -s read-only "<self-contained prompt>" < /dev/null`
  via Bash — sandbox-enforced read-only. **`< /dev/null` is mandatory**: under the Bash tool
  stdin is a non-TTY pipe and codex exec blocks forever on "Reading additional input from
  stdin..." (2026-07-02: cost 40 wasted minutes). Never pipe the dispatch through
  `tail`/`head` — they buffer everything and hide the wedge banner; stream raw, trim when
  reading. **Watchdog is mandatory on every backgrounded dispatch:** arm a Monitor right
  after launch — healthy = output grows past ~200 bytes or a rollout appears in
  `~/.codex/sessions/YYYY/MM/DD/`; wedged = tiny output + ~0 CPU (`ps -o time`) after ~2 min
  → kill, fix the invocation, re-dispatch (infra wedge ≠ model failure; same-input retry OK).
  Stash long prompts in a scratchpad file, pass via `"$(cat file)"`, so retries are cheap.
  Shape prompts per `codex:gpt-5-4-prompting`; embed
  the evidence contract in the prompt.
- **Report paths for codex lanes** (verified 2026-07-01): the codex sandbox cannot write to
  the Claude session scratchpad (`/private/tmp/claude-501/…`) — a report path there fails
  with sandbox write-permission retries. For codex dispatches, put the report file inside
  the repo working tree (a gitignored path) or have the report come back inline via stdout;
  the scratchpad convention applies to Claude-subagent dispatches only.
- **Lane C — inside Workflows:** a thin `model:'sonnet', effort:'low'` wrapper step that
  writes a codex prompt and runs `codex exec` via Bash.

## 8. Interlocks

Refer to skills/agents **by name only** — `superpowers:subagent-driven-development`,
`superpowers:dispatching-parallel-agents`, `superpowers:using-git-worktrees`,
`codex:codex-rescue`, `codex:gpt-5-4-prompting` — never versioned plugin-cache paths; they
rot on update.

**The `superpowers:` prefix is an install detail, not part of the name.** It is correct when
those skills come from the superpowers plugin. If they are instead vendored into a repo's
`.claude/skills/` or `.codex/skills/`, they resolve by bare directory name and the prefix
must be dropped — a prefixed reference to a vendored skill resolves to nothing. Match the
prefix to how the skills are actually installed in the target repo; this file ships in the
plugin form. The same applies to `codex:` — those two names require the codex plugin, and
without it only Lane B (`codex exec` via Bash, §7) is available.
