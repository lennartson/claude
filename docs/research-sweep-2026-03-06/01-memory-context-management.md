# Research: Memory & Context Management (Mar 2026)

## Genuinely Novel Patterns

### 1. Observational Memory (Mastra)
- **Source**: [mastra.ai/blog/observational-memory](https://mastra.ai/blog/observational-memory)
- Two background agents (Observer + Reflector) watch conversations and compress into dense observations
- Observer compresses at 30K tokens, Reflector restructures at 40K tokens
- Append-only observations are prompt-cacheable (unlike RAG which breaks caching)
- 94.87% on LongMemEval benchmark, 10x cost reduction vs RAG
- Compression: 3-6x for text, 5-40x for tool-heavy workloads

### 2. Sidecar Memory Agent (Letta Subconscious)
- **Source**: [github.com/letta-ai/claude-subconscious](https://github.com/letta-ai/claude-subconscious)
- Separate Letta agent observes Claude Code transcripts asynchronously
- Forms memories independently, "whispers" back relevant context
- Multiple Claude Code sessions share the same Letta agent
- Decouples memory formation from coding work

### 3. Brain-Inspired Decay + Consolidation (claude-engram)
- **Source**: [github.com/mlapeter/claude-engram](https://github.com/mlapeter/claude-engram)
- Salience scoring on 4 dimensions: novelty, relevance, emotional weight, prediction error
- Memories decay unless reinforced by access
- "Sleep consolidation" every 3 days merges redundant memories, extracts patterns, prunes dead ones
- Only system found that treats forgetting as a feature

### 4. Autonomous Skill Extraction with Quality Gates (Claudeception)
- **Source**: [github.com/blader/Claudeception](https://github.com/blader/Claudeception)
- Hook injects reminder on every prompt to evaluate if task produced extractable knowledge
- Strict criteria: must require actual discovery (not just docs), must help future tasks, must have clear triggers, must be verified
- Prevents skill bloat through selective extraction

### 5. Progressive Disclosure Retrieval (claude-mem)
- **Source**: [github.com/thedotmack/claude-mem](https://github.com/thedotmack/claude-mem)
- Tool outputs (1K-10K tokens) compressed to ~500 tokens via Agent SDK
- Tagged by type: decision, bugfix, feature, refactor, discovery, change
- Layered retrieval with token cost visibility
- Local SQLite with full-text search

### 6. Five-Layer Memory Protection (OpenClaw)
- **Source**: [github.com/gavdalf/openclaw-memory](https://github.com/gavdalf/openclaw-memory)
- Observer Cron (15 min), Reactive Watcher (inotify), PreCompact Hook, Session Startup, Session Recovery
- All plain Markdown on local filesystem
- ~$0.10-0.20/month using Gemini 2.5 Flash via OpenRouter

### 7. Markdown-as-Truth with Disposable Vector Index (memsearch)
- **Source**: [github.com/zilliztech/memsearch](https://github.com/zilliztech/memsearch)
- Markdown files are canonical, vector index is derived/rebuildable
- Hybrid search (dense vector + BM25) with RRF reranking
- SHA-256 content hashing prevents re-embedding unchanged content

## Standard Practice (already have or widely known)

- CLAUDE.md as persistent instructions
- Modular rules in `.claude/rules/`
- PreCompact hooks for session state preservation
- Manual `/learn` commands
- Skills with YAML frontmatter
- Tiered hot/warm/cold context (our skills/rules/references structure)

## Additional References

- [Codified Context Paper (arXiv)](https://arxiv.org/html/2602.20478v1) — 3-tier memory, 108K-line C# system in 70 days
- [Claude Diary (Anthropic staff pattern)](https://github.com/rlancemartin/claude-diary) — Two-phase record+reflect
- [Claude-Meta](https://github.com/aviadr1/claude-meta) — Meta-rules for self-regulating learning
- [Continuous-Claude-v3](https://github.com/parcadei/Continuous-Claude-v3) — 30 lifecycle hooks with YAML handoffs
- [Mother CLAUDE](https://dev.to/dorothyjb/mother-claude-automating-everything-with-hooks-12jh) — Automated handoffs via hooks
- [A-Mem Paper (arXiv)](https://arxiv.org/abs/2502.12110) — Zettelkasten-inspired memory linking
- [Context Buffer: autocompact at ~167K tokens, 33K buffer](https://claudefa.st/blog/guide/mechanics/context-buffer-management)
