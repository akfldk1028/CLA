# Project CLAUDE.md - React

## Build & Test

```bash
npm run build        # Build
npm test             # Run tests
npm run lint         # Lint
```

## Architecture

- `src/` structure: `components/`, `hooks/`, `pages/`, `services/`, `utils/`, `types/`
- One component per file. Colocate styles and tests (`Component.tsx`, `Component.test.tsx`)
- Use TypeScript. No `any` types unless absolutely necessary.

## Rules

- Prefer functional components with hooks. No class components.
- Custom hooks for shared logic. Prefix with `use`.
- No direct DOM manipulation. Use refs only when necessary.
- Keep components under 150 lines. Extract sub-components.
- `useEffect` must have proper dependency arrays. No eslint-disable for exhaustive-deps.
- No inline object/array literals in JSX props (causes unnecessary re-renders).
- Use `React.memo` only when profiling shows a real performance need.
- Handle loading and error states for all async operations.
