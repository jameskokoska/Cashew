# Task: Isolate Android debug build with applicationIdSuffix and distinct app label

**ID:** BT-10  
**Issue Reference:** [#21](https://github.com/kidomarcostelo/budget-tracking/issues/21)  
**Status:** In Progress  
**Assignee / Agent:** AI Assistant  

---

## 1. Objective & Scope
- **Problem Statement:** Debug builds installed on Android devices currently share the release package name (`com.budget.tracker_app`) and app label (`Cashew`). This exposes developers tracking real personal expenses to data loss: installing or uninstalling debug builds wipes the SQLite database, signing key differences cause update failures, and development features cannot be tested side-by-side with real personal tracking.
- **Expected Behavior:**
  1. Debug builds use `applicationIdSuffix ".debug"` resulting in `com.budget.tracker_app.debug`.
  2. Debug builds display a launcher label of `Cashew Dev`, while release builds display `Cashew`.
  3. `google-services.json` recognizes both `com.budget.tracker_app` and `com.budget.tracker_app.debug`.
  4. Both apps can be installed side-by-side on the same Android device with separate SQLite databases and settings.

---

## 2. Invariants & Constraints
- Consult [`CONSTRAINTS.md`](../../CONSTRAINTS.md) and [`GLOSSARY.md`](../../GLOSSARY.md).
- Release builds must retain their existing package ID `com.budget.tracker_app` and title `Cashew`.
- Kotlin package names, MethodChannels (`com.budget.tracker_app/ocr`), and Dart imports must remain fully compatible.
- All CI workflows (`CI Quality Gate` and `Build Android APK`) must continue to pass cleanly.

---

## 3. Plan & Implementation Steps
- [x] Configure `manifestPlaceholders` in `budget/android/app/build.gradle` for `debug`, `profile`, and `release`.
- [x] Set `applicationIdSuffix ".debug"` for the `debug` build type.
- [x] Update `budget/android/app/src/main/AndroidManifest.xml` to use `android:label="${appName}"`.
- [x] Add the `com.budget.tracker_app.debug` client entry to `budget/android/app/google-services.json`.
- [x] Update `docs/architecture.md` documenting parallel dev vs production environments.
- [ ] Verify Gradle configuration and CI compatibility.

---

## 4. Verification & Testing
- [ ] Gradle build configuration validation
- [ ] Code formatting and quality checks
- [ ] GitHub Actions CI passing on Pull Request
