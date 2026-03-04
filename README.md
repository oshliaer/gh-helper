# GH Helper

Version: 0.2.0

A command-line tool for working with comments and reviews in GitHub Pull Requests. View, filter, reply to comments, and resolve threads directly from the terminal.

## Installation

### As a GitHub CLI extension (recommended)

```bash
gh extension install oshliaer/gh-helper
```

After installation, the tool is invoked via `gh`:

```bash
gh helper <PR_NUMBER> [OPTIONS]
```

### Manually (global PATH)

```bash
git clone https://github.com/oshliaer/gh-helper.git
sudo ln -s "$(pwd)/gh-helper/gh-helper" /usr/local/bin/gh-helper
```

Or add the directory to `~/.bashrc` / `~/.zshrc`:

```bash
export PATH="$PATH:/path/to/gh-helper"
```

### Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`)
- `jq`
- `bash`

Authenticate with GitHub CLI:

```bash
gh auth login
```

## Claude Code skill `/review-pr`

The skill lets a Claude Code agent automatically work through all unresolved PR comments one by one — fixing code and replying to each thread.

### Install globally (all projects)

```bash
gh-helper --install-skill global
```

Or manually:

```bash
mkdir -p ~/.claude/commands
curl -sL https://raw.githubusercontent.com/oshliaer/gh-helper/master/skills/review-pr.md \
  -o ~/.claude/commands/review-pr.md
```

### Install for current project only

```bash
gh-helper --install-skill local
```

Or manually:

```bash
mkdir -p .claude/commands
curl -sL https://raw.githubusercontent.com/oshliaer/gh-helper/master/skills/review-pr.md \
  -o .claude/commands/review-pr.md
```

### Usage

In any Claude Code chat:

```text
/review-pr 123
```

The agent will fetch unresolved comments, make the required code changes, and reply to each thread.

## Command reference

### Basic usage

```bash
gh-helper <PR_NUMBER> [OPTIONS]
```

### View options

- `--code-review-only`, `-cr` — Show only code review comments (inline comments on specific lines)
- `--reviews-only`, `-r` — Show only reviews
- `--pr-comments-only`, `-pc` — Show only PR comments (not from reviews)
- `--unresolved-only`, `-u` — Show only unresolved threads
- `--count <N>` — Limit output to N comments (works with any filter)

```bash
gh-helper 123 --unresolved-only
gh-helper 11 --unresolved-only --count 1
gh-helper 11 -cr --count 1
```

### Replying and resolving

- `--reply <COMMENT_ID>` — Reply to a specific comment
  - `-m <MESSAGE>` — Reply text
  - `--resolve` — Resolve the thread after replying

```bash
# Reply to a comment
gh-helper 123 --reply PR_kwDO... -m "Fixed as suggested"

# Reply and resolve
gh-helper 123 --reply PR_kwDO... --resolve -m "Fixed as suggested"
```

### Skill installation

```bash
gh-helper --install-skill global   # install for all projects
gh-helper --install-skill local    # install for current project
gh-helper --install-skill          # interactive prompt
```

## Output format

Each comment is displayed with:

- Comment ID
- Author
- Created date
- Location (file and line, if applicable)
- Comment body

## Permissions

The GitHub CLI token must have permission to:

- Read PR comments
- Post PR comments
- Resolve review threads
