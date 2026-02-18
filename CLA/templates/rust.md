# Project CLAUDE.md - Rust

## Build & Test

```bash
cargo build          # Build
cargo test           # Run tests
cargo clippy         # Lint
cargo fmt --check    # Format check
```

## Architecture

- Follow standard Cargo workspace layout (`src/`, `tests/`, `benches/`)
- One module per file. Split when a file exceeds ~300 lines.
- Public API goes in `lib.rs`; binary entry point in `main.rs`

## Rules

- No `.unwrap()` or `.expect()` in library code. Use `?` with proper error types.
- No unnecessary `.clone()`. Prefer borrowing.
- Use `thiserror` for library errors, `anyhow` for binary/application errors.
- All public functions must have doc comments.
- Run `cargo clippy` before committing. Fix all warnings.
- Prefer iterators over manual loops. Avoid indexing when iteration works.
- Use `#[must_use]` on functions that return values the caller shouldn't ignore.
