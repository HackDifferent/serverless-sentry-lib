# Architecture Overview

> **Note:** This documentation serves both **human developers** and **AI agents**.

## What This System Does

`serverless-sentry-lib` is a small TypeScript library (v2.5.2) that wraps AWS Lambda function handlers with Sentry error monitoring. It provides a single higher-order function (`withSentry`) that automatically captures errors, unhandled promise rejections, uncaught exceptions, memory warnings, and timeout warnings — and reports them to Sentry.

It is the runtime companion to the [serverless-sentry-plugin](https://github.com/arabold/serverless-sentry-plugin) (the Serverless Framework deployment plugin), but can be used independently.

## Core Business Concept

The library wraps a Lambda handler at invocation time:

```
withSentry([options | SentryInstance,] handler) → wrappedHandler
```

The wrapped handler:
1. Initializes Sentry (unless a custom instance is passed)
2. Configures scope with Lambda context tags/extras/user info
3. Installs watchdog timers for memory and timeout
4. Registers unhandledRejection and uncaughtException listeners
5. Invokes the original handler (callback-based or Promise-based)
6. Captures any thrown errors
7. Flushes Sentry before returning

## Module Structure

This is a single-file library — all logic lives in `src/index.ts`.

```
src/
└── index.ts          # All library logic and type exports
dist/
├── index.js          # Compiled output (CommonJS, ES5)
└── index.d.ts        # TypeScript declarations
```

## Entry Points

- **Library consumers**: import `withSentry` from `dist/index.js` (or via npm package)
- **Development**: `src/index.ts` is the single source of truth
- **Tests**: `src/index.test.ts`

## Key External Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `@sentry/node` | >=5 (peer) | Sentry SDK — error capturing, scope management |
| `@sentry/integrations` | >=5 (peer) | `RewriteFrames` integration for source map support |
| `aws-lambda` | ^8.10.61 (dev) | TypeScript types for `Context`, `Callback`, `Handler` |

Both Sentry packages are **peer dependencies** — the consuming Lambda project must install them. The library does not bundle Sentry.

## Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Language | TypeScript | ^4.0.2 |
| Target | ES5, CommonJS | — |
| Runtime | Node.js | >=12.0.0 |
| Test runner | Mocha | ^10.0.0 |
| Test utilities | Chai, Sinon, proxyquire | ^4, ^14, ^2 |
| Linter | ESLint + @typescript-eslint | ^8, ^5 |
| Formatter | Prettier | ^2 |
| Git hooks | Husky + lint-staged | ^8, ^13 |

## Deployment

This is a **published npm package** (`serverless-sentry-lib`). It is not deployed as a Lambda itself. The workflow is:

1. `npm run build` — compiles TypeScript to `dist/`
2. `npm version [patch|minor|major]` — bumps version, runs tests + lint + build, commits and pushes
3. `npm publish` — publishes `dist/`, `package.json`, `README.md`

## AI Agent Delegation Model

See `workflows/task-workflow-template.md` for the full 8-phase workflow. For this tiny repo, most tasks will be:
1. **Research** (if Sentry SDK API changes are involved)
2. **Implementation** in `src/index.ts`
3. **Testing** in `src/index.test.ts`
