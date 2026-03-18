# Mac Setup Guide for Claude Development Stack

## Overview
This guide provides practical, actionable instructions for setting up Claude Desktop, Claude Code, and related development tools on macOS. It focuses on security best practices, proper configuration management, and avoiding common pitfalls.

## Prerequisites

- macOS 12.0 or later
- Administrator access for software installation
- Basic command-line familiarity
- GitHub account (for GitHub MCP integration)

## Quick Start Checklist

- [ ] Install Claude Desktop
- [ ] Install Claude Code
- [ ] Configure local MCP servers (optional)
- [ ] Set up remote Connectors via Desktop UI (optional)
- [ ] Import MCP configuration to Claude Code
- [ ] Install browser extensions (optional)
- [ ] Run acceptance tests

## Installation Steps

### 1. Install Claude Desktop

**Official Download**:
- Visit [claude.ai](https://claude.ai) and download Claude Desktop for macOS
- Or check Claude's official documentation for current download links

**Installation**:
```bash
# After downloading .dmg file
open Claude-Desktop-*.dmg

# Drag Claude app to Applications folder
# Then eject the disk image
```

**Verify Installation**:
```bash
# Check application exists
ls -la /Applications/Claude.app

# Get version (if CLI available)
/Applications/Claude.app/Contents/MacOS/Claude --version || \
defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString
```

### 2. Install Claude Code

**Official Installation**:
- Follow official Claude Code installation documentation
- Verify the Claude CLI tool is available after installation

**Verify Installation**:
```bash
# Check CLI is available
which claude

# Check version
claude --version
```

### 3. Install Homebrew (Recommended for Dependencies)

If not already installed:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify installation
brew --version
```

### 4. Install Node.js (Required for npx-based MCP Servers)

```bash
# Via Homebrew
brew install node

# Verify
node --version
npm --version
```

## MCP Configuration Architecture

### Understanding MCP Servers vs Connectors

#### MCP Servers
**What**: Tool servers (often local processes) that Claude can call. You configure them in `claude_desktop_config.json`.

**Examples**:
- Filesystem access (controlled directories)
- Local memory/cache servers
- Local development tools
- Database clients
- GitHub MCP server (if you need custom tooling)

**Characteristics**:
- Configured via JSON file
- Run as local processes (or connect to services via API)
- Imported to Claude Code via CLI
- Reproducible configuration
- Full control over settings

#### Connectors
**What**: First-party integrations configured in Claude Desktop's UI.

**Configuration**: Desktop UI → Settings → Connectors

**Examples**:
- GitHub integration (if using the Connector)
- Notion workspace access
- Zapier workflows
- Supabase projects
- Slack workspaces

**Characteristics**:
- Configure via Desktop UI
- Often simpler to set up
- OAuth-based authentication
- Managed per-installation

### When to Use Which

**Use Connectors when:**
- A connector exists for your service
- You want simple, UI-guided setup
- You don't need custom configuration

**Use MCP Servers when:**
- You need explicit control over configuration
- You want reproducible configs (version control)
- You need custom tooling or specialized access
- A connector doesn't exist for your use case

**Note**: Some services (like GitHub) may be available via **both** a Connector **and** an MCP server. Choose based on your needs - Connectors for simplicity, MCP servers for flexibility and control.

## Local MCP Configuration

### Configuration File Location

**macOS**:
```bash
$HOME/Library/Application Support/Claude/claude_desktop_config.json
```

### Minimal Safe Example Configuration

**Important**: The example config files use placeholder paths that you must replace.

See `claude_desktop_config.json` for a clean, copy-paste ready config, or `claude_desktop_config.example.json` for an annotated version with detailed guidance.

**Key Points**:
- Replace `/ABSOLUTE/PATH/TO/YOUR/PROJECTS` with your actual project directory path
- Do NOT use `$HOME` or other shell variables in JSON - they won't expand
- Use absolute paths for all file/directory references
- Never include API keys or secrets in the JSON file
- Use environment variables for sensitive data

### Recommended Local MCP Servers

#### 1. Filesystem Server (Limited Scope)
Provides controlled access to specific directories.

**Security Best Practice**: Only grant access to specific project directories, never entire drives.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/yourname/projects/allowed-dir"]
    }
  }
}
```

**Note**: Replace `/Users/yourname/projects/allowed-dir` with your actual absolute path.

#### 2. Memory Server (Optional)
Provides ephemeral storage for conversation context.

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

### Installing MCP Servers

Most official MCP servers are available via npm:

```bash
# Filesystem server
npx -y @modelcontextprotocol/server-filesystem --help

# Memory server
npx -y @modelcontextprotocol/server-memory --help
```

## GitHub Integration Options

### GitHub MCP Server

**Official Documentation**: [GitHub MCP Server README](https://github.com/github/github-mcp-server)

GitHub integration can be set up via **either** a Connector **or** an MCP server, depending on your needs:

#### Option 1: GitHub Connector (Simpler)

**Best for**: Simple access to GitHub data without custom tooling needs

**Setup Steps**:
1. Open Claude Desktop → Settings → Connectors
2. Find GitHub in available connectors
3. Click "Connect" and follow authentication flow
4. Grant appropriate repository access
5. Test connection

**Advantages**: Simple UI-guided setup, OAuth authentication, no JSON config needed

#### Option 2: GitHub MCP Server (More Control)

**Best for**: Custom tooling needs, reproducible configuration, explicit control

**Setup**:
1. Follow the [official GitHub MCP Server documentation](https://github.com/github/github-mcp-server)
2. Configure in `claude_desktop_config.json` like any other MCP server
3. Store GitHub token in environment variables (never in JSON)
4. Import to Claude Code if needed

**Example configuration** (with token in environment):
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

**Security**: Set `GITHUB_TOKEN` environment variable separately - never hardcode tokens in JSON.

### Other Service Integrations

For Notion, Zapier, Supabase, etc.:
- Check if a Connector exists (Settings → Connectors)
- If yes: Use the Connector for simplicity
- If no, or if you need custom control: Look for an MCP server
- Always follow each service's official setup guide
- Never put API keys directly in JSON files

## Importing Configuration to Claude Code

After configuring MCPs in Claude Desktop, import to Claude Code:

```bash
# Standard import command
claude mcp add-from-claude-desktop

# Verify import
claude mcp list
```

This command:
- Reads local MCP configuration from Desktop
- Imports compatible servers to Code
- Maintains consistency between tools

**Note**: Remote Connectors configured via UI are separate and may need independent setup in Code.

## Security Best Practices

### Configuration as Code

1. **Version Control**: Track `claude_desktop_config.json` (without secrets) in git
2. **Code Review**: Review all configuration changes before applying
3. **Testing**: Test new MCPs in isolation before production use
4. **Documentation**: Document why each MCP is needed and what it accesses

### Secret Management

**Never Do**:
- ❌ Hardcode API keys in `claude_desktop_config.json`
- ❌ Commit secrets to version control
- ❌ Share configuration files with embedded credentials
- ❌ Grant MCPs more access than needed

**Always Do**:
- ✅ Use environment variables for secrets
- ✅ Use secret management tools (1Password, AWS Secrets Manager)
- ✅ Apply principle of least privilege
- ✅ Regularly audit MCP permissions
- ✅ Use deny lists for sensitive files

### Example: Secure Configuration with Environment Variables

```json
{
  "mcpServers": {
    "custom-server": {
      "command": "node",
      "args": ["$HOME/servers/custom-server.js"],
      "env": {
        "API_KEY": "${API_KEY}",
        "DB_PASSWORD": "${DB_PASSWORD}"
      }
    }
  }
}
```

Set environment variables separately:
```bash
# In ~/.zshrc or ~/.bashrc
export API_KEY="your-api-key-here"
export DB_PASSWORD="your-password-here"
```

### Deny Lists for Sensitive Files

Prevent MCP filesystem servers from accessing sensitive files:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/projects"],
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

## Common Pitfalls to Avoid

### 1. Configuration Management
❌ **Don't**: Manually copy config files with secrets  
✅ **Do**: Start from minimal example, add what you need, use environment variables

### 2. MCP Overload
❌ **Don't**: Install every available MCP "just in case"  
✅ **Do**: Only install MCPs you actually use

### 3. Secret Exposure
❌ **Don't**: Commit `claude_desktop_config.json` with API keys  
✅ **Do**: Exclude secrets, use environment variables, add `.gitignore` rules

### 4. Permission Creep
❌ **Don't**: Grant filesystem MCP access to entire home directory  
✅ **Do**: Limit to specific project directories with explicit deny lists

### 5. Configuration Drift
❌ **Don't**: Maintain separate configs for Desktop and Code  
✅ **Do**: Use Desktop as authority, import to Code regularly

## Verification and Testing

### System Acceptance Test

After setup, run acceptance tests:

```bash
# Check all tools installed
claude --version
node --version
npm --version

# Verify Desktop config
ls -la "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
python3 -m json.tool "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# List imported MCPs in Code
claude mcp list

# Test basic MCP functionality
# (This step is interactive - test in Claude Desktop/Code)
```

See `ACCEPTANCE_TEST.md` in the migration docs for comprehensive testing procedures.

## Troubleshooting

### Claude Code CLI Not Found

```bash
# Check installation
which claude

# Add to PATH if needed (add to ~/.zshrc or ~/.bashrc)
export PATH="$PATH:/path/to/claude/bin"
```

### MCP Configuration Not Loading

```bash
# Validate JSON syntax
python3 -m json.tool "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# Check file permissions
ls -la "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# Restart Claude Desktop after config changes
```

### Import Command Fails

```bash
# Ensure Claude Desktop config exists
test -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" && echo "Found" || echo "Missing"

# Verify Claude Code is updated
claude --version

# Check for error details
claude mcp add-from-claude-desktop --verbose  # if available
```

## Additional Resources

### Official Documentation
- [Claude Code Settings](https://code.claude.com/docs/de/settings)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)

### Security
- See `SECURITY.md` in this directory for detailed security guidance

## Next Steps

1. **Complete Setup**: Install all required tools
2. **Configure MCPs**: Start with minimal local configuration
3. **Add Connectors**: Set up remote integrations via UI as needed
4. **Import to Code**: Run `claude mcp add-from-claude-desktop`
5. **Test Everything**: Run acceptance tests
6. **Document Your Setup**: Keep notes on what you configured and why
7. **Regular Maintenance**: Review and update configurations periodically

## Getting Help

- Check official Claude documentation
- Review GitHub issues for specific MCP servers
- Consult security guide for permission questions
- Test changes in isolation before production use

---

**Remember**: Treat all configurations as code. Review changes, test thoroughly, and never commit secrets to version control.
