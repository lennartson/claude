# Acceptance Test Guide

## Overview
This document provides command-line procedures for capturing system state, versioning, and verifying Claude stack configuration at test time for audit and debugging purposes.

## Pre-Test: Capture System Environment

### System Information Capture

#### macOS
```bash
# System version
sw_vers

# Detailed system info
system_profiler SPSoftwareDataType SPHardwareDataType

# Shell environment
echo $SHELL
echo $0
```

#### Linux
```bash
# Distribution info
cat /etc/os-release
lsb_release -a  # If available

# Kernel version
uname -a

# System details
hostnamectl  # If systemd-based
```

#### Windows
```powershell
# System information
systeminfo

# PowerShell version
$PSVersionTable
```

### Claude Tools Version Capture

#### Claude Desktop
```bash
# macOS - Check app version
/Applications/Claude.app/Contents/MacOS/Claude --version 2>/dev/null || \
defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString

# Linux - Check installed version
claude-desktop --version 2>/dev/null || \
dpkg -l | grep claude || \
rpm -qa | grep claude

# Windows
# Check via Control Panel > Programs or:
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Where-Object { $_.DisplayName -like "*Claude*" } | 
    Select-Object DisplayName, DisplayVersion
```

#### Claude Code
```bash
# CLI version
claude --version

# Code app version (if separate)
claude code --version 2>/dev/null

# Check installation path
which claude

# Verify PATH configuration
echo $PATH | tr ':' '\n' | grep -i claude
```

### Browser Versions

#### Chrome Version
```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# Linux
google-chrome --version

# Windows
reg query "HKEY_CURRENT_USER\Software\Google\Chrome\BLBeacon" /v version
```

#### Firefox Version (if applicable)
```bash
# macOS
/Applications/Firefox.app/Contents/MacOS/firefox --version

# Linux
firefox --version
```

#### Edge Version (if applicable)
```bash
# macOS
/Applications/Microsoft\ Edge.app/Contents/MacOS/Microsoft\ Edge --version

# Linux
microsoft-edge --version

# Windows
reg query "HKEY_CURRENT_USER\Software\Microsoft\Edge\BLBeacon" /v version
```

### MCP Configuration State

#### List Active MCP Servers
```bash
# Claude Code MCP list
claude mcp list

# Check Desktop config exists
ls -la "$HOME/Library/Application Support/Claude/claude_desktop_config.json"  # macOS
ls -la "$HOME/.config/Claude/claude_desktop_config.json"  # Linux

# Validate Desktop config JSON
python3 -m json.tool "$HOME/Library/Application Support/Claude/claude_desktop_config.json" > /dev/null && echo "Valid JSON" || echo "Invalid JSON"
```

#### Capture MCP Server Versions
```bash
# Node/npm versions (for npx-based MCP servers)
node --version
npm --version
npx --version

# Python version (for Python-based MCP servers)
python3 --version
pip3 --version

# Other runtime versions as needed
go version  # For Go-based servers
```

### Development Environment

#### Git Configuration
```bash
git --version
git config --get user.name
git config --get user.email
```

#### Shell Configuration
```bash
# Current shell
echo $SHELL

# Shell version
bash --version || zsh --version

# Key environment variables
echo "HOME=$HOME"
echo "USER=$USER"
echo "PATH=$PATH"
```

## Acceptance Test Procedures

### Test 1: Desktop MCP Functionality

```bash
# Capture test start time
echo "Test Start: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Verify config file exists
test -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" && echo "✓ Desktop config exists" || echo "✗ Desktop config missing"

# Validate JSON
python3 -m json.tool "$HOME/Library/Application Support/Claude/claude_desktop_config.json" > /dev/null 2>&1 && echo "✓ Valid JSON" || echo "✗ Invalid JSON"

# List configured servers
echo "Configured MCP servers:"
python3 -c "import json; f=open('$HOME/Library/Application Support/Claude/claude_desktop_config.json'); d=json.load(f); print('\n'.join(d.get('mcpServers', {}).keys()))"

# Capture test end time
echo "Test End: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

### Test 2: Claude Code MCP Import

```bash
# Capture test start time
echo "Test Start: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Verify Claude CLI is available
which claude && echo "✓ Claude CLI found" || echo "✗ Claude CLI not found"

# Check Claude version
claude --version

# List imported MCP servers
claude mcp list

# Verify specific servers (example)
claude mcp list | grep -q "filesystem" && echo "✓ filesystem server imported" || echo "✗ filesystem server not found"

# Capture test end time
echo "Test End: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

### Test 3: Chrome Extension Verification

```bash
# Capture test start time
echo "Test Start: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Chrome version
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# Check native messaging manifest
test -f "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_native.json" && echo "✓ Native messaging manifest exists" || echo "✗ Manifest not found"

# Validate manifest JSON
if [ -f "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_native.json" ]; then
    python3 -m json.tool "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_native.json" > /dev/null 2>&1 && echo "✓ Valid manifest JSON" || echo "✗ Invalid manifest JSON"
fi

# Capture test end time
echo "Test End: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

### Test 4: End-to-End Workflow

```bash
# Capture test start time
echo "Test Start: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Test filesystem MCP (if configured)
# This would be done interactively in Claude Desktop/Code
echo "Manual verification required:"
echo "1. Open Claude Desktop"
echo "2. Test filesystem access"
echo "3. Open Claude Code"
echo "4. Verify same filesystem access"
echo "5. Test Chrome extension"

# Log test completion
echo "Test End: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

## Complete System State Capture Script

```bash
#!/bin/bash
# capture-system-state.sh
# Captures complete system state for audit/debugging

REPORT_FILE="system-state-$(date +%Y%m%d-%H%M%S).txt"

{
    echo "========================================="
    echo "SYSTEM STATE CAPTURE"
    echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "========================================="
    echo ""

    echo "--- System Information ---"
    sw_vers 2>/dev/null || cat /etc/os-release 2>/dev/null || systeminfo
    echo ""

    echo "--- Claude Desktop Version ---"
    /Applications/Claude.app/Contents/MacOS/Claude --version 2>/dev/null || 
    defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null ||
    echo "Not found"
    echo ""

    echo "--- Claude Code Version ---"
    claude --version 2>/dev/null || echo "Not found"
    echo ""

    echo "--- Chrome Version ---"
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version 2>/dev/null ||
    google-chrome --version 2>/dev/null ||
    echo "Not found"
    echo ""

    echo "--- Node/npm Versions ---"
    node --version 2>/dev/null || echo "Node not found"
    npm --version 2>/dev/null || echo "npm not found"
    echo ""

    echo "--- Python Version ---"
    python3 --version 2>/dev/null || echo "Python not found"
    echo ""

    echo "--- Git Version ---"
    git --version 2>/dev/null || echo "Git not found"
    echo ""

    echo "--- Desktop MCP Config ---"
    if [ -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]; then
        echo "Config file exists"
        python3 -m json.tool "$HOME/Library/Application Support/Claude/claude_desktop_config.json" > /dev/null 2>&1 && 
        echo "JSON valid" || echo "JSON INVALID"
        echo "Configured servers:"
        python3 -c "import json; f=open('$HOME/Library/Application Support/Claude/claude_desktop_config.json'); d=json.load(f); print('\n'.join(d.get('mcpServers', {}).keys()))" 2>/dev/null
    else
        echo "Config file not found"
    fi
    echo ""

    echo "--- Claude Code MCP Servers ---"
    claude mcp list 2>/dev/null || echo "Unable to list"
    echo ""

    echo "--- Chrome Native Messaging ---"
    if [ -f "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_native.json" ]; then
        echo "Manifest exists"
        python3 -m json.tool "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_native.json" > /dev/null 2>&1 && 
        echo "Manifest JSON valid" || echo "Manifest JSON INVALID"
    else
        echo "Manifest not found"
    fi
    echo ""

    echo "========================================="
    echo "END OF REPORT"
    echo "========================================="
} > "$REPORT_FILE"

echo "System state captured to: $REPORT_FILE"
cat "$REPORT_FILE"
```

## Audit Log Template

Create timestamped audit logs for each test run:

```bash
# Create audit log
AUDIT_LOG="audit-$(date +%Y%m%d-%H%M%S).log"

{
    echo "=== ACCEPTANCE TEST AUDIT LOG ==="
    echo "Test Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Tester: $USER"
    echo "Hostname: $(hostname)"
    echo ""
    
    # Version information
    echo "=== VERSIONS ==="
    echo "OS: $(sw_vers 2>/dev/null | grep ProductVersion || cat /etc/os-release | grep VERSION_ID)"
    echo "Claude Desktop: $(defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null)"
    echo "Claude Code: $(claude --version 2>/dev/null)"
    echo "Chrome: $(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version 2>/dev/null)"
    echo ""
    
    # Test results
    echo "=== TEST RESULTS ==="
    echo "[ ] Desktop MCP Config Valid"
    echo "[ ] Desktop MCP Servers Functional"
    echo "[ ] Claude Code Import Successful"
    echo "[ ] Code MCP Servers Functional"
    echo "[ ] Chrome Extension Installed"
    echo "[ ] Chrome Native Messaging Working"
    echo "[ ] End-to-End Workflow Verified"
    echo ""
    
    # Notes
    echo "=== NOTES ==="
    echo "Add any observations or issues here"
    echo ""
} > "$AUDIT_LOG"

echo "Audit log created: $AUDIT_LOG"
```

## Best Practices

1. **Capture Before Changes**: Always capture system state before making configuration changes
2. **Version Everything**: Record all tool and runtime versions
3. **Timestamp All Tests**: Use ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)
4. **Save Logs**: Keep audit logs for debugging and compliance
5. **Automate Where Possible**: Use scripts for consistent capture
6. **Document Failures**: Record both successes and failures
7. **Compare States**: Diff system state before/after changes

## References

- System state capture script: `capture-system-state.sh`
- Audit log template: `audit-YYYYMMDD-HHMMSS.log`
- [Claude Code Documentation](https://code.claude.com/docs)
