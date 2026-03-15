---
name: team-builder
description: Interactive agent picker — browse available agents by domain, compose custom teams, and dispatch them in parallel on a task. Use when saying "team builder", "pick agents", "assemble team", or "browse agents".
origin: community
---

# Team Builder

Interactive menu for browsing and composing agent teams on demand. Works with flat or domain-subdirectory agent collections.

## When to Use

- You have multiple agent personas (markdown files) and want to pick which ones to use for a task
- You want to compose an ad-hoc team from different domains (e.g., Security + SEO + Architecture)
- You want to browse what agents are available before deciding

## Prerequisites

Agent files must be markdown files containing a persona prompt (identity, rules, workflow, deliverables). The first `# Heading` is used as the agent name and the first paragraph as the description.

Both flat and subdirectory layouts are supported:

**Subdirectory layout** — domain is inferred from the folder name:

```
agents/
├── engineering/
│   ├── security-engineer.md
│   └── software-architect.md
├── marketing/
│   └── seo-specialist.md
└── sales/
    └── discovery-coach.md
```

**Flat layout** — all agents in one directory, domain inferred from filename prefix (e.g., `engineering-security-engineer.md` → Engineering). If no prefix pattern is detected, agents are grouped under "General":

```
agents/
├── engineering-security-engineer.md
├── engineering-software-architect.md
├── marketing-seo-specialist.md
└── sales-discovery-coach.md
```

## Configuration

The agent directory path is probed in order. The first location that contains `.md` files wins:

1. `./agents/**/*.md` + `./agents/*.md` — project-local agents (both depths)
2. `~/.claude/agents/**/*.md` + `~/.claude/agents/*.md` — global agents (both depths)

Results from both locations are merged and deduplicated (by agent name). A custom path can be used instead if the user specifies one.

## How It Works

### Step 1: Discover Available Agents

Glob agent directories using the probe order above. Exclude README files. For each file found:
- **Subdirectory layout:** extract the domain from the parent folder name
- **Flat layout:** extract the domain from the filename prefix before the first `-` that separates domain from agent name (e.g., `engineering-security-engineer.md` → Engineering). If no prefix pattern is detected, use "General"
- Extract the agent name from the first `# Heading`
- Extract a one-line summary from the first paragraph after the heading

If no agent files are found after probing all locations, inform the user: "No agent files found. Checked: [list paths probed]. Expected: markdown files in one of those directories." Then stop.

### Step 2: Present Domain Menu

```
Available agent domains:
1. Engineering — Software Architect, Security Engineer
2. Marketing — SEO Specialist
3. Sales — Discovery Coach, Outbound Strategist

Pick domains or name specific agents (e.g., "1,3" or "security + seo"):
```

- Skip domains with zero agents (empty directories)
- Show agent count per domain

### Step 3: Handle Selection

Accept flexible input:
- Numbers: "1,3" selects all agents from Engineering and Sales
- Names: "security + seo" fuzzy-matches against discovered agents
- "all from engineering" selects every agent in that domain

If more than 5 agents are selected, list them and ask the user to narrow down: "You selected N agents (max 5). Pick which to keep, or say 'top 5'."

Confirm selection:
```
Selected: Security Engineer + SEO Specialist
What should they work on? (describe the task):
```

### Step 4: Spawn Agents in Parallel

1. Read each selected agent's markdown file
2. Prompt for the task description if not already provided
3. Spawn all agents in parallel using the Agent tool:
   - `subagent_type: "general-purpose"`
   - `prompt: "{agent file content}\n\nTask: {task description}"`
   - Each agent runs independently — no inter-agent communication needed

### Step 5: Synthesize Results

Collect all outputs and present a unified report:
- Results grouped by agent
- Synthesis section highlighting:
  - Agreements across agents
  - Conflicts or tensions between recommendations
  - Recommended next steps

If only 1 agent was selected, skip synthesis and present the output directly.

## Rules

- **Dynamic discovery only.** Never hardcode agent lists. New files in the directory auto-appear in the menu.
- **Max 5 agents per team.** More than 5 produces diminishing returns and excessive token usage. Enforce at selection time.
- **Parallel dispatch.** All agents run simultaneously — use the Agent tool's parallel invocation pattern.
- **No TeamCreate needed.** Ad-hoc teams use parallel Agent calls. Reserve TeamCreate for pre-built teams where agents need to debate or respond to each other.

## Examples

```
User: team builder

Claude:
Available agent domains:
1. Engineering (2) — Software Architect, Security Engineer
2. Marketing (1) — SEO Specialist
3. Sales (4) — Discovery Coach, Outbound Strategist, Proposal Strategist, Sales Engineer
4. Support (1) — Executive Summary

Pick domains or name specific agents:

User: security + seo

Claude:
Selected: Security Engineer + SEO Specialist
What should they work on?

User: Review my Next.js e-commerce site before launch

[Both agents spawn in parallel, each applying their specialty to the codebase]

Claude:
## Security Engineer Findings
- [findings...]

## SEO Specialist Findings
- [findings...]

## Synthesis
Both agents agree on: [...]
Tension: Security recommends CSP that blocks inline styles, SEO needs inline schema markup. Resolution: [...]
Next steps: [...]
```
