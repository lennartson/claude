---
name: add-new-skill-or-agent
description: Workflow command scaffold for add-new-skill-or-agent in everything-claude-code.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /add-new-skill-or-agent

Use this workflow when working on **add-new-skill-or-agent** in `everything-claude-code`.

## Goal

Adds a new skill or agent to the everything-claude-code system, including documentation and configuration.

## Common Files

- `.claude/commands/add-new-skill-or-agent.md`
- `.claude/commands/add-new-skill.md`
- `.claude/commands/add-new-agent.md`
- `.agents/skills/everything-claude-code/SKILL.md`
- `.claude/skills/everything-claude-code/SKILL.md`
- `.agents/skills/everything-claude-code/agents/openai.yaml`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Create or update '.claude/commands/add-new-skill-or-agent.md' or similar command documentation.
- Add or update '.agents/skills/everything-claude-code/SKILL.md' and/or '.claude/skills/everything-claude-code/SKILL.md'.
- Optionally, add or update agent configuration files such as '.agents/skills/everything-claude-code/agents/openai.yaml' or '.codex/agents/*.toml'.

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.