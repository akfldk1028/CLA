# Project CLAUDE.md - Backend (Python)

## Build & Test

```bash
pytest               # Run tests
ruff check .         # Lint
ruff format --check  # Format check
mypy .               # Type check (if configured)
```

## Architecture

- Structure: `app/` with `routers/`, `services/`, `models/`, `schemas/`, `utils/`, `config/`
- Follow the framework convention (FastAPI routers / Django apps)
- Use Pydantic models for request/response validation (FastAPI) or serializers (Django)

## Rules

- Use type hints on all function signatures.
- Async functions for I/O-bound operations (FastAPI). Don't mix sync/async DB calls.
- No bare `except:`. Catch specific exceptions.
- Use dependency injection for database sessions and services.
- Validate all input via Pydantic models or Django forms. No raw `request.data` access.
- No secrets in code. Use environment variables or a settings module.
- Write tests with pytest. Use fixtures for database setup/teardown.
- Keep route handlers thin. Business logic goes in service layer.
