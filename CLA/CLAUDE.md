# Global behavioral guidelines

Merge with project-specific CLAUDE.md as needed. Bias toward caution over speed - use judgment for trivial tasks.

## 1. Think before coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity first

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

## 3. Surgical changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.

## 4. Goal-driven execution

**Define success criteria. Loop until verified.**

- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- For multi-step tasks: `1. [Step] -> verify: [check]`

## 5. Safety

- **NEVER use `--dangerously-skip-permissions` on the host machine.** Containers only.
- For complex bash commands, break into multiple simple commands.
- Never use `2>&1` in bash commands. Keep stderr and stdout separate.

## 6. Context management

- Use `/handoff` to write HANDOFF.md before context runs out.
- Use `/half-clone` proactively when context exceeds 85%.
- Write concise summaries, not verbose explanations.
