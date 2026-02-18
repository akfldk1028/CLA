---
name: review-claudemd
description: Review recent conversations to find improvements for CLAUDE.md files.
---

# Review CLAUDE.md from conversation history

Analyze recent conversations to improve both global and local (project) CLAUDE.md files.

First, determine the Claude config directory:
```bash
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
```

## Step 1: Find conversation history

The project's conversation history is in `$CLAUDE_DIR/projects/`. The folder name is the project path with slashes replaced by dashes.

```bash
# Cross-platform: handles /home/user/project and D:\Data\project
PROJECT_DIR=$(pwd | sed 's|[/\\:_]|-|g')
CONVO_DIR="$CLAUDE_DIR/projects/${PROJECT_DIR}"
ls -lt "$CONVO_DIR"/*.jsonl | head -20
```

## Step 2: Extract recent conversations

Extract the 15-20 most recent conversations (excluding the current one) to a temp directory:

```bash
SCRATCH=/tmp/claudemd-review-$(date +%s)
mkdir -p "$SCRATCH"

for f in $(ls -t "$CONVO_DIR"/*.jsonl | head -20); do
  basename=$(basename "$f" .jsonl)
  # Skip current conversation if known
  cat "$f" | jq -r '
    if .type == "user" then
      "USER: " + (.message.content // "")
    elif .type == "assistant" then
      "ASSISTANT: " + ((.message.content // []) | map(select(.type == "text") | .text) | join("\n"))
    else
      empty
    end
  ' 2>/dev/null | grep -v "^ASSISTANT: $" > "$SCRATCH/${basename}.txt"
done

ls -lhS "$SCRATCH"
```

## Step 3: Spin up Sonnet subagents

Launch parallel Sonnet subagents to analyze conversations. Each agent should read:
- Global CLAUDE.md: `$CLAUDE_DIR/CLAUDE.md`
- Local CLAUDE.md: `./CLAUDE.md` (if exists)
- Batch of conversation files

Give each agent this prompt template:

```
Read:
1. Global CLAUDE.md: $CLAUDE_DIR/CLAUDE.md
2. Local CLAUDE.md: [project]/CLAUDE.md
3. Conversations: [list of files]

Analyze the conversations against BOTH CLAUDE.md files. Find:
1. Instructions that exist but were violated (need reinforcement or rewording)
2. Patterns that should be added to LOCAL CLAUDE.md (project-specific)
3. Patterns that should be added to GLOBAL CLAUDE.md (applies everywhere)
4. Anything in either file that seems outdated or unnecessary

Be specific. Output bullet points only.
```

Batch conversations by size:
- Large (>100KB): 1-2 per agent
- Medium (10-100KB): 3-5 per agent
- Small (<10KB): 5-10 per agent

## Step 4: Aggregate findings

Combine results from all agents into a summary with these sections:

1. **Instructions violated** - existing rules that weren't followed (need stronger wording)
2. **Suggested additions - LOCAL** - project-specific patterns
3. **Suggested additions - GLOBAL** - patterns that apply everywhere
4. **Potentially outdated** - items that may no longer be relevant

Present as tables or bullet points. Ask user if they want edits drafted.
