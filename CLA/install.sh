#!/usr/bin/env bash
#
# install.sh - Install CLA module globally
#
# Installs to $CLAUDE_CONFIG_DIR (fallback: ~/.claude):
# - CLAUDE.md (global behavioral rules)
# - skills/ (10 skills)
# - scripts/ (6 utility scripts)
# - templates/ (7 project templates)
# - settings.json hooks: Stop (check-context), PreToolUse (protect-files), PreCompact (backup-transcript)
# - settings.json permissions: auto-approve read-only tools
#
# Only copies files that have changed (diff -q). Safe to re-run.
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Resolve CLA source directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLA_DIR="$SCRIPT_DIR"

# Target: $CLAUDE_CONFIG_DIR or ~/.claude
# Normalize to forward slashes (Windows/Git Bash compatibility)
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
CONFIG_DIR="${CONFIG_DIR//\\//}"

if [ ! -d "$CONFIG_DIR" ]; then
    log_error "$CONFIG_DIR not found. Install Claude Code first."
    exit 1
fi

# Copy a file only if it differs from the target (idempotent)
copy_if_changed() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$dst" ] || ! diff -q "$src" "$dst" > /dev/null 2>/dev/null; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        return 0  # copied
    fi
    return 1  # skipped (identical)
}

echo ""
echo "=== CLA Module Installer ==="
echo "Source: $CLA_DIR"
echo "Target: $CONFIG_DIR"
echo ""

COPIED=0
SKIPPED=0

# --- CLAUDE.md ---
log_info "CLAUDE.md..."
if copy_if_changed "$CLA_DIR/CLAUDE.md" "$CONFIG_DIR/CLAUDE.md"; then
    log_success "  CLAUDE.md installed"
    COPIED=$((COPIED + 1))
else
    log_success "  CLAUDE.md (unchanged)"
    SKIPPED=$((SKIPPED + 1))
fi

# --- Skills (10) ---
log_info "Skills..."
SKILLS=(handoff half-clone clone gha karpathy-guidelines reddit-fetch review-claudemd cla-init ac ac-status)

for skill in "${SKILLS[@]}"; do
    src="$CLA_DIR/skills/$skill/SKILL.md"
    dst="$CONFIG_DIR/skills/$skill/SKILL.md"
    if [ ! -f "$src" ]; then
        log_warning "  $skill: source not found, skipping"
        continue
    fi
    if copy_if_changed "$src" "$dst"; then
        log_success "  $skill"
        COPIED=$((COPIED + 1))
    else
        log_success "  $skill (unchanged)"
        SKIPPED=$((SKIPPED + 1))
    fi
done

# --- Scripts (6) ---
log_info "Scripts..."
SCRIPTS=(context-bar.sh check-context.sh clone-conversation.sh half-clone-conversation.sh protect-files.sh backup-transcript.sh)

for script in "${SCRIPTS[@]}"; do
    src="$CLA_DIR/scripts/$script"
    dst="$CONFIG_DIR/scripts/$script"
    if [ ! -f "$src" ]; then
        log_warning "  $script: source not found, skipping"
        continue
    fi
    if copy_if_changed "$src" "$dst"; then
        chmod +x "$dst"
        log_success "  $script"
        COPIED=$((COPIED + 1))
    else
        log_success "  $script (unchanged)"
        SKIPPED=$((SKIPPED + 1))
    fi
done

# --- Templates (7) ---
log_info "Templates..."
TEMPLATES=(rust.md flutter.md react.md unity.md backend-node.md backend-python.md auto-claude.md)

for tmpl in "${TEMPLATES[@]}"; do
    src="$CLA_DIR/templates/$tmpl"
    dst="$CONFIG_DIR/templates/$tmpl"
    if [ ! -f "$src" ]; then
        log_warning "  $tmpl: source not found, skipping"
        continue
    fi
    if copy_if_changed "$src" "$dst"; then
        log_success "  $tmpl"
        COPIED=$((COPIED + 1))
    else
        log_success "  $tmpl (unchanged)"
        SKIPPED=$((SKIPPED + 1))
    fi
done

# --- Git hooks (auto-sync on git pull / branch switch) ---
log_info "Git hooks..."

REPO_ROOT="$(cd "$CLA_DIR/.." && git rev-parse --show-toplevel 2>/dev/null)" || true
REPO_ROOT="${REPO_ROOT//\\//}"

GIT_DIR="$(cd "$REPO_ROOT" 2>/dev/null && git rev-parse --git-dir 2>/dev/null)" || true
GIT_DIR="${GIT_DIR//\\//}"
# Make absolute if relative (git rev-parse --git-dir returns relative in normal repos)
[[ "$GIT_DIR" != /* ]] && [ -n "$GIT_DIR" ] && GIT_DIR="$REPO_ROOT/$GIT_DIR"

if [ -n "$REPO_ROOT" ] && [ -n "$GIT_DIR" ] && [ -d "$GIT_DIR/hooks" ]; then
    HOOKS=(post-merge post-checkout)
    for hook in "${HOOKS[@]}"; do
        src="$CLA_DIR/hooks/$hook"
        dst="$GIT_DIR/hooks/$hook"
        if [ ! -f "$src" ]; then
            log_warning "  $hook: source not found, skipping"
            continue
        fi
        # If hook already exists and is NOT ours, don't overwrite
        if [ -f "$dst" ] && ! grep -q "CLA" "$dst" 2>/dev/null; then
            log_warning "  $hook: existing non-CLA hook found, skipping (backup or merge manually)"
            SKIPPED=$((SKIPPED + 1))
            continue
        fi
        if copy_if_changed "$src" "$dst"; then
            chmod +x "$dst"
            log_success "  $hook hook installed"
            COPIED=$((COPIED + 1))
        else
            log_success "  $hook hook (unchanged)"
            SKIPPED=$((SKIPPED + 1))
        fi
    done
else
    log_warning "  Not a git repo or hooks dir not found, skipping git hooks"
fi

# --- Stop hook in settings.json ---
log_info "Checking settings.json for Stop hook..."

SETTINGS_FILE="$CONFIG_DIR/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    log_warning "settings.json not found, creating minimal one"
    echo '{}' > "$SETTINGS_FILE"
fi

# Build the hook command with the correct CONFIG_DIR path
HOOK_CMD="bash ${CONFIG_DIR}/scripts/check-context.sh"

if grep -q "check-context.sh" "$SETTINGS_FILE" 2>/dev/null; then
    log_success "  Stop hook already exists, skipping"
else
    if command -v jq > /dev/null 2>/dev/null; then
        # Use --arg (not --argjson) to safely handle paths with spaces
        jq --arg cmd "$HOOK_CMD" '
            .hooks = (.hooks // {}) |
            if .hooks.Stop then
                .hooks.Stop += [{"hooks":[{"type":"command","command":$cmd}]}]
            else
                .hooks.Stop = [{"hooks":[{"type":"command","command":$cmd}]}]
            end
        ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        log_success "  Stop hook added"
    else
        log_warning "jq not found - please manually add Stop hook to settings.json:"
        echo "  \"Stop\": [{\"hooks\":[{\"type\":\"command\",\"command\":\"${HOOK_CMD}\"}]}]"
    fi
fi

# --- PreToolUse hook (protect-files.sh) ---
log_info "Checking settings.json for PreToolUse hook..."

PROTECT_CMD="bash ${CONFIG_DIR}/scripts/protect-files.sh"

if grep -q "protect-files.sh" "$SETTINGS_FILE" 2>/dev/null; then
    log_success "  PreToolUse hook already exists, skipping"
else
    if command -v jq > /dev/null 2>/dev/null; then
        jq --arg cmd "$PROTECT_CMD" '
            .hooks = (.hooks // {}) |
            if .hooks.PreToolUse then
                .hooks.PreToolUse += [{"hooks":[{"type":"command","command":$cmd}],"matcher":"Edit|Write"}]
            else
                .hooks.PreToolUse = [{"hooks":[{"type":"command","command":$cmd}],"matcher":"Edit|Write"}]
            end
        ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        log_success "  PreToolUse hook added (file protection)"
    else
        log_warning "jq not found - please manually add PreToolUse hook to settings.json"
    fi
fi

# --- PreCompact hook (backup-transcript.sh) ---
log_info "Checking settings.json for PreCompact hook..."

BACKUP_CMD="bash ${CONFIG_DIR}/scripts/backup-transcript.sh"

if grep -q "backup-transcript.sh" "$SETTINGS_FILE" 2>/dev/null; then
    log_success "  PreCompact hook already exists, skipping"
else
    if command -v jq > /dev/null 2>/dev/null; then
        jq --arg cmd "$BACKUP_CMD" '
            .hooks = (.hooks // {}) |
            if .hooks.PreCompact then
                .hooks.PreCompact += [{"hooks":[{"type":"command","command":$cmd}]}]
            else
                .hooks.PreCompact = [{"hooks":[{"type":"command","command":$cmd}]}]
            end
        ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        log_success "  PreCompact hook added (transcript backup)"
    else
        log_warning "jq not found - please manually add PreCompact hook to settings.json"
    fi
fi

# --- Permissions (auto-approve read-only tools) ---
log_info "Checking settings.json for permissions..."

READONLY_PERMS='["Read","Glob","Grep","Bash(git status)","Bash(git diff *)","Bash(git log *)","Bash(git branch *)","Bash(git show *)"]'

if jq -e '.permissions.allow' "$SETTINGS_FILE" > /dev/null 2>/dev/null; then
    log_success "  Permissions already exist, merging..."
    jq --argjson new "$READONLY_PERMS" '
        .permissions.allow = (.permissions.allow + $new | unique)
    ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    log_success "  Read-only permissions merged"
else
    if command -v jq > /dev/null 2>/dev/null; then
        jq --argjson perms "$READONLY_PERMS" '
            .permissions = (.permissions // {}) |
            .permissions.allow = $perms
        ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        log_success "  Read-only permissions added"
    else
        log_warning "jq not found - please manually add permissions to settings.json"
    fi
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "  Copied: $COPIED files"
echo "  Unchanged: $SKIPPED files"
echo ""
echo "Installed to $CONFIG_DIR:"
echo "  - CLAUDE.md (global behavioral rules)"
echo "  - skills/ (${#SKILLS[@]} skills: ${SKILLS[*]})"
echo "  - scripts/ (${#SCRIPTS[@]} scripts)"
echo "  - templates/ (${#TEMPLATES[@]} project templates)"
echo "  - Hooks: Stop (context check), PreToolUse (file protection), PreCompact (transcript backup)"
echo "  - Permissions: auto-approve read-only tools (Read, Glob, Grep, git read commands)"
echo "  - Git hooks (auto-install on git pull/branch switch)"
echo ""
echo "Start a new Claude Code session to apply."
echo ""
