# Research: CLAUDE.md Best Practices (Mar 2026)

## Top Findings

### 1. Arize Prompt Learning (Meta-Optimization of Rules) — VERY HIGH NOVELTY
- Automated optimization of CLAUDE.md via LLM evals on SWE-bench
- +5.19% general, +10.87% on Django; repo-specific optimization +11%
- Proves instruction quality matters quantifiably — no architecture changes needed
- Source: [arize.com/blog/claude-md-best-practices](https://arize.com/blog/claude-md-best-practices-learned-from-optimizing-claude-code-with-prompt-learning/)

### 2. Forced-Eval Skill Activation Hooks — HIGH
- Without hooks, Claude discovers skills in only ~44% of matching cases
- Forced-eval commitment pattern (explicit YES/NO per skill): 84% activation
- Simple "check skills first" hook: only 20% improvement
- Source: [dev.to/diet-code103](https://dev.to/diet-code103/claude-code-is-a-beast-tips-from-6-months-of-hardcore-use-572n)

### 3. Declarative Workflow Profiles (Brad Feld) — HIGH
- Global-first config: all rules, skills, commands in `~/.claude/`
- Per-project workflow profiles drive behavior (base_branch, quality_gates, review depth)
- Review triage auto-scales: NONE (<3 files), LIGHT (3-9), FULL (10+)
- Chain mode: `/start chain TICKET-A TICKET-B TICKET-C`
- NEVER create project-level `.claude/settings.json` — breaks permission inheritance
- Source: [gist.github.com/bradfeld](https://gist.github.com/bradfeld/1deb0c385d12289947ff83f145b7e4d2)

### 4. "Code SEO" for Agent Discoverability (Marmelab) — HIGH
- Synonym incorporation in comments, no duplicate filenames, avoid abbreviations
- Directory README files, Architecture Decision Records for agent consumption
- Serendipity-by-design: intentional cross-references and tagging
- Source: [marmelab.com/blog/2026/01/21/agent-experience.html](https://marmelab.com/blog/2026/01/21/agent-experience.html)

### 5. Path-Specific Conditional Rules — HIGH
- `.claude/rules/` files with `paths:` YAML frontmatter for conditional loading
- Prevents "priority saturation" where unrelated rules compete for attention
- Caveat: bug reports show path-scoped rules sometimes load globally (v2.0.64+)
- Source: [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)

### 6. System Prompt Extraction (Piebald-AI) — HIGH
- Extracted Claude Code's internal system prompts (18 builtin tools, subagent prompts)
- Updated within minutes of each release
- Prevents writing redundant/conflicting instructions
- Source: [github.com/Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts)

### 7. GitHub AGENTS.md Analysis (2,500 repos) — MODERATE
- Six core areas: commands, testing, structure, style, git workflow, boundaries
- Three-tier boundaries: always do / ask first / never do
- "One real code snippet > three paragraphs describing style"
- Source: [github.blog](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)

### 8. Negative Instructions Are Counterproductive — LOW-MODERATE
- "Don't do X" less effective than "Do Y instead" (pink elephant paradox)
- Reframe: "Don't use mock data" -> "Only use real-world data"
- Source: [eval.16x.engineer/blog](https://eval.16x.engineer/blog/the-pink-elephant-negative-instructions-llms-effectiveness-analysis)

## Cross-Cutting Themes
1. Keep Tier 1 (always-loaded) ruthlessly minimal (~500 tokens)
2. Skills/rules activation is unreliable without hooks — forced-eval pattern needed
3. CLAUDE.md rules can be automatically optimized via eval loops
4. "Never send an LLM to do a linter's job" — deterministic tools over instructions
5. Codebases that are discoverable (Code SEO) reduce instruction bloat
