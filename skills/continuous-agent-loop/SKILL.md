---
name: continuous-agent-loop
description: Patterns for continuous autonomous agent loops with quality gates, evals, and recovery controls.
origin: ECC
---

# Continuous Agent Loop

> **v1.8+ canonical skill.** Supersedes `autonomous-loops` while keeping
> compatibility for one release. All new loop guidance is authored here.
> See `autonomous-loops` for the extended reference implementations of each
> pattern (Sequential Pipeline, NanoClaw REPL, Infinite Agentic Loop, Continuous
> Claude PR Loop, De-Sloppify, and Ralphinho / RFC-Driven DAG).

## When to Use

- Setting up an autonomous development workflow that runs without human intervention
- Choosing and wiring up the right loop architecture for a task
- Adding quality gates, eval loops, or cost controls to any existing loop
- Debugging a loop that has stalled, churned, or cost-spiralled
- Building CI-style continuous development pipelines driven by `claude -p`

---

## Loop Selection Flow

```text
Start
  │
  ├─ Need strict CI/PR gate per iteration?
  │     └─ yes ──► continuous-pr  (Continuous Claude loop)
  │
  ├─ Need RFC / spec decomposition into a dependency DAG?
  │     └─ yes ──► rfc-dag        (Ralphinho orchestration)
  │
  ├─ Need many parallel variations of the same artefact?
  │     └─ yes ──► infinite       (Infinite Agentic Loop)
  │
  ├─ Need interactive persistence with branching / search?
  │     └─ yes ──► nanoclaw       (NanoClaw REPL)
  │
  └─ default ──────────────────► sequential  (claude -p pipeline)
```

---

## Pattern Overview

| Pattern | Complexity | Best For |
|---------|-----------|---------|
| Sequential Pipeline | Low | Daily dev steps, scripted workflows |
| NanoClaw REPL | Low | Interactive, persistent exploration |
| Infinite Agentic Loop | Medium | Parallel spec-driven generation |
| Continuous Claude PR Loop | Medium | Multi-day projects with CI gates |
| Ralphinho / RFC-Driven DAG | High | Large features, parallel merge queue |

Full implementations of each pattern live in `skills/autonomous-loops/SKILL.md`.

---

## Recommended Production Stack

Wire these four layers together for any non-trivial autonomous loop:

```
1. RFC decomposition  ──►  ralphinho-rfc-pipeline skill
2. Quality gates      ──►  plankton-code-quality skill + /quality-gate command
3. Eval loop          ──►  eval-harness skill
4. Session persistence──►  nanoclaw-repl skill  (or SHARED_TASK_NOTES.md)
```

You do not need all four. Start with the minimum needed and add layers when
a specific failure mode appears.

---

## Wiring a Basic Loop

```bash
#!/usr/bin/env bash
# loop.sh — minimal production loop with exit conditions
set -euo pipefail

MAX_RUNS="${MAX_RUNS:-10}"
MAX_COST="${MAX_COST:-5.00}"
TASK_FILE="${TASK_FILE:-LOOP_TASK.md}"
NOTES_FILE="SHARED_TASK_NOTES.md"
COMPLETION_SIGNAL="LOOP_COMPLETE"

for ((i=1; i<=MAX_RUNS; i++)); do
  echo "=== Iteration $i / $MAX_RUNS ==="

  # Implement
  OUT=$(claude -p "
    Read $TASK_FILE for the goal.
    Read $NOTES_FILE for progress context (create it if missing).
    Make the next logical increment of progress.
    At the end, update $NOTES_FILE with what was done and what remains.
    If the task is fully complete, output the signal: $COMPLETION_SIGNAL
  ")

  # Check completion signal
  if echo "$OUT" | grep -q "$COMPLETION_SIGNAL"; then
    echo "Loop complete after $i iteration(s)."
    break
  fi

  # Quality gate
  claude -p "
    Run the full build, lint, and test suite.
    Fix any failures. Do not add new features.
  "
done
```

### Key Wiring Principles

1. **One task file** — Write the goal to a Markdown file; pass its path in every prompt. Avoids prompt-length issues and keeps the goal stable across iterations.
2. **Notes file as context bridge** — Each fresh `claude -p` call has no memory. `SHARED_TASK_NOTES.md` bridges iterations: Claude reads it at start, updates it at end.
3. **Separate quality gate step** — Don't ask the implementer to also verify. A fresh context window per step produces better results.
4. **Completion signal** — Let Claude signal "done" rather than relying on a fixed run count. Three consecutive signals is a reliable threshold for real completion.

---

## Quality Gates

Quality gates are checkpoints that must pass before a loop iteration is considered
successful. They prevent bad iterations from compounding.

### Minimal Gate (build + test)

```bash
claude -p --allowedTools "Bash" "
  Run: npm run build && npm test
  If anything fails, fix it. Do not introduce new features.
  Exit non-zero if the gate still fails after your fixes.
"
```

### Standard Gate (build + lint + typecheck + test)

```bash
claude -p --allowedTools "Read,Bash,Edit" "
  Run all of:
    1. Build (exit-code must be 0)
    2. Lint (exit-code must be 0)
    3. Type check (exit-code must be 0)
    4. Tests (all must pass)
  Fix any failures. Report GATE_PASSED or GATE_FAILED at the end.
"
```

### Gate with `/quality-gate` Command

Use the ECC `/quality-gate` command for a pre-configured gate that reads
quality criteria from your project's `QUALITY_GATE.md`:

```bash
claude -p "/quality-gate"
```

---

## Eval Loop

An eval loop measures whether each iteration actually improves quality on a
defined benchmark, not just whether the build passes.

```bash
# eval-loop.sh
for ((i=1; i<=MAX_RUNS; i++)); do
  # Implement
  claude -p "Read TASK.md. Make improvements."

  # Eval
  SCORE=$(claude -p "
    Run the eval suite in tests/eval/.
    Output only a JSON line: {\"score\": <0-100>, \"details\": \"...\"}
  " | grep '^{')

  CURRENT=$(echo "$SCORE" | node -e "process.stdin.resume();let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).score))")

  echo "Iteration $i score: $CURRENT"

  if [ "$CURRENT" -ge 90 ]; then
    echo "Eval threshold reached."
    break
  fi
done
```

See `skills/eval-harness/SKILL.md` for a full eval framework including
regression detection and score tracking.

---

## Cost Controls

Unbounded loops can spend significantly. Apply at least one cost control:

| Control | Implementation |
|---------|---------------|
| `--max-runs N` | Stop after N iterations (build into your loop script) |
| `--max-cost $X` | Track cumulative cost via `scripts/hooks/cost-tracker.js`; exit when threshold hit |
| `--max-duration Xh` | Wrap loop in `timeout Xh bash loop.sh` |
| Model routing | Use `claude -p --model haiku` for cheap steps (formatting, search); Opus for reasoning |
| Completion signal | Let Claude signal done instead of running to `MAX_RUNS` |

### Model Routing in a Loop

```bash
# Fast/cheap: analysis, search, formatting
claude -p --model haiku "Find all TODO comments in src/ and list them."

# Standard: implementation
claude -p "Implement the TODO items found in todos.md."

# Thorough: architecture review, security audit
claude -p --model opus "Review all changes for security issues and race conditions."
```

---

## Session Persistence

Each `claude -p` call starts with an empty context window. Use one of these
strategies to persist state across iterations:

### Strategy 1: SHARED_TASK_NOTES.md (recommended for most loops)

```markdown
# SHARED_TASK_NOTES.md

## Goal
Add rate limiting to the /api/auth endpoints.

## Progress
- [x] Added Redis client setup (iteration 1)
- [x] Implemented token bucket in middleware (iteration 2)
- [ ] Integration tests for rate limit headers

## Next
Focus on integration tests in tests/integration/rate-limit.test.ts.
The mock Redis setup in tests/helpers/redis.ts can be reused.
```

Claude reads this file at start and overwrites the `Progress` / `Next` sections
at end. This bridges the context gap without growing prompt size unboundedly.

### Strategy 2: NanoClaw REPL

For interactive loops where you want to participate between turns, use NanoClaw.
It stores full conversation history in `~/.claude/claw/{session}.md`.

```bash
CLAW_SESSION=my-feature CLAW_SKILLS=tdd-workflow node scripts/claw.js
```

See `skills/nanoclaw-repl/SKILL.md` for full NanoClaw documentation.

### Strategy 3: Filesystem State

Write structured state to JSON files that each iteration reads:

```bash
# iteration writes: .loop-state.json
# { "iteration": 3, "lastFile": "src/auth.ts", "remainingTodos": ["rate-limit tests"] }
claude -p "Read .loop-state.json. Continue from where iteration 3 left off."
```

---

## Failure Modes and Recovery

### 1. Loop Churn (no measurable progress)

**Symptoms:** Iterations complete but the task doesn't advance. Test suite
output is the same across multiple runs.

**Recovery:**
```bash
# Freeze the loop. Run harness audit.
claude -p "/harness-audit"

# Narrow scope: pick the single failing unit.
claude -p "
  Read SHARED_TASK_NOTES.md.
  Identify the single smallest change that would move the task forward.
  Implement only that change.
  Update SHARED_TASK_NOTES.md.
"
```

### 2. Repeated Retries on the Same Root Cause

**Symptoms:** Loop retries the same failing test or build error across
multiple iterations without fixing the underlying problem.

**Recovery:**
```bash
# Capture full error context, not just the last message.
claude -p "
  Run the failing test suite. Capture the full output.
  Identify the root cause (not just the symptom).
  Write a diagnosis to DIAGNOSIS.md before attempting any fix.
"
# Then implement the fix in a separate call, reading DIAGNOSIS.md.
claude -p "Read DIAGNOSIS.md. Implement the fix described there."
```

### 3. Merge Queue Stalls (for PR-based loops)

**Symptoms:** PRs created by the loop are stuck — CI failures, merge conflicts,
or reviewer holds.

**Recovery:**
```bash
# Inspect the stuck PR.
gh pr view --json state,statusCheckRollup,mergeable

# Feed eviction context to Claude.
gh run view --log-failed > /tmp/ci-failure.txt
claude -p "
  Read /tmp/ci-failure.txt (CI failure log).
  Read the diff of the stuck PR: $(gh pr diff).
  Fix the CI failure. Do not change unrelated code.
"
```

### 4. Cost Drift (unbounded escalation)

**Symptoms:** Loop cost is growing faster than expected; iterations are
spending on retries or over-generating.

**Recovery:**
- Check `scripts/hooks/cost-tracker.js` output.
- Add `--model haiku` to cheap steps.
- Reduce scope: break the task into smaller pieces.
- Add a hard `MAX_COST` exit condition to the loop script.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| No exit condition | Loop runs to context exhaustion | Add `MAX_RUNS`, `MAX_COST`, or completion signal |
| No context bridge | Each iteration starts blind | Use `SHARED_TASK_NOTES.md` or NanoClaw |
| Retry same failure blindly | Root cause never addressed | Capture error context; diagnose before re-implementing |
| Negative instructions | Downstream quality degradation | Add a separate de-sloppify pass instead |
| Single context window for all agents | No author-bias separation | Separate reviewer from implementer |
| Parallel agents editing same file | Merge conflicts | Assign non-overlapping file ownership; use sequential landing |
| Unbounded model escalation | Cost spiral | Pin cheap steps to haiku; escalate only for reasoning |

---

## Integration with Other ECC Skills

| Need | Skill |
|------|-------|
| Full loop pattern implementations | `autonomous-loops` |
| NanoClaw REPL operation | `nanoclaw-repl` |
| RFC decomposition into DAG | `ralphinho-rfc-pipeline` |
| Quality gate configuration | `plankton-code-quality` |
| Eval framework | `eval-harness` |
| Continuous learning from loops | `continuous-learning-v2` |
| Cost-aware LLM pipeline design | `cost-aware-llm-pipeline` |

---

## References

| Project | Author |
|---------|--------|
| Ralphinho | credit: @enitrat |
| Infinite Agentic Loop | credit: @disler |
| Continuous Claude | credit: @AnandChowdhary |
| NanoClaw, ECC loop infrastructure | ECC team |
