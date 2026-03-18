# Chrome Extension Handoff Guide

## Overview
This guide provides deterministic, anti-footgun procedures for installing, configuring, and verifying the Claude Chrome extension with native messaging host integration.

## Pre-Installation Checklist

- [ ] Identify Chrome version and profile location
- [ ] Document current native messaging hosts (if any)
- [ ] Create backup of Chrome configuration
- [ ] Verify Chrome is fully closed before changes
- [ ] Note current extension state (if updating)

## Backup Procedures

### 1. Backup Chrome Manifest First

**Critical**: Always backup the native messaging manifest before making changes.

#### macOS
```bash
# Backup native messaging manifests
BACKUP_DIR="$HOME/chrome-manifest-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# System-wide manifests
if [ -d "/Library/Google/Chrome/NativeMessagingHosts" ]; then
    sudo cp -R "/Library/Google/Chrome/NativeMessagingHosts" "$BACKUP_DIR/system/"
    sudo chown -R "$USER":"$(id -gn)" "$BACKUP_DIR/system/" 2>/dev/null || true
fi

# User-specific manifests
if [ -d "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts" ]; then
    cp -R "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts" "$BACKUP_DIR/user/"
fi

echo "Backup created at: $BACKUP_DIR"
```

#### Linux
```bash
# Backup native messaging manifests
BACKUP_DIR="$HOME/chrome-manifest-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# System-wide manifests
if [ -d "/etc/opt/chrome/native-messaging-hosts" ]; then
    sudo cp -R "/etc/opt/chrome/native-messaging-hosts" "$BACKUP_DIR/system/"
    sudo chown -R "$USER":"$(id -gn)" "$BACKUP_DIR/system/" 2>/dev/null || true
fi

# User-specific manifests
if [ -d "$HOME/.config/google-chrome/NativeMessagingHosts" ]; then
    cp -R "$HOME/.config/google-chrome/NativeMessagingHosts" "$BACKUP_DIR/user/"
fi

echo "Backup created at: $BACKUP_DIR"
```

#### Windows
```powershell
# Backup native messaging manifests
$BackupDir = "$env:USERPROFILE\chrome-manifest-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $BackupDir -Force

# User-specific manifests
$UserManifests = "$env:APPDATA\Google\Chrome\NativeMessagingHosts"
if (Test-Path $UserManifests) {
    Copy-Item -Path $UserManifests -Destination "$BackupDir\user" -Recurse
}

Write-Host "Backup created at: $BackupDir"
```

### 2. Backup Chrome Profile (Optional but Recommended)

```bash
# macOS
PROFILE_BACKUP="$HOME/chrome-profile-backup-$(date +%Y%m%d-%H%M%S)"
cp -R "$HOME/Library/Application Support/Google/Chrome/Default" "$PROFILE_BACKUP"

# Linux
PROFILE_BACKUP="$HOME/chrome-profile-backup-$(date +%Y%m%d-%H%M%S)"
cp -R "$HOME/.config/google-chrome/Default" "$PROFILE_BACKUP"
```

## Installation Steps

### 1. Close Chrome Completely

**Critical**: Chrome must be fully closed for manifest changes to take effect.

```bash
# macOS - Try graceful quit first
osascript -e 'tell application "Google Chrome" to quit' 2>/dev/null || true
sleep 2

# If still running, try normal termination
pkill "Google Chrome" 2>/dev/null || true
sleep 2

# Linux - Try graceful quit
if command -v wmctrl &> /dev/null; then
    wmctrl -c "Google Chrome" 2>/dev/null || true
fi
pkill chrome 2>/dev/null || true
sleep 2

# LAST RESORT ONLY - Force kill if still running
# (Check first to avoid data loss)
if pgrep -x "Google Chrome" > /dev/null 2>&1 || pgrep -x "chrome" > /dev/null 2>&1; then
    echo "Warning: Chrome still running, using force kill..."
    pkill -9 -x "Google Chrome" 2>/dev/null || true
    pkill -9 -x "chrome" 2>/dev/null || true
fi

# Verify no Chrome processes running
ps aux | grep -i chrome | grep -v grep
```

**Note**: The script tries graceful quit first to avoid data loss. Force kill (-9) is only used as a last resort.

### 2. Install Claude Extension

1. Open Chrome Web Store
2. Search for "Claude" or navigate to Claude extension URL
3. Click "Add to Chrome"
4. Review permissions carefully
5. Click "Add extension"

### 3. Configure Native Messaging Host

The Claude extension may install its native messaging host automatically. If manual configuration is needed:

#### Verify Host Location
```bash
# macOS - Check for native messaging host
ls -la "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/"

# Linux - Check for native messaging host
ls -la "$HOME/.config/google-chrome/NativeMessagingHosts/"
```

#### Expected Manifest Structure
```json
{
  "name": "com.anthropic.claude_native",
  "description": "Claude Native Messaging Host",
  "path": "/path/to/claude/native/host",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://EXTENSION_ID_HERE/"
  ]
}
```

### 4. Restart Chrome

```bash
# macOS
open -a "Google Chrome"

# Linux
google-chrome &
```

## Verification Steps (Deterministic)

### 1. Verify Chrome Version
```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# Linux
google-chrome --version
```

### 2. Verify Extension Installation

1. Open Chrome
2. Navigate to `chrome://extensions/`
3. Enable "Developer mode"
4. Locate Claude extension
5. Note extension ID
6. Verify status is "Enabled"

### 3. Verify Native Messaging Host via Manifest JSON

**macOS**:
```bash
# List all native messaging hosts
ls -la "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/"

# Find Claude-related manifests
find "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts" -maxdepth 1 -name "*.json" -exec basename {} \;

# Display and validate specific manifest
# Note: Parentheses must be escaped with backslashes to group OR conditions properly
MANIFEST_FILE=$(find "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts" -maxdepth 1 \( -name "*claude*.json" -o -name "*anthropic*.json" \) 2>/dev/null | head -1)
if [ -n "$MANIFEST_FILE" ]; then
    echo "Found manifest: $MANIFEST_FILE"
    cat "$MANIFEST_FILE" | python3 -m json.tool
else
    echo "No Claude manifest found"
fi
```

**Linux**:
```bash
# List all native messaging hosts
ls -la "$HOME/.config/google-chrome/NativeMessagingHosts/"

# Find Claude-related manifests
find "$HOME/.config/google-chrome/NativeMessagingHosts" -maxdepth 1 -name "*.json" -exec basename {} \;

# Display and validate specific manifest
# Note: Parentheses must be escaped with backslashes to group OR conditions properly
MANIFEST_FILE=$(find "$HOME/.config/google-chrome/NativeMessagingHosts" -maxdepth 1 \( -name "*claude*.json" -o -name "*anthropic*.json" \) 2>/dev/null | head -1)
if [ -n "$MANIFEST_FILE" ]; then
    echo "Found manifest: $MANIFEST_FILE"
    cat "$MANIFEST_FILE" | python3 -m json.tool
else
    echo "No Claude manifest found"
fi
```

**Expected Manifest Structure** (name may vary):
```json
{
  "name": "com.anthropic.claude_native",
  "description": "Claude Native Messaging Host",
  "path": "/path/to/claude/native/host",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://EXTENSION_ID_HERE/"
  ]
}
```

**Note**: The actual manifest filename and internal name may vary. Use the find commands above to locate it.

### 4. Verify Extension Permissions

In `chrome://extensions/`, click on Claude extension:
- [ ] Check "Permissions" section
- [ ] Verify permissions match expectations
- [ ] Review "Site access" settings

### 5. Test Basic Functionality

1. Navigate to a webpage
2. Click Claude extension icon
3. Verify extension loads without errors
4. Test basic interaction
5. Check Chrome console for errors (`Ctrl+Shift+J` or `Cmd+Option+J`)

## Troubleshooting

### Extension Not Working

1. **Check Manifest JSON**:
   ```bash
   # Validate JSON syntax
   cat "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_native.json" | python3 -m json.tool
   ```

2. **Verify Host Path**:
   - Check that the `path` in manifest points to existing executable
   - Verify executable has correct permissions
   - Test host independently if possible

3. **Check Extension ID**:
   - Ensure manifest `allowed_origins` includes correct extension ID
   - Extension ID can be found at `chrome://extensions/`

4. **Review Chrome Logs**:
   ```bash
   # macOS - View Chrome system logs
   log show --predicate 'process == "Google Chrome"' --last 5m | grep -i claude
   
   # Linux - Check Chrome debug logs
   google-chrome --enable-logging --v=1 2>&1 | grep -i claude
   ```

### Extension Installed but Native Messaging Fails

1. Restart Chrome completely (quit and reopen)
2. Verify manifest file exists and is readable
3. Check host executable permissions
4. Review manifest `allowed_origins` for typos
5. Check Chrome native messaging logs

### Chrome Won't Start After Changes

1. Restore from backup:
   ```bash
   # Restore native messaging hosts
   cp -R "$BACKUP_DIR/user/NativeMessagingHosts" "$HOME/Library/Application Support/Google/Chrome/"
   ```

2. Delete problematic manifest if identified
3. Restart Chrome
4. Investigate root cause before retrying

## Post-Installation Checklist

- [ ] Chrome version documented
- [ ] Extension ID recorded
- [ ] Native messaging manifest backed up
- [ ] Manifest JSON validated
- [ ] Host path verified
- [ ] Extension permissions reviewed
- [ ] Basic functionality tested
- [ ] Backup location documented

## Security Considerations

### Extension Permissions
- Review all requested permissions before installation
- Understand what data the extension can access
- Regularly audit installed extensions

### Native Messaging Host
- Verify host executable is from trusted source
- Check host binary signature (if available)
- Ensure host runs with least privilege
- Monitor host process activity

### Update Management
- Keep extension updated
- Monitor for security advisories
- Review permission changes on updates
- Back up before major updates

## Rollback Procedure

If issues occur:

1. **Close Chrome completely**
2. **Restore from backup**:
   ```bash
   # Restore native messaging hosts
   cp -R "$BACKUP_DIR/user/NativeMessagingHosts" "$HOME/Library/Application Support/Google/Chrome/"
   ```
3. **Remove extension** (if needed):
   - Go to `chrome://extensions/`
   - Click "Remove" on Claude extension
4. **Restart Chrome**
5. **Verify Chrome works normally**
6. **Investigate failure** before retrying

## References

- [Chrome Native Messaging Documentation](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)
- [Chrome Extension Best Practices](https://developer.chrome.com/docs/extensions/develop/migrate)
- Backup location: `$HOME/chrome-manifest-backup-YYYYMMDD-HHMMSS/`
