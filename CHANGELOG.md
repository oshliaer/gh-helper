# Changelog

## [0.3.0] — 2026-03-04

### Changed

- `README.md` — replaced one-liner with a full project description (problem, CLI workflow, AI integration)
- `README.md` — removed hardcoded version line, fixed `ln -s` path, documented both invocation forms (`gh helper` / `gh-helper`) for `--install-skill`
- `CHANGELOG.md` — removed `README.ru.md` mention
- `gh-helper` — `--install-skill local` now resolves repository root via `git rev-parse --show-toplevel`
- `gh-helper` — `usage()` now shows both invocation forms

### Fixed

- `gh-helper` — jq injection via COMMENT_ID interpolated into filter string
- `gh-helper` — `@`-prefix file-read injection via `-F body` (changed to `-f`)

## [0.2.0] — 2026-03-04

### Added

- `CLAUDE.md` — Claude Code instructions for working with the repository
- `skills/review-pr.md` — `/review-pr` skill for Claude Code to automate iterative PR review comment resolution
- `--install-skill [global|local]` — command to install the skill to `~/.claude/commands/` or `.claude/commands/`
- `VERSION` — project version file

### Changed

- `README.md` — rewritten in English, added documentation for `/review-pr` skill and `--install-skill` command

### Removed

- `ai.instructions.md` — replaced by `CLAUDE.md`
- `helpai()` function and `--helpai` flag from the `gh-helper` script
