# Code Style

## Enforced by Tooling

Prettier + ESLint run on commit via lint-staged (configured in `package.json`).

Config lives entirely in `package.json` (no `.eslintrc` or `.prettierrc` files).

### Prettier Settings (from `package.json`)

```json
{
  "printWidth": 120,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": false,
  "quoteProps": "as-needed",
  "trailingComma": "all",
  "bracketSpacing": true,
  "arrowParens": "always"
}
```

Key rules:
- **2-space indent, no tabs**
- **120-char line width**
- **Double quotes** for strings
- **Semicolons required**
- **Trailing commas everywhere** (including function params)
- **Always parenthesize arrow function args**: `(x) => x`, never `x => x`

### Import Sorting

`prettier-plugin-import-sort` with `import-sort-style-module` style sorts imports automatically. Result: Node built-ins first, then external packages alphabetically, then local imports.

Example from `src/index.ts`:
```typescript
import path from "path";

import { RewriteFrames } from "@sentry/integrations";
import * as SentryLib from "@sentry/node";
import { Callback, Context } from "aws-lambda";
```

### TypeScript Compiler Rules (tsconfig.json)

```json
{
  "noImplicitAny": true,
  "strictNullChecks": true,
  "skipLibCheck": true
}
```

- No implicit `any` — all types must be explicit or inferable
- Strict null checks — `null` and `undefined` are not assignable without explicit union

## Logging

No logging framework — uses `console.warn`, `console.log` for diagnostic output:

```typescript
console.warn("Sentry disabled in local environment.");
console.warn("SENTRY_DSN not set. Sentry is disabled.");
console.log("Sentry initialized.");
```

No structured logging; this is a library, not a service.

## Exception Handling

- Internal init errors are caught and logged as warnings (not thrown): the library degrades gracefully to a pass-through if Sentry can't initialize
- `captureException(err)` captures errors before rethrowing (the original error propagates to Lambda)
- `finalize()` always runs (via `finally`) regardless of success/failure
- Promise rejections in timer callbacks swallow errors with `.catch(null)` to avoid crashing Lambda

## Null / Undefined Handling

- Uses `?? ` (nullish coalescing) extensively for defaults: `flushTimeout ?? 2000`
- Optional chaining `?.` used for safe property access: `options?.sentryOptions?.dsn`
- Ternary + `|| undefined` to coerce empty strings to `undefined`: `identity.cognitoIdentityId || undefined`

## Type Exports

All public types are exported from `src/index.ts`:
- `Handler<TEvent, TResult>`
- `WithSentryOptions`
- `CaptureMemoryOptions`
- `CaptureTimeoutOptions`
