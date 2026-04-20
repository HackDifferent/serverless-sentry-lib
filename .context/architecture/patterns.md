# Architecture Patterns

## Primary Pattern: Higher-Order Function (HOF) Wrapper

The entire library is a single higher-order function that instruments another function.

```
withSentry(handler) → wrappedHandler
```

This is the only pattern in the codebase. There are no controllers, services, repositories, or layers.

## Overloaded Entry Point

`withSentry` has three call signatures resolved via runtime type checks:

```typescript
// 1. Handler only — auto-initialize Sentry from env vars
export function withSentry<TEvent, TResult>(handler: Handler<TEvent, TResult>): Handler<TEvent, TResult>;

// 2. Options + handler — auto-initialize with custom options
export function withSentry<TEvent, TResult>(
  pluginConfig: WithSentryOptions,
  handler: Handler<TEvent, TResult>
): Handler<TEvent, TResult>;

// 3. Sentry instance + handler — use pre-initialized Sentry
export function withSentry<TEvent, TResult>(
  SentryInstance: typeof SentryLib,
  handler: Handler<TEvent, TResult>
): Handler<TEvent, TResult>;
```

Dispatched via `isSentryInstance()` type guard and `typeof` checks at runtime (`src/index.ts:367-381`).

## Dual Handler Support (Callback and Promise)

Lambda handlers can be either callback-based or Promise-based. The wrapper detects which style is used at runtime:

```typescript
const response = handler(event, context, wrappedCallback);

if (!callbackCalled && typeof response === "object" && typeof response.then === "function") {
  // Promise path — await the response, capture errors, then finalize
  return resolveResponseAsync();
} else {
  // Callback path — callback will call finalize() when done
  return response;
}
```

`src/index.ts:573-593`

## Watchdog Timer Pattern

`installTimers()` (`src/index.ts:217`) sets up three non-overlapping timers:

1. **Timeout warning timer** — fires at `remainingTime - timeoutWarningMsec` (default: half of remaining time)
2. **Timeout error timer** — fires at `remainingTime - timeoutErrorMsec` (default: `flushTimeout` before actual timeout)
3. **Memory watchdog** — recursive `setTimeout` polling every `captureMemoryInterval`ms (default 500ms)

All timers are cleared in `clearTimers()` (`src/index.ts:309`) called from `finalize()`.

## Graceful Degradation

If `sentryClient` is null (no DSN set, local env filtered, or init failed), the wrapper becomes a zero-overhead pass-through:

```typescript
if (!sentryClient) {
  return handler(event, context, callback);
}
```

`src/index.ts:415-417`

## Scope Isolation per Invocation

On each warm-start invocation, `scope.clear()` is called before setting new tags/extras/user — preventing data from a previous invocation leaking into the next:

```typescript
sentryClient.configureScope((scope) => {
  if (!customSentryClient) {
    scope.clear(); // only when we own the Sentry instance
  }
  scope.setUser(...);
  scope.setExtras(...);
  scope.setTags(...);
});
```

`src/index.ts:469-477`
