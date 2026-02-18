#!/usr/bin/env bash
#
# install.sh - Install CLA module globally
#
# Installs to $CLAUDE_CONFIG_DIR (fallback: ~/.claude):
# - CLAUDE.md (global behavioral rules)
# - skills/ (8 skills)
# - scripts/ (4 utility scripts)
# - templates/ (6 project templates)
# - settings.json Stop hook (check-context.sh)
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

# --- Skills (8) ---
log_info "Skills..."
SKILLS=(handoff half-clone clone gha karpathy-guidelines reddit-fetch review-claudemd cla-init)

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

# --- Scripts (4) ---
log_info "Scripts..."
SCRIPTS=(context-bar.sh check-context.sh clone-conversation.sh half-clone-conversation.sh)

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

# --- Templates (6) ---
log_info "Templates..."
TEMPLATES=(rust.md flutter.md react.md unity.md backend-node.md backend-python.md)

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
        HOOK_ENTRY="{\"hooks\":[{\"type\":\"command\",\"command\":\"${HOOK_CMD}\"}]}"

        # Add to existing Stop hooks array or create it
        jq --argjson hook "$HOOK_ENTRY" '
            if .hooks.Stop then
                .hooks.Stop += [$hook]
            else
                .hooks = (.hooks // {}) + {"Stop": [$hook]}
            end
        ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        log_success "  Stop hook added"
    else
        log_warning "jq not found - please manually add Stop hook to settings.json:"
        echo "  \"Stop\": [{\"hooks\":[{\"type\":\"command\",\"command\":\"${HOOK_CMD}\"}]}]"
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
echo "  - Stop hook for auto half-clone at >85% context"
echo ""
echo "Start a new Claude Code session to apply."
echo ""
