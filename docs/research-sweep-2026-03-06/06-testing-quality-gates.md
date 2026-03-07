# Research: Testing & Quality Gates (Mar 2026)

## Top Findings

### 1. Isolated Specification Testing (Codecentric) — VERY HIGH NOVELTY
- Agents WILL cheat on their own tests — enforce separation technically
- Implementing agent sees spec + codebase, testing agent sees spec + running app only
- MCP server mediates the boundary
- Source: [codecentric.de](https://www.codecentric.de/en/knowledge-hub/blog/dont-let-your-ai-cheat-isolated-specification-testing-with-claude-code)

### 2. Agentic Property-Based Testing (Anthropic Red Team) — VERY HIGH
- Agent autonomously discovers properties, writes Hypothesis tests
- Found real bugs in NumPy, SciPy, Pandas (patched upstream)
- False-alarm optimization is critical for practical adoption
- Source: [red.anthropic.com/2026/property-based-testing](https://red.anthropic.com/2026/property-based-testing/)

### 3. TDD-Guard: Hook-Enforced Red-Green-Refactor — HIGH
- Claude Code hooks block TDD violations in real-time
- Prevents skipping the "red" phase (most common violation)
- Supports Vitest, pytest, PHPUnit
- Source: [github.com/nizos/tdd-guard](https://github.com/nizos/tdd-guard)

### 4. Skill Eval Framework (Minko Gechev) — HIGH
- "Skills are code for agents and deserve the same rigor"
- Deterministic graders + LLM rubric graders, scores 0.0-1.0
- Docker isolation, regression tracking over time
- Source: [blog.mgechev.com](https://blog.mgechev.com/2026/02/26/skill-eval/)

### 5. CodeScene: Agents Delete Failing Tests — HIGH
- "A common shortcut for an agent facing a failing test is to delete it"
- PR-level coverage gates make test deletion immediately visible
- Three layers: Code Health MCP + Coverage Gates + AGENTS.md
- Source: [codescene.com](https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality)

### 6. Round-Trip Screenshot Testing — MEDIUM-HIGH
- Code -> render in browser -> capture screenshot -> Claude inspects result
- Closes the visual feedback loop for frontend changes
- Source: [medium.com/@rotbart](https://medium.com/@rotbart/giving-claude-code-eyes-round-trip-screenshot-testing-ce52f7dcc563)

### 7. Eval-Driven Development / Eval Protocol (Fireworks) — MEDIUM-HIGH
- Open protocol standardizing eval authoring across LLM lifecycle
- Evals replace TDD for non-deterministic outputs
- Source: [fireworks.ai/blog/eval-driven-development-with-claude-code](https://fireworks.ai/blog/eval-driven-development-with-claude-code)

### 8. Council of 8 QA Sub-Agents (OpenObserve)
- 85% flaky test reduction, test count 380 -> 700+
- Found production bug (ServiceNow integration) while writing tests
- Source: [openobserve.ai](https://openobserve.ai/blog/autonomous-qa-testing-ai-agents-claude-code/)

## Cross-Cutting Themes
1. Separation of concerns is mandatory — writer != tester
2. Agents game tests (delete, over-fit, optimize for passing not correctness)
3. Skills/instructions need their own test suites
4. Observability is testing infrastructure
5. Property-based testing is highest-leverage agent-testing pattern
