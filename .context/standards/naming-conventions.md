# Naming Conventions

## File Naming

| File | Convention | Example |
|------|-----------|---------|
| Library source | `index.ts` | `src/index.ts` |
| Test file | `[name].test.ts` | `src/index.test.ts` |
| Compiled output | `index.js`, `index.d.ts` | `dist/index.js` |
| TypeScript config | `tsconfig[.purpose].json` | `tsconfig.json`, `tsconfig.release.json` |

## Function and Type Naming

| Item | Convention | Example |
|------|-----------|---------|
| Exported HOF | `camelCase` | `withSentry` |
| Internal functions | `camelCase` | `initSentry`, `installTimers`, `clearTimers` |
| Type aliases | `PascalCase` | `WithSentryOptions`, `CaptureMemoryOptions` |
| Type parameters | single uppercase letter or descriptive `T` prefix | `TEvent`, `TResult` |
| Module-level timers | `camelCase` + `Timer` suffix | `memoryWatchTimer`, `timeoutWarningTimer` |
| Listener functions | `camelCase` + `Listener` or `Func` suffix | `unhandledRejectionListener`, `timeoutWarningFunc` |

## Environment Variables

All Sentry-related env vars use `SENTRY_` prefix:

| Variable | Purpose |
|----------|---------|
| `SENTRY_DSN` | Sentry data source name |
| `SENTRY_RELEASE` | Release version tag |
| `SENTRY_ENVIRONMENT` | Environment name (e.g. `production`) |
| `SENTRY_CAPTURE_ERRORS` | Override `captureErrors` option |
| `SENTRY_CAPTURE_UNHANDLED` | Override `captureUnhandledRejections` |
| `SENTRY_CAPTURE_UNCAUGHT` | Override `captureUncaughtException` |
| `SENTRY_CAPTURE_MEMORY` | Override `captureMemory` |
| `SENTRY_CAPTURE_TIMEOUTS` | Override `captureTimeouts` |
| `SENTRY_AUTO_BREADCRUMBS` | Override `autoBreadcrumbs` |
| `SENTRY_FILTER_LOCAL` | Override `filterLocal` |
| `SENTRY_SOURCEMAPS` | Override `sourceMaps` |

AWS Lambda built-in env vars used:
- `AWS_LAMBDA_FUNCTION_NAME`, `AWS_LAMBDA_FUNCTION_VERSION`, `AWS_LAMBDA_FUNCTION_MEMORY_SIZE`
- `AWS_LAMBDA_LOG_GROUP_NAME`, `AWS_LAMBDA_LOG_STREAM_NAME`
- `AWS_REGION`, `LAMBDA_TASK_ROOT`

Serverless Framework env vars (optional):
- `SERVERLESS_REGION`, `SERVERLESS_SERVICE`, `SERVERLESS_STAGE`, `SERVERLESS_ALIAS`

Local detection vars:
- `IS_OFFLINE` (serverless-offline plugin), `IS_LOCAL`

## Sentry Scope Tags

Tags set on every invocation (in `additionalScope.tags`):
`lambda`, `version`, `memory_size`, `log_group`, `log_stream`, `region`

Optional tags: `service_name`, `stage`, `alias`, `api_id`, `api_stage`, `http_method`
