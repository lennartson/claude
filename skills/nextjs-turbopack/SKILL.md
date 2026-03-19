---
name: nextjs-turbopack
description: Next.js 16+ and Turbopack — incremental bundling, FS caching, dev speed, and when to use Turbopack vs webpack.
origin: ECC
---

# Next.js and Turbopack

Next.js 16+ uses **Turbopack** by default for local development: an incremental
bundler written in Rust that significantly speeds up dev startup and hot module
replacement (HMR), especially in large applications.

## When to Use

- Developing or debugging Next.js 16+ apps
- Diagnosing slow dev startup or HMR lag
- Optimizing production bundle size or build time
- Evaluating whether to stay on Turbopack or fall back to webpack
- Configuring Next.js bundler behavior (aliases, loaders, experimental flags)

---

## Turbopack vs Webpack Decision

| Situation | Use |
|-----------|-----|
| Day-to-day development on Next.js 16+ | **Turbopack** (default) |
| Hit a reproducible Turbopack bug | **webpack** (temporary fallback) |
| Need a webpack-only plugin in dev | **webpack** (until Turbopack supports it) |
| Production build | Check your Next.js version release notes — behavior varies |
| Large app with slow cold start | **Turbopack** (5–14× faster restarts) |
| Debugging bundler output | **Turbopack** + Bundle Analyzer (16.1+) |

### Switching Bundlers

```bash
# Default (Turbopack)
next dev

# Webpack fallback
next dev --webpack
# or (depending on your Next.js patch version)
next dev --no-turbopack
```

Always check the official Next.js changelog for your exact version — the flag
name changed between minor releases.

---

## How Turbopack Works

### Incremental Bundling

Turbopack uses a **demand-driven, incremental** compilation model:

1. On cold start, it only compiles modules reachable from the routes you visit.
2. On subsequent startups, it reuses the on-disk cache (under `.next/cache/`).
3. On file save, it recompiles only the changed module and its direct dependants
   (not the whole graph).

This produces two measurable effects:
- **Cold start** is 5–14× faster than webpack on large projects.
- **HMR latency** is typically <100 ms regardless of project size.

### File-System Cache

The Turbopack cache lives in `.next/cache/turbopack/` by default. It is
persistent across restarts. Cache invalidation is content-hash–based: a file
change invalidates only the modules that depend on it.

```bash
# Clear cache manually if you suspect stale state
rm -rf .next/cache/turbopack
next dev
```

Do not clear the cache routinely — it defeats the speed benefit.

### Production Builds

As of Next.js 16.x, `next build` may use Turbopack or webpack depending on
the patch version and experimental flags. Check the release notes:

```bash
# See which bundler is active for your build
next build --debug 2>&1 | grep -i 'turbopack\|webpack'
```

---

## Configuration

### next.config.js / next.config.ts

```js
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Turbopack configuration (Next.js 16+)
  turbopack: {
    // Module aliases (equivalent to webpack resolve.alias)
    resolveAlias: {
      '@/components': './src/components',
      '@/lib': './src/lib',
    },
    // File extensions to resolve (order matters)
    resolveExtensions: ['.tsx', '.ts', '.jsx', '.js', '.json'],
    // Custom loaders (Turbopack uses its own loader API)
    rules: {
      '*.svg': {
        loaders: ['@svgr/webpack'],
        as: '*.js',
      },
    },
  },
};

module.exports = nextConfig;
```

### Environment-Based Bundler Selection

```bash
# .env.development (commit)
NEXT_TURBOPACK=1

# .env.development.local (gitignored, per-machine override)
# Leave empty to use Turbopack, or set to 0 to use webpack
```

---

## Bundle Analysis

### Next.js 16.1+ Bundle Analyzer

Next.js 16.1 ships with an experimental built-in bundle analyzer. Enable it
via config or the `ANALYZE` environment variable:

```js
// next.config.js
const nextConfig = {
  experimental: {
    bundlePagesRouterDependencies: true,
  },
};

module.exports = nextConfig;
```

```bash
ANALYZE=true next build
```

This opens an interactive treemap of your bundle in the browser after build.

### @next/bundle-analyzer (older versions)

```bash
npm install --save-dev @next/bundle-analyzer
```

```js
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer({
  // ...your config
});
```

```bash
ANALYZE=true next build
```

---

## Performance Patterns

### 1. App Router + Server Components (primary recommendation)

Server components are rendered on the server and ship zero client-side JS
by default. Use them for anything that does not need interactivity:

```tsx
// app/products/page.tsx — Server Component (no 'use client')
import { getProducts } from '@/lib/db';

export default async function ProductsPage() {
  const products = await getProducts();           // runs on server
  return <ProductList products={products} />;     // static HTML
}
```

```tsx
// app/products/AddToCart.tsx — Client Component
'use client';

import { useState } from 'react';

export function AddToCart({ productId }: { productId: string }) {
  const [added, setAdded] = useState(false);
  // ...
}
```

Keep the `'use client'` boundary as deep as possible to maximize server-rendered surface area.

### 2. Dynamic Imports for Code Splitting

```tsx
import dynamic from 'next/dynamic';

// Loaded only when the component mounts on the client
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <p>Loading chart…</p>,
  ssr: false,    // skip server render for browser-only libs
});
```

### 3. Image Optimization

```tsx
import Image from 'next/image';

// next/image handles resizing, WebP conversion, and lazy loading
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority               // preload above-the-fold images
  placeholder="blur"
  blurDataURL="..."
/>
```

### 4. Font Optimization

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

export default function RootLayout({ children }) {
  return (
    <html className={inter.variable}>
      <body>{children}</body>
    </html>
  );
}
```

`next/font` self-hosts Google Fonts at build time — no runtime network request.

### 5. Route-Level Caching

```tsx
// Static: cached indefinitely (ISR revalidates on schedule)
export const revalidate = 3600;   // revalidate every 1 hour

// Dynamic: never cached
export const dynamic = 'force-dynamic';

// Per-fetch caching
const data = await fetch('/api/data', {
  next: { revalidate: 60 },   // cache for 60 seconds
});
```

---

## Debugging Slow Dev

### Checklist

1. **Confirm Turbopack is active** — `next dev` output should say `⚡ Turbopack`.
2. **Check cache state** — If a recent dependency change caused issues, `rm -rf .next/cache/turbopack` and restart.
3. **Profile module graph** — Large `node_modules` included in the client bundle are the most common cause of slow HMR. Use the Bundle Analyzer to identify heavy deps.
4. **Avoid barrel files** — `index.ts` files that re-export everything force the bundler to process the entire module tree. Import directly: `import { Button } from '@/components/ui/Button'` not `@/components/ui`.
5. **Check for memory pressure** — Turbopack keeps the incremental graph in memory. On machines with <16GB RAM, Node.js may hit the heap limit. Set `NODE_OPTIONS=--max-old-space-size=8192` if needed.

### Measuring HMR Latency

Next.js Dev Tools (browser extension) shows per-component HMR latency.
Alternatively, check the terminal output — Turbopack logs `✓ Compiled /page in Xms`.

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Clearing `.next` cache on every restart | Defeats incremental rebuild | Only clear on suspected stale cache |
| Putting everything in Client Components | Bloats client bundle | Default to Server Components; use `'use client'` only where needed |
| Barrel files (`index.ts` re-exporting 50 things) | Forces full tree processing on any change | Import directly from source files |
| Using webpack-specific loader config for Turbopack | Config silently ignored | Use `turbopack.rules` in `next.config.js` |
| Importing large libraries client-side | Large initial bundle | Use `dynamic()` with `ssr: false` for heavy browser-only libs |
| No `priority` on LCP image | Poor Core Web Vitals | Add `priority` prop to the largest above-the-fold image |

---

## Upgrade Path

When upgrading from an older Next.js version:

```bash
# Check current version
node -e "console.log(require('./node_modules/next/package.json').version)"

# Upgrade
npm install next@latest react@latest react-dom@latest

# After upgrade: test dev startup
next dev

# If you see bundler errors, try webpack fallback first to isolate
next dev --webpack
```

Common breaking changes between major versions are listed in the official
[Next.js upgrade guide](https://nextjs.org/docs/app/guides/upgrading). Review
the migration guide for any major version bump before upgrading production.

---

## Best Practices

- Stay on a recent Next.js 16.x patch for stable Turbopack caching behavior.
- Default to App Router and Server Components for new routes.
- Use `next/image`, `next/font`, and `next/link` — they encode framework-level
  optimizations that manual implementations miss.
- Run `next build && next start` in CI to catch production-only issues not
  caught by `next dev`.
- Pin your Node.js version in `.tool-versions` or `.nvmrc` — Next.js has
  minimum Node version requirements that change across majors.
- Analyze bundle size before shipping a new large dependency to production.
