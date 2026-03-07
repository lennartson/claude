---
name: semi-formal-reasoning
description: "Structured code reasoning that prevents premature conclusions. Use when you debug, review code changes, compare implementations, investigate why code behaves unexpectedly, trace bugs to root cause, verify patch correctness, or answer questions about code behavior. Forces explicit premises, execution path trace, and evidence-based conclusions instead of guessing. Covers diff review, bug investigation, test failure analysis, error trace, fault localization, and root cause analysis."
use-when: "Debug bug, review diff, compare patch, investigate unexpected behavior, trace execution error, verify code correctness, answer how why code works, fault localization, root cause analysis, code review, test failure, failing test"
allowed-tools: Read, Grep, Glob, Bash
---

# Semi-Formal Reasoning

Structured reasoning methodology that prevents the most common failure mode in code analysis: **concluding before tracing.** Based on Meta's research (Ugare & Chandra, 2026) showing 5-12 percentage point accuracy improvements across patch equivalence, fault localization, and code understanding tasks.

## The Core Problem

When reasoning about code, the natural tendency is:
1. Glance at the code
2. Form an intuition ("this looks like it does X")
3. Conclude based on that intuition

This fails because:
- Functions may be shadowed by imports you didn't check
- Side effects in called functions change behavior
- Edge cases (null, empty, boundary values) break assumptions
- Two implementations that "look equivalent" may diverge on specific inputs

**Semi-formal reasoning forces you to trace before concluding.** Every claim must cite evidence from actual code you read.

## When to Use This

| Situation | Template |
|-----------|----------|
| Reviewing a diff or PR | Patch Comparison |
| Comparing two implementations | Patch Comparison |
| Debugging a failing test or bug | Fault Localization |
| "Why does this code do X?" | Code Understanding |
| "Is this change safe?" | Patch Comparison |
| Investigating unexpected behavior | Fault Localization |
| Root cause analysis | Fault Localization |

## The Universal Structure

All three templates follow this pattern:

```
1. PREMISES     — State what each piece of code does (read it, don't guess)
2. TRACE        — Follow execution step by step through function calls
3. EVIDENCE     — Find specific inputs/paths where behavior differs or matches
4. CONCLUSION   — Derive answer ONLY from traced evidence
```

**The rule:** You cannot write a CONCLUSION until you have completed TRACE. No skipping ahead.

---

## Template 1: Patch Comparison

Use when reviewing diffs, comparing two implementations, or verifying that a change is safe.

### Structure

```
PREMISES:
- Patch A modifies [file:line]: [what it does]
- Patch B modifies [file:line]: [what it does]
- Shared context: [relevant imports, class state, config]

EXECUTION TRACE (per relevant test/scenario):
  Scenario: [description of input/state]
  With Patch A:
    1. [function] called with [args] → returns [value]
    2. [next function] receives [value] → does [action]
    3. ...
  With Patch B:
    1. [function] called with [args] → returns [value]
    2. [next function] receives [value] → does [action]
    3. ...
  Divergence: [where behavior differs, if at all]

COUNTEREXAMPLE (if non-equivalent):
  Input: [specific value or state]
  Patch A produces: [result]
  Patch B produces: [result]
  Therefore: NOT equivalent because [reason with file:line evidence]

CONCLUSION:
  [Equivalent/Not equivalent] because [derived from traced evidence above]
```

### Critical Checks During Tracing

- **Name shadowing**: Is `format()` the builtin or a module-level import? Read the imports.
- **Method resolution**: In a class hierarchy, which implementation actually runs? Check the MRO.
- **Side effects**: Does calling function A modify state that function B reads? Trace the mutations.
- **Error paths**: What happens when the input is null, empty, or at a boundary? Trace both paths.
- **Type coercion**: Does `==` vs `===` matter here? Does string-to-number conversion change behavior?

---

## Template 2: Fault Localization

Use when debugging a failing test, investigating a bug, or doing root cause analysis. Complements the `debugging` skill — debugging gives you the process (phases 1-4), semi-formal reasoning gives you the thinking methodology within Phase 1.

### Structure

```
TEST SEMANTICS:
- Failing test: [test name at file:line]
- What it checks: [the assertion, in plain language]
- Expected behavior: [what should happen]
- Actual behavior: [what happens instead]

CODE PATH TRACE:
  From test entry point:
    1. [test calls] function at [file:line]
    2. [function] reads [state/config/param]
    3. [function] calls [next function] at [file:line]
    4. [next function] does [action]
    5. ...trace until the divergence point...

DIVERGENCE ANALYSIS:
  Expected path: [what should execute]
  Actual path: [what actually executes]
  Divergence at: [file:line]
  Root cause: [why the code takes the wrong path]
  Evidence: [specific code that proves this — quote it with file:line]

RANKED PREDICTIONS:
  1. [file:line] — [reason, with confidence: high/medium/low]
  2. [file:line] — [reason, with confidence]
  3. [file:line] — [reason, with confidence]
```

### Common Tracing Failures to Avoid

- **Stopping at the symptom**: The error appears at line 42, but the root cause is at line 10 where the wrong value was assigned. Keep tracing backward.
- **Trusting function names**: `validateInput()` might not actually validate. Read the implementation.
- **Ignoring indirection**: The bug might be in a class that's never directly called but is reached through a factory, event handler, or dependency injection.
- **Assuming library behavior**: If the bug involves a third-party library, read how it actually works — don't assume from the function name.

---

## Template 3: Code Understanding

Use when answering questions about how code works, why it behaves a certain way, or what would happen under specific conditions.

### Structure

```
QUESTION: [restate the question precisely]

RELEVANT CODE:
- [file:line]: [what this code does]
- [file:line]: [what this code does]
- [dependencies, imports, config that affect behavior]

EXECUTION TRACE:
  Given [specific input/state]:
    1. [entry point] at [file:line]
    2. [reads/calls] [value/function] — result: [what happens]
    3. [next step] — result: [what happens]
    4. ...

INVARIANTS:
- [what must always be true, based on traced evidence]
- [what can never happen, based on traced evidence]

CONCLUSION:
  [Answer derived from the trace above]
  Confidence: [high/medium/low]
  If low: [what additional information would increase confidence]
```

### When Confidence Is Low

If you trace through the code and still aren't confident:
1. State what you DO know (from evidence)
2. State what you DON'T know (what's missing)
3. Identify what you'd need to read or test to get higher confidence
4. NEVER present a low-confidence answer as certain

---

## Anti-Patterns

| You're Doing This | Do This Instead |
|---|---|
| "These two functions look the same" | Trace both with the same input, compare step by step |
| "This should work because..." | Show it works by tracing execution with a specific input |
| "I'm pretty sure X calls Y" | Read X. Find the actual call. Quote the line. |
| "This is equivalent" (without tracing) | Trace at least one non-trivial input through both paths |
| Concluding after reading one file | Follow the call chain across files before concluding |
| "The function name suggests..." | Read the function body. Names lie. |

## Integration with Other Skills

- **debugging**: Use semi-formal reasoning during Phase 1 (Root Cause Investigation) to trace execution paths rigorously
- **coding-standards**: When reviewing code for correctness, apply the Patch Comparison template to verify changes don't alter behavior
- **verification rule**: Semi-formal reasoning is the HOW behind "verify, don't assume"

## Evidence Quality

Every claim in your trace must be backed by code you actually read:

| Evidence Type | Strength | Example |
|---|---|---|
| **Direct** (code quote) | Strong | `format` at `utils.py:3` is imported from `django.utils.dateformat`, not the builtin |
| **Structural** (file/class organization) | Medium | Class `Foo` extends `Bar`, so `method()` resolves to `Bar.method` at `bar.py:45` |
| **Inferential** (reasoning from patterns) | Weak | "This probably uses the default because no override is visible" — verify by reading the constructor |

Weak evidence requires additional investigation before use in conclusions.
