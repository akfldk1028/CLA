# Claude Master Module

Three sources unified into one global module for Claude Code:

1. **Karpathy Guidelines** - LLM coding mistake prevention (Think, Simplicity, Surgical, Goal-Driven)
2. **DX Plugin Skills** - Practical skills (handoff, gha, clone, half-clone, reddit-fetch, review-claudemd)
3. **Reference Docs** - Advent of Claude 2025 guide + Skills building guide

## Install

```bash
bash scripts/install.sh
```

This will:
- Copy `CLAUDE.md` to `~/.claude/CLAUDE.md` (global behavioral rules)
- Copy 7 skills to `~/.claude/skills/`
- Copy utility scripts to `~/.claude/scripts/`
- Add the context check Stop hook to `~/.claude/settings.json`

## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| karpathy-guidelines | `/karpathy-guidelines` | Apply 4 coding principles |
| handoff | `/handoff` | Write HANDOFF.md for session transfer |
| gha | `/gha <url>` | Analyze GitHub Actions failures |
| clone | `/clone` | Clone current conversation |
| half-clone | `/half-clone` | Clone later half, discard early context |
| reddit-fetch | `/reddit-fetch` | Fetch Reddit content via Gemini CLI |
| review-claudemd | `/review-claudemd` | Review CLAUDE.md from conversation history |

## Scripts

| Script | Purpose |
|--------|---------|
| `context-bar.sh` | Custom status line with context usage bar |
| `check-context.sh` | Auto-suggest half-clone at >85% context |
| `clone-conversation.sh` | Full conversation clone utility |
| `half-clone-conversation.sh` | Half-clone conversation utility |
| `install.sh` | Global installation script |

## Docs

- `docs/advent-of-claude-2025.md` - 31-day Claude Code feature guide
- `docs/claude-skills-building-guide.md` - Skills construction guide
- `docs/quick-reference.md` - CLI cheat sheet

## Uninstall

```bash
rm ~/.claude/CLAUDE.md
rm -rf ~/.claude/skills/{karpathy-guidelines,handoff,gha,clone,half-clone,reddit-fetch,review-claudemd}
rm -rf ~/.claude/scripts/{context-bar.sh,check-context.sh,clone-conversation.sh,half-clone-conversation.sh}
```
