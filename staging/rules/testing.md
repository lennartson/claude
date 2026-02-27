# Testing Rules

## Test Framework

**ALWAYS use VITEST for tests, not bun:test.**

This is non-negotiable. The project uses Vitest.

## TDD Default

Test-Driven Development is the default for all work EXCEPT `/spike` mode.

1. Write failing test first (RED)
2. Implement minimal code to pass (GREEN)
3. Refactor while tests pass (REFACTOR)

## When to Write Tests

- Bug fix → Write test that reproduces bug FIRST
- New feature → Write tests alongside implementation
- Refactor → Ensure tests exist before changing

## Test Quality

- Test behavior, not implementation
- One assertion per test when practical
- Descriptive test names: "should reject empty input"
- No console.log in tests

## Test Naming

| Quality | Good | Bad |
|---------|------|-----|
| **Minimal** | One thing. "and" in name? Split it. | `test('validates email and domain and whitespace')` |
| **Clear** | Name describes behavior: `'retries failed operations 3 times'` | `test('test1')` or `test('retry works')` |
| **Shows intent** | Demonstrates desired API with real code | Obscures behavior behind mocks |

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write wished-for API. Write assertion first. Ask your human partner. |
| Test too complicated | Design too complicated. Simplify interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify design. |

## Coverage

- Aim for meaningful coverage, not 100%
- Critical paths MUST be covered
- Edge cases MUST be covered
- Happy path alone is insufficient
