#!/bin/bash
# Test the full installation cycle for gh-helper.
#
# Cases:
#   A. detect-cmd.sh: nothing installed      → exit 1
#   B. detect-cmd.sh: gh extension installed → "gh helper"
#   C. detect-cmd.sh: gh-helper in PATH      → "gh-helper"
#   D. detect-cmd.sh: both installed         → "gh-helper" (PATH takes priority)
#   E. --install-skill local                 → files in .claude/commands/
#   F. --install-skill global                → files in ~/.claude/commands/
#   G. detect-cmd.sh after skill removed     → exit 1
#
# Usage: bash test-install.sh

set -uo pipefail

PASS=0
FAIL=0
GIT_ROOT=$(git rev-parse --show-toplevel)
if [[ -z "${GIT_ROOT:-}" ]] || [[ ! -d "$GIT_ROOT" ]]; then
  echo "Error: could not determine git repository root. Run this script from within a git repo." >&2
  exit 1
fi
SCRIPT="$GIT_ROOT/gh-helper"

ok()   { echo "  ok  $*"; PASS=$((PASS+1)); }
fail() { echo "  FAIL $*"; FAIL=$((FAIL+1)); }

section() { echo; echo "=== $* ==="; }

# ---------------------------------------------------------------------------
# Helpers

detect() {
  local script="$1"
  bash "$script" 2>/dev/null
}

detect_exit() {
  local script="$1"
  bash "$script" >/dev/null 2>&1; echo $?
}

remove_extension() {
  gh extension list 2>/dev/null | grep -q 'gh helper' \
    && gh extension remove helper >/dev/null 2>&1 || true
}

remove_skill_local() {
  local dir="$GIT_ROOT/.claude/commands"
  rm -f "$dir/review-pr.md"
  rm -rf "$dir/review-pr"
}

remove_skill_global() {
  local dir="$HOME/.claude/commands"
  rm -f "$dir/review-pr.md"
  rm -rf "$dir/review-pr"
}

install_extension() {
  gh extension install . >/dev/null 2>&1
}

install_skill_local() {
  "$SCRIPT" --install-skill local >/dev/null 2>&1
}

install_skill_global() {
  "$SCRIPT" --install-skill global >/dev/null 2>&1
}

DETECT_LOCAL="$GIT_ROOT/.claude/commands/review-pr/scripts/detect-cmd.sh"
DETECT_GLOBAL="$HOME/.claude/commands/review-pr/scripts/detect-cmd.sh"

# ---------------------------------------------------------------------------
section "CLEANUP: remove all installations"

remove_extension
remove_skill_local
remove_skill_global
ok "environment clean"

# ---------------------------------------------------------------------------
section "A. detect-cmd.sh: nothing installed → exit 1"

install_skill_local
[[ ! -x "$DETECT_LOCAL" ]] && fail "detect-cmd.sh not installed" && exit 1

code=$(detect_exit "$DETECT_LOCAL")
[[ "$code" == "1" ]] && ok "exits 1 when nothing installed" || fail "expected exit 1, got $code"

remove_skill_local

# ---------------------------------------------------------------------------
section "B. detect-cmd.sh: gh extension → 'gh helper'"

install_extension
install_skill_local

result=$(detect "$DETECT_LOCAL")
[[ "$result" == "gh helper" ]] \
  && ok "detected 'gh helper'" \
  || fail "expected 'gh helper', got '$result'"

# ---------------------------------------------------------------------------
section "C. detect-cmd.sh: gh-helper in PATH → 'gh-helper'"

# Create a temporary fake gh-helper in PATH
TMPBIN=$(mktemp -d)
cat > "$TMPBIN/gh-helper" <<'EOF'
#!/bin/bash
echo "fake gh-helper"
EOF
chmod +x "$TMPBIN/gh-helper"

result=$(PATH="$TMPBIN:$PATH" bash "$DETECT_LOCAL" 2>/dev/null)
[[ "$result" == "gh-helper" ]] \
  && ok "detected 'gh-helper'" \
  || fail "expected 'gh-helper', got '$result'"

# ---------------------------------------------------------------------------
section "D. both installed → 'gh-helper' takes priority"

result=$(PATH="$TMPBIN:$PATH" bash "$DETECT_LOCAL" 2>/dev/null)
[[ "$result" == "gh-helper" ]] \
  && ok "'gh-helper' takes priority over 'gh helper'" \
  || fail "expected 'gh-helper', got '$result'"

rm -rf "$TMPBIN"

# ---------------------------------------------------------------------------
section "E. --install-skill local → files in .claude/commands/"

SKILL_MD="$GIT_ROOT/.claude/commands/review-pr.md"

[[ -f "$SKILL_MD" ]]    && ok "review-pr.md present"        || fail "review-pr.md missing"
[[ -f "$DETECT_LOCAL" ]] && ok "detect-cmd.sh present"      || fail "detect-cmd.sh missing"
[[ -x "$DETECT_LOCAL" ]] && ok "detect-cmd.sh executable"   || fail "detect-cmd.sh not executable"

# ---------------------------------------------------------------------------
section "F. --install-skill global → files in ~/.claude/commands/"

remove_skill_global
install_skill_global

[[ -f "$DETECT_GLOBAL" ]] && ok "detect-cmd.sh installed globally" || fail "detect-cmd.sh missing globally"

result=$(detect "$DETECT_GLOBAL")
[[ "$result" == "gh helper" ]] \
  && ok "global detect: 'gh helper'" \
  || fail "global detect: expected 'gh helper', got '$result'"

remove_skill_global

# ---------------------------------------------------------------------------
section "G. detect-cmd.sh after extension removed → exit 1"

remove_extension
remove_skill_local
install_skill_local

code=$(detect_exit "$DETECT_LOCAL")
[[ "$code" == "1" ]] \
  && ok "exits 1 after extension removed" \
  || fail "expected exit 1, got $code"

# ---------------------------------------------------------------------------
section "H. curl-like install (both files) → detect-cmd.sh present and works"

install_extension
# Simulate correct curl install: copy both SKILL.md and detect-cmd.sh
remove_skill_local
mkdir -p "$GIT_ROOT/.claude/commands/review-pr/scripts"
cp "$GIT_ROOT/skills/review-pr/SKILL.md" "$GIT_ROOT/.claude/commands/review-pr.md"
cp "$GIT_ROOT/skills/review-pr/scripts/detect-cmd.sh" \
   "$GIT_ROOT/.claude/commands/review-pr/scripts/detect-cmd.sh"
chmod +x "$GIT_ROOT/.claude/commands/review-pr/scripts/detect-cmd.sh"

[[ -f "$DETECT_LOCAL" ]] && ok "curl install: detect-cmd.sh present" \
                         || fail "curl install: detect-cmd.sh missing"

GH_HELPER=$(bash "$DETECT_LOCAL" 2>/dev/null || true)
[[ -n "$GH_HELPER" ]] \
  && ok "curl install: GH_HELPER='$GH_HELPER'" \
  || fail "curl install: GH_HELPER is empty"

remove_skill_local

# ---------------------------------------------------------------------------
section "I. SKILL.md setup block produces non-empty GH_HELPER (local install)"

install_extension
install_skill_local

# Run the actual setup block from SKILL.md from project root (as Claude Code would)
cd "$GIT_ROOT" || { fail "could not cd to $GIT_ROOT"; exit 1; }
GH_HELPER=$(bash "$DETECT_LOCAL" 2>/dev/null \
  || bash "$DETECT_GLOBAL" 2>/dev/null \
  || true)

[[ -n "$GH_HELPER" ]] \
  && ok "setup block: GH_HELPER='$GH_HELPER'" \
  || fail "setup block: GH_HELPER is empty — agent will not know which command to use"

# ---------------------------------------------------------------------------
section "J. detect-cmd.sh local path matches SKILL.md reference"

# Extract the local path referenced in SKILL.md
SKILL_LOCAL_PATH=$(grep -o '\.claude/commands/review-pr/scripts/detect-cmd\.sh' \
  "$GIT_ROOT/skills/review-pr/SKILL.md" | head -1)

[[ -n "$SKILL_LOCAL_PATH" ]] \
  && ok "SKILL.md references local path: $SKILL_LOCAL_PATH" \
  || fail "SKILL.md does not reference a local detect-cmd.sh path"

[[ -f "$GIT_ROOT/$SKILL_LOCAL_PATH" ]] \
  && ok "file exists at referenced path (from project root)" \
  || fail "file missing at: $GIT_ROOT/$SKILL_LOCAL_PATH"

# ---------------------------------------------------------------------------
section "CLEANUP"

remove_extension
remove_skill_local
ok "environment restored"

# ---------------------------------------------------------------------------
echo
echo "passed: $PASS  failed: $FAIL"
[[ $FAIL -eq 0 ]]
