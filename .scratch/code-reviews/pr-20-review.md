# Code Review Report: PR #20

**Target Branch:** `feat/dedupe-ledger` against `main`  
**Pull Request:** [#20](https://github.com/kidomarcostelo/budget-tracking/pull/20) (`feat(notifications): add dedupe ledger and duplicate suppression (#7)`)  
**Tracking Issue:** [#7](https://github.com/kidomarcostelo/budget-tracking/issues/7) (Task: [`BT-3`](../BT-3-extend-auto-transactions-google-pay/task.md))  
**Commits Reviewed:**
- `9850db85` fix(notifications): prevent dedupe self-suppression, cap suppressed entries, and await persistence
- `05f1a08d` fix(db): implement missing Insertable methods in DedupeEntriesCompanion
- `dddc159b` fix(ci): resolve static analysis errors in schema_versions, notificationDispatcher, and appLinks
- `9cb13116` style: format schema and dedupe ledger files
- `b47a6246` docs(handoff): document PR 20 CI status and add workspace handoff
- `00005e92` feat(notifications): add dedupe ledger and duplicate suppression (#7)

---

## Standards

### (a) Documented Standards Violations
**None detected.**
- **`CONSTRAINTS.md` (Sec. 2) / `AGENTS.md` (Drift Migrations):** Strictly adheres to atomic forward migration discipline. Increments schema from 46 to 47, introduces `drift_schema_v47.json`, adds `from46To47` migration step in `schema_versions.dart`, and leaves historical schema versions and snapshots untouched.
- **`CONSTRAINTS.md` (Sec. 1) / `AGENTS.md` (Suppressions):** Zero `// ignore:` or `// ignore_for_file:` directives added.
- **`AGENTS.md` (Commit Trailers):** Commit subjects/bodies contain no `Co-authored-by` or AI trailers.
- **`GLOSSARY.md`:** Standard domain vocabulary maintained (`Transaction`, `Wallet`).

### (b) Baseline Smells (Judgement Calls)

1. **Duplicated Code**
   - `budget/lib/widgets/util/appLinks.dart` (L137-L147 & L251-L261):
     Verbatim 10-line payment deduplication check repeated across both `processAddTransactionFromParams` and `processAddTransactionRouteFromParams`:
     ```dart
     if (amount > 0 && params["skipDedupe"] != "true") {
       final dedupeResult = await DedupeLedger.instance.checkAndRecordPayment(
         amount: amount,
         title: params["title"] ?? params["name"],
         source: params["source"] ?? 'app_link',
       );
       if (dedupeResult.isDuplicate) return null;
     }
     ```
   - `budget/lib/struct/dedupeLedger.dart` (L227-L266 & L314-L350):
     Reversed-loop sliding window traversal, amount/currency matching, suppressed entry instantiation, and capped list pruning are duplicated between `checkAndRecordNotification` (Tier 2) and `checkAndRecordPayment`.

2. **Speculative Generality**
   - `budget/lib/database/tables.dart` (L1340-L1360):
     `updateDedupeEntryStatus` query is added to `FinanceDatabase` but never invoked anywhere in the codebase.
   - `budget/lib/struct/dedupeLedger.dart` (L137-L167):
     `loadFromDatabase()` hydrates ledger entries from Drift but is never wired into the app startup/lifecycle or test suites.

3. **Data Clumps**
   - `budget/lib/struct/dedupeLedger.dart` (L170-L179 & L297-L306):
     `checkAndRecordNotification` and `checkAndRecordPayment` each accept 8 loose parameters mirroring `DedupeEntryRecord`.

4. **Primitive Obsession / Magic Numbers**
   - `budget/lib/struct/dedupeLedger.dart` (L210-L211):
     Literal integer `200` is repeated across 6 locations for capping `entries` and `suppressedEntries` without a named constant (`maxLedgerCapacity`).

---

## Spec

### (a) Requirements Missing or Partial

1. **Spec:** *"Google Pay + bank notification for the same payment"*
   In `budget/lib/struct/notificationDispatcher.dart` (L107-L118), amount extraction only calls `GooglePayParser.parse()`. For standard bank notifications handled via `ScannerTemplates`, `googlePayResult` is `null`, passing `amount: null` to `checkAndRecordNotification`. Because Tier 2 matching requires a non-null amount, bank notifications never deduplicate against Google Pay transactions.

2. **Spec:** *"Store in a new Drift table (additive migration)"*
   Persistence is write-only. Deduplication checks (`checkAndRecordNotification` / `checkAndRecordPayment`) inspect only the in-memory `entries` list. `DedupeLedger.loadFromDatabase()` is defined but never called in the app lifecycle; process restarts discard all active window history.

3. **Spec:** *"A second match within the window is suppressed or sent to review."*
   Matches are strictly dropped/suppressed (`return false` in dispatcher, `return null` in appLinks). Ambiguous match routing to review is missing in this slice.

### (b) Scope Creep (Not Asked For)

1. **Spec:** *"Constraints: Android only. Gated by existing notificationScanning preference."*
   In `budget/lib/widgets/util/appLinks.dart` (L137-L146), deduplication checks run unconditionally across all platforms (iOS, desktop, web) and without checking `appStateSettings["notificationScanning"]`.

2. **Spec:** *"Store in a new Drift table (additive migration)."*
   `DedupeEntries` schema adds unused state columns (`createdTransactionPk`, `matchedEntryPk`, `status`) and `budget/lib/database/tables.dart` adds `updateDedupeEntryStatus()`, none of which are ever wired or updated when transactions are confirmed.

### (c) Requirements Implemented Wrongly

1. **Spec:** *"key from packageName + id + normalized amount/title/timestamp bucket, with a time window (default 5 min, to be tuned from S0 samples)."*
   The composite key and timestamp bucketing are not implemented as specified. Instead, the implementation splits into two separate keys (`notif:$packageName:$id` and `pay:$amount:$currency`) and performs linear in-memory traversals calculating dynamic time differences (`difference().abs() <= window`).

---

## Summary

Standards found **0 documented violations** and **4 baseline smell heuristics** (worst: duplicated traversal, pruning, and matching logic in `dedupeLedger.dart`); Spec found **6 findings** (worst: bank notifications pass `amount: null`, preventing cross-source Google Pay vs bank notification deduplication).
