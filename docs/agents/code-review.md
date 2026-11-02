# Code Review Workflow & Output Archive

Guidelines for conducting code reviews and archiving review artifacts in this repository.

## Session Isolation

Never run `/code-review` in an active implementation session. Implementation sessions accumulate context, biases, and conversational state. Code reviews must always run in an isolated, dedicated session with fresh context.

## Two-Axis Review

Every review evaluates changes along two independent axes:
- **Standards:** Conformance to documented repo standards (`CONSTRAINTS.md`, `AGENTS.md`, `GLOSSARY.md`, `docs/architecture.md`, ADRs) and the Fowler smell baseline.
- **Spec:** Conformance to the originating issue or local task specification (missing requirements, scope creep, implementation mismatches).

## Automatic Artifact Persistence

Whenever a code review is completed, the reviewing agent must automatically save the complete report as a Markdown (`.md`) file in the code review directory:

1. **Target Directory:**
   - Dedicated review directory: `.scratch/code-reviews/`
   - Alternatively, when reviewing a designated local task: `.scratch/BT-N-<slug>/`
2. **File Naming Convention:**
   - For pull requests: `.scratch/code-reviews/pr-<PR_NUMBER>-review.md` (e.g. `.scratch/code-reviews/pr-20-review.md`)
   - For branches or commits: `.scratch/code-reviews/<branch-or-commit>-review.md`
   - For task-specific violation reports: `.scratch/BT-N-<slug>/code-review-violations.md`
3. **Report Structure:**
   - Metadata header: Target PR/branch/commit, tracking issue/task, timestamp.
   - `## Standards`: (a) Documented standards violations; (b) Baseline smells.
   - `## Spec`: (a) Requirements missing/partial; (b) Scope creep; (c) Incorrect implementations.
   - Summary: Finding counts and worst issues per axis.
