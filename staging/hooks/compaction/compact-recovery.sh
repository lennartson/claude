#!/bin/bash
# Post-Compaction Context Recovery
#
# SessionStart hook with "compact" matcher — fires after compaction completes.
# Reads the handoff file written by pre-compact.py and outputs it to stdout,
# which should inject the context into Claude's post-compaction session.
#
# If the compact matcher stdout injection doesn't work (known bug in some versions),
# the fallback is the CLAUDE.md instruction to read the handoff file.
#
# Hook config (in ~/.claude/settings.json):
# {
#   "hooks": {
#     "SessionStart": [{
#       "matcher": "compact",
#       "hooks": [{
#         "type": "command",
#         "command": "~/.claude/hooks/compaction/compact-recovery.sh",
#         "timeout": 5000
#       }]
#     }]
#   }
# }

HANDOFF_FILE="${HOME}/.claude/compaction/handoff.md"

if [ -f "$HANDOFF_FILE" ]; then
  # Check handoff is recent (within last 5 minutes)
  handoff_age=$(( $(date +%s) - $(stat -f %m "$HANDOFF_FILE" 2>/dev/null || stat -c %Y "$HANDOFF_FILE" 2>/dev/null || echo 0) ))

  if [ "$handoff_age" -lt 300 ]; then
    # Output to stdout — injected into Claude's context
    echo ""
    echo "=== POST-COMPACTION CONTEXT RECOVERY ==="
    echo "The following state was captured before compaction. Use it to continue seamlessly."
    echo ""
    cat "$HANDOFF_FILE"
    echo ""
    echo "=== END RECOVERY ==="
    echo ""
    echo "[CompactRecovery] Injected handoff context (${handoff_age}s old)" >&2
  else
    echo "[CompactRecovery] Handoff file is stale (${handoff_age}s old), skipping injection" >&2
    echo "[CompactRecovery] Read ~/.claude/compaction/handoff.md manually if needed" >&2
  fi
else
  echo "[CompactRecovery] No handoff file found" >&2
fi
