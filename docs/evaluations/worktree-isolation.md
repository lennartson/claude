# Evaluation: Claude Code Built-in Git Worktree Support

**Source:** https://x.com/bcherny/status/2025007393290272904
**Author:** Boris Cherny (@bcherny) — leads Claude Code at Anthropic
**Date:** Feb 21, 2026
**Evaluated:** Feb 25, 2026

## 1. Summary of Claim

- Claude Code sessions can run in parallel on the same repo without clobbering each other's edits
- Each session/subagent gets its own git worktree (separate working directory, same repo)
- Subagents support `isolation: worktree` for large batched changes and code migrations
- Custom agents declare worktree isolation in their frontmatter
- Non-git SCM users can define worktree hooks (Mercurial, Perforce, SVN)
- Available in CLI, Desktop, IDE extensions, web, and mobile (v2.1.50+)

## 2. Technical Reality Check

**Category:** Infrastructure + Agent configuration

Uses `git worktree add` to create lightweight checkouts of the same repo in separate directories. Each Claude Code session operates in its own worktree, so file edits in one session don't conflict with another. Subagent changes merge back via standard git merge/rebase.

Real engineering feature, not a prompt trick. Git worktrees are well-understood. The novel part is integration into Claude Code's agent orchestration.

## 3. Hype / Credibility Check

| Check | Assessment |
|-------|-----------|
| Evidence | Shipped in v2.1.50, from Claude Code lead |
| Specificity | Concrete flags, version number, frontmatter syntax |
| Terminology | Correct git worktree concepts |
| Cherry-picking | No — straightforward feature announcement |
| Overclaiming | None |
| Engineering detail | CLI flags, frontmatter syntax, Desktop UI shown |

**Red flags:** None.

## 4. Fit Assessment

- **Context cost:** Zero. Runtime infrastructure, not prompt content.
- **Latency:** Minimal (~100ms to create worktree).
- **Security:** No new concerns. Same repo permissions.
- **Compatibility:** Direct fit. Already using git, Claude Code CLI, subagents.

## 5. What This Replaces

| Replaces | With |
|----------|------|
| One session per repo at a time | Multiple parallel isolated sessions |
| Manual worktree management | Built-in `--worktree` flag |
| Subagents editing same working directory | Subagents in isolated worktrees |

## 6. Scores

| Metric | Score | Rationale |
|--------|-------|-----------|
| Usefulness | 5/5 | Parallel agent work is the biggest bottleneck |
| Effort to implement | 1/5 | Already shipped — just add frontmatter |
| Time to first signal | 1/5 | Immediate |
| Bullshit risk | 1/5 | First-party feature, already in CLI |
| Context cost | 1/5 | Zero context cost |

## 7. Recommendation

**ADOPT**

## 8. Implementation

### Changes made

- Added `isolation: worktree` to 6 write-heavy agent frontmatters (staging + production):
  - refactor-cleaner, build-error-resolver, doc-updater, e2e-runner, security-reviewer, tdd-guide
- Left 3 read-only agents without worktree: code-reviewer, architect, planner
- Added "Worktree Isolation" section to `~/.claude/CLAUDE.md` and `staging/CLAUDE.md`

### Verification

- All 6 write-heavy agents have `isolation: worktree` in both staging and production
- 3 read-only agents correctly excluded
- CLAUDE.md has usage guidelines for CLI (`--worktree`, `--tmux`) and subagent spawning

## 9. Caveats

- Merge conflict handling between worktree agents editing same file — worth testing
- Worktree cleanup after agent completion — verify no stale worktrees accumulate
- Performance at scale (5+ simultaneous worktree agents) — untested
