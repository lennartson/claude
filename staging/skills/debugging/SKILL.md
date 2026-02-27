---
name: debugging
description: Use when encountering any bug, test failure, or unexpected behavior. Enforces root cause investigation before proposing fixes.
---

# Debugging

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## The Four Phases

Complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Read stack traces completely
   - Note line numbers, file paths, error codes
   - They often contain the exact solution

2. **Reproduce Consistently**
   - Can you trigger it reliably? What are the exact steps?
   - If not reproducible, gather more data -- don't guess

3. **Check Recent Changes**
   - Git diff, recent commits
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**

   When the system has multiple components (CI -> build -> signing, API -> service -> database), add diagnostic instrumentation BEFORE proposing fixes:

   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation

   Run once to gather evidence showing WHERE it breaks
   THEN analyze evidence to identify failing component
   THEN investigate that specific component
   ```

   **Example (multi-layer system):**
   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   This reveals which layer fails (secrets -> workflow OK, workflow -> build FAIL).

5. **Trace Data Flow**

   See `root-cause-tracing.md` in this directory for the complete backward tracing technique.

   Quick version: Where does the bad value originate? What called this with the bad value? Keep tracing up until you find the source. Fix at source, not at symptom.

### Phase 2: Pattern Analysis

1. **Find Working Examples** - Locate similar working code in the same codebase
2. **Compare Against References** - Read reference implementations COMPLETELY, don't skim
3. **Identify Differences** - List every difference between working and broken, however small
4. **Understand Dependencies** - What components, settings, config, environment does this need?

### Phase 3: Hypothesis and Testing

1. **Form Single Hypothesis** - State clearly: "I think X is the root cause because Y"
2. **Test Minimally** - Make the SMALLEST possible change to test hypothesis. One variable at a time.
3. **Verify** - Did it work? Yes -> Phase 4. No -> Form NEW hypothesis. Don't stack fixes.

### Phase 4: Implementation

1. **Create Failing Test Case** - Simplest possible reproduction. MUST exist before fixing.
2. **Implement Single Fix** - Address root cause. ONE change at a time. No "while I'm here" improvements.
3. **Verify Fix** - Test passes? No other tests broken? Issue actually resolved?
4. **If Fix Doesn't Work**
   - Count: How many fixes have you tried?
   - If < 3: Return to Phase 1, re-analyze with new information
   - If >= 3: STOP. Question the architecture (see Escalation below)

### Escalation: 3+ Fixes Failed

Pattern indicating architectural problem:
- Each fix reveals new shared state/coupling in a different place
- Fixes require massive refactoring to implement
- Each fix creates new symptoms elsewhere

STOP and question fundamentals:
- Is this pattern fundamentally sound?
- Should we refactor architecture vs. continue fixing symptoms?
- **Discuss with the user before attempting more fixes**

This is NOT a failed hypothesis -- this is a wrong architecture.

## Red Flags -- STOP and Return to Phase 1

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- "One more fix attempt" (when already tried 2+)

## When Investigation Reveals No Root Cause

If systematic investigation shows the issue is truly environmental, timing-dependent, or external:
1. Document what you investigated
2. Implement appropriate handling (retry, timeout, error message)
3. Add monitoring/logging for future investigation

But: 95% of "no root cause" cases are incomplete investigation.

---

## Advanced: Parallel Hypothesis Investigation (ACH)

For complex bugs with multiple plausible root causes, use Analysis of Competing Hypotheses to avoid confirmation bias.

**When to use:** Bug has multiple plausible causes, spans multiple modules, or initial investigation is inconclusive.

### Evidence Taxonomy

| Evidence Type     | Strength | Example                                                          |
| ----------------- | -------- | ---------------------------------------------------------------- |
| **Direct**        | Strong   | Code at `file.ts:42` shows `if (x > 0)` should be `if (x >= 0)` |
| **Correlational** | Medium   | Error rate increased after commit `abc123`                       |
| **Testimonial**   | Weak     | "It works on my machine"                                         |
| **Absence**       | Variable | No null check found in the code path                             |

Always cite evidence with `file:line` references.

### Confidence Levels

| Level               | Criteria                                                                           |
| ------------------- | ---------------------------------------------------------------------------------- |
| **High (>80%)**     | Multiple direct evidence pieces, clear causal chain, no contradicting evidence     |
| **Medium (50-80%)** | Some direct evidence, plausible causal chain, minor ambiguities                    |
| **Low (<50%)**      | Mostly correlational evidence, incomplete causal chain, some contradicting evidence |

### Hypothesis Arbitration

After investigating all hypotheses:

1. **Categorize**: Confirmed (high confidence, strong evidence) | Plausible (medium) | Falsified (contradicted) | Inconclusive (insufficient data)
2. **If one hypothesis clearly dominates**: Declare as root cause
3. **If multiple confirmed**: Rank by confidence, evidence count, causal chain strength. May be compound issue.
4. **If none confirmed**: Generate new hypotheses from gathered evidence

### Validate Fix Checklist

- [ ] Fix addresses the identified root cause
- [ ] Fix doesn't introduce new issues
- [ ] Original reproduction case no longer fails
- [ ] Related edge cases are covered
- [ ] Relevant tests are added or updated

---

## Supporting Techniques

Available in this directory:
- **`root-cause-tracing.md`** - Trace bugs backward through call stack to find original trigger
- **`defense-in-depth.md`** - Add validation at multiple layers after finding root cause
- **`condition-based-waiting.md`** - Replace arbitrary timeouts with condition polling
- **`find-polluter.sh`** - Bisect test suite to find which test creates unwanted state

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |
