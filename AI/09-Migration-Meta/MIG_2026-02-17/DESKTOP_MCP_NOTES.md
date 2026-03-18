# Desktop MCP Notes

## Quick Reference for Claude Desktop MCP Configuration

### Official MCP Import Command

The sanctioned command for importing MCP configuration from Claude Desktop to Claude Code is:

```bash
claude mcp add-from-claude-desktop
```

This is the official, supported method for migrating local MCP server configurations between Claude Desktop and Claude Code.

### When to Use This Command

- **Initial Setup**: When setting up Claude Code for the first time
- **Configuration Sync**: When MCP servers are added or modified in Desktop
- **Environment Migration**: When moving to a new development machine
- **Drift Resolution**: When Desktop and Code configurations diverge

### Configuration Architecture

#### Local MCP Servers (JSON Config)
Local MCP servers are defined in `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

**Characteristics**:
- Configured via JSON file
- Run as local processes
- Direct filesystem or system access
- Imported via `claude mcp add-from-claude-desktop`

#### Remote MCP Servers (Connectors)
Remote integrations are configured via Desktop UI under "Connectors":

**Examples**:
- GitHub integration
- Notion workspace
- Zapier workflows
- Supabase projects
- Slack workspaces

**Characteristics**:
- Configured via Desktop UI
- Connect to hosted services
- API-based communication
- Managed separately from local config

### Standard Migration Workflow

1. **Configure in Desktop First**
   - Set up and test local MCPs in `claude_desktop_config.json`
   - Configure remote integrations via Connectors UI
   - Verify all servers work correctly

2. **Import to Claude Code**
   ```bash
   claude mcp add-from-claude-desktop
   ```

3. **Verify Import**
   - Check Claude Code settings for imported servers
   - Test MCP functionality
   - Document any discrepancies

4. **Maintain Consistency**
   - Use Desktop as the authoritative source
   - Re-import when Desktop config changes
   - Document environment-specific overrides

### Security Best Practices

- **Never hardcode secrets** in `claude_desktop_config.json`
- Use **environment variables** for API keys and tokens
- Apply **least privilege** to MCP permissions
- **Version control** configs (without secrets)
- **Audit** MCP access regularly
- **Test** in isolation before production use

### Common Configuration Patterns

#### Filesystem Server (Limited Scope)
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/projects/allowed-dir"]
    }
  }
}
```

#### Memory Server (Ephemeral Storage)
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

#### Environment Variable Pattern
```json
{
  "mcpServers": {
    "custom-server": {
      "command": "node",
      "args": ["/path/to/server.js"],
      "env": {
        "API_KEY": "${API_KEY}",
        "SERVICE_URL": "${SERVICE_URL}"
      }
    }
  }
}
```

### Troubleshooting

#### Import Command Not Found
- Verify Claude Code CLI is installed
- Check PATH includes Claude Code binaries
- Update Claude Code to latest version

#### Configuration Not Importing
- Validate `claude_desktop_config.json` syntax (use JSON linter)
- Ensure Desktop config file exists at expected location
- Check file permissions

#### MCPs Not Working After Import
- Verify MCP server dependencies are installed
- Check paths are absolute or properly resolved
- Review Claude Code logs for error messages
- Test MCP server independently

### Configuration File Locations

**macOS**:
- Desktop: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Code: Check Claude Code settings/preferences

**Linux**:
- Desktop: `~/.config/Claude/claude_desktop_config.json`
- Code: Check Claude Code settings/preferences

**Windows**:
- Desktop: `%APPDATA%\Claude\claude_desktop_config.json`
- Code: Check Claude Code settings/preferences

### References

- [Claude Code Settings Documentation](https://code.claude.com/docs/de/settings)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)
- [MCP Server Examples](https://github.com/modelcontextprotocol)
