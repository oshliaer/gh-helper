# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

GH Helper is a bash CLI script for working with comments and reviews in GitHub Pull Requests. It lets you view, filter, reply to comments, and resolve threads directly from the terminal.

Single executable: `gh-helper` (bash script).

## Dependencies

- `gh` (GitHub CLI) — must be authenticated (`gh auth login`)
- `jq` — for JSON processing
- `bash`

## Running

```bash
gh-helper <PR_NUMBER> [OPTIONS]
```

Built-in help:

```bash
gh-helper --help
```

## Script architecture

The script uses two API types:

- **REST API** (`gh api repos/.../pulls/...`): fetches reviews, PR comments, review comments — stored in temp files (`mktemp`)
- **GraphQL API** (`gh api graphql`): fetches unresolved threads (`--unresolved-only`) and handles reply/resolve operations (`--reply`, `--resolve`)

Main functions:

- `print_code_review_comments` — inline comments on code lines
- `print_reviews_only` — reviews only
- `print_pr_comments_only` — PR comments (not from reviews)
- `print_unresolved_comments` — unresolved threads via GraphQL
- `reply_to_comment` — reply via GraphQL `addPullRequestReviewThreadReply`, optionally `resolveReviewThread`

Filter options (`-cr`, `-r`, `-pc`, `-u`) are **mutually exclusive** — only one can be used at a time.

## Code review cycle (for AI agents)

1. Get the next unresolved comment:

   ```bash
   gh-helper <PR_NUMBER> -u --count 1
   ```

2. Make the required code changes.

3. Reply and resolve:

   ```bash
   gh-helper <PR_NUMBER> --reply <COMMENT_ID> --resolve -m "<Message>"
   ```

4. Repeat from step 1.

`COMMENT_ID` is taken from the `Comment ID:` field in the command output.

## Claude Code skill

The `/review-pr` skill is stored in `skills/review-pr.md`. Install with:

```bash
gh-helper --install-skill global   # for all projects (~/.claude/commands/)
gh-helper --install-skill local    # for current project (.claude/commands/)
```
