# META - .context Directory Maintenance Guide

## Purpose

This document explains when and how to update `.context/` documentation. The goal is a living knowledge base that captures what AI agents and developers need to know beyond what's obvious from the code itself.

## Separation of Concerns

`.github/copilot-instructions.md` and `.context/` serve different roles — avoid duplicating content between them.

| | `copilot-instructions.md` | `.context/` |
|---|---|---|
| **Scope** | Big picture | Detailed, area-specific |
| **Content** | Project overview, tech stack, key commands, high-level conventions | Domain models, architectural patterns, coding standards, testing strategies |
| **Size** | Short (one file, quick to scan) | Structured (many files, read as needed) |
| **Example** | "We use Angular 18 with NGXS for state management" | Detailed NGXS action/state patterns with code examples |
| **Example** | "This app handles loan servicing and payment processing" | Detailed domain docs: `domains/payments.md`, `domains/loans.md`, `domains/state-management.md` |

When updating documentation, ask: is this a project-wide fact or convention? → `copilot-instructions.md`. Is this detailed guidance for a specific area? → `.context/`.

## When to Update

Update documentation when:

1. **New patterns emerge**: A pattern used successfully 3+ times should be documented in `standards/` or `architecture/` with real code examples and guidance on when to use it.
2. **Standards evolve**: Team agrees on new conventions. Update the relevant file in `standards/`, mark old conventions as deprecated, and provide migration examples.
3. **Architecture changes**: Major refactoring or technology changes. Create or update migration guides in `architecture/` with before/after states and step-by-step migration paths.
4. **Lessons learned**: Retrospective identifies reusable insights. Promote from `retrospectives.md` to the appropriate subdirectory. See the [Retrospective Mechanism](#retrospective-mechanism) section.
5. **AI agents make repeated mistakes**: Clarify the problematic area with explicit examples. Add "do this / not this" guidance to the relevant file.
6. **Onboarding friction**: New developers or agents struggle with a concept. Expand explanations, add FAQ sections, and include more examples.
7. **Working in an undocumented domain area**: When code touches a domain not yet covered in `domains/`, create a file for that domain. This includes business domains (e.g., `payments.md`, `loans.md`) covering entities, business rules, and terminology, as well as technical domains (e.g., `routing.md`, `state-management.md`, `lifecycle.md`) covering system patterns, conventions, and integration points.

## What to Document

**Document (high value):**
- Non-obvious patterns that aren't clear from code alone
- The "why" behind architectural decisions (rationale and trade-offs)
- Common pitfalls with solutions
- Real examples with file paths (e.g., "see `src/features/auth/login.component.ts` lines 45-67")
- Migration paths between old and new patterns

**Skip (low value):**
- Language basics and standard features
- Content already in official framework documentation
- Patterns obvious from reading the code
- Duplicated content — link to the single source of truth instead

## Retrospective Mechanism

The retrospective system ensures lessons outlive individual tasks:

1. **At task completion**, the manager conducts a lightweight retrospective (see task-workflow-template Phase 8).
2. **Lessons are logged** in `retrospectives.md` as a rolling log (last 10-15 entries).
3. **Lessons are promoted** to the appropriate subdirectory:
   - Coding patterns → `standards/`
   - Testing insights → `testing/`
   - Architecture decisions → `architecture/`
   - Domain clarifications → `domains/`
4. **The rolling log** gives agents a quick-reference of recent lessons without reading every subdirectory.

## Directory Structure

```
.context/
├── META.md              # This file — maintenance guide
├── overview.md          # Project overview, tech stack, key concepts
├── decisions.md         # Key project-wide decisions and rationale
├── retrospectives.md    # Rolling log of lessons learned (last 10-15)
├── architecture/        # System design, module structure, patterns
├── cache/               # Research reference documents cached by @researcher (3-day TTL, named <topic>-<YYYY-MM-DD>.md)
├── domains/             # Domain docs: business (payments, loans) and technical (routing, state-management)
├── standards/           # Coding conventions, style, error handling
├── styling/             # UI/CSS conventions (if applicable)
├── testing/             # Test patterns, mocking strategies, coverage
├── tasks/               # Ephemeral task execution plans (prunable)
└── workflows/           # Persistent process docs: CI/CD, branching, deployment
```

**tasks/ vs workflows/**: Tasks are ephemeral (per-task execution plans, pruned after ~3 months). Workflows are persistent (CI/CD processes, branching strategies, deployment procedures).

## Quality Standards

Documentation should be: **accurate** (correct and current), **specific** (concrete guidance, not vague), **example-driven** (real code and file paths), **contextual** (explains why, not just what), and **non-duplicated** (single source of truth, link elsewhere).

## Maintenance

**After major tasks**: Review and update documentation affected by the work. Promote lessons from `retrospectives.md`. Mark deprecated patterns.

**Periodically**: Read through `.context/` files. Remove outdated content. Consolidate duplicates. Verify code examples still work and file paths still exist.

**Warning signs that docs need attention**: Developers or agents ask questions already answered in docs. New patterns go undocumented. Examples reference non-existent files. Agents make the same mistakes repeatedly.

## Context Recovery

When an AI agent's context window compacts mid-task:
1. Re-read `.github/copilot-instructions.md` (always)
2. Re-read `.context/` files relevant to the current task
3. Review the task document for status, decisions, and next steps
4. Resume from the documented progress point

This protocol is also documented in the task-workflow-template.

---

*This file should be reviewed when the `.context/` structure changes.*
