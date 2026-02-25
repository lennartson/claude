# Evaluation: Opus/Haiku Web Scraper Orchestration Pattern

**Source:** [@0xSero tweet](https://x.com/0xSero/status/2017907852120060389) (Feb 1, 2026)
**Date evaluated:** Feb 2, 2026
**Recommendation:** MICRO-TEST

---

## 1. Summary of Claim

- Use Opus as orchestrator to plan scraping strategy and coordinate work
- Delegate actual scraping to Haiku subagents (cheap, fast)
- Haiku agents manage EXA (URL discovery) + Firecrawl (content extraction)
- Output structured JSON for downstream processing
- Chrome browser as fallback for targets that resist programmatic scraping

## 2. Technical Reality Check

**Category: Workflow/Orchestration Pattern**

Not a tool or product. A usage pattern combining existing Claude Code capabilities:

| Component | Implementation |
|-----------|---------------|
| Opus orchestrator | Default main model in Claude Code |
| Haiku subagents | Task tool with `model: "haiku"` |
| EXA | `exa-js` v2.0.0 SDK for search/discovery |
| Firecrawl | `@mendable/firecrawl-js` v4.11.1 SDK for extraction |
| Chrome fallback | Chrome MCP (already installed) |

Architecture:
```
Opus (orchestrator)
  ├── Plans scraping strategy from natural language goal
  ├── Uses EXA to build target list
  ├── Chunks targets into batches
  └── Spawns Haiku subagents (Task tool, model: "haiku")
        ├── Haiku #1 → EXA refine + Firecrawl scrape → JSON
        ├── Haiku #2 → EXA refine + Firecrawl scrape → JSON
        └── Haiku #N → ...
  Opus assembles all JSON → final output
```

## 3. Hype / Credibility Check

| Check | Assessment |
|-------|-----------|
| **Evidence** | No repo or code — recipe tweet with screenshot |
| **Specificity** | Concrete steps mapping to real Claude Code features |
| **Terminology** | Correct usage of subagents, model routing, API concepts |
| **Cherry-picking** | Likely best-case scenario |
| **Overclaiming** | "Best web-scraper" is hyperbolic |
| **Engineering detail** | Missing: error handling, rate limits, cost tracking |

**Red flags:** No implementation provided. But pattern maps directly to Claude Code Task tool + model parameter, which is well-documented.

## 4. Claude Code Fit Assessment

### Context Window Impact
- Zero. This is a prompting/workflow pattern, not a CLAUDE.md addition.

### Latency Impact
- None to main session. Subagents run independently.

### Security Considerations
- Requires EXA and Firecrawl API keys (already have both)
- Scraping targets are user-specified, not arbitrary

### Compatibility
- All components already available in current setup
- EXA API key: existing
- Firecrawl API key: existing
- Chrome MCP: installed
- Task tool with model routing: available in Claude Code v2.1.29

## 5. What This Replaces

| Replaces | With |
|----------|------|
| Sequential EXA → Firecrawl in Opus context | Opus orchestrates, Haiku executes in parallel |
| Manual scraping coordination | Automated fan-out to subagents |
| High per-target cost (Opus tokens) | Low per-target cost (Haiku tokens) |

Genuine improvement: cheaper per-target cost, parallel execution, keeps Opus context clean.

## 6. Scores (1-5)

| Metric | Score | Rationale |
|--------|-------|-----------|
| **Usefulness** | 4/5 | Directly relevant — heavy scraping is existing workflow |
| **Effort to implement** | 2/5 | Low — thin wrappers + a command prompt |
| **Time to first signal** | 2/5 | Fast — try on next scraping task |
| **Bullshit risk** | 2/5 | Pattern is sound, just oversold in tweet |
| **Context cost** | 1/5 | Zero CLAUDE.md additions |

## 7. Recommendation: MICRO-TEST

Building as a Claude Code `/scrape` command in a dedicated `scrape-agent` project at `/Users/sethkravitz/Code Projects/scrape-agent/`.

## 8. Implementation

### Project: scrape-agent

- TypeScript wrappers around EXA and Firecrawl SDKs
- CLI interface so Haiku subagents can call them via `npx tsx`
- `/scrape` Claude Code command that teaches Opus the orchestration pattern
- Output to `output/` directory as JSON

### Key files
- `src/exa.ts` — EXA search/discovery wrapper
- `src/firecrawl.ts` — Firecrawl scrape/extract wrapper
- `src/types.ts` — Shared type definitions
- `.claude/commands/scrape.md` — Orchestration command

## 9. Caveats

- **Rate limiting**: Multiple Haiku agents hitting APIs simultaneously could trigger limits
- **Concurrency**: Unknown practical limit on concurrent Task tool subagents
- **Chrome MCP concurrency**: May not handle multiple subagents accessing browser simultaneously
- **Cost at scale**: Need to measure actual Haiku + API costs vs sequential Opus approach
- **Error handling**: Subagent failures need graceful degradation (retry, skip, report)
