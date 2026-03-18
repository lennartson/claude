# Claude Code Handoff Guide

## Overview
This document provides technical guidance for migrating and managing Claude Code configuration, with emphasis on security, configuration management, and preventing common pitfalls.

## MCP Configuration Management

### Configuration Source Authority

**Recommended Approach**: Use Claude Desktop as the authoritative source for MCP configuration, then import to Claude Code.

#### Why Desktop as Authority?
1. **Centralized Management**: Single source of truth for local MCPs
2. **Tested Configuration**: Desktop provides UI for testing MCPs before import
3. **Version Control**: Easier to track changes in one location
4. **Drift Prevention**: Regular imports keep environments synchronized

#### Import Workflow
```bash
# Standard import command
claude mcp add-from-claude-desktop

# Verify import
claude mcp list  # Check imported servers
```

### Configuration Sources Explained

#### 1. Claude Desktop Config (Local MCPs)
**File**: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)

**Purpose**: Define local MCP servers that run as processes on your machine

**Example**:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/projects"]
    }
  }
}
```

#### 2. Claude Desktop Connectors (Remote MCPs)
**Location**: Desktop UI → Settings → Connectors

**Purpose**: Configure hosted integrations (GitHub, Notion, Zapier, etc.)

**Note**: Connectors are UI-managed and not stored in JSON config

#### 3. Claude Code Project Config
**Purpose**: Project-specific MCP overrides or additions

**Warning**: Can lead to configuration drift if not carefully managed

### Preventing Configuration Drift

#### Best Practices
1. **Single Source**: Designate Desktop config as primary
2. **Regular Imports**: Re-import after Desktop config changes
3. **Document Overrides**: Clearly document any Code-specific configs
4. **Version Control**: Track Desktop config (without secrets) in git
5. **Audit Trail**: Log all configuration changes

#### Sync Checklist
- [ ] Review Desktop config changes
- [ ] Test in Desktop environment
- [ ] Run `claude mcp add-from-claude-desktop`
- [ ] Verify imported changes in Code
- [ ] Update documentation
- [ ] Run acceptance tests

## Security: Secret Deny Listing

### Tool-Prefixed Syntax (Correct)

When denying MCP tools access to sensitive files, use the proper tool-prefixed syntax:

#### Filesystem Tool Denial Examples
```
Read(./.env)
Read(./config/secrets.yml)
Read($HOME/.aws/credentials)
Write(./.env)
Write(./config/production.yml)
```

#### Common Patterns
```
# Environment files
Read(./.env)
Read(./.env.local)
Read(./.env.production)

# Configuration with secrets
Read(./config/secrets.yml)
Read(./config/database.yml)
Read(./docker-compose.override.yml)

# Credentials and keys
Read($HOME/.ssh/*)
Read($HOME/.aws/*)
Read($HOME/.config/gcloud/*)
```

### Deny List Configuration

Configure MCP server with deny list:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "$HOME/projects"
      ],
      "deny": [
        "Read(./.env)",
        "Read(./.env.*)",
        "Read(./config/secrets.*)",
        "Write(./.env)",
        "Read($HOME/.ssh/*)",
        "Read($HOME/.aws/*)"
      ]
    }
  }
}
```

### Security Principles

#### Least Privilege
- Grant minimum necessary access
- Scope filesystem access to specific directories
- Use deny lists for sensitive files
- Regularly audit MCP permissions

#### Secret Management
- **Never** hardcode secrets in config files
- Use environment variables for sensitive data
- Keep secrets out of version control
- Rotate credentials regularly
- Use secret management systems (1Password, AWS Secrets Manager, etc.)

#### Configuration as Code
- Treat MCP configs as code artifacts
- Review all changes before applying
- Test in isolated environments first
- Document security decisions
- Maintain audit trail

## Migration Checklist

### Pre-Migration
- [ ] Backup current Desktop config
- [ ] Backup current Code config (if exists)
- [ ] Document current MCP setup
- [ ] Identify secrets in configs
- [ ] Create deny list for sensitive files

### Migration Steps
1. **Clean Desktop Config**
   - [ ] Remove any hardcoded secrets
   - [ ] Add proper deny lists
   - [ ] Test configuration

2. **Import to Code**
   ```bash
   claude mcp add-from-claude-desktop
   ```

3. **Verify Import**
   - [ ] Check imported servers in Code
   - [ ] Test MCP functionality
   - [ ] Verify deny lists are applied
   - [ ] Check for configuration drift

4. **Document**
   - [ ] Record migration date
   - [ ] Document any Code-specific overrides
   - [ ] Update team documentation
   - [ ] Create rollback procedure

### Post-Migration
- [ ] Run comprehensive acceptance tests
- [ ] Monitor for issues
- [ ] Update runbooks
- [ ] Train team on new workflow

## Troubleshooting

### Import Fails
1. Check Desktop config is valid JSON
2. Verify Claude Code is updated
3. Review error logs
4. Test Desktop config independently

### MCPs Not Working
1. Verify MCP server dependencies installed
2. Check deny lists aren't too restrictive
3. Validate paths (use absolute paths)
4. Review Claude Code logs

### Configuration Drift Detected
1. Identify which config changed
2. Determine authoritative source
3. Back up both configs
4. Re-import from authority
5. Document the drift cause
6. Update process to prevent recurrence

## Best Practices Summary

1. **Authority**: Desktop config is authoritative for local MCPs
2. **Import**: Use official `claude mcp add-from-claude-desktop` command
3. **Security**: Use tool-prefixed deny list syntax (e.g., `Read(./.env)`)
4. **Secrets**: Never hardcode; use environment variables
5. **Version Control**: Track configs without secrets
6. **Testing**: Test changes in isolation first
7. **Documentation**: Document all configuration decisions
8. **Audit**: Regularly review MCP permissions

## References

- [Claude Code Settings](https://code.claude.com/docs/de/settings)
- [MCP Specification](https://modelcontextprotocol.io)
- [Acceptance Test Guide](./ACCEPTANCE_TEST.md)
