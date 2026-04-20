# Domain: withSentry Wrapper

## Overview

`withSentry` is the sole public API of this library. It wraps any AWS Lambda handler and instruments it with Sentry monitoring. All logic lives in `src/index.ts`.

## Public API

### Exported Types

| Type | Purpose |
|------|---------|
| `Handler<TEvent, TResult>` | Re-export of the AWS Lambda handler signature |
| `WithSentryOptions` | Configuration object for the wrapper |
| `CaptureMemoryOptions` | `{ enabled, interval? }` — memory monitoring config |
| `CaptureTimeoutOptions` | `{ enabled, timeRemainingWarning?, timeRemainingError? }` — timeout monitoring config |

### `WithSentryOptions` Fields

| Field | Type | Default | Source |
|-------|------|---------|--------|
| `sentry` | `typeof SentryLib` | auto-init | — |
| `sentryOptions` | `SentryLib.NodeOptions` | `{}` | — |
| `scope` | `{ tags, extras, user }` | `{}` | — |
| `filterLocal` | `boolean` | `true` | `SENTRY_FILTER_LOCAL` |
| `sourceMaps` | `boolean` | `false` | `SENTRY_SOURCEMAPS` |
| `flushTimeout` | `number` (ms) | `sentryOptions.shutdownTimeout ?? 2000` | — |
| `autoBreadcrumbs` | `boolean` | `true` | `SENTRY_AUTO_BREADCRUMBS` |
| `captureErrors` | `boolean` | `true` | `SENTRY_CAPTURE_ERRORS` |
| `captureUnhandledRejections` | `boolean` | `true` | `SENTRY_CAPTURE_UNHANDLED` |
| `captureUncaughtException` | `boolean` | `true` | `SENTRY_CAPTURE_UNCAUGHT` |
| `captureMemory` | `boolean \| CaptureMemoryOptions` | `true` | `SENTRY_CAPTURE_MEMORY` |
| `captureTimeouts` | `boolean \| CaptureTimeoutOptions` | `true` | `SENTRY_CAPTURE_TIMEOUTS` |

## Invocation Lifecycle

```
1. withSentry() called → resolve args, build options, call initSentry()
                         └─ if local env or no DSN → return undefined (pass-through)
                         └─ otherwise → Sentry.init(), return sentryClient

2. Lambda invoked → wrappedHandler(event, context, callback)
   a. if sentryClient is null → pass-through to original handler, return

   b. configureScope()
      - scope.clear() (warm start isolation)
      - setUser (Cognito identity from event.requestContext.identity or context.identity)
      - setExtras ({ Event, Context })
      - setTags (lambda, version, memory_size, log_group, log_stream, region, ...)

   c. installTimers() — start watchdog timers

   d. captureUnhandledRejections: replace process 'unhandledRejection' listeners
   e. captureUncaughtException: replace process 'uncaughtException' listeners

   f. autoBreadcrumbs: addBreadcrumb({ category: "lambda", message: functionName })

   g. invoke original handler
      → callback path: wrap callback → on error, captureException → finalize()
      → promise path: await → on rejection, captureException → finalize()

3. finalize()
   - clearTimers()
   - remove unhandledRejection listener
   - remove uncaughtException listener
   - sentryClient.flush(flushTimeout)
```

## Key Code Paths

| Task | Entry Point | Location |
|------|------------|---------|
| Initialize Sentry | `initSentry(options)` | `src/index.ts:138` |
| Start timers | `installTimers(sentryClient, options, context)` | `src/index.ts:217` |
| Clear timers | `clearTimers()` | `src/index.ts:309` |
| Main HOF | `withSentry(arg1, arg2?)` | `src/index.ts:357` |
| Arg dispatch | Type checks | `src/index.ts:367-381` |
| Options merging | Spread with env-var defaults | `src/index.ts:383-396` |
| Scope configuration | `configureScope` call | `src/index.ts:469-477` |
| Callback wrapping | `handler(event, context, wrappedCallback)` | `src/index.ts:562-571` |
| Promise wrapping | `resolveResponseAsync()` | `src/index.ts:575-591` |

## Business Rules

1. **Local filtering**: Sentry is disabled if `IS_OFFLINE=true`, `IS_LOCAL=true`, or `LAMBDA_TASK_ROOT` is unset — when `filterLocal: true` (default). This prevents noise from local Serverless offline runs.

2. **No DSN = no-op**: If neither `SENTRY_DSN` nor `sentryOptions.dsn` is set, Sentry is disabled and the wrapper is a pass-through.

3. **Scope clear on warm start**: When the library owns the Sentry instance, `scope.clear()` runs on every invocation to prevent cross-invocation tag/user leakage.

4. **Source map rewriting**: When `sourceMaps: true`, a `RewriteFrames` integration is injected to rewrite stack frame filenames from absolute paths to `app:///filename.js`. Only added if not already present.

5. **Deprecated options backward-compat**: `captureMemoryWarnings` → `captureMemory`, `captureTimeoutWarnings` → `captureTimeouts`. Warns to console and bridges to new options.

## Gotchas

- **Timer state is module-level**: `memoryWatchTimer`, `timeoutWarningTimer`, `timeoutErrorTimer` are module globals. This is safe because Lambda instances handle one invocation at a time, but means the timers from a previous invocation persist until `clearTimers()` is called at the start of `finalize()`.

- **`flush()` not `close()`**: `Sentry.flush()` is used deliberately — `close()` would destroy the client and break warm invocations.

- **Callback detection**: The wrapper sets `callbackCalled = true` inside the wrapped callback to distinguish between callback-style and promise-style handlers. If the handler invokes the callback AND returns a promise (unusual), the callback path wins.

- **Custom Sentry instance skips `scope.clear()`**: When the consumer passes a pre-initialized Sentry, scope is NOT cleared. The consumer owns scope lifecycle.
