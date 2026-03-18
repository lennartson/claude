# Security Guide for Claude MCP Configuration

## Overview
This document provides security guidance for configuring Model Context Protocol (MCP) servers, managing trust boundaries, and treating configurations as auditable code artifacts.

## Core Security Principles

### 1. Least Privilege
Grant only the minimum access necessary for each MCP server to function.

**Example: Filesystem Access**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "$HOME/projects/specific-project"
      ]
    }
  }
}
```

❌ **Don't**: Grant access to entire home directory or root  
✅ **Do**: Limit to specific project directories

### 2. Defense in Depth
Use multiple layers of security controls.

**Layers**:
1. **Scope limitation**: Restrict MCP to specific directories
2. **Deny lists**: Block sensitive files explicitly
3. **Environment isolation**: Use separate configs for different environments
4. **Regular audits**: Review permissions periodically

### 3. Configuration as Code
Treat all MCP configurations as code artifacts subject to review and version control.

**Best Practices**:
- Version control configs (without secrets)
- Code review all changes
- Test in isolation before production
- Document security decisions
- Maintain audit trail

## MCP Trust Boundaries

### Local MCP Servers

**Trust Model**: Local MCPs run as processes with your user permissions

**Security Implications**:
- Can access any file your user can access
- Can execute commands with your privileges
- Can modify system state
- Can communicate over network

**Risk Level**: HIGH - Full local system access potential

**Mitigation**:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "$HOME/projects/allowed-dir"
      ],
      "deny": [
        "Read(./.env)",
        "Read(./.env.*)",
        "Write(./.env)",
        "Read(./config/secrets.*)",
        "Write(./config/secrets.*)",
        "Read($HOME/.ssh/*)",
        "Write($HOME/.ssh/*)",
        "Read($HOME/.aws/*)",
        "Write($HOME/.aws/*)",
        "Read($HOME/.config/gcloud/*)",
        "Write($HOME/.config/gcloud/*)",
        "Read($HOME/Library/Keychains/*)",
        "Write($HOME/Library/Keychains/*)"
      ]
    }
  }
}
```

### Remote MCP Servers (Connectors)

**Trust Model**: Remote MCPs communicate with third-party services via APIs

**Security Implications**:
- Data transmitted to external services
- Subject to third-party security policies
- OAuth tokens stored locally
- Potential for data leakage

**Risk Level**: MEDIUM to HIGH - Depends on service and data sensitivity

**Mitigation**:
1. **Review Permissions**: Understand what each Connector can access
2. **Minimize Scope**: Grant minimal necessary permissions
3. **Regular Audit**: Review connected services periodically
4. **Revoke Unused**: Remove Connectors no longer needed
5. **Monitor Activity**: Check service activity logs

## Secret Management

### Never Hardcode Secrets

❌ **Wrong**:
```json
{
  "mcpServers": {
    "custom": {
      "command": "node",
      "args": ["server.js"],
      "env": {
        "API_KEY": "sk-abc123xyz789"
      }
    }
  }
}
```

✅ **Correct**:
```json
{
  "mcpServers": {
    "custom": {
      "command": "node",
      "args": ["server.js"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

Then set environment variable:
```bash
# In ~/.zshrc or ~/.bashrc
export API_KEY="sk-abc123xyz789"

# Or use a secret management tool
export API_KEY="$(security find-generic-password -a $USER -s 'api-key' -w)"
```

### Secret Storage Options

#### 1. Environment Variables
```bash
# ~/.zshrc or ~/.bashrc
export API_KEY="your-key"
export DB_PASSWORD="your-password"
```

**Pros**: Simple, widely supported  
**Cons**: Visible in process list, stored in shell history if set inline

#### 2. macOS Keychain
```bash
# Store secret
security add-generic-password -a $USER -s 'api-key' -w 'your-key'

# Retrieve secret
security find-generic-password -a $USER -s 'api-key' -w
```

**Pros**: Encrypted, secure  
**Cons**: macOS-specific

#### 3. Secret Management Services
- AWS Secrets Manager
- HashiCorp Vault
- 1Password CLI
- Doppler

**Pros**: Enterprise-grade, audit trails, rotation  
**Cons**: Additional complexity, cost

### Secrets in Version Control

**Rules**:
1. **Never commit secrets** to version control
2. **Use .gitignore** for files with secrets
3. **Scan for secrets** before committing
4. **Rotate immediately** if accidentally committed

**.gitignore Example**:
```
# Environment files
.env
.env.*
!.env.example

# Config files that might contain secrets
claude_desktop_config.json
config/secrets.*

# Credentials
*.pem
*.key
credentials.json
```

**Pre-commit Hook** (optional):
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for potential secrets
if git diff --cached | grep -iE '(password|secret|api_key|token|credential).*=.*["\047][^"\047]{8,}'; then
    echo "ERROR: Potential secret detected in commit"
    echo "Review your changes and remove secrets before committing"
    exit 1
fi
```

## Deny Lists and Access Control

### Filesystem Deny Lists

Always protect sensitive files:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME/projects"],
      "deny": [
        "Read(./.env)",
        "Read(./.env.*)",
        "Write(./.env)",
        "Read(./config/secrets.*)",
        "Write(./config/secrets.*)",
        "Read(./config/database.yml)",
        "Write(./config/database.yml)",
        "Read($HOME/.ssh/*)",
        "Write($HOME/.ssh/*)",
        "Read($HOME/.aws/*)",
        "Write($HOME/.aws/*)",
        "Read($HOME/.config/gcloud/*)",
        "Write($HOME/.config/gcloud/*)",
        "Read($HOME/.kube/*)",
        "Write($HOME/.kube/*)",
        "Read($HOME/.docker/config.json)",
        "Write($HOME/.docker/config.json)",
        "Read($HOME/.gnupg/*)",
        "Write($HOME/.gnupg/*)"
      ]
    }
  }
}
```

### Common Sensitive Paths

Protect these by default:

**Credentials & Keys**:
- `$HOME/.ssh/` - SSH keys
- `$HOME/.aws/` - AWS credentials
- `$HOME/.config/gcloud/` - Google Cloud credentials
- `$HOME/.kube/` - Kubernetes configs
- `$HOME/.gnupg/` - GPG keys
- `$HOME/.docker/config.json` - Docker credentials

**Environment & Configuration**:
- `.env` - Environment variables
- `.env.*` - Environment-specific configs
- `config/secrets.*` - Secret configuration files
- `config/database.yml` - Database credentials

**Application Secrets**:
- `credentials.json` - Generic credentials
- `*.pem` - Private keys
- `*.key` - Private keys
- `auth.json` - Authentication configs

## Auditing and Monitoring

### Regular Configuration Audits

**Monthly Review Checklist**:
- [ ] Review all configured MCP servers
- [ ] Verify each MCP is still needed
- [ ] Check deny lists are current
- [ ] Confirm no secrets in config files
- [ ] Review connected Connectors
- [ ] Audit filesystem access scopes
- [ ] Test deny lists are working
- [ ] Update documentation

### Audit Script Example

```bash
#!/bin/bash
# audit-mcp-config.sh

CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

echo "=== MCP Configuration Audit ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Check for secrets in config
echo "Checking for potential secrets..."
if grep -qi "password\|secret\|api_key\|apikey\|token\|credential" "$CONFIG"; then
    echo "⚠️  WARNING: Potential secrets detected!"
    grep -i "password\|secret\|api_key\|apikey\|token\|credential" "$CONFIG" | sed 's/:.*/: [REDACTED]/'
else
    echo "✓ No obvious secrets found"
fi
echo ""

# Check for environment variable usage
echo "Checking for environment variable usage..."
if grep -q '\${.*}' "$CONFIG"; then
    echo "✓ Environment variables in use:"
    grep -o '\${[^}]*}' "$CONFIG" | sort -u
else
    echo "⚠️  No environment variables found"
fi
echo ""

# List configured servers
echo "Configured MCP servers:"
python3 -c "import json; f=open('$CONFIG'); d=json.load(f); [print(f'  - {k}') for k in d.get('mcpServers', {}).keys()]"
echo ""

# Check deny lists
echo "Servers with deny lists:"
python3 -c "import json; f=open('$CONFIG'); d=json.load(f); [print(f'  - {k}: {len(v.get(\"deny\", []))} rules') for k,v in d.get('mcpServers', {}).items() if 'deny' in v]"
echo ""
```

### Security Incident Response

**If Secret is Exposed**:

1. **Immediate Actions**:
   - Revoke/rotate the exposed secret immediately
   - Remove from version control history if committed
   - Notify relevant stakeholders
   - Document the incident

2. **Investigation**:
   - Determine exposure scope
   - Check access logs for unauthorized use
   - Identify root cause
   - Document findings

3. **Remediation**:
   - Implement preventive controls
   - Update procedures
   - Train team on secure practices
   - Add pre-commit hooks if not present

4. **Follow-up**:
   - Verify new secret is working
   - Monitor for suspicious activity
   - Review and update security policies
   - Schedule review of other secrets

## Configuration Review Process

### Before Applying Changes

**Checklist**:
- [ ] No secrets in configuration
- [ ] Deny lists protect sensitive files
- [ ] Access scope is minimal
- [ ] Environment variables used for secrets
- [ ] Changes documented
- [ ] Tested in isolation
- [ ] Peer reviewed (if team environment)

### Code Review Questions

When reviewing MCP configuration changes:

1. **Why is this MCP needed?**
2. **What access does it require?**
3. **Are there secrets in the config?**
4. **Is access scope minimal?**
5. **Are deny lists comprehensive?**
6. **Could this be done more securely?**
7. **What's the risk if compromised?**
8. **How will we audit this?**

## Compliance and Governance

### Documentation Requirements

For each MCP server, document:

1. **Purpose**: Why is this MCP configured?
2. **Access**: What can it access?
3. **Justification**: Why does it need this access?
4. **Risk Assessment**: What are the risks?
5. **Mitigation**: How are risks mitigated?
6. **Owner**: Who is responsible?
7. **Review Date**: When to review next?

### Template

```markdown
## MCP Server: [name]

**Purpose**: [Why this MCP exists]

**Access Granted**: 
- [Specific access granted]

**Justification**: [Why this access is needed]

**Risk Level**: [Low/Medium/High]

**Risks**:
- [Potential risk 1]
- [Potential risk 2]

**Mitigation**:
- [Control 1]
- [Control 2]

**Owner**: [Person responsible]

**Last Review**: [Date]
**Next Review**: [Date]
```

## Best Practices Summary

### DO
✅ Use least privilege access  
✅ Implement comprehensive deny lists  
✅ Use environment variables for secrets  
✅ Version control configs (without secrets)  
✅ Code review all changes  
✅ Audit configurations regularly  
✅ Document security decisions  
✅ Test in isolation first  
✅ Monitor for anomalies  
✅ Rotate secrets regularly  

### DON'T
❌ Hardcode secrets in configs  
❌ Grant excessive filesystem access  
❌ Skip deny lists  
❌ Commit secrets to version control  
❌ Share configs with embedded credentials  
❌ Ignore security warnings  
❌ Deploy without testing  
❌ Forget to audit  
❌ Reuse secrets across environments  
❌ Ignore suspicious activity  

## References

- [Model Context Protocol Specification](https://modelcontextprotocol.io)
- [OWASP Security Guidelines](https://owasp.org/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

## Related Documentation

- `README.md` - Setup guide
- `stack-comparison.md` - Tool comparison
- `../AI/09-Migration-Meta/MIG_2026-02-17/CODE_HANDOFF.md` - Configuration management

---

**Remember**: Security is an ongoing process, not a one-time setup. Regular audits, monitoring, and updates are essential for maintaining a secure configuration.
