# Handoff Queue

## Overview
This document provides a staged migration and configuration checklist for transitioning Claude configurations across Desktop, Code, and Chrome environments.

## Stage 1: Desktop MCP Configuration

### Tasks
- [ ] Review existing Claude Desktop MCP configuration
- [ ] Remove any hardcoded secrets or API keys from config
- [ ] Configure local MCP servers (filesystem, memory, etc.) in `claude_desktop_config.json`
- [ ] Configure remote integrations via Desktop Connectors UI (GitHub, Notion, etc.)
- [ ] Test MCP functionality in Claude Desktop
- [ ] **Run acceptance test** for Desktop MCP configuration
- [ ] Document working configuration

### Acceptance Test Criteria
- All local MCPs respond correctly in Desktop
- No authentication errors
- File operations work as expected
- Configuration is documented and backed up

---

## Stage 2: Claude Code MCP Import

### Tasks
- [ ] Verify Claude Code is installed and up to date
- [ ] Import MCP configuration from Desktop using: `claude mcp add-from-claude-desktop`
- [ ] Review imported MCP servers in Claude Code settings
- [ ] Test imported MCPs in Claude Code environment
- [ ] Document any MCPs that require manual configuration
- [ ] Verify configuration consistency between Desktop and Code
- [ ] **Run acceptance test** for Claude Code MCP configuration

### Import Command
```bash
claude mcp add-from-claude-desktop
```

### Acceptance Test Criteria
- Imported MCPs function correctly in Claude Code
- No configuration drift between Desktop and Code
- All expected local MCPs are present
- File permissions and paths are correct

---

## Stage 3: Chrome Extension Configuration

### Tasks
- [ ] Backup current Chrome native messaging manifest
- [ ] Install/update Claude Chrome extension
- [ ] Verify native messaging host configuration
- [ ] Test Chrome extension connectivity
- [ ] Confirm extension permissions are appropriate
- [ ] **Run acceptance test** for Chrome extension

### Acceptance Test Criteria
- Chrome extension connects to native host successfully
- Claude features work within browser
- No permission conflicts
- Extension manifest is backed up

---

## Stage 4: Integration Verification

### Tasks
- [ ] Test workflow across Desktop, Code, and Chrome
- [ ] Verify configuration synchronization
- [ ] Document any environment-specific settings
- [ ] Create runbook for future configuration updates
- [ ] **Run comprehensive acceptance test** across all environments

### Acceptance Test Criteria
- Seamless workflow across all three environments
- No data loss or configuration conflicts
- All MCPs function as expected
- Documentation is complete and accurate

---

## Rollback Plan

### If Issues Occur
1. Stop the migration at current stage
2. Restore from backed-up configurations
3. Document the failure point
4. Investigate root cause
5. Fix issue before retrying

### Backup Locations
- Desktop config: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Code config: Claude Code settings directory
- Chrome manifest: Chrome native messaging manifest directory

---

## Notes

### Configuration Management
- Treat all configurations as code
- Version control (without secrets)
- Test in isolation before production
- Document all manual changes

### Security Reminders
- Never commit secrets to version control
- Use environment variables for sensitive data
- Apply least privilege principle
- Audit access regularly

### Support Resources
- [Claude Code Documentation](https://code.claude.com/docs)
- [Claude Desktop Settings](https://claude.ai/settings)
- [MCP Specification](https://modelcontextprotocol.io)
