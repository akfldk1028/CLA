---
name: ac-status
description: "Check Auto-Claude daemon and task status. Shows running specs, pipeline phases, and daemon health."
---

Check Auto-Claude daemon and task status for the current project.

---

## Step 1: Locate status files

Look for `.auto-claude/` in the current project root (`$(pwd)`).

If `.auto-claude/` doesn't exist, tell the user: "No .auto-claude/ directory found. This project hasn't been used with Auto-Claude yet." and stop.

## Step 2: Read daemon status

Check `.auto-claude/daemon_status.json`. If it exists, extract:
- `status`: running / stopped
- `uptime`: how long the daemon has been running
- `active_tasks`: number of currently executing tasks
- `ws_port`: WebSocket port (if present)

If the file doesn't exist or is stale (modified >5 minutes ago), report "Daemon: not running or status file stale".

## Step 3: List specs

Read directories in `.auto-claude/specs/`. For each spec directory:
- Read `implementation_plan.json` for `status`, `executionPhase`, `taskType`
- Read `spec.md` first line for the title (if exists)

Display as a table:

```
| Spec | Title | Status | Phase | Type |
|------|-------|--------|-------|------|
| 001  | ...   | queue  | ...   | impl |
```

If no specs found, report "No specs found."

## Step 4: Recent events

Read the last 5 lines of `.auto-claude/specs/*/events.jsonl` (from the most recently modified spec). Show event type and timestamp.

If no events found, skip this section.

## Step 5: Summary

Show a one-line summary:
```
Daemon: running | Specs: 3 total (1 active, 1 queue, 1 done)
```
