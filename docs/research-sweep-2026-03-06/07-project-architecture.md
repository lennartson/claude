# Research: Project Architecture for AI (Mar 2026)

## Top Findings

### 1. Linters as Agent Teachers (Factory.ai + OpenAI)
- Error messages double as remediation instructions — linters teach agents while enforcing rules
- Categories: grep-ability, glob-ability, architectural boundaries
- Source: [factory.ai/news/using-linters-to-direct-agents](https://factory.ai/news/using-linters-to-direct-agents)

### 2. ETH Zurich Warning: More Context Can Hurt
- LLM-generated context files REDUCE success by 2-3% and increase cost 20%+
- Developer-written files improve success ~4% but add 14-22% token cost
- Lean, high-signal > comprehensive
- Source: [arxiv.org/abs/2602.11988](https://arxiv.org/abs/2602.11988)

### 3. Nx Project Graph as Agent Navigation
- Structured topology queries replace file exploration
- Blast radius analysis: "if lib-api changes, what's affected?"
- Source: [nx.dev/blog/nx-ai-agent-skills](https://nx.dev/blog/nx-ai-agent-skills)

### 4. Mercari's Four-Layer Monorepo Model
- @core -> @domain -> @feature -> @app
- eslint-plugin-boundaries enforces dependency direction
- Per-domain AGENTS.md files
- Source: [engineering.mercari.com](https://engineering.mercari.com/en/blog/entry/20251030-taming-agents-in-the-mercari-web-monorepo/)

### 5. Spec-Driven Development (SDD)
- Spec as primary artifact, code as derivative
- Tools: AWS Kiro, GitHub Spec Kit, Tessl, cc-sdd
- Source: [martinfowler.com](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)

### 6. AGENTS.md Standard (60K+ repos)
- Six core areas: commands, testing, structure, style, git workflow, boundaries
- One real code snippet > three paragraphs describing style
- Source: [agents.md](https://agents.md/) | [GitHub analysis of 2,500 repos](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)

## Cross-Cutting Themes
1. Constraints enable speed (more restrictions = faster, more reliable agent output)
2. Monorepos winning for agent workflows
3. Documentation is load-bearing infrastructure
4. Lean hot context + on-demand cold retrieval > comprehensive docs
