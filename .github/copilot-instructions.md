# serverless-sentry-lib

## Project Overview

A TypeScript npm library (v2.5.2) that wraps AWS Lambda handlers with automatic Sentry error monitoring. Exports a single higher-order function `withSentry` that instruments any Lambda handler — capturing errors, promise rejections, uncaught exceptions, memory warnings, and timeout warnings.

Used as a runtime companion to the `serverless-sentry-plugin` Serverless Framework plugin, but works independently.

## Tech Stack

- **Language**: TypeScript ^4 → compiled to ES5/CommonJS
- **Runtime**: Node.js >=12
- **Test framework**: Mocha + Chai + Sinon + proxyquire
- **Linter/formatter**: ESLint + Prettier (config in `package.json`)
- **Peer dependencies**: `@sentry/node >=5`, `@sentry/integrations >=5`

## Key Commands

```bash
npm test              # run tests (mocha via ts-node)
npm run build         # compile TypeScript → dist/
npm run lint          # type-check + eslint
npm version patch     # bump version, run tests + lint + build, push
```

## Project Structure

```
src/
├── index.ts          # ALL library logic — single source file
└── index.test.ts     # All tests
dist/                 # Compiled output (don't edit)
```

## Key Conventions

- All logic lives in `src/index.ts` — no submodules
- Sentry packages are **peer dependencies** — consumers install them
- Prettier: 2-space indent, 120-char lines, double quotes, semicolons, trailing commas
- Tests use `proxyquire` to inject mock Sentry at module load time
- Use `flush()` not `close()` when finishing with Sentry (warm-start safety)
- Integration branch: `master`
- Commit style: plain descriptive, no ticket prefix required

## Detailed Documentation

See `.context/` for deep documentation:
- `overview.md` — architecture, lifecycle, tech stack
- `domains/with-sentry.md` — full API, lifecycle steps, business rules, gotchas
- `standards/code-style.md` — Prettier/ESLint rules, logging, null handling
- `testing/unit-testing.md` — Mocha/Chai/Sinon patterns, mock architecture
- `decisions.md` — why ES5/CommonJS, why peer deps, why flush not close
