---
name: search-first
description: Research-before-coding workflow. Search for existing tools, libraries, skills, and patterns before writing custom code.
---

# /search-first — Research Before You Code

Systematizes the "search for existing solutions before implementing" workflow.

## Trigger

Use this skill when:
- Starting a new feature that likely has existing solutions
- Adding a dependency or integration
- The user asks "add X functionality" and you're about to write code
- Before creating a new utility, helper, or abstraction
- The user asks "how do I do X", "find a skill for X", or "can you do X"

## Quick Mode (5-check inline sequence)

Before writing a utility or adding functionality, run through these checks in order:

1. **Existing code in project?** → `Grep pattern="[keyword]" glob="*.ts"` in the codebase
2. **Existing skill?** → `ls ~/.claude/skills/` or `npx skills find [keyword]`
3. **Existing MCP?** → `grep -i "[keyword]" ~/.claude/settings.json`
4. **Existing package?** → `WebSearch "npm [keyword]"` or `WebSearch "pypi [keyword]"`
5. **GitHub reference?** → `WebSearch "[keyword] github template [language]"`

If any check returns a viable result, use it instead of writing custom code.

## Full Mode (agent-based deep research)

For non-trivial functionality, launch the researcher agent:

```
Task(subagent_type="general-purpose", prompt="
  Research existing tools for: [DESCRIPTION]
  Language/framework: [LANG]
  Constraints: [ANY]

  Search: npm/PyPI, MCP servers, Claude Code skills, GitHub
  Return: Structured comparison with recommendation
")
```

## Decision Matrix

| Signal | Action |
|--------|--------|
| Exact match, well-maintained, MIT/Apache | **Adopt** — install and use directly |
| Partial match, good foundation | **Extend** — install + write thin wrapper |
| Multiple weak matches | **Compose** — combine 2-3 small packages |
| Nothing suitable found | **Build** — write custom, but informed by research |

## Skills Discovery

The Skills CLI (`npx skills`) is the package manager for the open agent skills ecosystem. Skills are modular packages that extend agent capabilities with specialized knowledge, workflows, and tools.

### Commands

| Command | Purpose |
|---------|---------|
| `npx skills find [query]` | Search for skills by keyword |
| `npx skills add <owner/repo@skill>` | Install a skill from GitHub |
| `npx skills add <pkg> -g -y` | Install globally, skip prompts |
| `npx skills check` | Check for skill updates |
| `npx skills update` | Update all installed skills |
| `npx skills init <name>` | Create a new skill |

Browse skills at: https://skills.sh/

### Presenting Results

When you find relevant skills, present them with:
1. The skill name and what it does
2. The install command
3. A link to learn more

```
I found a skill that might help! The "vercel-react-best-practices" skill provides
React and Next.js performance optimization guidelines from Vercel Engineering.

To install it:
npx skills add vercel-labs/agent-skills@vercel-react-best-practices

Learn more: https://skills.sh/vercel-labs/agent-skills/vercel-react-best-practices
```

### Skill Categories

| Category | Example Queries |
|----------|----------------|
| Web Development | react, nextjs, typescript, css, tailwind |
| Testing | testing, jest, playwright, e2e |
| DevOps | deploy, docker, kubernetes, ci-cd |
| Documentation | docs, readme, changelog, api-docs |
| Code Quality | review, lint, refactor, best-practices |
| Design | ui, ux, design-system, accessibility |
| Productivity | workflow, automation, git |

### When No Skills Are Found

1. Acknowledge that no existing skill was found
2. Offer to help with the task directly
3. Suggest creating a custom skill: `npx skills init my-skill-name`

## Examples

### "Add dead link checking"
```
Need: Check markdown files for broken links
Search: npm "markdown dead link checker"
Found: textlint-rule-no-dead-link (score: 9/10)
Action: ADOPT — npm install textlint-rule-no-dead-link
Result: Zero custom code, battle-tested solution
```

### "Make my React app faster"
```
Need: React performance optimization
Search: npx skills find react performance
Found: vercel-react-best-practices
Action: ADOPT — npx skills add vercel-labs/agent-skills@vercel-react-best-practices
Result: Installed expert knowledge, no custom code
```

## Anti-Patterns

- **Jumping to code**: Writing a utility without checking if one exists
- **Ignoring MCP**: Not checking if an MCP server already provides the capability
- **Ignoring skills ecosystem**: Not running `npx skills find` before building from scratch
- **Over-customizing**: Wrapping a library so heavily it loses its benefits
- **Dependency bloat**: Installing a massive package for one small feature
