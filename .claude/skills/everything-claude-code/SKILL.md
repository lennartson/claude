---
name: everything-claude-code-conventions
description: Development conventions and patterns for everything-claude-code. JavaScript project with conventional commits.
---

# Everything Claude Code Conventions

> Generated from [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) on 2026-03-18

## Overview

This skill teaches Claude the development patterns and conventions used in everything-claude-code.

## Tech Stack

- **Primary Language**: JavaScript
- **Architecture**: hybrid module organization
- **Test Location**: separate

## When to Use This Skill

Activate this skill when:
- Making changes to this repository
- Adding new features following established patterns
- Writing tests that match project conventions
- Creating commits with proper message format

## Commit Conventions

Follow these commit message conventions based on 500 analyzed commits.

### Commit Style: Conventional Commits

### Prefixes Used

- `feat`
- `fix`

### Message Guidelines

- Average message length: ~81 characters
- Keep first line concise and descriptive
- Use imperative mood ("Add feature" not "Added feature")


*Commit message example*

```text
feat: add everything-claude-code ECC bundle (.claude/commands/add-new-agent-command.md)
```

*Commit message example*

```text
fix: resolve 8 test failures on main (install pipeline, orchestrator, repair) (#564)
```

*Commit message example*

```text
merge: PR #529 — feat(skills): add documentation-lookup, bun-runtime, nextjs-turbopack; feat(agents): add rust-reviewer
```

*Commit message example*

```text
docs(skills): align documentation-lookup with CONTRIBUTING template; add cross-harness (Codex/Cursor) skill copies
```

*Commit message example*

```text
chore(config): governance and config foundation (#292)
```

*Commit message example*

```text
feat: add everything-claude-code ECC bundle (.claude/commands/add-new-skill-command.md)
```

*Commit message example*

```text
feat: add everything-claude-code ECC bundle (.claude/commands/feature-development.md)
```

*Commit message example*

```text
feat: add everything-claude-code ECC bundle (.claude/enterprise/controls.md)
```

## Architecture

### Project Structure: Single Package

This project uses **hybrid** module organization.

### Configuration Files

- `.github/workflows/ci.yml`
- `.github/workflows/maintenance.yml`
- `.github/workflows/monthly-metrics.yml`
- `.github/workflows/release.yml`
- `.github/workflows/reusable-release.yml`
- `.github/workflows/reusable-test.yml`
- `.github/workflows/reusable-validate.yml`
- `.opencode/package.json`
- `.opencode/tsconfig.json`
- `.prettierrc`
- `eslint.config.js`
- `package.json`

### Guidelines

- This project uses a hybrid organization
- Follow existing patterns when adding new code

## Code Style

### Language: JavaScript

### Naming Conventions

| Element | Convention |
|---------|------------|
| Files | camelCase |
| Functions | camelCase |
| Classes | PascalCase |
| Constants | SCREAMING_SNAKE_CASE |

### Import Style: Mixed Style

### Export Style: Named Exports


*Preferred export style*

```typescript
// Use named exports
export function calculateTotal() { ... }
export const TAX_RATE = 0.1
export interface Order { ... }
```

## Testing

### Test Framework

No specific test framework detected — use the repository's existing test patterns.

### File Pattern: `*.test.js`

### Test Types

- **Unit tests**: Test individual functions and components in isolation
- **Integration tests**: Test interactions between multiple components/services

### Coverage

This project has coverage reporting configured. Aim for 80%+ coverage.


## Error Handling

### Error Handling Style: Try-Catch Blocks


*Standard error handling pattern*

```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('User-friendly message')
}
```

## Common Workflows

These workflows were detected from analyzing commit patterns.

### Feature Development

Standard feature implementation workflow

**Frequency**: ~30 times per month

**Steps**:
1. Add feature implementation
2. Add tests for feature
3. Update documentation

**Example commit sequence**:
```
feat: add everything-claude-code ECC bundle (.claude/team/everything-claude-code-team-config.json)
feat: add everything-claude-code ECC bundle (.claude/enterprise/controls.md)
feat: add everything-claude-code ECC bundle (.claude/commands/feature-development.md)
```

### Add New Agent Command

Adds documentation or configuration for a new agent command to the system.

**Frequency**: ~4 times per month

**Steps**:
1. Create or update '.claude/commands/add-new-agent-command.md' with details of the new agent command.

**Files typically involved**:
- `.claude/commands/add-new-agent-command.md`

**Example commit sequence**:
```
Create or update '.claude/commands/add-new-agent-command.md' with details of the new agent command.
```

### Add New Skill Command

Adds documentation or configuration for a new skill command to the system.

**Frequency**: ~4 times per month

**Steps**:
1. Create or update '.claude/commands/add-new-skill-command.md' with details of the new skill command.

**Files typically involved**:
- `.claude/commands/add-new-skill-command.md`

**Example commit sequence**:
```
Create or update '.claude/commands/add-new-skill-command.md' with details of the new skill command.
```

### Add Team Config

Adds or updates the team configuration for everything-claude-code.

**Frequency**: ~4 times per month

**Steps**:
1. Create or update '.claude/team/everything-claude-code-team-config.json' with new team configuration.

**Files typically involved**:
- `.claude/team/everything-claude-code-team-config.json`

**Example commit sequence**:
```
Create or update '.claude/team/everything-claude-code-team-config.json' with new team configuration.
```

### Add Skill Documentation

Adds or updates documentation for a skill in the agents or claude skills directories.

**Frequency**: ~3 times per month

**Steps**:
1. Create or update '.agents/skills/everything-claude-code/SKILL.md' and/or '.claude/skills/everything-claude-code/SKILL.md' with skill details.

**Files typically involved**:
- `.agents/skills/everything-claude-code/SKILL.md`
- `.claude/skills/everything-claude-code/SKILL.md`

**Example commit sequence**:
```
Create or update '.agents/skills/everything-claude-code/SKILL.md' and/or '.claude/skills/everything-claude-code/SKILL.md' with skill details.
```

### Add Identity Or Tools Config

Adds or updates system identity or ECC tools configuration.

**Frequency**: ~3 times per month

**Steps**:
1. Create or update '.claude/identity.json' and/or '.claude/ecc-tools.json' with new configuration.

**Files typically involved**:
- `.claude/identity.json`
- `.claude/ecc-tools.json`

**Example commit sequence**:
```
Create or update '.claude/identity.json' and/or '.claude/ecc-tools.json' with new configuration.
```

### Add Research Or Guardrails Docs

Adds or updates research playbooks or guardrails documentation.

**Frequency**: ~3 times per month

**Steps**:
1. Create or update '.claude/research/everything-claude-code-research-playbook.md' and/or '.claude/rules/everything-claude-code-guardrails.md'.

**Files typically involved**:
- `.claude/research/everything-claude-code-research-playbook.md`
- `.claude/rules/everything-claude-code-guardrails.md`

**Example commit sequence**:
```
Create or update '.claude/research/everything-claude-code-research-playbook.md' and/or '.claude/rules/everything-claude-code-guardrails.md'.
```

### Add Codex Agent Config

Adds or updates agent configuration files in the codex agents directory.

**Frequency**: ~3 times per month

**Steps**:
1. Create or update '.codex/agents/docs-researcher.toml', '.codex/agents/reviewer.toml', or '.codex/agents/explorer.toml' with agent configuration.

**Files typically involved**:
- `.codex/agents/docs-researcher.toml`
- `.codex/agents/reviewer.toml`
- `.codex/agents/explorer.toml`

**Example commit sequence**:
```
Create or update '.codex/agents/docs-researcher.toml', '.codex/agents/reviewer.toml', or '.codex/agents/explorer.toml' with agent configuration.
```

### Add Enterprise Controls Doc

Adds or updates enterprise controls documentation.

**Frequency**: ~4 times per month

**Steps**:
1. Create or update '.claude/enterprise/controls.md' with the relevant information.

**Files typically involved**:
- `.claude/enterprise/controls.md`

**Example commit sequence**:
```
Create or update '.claude/enterprise/controls.md' with the relevant information.
```


## Best Practices

Based on analysis of the codebase, follow these practices:

### Do

- Use conventional commit format (feat:, fix:, etc.)
- Follow *.test.js naming pattern
- Use camelCase for file names
- Prefer named exports

### Don't

- Don't write vague commit messages
- Don't skip tests for new features
- Don't deviate from established patterns without discussion

---

*This skill was auto-generated by [ECC Tools](https://ecc.tools). Review and customize as needed for your team.*
