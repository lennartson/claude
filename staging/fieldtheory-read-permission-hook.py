#!/usr/bin/env python3
"""
PreToolUse Auto-Approve Hook for Field Theory Read Permissions

Auto-approves Read/Write/Edit operations for:
- ~/Library/Application Support/fieldtheory-mac/users/*/figures/* (screenshot figures)
- .cursor/commands/* (portable commands)

This is separate from Librarian functionality.
Never blocks - only auto-approves or passes through to normal flow.
"""
import json
import sys

def main():
    try:
        input_data = json.load(sys.stdin)
    except:
        sys.exit(0)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    if tool_name in ("Read", "Write", "Edit"):
        file_path = tool_input.get("file_path", "")

        # Check for screenshot figures (fieldtheory-mac/.../figures/...)
        if "fieldtheory-mac" in file_path and "/figures/" in file_path:
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "allow"
                }
            }))
            sys.exit(0)

        # Check for portable commands (.cursor/commands/...)
        if "/.cursor/commands/" in file_path:
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
