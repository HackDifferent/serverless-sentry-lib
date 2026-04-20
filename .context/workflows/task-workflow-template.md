# Task Workflow Template

## Overview

This workflow defines how agents collaborate on tasks using the manager-of-engineers delegation model. The manager orchestrates work by delegating to specialist agents, tracking progress, and ensuring quality.

## Task Phases

### Phase 1: Initiation

**Goal:** Understand the request and gather context.

1. Read the user request. Identify the goal, constraints, and scope.
2. Gather context from `.context/` documentation and `.github/copilot-instructions.md`.
3. Check `.context/retrospectives.md` for lessons relevant to this type of task.
4. Check domain coverage: if the task touches a domain area (business or technical) not yet documented in `.context/domains/`, plan to document it during or after implementation.
5. Assess complexity:
   - **Simple**: Single component or fix, established patterns
   - **Medium**: Feature with multiple components
   - **Complex**: Module-level changes, migrations, or new patterns
5. **Branch management**: Search for an existing branch containing the task ID. If found, check it out. If not found, create a new branch following the project's existing naming pattern (inspect existing branches to detect convention). Record the branch name in the task document.
6. Create a task document with status, scope, branch, affected modules, and open questions.

**Agent delegation:**
- Complex codebases: delegate to @planner for breakdown
- Architecture questions: consult @architect
- Library/framework questions: delegate to @researcher

### Phase 2: Research (When Needed)

**Goal:** Gather current information before making decisions.

**When to research:** Working with specific libraries/frameworks, upgrading versions, adopting new patterns, integrating external services, resolving deprecation warnings.

**When to skip:** Well-established patterns, information in `.context/`, simple fixes, no external libraries.

Delegate to @researcher with: the specific topic, current and target versions, specific questions, and the decision that depends on the findings. Document key findings for use in later phases.

### Phase 3: Planning

**Goal:** Break down work into sequenced, actionable steps.

Delegate to @planner with: the task description, affected modules, complexity, relevant context, and any research findings. The planner provides ordered implementation steps with file lists, dependencies, and acceptance criteria.

### Phase 4: Architecture Review (When Needed)

**Goal:** Validate structural decisions before implementation.

**When to consult @architect:** New modules, changes to shared components, new dependencies, performance-critical changes, security changes, data flow changes.

**When to skip:** Simple fixes, UI-only changes, following established patterns exactly.

Delegate to @architect with: the proposed change, current architecture context, and specific questions about fit and risk.

### Phase 5: Implementation

**Goal:** Execute the plan.

Delegate steps to @coder with: the step from the plan, files to create/modify, patterns to follow (from `.context/`), research findings if applicable, and specific requirements. Verify each step builds before proceeding.

Track progress in the task document. Note any deviations from the plan and their rationale.

### Phase 6: Testing

**Goal:** Validate the implementation.

Delegate to @tester with: what was implemented, changed files, test requirements from the plan, and specific tests needed. All tests must pass before proceeding to review.

### Phase 7: Review

**Goal:** Quality check before completion.

Delegate to @reviewer with: the feature description, all changed files, and relevant standards from `.context/`. Address all critical and moderate findings before proceeding.

### Phase 8: Completion and Retrospective

**Goal:** Finalize, document, and learn.

1. **Update documentation**: Update relevant `.context/` files if new patterns emerged. If a new domain area was touched, create or update its file in `.context/domains/`. Only update `copilot-instructions.md` for project-wide changes (tech stack, key commands, high-level conventions); detailed area-specific knowledge belongs in `.context/`.

2. **Create completion summary**: Brief description of what was accomplished, files changed, and test results.

3. **Conduct retrospective** (mandatory): Answer these three questions:
   - What mistake or friction did we encounter that we should avoid next time?
   - What pattern or approach worked well that we should repeat?
   - What should be updated in `.context/` based on this experience?

4. **Promote lessons**: For each lesson identified:
   - Add it to `.context/retrospectives.md` (rolling log, keep last 10-15 entries)
   - If it's a coding pattern: update `.context/standards/`
   - If it's a testing insight: update `.context/testing/`
   - If it's an architecture decision: update `.context/architecture/`
   - If it's a domain clarification: update `.context/domains/`

5. **Note follow-up work**: Document any technical debt created or follow-up tasks needed.

---

## Task Document Template

Create this in `.context/tasks/[JIRA-ID-kebab-description]/` for medium and complex tasks:

```markdown
## Task: [JIRA-ID-kebab-description]

**Status:** Planning | In Progress | Testing | Review | Complete
**Complexity:** Simple | Medium | Complex
**Branch:** [branch-name]
**Started:** [date]

### Scope
- Affected modules: [list]
- New files: [estimate]
- Changed files: [estimate]

### Plan
[From @planner output or inline for simple tasks]

### Progress
[Updated as steps complete]

### Decisions
[Key decisions and rationale]

### Retrospective
[Completed in Phase 8]
```

For simple tasks, track inline in the session rather than creating a task folder.

---

## When to Create Task Folders

Create `.context/tasks/[JIRA-ID-kebab-description]/` when:
- Task is complex (multiple modules or phases)
- Involves architectural changes
- Has many decision points
- Will serve as reference for similar future work

Skip task folders for: simple fixes, trivial changes, routine maintenance.

---

## Context Recovery After Compaction

When context is compacted mid-task:
1. Re-read `.github/copilot-instructions.md`
2. Re-read relevant `.context/` files for the current task
3. Review the task document for current status, decisions, and next steps
4. Resume from the documented progress point
