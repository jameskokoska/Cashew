# Agent Guide

## Tech Stack & Environment
- **Framework & Language:** Flutter (>=3.0.0), Dart SDK (>=3.0.0).
- **Core Package Directory:** All Flutter code lives in `./budget/`. Always run flutter commands inside `./budget/` or specify the budget subdirectory.
- **Database:** Drift (SQLite) with code generation and versioned schemas.
- **State Management:** Provider / Listenable / ChangeNotifier, StreamBuilder for Drift reactive tables.
- **Platform Targets:** Android, iOS, Web, macOS, Windows, Linux.

## Essential Commands
Run these commands from `budget/` (e.g. `cd budget && ...`):
- **Dependencies:** `flutter pub get`
- **Code Generation (Drift & Mocks):** `dart run build_runner build --delete-conflicting-outputs`
- **Static Analysis:** `flutter analyze`
- **Tests:** `flutter test`
- **Format Check:** `dart format --output=none --set-exit-if-changed .`

## Architecture & Context Pointers
- **Domain Vocabulary:** See `GLOSSARY.md` for definitions of `Wallet`, `Budget`, `Category`, `Objective`, `Transaction`. Always use these exact terms.
- **Subsystem Architecture:** See `docs/architecture.md` for folder responsibilities and navigation guides for large files (`tables.dart`, `addTransactionPage.dart`, etc.).
- **Quality Standards & Constraints:** See `CONSTRAINTS.md` for non-negotiable rules on Drift migrations, static analysis, and testing standards.
- **Decision Records:** See `docs/adr/` before proposing changes to storage, currency, or core architecture.

## Code Conventions & Patterns
- **Database Seams:** Access tables through database singleton / providers in `budget/lib/database/tables.dart`. Write queries as methods on DAO / Database classes, never raw string SQL queries scattered in widgets.
- **Widget Decomposition:** Extract complex UI into reusable widgets under `budget/lib/widgets/`. Avoid monolithic build methods where possible.
- **Color & Theming:** Use theme palettes defined in `budget/lib/colors.dart`. Avoid hardcoded raw Color hex values in page widgets.
- **Localization:** All user-facing text must use localized strings via `app_localizations` or existing localization delegates.

## Boundaries & Safety Guardrails
- **Drift Migrations:** NEVER edit past migration steps in `budget/lib/database/schema_versions.dart` or files in `budget/drift_schemas/`. Always create a new version step when modifying tables.
- **Credentials & Keys:** Never commit `.env`, Firebase service account JSONs, or API keys.
- **Suppressions:** Do not add `// ignore:` or `// ignore_for_file:` directives without documented justification.
- **Commit Trailers:** Do not add `Co-authored-by` trailers to commit messages, including GitHub Copilot or other AI co-author lines. Commit messages contain only the subject and body.
- **Branching & Pull Requests:** NEVER push directly to the `main` branch. Always create a feature branch (e.g. `feat/owner-recognition`), push the branch, and open a Pull Request (PR) against `main` using `gh pr create` so changes can be reviewed before merging.
- **Separate Session for Code Review:** Do NOT run `/code-review` in the same implementation session. Once changes are committed, pushed, and a PR is opened, the implementing agent MUST pause and stop immediately. The user will run code review in a separate, isolated session to evaluate standards and spec conformance with fresh context, and will provide a go signal before the agent takes any further actions. Whenever a code review completes, automatically create a markdown report file in the code review directory (`.scratch/code-reviews/`).

## Agent skills

### Code review in separate session

Do not run `/code-review` inside the implementation session. Implementation sessions accumulate conversation context and bias. Code reviews must happen in a clean, dedicated session executed by the user. The implementing agent pauses upon PR creation and awaits the user's go signal. Whenever a code review completes, automatically create a markdown report file in the code review directory (`.scratch/code-reviews/` or task-specific `.scratch/BT-N-<slug>/`). See `docs/agents/code-review.md`.

### Issue tracker

GitHub Issues on fork `kidomarcostelo/budget-tracking` (via `gh` CLI) and local markdown under `.scratch/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical 5-role vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (`GLOSSARY.md` + `docs/adr/`). See `docs/agents/domain.md`.
