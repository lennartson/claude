---
name: nanoclaw-repl
description: Operate and extend NanoClaw v2, ECC's zero-dependency session-aware REPL built on claude -p.
origin: ECC
---

# NanoClaw REPL

Use this skill when running, scripting, or extending `scripts/claw.js` — ECC's
built-in persistent agent REPL. NanoClaw wraps `claude -p` with session
persistence, skill context loading, and a suite of `/commands` for managing
conversation history without any external runtime dependencies.

## When to Use

- Interactive exploration that needs to persist across restarts
- Building a multi-turn conversation with accumulated context (unlike a stateless `claude -p` call)
- Loading specific ECC skills as active context for a session
- Branching a conversation before a risky experiment
- Searching previous sessions for prior art or decisions
- Exporting a session for sharing, archival, or handoff

---

## Starting NanoClaw

```bash
# Default session ("default")
node scripts/claw.js

# Named session
CLAW_SESSION=my-feature node scripts/claw.js

# Named session with skills pre-loaded into context
CLAW_SESSION=auth-refactor CLAW_SKILLS=tdd-workflow,security-review node scripts/claw.js

# Different model
CLAW_MODEL=opus CLAW_SESSION=design node scripts/claw.js
```

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAW_SESSION` | `default` | Session name (alphanumeric + hyphens) |
| `CLAW_SKILLS` | _(none)_ | Comma-separated skill names to load as system context |
| `CLAW_MODEL` | `sonnet` | Model shorthand passed to `claude --model` |

Session files are stored at `~/.claude/claw/{session-name}.md`.

---

## REPL Commands

Once inside NanoClaw, use these slash commands:

| Command | Description |
|---------|-------------|
| `/help` | Show all available commands |
| `/clear` | Erase current session history (destructive — cannot be undone) |
| `/history` | Print the full conversation history to stdout |
| `/sessions` | List all saved sessions |
| `/model [name]` | Show current model, or switch to `name` (e.g., `/model opus`) |
| `/load <skill-name>` | Load a skill's SKILL.md into the active system context |
| `/branch <session-name>` | Copy current session into a new named session |
| `/search <query>` | Search across all sessions for a keyword or phrase |
| `/compact` | Keep the most recent 20 turns; summarize older context |
| `/export <format> [path]` | Export session as `md`, `json`, or `txt` |
| `/metrics` | Show turn count, character count, and token estimate |
| `exit` | Quit NanoClaw |

---

## How It Works

### Architecture

```
~/.claude/claw/
  default.md          ← default session
  auth-refactor.md    ← named session
  auth-refactor.export.json

Each session file (Markdown-as-database):
  ### [2025-03-19T10:00:00.000Z] User
  <user message>
  ---
  ### [2025-03-19T10:00:01.500Z] Assistant
  <claude response>
  ---
```

### Per-Turn Flow

1. User types a message (or a `/command`).
2. NanoClaw builds a full prompt:
   - `=== SYSTEM CONTEXT ===` — loaded skills (if any)
   - `=== CONVERSATION HISTORY ===` — full session file contents
   - `=== USER MESSAGE ===` — the new message
3. `claude -p <full-prompt>` is called synchronously via `spawnSync`.
4. The response is printed to stdout and appended to the session file.
5. Loop repeats.

Because each turn sends the full history, NanoClaw provides **stateful
conversation** on top of the stateless `claude -p` primitive.

---

## Session Management

### Branching (Safe Experimentation)

Branch before any risky or exploratory change so you can return to the
stable state:

```
/branch auth-refactor-experiment
```

This copies the current session to `auth-refactor-experiment.md`. Switch to
the branch by restarting with `CLAW_SESSION=auth-refactor-experiment`.

**Workflow:**
```bash
# Current session: auth-refactor
# Branch before risky change:
#   /branch auth-refactor-v2
# Try the risky approach in auth-refactor (current session)
# If it fails, restart with CLAW_SESSION=auth-refactor-v2
```

### Compaction (Context Management)

As a session grows, it consumes more tokens per turn. Compact after major
milestones to keep costs controlled:

```
/compact
```

Compaction keeps the **20 most recent turns** and discards older ones,
prepending a compaction header with the timestamp and turn counts.

Run `/metrics` before compacting to see current size:
```
/metrics
→ Turns: 47  |  User: 24  |  Assistant: 23  |  ~3,200 tokens
```

### Searching Across Sessions

```
/search rate limiting
```

Searches all session files in `~/.claude/claw/` for the query string and
returns matching session names with a 80-character snippet around the match.
Useful for finding prior decisions or prior art.

---

## Skill Loading

Skills can be loaded into the active system context in two ways:

### At Startup

```bash
CLAW_SKILLS=tdd-workflow,security-review node scripts/claw.js
```

### During a Session

```
/load tdd-workflow
```

Skills are loaded from `skills/<skill-name>/SKILL.md` in the current working
directory (the ECC repo root). Unknown or missing skills are silently skipped.

**Use skill loading when:**
- You want Claude to follow a specific workflow (e.g., TDD) for the session
- You need domain context (e.g., `django-patterns`) for the project you're working on
- You're doing a security review and want `security-review` context active

---

## Export Formats

```bash
/export md                          # Markdown (default, same as session file)
/export json                        # JSON array of {timestamp, role, content}
/export txt                         # Plain text, one turn per line
/export md /tmp/session-handoff.md  # Custom output path
```

Use exports for:
- Sharing a session with a team member
- Archiving a completed investigation
- Feeding a session's context into another tool

---

## NanoClaw vs Sequential Pipeline

Choose based on your interaction model:

| Consideration | NanoClaw | Sequential Pipeline (`claude -p`) |
|--------------|----------|----------------------------------|
| Interaction model | Interactive (you type between turns) | Fully automated |
| Context | Grows per turn (full history) | Fresh per call |
| Session persistence | Built-in (Markdown files) | Manual (SHARED_TASK_NOTES.md) |
| Skill context | `/load` command | Pass via system prompt or file |
| CI/CD suitability | Poor (blocks on readline) | Excellent |
| Cost per turn | Grows with session length | Fixed per call |
| Best for | Exploration, debugging, research | Scripted automation, loops |

---

## Extension Rules

When adding new capabilities to `scripts/claw.js`, follow these invariants:

1. **Zero external runtime dependencies** — NanoClaw must run with `node scripts/claw.js` and nothing else. No `npm install` required. Use only Node.js built-ins (`fs`, `path`, `os`, `child_process`, `readline`).
2. **Markdown-as-database compatibility** — Session files must remain valid Markdown. The turn format is `### [<ISO timestamp>] <Role>\n<content>\n---\n`. Do not change this structure without a migration path.
3. **Deterministic, local command handlers** — REPL commands (`/compact`, `/export`, etc.) must be pure filesystem operations. No network calls, no external processes beyond `claude`.
4. **Additive extension** — Add new `/commands` without breaking existing ones. Keep `handleHelp()` in sync with any new commands.

### Adding a New Command

1. Add a handler function: `function handleMyCommand(args, state) { ... }`
2. Add a `case '/mycommand':` branch in the main REPL input handler.
3. Add a line to `handleHelp()`.
4. Add a test in `tests/scripts/claw.test.js` (or the equivalent test file).

---

## Troubleshooting

### Session name rejected at startup

Session names must match `/^[a-zA-Z0-9][-a-zA-Z0-9]*$/`. Spaces, underscores,
and special characters are not allowed.

```bash
# Bad
CLAW_SESSION="my feature" node scripts/claw.js  # space not allowed

# Good
CLAW_SESSION=my-feature node scripts/claw.js
```

### Session file growing too large

Run `/metrics` to check token estimate. If above ~30,000 tokens, `/compact`
before the next major turn. For very long-running projects, branch at each
major milestone so each branch stays manageable.

### Skill not loading

Verify the skill path exists:
```bash
ls skills/<skill-name>/SKILL.md
```

Skills are loaded relative to `process.cwd()`, so run NanoClaw from the ECC
repo root.

### Claude call times out

The `claude -p` call has a 300 second (5 minute) timeout. For very long
operations, break the work into smaller turns. The REPL will surface a
`[Error: ...]` message if the timeout is hit; the session file is not corrupted.

---

## Examples

### Iterative Debugging Session

```bash
CLAW_SESSION=debug-auth CLAW_SKILLS=security-review node scripts/claw.js

> Read src/auth/jwt.ts and tell me what you see.
> The token refresh fails when the expiry is exactly on the boundary. Investigate.
> Write a failing test that reproduces it.
> Fix the implementation to make the test pass.
/metrics
/compact
> Now run the full auth test suite and report results.
/export md ~/Desktop/auth-debug-2025-03-19.md
```

### Research and Handoff

```bash
CLAW_SESSION=research-caching node scripts/claw.js

> Research the codebase for all caching patterns currently in use.
> Compare them and recommend a unified approach.
> Write the recommendation to docs/caching-strategy.md
/export json /tmp/caching-research.json
exit
```

Feed the JSON to another process or share with a teammate.

### Safe Experimentation

```bash
CLAW_SESSION=refactor-v1 node scripts/claw.js

> Refactor the UserRepository to use the repository pattern.
# Looks good so far, but want to try a different approach:
/branch refactor-v2
# Now try alternative in refactor-v1
> Actually, revert that. Try using a base class instead.
# If approach fails:
exit
CLAW_SESSION=refactor-v2 node scripts/claw.js  # resume from branch
```
