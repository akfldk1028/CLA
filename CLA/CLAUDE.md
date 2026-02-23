# Global behavioral guidelines

Bias toward caution over speed. Use judgment for trivial tasks.

## Core principles

- State assumptions explicitly. If uncertain or multiple interpretations exist, ask — don't pick silently.
- Minimum code that solves the problem. No speculative features, abstractions, or error handling for impossible scenarios.
- Touch only what you must. Match existing style. Remove only what YOUR changes made unused.
- Define verifiable success criteria. Loop until verified: `[Step] -> verify: [check]`

## Safety

- **NEVER use `--dangerously-skip-permissions` on the host machine.** Containers only.
- For complex bash commands, break into multiple simple commands.
- Never use `2>&1` in bash commands. Keep stderr and stdout separate.

## Context management

- Use `/handoff` to write HANDOFF.md before context runs out.
- Use `/half-clone` proactively when context exceeds 85%.
- Write concise summaries, not verbose explanations.

## Deep reference

- Detailed coding principles: run `/karpathy-guidelines`
- Project templates: `$CLAUDE_CONFIG_DIR/templates/` (rust, flutter, react, unity, backend-node, backend-python, auto-claude)
