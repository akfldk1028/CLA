#!/bin/bash

# PreCompact hook: backs up transcript before context compression.
# Creates timestamped copy in backups/ next to the transcript file.
# Installed by CLA install.sh into $CLAUDE_CONFIG_DIR/settings.json.

if ! command -v jq > /dev/null 2>&1; then
    exit 0
fi

input=$(cat)

transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
    exit 0
fi

backup_dir="$(dirname "$transcript_path")/backups"
mkdir -p "$backup_dir"

timestamp=$(date +%Y%m%d-%H%M%S)
basename=$(basename "$transcript_path" .jsonl)
cp "$transcript_path" "$backup_dir/${basename}-${timestamp}.jsonl"
