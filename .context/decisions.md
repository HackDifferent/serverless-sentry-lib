# Architecture Decision Records (ADRs)

## ADR-001: TypeScript compiled to ES5/CommonJS

**Date**: ~2020 (v2.0.0 rewrite)
**Status**: Accepted

### Context
The library needs maximum compatibility across Lambda runtimes (Node.js 12+) including runtimes that don't support ES modules natively.

### Decision
Compile to ES5 with `"module": "commonjs"` targeting `dist/`. This ensures the package works in any Node.js Lambda runtime without transpilation by consumers.

### Consequences
- `dist/index.js` is the published artifact (CommonJS, ES5 compat)
- Consumers can `require()` or `import` via interop
- `module.exports = withSentry` and `module.exports.default = withSentry` both set for CJS/ESM interop

---

## ADR-002: Peer Dependencies for Sentry Packages

**Date**: v2.5.1 (2022)
**Status**: Accepted

### Context
Prior to v2.5.1, `@sentry/integrations` was bundled as a direct dependency. This caused version conflicts when consumers also imported Sentry.

### Decision
Both `@sentry/node` and `@sentry/integrations` are peer dependencies. The consumer's Lambda project owns the Sentry version.

### Consequences
- Consumers must install Sentry packages themselves
- The library adapts to whichever Sentry version (>=5) the consumer uses
- No version lock conflicts
- **Breaking**: consumers upgrading from <2.5.1 must add `@sentry/integrations` to their own `package.json` if they use `sourceMaps: true`

---

## ADR-003: No bundled Sentry initialization — consumer controls DSN

**Date**: v2.0.0 rewrite
**Status**: Accepted

### Context
Different Lambda functions in the same project may want different Sentry configurations, or consumers may pre-initialize Sentry themselves.

### Decision
`withSentry` accepts three call signatures:
1. `withSentry(handler)` — auto-init from env vars
2. `withSentry(options, handler)` — auto-init with custom options
3. `withSentry(sentryInstance, handler)` — pass pre-initialized Sentry

### Consequences
- `SENTRY_DSN` env var is the primary configuration mechanism for auto-init
- When `filterLocal: true` (default), Sentry is disabled if `IS_OFFLINE`, `IS_LOCAL`, or no `LAMBDA_TASK_ROOT`
- A null `sentryClient` results in a simple pass-through (no overhead)

---

## ADR-004: `flush()` over `close()` for cleanup

**Date**: v2.1.0
**Status**: Accepted

### Context
Lambda instances are reused (warm starts). Calling `Sentry.close()` would destroy the Sentry client and break subsequent invocations.

### Decision
Use `Sentry.flush(flushTimeout)` at the end of each invocation rather than `close()`. This sends buffered events without tearing down the client.

### Consequences
- Sentry remains usable across warm-start invocations
- The consumer controls flush timeout via `flushTimeout` option (defaults to `sentryOptions.shutdownTimeout ?? 2000ms`)

---

## ADR-005: Module-level timer state (not per-invocation)

**Date**: v2.0.0
**Status**: Accepted (known limitation)

### Context
Timer handles (`memoryWatchTimer`, `timeoutWarningTimer`, `timeoutErrorTimer`) are module-level variables.

### Decision
Accept this as a trade-off — Lambda instances handle one request at a time, so concurrent invocation timer state is not a concern.

### Consequences
- `clearTimers()` is called in `finalize()` to clean up before next invocation
- On warm starts, the module-level vars are reused safely because Lambda doesn't parallelize invocations per instance

---

## Technical Debt

- The `captureMemoryWarnings` and `captureTimeoutWarnings` options are deprecated but still supported with console warnings. Remove in a future major version.
- `src/index.test.ts` has a skipped test (`xit`) for memory capture — that test path remains untested.
- ESLint disable comments at the top of both source files indicate some type-safety compromises in the test mocking layer.
