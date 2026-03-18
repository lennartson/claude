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

- `fix`
- `test`
- `feat`
- `docs`

### Message Guidelines

- Average message length: ~66 characters
- Keep first line concise and descriptive
- Use imperative mood ("Add feature" not "Added feature")


*Commit message example*

```text
feat: add everything-claude-code ECC bundle (.claude/commands/add-or-update-language-support.md)
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
feat: add everything-claude-code ECC bundle (.claude/commands/add-new-skill-or-agent.md)
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

**Frequency**: ~25 times per month

**Steps**:
1. Add feature implementation
2. Add tests for feature
3. Update documentation

**Files typically involved**:
- `manifests/*`
- `**/*.test.*`
- `**/api/**`

**Example commit sequence**:
```
feat: strengthen install lifecycle and target adapters (#512)
feat: add skill evolution foundation (#514)
feat: add SQLite state store and query CLI (#510)
```

### Add New Skill

Adds a new skill to the repository, including documentation and agent config if cross-harness.

**Frequency**: ~6 times per month

**Steps**:
1. Create or update skills/<skill-name>/SKILL.md with skill documentation.
2. If cross-harness, add .agents/skills/<skill-name>/SKILL.md and/or .cursor/skills/<skill-name>/SKILL.md.
3. If agent config is needed, add .agents/skills/<skill-name>/agents/openai.yaml.
4. If needed, register the skill in install manifests or documentation.

**Files typically involved**:
- `skills/*/SKILL.md`
- `.agents/skills/*/SKILL.md`
- `.cursor/skills/*/SKILL.md`
- `.agents/skills/*/agents/openai.yaml`

**Example commit sequence**:
```
Create or update skills/<skill-name>/SKILL.md with skill documentation.
If cross-harness, add .agents/skills/<skill-name>/SKILL.md and/or .cursor/skills/<skill-name>/SKILL.md.
If agent config is needed, add .agents/skills/<skill-name>/agents/openai.yaml.
If needed, register the skill in install manifests or documentation.
```

### Add New Agent

Adds a new agent to the repository, including documentation and registration.

**Frequency**: ~3 times per month

**Steps**:
1. Create agents/<agent-name>.md with agent documentation.
2. Register the agent in AGENTS.md.
3. If needed, add agent config in .codex/agents/<agent-name>.toml or similar.
4. If needed, update rules/common/agents.md or other rules files.

**Files typically involved**:
- `agents/*.md`
- `AGENTS.md`
- `.codex/agents/*.toml`
- `rules/common/agents.md`

**Example commit sequence**:
```
Create agents/<agent-name>.md with agent documentation.
Register the agent in AGENTS.md.
If needed, add agent config in .codex/agents/<agent-name>.toml or similar.
If needed, update rules/common/agents.md or other rules files.
```

### Add Language Support

Adds support for a new programming language, including agents, skills, commands, rules, and tests.

**Frequency**: ~2 times per month

**Steps**:
1. Add agents for the language (e.g., <lang>-reviewer.md, <lang>-build-resolver.md).
2. Add skills for the language (e.g., <lang>-patterns/SKILL.md, <lang>-testing/SKILL.md).
3. Add commands for the language (e.g., commands/<lang>-build.md, <lang>-review.md, <lang>-test.md).
4. Add or update rules for the language (e.g., rules/<lang>/*.md).
5. Add or update tests for language hooks or features.
6. Register agents and update documentation (AGENTS.md, README.md).

**Files typically involved**:
- `agents/*<lang>*.*`
- `skills/*<lang>*/*`
- `commands/*<lang>*.*`
- `rules/<lang>/*.md`
- `tests/hooks/*.test.js`
- `AGENTS.md`
- `README.md`

**Example commit sequence**:
```
Add agents for the language (e.g., <lang>-reviewer.md, <lang>-build-resolver.md).
Add skills for the language (e.g., <lang>-patterns/SKILL.md, <lang>-testing/SKILL.md).
Add commands for the language (e.g., commands/<lang>-build.md, <lang>-review.md, <lang>-test.md).
Add or update rules for the language (e.g., rules/<lang>/*.md).
Add or update tests for language hooks or features.
Register agents and update documentation (AGENTS.md, README.md).
```

### Add Or Update Command

Adds or updates a command (slash command or workflow) and its documentation.

**Frequency**: ~3 times per month

**Steps**:
1. Create or update commands/<command>.md with command documentation.
2. If mirrored, update .opencode/commands/<command>.md.
3. If related to an agent or skill, update agent/skill documentation.
4. If needed, update AGENTS.md, README.md, or other registry files.

**Files typically involved**:
- `commands/*.md`
- `.opencode/commands/*.md`
- `skills/*/SKILL.md`
- `AGENTS.md`
- `README.md`

**Example commit sequence**:
```
Create or update commands/<command>.md with command documentation.
If mirrored, update .opencode/commands/<command>.md.
If related to an agent or skill, update agent/skill documentation.
If needed, update AGENTS.md, README.md, or other registry files.
```

### Add Or Update Install Manifest

Adds or updates install manifest files to register new skills, modules, or profiles.

**Frequency**: ~2 times per month

**Steps**:
1. Update manifests/install-components.json, install-modules.json, or install-profiles.json.
2. If needed, update related documentation or validation scripts.

**Files typically involved**:
- `manifests/install-components.json`
- `manifests/install-modules.json`
- `manifests/install-profiles.json`

**Example commit sequence**:
```
Update manifests/install-components.json, install-modules.json, or install-profiles.json.
If needed, update related documentation or validation scripts.
```

### Feature Development With Tests And Docs

Implements a new feature or fixes an issue, including code, tests, and documentation.

**Frequency**: ~4 times per month

**Steps**:
1. Implement or update code in scripts/, skills/, or agents/.
2. Write or update corresponding tests in tests/.
3. Update related documentation (README.md, AGENTS.md, etc.).

**Files typically involved**:
- `scripts/**/*.js`
- `skills/**/*.js`
- `agents/**/*.js`
- `tests/**/*.test.js`
- `README.md`
- `AGENTS.md`

**Example commit sequence**:
```
Implement or update code in scripts/, skills/, or agents/.
Write or update corresponding tests in tests/.
Update related documentation (README.md, AGENTS.md, etc.).
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
