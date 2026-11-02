# Architecture & Subsystem Guide

This document maps the architectural layers of the `budget-tracking` application to help human developers and AI agents navigate the codebase efficiently.

---

## 1. Directory Structure

```
budget/
├── drift_schemas/          ← Versioned schema snapshots for Drift migrations
├── lib/
│   ├── database/           ← Drift database definitions, migrations, DAOs
│   │   ├── tables.dart     ← Core schema definitions and database queries
│   │   ├── tables.g.dart   ← Generated Drift code (do not edit manually)
│   │   └── schema_versions.dart ← Migration logic across app versions
│   ├── struct/             ← Global data structures, helpers, preferences, sync
│   │   ├── currencyFunctions.dart ← Exchange rates and currency math
│   │   ├── defaultPreferences.dart← SharedPreferences wrapper & defaults
│   │   ├── settings.dart   ← User settings state model
│   │   └── syncClient.dart ← Cloud sync orchestration (Google Drive/Firebase)
│   ├── pages/              ← Screen-level widgets and full views
│   │   ├── homePage/       ← Main dashboard view
│   │   ├── addTransactionPage.dart ← Full transaction creator/editor
│   │   ├── addBudgetPage.dart      ← Budget configuration screen
│   │   └── addWalletPage.dart      ← Wallet configuration screen
│   ├── widgets/            ← Modular, reusable UI components
│   ├── colors.dart         ← Global color palettes and dark/light themes
│   ├── functions.dart      ← Core calculation utilities and budget algorithms
│   └── main.dart           ← App entry point and top-level provider setup
└── packages/               ← Vendored and customized Flutter packages
```

---

## 2. Core Architectural Patterns

### Local-First Data Flow
- **Single Source of Truth:** The SQLite database initialized in `budget/lib/database/tables.dart` (`FinanceDatabase`).
- **Reactive UI:** Database queries expose reactive streams (e.g. `watchAllWallets()`, `watchAllBudgets()`). Pages use `StreamBuilder` or Provider to automatically re-render when transactions are inserted or edited.
- **Transactions & Wallets:** When a transaction is saved, wallet balances and associated budget totals update atomically in the database.

### Working with Large Files (Agent Guidance)
Several core files in this project are large and feature-dense:
- `budget/lib/database/tables.dart` (~296 KB)
- `budget/lib/pages/addTransactionPage.dart` (~204 KB)
- `budget/lib/database/schema_versions.dart` (~176 KB)
- `budget/lib/functions.dart` (~49 KB)

> [!TIP]
> **Do not view entire large files at once.** This floods agent context and degrades reasoning.
> Instead, navigate using targeted line ranges, symbol search, or search commands:
> - Search for method signatures or table names: `git grep -n "class Transactions" budget/lib/`
> - Inspect specific line slices: use line range views around the specific function or widget.

---

## 3. Database Migrations Discipline
Drift maintains schema evolution snapshots in `budget/drift_schemas/`.
1. When altering tables, add the new field to the table class in `tables.dart`.
2. Increment the schema version in `schema_versions.dart`.
3. Implement the migration step function in `schema_versions.dart`.
4. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `tables.g.dart`.
5. Dump the new schema using Drift migration tools.
6. **Never alter existing historical migration blocks.**

---

## 4. Android Environments & Package Isolation

To allow developers to track real personal finances on their daily driver while simultaneously developing and testing features:
- **Release Build (`release`):** Package `com.budget.tracker_app` with launcher label `Cashew`.
- **Debug Build (`debug`):** Package `com.budget.tracker_app.debug` (via `applicationIdSuffix ".debug"`) with launcher label `Cashew Dev`.
- **Profile Build (`profile`):** Inherits release configuration (`com.budget.tracker_app`, `Cashew`) to measure production-accurate performance.

### Data Safety Invariants:
1. Both apps can be installed simultaneously on the same Android device with independent SQLite databases (`FinanceDatabase`) and separate `SharedPreferences`.
2. Debug builds will never overwrite, corrupt, or wipe the production database upon install or uninstall.
3. Realistic data testing is supported via the built-in database bridge: export a `.sql` snapshot from `Cashew` (`Settings → Import and export → Export data file`) and import it into `Cashew Dev`.

