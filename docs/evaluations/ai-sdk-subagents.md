# AI SDK Subagents

**Source**: https://x.com/nicoalbanese10/status/2019087720522588555
**Date evaluated**: 2026-02-05
**Recommendation**: ADOPT

## Summary

AI SDK now has first-class subagent support via `ToolLoopAgent`. Parent agents delegate to child agents running in isolated context windows. Child agents can consume 100k+ tokens; parent only sees a summary via `toModelOutput`. Supports streaming progress to UI while keeping model context clean.

## Scores

| Metric | Score |
|--------|-------|
| Usefulness | 5/5 |
| Effort to implement | 2/5 |
| Time to first signal | 1/5 |
| Bullshit risk | 1/5 |
| Context cost | 1/5 |

## Key APIs

- `ToolLoopAgent` — agent with tool loop, own context window
- `tool()` with `toModelOutput` — decouples UI output from model input
- `readUIMessageStream` — accumulates streaming chunks for preliminary results
- `async function*` execute — generator pattern for streaming subagent progress
- `InferAgentUIMessage<typeof agent>` — type-safe UI message inference
- `abortSignal` propagation for cancellation

## Implementation

Created `staging/skills/ai-sdk/SKILL.md` with full reference including subagent patterns.

## Docs

https://ai-sdk.dev/docs/agents/subagents
