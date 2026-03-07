# Research: Hooks & Automation (Mar 2026)

## Top Findings

### 1. PreToolUse Input Rewriting (v2.0.10+) — VERY HIGH NOVELTY
- PreToolUse hooks can silently modify tool inputs via `updatedInput` before execution
- Transparent sandboxing: auto-inject `--dry-run`, path correction, secret redaction
- Claude doesn't know its commands are being rewritten
- Source: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

### 2. Agent-Based Verification Hooks — HIGH
- `type: "agent"` hooks spawn full subagent with Read/Grep/Glob/Bash (up to 50 turns)
- Deep verification: reading files, running tests, checking codebase state
- No community examples yet of sophisticated agent hook usage
- Source: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

### 3. Async Background Test Runner — HIGH
- PostToolUse + `"async": true` runs tests in background after every file write
- Results delivered on next conversation turn via `additionalContext`
- Test-on-save for AI agents — continuous integration inside the agent loop
- Source: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

### 4. Context Handoff Across Compaction — HIGH
- PreCompact writes handoff file (last 15 user messages, last 10 code snippets)
- SessionStart(compact|clear) restores as `additionalContext`
- 85% similarity threshold for deduplication
- Configurable: `HANDOFF_MAX_USER_MESSAGES`, `HANDOFF_DEDUP_THRESHOLD`
- Source: [github.com/who96/claude-code-context-handoff](https://github.com/who96/claude-code-context-handoff)

### 5. Stop Hook with Prompt Verification — MEDIUM-HIGH
- `type: "prompt"` Stop hook asks fast model if all tasks are complete
- Critical: must check `stop_hook_active` flag to prevent infinite loops
- Source: [claude.com/blog/how-to-configure-hooks](https://claude.com/blog/how-to-configure-hooks)

### 6. Hooks in Skills/Agents Frontmatter — HIGH
- Hooks defined in YAML frontmatter, scoped to component's lifetime
- Auto-cleanup when skill/agent deactivates
- `once: true` runs only once per session
- Source: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

### 7. PostToolUse MCP Output Rewriting — HIGH
- `updatedMCPToolOutput` replaces MCP tool output before Claude sees it
- Filter sensitive data, normalize formats, inject context
- Only works for MCP tools (not built-in)
- Source: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

### 8. 17 Lifecycle Events (Current State)
- New events: `InstructionsLoaded`, `ConfigChange`, `WorktreeCreate/Remove`, `TeammateIdle`, `TaskCompleted`
- Four handler types: command, http, prompt, agent
- Exit code behavior: 0 = pass, 2 = block + feed error to model
- Source: [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

### 9. Multi-Agent Observability Dashboard — HIGH
- Real-time monitoring: hooks POST events to Bun server -> SQLite -> WebSocket -> Vue
- Swim lanes per agent, pulse charts, failure tracing
- Only real observability solution for Claude Code multi-agent workflows
- Source: [github.com/disler/claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability)

## Feature Gaps (GitHub Issues)
1. No cost/usage data in hook events (#29829)
2. No context threshold hooks (#24320)
3. No PostCompact hook (#14258)
4. No PreCommit/PostCommit git hooks (#4834)

## Cross-Cutting Themes
1. Input rewriting is the most powerful hook capability — transparent guardrails
2. Agent hooks enable deep verification (50 turns) but no community patterns yet
3. Async hooks enable CI-in-the-loop without blocking
4. Per-skill/agent hooks prevent global config pollution
5. HTTP hooks enable centralized team-wide policy enforcement
