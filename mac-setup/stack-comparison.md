# Claude Development Stack Comparison

## Overview
This document provides a factual comparison of tools in the Claude development stack. It focuses on observable characteristics and documented capabilities without speculative claims.

## Tool Comparison Matrix

| Feature | Claude Desktop | Claude Code | Chrome Extension |
|---------|---------------|-------------|------------------|
| **Platform** | macOS, Windows, Linux | macOS, Windows, Linux | Chrome browser |
| **Primary Use** | Conversational AI interface | Development-focused AI | Browser integration |
| **MCP Support** | Yes (local + UI Connectors) | Yes (imported from Desktop) | Varies by implementation |
| **Configuration** | JSON + UI (Connectors) | Imported via CLI | Browser extension settings |
| **Offline Use** | Requires internet | Requires internet | Requires internet |
| **Integration** | Standalone app | IDE/development workflow | Web browsing |

## Local vs Remote MCP Servers

### Local MCP Servers

**Definition**: Process-based servers running on your local machine

**Configuration Method**: JSON file (`claude_desktop_config.json`)

**Examples**:
- Filesystem access
- Local memory/cache servers
- Database clients
- Development tools

**Characteristics**:
- Direct system access
- No external API dependencies
- Fast local execution
- Privacy: data stays local

### Remote MCP Servers (Connectors)

**Definition**: Integrations with hosted cloud services

**Configuration Method**: Claude Desktop UI (Settings → Connectors)

**Examples**:
- GitHub (repos, issues, PRs)
- Notion workspaces
- Zapier workflows
- Supabase projects

**Characteristics**:
- API-based communication
- OAuth authentication required
- Internet connectivity required
- Service-specific rate limits apply

## Installation Methods

### Claude Desktop

**Installation**:
1. Download from official source (claude.ai)
2. Standard macOS .dmg installation
3. Drag to Applications folder

**Updates**: Check app for update notifications

### Claude Code

**Installation**:
Follow official Claude Code documentation for current installation method

**Updates**: Check via CLI or official documentation

### MCP Servers

**Local MCP Servers (npm-based)**:
```bash
# Installed on-demand via npx
npx -y @modelcontextprotocol/server-filesystem
npx -y @modelcontextprotocol/server-memory
```

**Remote Connectors**:
- Configured via Desktop UI
- No local installation needed
- Authentication per service

## Performance Characteristics

### Measurable Factors

Performance depends on several factors:

1. **Network Connectivity**: Response times vary with internet speed
2. **System Resources**: Available RAM and CPU affect local processing
3. **MCP Server Type**: Local MCPs generally faster than remote API calls
4. **Request Complexity**: Complex queries take longer regardless of tool
5. **Service Load**: Response times may vary based on service availability

### Measuring Your Environment

Test performance in your specific environment:

```bash
# System resources
system_profiler SPHardwareDataType  # macOS

# Network speed
# Use online speed test tools

# Response time measurement
time claude [command]  # If CLI supports timing
```

See acceptance test documentation for systematic measurement procedures.

## Configuration Management

### Desktop as Authority (Recommended)

**Workflow**:
1. Configure local MCPs in Desktop JSON file
2. Configure remote Connectors via Desktop UI
3. Test in Desktop environment
4. Import to Code: `claude mcp add-from-claude-desktop`
5. Verify in Code

**Advantages**:
- Single source of truth
- Easier to maintain
- Reduced configuration drift
- Better for version control

### Separate Configurations (Not Recommended)

Maintaining separate configs for Desktop and Code can lead to:
- Configuration drift
- Inconsistent behavior
- Difficult troubleshooting
- Maintenance burden

## Security Considerations

### Local MCPs

**Risks**:
- Filesystem access (if granted)
- System resource access
- Potential for data exfiltration if compromised

**Mitigation**:
- Use deny lists for sensitive files
- Limit filesystem scope to specific directories
- Audit MCP server code
- Apply least privilege principle

### Remote Connectors

**Risks**:
- API key/token exposure
- Unauthorized access to connected services
- Data sent to third-party services

**Mitigation**:
- Use OAuth when available
- Review connector permissions carefully
- Regularly audit connected services
- Revoke access when no longer needed

## Use Case Guidance

### When to Use Claude Desktop
- General conversational AI tasks
- Testing MCP configurations
- Initial setup and configuration
- Managing remote Connectors

### When to Use Claude Code
- Development workflows
- Code generation and review
- Project-specific AI assistance
- IDE-integrated AI features

### When to Use Browser Extension
- Web page analysis
- Browser-based workflows
- Quick AI access while browsing
- Context from web pages

## Measuring Your Stack

Rather than relying on generic benchmarks, measure your specific setup:

### Acceptance Tests

Create reproducible tests:

```bash
#!/bin/bash
# Simple response time test

echo "Testing Claude Code response time..."
START=$(date +%s)
claude [test-command] > /dev/null 2>&1
END=$(date +%s)
DURATION=$((END - START))
echo "Response time: ${DURATION}s"
```

### System State Capture

Document your environment for comparison:

```bash
# Capture system state
sw_vers  # macOS version
claude --version  # Claude Code version
node --version  # Node.js version (for MCP servers)
system_profiler SPHardwareDataType  # Hardware specs
```

See `../AI/09-Migration-Meta/MIG_2026-02-17/ACCEPTANCE_TEST.md` for comprehensive testing procedures.

## Common Questions

### Q: Which tool is faster?
**A**: Performance depends on your specific environment, network, system resources, and use case. Measure in your environment using acceptance tests.

### Q: Which tool should I use for development?
**A**: Claude Code is designed for development workflows. Use Desktop for general AI tasks and managing configurations.

### Q: Can I use both Desktop and Code together?
**A**: Yes. Configure MCPs in Desktop, import to Code with `claude mcp add-from-claude-desktop`, and use each tool for its strengths.

### Q: How do I choose which MCPs to install?
**A**: Start minimal. Only add MCPs you actively need. Remove unused MCPs to reduce complexity and potential security surface.

### Q: Are there costs associated with different tools?
**A**: Check official Claude pricing documentation for current information. Costs may vary based on usage, subscription tier, and features.

## Best Practices Summary

1. **Start Simple**: Begin with minimal configuration
2. **Measure Your Environment**: Don't rely on generic benchmarks
3. **Desktop as Authority**: Use Desktop for configuration, import to Code
4. **Security First**: Apply least privilege, use deny lists, audit regularly
5. **Test Changes**: Test MCP changes in isolation before production
6. **Document Decisions**: Record why each tool/MCP is used
7. **Regular Audits**: Review configurations and permissions periodically

## References

### Official Documentation
- [Claude Code Settings](https://code.claude.com/docs/de/settings)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)

### Related Documentation
- `README.md` - Setup guide
- `SECURITY.md` - Security best practices
- `../AI/09-Migration-Meta/MIG_2026-02-17/ACCEPTANCE_TEST.md` - Testing procedures

---

**Note**: This document focuses on factual, measurable characteristics. For specific performance numbers or costs, refer to official documentation and test in your specific environment.
