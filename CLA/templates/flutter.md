# Project CLAUDE.md - Flutter

## Build & Test

```bash
flutter analyze      # Lint
flutter test         # Run tests
flutter build apk    # Build Android
flutter build ios    # Build iOS (macOS only)
```

## Architecture

- `lib/` structure: `models/`, `screens/`, `widgets/`, `services/`, `utils/`
- One widget per file. Extract reusable widgets to `widgets/`.
- State management: follow the pattern already in use (Provider/Riverpod/Bloc)
- Keep build methods under 50 lines. Extract sub-widgets.

## Rules

- No business logic in widgets. Move to services or state management layer.
- Minimize `setState()` usage. Prefer the project's state management solution.
- Use `const` constructors wherever possible.
- Always add `Key` parameter to custom widget constructors.
- Run `flutter analyze` before committing. Fix all warnings.
- Use named routes or GoRouter. No hardcoded route strings scattered in code.
- Dispose controllers and subscriptions in `dispose()`.
