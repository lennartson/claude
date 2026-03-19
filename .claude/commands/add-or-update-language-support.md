---
name: add-or-update-language-support
description: Workflow command scaffold for add-or-update-language-support in everything-claude-code.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /add-or-update-language-support

Use this workflow when working on **add-or-update-language-support** in `everything-claude-code`.

## Goal

Adds or expands support for a programming language, including agents, commands, rules, and tests.

## Common Files

- `agents/*-reviewer.md`
- `agents/*-build-resolver.md`
- `commands/*-build.md`
- `commands/*-review.md`
- `commands/*-test.md`
- `rules/*/*.md`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Add agents/<language>-reviewer.md and/or agents/<language>-build-resolver.md
- Add commands/<language>-build.md, commands/<language>-review.md, commands/<language>-test.md
- Add or update rules/<language>/*.md (coding-style, hooks, patterns, security, testing)
- Add or update skills/<language>-patterns/SKILL.md, skills/<language>-testing/SKILL.md, etc.
- Register agents in AGENTS.md

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.