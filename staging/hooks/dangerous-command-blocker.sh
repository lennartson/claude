#!/bin/bash
# Dangerous command blocker — runs as PreToolUse hook
# More reliable than deny rules (works regardless of permission mode)
# Exit 2 = block, Exit 0 = allow

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // ""' 2>/dev/null)

# Fail-closed: if we cannot determine the tool name (malformed JSON, jq error),
# block the call rather than allowing it through
if [ -z "$tool_name" ]; then
  echo "[Hook] BLOCKED: Unable to parse tool input (fail-closed)" >&2
  exit 2
fi

# Only inspect Bash tool calls; other tools pass through
[ "$tool_name" != "Bash" ] && exit 0

# Fail-closed: if this is a Bash call but we cannot extract the command, block it
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')
if [ -z "$cmd" ]; then
  echo "[Hook] BLOCKED: Bash tool with empty command (fail-closed)" >&2
  exit 2
fi

blocked() {
  echo "[Hook] BLOCKED: $1" >&2
  echo "[Hook] $2" >&2
  exit 2
}

# --- RECURSIVE RM (all flag combinations) ---
# Catches: rm -r, rm -rf, rm -fr, rm -Rf, rm -RF, rm -v -r, rm --recursive
if echo "$cmd" | grep -qE '\brm\s+(-[a-zA-Z]+\s+)*-[a-zA-Z]*[rR][a-zA-Z]*(\s|$)'; then
  blocked "Recursive rm detected" "Use 'trash' instead of rm -r"
fi
if echo "$cmd" | grep -qE '\brm\s+.*--recursive'; then
  blocked "Recursive rm detected" "Use 'trash' instead of rm --recursive"
fi

# --- SUDO (belt-and-suspenders with deny list) ---
if echo "$cmd" | grep -qE '(^|;|&&|\|)\s*sudo\s'; then
  blocked "sudo is not allowed" "Ask the user to run privileged commands manually"
fi

# --- DD EVASION (absolute paths, backslash, command prefix) ---
if echo "$cmd" | grep -qE '(^|;|&&|\|)\s*(\\\\|/usr/bin/|/bin/|command\s+)dd\s'; then
  blocked "dd via path/evasion detected" "dd disk writes are not allowed"
fi

# --- PIPE-TO-SHELL BYPASS (process substitution) ---
if echo "$cmd" | grep -qE '(bash|sh|zsh)\s+<\('; then
  blocked "Process substitution to shell" "Download the script, review it, then run it"
fi
if echo "$cmd" | grep -qE '(source|\.\s)\s*<\('; then
  blocked "Source with process substitution" "Download the script, review it, then run it"
fi

# --- EVAL WITH REMOTE FETCH ---
if echo "$cmd" | grep -qE 'eval\s.*\$\(.*(curl|wget)'; then
  blocked "eval with remote fetch" "Download the script, review it, then run it"
fi

# --- DOWNLOAD-THEN-EXECUTE ---
if echo "$cmd" | grep -qE '(curl|wget)\s.*&&\s*(bash|sh|zsh|chmod\s+\+x)\s'; then
  blocked "Download-then-execute pattern" "Download the script, review it, then run it"
fi

# --- GIT DESTRUCTIVE OPS ---
if echo "$cmd" | grep -qE '\bgit\s+clean\s+.*-[a-zA-Z]*f'; then
  blocked "git clean with force" "This deletes untracked files permanently"
fi
if echo "$cmd" | grep -qE '\bgit\s+(checkout|restore)\s+\.\s*(;|&&|\||$)'; then
  blocked "Discarding all working tree changes" "This is irreversible for unstaged changes"
fi
if echo "$cmd" | grep -qE '\bgit\s+push\s.*--mirror'; then
  blocked "git push --mirror" "This overwrites the entire remote"
fi

# --- DOCKER DESTRUCTIVE OPS ---
if echo "$cmd" | grep -qE '\bdocker\s+system\s+prune'; then
  blocked "docker system prune" "This removes all unused containers, images, and networks"
fi
if echo "$cmd" | grep -qE '\bdocker\s+volume\s+(rm|prune)'; then
  blocked "docker volume destruction" "This permanently deletes persistent data"
fi

# --- FILE DESTRUCTION ---
if echo "$cmd" | grep -qE '(^|;|&&|\|)\s*(truncate|shred|wipe|srm)\s'; then
  blocked "File destruction command" "Use 'trash' for safe deletion"
fi

# --- DISK FORMATTING (mkfs variants) ---
if echo "$cmd" | grep -qE '(^|;|&&|\|)\s*(mkfs|mke2fs|newfs|wipefs)\b'; then
  blocked "Filesystem formatting command" "This destroys disk data"
fi

# --- DATABASE DROPS ---
if echo "$cmd" | grep -qiE "(DROP\s+(TABLE|DATABASE|SCHEMA)|FLUSHALL|FLUSHDB|dropDatabase)"; then
  blocked "Database destruction command" "This permanently deletes data"
fi

exit 0
