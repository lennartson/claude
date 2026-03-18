# Desktop MCP Configuration Plan

## Overview
This document provides guidance on configuring Model Context Protocol (MCP) servers in Claude Desktop and migrating configurations to Claude Code.

## MCP Configuration Architecture

### Local MCP Servers
- **Configuration Method**: JSON configuration file (`claude_desktop_config.json`)
- **Location**: Stored in Claude Desktop application directory
- **Use Case**: Local filesystem access, local development tools, system utilities
- **Examples**: filesystem server, memory server, local database connections

### Remote/Server-Based MCPs (Connectors)
- **Configuration Method**: Claude Desktop "Connectors" UI
- **Management**: UI-managed integrations in Claude Desktop settings
- **Use Case**: Cloud services, third-party APIs, hosted integrations
- **Examples**: GitHub, Notion, Zapier, Supabase, Slack

**Key Distinction**: Local MCPs are configured via JSON file and run as local processes. Remote MCPs (Connectors) are configured through the Desktop UI and connect to hosted services.

## Importing MCP Configuration to Claude Code

### Standard Command
The official CLI command for importing MCP configuration from Claude Desktop to Claude Code is:

```bash
claude mcp add-from-claude-desktop
```

This command:
- Reads your local MCP configuration from Claude Desktop
- Imports compatible MCP servers into Claude Code
- Preserves local development environment consistency

### Configuration Migration Workflow
1. Configure and test MCPs in Claude Desktop first
2. Use `claude mcp add-from-claude-desktop` to import to Claude Code
3. Verify imported configuration with acceptance tests
4. Document any MCPs that require manual configuration

## Best Practices

### Configuration as Code
- Treat MCP configurations as code artifacts
- Version control your `claude_desktop_config.json` (without secrets)
- Review changes before applying
- Test in isolation before production use

### Security Considerations
- Never commit API keys or secrets to configuration files
- Use environment variables for sensitive data
- Apply principle of least privilege to MCP permissions
- Audit MCP access regularly

### Preventing Configuration Drift
- Use Claude Desktop as the authoritative source for local MCP configuration
- Import to Claude Code using the official command
- Document any environment-specific overrides
- Sync configurations across development environments periodically

## Troubleshooting

### Import Issues
If `claude mcp add-from-claude-desktop` fails:
1. Verify Claude Desktop is properly installed
2. Check that `claude_desktop_config.json` exists and is valid JSON
3. Ensure Claude Code is up to date
4. Review Claude Code logs for specific error messages

### Configuration Conflicts
If configurations differ between Desktop and Code:
1. Identify which environment is authoritative
2. Back up both configurations
3. Re-import from authoritative source
4. Test thoroughly after sync

## References
- [Claude Code Settings Documentation](https://code.claude.com/docs/de/settings)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)
- Local configuration file: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)
