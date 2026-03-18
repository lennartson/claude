# Evidence Collection Guide

## Overview
This document provides procedures for collecting, organizing, and preserving evidence of system state, configuration changes, and test results during Claude stack migration and configuration.

## Evidence Categories

### 1. System State Evidence
### 2. Configuration Evidence
### 3. Test Results Evidence
### 4. Security Audit Evidence
### 5. Issue Resolution Evidence

## Path Standardization

**Critical**: Always use `$HOME` variable instead of hardcoded user paths.

### Correct Path Usage
```bash
# macOS examples
$HOME/Library/Application Support/Claude/
$HOME/Library/Application Support/Google/Chrome/
$HOME/.ssh/
$HOME/evidence/migration-20260217/

# Linux examples
$HOME/.config/Claude/
$HOME/.config/google-chrome/
$HOME/.ssh/
$HOME/evidence/migration-20260217/

# Cross-platform
$HOME/backups/
$HOME/reports/
$HOME/temp/
```

### Why $HOME Variable?

1. **Case-Insensitivity**: Prevents issues with macOS path case variations
   - `/Users/` vs `/users/` - `$HOME` eliminates ambiguity

2. **User-Independence**: Works for any user without modification

3. **Script Portability**: Same scripts work across different environments

4. **Privacy**: Doesn't expose specific usernames in documentation

## Evidence Collection Structure

Create timestamped evidence directory:

```bash
#!/bin/bash
# Create evidence collection directory

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EVIDENCE_DIR"/{system,config,tests,security,logs,screenshots}

echo "Evidence directory created: $EVIDENCE_DIR"
```

## 1. System State Evidence

### Capture System Information

```bash
#!/bin/bash
# capture-system-state.sh

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"
SYSTEM_FILE="$EVIDENCE_DIR/system/system-state.txt"

mkdir -p "$EVIDENCE_DIR/system"

{
    echo "=== SYSTEM STATE EVIDENCE ==="
    echo "Capture Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "User: $USER"
    echo "Home: $HOME"
    echo "Hostname: $(hostname)"
    echo ""
    
    echo "--- Operating System ---"
    sw_vers 2>/dev/null || cat /etc/os-release 2>/dev/null || systeminfo | head -20
    echo ""
    
    echo "--- System Hardware ---"
    system_profiler SPHardwareDataType 2>/dev/null || lscpu 2>/dev/null || echo "N/A"
    echo ""
    
    echo "--- Shell Environment ---"
    echo "Shell: $SHELL"
    bash --version 2>/dev/null || zsh --version 2>/dev/null || echo "N/A"
    echo ""
    
    echo "--- Key Environment Variables ---"
    echo "HOME=$HOME"
    echo "USER=$USER"
    echo "PATH=$PATH"
    echo ""
    
} > "$SYSTEM_FILE"

echo "System state captured: $SYSTEM_FILE"
```

### Capture Tool Versions

```bash
#!/bin/bash
# capture-tool-versions.sh

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"
VERSIONS_FILE="$EVIDENCE_DIR/system/tool-versions.txt"

mkdir -p "$EVIDENCE_DIR/system"

{
    echo "=== TOOL VERSIONS EVIDENCE ==="
    echo "Capture Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    
    echo "--- Claude Tools ---"
    echo "Desktop: $(defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo 'Not installed')"
    echo "Code: $(claude --version 2>/dev/null || echo 'Not installed')"
    echo ""
    
    echo "--- Browsers ---"
    echo "Chrome: $(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version 2>/dev/null || google-chrome --version 2>/dev/null || echo 'Not installed')"
    echo "Firefox: $(/Applications/Firefox.app/Contents/MacOS/firefox --version 2>/dev/null || firefox --version 2>/dev/null || echo 'Not installed')"
    echo ""
    
    echo "--- Development Tools ---"
    echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
    echo "npm: $(npm --version 2>/dev/null || echo 'Not installed')"
    echo "Python: $(python3 --version 2>/dev/null || echo 'Not installed')"
    echo "Git: $(git --version 2>/dev/null || echo 'Not installed')"
    echo ""
    
} > "$VERSIONS_FILE"

echo "Tool versions captured: $VERSIONS_FILE"
```

## 2. Configuration Evidence

### Backup Configuration Files

```bash
#!/bin/bash
# backup-configurations.sh

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"
CONFIG_DIR="$EVIDENCE_DIR/config"

mkdir -p "$CONFIG_DIR"/{desktop,code,chrome,backups}

# Desktop MCP Config (macOS)
if [ -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]; then
    cp "$HOME/Library/Application Support/Claude/claude_desktop_config.json" \
       "$CONFIG_DIR/desktop/claude_desktop_config.json"
    echo "✓ Desktop config backed up"
fi

# Desktop MCP Config (Linux)
if [ -f "$HOME/.config/Claude/claude_desktop_config.json" ]; then
    cp "$HOME/.config/Claude/claude_desktop_config.json" \
       "$CONFIG_DIR/desktop/claude_desktop_config.json"
    echo "✓ Desktop config backed up"
fi

# Chrome Native Messaging (macOS)
if [ -d "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts" ]; then
    cp -R "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts" \
       "$CONFIG_DIR/chrome/"
    echo "✓ Chrome native messaging backed up"
fi

# Chrome Native Messaging (Linux)
if [ -d "$HOME/.config/google-chrome/NativeMessagingHosts" ]; then
    cp -R "$HOME/.config/google-chrome/NativeMessagingHosts" \
       "$CONFIG_DIR/chrome/"
    echo "✓ Chrome native messaging backed up"
fi

# Create manifest of backed up files
ls -laR "$CONFIG_DIR" > "$CONFIG_DIR/backup-manifest.txt"

echo "Configuration evidence collected: $CONFIG_DIR"
```

### Validate Configuration Files

```bash
#!/bin/bash
# validate-configurations.sh

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"
VALIDATION_FILE="$EVIDENCE_DIR/config/validation-report.txt"

mkdir -p "$EVIDENCE_DIR/config"

{
    echo "=== CONFIGURATION VALIDATION EVIDENCE ==="
    echo "Validation Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    
    echo "--- Desktop MCP Config ---"
    DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    if [ -f "$DESKTOP_CONFIG" ]; then
        echo "File: $DESKTOP_CONFIG"
        echo "Size: $(wc -c < "$DESKTOP_CONFIG") bytes"
        echo "Modified: $(stat -f %Sm "$DESKTOP_CONFIG" 2>/dev/null || stat -c %y "$DESKTOP_CONFIG")"
        echo "JSON Valid: $(python3 -m json.tool "$DESKTOP_CONFIG" > /dev/null 2>&1 && echo 'Yes' || echo 'No')"
        
        if python3 -m json.tool "$DESKTOP_CONFIG" > /dev/null 2>&1; then
            echo "Configured Servers:"
            python3 -c "import json; f=open('$DESKTOP_CONFIG'); d=json.load(f); [print(f'  - {k}') for k in d.get('mcpServers', {}).keys()]" 2>/dev/null
        fi
    else
        echo "File not found: $DESKTOP_CONFIG"
    fi
    echo ""
    
    echo "--- Chrome Native Messaging Manifests ---"
    CHROME_HOSTS="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
    if [ -d "$CHROME_HOSTS" ]; then
        echo "Directory: $CHROME_HOSTS"
        echo "Manifest Files:"
        for manifest in "$CHROME_HOSTS"/*.json; do
            if [ -f "$manifest" ]; then
                echo "  File: $(basename "$manifest")"
                echo "  Valid: $(python3 -m json.tool "$manifest" > /dev/null 2>&1 && echo 'Yes' || echo 'No')"
            fi
        done
    else
        echo "Directory not found: $CHROME_HOSTS"
    fi
    echo ""
    
} > "$VALIDATION_FILE"

echo "Validation evidence captured: $VALIDATION_FILE"
```

## 3. Test Results Evidence

### Capture Test Output

```bash
#!/bin/bash
# capture-test-results.sh

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"
TESTS_DIR="$EVIDENCE_DIR/tests"

mkdir -p "$TESTS_DIR"

# Run acceptance tests and capture output
{
    echo "=== ACCEPTANCE TEST EVIDENCE ==="
    echo "Test Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    
    echo "--- Test 1: Desktop MCP Config ---"
    if [ -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]; then
        echo "✓ Config exists"
        python3 -m json.tool "$HOME/Library/Application Support/Claude/claude_desktop_config.json" > /dev/null 2>&1 && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
    else
        echo "✗ Config not found"
    fi
    echo ""
    
    echo "--- Test 2: Claude Code CLI ---"
    if command -v claude &> /dev/null; then
        echo "✓ Claude CLI available"
        echo "Version: $(claude --version)"
    else
        echo "✗ Claude CLI not found"
    fi
    echo ""
    
    echo "--- Test 3: MCP Server List ---"
    if command -v claude &> /dev/null; then
        echo "Configured MCP Servers:"
        claude mcp list 2>&1
    else
        echo "✗ Cannot list - Claude CLI not available"
    fi
    echo ""
    
} > "$TESTS_DIR/acceptance-tests.txt"

echo "Test results captured: $TESTS_DIR/acceptance-tests.txt"
```

## 4. Security Audit Evidence

### Security Scan

```bash
#!/bin/bash
# security-audit.sh

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"
SECURITY_FILE="$EVIDENCE_DIR/security/audit-report.txt"

mkdir -p "$EVIDENCE_DIR/security"

{
    echo "=== SECURITY AUDIT EVIDENCE ==="
    echo "Audit Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    
    echo "--- Scanning for Hardcoded Secrets ---"
    DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    
    if [ -f "$DESKTOP_CONFIG" ]; then
        echo "Checking: $DESKTOP_CONFIG"
        
        # Check for common secret patterns (case-insensitive)
        if grep -qi "password\|secret\|api_key\|apikey\|token\|credential" "$DESKTOP_CONFIG"; then
            echo "⚠ WARNING: Potential secrets detected in config"
            echo "Patterns found:"
            grep -i "password\|secret\|api_key\|apikey\|token\|credential" "$DESKTOP_CONFIG" | sed 's/:.*/: [REDACTED]/'
        else
            echo "✓ No obvious secret patterns found"
        fi
        
        # Check for environment variable usage
        if grep -q '\${.*}' "$DESKTOP_CONFIG"; then
            echo "✓ Environment variables detected (good practice)"
            grep -o '\${[^}]*}' "$DESKTOP_CONFIG" | sort -u
        else
            echo "⚠ No environment variables found - consider using them for secrets"
        fi
    else
        echo "Config not found: $DESKTOP_CONFIG"
    fi
    echo ""
    
    echo "--- File Permissions Check ---"
    if [ -f "$DESKTOP_CONFIG" ]; then
        PERMS=$(stat -f %A "$DESKTOP_CONFIG" 2>/dev/null || stat -c %a "$DESKTOP_CONFIG")
        echo "Config permissions: $PERMS"
        if [ "$PERMS" = "600" ] || [ "$PERMS" = "644" ]; then
            echo "✓ Permissions acceptable"
        else
            echo "⚠ Unusual permissions detected"
        fi
    fi
    echo ""
    
} > "$SECURITY_FILE"

echo "Security audit captured: $SECURITY_FILE"
```

## 5. Log Collection

### Collect Relevant Logs

```bash
#!/bin/bash
# collect-logs.sh

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"
LOGS_DIR="$EVIDENCE_DIR/logs"

mkdir -p "$LOGS_DIR"

# macOS system logs
if command -v log &> /dev/null; then
    log show --predicate 'process == "Claude"' --last 1h > "$LOGS_DIR/claude-system.log" 2>&1
    log show --predicate 'process == "Google Chrome"' --last 1h | grep -i claude > "$LOGS_DIR/chrome-claude.log" 2>&1
fi

# Check for Claude-specific log files
if [ -d "$HOME/Library/Logs/Claude" ]; then
    cp -R "$HOME/Library/Logs/Claude" "$LOGS_DIR/claude-app-logs/"
fi

# Create log manifest
ls -laR "$LOGS_DIR" > "$LOGS_DIR/log-manifest.txt"

echo "Logs collected: $LOGS_DIR"
```

## Complete Evidence Collection Script

```bash
#!/bin/bash
# collect-all-evidence.sh

set -e

EVIDENCE_DIR="$HOME/evidence/migration-$(date +%Y%m%d-%H%M%S)"

echo "Creating evidence collection directory: $EVIDENCE_DIR"
mkdir -p "$EVIDENCE_DIR"/{system,config,tests,security,logs,screenshots,summary}

# Capture system state
echo "1. Capturing system state..."
bash capture-system-state.sh

# Backup configurations
echo "2. Backing up configurations..."
bash backup-configurations.sh

# Run validation
echo "3. Validating configurations..."
bash validate-configurations.sh

# Capture test results
echo "4. Capturing test results..."
bash capture-test-results.sh

# Run security audit
echo "5. Running security audit..."
bash security-audit.sh

# Collect logs
echo "6. Collecting logs..."
bash collect-logs.sh

# Create summary
{
    echo "=== EVIDENCE COLLECTION SUMMARY ==="
    echo "Collection Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Evidence Directory: $EVIDENCE_DIR"
    echo ""
    echo "Contents:"
    ls -lah "$EVIDENCE_DIR"
    echo ""
    echo "Total Size:"
    du -sh "$EVIDENCE_DIR"
    echo ""
} > "$EVIDENCE_DIR/summary/collection-summary.txt"

echo ""
echo "Evidence collection complete!"
echo "Location: $EVIDENCE_DIR"
echo ""
echo "To create archive:"
EVIDENCE_NAME="$(basename "$EVIDENCE_DIR")"
ARCHIVE_NAME="evidence-${EVIDENCE_NAME}-$(date +%Y%m%d-%H%M%S).tar.gz"
echo "  tar -czf \"$ARCHIVE_NAME\" -C \"$HOME/evidence\" \"$EVIDENCE_NAME\""
```

## Evidence Archive

Create compressed archive for storage or sharing:

```bash
#!/bin/bash
# archive-evidence.sh

EVIDENCE_DIR="$1"

if [ -z "$EVIDENCE_DIR" ] || [ ! -d "$EVIDENCE_DIR" ]; then
    echo "Usage: $0 <evidence-directory>"
    exit 1
fi

ARCHIVE_NAME="evidence-$(basename "$EVIDENCE_DIR")-$(date +%Y%m%d-%H%M%S).tar.gz"
ARCHIVE_PATH="$HOME/evidence-archives/$ARCHIVE_NAME"

mkdir -p "$HOME/evidence-archives"

tar -czf "$ARCHIVE_PATH" -C "$(dirname "$EVIDENCE_DIR")" "$(basename "$EVIDENCE_DIR")"

echo "Evidence archived: $ARCHIVE_PATH"
echo "Size: $(du -sh "$ARCHIVE_PATH" | cut -f1)"
echo "SHA256: $(shasum -a 256 "$ARCHIVE_PATH" | cut -d' ' -f1)"
```

## Best Practices

1. **Use $HOME**: Always use `$HOME` variable in all paths
2. **Timestamp Everything**: Use ISO 8601 format for timestamps
3. **Preserve Originals**: Never modify original evidence
4. **Validate Data**: Check file integrity with checksums
5. **Document Chain of Custody**: Log who collected what and when
6. **Redact Secrets**: Remove sensitive data before sharing
7. **Archive Regularly**: Create compressed archives for long-term storage
8. **Test Restoration**: Verify archives can be restored

## References

- Run Report Template: `RUN_REPORT.md`
- Acceptance Test Guide: `ACCEPTANCE_TEST.md`
- Manifest: `MANIFEST.csv`
