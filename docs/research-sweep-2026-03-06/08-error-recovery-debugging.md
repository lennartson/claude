# Research: Error Recovery & Debugging (Mar 2026)

## Top Findings

### 1. IBM STRATUS: Formal Undo Operators — VERY HIGH NOVELTY
- Every action paired with a corresponding inverse operator
- Simulation before execution catches errors pre-run
- Destructive actions rejected; agent must find reversible alternative
- Constraining to reversible actions IMPROVES exploration quality
- Source: [research.ibm.com/blog/undo-agent-for-cloud](https://research.ibm.com/blog/undo-agent-for-cloud)

### 2. AgentDebug: Trajectory Root-Cause Attribution — VERY HIGH
- Identifies the EARLIEST critical error in a failing trajectory
- Error taxonomy: memory, reflection, planning, action, system-level
- 24% higher accuracy vs baselines; correcting single root cause flips failing runs
- Source: [arxiv.org/abs/2509.25370](https://arxiv.org/abs/2509.25370)

### 3. Systematic Debugging Protocol (4-Phase) — HIGH
- NO FIXES WITHOUT ROOT CAUSE FIRST
- Observe -> trace call chain -> follow invalid data backward -> find trigger
- Claims ~95% first-time fix rate vs ~40% ad-hoc
- Source: [github.com/ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase)

### 4. Loop Detection with Archetype Classification — MEDIUM-HIGH
- Three stuck types: Repeater (same action), Wanderer (busy not progressing), Looper (A-B oscillation)
- Hash-based near-duplicate detection (normalize whitespace, ignore timestamps)
- Dual threshold: nudge at warning, force at hard limit
- Source: [gantz.ai/blog/post/agent-loops](https://gantz.ai/blog/post/agent-loops/)

### 5. Independent Verification with Different Model — MEDIUM-HIGH
- Different LLM reviews with "no investment in defending original output"
- Breaks self-confirmation bias and shared blind spots
- Source: [dev.to/singhdevhub](https://dev.to/singhdevhub/how-we-prevent-ai-agents-drift-code-slop-generation-2eb7)

### 6. Multi-Agent Failure Taxonomy (14 modes) — HIGH
- Four archetypes: premature action, over-helpfulness (fabricating data), context pollution, fragile under load
- Inter-agent misalignment is #1 production failure mode
- Source: [arxiv.org/abs/2503.13657](https://arxiv.org/abs/2503.13657)

### 7. SWE-Bench Process Analysis
- Most prevalent errors: ModuleNotFoundError, TypeError
- Most CHALLENGING: OSError, database errors (disproportionate debugging effort)
- Source: [arxiv.org/abs/2503.12374](https://arxiv.org/abs/2503.12374)

## Cross-Cutting Principles
1. Progress lives in files/git, not agent memory
2. External verification beats self-assessment
3. Constrain to reversible actions to enable exploration
4. Fix at root cause, not symptom location
5. Classify errors before choosing recovery strategy
