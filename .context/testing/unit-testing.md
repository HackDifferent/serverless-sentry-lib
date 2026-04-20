# Unit Testing

## Framework Stack

| Tool | Version | Role |
|------|---------|------|
| Mocha | ^10.0.0 | Test runner |
| Chai | ^4.2.0 | Assertions |
| chai-as-promised | ^7.1.1 | Async/Promise assertions |
| sinon | ^14.0.0 | Stubs, spies, sandboxes |
| sinon-chai | ^3.5.0 | Sinon matchers for Chai |
| proxyquire | ^2.1.3 | Module dependency injection |

## Running Tests

```bash
npm test
# runs: mocha src/*.test.ts --require ts-node/register
```

Tests run directly from TypeScript source via `ts-node`. No compilation step needed for tests.

## Test File Location

All tests are in `src/` alongside source: `src/index.test.ts`

## Mock Architecture

Because `@sentry/node` is a peer dependency loaded via `require`, the test file uses `proxyquire` to inject a mock Sentry object at module load time:

```typescript
const withSentry = proxyquire("./index", {
  "@sentry/node": mockSentry,
});
```

The `mockSentry` object is a full stub of the Sentry API surface:

```typescript
const mockSentry: typeof Sentry = {
  init: sandbox.stub(),
  addBreadcrumb: sandbox.stub(),
  captureMessage: sandbox.spy((message: string) => ""),
  captureException: sandbox.spy((exception: any) => ""),
  configureScope: sandbox.spy((fn) => { fn(mockScope as any); }),
  withScope: sandbox.spy((fn) => { fn(mockScope as any); }),
  flush: sandbox.spy(() => Promise.resolve(true)),
  close: sandbox.spy(() => Promise.resolve(true)),
  // ...
} as any;
```

## Sandbox Pattern

A single sinon sandbox is created at module level and reset between tests:

```typescript
const sandbox = sinon.createSandbox();

afterEach(() => {
  sandbox.resetHistory();  // resets call counts without restoring stubs
});
```

Note: `resetHistory()` is used (not `restore()`), so stubs remain in place between tests.

## Assertion Style

Chai `expect` with `chai-as-promised` and `sinon-chai`:

```typescript
const expect = chai.expect;
chai.use(chaiAsPromised);
chai.use(sinonChai);

// Sync
expect(err).to.be.an("error").with.property("message", "Test Error");
expect(mockSentry.init).to.be.calledOnce;
expect(mockSentry.captureException).to.not.be.called;

// Async (Promise)
return expect(handler(mockEvent, mockContext, sinon.stub()))
  .to.eventually.be.fulfilled
  .then((result) => {
    expect(result).to.have.property("message").that.is.a("string");
  });

// Rejection
return expect(handler(mockEvent, mockContext, sinon.stub()))
  .to.eventually.be.rejectedWith("Test Error");
```

## Test Structure

Tests are organized with nested `describe` blocks:

```
describe("withSentry", () => {
  describe("Sentry DSN not set", () => {
    describe("Callbacks", () => { ... })
    describe("Async/Await (Promises)", () => { ... })
  })
  describe("Sentry DSN set", () => { ... })
  describe("Custom Sentry Instance", () => { ... })
  describe("Custom Settings", () => {
    describe("autoBreadcrumbs", () => { ... })
    describe("filterLocal", () => { ... })
    describe("scope", () => { ... })
    describe("captureErrors", () => { ... })
    describe("captureUnhandledRejections", () => { ... })
    describe("captureUncaughtException", () => { ... })
    describe("captureMemory", () => { ... })  // xit — skipped
    describe("captureTimeouts", () => { ... })
  })
})
```

## Mock Lambda Context

```typescript
const mockContext: Context = {
  getRemainingTimeInMillis: () => 6 * 1000,
  memoryLimitInMB: "1024",
  functionName: "test-function",
  // ... standard AWS Lambda context fields
};
```

## Common Import Block

```typescript
import * as Sentry from "@sentry/node";
import { Callback, Context, Handler } from "aws-lambda";
import * as chai from "chai";
import * as chaiAsPromised from "chai-as-promised";
import * as proxyquire from "proxyquire";
import Sinon, * as sinon from "sinon";
import { match } from "sinon";
import * as sinonChai from "sinon-chai";
import { WithSentryOptions } from ".";
```

## What Is Not Tested

- Memory capture (`captureMemory`) — skipped with `xit`, marked TODO
- The `parseBoolean` utility (internal, tested implicitly via env var overrides)
