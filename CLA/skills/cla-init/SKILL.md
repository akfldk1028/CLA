---
name: cla-init
description: "Initialize a project-specific CLAUDE.md. Auto-detects project type from files, or specify manually. Supports combining multiple types. Usage: /cla-init (auto-detect), /cla-init rust, /cla-init react backend-node"
argument-hint: "[type1] [type2] ..."
---

Initialize a project-specific CLAUDE.md from templates with **auto-detection** and **composable** support.

**Argument:** `$ARGUMENTS` (optional - auto-detects if empty)

Available types: `rust`, `flutter`, `react`, `unity`, `backend-node`, `backend-python`

---

## Step 1: Determine project types

### If `$ARGUMENTS` is empty → Auto-detect mode

Scan the **current project root** for marker files and determine ALL matching types:

| Marker file/pattern | Detected type |
|---------------------|---------------|
| `Cargo.toml` | `rust` |
| `pubspec.yaml` | `flutter` |
| `package.json` with `"react"` in dependencies or devDependencies | `react` |
| `*.sln` file OR `Assets/Scripts/` directory | `unity` |
| `package.json` with `"express"` or `"fastify"` or `"koa"` or `"nest"` in dependencies | `backend-node` |
| `requirements.txt` or `pyproject.toml` or `Pipfile`, AND (`fastapi` or `django` or `flask` in those files) | `backend-python` |

**Important detection rules:**
- A project can match **multiple types** (e.g., React frontend + Node backend in monorepo)
- If `package.json` exists but matches neither `react` nor `backend-node` specifically, treat as `backend-node` (generic Node.js project)
- If `pyproject.toml` or `requirements.txt` exists but no framework detected, treat as `backend-python` (generic Python project)
- If **nothing** is detected, tell the user: "Could not auto-detect project type. Available types: rust, flutter, react, unity, backend-node, backend-python. Usage: /cla-init <type>"

After detection, show the user what was found:
```
Detected: react, backend-node
Generating combined CLAUDE.md...
```

### If `$ARGUMENTS` is provided → Manual mode

Split `$ARGUMENTS` by spaces. Each word is a type name. Validate each one is a known type. If any is invalid, list available types and stop.

Examples:
- `/cla-init rust` → single type
- `/cla-init react backend-node` → combined types
- `/cla-init flutter backend-python` → combined types

---

## Step 2: Locate templates

For each detected/specified type, find the template file at:
- `${CLAUDE_CONFIG_DIR:-~/.claude}/templates/<type>.md`

If any template file doesn't exist, report an error for that type and skip it. Continue with remaining types.

---

## Step 3: Check for existing CLAUDE.md

If `./CLAUDE.md` already exists in the project root:
- Show the user the first 10 lines of the existing file
- Ask: **overwrite**, **append** (add below existing content), or **cancel**
- If cancel, stop

---

## Step 4: Generate combined CLAUDE.md

### Single type
Read the template and write it directly to `./CLAUDE.md`.

### Multiple types (composable)
Combine templates into a single coherent CLAUDE.md:

```markdown
# Project CLAUDE.md

## Build & Test

### [Type 1 name]
(Build & Test section from type 1 template)

### [Type 2 name]
(Build & Test section from type 2 template)

## Architecture

### [Type 1 name]
(Architecture section from type 1 template)

### [Type 2 name]
(Architecture section from type 2 template)

## Rules

### [Type 1 name]
(Rules section from type 1 template)

### [Type 2 name]
(Rules section from type 2 template)
```

Each template has 3 sections (`## Build & Test`, `## Architecture`, `## Rules`). Extract each section from each template and merge under shared headings.

---

## Step 5: Post-setup guidance

Tell the user:
- Which types were applied (and how they were detected if auto mode)
- The CLAUDE.md has been created/updated
- They should review and customize project-specific details (project name, paths, etc.)
- The global CLAUDE.md rules still apply on top of this project config
- To re-run with different types: `/cla-init <type1> <type2>`
