# Research Notes

Links, articles, and analysis notes for Claude Code optimization.

---

## Core Resources

### Official Documentation
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Anthropic Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

### Essential Guides
- [The Shorthand Guide to Everything Claude Code](https://x.com/affaanmustafa/status/2012378465664745795) - Hackathon winner's overview
- [The Longform Guide to Everything Claude Code](https://x.com/affaanmustafa/status/2014040193557471352) - Detailed follow-up
- [Builder.io CLAUDE.md Guide](https://www.builder.io/blog/claude-md-guide) - File placement and structure
- [Claude Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/) - Skills architecture explained

---

## Self-Improvement

### The Magic Prompt
> "Reflect on this mistake. Abstract and generalize the learning. Write it to CLAUDE.md."

### Resources
- [Self-Improving AI Article](https://dev.to/aviad_rozenhek_cba37e0660/self-improving-ai-one-prompt-that-makes-claude-learn-from-every-mistake-16ek)
- [claude-skill-self-improvement](https://github.com/bokan/claude-skill-self-improvement) - Automated pattern extraction

### Key Insight
Write learnings to dated files (`~/.claude/learned/2026-01-21.md`) not directly to CLAUDE.md. Consolidate weekly to prevent bloat.

---

## Community Resources

### Curated Collections
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) - Community resource catalog
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) - Hackathon winner configs (in reference/)

### Skills & Plugins
- [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) - React best practices, web design guidelines
- [Trail of Bits Security Skills](https://github.com/trailofbits/skills) - Professional security auditing
- [Context Engineering Kit](https://github.com/NeoLabHQ/context-engineering-kit) - Minimal token footprint

### Hooks
- [TDD Guard](https://github.com/nizos/tdd-guard) - Real-time TDD enforcement
- [TypeScript Quality Hooks](https://github.com/bartolli/claude-code-typescript-hooks) - Compilation + formatting
- [CC Notify](https://github.com/dazuiba/CCNotify) - Desktop notifications

### Workflows
- [RIPER Workflow](https://github.com/tony/claude-code-riper-5) - Research → Innovate → Plan → Execute → Review
- [Claude CodePro](https://github.com/maxritter/claude-codepro) - Spec-driven + TDD
- [AB Method](https://github.com/ayoubaben18/ab-method) - Large problems → focused missions

### Orchestrators
- [Claude Squad](https://github.com/smtg-ai/claude-squad) - Multiple agents in git worktrees
- [Claude Swarm](https://github.com/parruda/claude-swarm) - Agent swarm coordination
- [Happy Coder](https://github.com/slopus/happy) - Control multiple Claudes from phone

---

## Patterns & Best Practices

### Claude Bootstrap Patterns
From [alinaqi/claude-bootstrap](https://github.com/alinaqi/claude-bootstrap):

**Hard Limits**:
- 20 lines per function maximum
- 3 parameters maximum per function
- 2-level nesting depth maximum
- 200 lines per file maximum
- 80% test coverage minimum

**Commit Hygiene**:
| State | Files | Lines | Action |
|-------|-------|-------|--------|
| Green | ≤5 | ≤200 | Optimal |
| Yellow | 6-10 | 201-400 | Commit soon |
| Red | >10 | >400 | Commit NOW |

### Claude Code Showcase
From [ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase):

**Hook Response Format**:
```json
{
  "block": true,
  "message": "reason",
  "feedback": "info",
  "suppressOutput": true,
  "continue": false
}
```

**Exit Codes**:
- 0: Success
- 2: Blocking error (PreToolUse only)

---

## Context Management

### Quality Degradation Map
| Context % | Quality | Recommendation |
|-----------|---------|----------------|
| 0-40% | Excellent | Optimal zone |
| 40-60% | Good | Still effective |
| 60-80% | Degrading | Start being selective |
| 80-95% | Poor | Manual compaction needed |
| 95-100% | Critical | "The last 20% is poison" |

### MCP Guidelines
- Keep under 10 MCPs enabled per project
- Max ~80 active tools
- Use `disabledMcpServers` in project config

---

## Verified Patterns (From Mistakes)

| Mistake | Lesson |
|---------|--------|
| Converted tests to bun:test | ALWAYS use VITEST |
| Used --no-verify | NEVER skip pre-commit hooks |
| AI SDK v5 patterns | We use AI SDK v6 |
| Added newlines to env vars | Use `echo -n` |
| .js extensions in imports | Turbopack hates them |
| Blamed pre-existing errors | Fix ALL errors you see |
| Auto-refunded purchases | Platform never auto-refunds |
| Skipped DATABASE_URL at build | Required at build time |
| Singleton imports in serverless | Use lazy initialization |
| Direct drizzle-orm imports | Import from @/core/db |
| npm in Vercel | Use bun |
| Assumed shared root .env | Each app needs own .env |

---

## To Investigate

- [ ] Trail of Bits security skills implementation
- [ ] Vercel react-best-practices installation
- [ ] TDD Guard hook integration
- [ ] Strategic compact patterns
- [ ] Claude SDK agent patterns

---

## Evaluated Resources

Resources evaluated using the [EVALUATE.md](EVALUATE.md) framework:

| Date | Resource | Category | Recommendation | Notes |
|------|----------|----------|----------------|-------|
| 2026-01-23 | [Ralph / AIHero Guide](https://www.aihero.dev/getting-started-with-ralph) | Methodology/Workflow | **ALREADY ADOPTED** | Autonomous loop methodology. Already have ralph-wiggum + ralph-loop plugins. frankbria CLI offers +1.4% improvement via safeguards - not worth complexity given your interactive workflow preference (40% compatibility). Use current setup for 10-20% of tasks: greenfield, test-verifiable, clear completion criteria. See [evaluation](docs/evaluations/ralph-aihero-guide.md). |
| 2026-01-22 | [MCP Tool Search](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool) | Built-in Feature | **ALREADY ACTIVE** | Announced Jan 14, 2026. Reduces MCP context pollution by 85% (50-60K→6-9K tokens). Auto-enables when tools exceed 10K tokens. No configuration needed - already working in Claude Code. See [evaluation](docs/evaluations/mcp-tool-search.md). |
| 2026-01-22 | [browser-use v0.11.4](https://github.com/browser-use/browser-use) | Skill/External Tool | **REMOVED** | Caused severe Chrome disruption (logged out accounts, removed extensions). Completely uninstalled. Use e2e-runner/Playwright for all browser automation. |
| 2026-01-22 | [Supabase Postgres Best Practices](https://github.com/supabase/agent-skills/tree/main/skills/postgres-best-practices) | Skill | **PARK** | High-quality Postgres optimization rules (~11k tokens). 28+ rules across 8 categories with quantified impact metrics. Upgrade to MICRO-TEST when DB work intensifies. |
| 2026-01-28 | [skills.sh / AI SDK Skill](https://skills.sh/) | Skill Registry | **ADOPTED** | Installed `vercel/ai` skill globally via `npx skills add vercel/ai -y -g`. Official Vercel skill provides authoritative AI SDK patterns, forces doc verification over training data, includes common errors reference. Auto-triggers on AI SDK keywords. Located at `~/.agents/skills/ai-sdk/` (symlinked to `~/.claude/skills/`). |
| 2026-01-28 | [Async Hooks (`async: true`)](https://x.com/bcherny/status/2015524460481388760) | Infrastructure | **ADOPTED** | Added `async: true` to non-blocking hooks: Prettier formatting, console.log warnings, memory persistence (PreCompact, Stop/session-end). Keeps --no-verify blocker, strategic-compact, and TypeScript check synchronous. Zero context cost, reduces execution blocking. |
| 2026-01-28 | [last30days-skill](https://github.com/mvanhorn/last30days-skill) | Skill | **PARK** | Research aggregator for Reddit/X from last 30 days. Requires TWO additional API keys (OpenAI + xAI), adds ongoing costs, overlaps with existing `/grok` and WebSearch. Nice-to-have but friction too high. Revisit if need frequent "last 30 days" research or if implementation simplifies. |
| 2026-01-28 | [Agentation](https://github.com/benjitaylor/agentation) | Dev Tool | **ADOPTED** | Visual annotation tool for React apps. Click UI elements → get CSS selectors + class names → paste into Claude Code instead of screenshots. Solves the screenshot-to-code gap. Install per-project: `npm install agentation -D`. React 18+ only. PolyForm Shield license (fine for internal use). Not a Claude Code config - it's a project-level dev dependency. |
| 2026-01-28 | [DummyJSON](https://github.com/Ovi/DummyJSON) | Dev Tool | **ADOPTED** | Free REST API for mock data during prototyping (products, users, posts, carts, images). Zero config, instant data. Added to global CLAUDE.md so Claude reaches for it instead of hand-writing fake arrays. MIT license, 2.7k stars. |
| 2026-01-28 | [Firecrawl CLI Skill](https://docs.firecrawl.dev/sdks/cli) | Skill/External API | **PARK** | CLI + skill for JS-rendered web fetching via Firecrawl API. Cleaner than WebFetch for JS-heavy pages, supports site crawling. But: paid API credits, external dependency, and existing WebFetch + Chrome MCP cover most cases. Revisit if WebFetch regularly fails or if bulk docs crawling needed. |
| 2026-01-31 | [AGENTS.md Outperforms Skills](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) | Context Management / Pattern | **ADOPTED (pattern)** | Vercel evals: compressed framework docs in passive context (100%) beats skills (79%) for APIs absent from training data. Extracted pattern: add "Framework Docs Index" section to project CLAUDE.md for any framework with post-training-cutoff APIs. Added to project template. Next.js specific: `npx @next/codemod@canary agents-md`. |
| 2026-02-02 | [Vercel Sandbox GA](https://x.com/rauchg/status/2017423825152184772) | Infrastructure / Compute | **PARK** | Firecracker microVMs for AI agent code execution. Sub-second startup, snapshotting, open-source SDK. Legit product but solves agent-platform problems, not config optimization. No fit for current VPS-based workflow. Revisit if building an agent product that executes untrusted code. |
| 2026-02-02 | [Opus/Haiku Web Scraper Pattern](https://x.com/0xSero/status/2017907852120060389) | Workflow/Orchestration | **MICRO-TEST** | Opus orchestrates → Haiku subagents manage EXA (discovery) + Firecrawl (extraction) → JSON output. All components already available. Pattern adds parallelization + cost savings via Haiku delegation. Building as `/scrape` command in scrape-agent project. |
| 2026-02-05 | [Agent Teams](https://code.claude.com/docs/en/agent-teams) | Built-in Feature / Orchestration | **PARK** | Official Anthropic feature: coordinate multiple Claude Code instances as a team with shared task list and inter-agent messaging. Experimental, disabled by default. Genuine new capability (teammates message each other, not just report back). Parked because: experimental with 8 known limitations, VS Code split-pane unsupported, no session resumption, high token cost. Subagents cover 80% of parallelization needs. Revisit when feature exits experimental. |
| 2026-02-05 | [AI SDK Subagents](https://x.com/nicoalbanese10/status/2019087720522588555) | SDK Feature / Agent Architecture | **ADOPT** | First-class subagent support in AI SDK via `ToolLoopAgent`. Key API: `toModelOutput` decouples UI output from parent model input — subagent burns 100k tokens, parent sees only summary. Supports streaming via async generators + `readUIMessageStream`. Direct upgrade to existing agent harness pattern. Created `staging/skills/ai-sdk/SKILL.md` with full reference. See [evaluation](docs/evaluations/ai-sdk-subagents.md). |
| 2026-02-25 | [Built-in Git Worktree Support](https://x.com/bcherny/status/2025007393290272904) | Infrastructure / Agent Config | **ADOPT** | Claude Code v2.1.50 ships built-in git worktree isolation. `claude --worktree` for parallel sessions, `isolation: worktree` in agent frontmatter for subagents. Added to all 6 write-heavy agents (refactor-cleaner, build-error-resolver, doc-updater, e2e-runner, security-reviewer, tdd-guide). Read-only agents excluded. Zero context cost. See [evaluation](docs/evaluations/worktree-isolation.md). |
| 2026-02-25 | [Autonomous Dogfooding Skill](https://x.com/ctatedev/status/2026357704617267314) | Skill / Browser Automation | **MICRO-TEST** | agent-browser skill that autonomously explores web apps, clicks buttons, fills forms, checks console, captures repro videos/screenshots, outputs structured severity report. 6-phase workflow. Unlike browser-use (which caused Chrome disruption), agent-browser downloads its own isolated Chromium — structurally cannot touch your Chrome. Installed: `brew install agent-browser` + `npx skills add ... --skill dogfood -g`. Ready for first test on a live app. |
| 2026-02-27 | [AI Code Security Benchmark](https://x.com/princechaddha/status/2027243058983821443) | Security Research / Product Marketing | **PARK** | ProjectDiscovery built 3 apps with Claude Code/Codex/Cursor, found 70 exploitable vulns. Key signal: AI-generated code's primary vulnerability profile is business logic flaws (auth bypass, privilege escalation, workflow abuse), not classic injection. Neo (their product) found 62/70 vs Claude Code 40/70 vs Snyk 0/70 — but it's a vendor benchmark. Research paper with prompts/source code "coming soon." Revisit when paper drops for concrete patterns to add to security-reviewer agent. |

### Evaluation Log

When evaluating a new resource, add:
1. A row to the table above with summary
2. Full evaluation to `docs/evaluations/<resource-name>.md` if MICRO-TEST or ADOPT

### Recommendation Key

| Decision | Meaning |
|----------|---------|
| **IGNORE** | Not useful, too much hype, doesn't fit |
| **PARK** | Interesting but not now |
| **MICRO-TEST** | ≤2 hours to try in staging/ |
| **ADOPT** | Add to staging/, test, deploy |

---

## Notes

*Add your own notes and findings here as you experiment.*
