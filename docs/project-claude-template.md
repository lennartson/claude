# Project CLAUDE.md Template

Copy this to your project root as `CLAUDE.md` and customize for your project.

---

# [Project Name]

## Tech Stack
- Framework: [Next.js / React / Node / etc.]
- Database: [Postgres / Supabase / etc.]
- Package manager: [bun / npm / pnpm]

## Project Structure
```
src/           # or app/, lib/, etc.
├── components/
├── lib/
└── ...
```

## Commands
```bash
# Development
[bun/npm] run dev

# Tests
[bun/npm] run test

# Build
[bun/npm] run build

# Lint
[bun/npm] run lint
```

## Project-Specific Rules

### Import Patterns
- Import database utilities from `@/lib/db` not directly from ORM
- Import UI components from `@/components` not from package directly

### Build Requirements
- DATABASE_URL is required at build time (no "skip" patterns)
- Use `bun` not `npm` in CI/deployment

### Code Patterns
- NEVER add .js extensions to imports (Turbopack incompatible)
- Use server actions for mutations, not API routes
- [Add your project-specific patterns here]

## Agentation (Visual Feedback)

This project uses [agentation](https://github.com/benjitaylor/agentation) for visual UI feedback. When the user pastes agentation output containing CSS selectors and annotations (e.g. `.sidebar > button.primary`), grep for those selectors to locate the source component, then apply the requested changes. Prefer selector-based references over screenshot descriptions.

## Framework Docs Index

<!--
  If this project uses a framework with APIs newer than Claude's training data
  (e.g. Next.js 16+, AI SDK v6+), add a compressed reference here.

  Passive context beats on-demand skills for framework knowledge.
  Skills plateau at ~79% accuracy; always-loaded docs hit 100%.
  (Source: Vercel agent evals, Jan 2026)

  For Next.js: npx @next/codemod@canary agents-md
  For other frameworks: manually compress key APIs, gotchas, and migration
  notes into <200 lines below. Focus on what changed since training cutoff.
-->

<!-- Example for Next.js 16+:
### Next.js 16 API Reference (compressed)
- `use cache` directive: replaces ISR/SSG, caches at component level
- `connection()`: await before reading request-specific data in cached components
- `forbidden()`: throws 403, use in Server Components/Actions/Route Handlers
- `unauthorized()`: throws 401, same usage pattern as forbidden()
- Dynamic APIs (cookies, headers, params, searchParams) are now async
- Middleware cannot use Node.js APIs (crypto, fs, etc.)
-->

## Known Gotchas
- [List any quirks or traps specific to this project]
- [Things that have caused bugs before]
