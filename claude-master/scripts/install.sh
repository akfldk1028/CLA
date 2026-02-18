#!/usr/bin/env bash
#
# install.sh - Install claude-master module globally
#
# Installs:
# - ~/.claude/CLAUDE.md (global behavioral rules)
# - ~/.claude/skills/ (7 skills)
# - ~/.claude/scripts/ (4 utility scripts)
# - ~/.claude/settings.json Stop hook (check-context.sh)
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

CLAUDE_DIR="${HOME}/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verify we're in the right repo
if [ ! -f "$REPO_DIR/.claude-plugin/plugin.json" ]; then
    log_error "Cannot find .claude-plugin/plugin.json. Run from claude-master/scripts/"
    exit 1
fi

if [ ! -d "$CLAUDE_DIR" ]; then
    log_error "~/.claude/ directory not found. Install Claude Code first."
    exit 1
fi

# Backup timestamp
BACKUP_TS=$(date +%Y%m%d_%H%M%S)

echo ""
echo "=== Claude Master Module Installer ==="
echo ""

# --- Step 1: Install CLAUDE.md ---
log_info "Installing CLAUDE.md..."
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak.${BACKUP_TS}"
    log_warning "Existing CLAUDE.md backed up to CLAUDE.md.bak.${BACKUP_TS}"
fi
cp "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
log_success "~/.claude/CLAUDE.md installed"

# --- Step 2: Install skills ---
log_info "Installing skills..."
SKILLS=(karpathy-guidelines handoff gha clone half-clone reddit-fetch review-claudemd)
mkdir -p "$CLAUDE_DIR/skills"

for skill in "${SKILLS[@]}"; do
    skill_src="$REPO_DIR/skills/$skill"
    skill_dst="$CLAUDE_DIR/skills/$skill"

    if [ -d "$skill_dst" ]; then
        log_warning "Skill '$skill' already exists, overwriting"
    fi

    mkdir -p "$skill_dst"
    cp "$skill_src/SKILL.md" "$skill_dst/SKILL.md"
    log_success "  $skill"
done

# --- Step 3: Install scripts ---
log_info "Installing scripts..."
mkdir -p "$CLAUDE_DIR/scripts"

SCRIPTS=(context-bar.sh check-context.sh clone-conversation.sh half-clone-conversation.sh)
for script in "${SCRIPTS[@]}"; do
    cp "$REPO_DIR/scripts/$script" "$CLAUDE_DIR/scripts/$script"
    chmod +x "$CLAUDE_DIR/scripts/$script"
    log_success "  $script"
done

# --- Step 4: Add Stop hook to settings.json ---
log_info "Checking settings.json for Stop hook..."

SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    log_warning "settings.json not found, creating minimal one"
    echo '{}' > "$SETTINGS_FILE"
fi

# Check if check-context.sh hook already exists
if grep -q "check-context.sh" "$SETTINGS_FILE" 2>/dev/null; then
    log_success "Stop hook for check-context.sh already exists, skipping"
else
    # Backup settings
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak.${BACKUP_TS}"
    log_warning "Settings backed up to settings.json.bak.${BACKUP_TS}"

    # Use jq to merge the Stop hook
    if command -v jq &> /dev/null; then
        HOOK_ENTRY='{"hooks":[{"type":"command","command":"bash ~/.claude/scripts/check-context.sh"}]}'

        # Add to existing Stop hooks array or create it
        jq --argjson hook "$HOOK_ENTRY" '
            if .hooks.Stop then
                .hooks.Stop += [$hook]
            else
                .hooks = (.hooks // {}) + {"Stop": [$hook]}
            end
        ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        log_success "Stop hook added to settings.json"
    else
        log_warning "jq not found - please manually add Stop hook to settings.json:"
        echo '  "Stop": [{"hooks":[{"type":"command","command":"bash ~/.claude/scripts/check-context.sh"}]}]'
    fi
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Installed:"
echo "  - ~/.claude/CLAUDE.md (global behavioral rules)"
echo "  - ~/.claude/skills/ (${#SKILLS[@]} skills: ${SKILLS[*]})"
echo "  - ~/.claude/scripts/ (${#SCRIPTS[@]} scripts)"
echo "  - Stop hook for auto half-clone at >85% context"
echo ""
echo "Start a new Claude Code session to apply."
echo ""
