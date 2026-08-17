#!/usr/bin/env bash
# Authoritative status of recent codex-rescue dispatches.
#
# WHY THIS EXISTS (2026-08-06): the codex-rescue forwarder returns a launch
# receipt ("Codex Task started in the background as task-…") and the agent
# "completed" notification fires on that receipt — NOT on the work finishing.
# A job that failed hard in 298ms is therefore indistinguishable from a job
# still running, unless you read the job state file. One such failure cost
# ~50 minutes of waiting on work that was never scheduled.
#
# The job JSON is the truth: .status is queued|running|completed|failed and
# .errorMessage carries the reason. Run this instead of guessing.
#
# Usage: codex-job-status.sh [N]     (default: 10 most recent jobs)

set -euo pipefail

STATE_DIR="$HOME/.claude/plugins/data/codex-openai-codex/state"
LIMIT="${1:-10}"

[ -d "$STATE_DIR" ] || { echo "no codex plugin state at $STATE_DIR"; exit 0; }

# Newest job files across every workspace namespace. The namespace is derived
# from the dispatch's cwd, so the same repo shows up under several keys when
# worktrees are involved — that split is exactly what breaks --resume-last.
# `head` closing the pipe early makes ls/xargs die on SIGPIPE; with `set -o
# pipefail` that would report a nonzero exit for a perfectly good read, which
# is the exact "looks like a failure but isn't" confusion this script exists to
# remove. Materialize the list first, then iterate.
jobs_list="$(find "$STATE_DIR" -name 'task-*.json' -type f -print0 2>/dev/null \
  | xargs -0 ls -t 2>/dev/null | head -n "$LIMIT" || true)"

[ -n "$jobs_list" ] || { echo "no codex jobs recorded yet"; exit 0; }

printf '%s\n' "$jobs_list" | while read -r job; do
      python3 - "$job" <<'PY'
import json, sys, datetime
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as fh:
        j = json.load(fh)
except Exception as exc:  # a half-written job file is not worth crashing on
    print(f"?? unreadable {path}: {exc}")
    sys.exit(0)

status = j.get("status", "?")
mark = {"completed": "OK  ", "failed": "FAIL", "running": "RUN ", "queued": "WAIT"}.get(status, "??  ")

started, done = j.get("startedAt"), j.get("completedAt")
dur = ""
if started and done:
    try:
        fmt = "%Y-%m-%dT%H:%M:%S.%f%z"
        delta = (datetime.datetime.strptime(done.replace("Z", "+0000"), fmt)
                 - datetime.datetime.strptime(started.replace("Z", "+0000"), fmt))
        dur = f" {delta.total_seconds():.1f}s"
    except Exception:
        pass

print(f"{mark} {j.get('id','?')}{dur}")
print(f"     title : {j.get('title','?')}  (resumeLast={j.get('request',{}).get('resumeLast')})")
print(f"     cwd   : {j.get('request',{}).get('cwd','?')}")
if j.get("errorMessage"):
    print(f"     ERROR : {j['errorMessage']}")
PY
    done
