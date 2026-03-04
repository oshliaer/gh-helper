---
description: Iteratively resolve all unresolved review comments in a GitHub Pull Request, one at a time.
argument-hint: <pr-number>
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

# Review PR

Work through all unresolved review comments in PR #$ARGUMENTS one by one until none remain.

Use `gh-helper` to interact with GitHub PR comments.

## Cycle

Repeat the following steps until the output says "No unresolved comments found":

### Step 1. Get the next comment

```bash
gh-helper $ARGUMENTS -u --count 1
```

If the output contains "No unresolved comments found" — all done.

### Step 2. Address the comment

Using all available tools (read files, edit code, etc.), do what the comment requires.

### Step 3. Reply and resolve

```bash
gh-helper $ARGUMENTS --reply <COMMENT_ID> --resolve -m "<Message in the author's language>"
```

- `<COMMENT_ID>` — value of the `Comment ID:` field from Step 1 output
- The message should briefly describe what was done
- Reply in the same language as the comment author

## Rules

- Process comments **strictly one at a time**
- Do not resolve a comment unless you are confident the requirement is fulfilled
- If a comment requires discussion rather than a code change — reply explaining your reasoning, then resolve the thread
- If `gh-helper` is not found in PATH — tell the user to install it first
