#!/bin/bash

# Stop hook: suggests /half-clone when context usage exceeds 85%.
# When triggered, it blocks Claude from stopping and tells it to run /half-clone,
# which creates a new conversation with only the later half to continue in.
# Installed automatically by CLA install.sh into $CLAUDE_CONFIG_DIR/settings.json.
# Manual install: add to settings.json hooks.Stop array:
#   {"hooks":[{"type":"command","command":"bash $CLAUDE_CONFIG_DIR/scripts/check-context.sh"}]}

if ! command -v jq > /dev/null 2>&1; then
    echo '{"decision":"block","reason":"jq is not installed. The context check hook requires jq. Install it: https://jqlang.github.io/jq/download/"}'
    exit 0
fi

input=$(cat)

# Prevent infinite loops - exit if already triggered by a stop hook
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')
if [[ "$stop_hook_active" == "true" ]]; then
    exit 0
fi

transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
    exit 0
fi

max_context=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Calculate context usage from transcript (same method as context-bar.sh)
context_length=$(jq -s '
    map(select(.message.usage and .isSidechain != true and .isApiErrorMessage != true)) |
    last |
    if . then
        (.message.usage.input_tokens // 0) +
        (.message.usage.cache_read_input_tokens // 0) +
        (.message.usage.cache_creation_input_tokens // 0)
    else 0 end
' < "$transcript_path")

if [[ -z "$context_length" || ! "$context_length" =~ ^[0-9]+$ || "$context_length" -eq 0 ]]; then
    exit 0
fi

if [[ -z "$max_context" || ! "$max_context" =~ ^[0-9]+$ || "$max_context" -eq 0 ]]; then
    exit 0
fi

pct=$((context_length * 100 / max_context))

if [[ $pct -ge 85 ]]; then
    echo "{\"decision\": \"block\", \"reason\": \"Context usage is at ${pct}%. Please run /half-clone to create a new conversation with only the later half so a new agent can continue there.\"}"
fi
