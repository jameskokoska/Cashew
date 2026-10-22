# Task: Extend automatic transaction creation to Google Pay (Android)

**ID:** BT-3  
**Issue Reference:** [#7](https://github.com/kidomarcostelo/budget-tracking/issues/7)

---

## What & why

Automatic transaction creation exists for Apple Pay (an external iOS Shortcut that opens App
Links such as `cashew://addTransaction?...`). Google Pay users on Android get no equivalent.
The app already has an Android notification listener (`budget/lib/pages/autoTransactionsPageEmail.dart`)
that turns notification text into a prefilled `AddTransactionPage` via `ScannerTemplates`, but
Google Pay notifications are not recognized as a source, and nothing dedupes events from multiple sources.

Expected behavior: on Android, a Google Pay payment notification (and the bank notification for
the same payment, when both exist) produces at most one prefilled Transaction. The user confirms
it, same as today. Uncertain matches go to review instead of being auto-created.

Out of scope: iOS (Google Pay does not run there), Gmail ingestion (#2/#3), the Triage UI (#4/#5),
and new bank-email parsing (#6, see BT-2).

## Invariants & constraints

- Consult [`CONSTRAINTS.md`](../../CONSTRAINTS.md) and [`GLOSSARY.md`](../../GLOSSARY.md). Use the terms `Transaction`, `Wallet`, `Category`, and `Budget` exactly.
- Drift schema changes must be additive: bump `schemaVersionGlobal` in `budget/lib/database/tables.dart` and add a new migration step. Never edit past steps in `budget/lib/database/schema_versions.dart` or `budget/drift_schemas/`.
- Money amounts keep the existing precision handling used by `ScannerTemplates` parsing.
- No `// ignore:` directives without documented justification.
- Colors come from `budget/lib/colors.dart`. User-facing strings go through `app_localizations`.
- Android only. Settings must be gated by the existing `notificationScanning` preference (`budget/lib/struct/defaultPreferences.dart`).
- Keep the listener single-owner: exactly one `NotificationListenerService.notificationsStream` subscription, owned by one dispatcher.

## What we know

- `initNotificationScanning()` sets one global subscription. The settings switch only cancels that subscription (`autoTransactionsPageEmail.dart` ~L38-49, ~L212-232).
- `onNotification` processes every event with no `hasRemoved` filter and no package filter. A posted event and its later removed event can each create a Transaction. This is an existing duplicate source.
- `queueTransactionFromMessage` uses first-match-wins over `ScannerTemplate.contains`, so a notification can route to the wrong template.
- `appLinks.dart` has a 350 ms throttler. Rapid repeated App Links can be dropped, but a Shortcut can also fire twice.
- `ServiceNotificationEvent` provides `id`, `packageName`, `title`, `content`, and `hasRemoved` (plugin README, notification_listener_service 0.3.3).
- The manifest has no SMS permissions. The "SMS listener" is the notification listener.
- S0 research is written to [`research.md`](research.md). Its completeness was not re-verified during this migration.

### Duplication & clash risks

| Risk | Source | Mitigation slice |
|---|---|---|
| Posted and removed events both create a Transaction | `onNotification` has no `hasRemoved` filter | S1 |
| Google Wallet notification and bank notification describe one payment | Two packages, same amount | S3 (key) and S4 (review) |
| Second `notificationsStream.listen` (if a Google Pay listener is added separately) | Plugin may be single-subscription (check S0) | S1 (single owner) |
| Settings toggle cancels only one subscription | `autoTransactionsPageEmail.dart` ~L212-232 | S1 |
| First-match-wins template routing | `queueTransactionFromMessage` | S2 (source classification first) |
| Apple Pay Shortcut or App Link retry fires twice | Shortcut + `appLinks.dart` throttler | S3 |

## Plan

Each slice ends in something runnable and testable. S1 to S4 depend on S0.

- [x] **S0 Research (blocking).** Output: `research.md`. Covers Google Wallet notification package and fields, plugin stream semantics (broadcast vs single subscription; `id`; posted/removed behavior), Android `onNotificationPosted` re-post semantics, Play policy for notification access, and whether any official consumer transaction API exists.
- [x] **S0b Plugin upgrade decision.** Upstream inspection of `notification_listener_service: 1.0.0` completed. Upgrading is recommended: it fixes plugin issue #35 (`RECEIVER_NOT_EXPORTED` on API 34+), adds `timestamp` needed for dedupe windows, and retains full Dart API backwards compatibility with existing methods. Caveat: `EXTRA_BIG_TEXT` is still unhandled upstream in 1.0.0 (plugin still uses `EXTRA_TEXT` truncated to 500 chars).
- [x] **S1 Single dispatcher (tracer for the refactor).** Move the global subscription into one dispatcher (`NotificationDispatcher`). Ignore `hasRemoved == true` events to eliminate duplicate transaction creation on notification dismissals. Keep current behavior for existing templates. Added unit test suite in `budget/test/notification_dispatcher_test.dart`.
- [x] **S2 Google Pay source tracer bullet.** Added source classification by `packageName` (`com.google.android.apps.walletnfcrel`, `com.google.android.apps.nbu.paisa.user`, and `com.google.android.gms`), implemented `GooglePayParser` parsing merchant, amount, currency, and card hints, and wired into `NotificationDispatcher` to prefill `AddTransactionPage`. Verified that payload length (~49 chars) fits within `EXTRA_TEXT` (500 chars). Added unit tests in `google_pay_parser_test.dart` and real device sample in `.scratch/bank-samples/google-pay/sample-notification.md`.
- [x] **S3 Dedupe ledger.** Record a key per event (`packageName` + `id` + normalized amount/title/timestamp bucket) with a time window (default 5 min, to be tuned from S0 samples). A second match within the window is suppressed or sent to review. Store in a new Drift table (additive migration). Covers:
  - posted + removed events for the same notification
  - Google Pay + bank notification for the same payment
  - Apple Pay Shortcut firing twice, or App Link throttler retries
- [ ] **S4 Review route for uncertain matches.** When a match is ambiguous (two sources, no exact key match), show a "possible duplicate" prompt rather than auto-creating. Align with the heuristics in [`BT-2`](../BT-2-plan-bank-email-duplicate-detection/task.md) and wayfinder #2 Triage Inbox. Do not build the full Triage UI (#4).
- [ ] **S5 Settings, permission UX, docs.** Settings copy for the Google Pay source (toggle per source). Update the FAQ/README pointer. Explain the notification-access permission and the Play policy note from S0.
- [ ] **S6 Verification.** Widget tests for the prefilled page, unit tests for dedupe window and source classification, and a manual test on a device with real Google Pay notifications (redacted).

## Acceptance & verification

- [ ] Unit / widget tests added or updated (S1, S2, S3, S4)
- [ ] Static analysis passes: `cd budget && flutter analyze`
- [ ] Code formatted: `cd budget && dart format --output=none --set-exit-if-changed .`
- [ ] Drift migration added as a new step; `schema_versions.dart` past steps untouched
- [ ] Manual verification on an Android device with real Google Pay notifications (redacted fixtures saved under `.scratch/bank-samples/`)
- [ ] Posted + removed event for one payment produces exactly one Transaction

## Roadblock

None blocking S4. S4 (Review route for uncertain matches) is unblocked and ready for implementation.

## Tried

- S0 research written to `.scratch/BT-3-extend-auto-transactions-google-pay/research.md`.
- S0b evaluation of `notification_listener_service: 1.0.0` completed and recorded in `research.md`.
- S1 implemented: upgraded to `notification_listener_service: ^1.0.0`, created `NotificationDispatcher` to own the listener stream, filtered out `hasRemoved == true` events, and added unit tests in `notification_dispatcher_test.dart`.
- S2 implemented: created `GooglePayParser`, classified packages and payment content, routed to prefilled `AddTransactionPage`, and added unit tests with real 7-Eleven sample in `google_pay_parser_test.dart`.
- S3 implemented: created `DedupeLedger` service, added additive Drift migration v46 -> v47 with `DedupeEntries` table and schema dump, wired deduplication into `NotificationDispatcher` and `appLinks`, and added unit tests in `dedupe_ledger_test.dart`.

## Resume / next step

Proceed to S4: Implement review route for uncertain matches.

## Links

- GitHub: #7 (kidomarcostelo/budget-tracking)
- Research: [`research.md`](research.md)
- Related: [`BT-2`](../BT-2-plan-bank-email-duplicate-detection/task.md) (bank-email duplicate heuristics)
