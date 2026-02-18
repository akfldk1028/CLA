# Project CLAUDE.md - Unity

## Build & Test

```bash
# Build (CLI)
Unity -batchmode -buildTarget <target> -executeMethod BuildScript.Build
# Tests: Unity Test Runner (Edit Mode and Play Mode tests)
```

## Architecture

- `Assets/` structure: `Scripts/`, `Prefabs/`, `Scenes/`, `Materials/`, `UI/`, `Audio/`
- Scripts follow namespace matching folder path: `MyGame.Player`, `MyGame.UI`
- One MonoBehaviour per file. Filename matches class name.

## Rules

- Minimize logic in `Update()`. Use events, coroutines, or async where possible.
- No `Find()` or `FindObjectOfType()` at runtime. Cache references in `Awake()` or use dependency injection.
- Use `[SerializeField]` for inspector fields. Keep fields `private`.
- Pool frequently instantiated objects. No `Instantiate`/`Destroy` in hot paths.
- Use ScriptableObjects for shared configuration data.
- No string-based method calls (`SendMessage`, `Invoke` with string). Use direct references or events.
- Always null-check GetComponent results.
