---
name: review-pr
description: Iteratively resolves all unresolved review comments in a GitHub Pull Request, one at a time. Use when the user asks to process, handle, or work through PR review comments, code review threads, or unresolved discussions on a pull request.
compatibility: Designed for Claude Code. Requires gh (GitHub CLI, authenticated) and gh-helper (installed as a PATH command or gh extension).
allowed-tools: Bash Read Edit Write Glob Grep
metadata:
  argument-hint: <pr-number>
---

# Review PR

Work through all unresolved review comments in PR #$ARGUMENTS one by one until none remain.

## Setup: detect gh-helper command

Before anything else, run the detection script installed alongside this skill:

```bash
GH_HELPER=$(bash .claude/commands/review-pr/scripts/detect-cmd.sh 2>/dev/null \
  || bash ~/.claude/commands/review-pr/scripts/detect-cmd.sh)
echo "Using: $GH_HELPER"
```

- If the script fails — stop and tell the user to reinstall the skill: `gh helper --install-skill` or `gh-helper --install-skill`
- Otherwise remember the value (e.g. `gh helper` or `gh-helper`) and use it as the command in every step below.

## Cycle

Repeat the following steps until the output says "No unresolved comments found":

### Step 1. Get the next comment

```bash
<GH_HELPER> $ARGUMENTS -u --count 1
```

If the output contains "No unresolved comments found" — all done.

### Step 2. Address the comment

Using all available tools (read files, edit code, etc.), do what the comment requires.

### Step 3. Reply and resolve

```bash
<GH_HELPER> $ARGUMENTS --reply <COMMENT_ID> --resolve -m "<Message in the author's language>"
```

- `<COMMENT_ID>` — value of the `Comment ID:` field from Step 1 output
- `<GH_HELPER>` — the exact value detected in Setup (e.g. `gh helper` or `gh-helper`)
- The message should briefly describe what was done
- Reply in the same language as the comment author

## Rules

- Process comments **strictly one at a time**
- Do not resolve a comment unless you are confident the requirement is fulfilled
- If a comment requires discussion rather than a code change — reply explaining your reasoning, then resolve the thread
