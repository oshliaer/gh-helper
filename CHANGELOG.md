# Changelog

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
