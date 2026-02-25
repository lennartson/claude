#!/bin/bash
# Strategic Compact Suggester (Fixed)
#
# Tracks tool calls using session-persistent counter file.
# Previous version used $$ (PID) which changes every hook invocation,
# making the counter always reset to 1. Now uses session_id from stdin.
#
# Hook config (in ~/.claude/settings.json):
# {
#   "hooks": {
#     "PreToolUse": [{
#       "matcher": "tool == \"Edit\" || tool == \"Write\"",
#       "hooks": [{
#         "type": "command",
#         "command": "~/.claude/hooks/strategic-compact/suggest-compact.sh"
#       }]
#     }]
#   }
# }

input=$(cat)

# Extract session_id from stdin JSON (persistent across hook invocations)
session_id=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null)

# Fallback: daily counter if no session_id
if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
  session_id="fallback-$(date +%Y%m%d)"
fi

COUNTER_DIR="/tmp/claude-compact-counters"
mkdir -p "$COUNTER_DIR"

# Clean up counter files older than 1 day
find "$COUNTER_DIR" -type f -mtime +1 -delete 2>/dev/null

COUNTER_FILE="${COUNTER_DIR}/${session_id}"
THRESHOLD=${COMPACT_THRESHOLD:-50}

# Initialize or increment counter
if [ -f "$COUNTER_FILE" ]; then
  count=$(cat "$COUNTER_FILE" 2>/dev/null)
  # Validate count is a number
  if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    count=0
  fi
  count=$((count + 1))
else
  count=1
fi
echo "$count" > "$COUNTER_FILE"

# Suggest compact at threshold (use -ge so a skipped count still triggers)
if [ "$count" -ge "$THRESHOLD" ] && [ "$count" -lt "$((THRESHOLD + 2))" ]; then
  echo "[StrategicCompact] $THRESHOLD tool calls reached — consider /compact if transitioning phases" >&2
fi

# Suggest at regular intervals after threshold
if [ "$count" -gt "$THRESHOLD" ] && [ $((count % 25)) -eq 0 ]; then
  echo "[StrategicCompact] $count tool calls — good checkpoint for /compact if context is getting stale" >&2
fi
