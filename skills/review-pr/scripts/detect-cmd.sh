#!/bin/bash
# Detect the available gh-helper command form.
# Outputs: "gh-helper" or "gh helper"
# Exits 1 if not found.

if command -v gh-helper >/dev/null 2>&1; then
  echo "gh-helper"
elif gh extension list 2>/dev/null | grep -q 'gh helper'; then
  echo "gh helper"
else
  echo "gh-helper is not installed. See https://github.com/oshliaer/gh-helper" >&2
  exit 1
fi
