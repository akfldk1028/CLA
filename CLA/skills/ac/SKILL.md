---
name: ac
description: "Create an Auto-Claude autonomous task from the current conversation context. Requires AC247 backend. Usage: /ac <task description>"
argument-hint: "<task description>"
---

Create an Auto-Claude autonomous task and queue it for the daemon.

**Argument:** `$ARGUMENTS` (required - the task description)

---

## Step 1: Validate argument

If `$ARGUMENTS` is empty, tell the user: "Usage: /ac <task description>" and stop.

## Step 2: Locate AC247 backend

Search for the Auto-Claude backend directory containing `runners/spec_runner.py` in this order:

1. `$AC247_BACKEND` environment variable (if set)
2. `../AC247/Auto-Claude/apps/backend` (relative to current project)
3. `~/AC247/Auto-Claude/apps/backend`

If none found, tell the user:
```
Auto-Claude backend not found. Set $AC247_BACKEND or ensure AC247 is at a standard location.
Expected: runners/spec_runner.py in the backend directory.
```
And stop.

## Step 3: Create the spec

Run from the located backend directory:

```bash
python runners/spec_runner.py --task "$ARGUMENTS" --project-dir "$(pwd)" --no-build
```

The `--no-build` flag creates the spec with `status: "queue"` so the daemon picks it up.

## Step 4: Report result

On success, show:
- Spec number and path (from command output)
- Status: queued for daemon
- Tip: "Start the daemon if not running: `python runners/daemon_runner.py --project-dir $(pwd)`"

On failure, show the error output and suggest checking:
- Python environment (`uv venv` / `pip install -r requirements.txt`)
- Authentication (`claude setup-token`)
