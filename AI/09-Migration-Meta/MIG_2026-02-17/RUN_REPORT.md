# Run Report

## Overview
This document provides a template and guidelines for documenting migration runs, configuration changes, and acceptance test results.

## Report Metadata

```
Run ID: RUN-[YYYYMMDD-HHMMSS]
Date: [ISO 8601 timestamp]
Operator: [username]
Environment: [Development/Staging/Production]
```

## System Configuration

### Paths (Use $HOME for Portability)

**Important**: Always use `$HOME` variable instead of hardcoded `/Users/username` paths to ensure case-insensitivity and portability on macOS and Linux.

#### Correct Path Format
```
$HOME/Library/Application Support/Claude/claude_desktop_config.json
$HOME/.config/Claude/claude_desktop_config.json
$HOME/projects/workspace
$HOME/.ssh/id_rsa
$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts
```

#### Incorrect Path Format (Avoid)
```
/Users/username/Library/Application Support/Claude/claude_desktop_config.json
/users/username/.config/Claude/claude_desktop_config.json
/Users/JohnDoe/projects/workspace
```

### Why Use $HOME?

1. **Case-Insensitivity**: macOS filesystem can be case-insensitive or case-sensitive
   - `/Users/` vs `/users/` - using `$HOME` eliminates this issue

2. **Portability**: Scripts work across different users and systems

3. **Consistency**: Maintains consistent paths in documentation and scripts

4. **Security**: Doesn't expose specific usernames in shared documentation

## System Information Section

```
=== SYSTEM INFORMATION ===
OS: [macOS 14.1 / Ubuntu 22.04 / Windows 11]
Hostname: [hostname]
User: $USER
Home Directory: $HOME

Shell: $SHELL
Shell Version: [bash 5.2 / zsh 5.9]

Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
```

## Tool Versions Section

```
=== TOOL VERSIONS ===
Claude Desktop: [version from defaults or --version]
Claude Code: [version from claude --version]
Chrome: [version from chrome --version]

Node.js: $(node --version)
npm: $(npm --version)
Python: $(python3 --version)
Git: $(git --version)
```

## Pre-Migration State

```
=== PRE-MIGRATION STATE ===

Desktop MCP Config:
  Location: $HOME/Library/Application Support/Claude/claude_desktop_config.json
  Exists: [Yes/No]
  Valid JSON: [Yes/No]
  Configured Servers: [list]
  Backup Created: [Yes/No]
  Backup Location: $HOME/backups/claude-config-[timestamp].json

Code MCP Config:
  CLI Available: [Yes/No]
  Existing Servers: [list or "None"]
  Backup Created: [Yes/No]

Chrome Extension:
  Installed: [Yes/No]
  Version: [version]
  Native Messaging Manifest: [Exists/Missing]
  Manifest Location: $HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts
  Backup Created: [Yes/No]
```

## Migration Steps Executed

```
=== MIGRATION STEPS ===

Step 1: Desktop Configuration Review
  Status: [✓ Complete / ✗ Failed / - Skipped]
  Time: [start - end]
  Notes: [observations]

Step 2: Remove Hardcoded Secrets
  Status: [✓ Complete / ✗ Failed / - Skipped]
  Secrets Found: [count]
  Secrets Removed: [count]
  Notes: [details]

Step 3: Add Security Deny Lists
  Status: [✓ Complete / ✗ Failed / - Skipped]
  Deny Rules Added: [count]
  Protected Paths: [list]
  Notes: [details]

Step 4: Import to Claude Code
  Command: claude mcp add-from-claude-desktop
  Status: [✓ Complete / ✗ Failed]
  Exit Code: [0 or error code]
  Servers Imported: [count]
  Output: [command output]
  Notes: [observations]

Step 5: Verification Tests
  Status: [✓ Complete / ✗ Failed]
  Tests Run: [count]
  Tests Passed: [count]
  Tests Failed: [count]
  Notes: [details]
```

## Post-Migration State

```
=== POST-MIGRATION STATE ===

Desktop MCP Config:
  Location: $HOME/Library/Application Support/Claude/claude_desktop_config.json
  Valid JSON: [Yes/No]
  Configured Servers: [list]
  Secrets Present: [Yes/No - should be No]
  Deny Lists Applied: [Yes/No]

Code MCP Config:
  Servers Configured: [list]
  Import Successful: [Yes/No]
  Configuration Match: [Desktop=Code / Drift Detected]
  Functional: [Yes/No]

Chrome Extension:
  Status: [Working/Issues/Not Tested]
  Native Messaging: [Working/Failed/Not Tested]
  Manifest Valid: [Yes/No]
```

## Acceptance Test Results

```
=== ACCEPTANCE TEST RESULTS ===

Test 1: Desktop MCP Functionality
  Status: [✓ Pass / ✗ Fail]
  Details: [test output or observations]

Test 2: Code MCP Import
  Status: [✓ Pass / ✗ Fail]
  Details: [test output or observations]

Test 3: Configuration Consistency
  Status: [✓ Pass / ✗ Fail]
  Details: [comparison results]

Test 4: Security Validation
  Status: [✓ Pass / ✗ Fail]
  No Hardcoded Secrets: [✓ / ✗]
  Deny Lists Active: [✓ / ✗]
  Minimal Permissions: [✓ / ✗]

Test 5: Chrome Extension
  Status: [✓ Pass / ✗ Fail / - Not Tested]
  Details: [test output or observations]

Test 6: End-to-End Workflow
  Status: [✓ Pass / ✗ Fail]
  Details: [workflow test results]
```

## Issues Encountered

```
=== ISSUES LOG ===

Issue 1: [Title]
  Severity: [Critical/High/Medium/Low]
  Description: [detailed description]
  Resolution: [how it was resolved or workaround]
  Time to Resolve: [duration]

Issue 2: [Title]
  Severity: [Critical/High/Medium/Low]
  Description: [detailed description]
  Resolution: [how it was resolved or workaround]
  Time to Resolve: [duration]
```

## Configuration Drift Analysis

```
=== CONFIGURATION DRIFT ===

Drift Detected: [Yes/No]

If Yes:
  Source: [Desktop/Code]
  Differences: [specific differences found]
  Root Cause: [why drift occurred]
  Resolution: [how drift was resolved]
  Prevention: [steps to prevent future drift]
```

## Security Audit

```
=== SECURITY AUDIT ===

Secrets in Config Files: [Yes/No - should be No]
API Keys Hardcoded: [Yes/No - should be No]
Environment Variables Used: [Yes/No - should be Yes]
Deny Lists Applied: [Yes/No - should be Yes]
Minimal Permissions: [Yes/No - should be Yes]
Security Issues Found: [count]
Security Issues Resolved: [count]
Outstanding Security Concerns: [list or "None"]
```

## Rollback Information

```
=== ROLLBACK INFORMATION ===

Rollback Available: [Yes/No]
Backup Locations (all using $HOME):
  - Desktop Config: $HOME/backups/claude-config-[timestamp].json
  - Code Config: $HOME/backups/code-mcp-[timestamp].backup
  - Chrome Manifest: $HOME/backups/chrome-manifest-[timestamp]/

Rollback Procedure:
  1. [specific step]
  2. [specific step]
  3. [specific step]

Rollback Tested: [Yes/No]
```

## Recommendations

```
=== RECOMMENDATIONS ===

Immediate Actions:
  - [action item 1]
  - [action item 2]

Follow-Up Tasks:
  - [task 1 with timeline]
  - [task 2 with timeline]

Process Improvements:
  - [improvement 1]
  - [improvement 2]

Documentation Updates:
  - [update 1]
  - [update 2]
```

## Sign-Off

```
=== SIGN-OFF ===

Migration Status: [✓ Success / ✗ Failed / ⚠ Partial]
Operator: [name]
Date: [ISO 8601 timestamp]
Approver: [name if required]
Approval Date: [ISO 8601 timestamp]

Notes: [final comments]
```

## Example Run Report

```
=== EXAMPLE RUN REPORT ===

Run ID: RUN-20260217-143022
Date: 2026-02-17T14:30:22Z
Operator: developer
Environment: Development

System: macOS 14.1
Claude Desktop: 1.2.3
Claude Code: 0.9.5
Chrome: 121.0.6167.160

Migration Steps: All Completed
Issues Encountered: 1 (resolved)
Tests Passed: 6/6
Configuration Drift: None
Security Audit: Passed

Backup Locations:
  - $HOME/backups/claude-config-20260217-143022.json
  - $HOME/backups/chrome-manifest-20260217-143022/

Status: ✓ Success
Sign-Off: developer @ 2026-02-17T16:45:00Z
```

## Best Practices

1. **Use $HOME**: Always use `$HOME` variable in path references
2. **ISO 8601 Timestamps**: Use standard timestamp format
3. **Complete Records**: Document all steps, even skipped ones
4. **Backup References**: Always record backup locations
5. **Issue Tracking**: Log all issues, even minor ones
6. **Security Focus**: Include security audit in every run
7. **Rollback Ready**: Maintain rollback information
8. **Version Everything**: Record all tool versions

## Path Variable Reference

Common path patterns using $HOME:

```bash
# macOS
$HOME/Library/Application Support/Claude/
$HOME/Library/Application Support/Google/Chrome/
$HOME/.ssh/
$HOME/Documents/
$HOME/projects/

# Linux
$HOME/.config/Claude/
$HOME/.config/google-chrome/
$HOME/.ssh/
$HOME/documents/
$HOME/projects/

# Cross-platform
$HOME/backups/
$HOME/temp/
$HOME/bin/
```

## Automation Script Template

```bash
#!/bin/bash
# run-report-generator.sh

REPORT_FILE="$HOME/reports/run-report-$(date +%Y%m%d-%H%M%S).md"
mkdir -p "$HOME/reports"

{
    echo "# Run Report"
    echo ""
    echo "Run ID: RUN-$(date +%Y%m%d-%H%M%S)"
    echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Operator: $USER"
    echo "Home Directory: $HOME"
    echo ""
    
    echo "## System Information"
    sw_vers 2>/dev/null || cat /etc/os-release
    echo ""
    
    echo "## Tool Versions"
    echo "Claude Desktop: $(defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo 'N/A')"
    echo "Claude Code: $(claude --version 2>/dev/null || echo 'N/A')"
    echo "Chrome: $(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version 2>/dev/null || echo 'N/A')"
    echo ""
    
    # Add more sections as needed
    
} > "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"
```

## References

- Acceptance Test Guide: `ACCEPTANCE_TEST.md`
- Evidence Collection: `EVIDENCE.md`
- Manifest: `MANIFEST.csv`
