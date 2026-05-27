# CLAUDE.md

# CLAUDE.md — Journal Workflow Project

This file defines how Claude should behave when working on this project. Read it before taking any action on the codebase.

---

## Project Overview

This project exists to turn digital journaling into something physical and lasting. Julio journals daily in Capacities and wants to convert those entries into beautifully typeset, print-ready PDFs that can be printed as physical books — the kind of artifact a family can hold onto.

The core challenge is threefold: cleanly exporting content from Capacities (including embedded blocks, images, and linked objects), producing a polished book-like layout with professional typography and indexing, and generating files that meet the technical requirements of print-on-demand services like Blurb.

This is an open-source project, shared with the journaling community. The goal is to make this workflow accessible to other Capacities users who want to do the same thing. Keep that in mind when writing code and documentation — clarity and accessibility matter, not just correctness.

---

## Role Division

**Claude is responsible for:**
- All code: Bash scripts, Lua filters, LaTeX templates, and Pandoc configuration
- Documentation updates whenever code changes are made

**Julio is responsible for:**
- Specifying new features and requirements
- Identifying bugs (most bugs manifest as formatting issues in the PDF output)
- Generating journal content that runs through the pipeline

---

## Tech Stack

- **Bash** — pipeline orchestration (`process-capacities-export.sh`, `preprocess-capacities.sh`, `build.sh`, `build-clean.sh`, `preprocess.sh`)
- **Lua** — Pandoc filters (`task-list-filter.lua`, `filter-media-links.lua`, `remove-object-embeds.lua`, `landscape-table-filter.lua`, `add-index-entries.lua`, `tag-filter.lua`)
- **LaTeX / LuaLaTeX** — typesetting via `templates/journal-template.tex`, using `imakeidx` for six separate indexes
- **Pandoc** — Markdown-to-LaTeX conversion, coordinated by `build.sh`
- **MacTeX** — required LaTeX distribution (macOS)

### Project Structure

```
journal-workflow/
├── source/           # Markdown input files from Capacities
├── templates/        # LaTeX templates
├── filters/          # Lua filters
├── output/           # Generated PDFs (cleared on each build by default)
├── assets/           # Images, PDFs, fonts
├── logs/             # Build logs
└── *.sh              # Build and processing scripts
```

### Build Pipeline (in order)

1. `process-capacities-export.sh` — extracts zip, combines daily notes, copies assets, builds reference map
2. `preprocess-capacities.sh` — Capacities-specific markdown preprocessing
3. `build.sh` — Pandoc conversion + LuaLaTeX compilation + index generation

---

## Git Workflow

**Always create a new branch before starting any feature or bug fix.** This is non-negotiable — it protects working functionality and avoids painful rollbacks if something goes wrong.

```bash
git checkout -b feature/short-description
git checkout -b fix/short-description
```

Work is merged back to `main` only after it has been tested and confirmed working.

---

## Bug Fix Workflow

Julio is typically the one who spots bugs, since most issues manifest as formatting problems in the PDF output rather than script errors.

When a bug is identified:

1. **Claude provides a brief overview** of what it thinks is causing the issue
2. **Claude proposes a fix** and asks Julio whether he wants more detail or prefers to proceed directly
3. **Claude waits for explicit buy-in** before implementing anything
4. Claude implements the fix only after getting the go-ahead

---

## Making Changes to the Codebase

### Incremental changes for substantial work
If a feature or fix requires significant changes across the codebase, break the work into testable steps rather than implementing everything at once. Each step should be verifiable before moving to the next. This makes it much easier to isolate where something goes wrong.

### Preserve existing behavior
When extending functionality, existing behavior must be preserved unless a change is explicitly requested. If a change is expected to affect existing behavior, flag it clearly before proceeding and get Julio's sign-off.

### Code style
- Comment the code extensively — this is a personal project and human readability is a priority
- Comments should explain *why*, not just *what*, especially for non-obvious logic
- Prefer clarity over cleverness throughout

---

## Documentation

Update the relevant documentation whenever code changes are made. This includes:
- `README.md` for user-facing changes (new features, changed behavior, new options)
- Inline comments for implementation-level changes
- `QUICKREF.md` or `PROJECT.md` if the change affects architecture or command references