#!/bin/bash
# Layer 4: Stop Hook Skill Audit (Retrospective Safety Net)
# Hook: Stop
# Checks if Claude wrote/edited code without having loaded any relevant skills.
# Outputs a warning to stderr (visible to Claude) if skills were likely missed.
#
# This is a lightweight heuristic check, not an LLM call.
# It reads the tool history from stdin and checks for patterns:
#   - Code was written/edited (Write/Edit on .ts/.tsx/.js/.jsx/.py files)
#   - No Skill tool was called in the session
#
# Cost: ~10ms (reads stdin JSON, simple string checks)

input=$(cat)

# Extract transcript path to check for Skill tool usage
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""' 2>/dev/null)

# Check the stop_hook_active flag to prevent infinite loops
# If this is a re-triggered stop (we already audited), exit silently
stop_active=$(echo "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$stop_active" = "true" ]; then
  exit 0
fi

# If no transcript, we can't audit — exit silently
if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
  exit 0
fi

# Check if the Skill tool was called in this session
# Look for "Skill" in the tool_name fields of the transcript
skill_used=$(grep -c '"tool_name".*"Skill"' "$transcript_path" 2>/dev/null || echo "0")

# If skills were used, no audit needed
if [ "$skill_used" -gt 0 ]; then
  exit 0
fi

# Check if code was written or edited (look for Write/Edit tool calls on code files)
code_written=$(grep -cE '"tool_name".*"(Write|Edit)"' "$transcript_path" 2>/dev/null || echo "0")

if [ "$code_written" -gt 0 ]; then
  # Check if any of the written/edited files are code files
  code_files=$(grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*\.(ts|tsx|js|jsx|py|rb|go|rs|java|swift|kt)"' "$transcript_path" 2>/dev/null | head -5)

  if [ -n "$code_files" ]; then
    echo "[Skill Audit] Code was written/edited but no skills were loaded this session." >&2
    echo "[Skill Audit] Consider loading relevant skills (coding-standards, frontend-design, etc.) for better code quality." >&2
    echo "[Skill Audit] Use the Skill tool to load skills before writing code." >&2
  fi
fi

exit 0
