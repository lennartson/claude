# Research: Skills & Knowledge Management (Mar 2026)

## Top Findings

### 1. SkillsBench: First Academic Benchmark — VERY HIGH NOVELTY
- 86 tasks, 11 domains, 7,308 trajectories with deterministic verifiers
- Curated skills raise pass rate by **+16.2pp** on average
- Self-generated skills **degrade** performance by -1.3pp — curation matters enormously
- Haiku 4.5 with skills (27.7%) outperforms Opus 4.5 without skills (22.0%)
- 16 of 84 tasks showed negative effects — skills can hurt when poorly matched
- Source: [arxiv.org/abs/2602.12670](https://arxiv.org/abs/2602.12670)

### 2. ToxicSkills: 36% Prompt Injection Rate — HIGH
- 1,467 malicious payloads found in studied agent skills
- Snyk + Vercel security scanning for skills.sh (LLM-based intent analysis)
- Skills have filesystem access, env vars, API keys — compromised skill = RCE vector
- Source: [snyk.io/blog/toxicskills](https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub/)

### 3. Skill-Creator 2.0: Eval/Benchmark/Improve Loop — HIGH
- Four modes: Create, Eval, Improve, Benchmark
- Improve mode: 60/40 train/test split, extended thinking for description optimization, up to 5 iterations
- A/B testing with blind comparator agents
- Description optimization = automated prompt engineering for trigger accuracy
- Source: [claude.com/blog/improving-skill-creator](https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills)

### 4. Claude-Mem: Hooks-Based Session Memory — HIGH
- Automatic capture via SessionStart/UserPromptSubmit/PostToolUse hooks
- AI compression via Claude Agent SDK, injected as `additionalContext`
- SQLite storage, queries last 10 sessions, top 50 observations
- Fire-and-forget HTTP with 2-second timeout (non-blocking)
- Source: [github.com/thedotmack/claude-mem](https://github.com/thedotmack/claude-mem)

### 5. Mengram: Multi-Type Memory with Knowledge Graphs — HIGH
- Semantic + episodic + procedural memory types
- Auto-extracts facts, deduplicates, handles contradictions, decays stale items
- Search combines vector + BM25 + graph expansion + LLM re-ranking
- 29 MCP tools, Apache 2.0 license
- Source: [mengram.io](https://mengram.io/)

### 6. skills.sh Registry (Vercel) — HIGH
- Open directory with CLI installer: `npx skills add [repo]`
- Cross-platform: Claude Code, Codex, Cursor, Copilot, Goose, etc.
- Top skill had 20,000+ installs within 6 hours of launch
- Growing at 147 new skills/day
- Source: [skills.sh](https://skills.sh/docs)

### 7. Workflow vs. Capability Uplift Taxonomy — MODERATE
- Capability Uplift: fill model gaps (PDF processing, PPTX), have retirement dates
- Workflow/Preference: encode team process, more durable but need fidelity checks
- Source: [geeky-gadgets.com/anthropic-skill-creator](https://www.geeky-gadgets.com/anthropic-skill-creator/)

### 8. 20-30 Skills Sweet Spot — LOW
- More skills = more metadata tokens, conflicting instructions, false triggers
- Source: [geeky-gadgets.com](https://www.geeky-gadgets.com/claude-code-skills-best-practices/)

## Ecosystem Gaps
1. No formal skill-to-skill dependency system
2. No quality metrics beyond pass rate (token efficiency, hallucination rate)
3. No skill version compatibility matrix ("requires Opus 4.5+")
4. No skill conflict detection at install time
5. No knowledge graph skills despite available infrastructure

## Cross-Cutting Themes
1. Curated > self-generated — invest in quality over quantity
2. Skills can make small models match large ones (cost optimization lever)
3. Security scanning is essential — 36% of community skills contain prompt injection
4. Composition is emergent from LLM reasoning, not declared dependencies
5. SKILL.md is now a cross-platform standard (30+ agents)
