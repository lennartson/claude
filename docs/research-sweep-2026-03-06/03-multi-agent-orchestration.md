# Research: Multi-Agent Orchestration (Mar 2026)

## Top Findings

### 1. Native Agent Teams (TeammateTool)
- Peer-to-peer messaging via inbox files, not hub-and-spoke
- Dependency-based wave execution, self-claiming tasks
- Delegate Mode (Shift+Tab): lead coordinates only, cannot write code
- Source: [code.claude.com/docs/en/agent-teams](https://code.claude.com/docs/en/agent-teams)

### 2. The 19-Agent Trap (Paddo)
- Simulating human org charts (PM->Architect->Dev->QA) is cargo-cult SDLC
- Operational roles beat SDLC personas
- AI collapses the SDLC — phase gates become friction
- Source: [paddo.dev/blog/the-19-agent-trap](https://paddo.dev/blog/the-19-agent-trap/)

### 3. Adversarial/Competitive Agents
- Cross-model debate: Claude reviews Codex's code, Codex reviews Claude's
- "Models are better adversaries than collaborators"
- Sequential investigation suffers anchoring bias; parallel adversaries don't
- Source: [github.com/alecnielsen/adversarial-review](https://github.com/alecnielsen/adversarial-review)

### 4. Cost-Aware Routing (92% savings)
- Cascade: 60-70% Haiku, 25-30% Sonnet, 3-5% Opus
- Kaxo: $6,500/yr -> $500/yr scaling from 4 to 35 agents
- Source: [kaxo.io](https://kaxo.io/insights/scaling-claude-code-sub-agent-architecture/)

### 5. Self-Improving Orchestrator (Composio)
- AI agent orchestrates other agents, learns from session outcomes
- Autonomous CI-fix loop: failure logs injected back into agent session
- Source: [github.com/ComposioHQ/agent-orchestrator](https://github.com/ComposioHQ/agent-orchestrator)

### 6. GasTown (Steve Yegge)
- 20-30 parallel Claude Code instances
- Operational roles: Mayor, Polecats, Witness, Deacon, Refinery
- $100/hr burn rate, not production-ready
- Source: [github.com/steveyegge/gastown](https://github.com/steveyegge/gastown)

### 7. 9 Parallel Review Agents (Hamy)
- Specialized: linter, code reviewer, security, quality/style, etc.
- Source: [hamy.xyz](https://hamy.xyz/blog/2026-02_code-reviews-claude-subagents)

## Key Takeaways
1. Peer-to-peer > hub-and-spoke for complex multi-agent work
2. Adversarial > collaborative for review quality
3. Cost-aware routing delivers 85-92% savings
4. Start vanilla (Boris's 10-15 sessions), add complexity only when needed
