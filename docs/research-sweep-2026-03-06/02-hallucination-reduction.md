# Research: Hallucination Reduction (Mar 2026)

## Top Findings

### 1. Citation-Grounded Code Comprehension — VERY HIGH NOVELTY
- Hybrid retrieval (BM25 + dense embeddings + graph expansion via import relationships)
- Mechanical citation verification: every `file:start-end` checked via interval arithmetic, no LLM in verification
- 92% citation accuracy with zero hallucinations; 14-18pp improvement over baselines
- Source: [arxiv.org/abs/2512.12117](https://arxiv.org/abs/2512.12117)

### 2. Confabulation Feedback Loop (ANTI-PATTERN) — HIGH NOVELTY
- Claude autonomously published fabricated claims to 8+ platforms over 72 hours
- MEMORY.md carried forward unverified claims between sessions, compounding hallucinations
- Persistent memory without verification gates = hallucination AMPLIFIER, not reducer
- When confronted, took 50+ turns to run a single verification command
- Source: [github.com/anthropics/claude-code/issues/27430](https://github.com/anthropics/claude-code/issues/27430)

### 3. Codified Context: Three-Tier Memory (108K-line C#) — HIGH
- Tier 1 (Hot): ~660-line constitution always loaded
- Tier 2 (Warm): 19 specialist agents (~9,300 lines total)
- Tier 3 (Cold): 34 on-demand spec docs via MCP with 5 search tools
- Trigger tables: deterministic agent routing based on file paths, not LLM choice
- Primary failure mode: STALE specifications (not missing ones)
- Source: [arxiv.org/abs/2602.20478](https://arxiv.org/abs/2602.20478)

### 4. 60% Context Window Threshold — MEDIUM-HIGH
- Past ~60% context utilization, additional context makes agent actively worse ("context rot")
- Even with 1M-token windows, this threshold holds
- MercadoLibre validated across 20,000 developers
- Source: [vibesparking.com](https://www.vibesparking.com/en/blog/ai/claude-code/2026-03-04-coding-agent-harness-context-engineering-at-scale/)

### 5. Prompt Learning / Rule Optimization (Arize AI) — HIGH
- RL-inspired loop: generate output -> evaluate -> optimize rules -> repeat
- English failure explanations beat scalar scores as optimization signals
- +6% accuracy on SWE-Bench Lite for Sonnet; GPT-4.1 closed gap to Sonnet-level via rules alone
- Source: [arize.com/blog/optimizing-coding-agent-rules](https://arize.com/blog/optimizing-coding-agent-rules-claude-md-agents-md-clinerules-cursor-rules-for-improved-accuracy/)

### 6. Chain-of-Verification (Factored Variant) — MEDIUM
- Four-step: generate baseline -> verification questions -> answer WITHOUT seeing draft -> refine
- Factored variant prevents "hallucination leakage" (model rubber-stamping own errors)
- F1 +23% on closed-book QA; reduces code errors 21-62%
- Source: [learnprompting.org/docs/advanced/self_criticism/chain_of_verification](https://learnprompting.org/docs/advanced/self_criticism/chain_of_verification)

### 7. Deterministic Tools Over Prompt Compliance — MEDIUM
- "Every deterministic check you add is one fewer thing the LLM can hallucinate about"
- Domain types (DocumentName, BlobUri) catch argument swaps at compile time
- Architectural constraint tests as blocking failures, not documentation
- Source: [jvaneyck.wordpress.com](https://jvaneyck.wordpress.com/2026/02/22/guardrails-for-agentic-coding-how-to-move-up-the-ladder-without-lowering-your-bar/)

## Cross-Cutting Principles
1. Persistent memory is a double-edged sword — needs verification gates
2. Deterministic verification beats self-verification (interval arithmetic, grep, tsc)
3. The 60% context threshold validates skills-based on-demand loading
4. Rule files can be automatically optimized (Arize's Prompt Learning)
5. Stale specifications are the primary failure mode, not missing ones
