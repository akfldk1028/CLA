---
name: half-clone
description: Clone the later half of the current conversation, discarding earlier context to reduce token usage while preserving recent work.
---

Clone the later half of the current conversation, discarding earlier context to reduce token usage while preserving recent work.

Steps:
1. Determine the Claude config directory: `CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
2. Get the current session ID and project path: `tail -1 "$CLAUDE_DIR/history.jsonl" | jq -r '[.sessionId, .project] | @tsv'`
3. Find half-clone-conversation.sh with bash: `find "$CLAUDE_DIR" -name "half-clone-conversation.sh" 2>/dev/null | sort -V | tail -1`
   - This finds the script whether installed via plugin or manual symlink
   - Uses version sort to prefer the latest version if multiple exist
4. Preview the conversation to verify the session ID: `<script-path> --preview <session-id> <project-path>`
   - Check that the first and last messages match the current conversation
5. Run the clone: `<script-path> <session-id> <project-path>`
   - Always pass the project path from the history entry, not the current working directory
6. Tell the user they can access the half-cloned conversation with `claude -r` and look for the one marked `[HALF-CLONE <timestamp>]` (e.g., `[HALF-CLONE Jan 7 14:30]`). The script automatically appends a reference to the original conversation at the end of the cloned file.
