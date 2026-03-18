---
name: add-new-skill
description: Workflow command scaffold for add-new-skill in everything-claude-code.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /add-new-skill

Use this workflow when working on **add-new-skill** in `everything-claude-code`.

## Goal

Adds a new skill to the codebase, including documentation, agent configuration, and cross-harness copies.

## Common Files

- `skills/*/SKILL.md`
- `.agents/skills/*/SKILL.md`
- `.agents/skills/*/agents/openai.yaml`
- `.cursor/skills/*/SKILL.md`
- `manifests/install-components.json`
- `manifests/install-modules.json`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Create or update SKILL.md in skills/<skill-name>/SKILL.md
- Create or update agents/openai.yaml in .agents/skills/<skill-name>/agents/openai.yaml
- Copy or update SKILL.md in .agents/skills/<skill-name>/SKILL.md and/or .cursor/skills/<skill-name>/SKILL.md
- Register or update skill in manifests/install-components.json, install-modules.json, or install-profiles.json as needed
- Update documentation (README.md, AGENTS.md) if required

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.