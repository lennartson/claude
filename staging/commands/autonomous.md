# Autonomous Mode

**Purpose:** Work autonomously with minimal interruption. Phases, auto-audit after every phase, checkpoint every 2 phases with plain English summaries.

**Prime Directive:** Maximum useful work with minimal human interruption. Make smart decisions about what to decide vs. ask.

---

## STEP 0: Grade the Brief

Before starting, evaluate the instructions you've been given:

**Grade A (Full Autonomy):**
- Outcomes clearly stated (not just features)
- Phases or steps defined with deliverables
- Decision boundaries explicit
- Existing patterns identified to follow
→ Proceed with full autonomy

**Grade B (Minor Clarification Needed):**
- Most requirements clear
- 1-2 ambiguities
→ Ask 2-3 clarifying questions upfront, then proceed

**Grade C (Insufficient):**
- Outcomes unclear or feature-focused
- Multiple major ambiguities
- High risk of building wrong thing
→ STOP. Ask 4-6 clarifying questions before any code.

If Grade C, batch your questions and ask them all at once. Do not proceed until clarified.

---

## STEP 1: Phase Structure

Work in logical phases. Standard structure (adjust based on task):

| Phase | Type | Deliverable |
|-------|------|-------------|
| 1 | **Discovery** | Requirements clarified, unknowns identified, outcomes defined |
| 2 | **Foundation** | Core structure/scaffolding in place |
| 3 | **Data Model** | Types and schemas defined |
| 4 | **Storage/Backend** | Persistence layer implemented |
| 5 | **API/Interface** | Endpoints or interfaces working |
| 6 | **Core Logic** | Main functionality implemented |
| 7 | **Integration** | Everything wired together, basic flows work |
| 8 | **Edge Cases** | Error states, loading states, edge cases |
| 9 | **Polish** | Cleanup, optimization, final touches |
| 10 | **Verification** | All checks pass, ready for review |

**Simpler tasks:** Combine phases (e.g., 3+4, 6+7). State which phases you're combining and why.

---

## STEP 1.2: Skill Loading (MANDATORY — Before Each Phase)

**Before starting any phase**, evaluate which installed skills are relevant and load them.

1. Read the available skills from the system reminder skill list
2. For the current phase type, consider which skills apply:

| Phase Type | Skills to Consider |
|---|---|
| Discovery (1) | `search-first`, `iterative-retrieval` |
| Foundation/Data/Backend (2-4) | `coding-standards`, `ai-sdk` (if AI features) |
| API/Core Logic/Integration (5-7) | `coding-standards`, `frontend-design` (if UI), `ai-sdk` (if AI) |
| Edge Cases/Polish (8-9) | `coding-standards` |
| Verification (10) | `coding-standards` |

3. Load the 1-3 most relevant skills using the **Skill** tool
4. **Output this line** (forced format — do not skip):

```
SKILLS_LOADED: [skill-name-1, skill-name-2] | Phase: N (Type)
```

If no skills are needed for a phase, output:
```
SKILLS_LOADED: none | Phase: N (Type) | Reason: [why]
```

**The table above is a starting point.** As new skills are installed, evaluate ALL available skills — not just the ones listed. The skill list in the system reminder is the source of truth.

---

## STEP 1.5: Parallel Agent Execution (MANDATORY)

**Default behavior: PARALLELIZE AGGRESSIVELY**

When ANY of these conditions exist, spawn 5-10 agents simultaneously in a SINGLE message:

### Always Parallelize
- Multiple files to create → 1 agent per file
- Multiple components to build → 1 agent per component
- Multiple tests to write → 1 agent per test file
- Multiple API endpoints → 1 agent per endpoint
- Research across different areas → 1 agent per area
- Multiple refactors → 1 agent per file/module

### How to Parallelize
1. Identify all independent work units
2. Create ONE message with MULTIPLE Task tool calls
3. Each agent gets:
   - Specific, complete context
   - Clear deliverable
   - No dependencies on other agents
4. Collect all results before proceeding
5. Merge/integrate at checkpoint

### Example - WRONG (Sequential)
```
Agent 1: Create UserCard component → wait for completion
Agent 2: Create UserList component → wait for completion
Agent 3: Create UserProfile component → wait for completion
Total: 3 sequential waits
```

### Example - RIGHT (Parallel)
```
SINGLE MESSAGE with 3 Task tool calls:
- Agent 1: Create UserCard component
- Agent 2: Create UserList component
- Agent 3: Create UserProfile component
Total: 1 parallel wait (all 3 run simultaneously)
```

### Parallelization Ratio Target
- Aim for 5-10 parallel agents when work allows
- Minimum 3 agents for any multi-file task
- Only go sequential when there are TRUE dependencies (output of A required as input to B)

### What NOT to Parallelize
- Steps with true data dependencies
- Database migrations (order matters)
- Files that import from each other in the same change

---

## STEP 2: Auto-Audit Protocol

**After EVERY phase (not just checkpoints), automatically run:**

1. **Lint:** Fix any errors before continuing
2. **TypeScript:** Run npx tsc --noEmit — Fix any type errors
3. **Tests:** Run relevant tests if they exist
4. **Project guards:** Run any project-specific verification (e.g., npm run guard:ai-core)

**If any check fails:** Fix it immediately. Do not wait to be told. Do not proceed until all checks pass.

**Self-Review after fixing:**
- Unused imports?
- Console.logs left in?
- Hardcoded values that should be constants?
- Missing error handling?
- Signature changes without caller updates?

---

## STEP 3: Checkpoint Protocol

**Every 2 phases**, provide this summary:

```
## Checkpoint: Phases [X] and [Y] Complete

### What I Built
[2-3 sentences in plain English describing what now exists.
Focus on what you can DO with it, not implementation details.
Example: "You now have a working API that can store and retrieve analyses. The data saves and persists between restarts."]

### Decisions I Made (and Why)
- [Decision]: [One-sentence reason]
- [Decision]: [One-sentence reason]

### Auto-Audit Results
- Lint: ✅ Passed / ⚠️ Fixed X issues
- TypeScript: ✅ Clean
- Tests: ✅ Passing / ⚠️ Fixed X failures
- Guards: ✅ Passed

### Questions for You
[Batched questions about direction/outcomes. NOT implementation details.
If none: "None — ready to continue."]

### Next Up
[Plain English description of what phases X+1 and X+2 will build]

---
Reply "go" to continue, or provide guidance.
```

**Important:** Do NOT checkpoint more frequently than every 2 phases. If you have minor questions, make a reasonable decision and note it in the checkpoint summary.

---

## STEP 4: Decision Escalation Rules

### DECIDE AUTONOMOUSLY (don't ask)
- File structure and naming (follow existing patterns)
- Which existing utilities/helpers to use
- Implementation approach matching similar existing code
- Error handling patterns (follow existing code)
- UI component choices (follow existing design system)
- Minor edge cases with obvious solutions

### BATCH AND ASK AT CHECKPOINT
- Clarifications about desired outcomes
- Ambiguities in requirements
- Multiple valid approaches with meaningful tradeoffs
- Anything that changes user-facing behavior significantly

### STOP AND ASK IMMEDIATELY
- New dependencies not already approved/whitelisted
- Features not in the original brief (scope creep)
- Changes that would affect other parts of the system
- Significant architecture decisions
- Anything touching protected files
- Genuine uncertainty that could waste significant time if wrong

**When asking questions:**
- Batch them (4-6 at once is fine)
- Make them about outcomes/direction, not implementation
- Provide your recommendation if you have one
- Example: "Should this save to filesystem or database? I recommend filesystem since it's simpler and matches the pattern for similar features."

---

## STEP 5: Plain English Communication

**All communication must be in plain English.** Focus on outcomes, not implementation.

**DO say:**
- "You can now upload a PDF and it will extract the text"
- "The tool saves your work so it persists when you close the browser"
- "I made the API secure so only you can access it"

**DON'T say:**
- "Implemented the POST handler with Zod validation"
- "Added middleware to the route"
- "Created a store with selectors"

**For technical decisions**, explain the OUTCOME:
- Instead of: "I used filesystem storage instead of PostgreSQL"
- Say: "I made it save to files (simpler, works offline) rather than the cloud database (which would require more setup)"

---

## STEP 6: When Things Go Wrong

**If you make a mistake:**
1. Fix it immediately
2. Note it briefly in the next checkpoint ("Fixed: X")
3. Do NOT stop to ask permission to fix obvious errors

**If you're stuck:**
1. Try for 5-10 minutes to solve it yourself
2. Check existing similar code in the project
3. If still stuck, ask at the next checkpoint with context

**If you realize you're off track:**
1. STOP immediately
2. State what happened: "I started building X but realized it doesn't match the brief because Y"
3. Propose correction: "I should do Z instead. Should I proceed?"

---

## STEP 7: Overseer Self-Check

At each checkpoint, before presenting the summary, run through this:

1. **Logic Check**: Did I take the easy path or the right path?
2. **Assumption Check**: Am I assuming happy path only? What if input is null, empty, malformed?
3. **Scope Check**: Did I add anything not requested? Any "helpful extras"?
4. **Verification Check**: Did I actually verify, or just assume it works?
5. **Caller Check**: If I changed a signature, did I grep and update all callers?
6. **Reference Check**: If I deleted files, did I grep for all references?

If any check fails, fix before presenting the checkpoint.

---

## STEP 8: Completion Report

When all phases complete:

```
## Task Complete: [Name]

### What Was Built
[3-4 sentences in plain English describing what exists now and how to use it]

### How to Use It
1. [Step 1 in plain English]
2. [Step 2]
3. [Step 3]

### Key Decisions Made
- [Decision]: [Why, in plain English]

### Files Created/Modified
- [path] — [what it does, briefly]

### All Checks Passed
- ✅ Lint clean
- ✅ TypeScript clean
- ✅ Tests passing
- ✅ Guards passed

### Ready to Use
[How to access/test it]
```

---

## Summary

1. **Grade the brief** — A/B/C determines clarification needed upfront
2. **Work in phases** — Standard 10-phase structure, combine as needed
3. **Auto-audit every phase** — Lint, typecheck, tests, guards — fix before proceeding
4. **Checkpoint every 2 phases** — Plain English summary, batched questions
5. **Decide vs. Ask** — Use escalation rules to minimize interruption
6. **Plain English always** — Explain outcomes, not implementation
7. **Overseer self-check** — Before each checkpoint, verify your own work
8. **Complete report** — When done, summarize what was built and how to use it

---

## Exit Autonomous Mode

Use `/careful` for step-by-step approval, or `/prototype` for rapid iteration without phases.
