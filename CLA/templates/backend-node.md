# Project CLAUDE.md - Backend (Node.js)

## Build & Test

```bash
npm start            # Start server
npm test             # Run tests
npm run lint         # Lint
```

## Architecture

- Structure: `routes/`, `middleware/`, `services/`, `models/`, `utils/`, `config/`
- Routes define endpoints. Services contain business logic. Models handle data access.
- Use TypeScript. Define interfaces for request/response shapes.

## Rules

- All async route handlers must have error handling. Use an async wrapper or express-async-errors.
- Validate all input at the boundary (request body, query params, path params).
- No secrets in code. Use environment variables via `process.env`.
- Database queries go in model/repository layer only. No raw queries in route handlers.
- Use proper HTTP status codes. 200/201/204 for success, 4xx for client errors, 5xx for server errors.
- Log errors with context (request ID, user ID). Don't log sensitive data.
- Write integration tests for API endpoints. Mock external services only.
