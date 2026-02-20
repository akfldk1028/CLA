# Project CLAUDE.md - Auto-Claude

## Build & Test

```bash
# Backend
cd apps/backend && uv pip install -r requirements.txt
python runners/spec_runner.py --task "test" --no-build  # Create spec
python run.py --spec 001 --qa                           # Run with QA

# Frontend
cd apps/frontend && npm install && npm run dev
npm run lint && npm run typecheck && npm test
```

## Architecture

- Monorepo: `apps/backend/` (Python) + `apps/frontend/` (Electron/React)
- Agent SDK only: always use `create_client()` from `core.client`, never raw `anthropic.Anthropic()`
- Pipeline: spec → plan → code → QA review → QA fix → merge
- All agents registered in `core/agent_registry.py` (single source of truth)
- Git worktree isolation for every build
- i18n: all frontend text via `react-i18next`, keys in `en/*.json` + `fr/*.json`

## Rules

- Never manually create spec files. Always use `spec_runner.py`.
- Never use `process.platform` directly. Import from platform modules.
- Use `encoding='utf-8'` for all file reads (Windows compatibility).
- No time estimates. Use priority-based ordering.
- PR target: `develop` branch, not `main`.
- Agent prompt changes: update the `.md` file in `prompts/`, not Python code.
