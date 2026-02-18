# Quick reference

## Keyboard shortcuts

| Key | Action |
|-----|--------|
| `Esc` | Cancel current generation |
| `Ctrl+C` | Exit Claude Code |
| `Ctrl+L` | Clear screen |
| `Tab` | Accept autocomplete |
| `Up/Down` | Navigate history |

## Slash commands

| Command | Description |
|---------|-------------|
| `/help` | Show help |
| `/clear` | Clear conversation |
| `/compact` | Compact conversation to save context |
| `/cost` | Show token usage and cost |
| `/doctor` | Check environment health |
| `/init` | Generate project CLAUDE.md |
| `/review` | Review code changes |
| `/memory` | View/edit auto memory |
| `/context` | Show loaded context files |

## Custom skills (claude-master)

| Command | Description |
|---------|-------------|
| `/karpathy-guidelines` | Apply 4 coding principles |
| `/handoff` | Write HANDOFF.md for session transfer |
| `/gha <url>` | Debug GitHub Actions failure |
| `/clone` | Clone conversation |
| `/half-clone` | Half-clone conversation (free context) |
| `/reddit-fetch` | Fetch Reddit via Gemini CLI |
| `/review-claudemd` | Review CLAUDE.md from history |

## CLI flags

| Flag | Description |
|------|-------------|
| `claude -r` | Resume last conversation |
| `claude -c` | Continue most recent session |
| `claude -p "prompt"` | Non-interactive single prompt |
| `claude --model <id>` | Choose model |
| `claude --allowedTools` | Restrict available tools |
| `claude --verbose` | Show debug info |

## Context management

- **85% rule**: Auto half-clone triggers at 85% context usage (via Stop hook)
- **HANDOFF.md**: Write before context runs out with `/handoff`
- **Compact**: Use `/compact` to summarize and free context
- Max context window: 200k tokens (Opus/Sonnet)

## File locations

| Path | Purpose |
|------|---------|
| `~/.claude/CLAUDE.md` | Global behavioral rules |
| `~/.claude/settings.json` | Permissions, hooks, status line |
| `~/.claude/skills/` | Installed skills |
| `~/.claude/scripts/` | Utility scripts |
| `~/.claude/commands/` | Slash commands |
| `./CLAUDE.md` | Project-specific rules |
| `./HANDOFF.md` | Session handoff document |
