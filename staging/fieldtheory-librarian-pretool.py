#!/usr/bin/env python3
"""
PreToolUse Auto-Approve Hook for Field Theory Librarian
Auto-approves Read/Write/Edit to ~/.fieldtheory/librarian/*
"""
import json
import sys
from pathlib import Path

def main():
    try:
        input_data = json.load(sys.stdin)
    except:
        sys.exit(0)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Auto-approve reads/writes to global librarian directory (where hooks write artifacts/jobs)
    if tool_name in ("Read", "Write", "Edit"):
        file_path = tool_input.get("file_path", "")
        global_librarian_dir = str(Path.home() / ".fieldtheory" / "librarian")

        if file_path.startswith(global_librarian_dir):
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "allow"
                }
            }))
            sys.exit(0)

    # Default: don't interfere, let normal permission flow happen
    sys.exit(0)

if __name__ == "__main__":
    main()
