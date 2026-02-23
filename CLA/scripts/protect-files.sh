#!/bin/bash

# PreToolUse hook: blocks Edit/Write on sensitive files.
# Protects: .env, keys/certs, lock files, .git internals.
# Installed by CLA install.sh into $CLAUDE_CONFIG_DIR/settings.json.

if ! command -v jq > /dev/null 2>&1; then
    exit 0
fi

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // empty')
case "$tool_name" in
    Edit|Write) ;;
    *) exit 0 ;;
esac

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
if [[ -z "$file_path" ]]; then
    exit 0
fi

basename=$(basename "$file_path")
deny_reason=""

# .env files
case "$basename" in
    .env|.env.*) deny_reason="Secret file: $basename" ;;
esac

# Key/cert files
if [[ -z "$deny_reason" ]]; then
    case "$basename" in
        *.key|*.pem|*.p12|*.pfx) deny_reason="Key/certificate file: $basename" ;;
    esac
fi

# Lock files
if [[ -z "$deny_reason" ]]; then
    case "$basename" in
        package-lock.json|yarn.lock|pnpm-lock.yaml|Cargo.lock|poetry.lock|uv.lock)
            deny_reason="Lock file: $basename" ;;
    esac
fi

# .git internals
if [[ -z "$deny_reason" ]]; then
    case "$file_path" in
        */.git/*|*\\.git\\*) deny_reason="Git internal file: $file_path" ;;
    esac
fi

if [[ -n "$deny_reason" ]]; then
    jq -n --arg reason "$deny_reason" '{hookSpecificOutput:{permissionDecision:"deny",permissionDecisionReason:$reason}}'
fi
