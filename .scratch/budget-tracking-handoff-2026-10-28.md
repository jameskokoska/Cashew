# Handoff: Budget Tracking (Cashew Fork)

**Date:** 2026-10-28  
**Current Branch:** `feat/dedupe-ledger` (synced with `origin/feat/dedupe-ledger`)  
**Target Repository:** `kidomarcostelo/budget-tracking`

---

## 1. Executive Summary & Session Accomplishments

1. **State Orientation (/ask-matt)**:
   - Evaluated repository status, git branches, PRs, and `.scratch/` tasks.
   - Identified that PR [#20](https://github.com/kidomarcostelo/budget-tracking/pull/20) (`feat(notifications): add dedupe ledger and duplicate suppression (#7)`) is open on branch `feat/dedupe-ledger`.
2. **CI Quality Gate Analysis**:
   - Analyzed failed GitHub Actions CI run `39794470162` (`CI Quality Gate` / `Lint, Format, and Test`).
   - The failure was caused by code formatting discrepancies (`dart format --output=none --set-exit-if-changed .`) across four files:
     - `budget/lib/database/schema_versions.dart`
     - `budget/lib/database/tables.dart`
     - `budget/lib/database/tables.g.dart`
     - `budget/test/dedupe_ledger_test.dart`
3. **Workspace Transfer Preparedness**:
   - Local branch `feat/dedupe-ledger` is completely pushed to remote `origin/feat/dedupe-ledger`.
   - Updated task specifications in `.scratch/BT-3-extend-auto-transactions-google-pay/task.md` with CI roadblock and exact resume instructions.

---

## 2. Immediate Next Steps in Target Workspace

When resuming in the target workspace:

1. **Fix Formatting on PR #20**:
   - Ensure Flutter/Dart SDK is available.
   - Run from `budget/`:
     ```bash
     cd budget
     dart format .
     git add -u
     git commit -m "style: format schema and dedupe ledger files"
     git push origin feat/dedupe-ledger
     ```
   - Verify CI Quality Gate passes on GitHub Actions.
2. **Perform Code Review**:
   - Per `AGENTS.md`, start a fresh, isolated session and run `/code-review` on PR [#20](https://github.com/kidomarcostelo/budget-tracking/pull/20).
   - Await human review / go-signal and merge PR #20 into `main`.
3. **Next Implementation Slice (S4)**:
   - Check out `main` and branch `feat/uncertain-match-review`.
   - Implement S4 ("Review route for uncertain matches" - show possible duplicate prompt rather than silent creation when an ambiguous match is detected).
   - Use `/tdd` test-first slices.

---

## 3. Key Repositories & Reference Links

- **Active PR #20**: [kidomarcostelo/budget-tracking#20](https://github.com/kidomarcostelo/budget-tracking/pull/20)
- **Active Issue #7**: [kidomarcostelo/budget-tracking#7](https://github.com/kidomarcostelo/budget-tracking/issues/7)
- **Task Specification**: [`.scratch/BT-3-extend-auto-transactions-google-pay/task.md`](BT-3-extend-auto-transactions-google-pay/task.md)
- **Research Document**: [`.scratch/BT-3-extend-auto-transactions-google-pay/research.md`](BT-3-extend-auto-transactions-google-pay/research.md)
- **Local Task Index**: [`.scratch/index.md`](index.md)

---

## 4. Suggested Skills for Next Agent

1. **`/code-review`**:
   - Run in an isolated session on PR [#20](https://github.com/kidomarcostelo/budget-tracking/pull/20) against `main`.
2. **`/tdd`**:
   - Build S4 (review flow for ambiguous duplicates) test-first.
3. **`/pr`**:
   - Structure pull requests with before/after evidence and two-axis quality checks.

---

## 5. Non-Negotiable Constraints & Guardrails (`AGENTS.md`)

- **Strict PR Workflow**: Never push directly to `main`. Work on feature branches and create PRs.
- **Separate Session for Code Review**: Do not run `/code-review` in the same implementation session.
- **Drift Migrations**: NEVER edit past migration steps in `budget/lib/database/schema_versions.dart` or `budget/drift_schemas/`. Always create additive steps.
- **No Commit Trailers**: Do not add `Co-authored-by` or AI attribution trailers in commit messages.
- **Local-First Privacy**: All parsing, ledger checks, and matching run 100% on-device.
