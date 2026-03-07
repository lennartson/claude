# Dual Review

**Purpose:** Cross-LLM code review combining Claude's 3-agent review with OpenAI Codex's 3-pass review, then reconciling disagreements with evidence. 6 independent reviewers across 2 LLMs, deduplicated, cross-referenced, and reconciled.

**When to use:** Substantial changes where maximum review confidence matters. For quick changes, use `/review` instead.

**Prerequisite:** `codex` CLI installed (`brew install codex`). If not available, fall back to `/review` and tell the user.

---

## Step 1: Verify Codex Available

```bash
which codex && codex --version
```

If `codex` is not found, tell the user: "Codex CLI not installed. Falling back to standard `/review`." Then execute `/review` instead.

## Step 2: Detect Scope

Determine what to review without asking:

```bash
git diff --cached --stat          # Staged changes
git diff --stat                   # Unstaged changes
git log --oneline main..HEAD      # Branch diff
git show --stat HEAD              # Last commit
```

Pick the first non-empty result. Tell the user what scope you detected.

## Step 3: Prepare Review Context

```bash
BASE_BRANCH=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null | sed 's|origin/||' || echo "main")
BASE_SHA=$(git merge-base HEAD origin/$BASE_BRANCH 2>/dev/null || echo "HEAD~1")
git diff --stat $BASE_SHA..HEAD       # File summary for user
```

Tell the user: "Launching dual review: 3 Claude agents + 3 Codex passes against `$BASE_BRANCH`."

## Step 4: Launch 6 Parallel Reviews

Launch ALL 6 reviews simultaneously. The Claude agents and Codex processes are fully independent.

### Claude Side (3 Agents via Agent tool)

Spawn 3 independent code-reviewer agents using the Agent tool. All 3 run in parallel. Each gets the same diff but a different review lens.

**Agent 1 -- Security & Correctness:**
> Review code changes between $BASE_SHA and HEAD. Primary focus: security vulnerabilities, correctness issues, edge cases, and error handling. Secondary: code quality and architecture. Read full files, not just diffs. Report findings as: [SEVERITY] Title | File: path:line | Issue: description | Fix: recommendation. Severity levels: CRITICAL, HIGH, MEDIUM, LOW.

**Agent 2 -- Architecture & Quality:**
> Review code changes between $BASE_SHA and HEAD. Primary focus: architectural issues, code quality, maintainability, and patterns. Secondary: security and performance. Read full files, not just diffs. Report findings as: [SEVERITY] Title | File: path:line | Issue: description | Fix: recommendation. Severity levels: CRITICAL, HIGH, MEDIUM, LOW.

**Agent 3 -- Testing & Edge Cases:**
> Review code changes between $BASE_SHA and HEAD. Primary focus: missing tests, unhandled edge cases, failure modes, and error paths. Secondary: security and code quality. Read full files, not just diffs. Report findings as: [SEVERITY] Title | File: path:line | Issue: description | Fix: recommendation. Severity levels: CRITICAL, HIGH, MEDIUM, LOW.

Use `subagent_type: code-reviewer` for all 3. Run all 3 in foreground (you need results before reconciliation).

### Codex Side (3 Background Bash Processes)

Run 3 Codex CLI reviews in parallel using the Bash tool with `run_in_background: true`. Each writes its output to a temp file.

**Important**: `codex exec review --base` does not accept a custom prompt alongside `--base`. Use `codex exec` (general mode) with `-s read-only` and a self-contained review prompt instead. Codex can run `git diff` in read-only sandbox mode.

**Codex Pass 1 -- Security & Correctness:**
```bash
codex exec -s read-only --ephemeral -o /tmp/dual-review-codex-security.md "You are performing a focused security code review. Run 'git diff $BASE_BRANCH...HEAD' to see the changes, then read the full files that were modified. Focus exclusively on: security vulnerabilities, correctness issues, edge cases, error handling, injection risks, auth bypasses, data leaks, and unsafe operations. For each finding, report in this exact format:

[SEVERITY] Title
File: path:line
Issue: description of the problem
Fix: recommended solution

Severity levels: CRITICAL (security vulnerabilities, data loss risks), HIGH (correctness bugs, missing error handling), MEDIUM (performance, maintainability), LOW (style, minor issues). Only report issues you are confident about. End with a summary count by severity."
```

**Codex Pass 2 -- Architecture & Quality:**
```bash
codex exec -s read-only --ephemeral -o /tmp/dual-review-codex-architecture.md "You are performing a focused architecture and code quality review. Run 'git diff $BASE_BRANCH...HEAD' to see the changes, then read the full files that were modified. Focus exclusively on: architectural issues, design patterns, code quality, maintainability, coupling, cohesion, naming, and API design. For each finding, report in this exact format:

[SEVERITY] Title
File: path:line
Issue: description of the problem
Fix: recommended solution

Severity levels: CRITICAL (fundamental design flaws), HIGH (poor patterns, tight coupling), MEDIUM (code smells, complexity), LOW (naming, style). Only report issues you are confident about. End with a summary count by severity."
```

**Codex Pass 3 -- Testing & Edge Cases:**
```bash
codex exec -s read-only --ephemeral -o /tmp/dual-review-codex-testing.md "You are performing a focused testing and edge case review. Run 'git diff $BASE_BRANCH...HEAD' to see the changes, then read the full files that were modified. Focus exclusively on: missing tests, unhandled edge cases, failure modes, error paths, unvalidated inputs, race conditions, and boundary conditions. For each finding, report in this exact format:

[SEVERITY] Title
File: path:line
Issue: description of the problem
Fix: recommended solution

Severity levels: CRITICAL (untested critical paths, data corruption risks), HIGH (missing error handling, unvalidated inputs), MEDIUM (missing edge case tests, incomplete coverage), LOW (test quality, naming). Only report issues you are confident about. End with a summary count by severity."
```

## Step 5: Collect All Reports

Wait for all 6 reviews to complete.

- **Claude reports**: Available directly from the Agent tool results.
- **Codex reports**: Read the 3 output files:
  - `/tmp/dual-review-codex-security.md`
  - `/tmp/dual-review-codex-architecture.md`
  - `/tmp/dual-review-codex-testing.md`

If any Codex pass produced an empty file or failed, note it but continue with whatever succeeded. A partial dual review is still better than aborting.

## Step 6: Deduplicate Within Each Side

### Claude Findings

Apply the same deduplication as `/review`:

| Agents Found | Confidence | Meaning |
|-------------|------------|---------|
| 3/3 | HIGH | All 3 agents flagged independently |
| 2/3 | MEDIUM | Majority consensus |
| 1/3 | LOW | Single agent only |

**Noise filter**: 1/3 confidence + LOW severity = drop.

### Codex Findings

Merge findings across Codex's 3 passes using the same logic:
- Same file:line + same issue from multiple passes = higher confidence
- Different issues at same location = separate findings
- Conflicting severity = use the higher one

## Step 7: Cross-LLM Reconciliation

This is the step that makes dual review uniquely valuable. Compare the deduplicated Claude findings against the deduplicated Codex findings.

### Category A: Both LLMs Agree

Findings where both Claude and Codex independently identified the same issue at the same location (or substantially the same issue).

Mark these as **CONSENSUS** confidence. These are almost certainly real issues. Two completely different LLMs with different training, different architectures, and different blind spots both flagged the same thing.

### Category B: Claude-Only Findings

Findings that only Claude's agents identified. Keep these with their existing confidence scoring (HIGH/MEDIUM/LOW based on agent consensus). These are still valid -- Claude has deep context from the full review process.

### Category C: Codex-Only Findings

**This is the critical reconciliation step. Do NOT skip or shortcut this.**

For EACH finding that Codex reported but Claude's agents did not:

1. **Read the actual source code** at the file:line Codex cited
2. **Trace the logic** that Codex flagged -- follow the code path, check callers/callees
3. **Make a verdict**:
   - **CONFIRMED**: The issue is real. Claude's agents missed it. Add to the report as CODEX-CONFIRMED.
   - **DISMISSED**: False positive. Explain WHY in one sentence (e.g., "input is already validated at the API boundary in middleware.ts:45").
   - **NOTED**: Stylistic disagreement or minor point. Include in report at LOW severity for awareness.

**Rules for reconciliation:**
- NEVER dismiss a Codex finding without reading the code first
- NEVER dismiss because "I didn't find it" -- that's circular reasoning
- If a Codex finding is ambiguous, default to CONFIRMED and let the user decide
- If Codex cites a file:line that doesn't exist or doesn't match, note it as INVALID REFERENCE

## Step 8: Unified Report

```markdown
## Dual Review: [scope description]

**Method**: 3 Claude agents (Sonnet) + 3 Codex passes (GPT-5.4), reconciled by Claude (Opus)
**Files Reviewed**: [count]
**Unique Findings**: [count] (from [raw Claude count] Claude + [raw Codex count] Codex findings)

### CONSENSUS Findings (Both LLMs Agree)

- **[CO-001]** `file:line` -- [description]
  Source: Claude (X/3 agents) + Codex ([pass]) | Fix: [recommendation]

### Critical

- **[CR-001]** `file:line` -- [description]
  Source: [Claude X/3 | Codex pass N | CODEX-CONFIRMED] | Fix: [recommendation]

### High

- **[HI-001]** `file:line` -- [description]
  Source: [Claude X/3 | Codex pass N | CODEX-CONFIRMED] | Fix: [recommendation]

### Medium

- **[ME-001]** `file:line` -- [description]
  Source: [Claude X/3 | Codex pass N | CODEX-CONFIRMED] | Fix: [recommendation]

### Codex Dismissed

- **[DI-001]** `file:line` -- [Codex's claim]
  Verdict: DISMISSED -- [one-sentence reason with evidence]

### Summary

| Source | CONSENSUS | Claude-Only | Codex-Confirmed | Codex-Dismissed | Total |
|--------|-----------|-------------|-----------------|-----------------|-------|
| Critical | 0 | 0 | 0 | 0 | 0 |
| High | 0 | 0 | 0 | 0 | 0 |
| Medium | 0 | 0 | 0 | 0 | 0 |
| Low | 0 | 0 | 0 | 0 | 0 |

Verdict: [APPROVE / WARNING / BLOCK]
```

## Step 9: After Review

- If issues found: "Should I fix these now?" -- fix starting with CONSENSUS findings, then highest severity.
- If zero findings across all 6 reviewers: exceptionally strong clean signal. State what was verified.
- Clean up temp files: `rm -f /tmp/dual-review-codex-*.md`

---

## Approval Criteria

| Verdict | Condition |
|---------|-----------|
| **APPROVE** | No CRITICAL or HIGH at CONSENSUS/CONFIRMED level |
| **WARNING** | HIGH findings only -- merge with caution |
| **BLOCK** | Any CRITICAL finding from either LLM |

## Failure Handling

| Failure | Action |
|---------|--------|
| Codex CLI not installed | Fall back to `/review` |
| Codex auth expired | Warn user, continue with Claude-only (becomes `/review`) |
| One Codex pass fails | Continue with remaining passes, note gap in report |
| All Codex passes fail | Degrade to `/review`, tell user why |
| One Claude agent fails | Continue with remaining agents |

## Related Commands

- `/review` -- Standard 3-agent Claude review (lighter weight)
- `/ship` -- Formal quality gate (includes review + verification)
- `/audit` -- Deep forensic codebase sweep (broader scope)
