# Code Review: Pull Request #22

- **PR:** [#22](https://github.com/kidomarcostelo/budget-tracking/pull/22) — `feat(android): isolate debug build with applicationIdSuffix and Cashew Dev label (#21)`
- **Branch:** `feat/debug-app-isolation` → `main`
- **Head Commit:** [`7fb0309f`](https://github.com/kidomarcostelo/budget-tracking/commit/7fb0309f990c24334f4ad3c74bda9c58901b5046)
- **Originating Spec:** Issue [#21](https://github.com/kidomarcostelo/budget-tracking/issues/21) & [`.scratch/BT-10-debug-app-isolation/task.md`](file:///home/kcostelo/person/budget-tracking/.scratch/BT-10-debug-app-isolation/task.md)
- **Review Date:** 2026-11-02
- **Review Type:** Two-Axis Code Review (Standards & Spec)

---

## Executive Summary

| Axis | Findings Count | Worst Issue | Status |
|:-----|:--------------:|:------------|:-------|
| **Standards** | 4 | `profile` build type alters launcher app label to `Cashew Dev` without `applicationIdSuffix ".debug"`, causing divergent configuration and clobbering production package identity. | Needs Attention |
| **Spec** | 2 | Half-configured `profile` build breaks isolation guarantees against production app overwrite hazard during `flutter run --profile`. | Needs Attention |

---

## 1. Standards Axis

### Documented Standards Compliance

- **[`budget/android/app/google-services.json`](file:///home/kcostelo/person/budget-tracking/budget/android/app/google-services.json#L89-L93)**
  - **Standard:** [`CONSTRAINTS.md`](file:///home/kcostelo/person/budget-tracking/CONSTRAINTS.md) §4 (*"No Hardcoded Secrets: Never commit API keys, Firebase service account keys, OAuth client secrets, or user tokens"*) and [`AGENTS.md`](file:///home/kcostelo/person/budget-tracking/AGENTS.md) (*"Credentials & Keys: Never commit .env, Firebase service account JSONs, or API keys"*).
  - **Hunk:**
    ```json
    + "api_key": [
    +   {
    +     "current_key": "AIzaSyDNVDtwGJUHBZohwB2RDeUco-5hAGfx2bA"
    +   }
    + ],
    ```
  - **Classification:** *Judgement Call (Tolerable)*. The base `google-services.json` file is already committed to the repository, and Gradle's `com.google.gms.google-services` plugin requires a client block matching `com.budget.tracker_app.debug`. Firebase Android client API keys act as project identifiers rather than backend authentication secrets. However, committing new key blocks touches the hardcoded secrets ban.

- **Fully Compliant Repository Standards:**
  - **Branching & PR Guardrails ([`AGENTS.md`](file:///home/kcostelo/person/budget-tracking/AGENTS.md)):** PR created from a dedicated feature branch (`feat/debug-app-isolation`), target is `main`, no direct commits to `main`.
  - **Commit Trailers ([`AGENTS.md`](file:///home/kcostelo/person/budget-tracking/AGENTS.md)):** No `Co-authored-by` or AI trailers added.
  - **Local Task Tracker ([`docs/agents/issue-tracker.md`](file:///home/kcostelo/person/budget-tracking/docs/agents/issue-tracker.md)):** Local scratch directory properly initialized at [`.scratch/BT-10-debug-app-isolation/task.md`](file:///home/kcostelo/person/budget-tracking/.scratch/BT-10-debug-app-isolation/task.md) and task index bumped to `Next ID: 11` in [`.scratch/index.md`](file:///home/kcostelo/person/budget-tracking/.scratch/index.md).
  - **Domain & Architecture Documentation ([`GLOSSARY.md`](file:///home/kcostelo/person/budget-tracking/GLOSSARY.md) & [`docs/architecture.md`](file:///home/kcostelo/person/budget-tracking/docs/architecture.md)):** Architecture documentation updated with a dedicated section (*"4. Android Environments & Package Isolation"*) documenting data preservation invariants and the `.sql` snapshot bridge.

### Fowler Refactoring Smell Baseline (Judgement Calls)

- **Duplicated Code — [`budget/android/app/build.gradle`](file:///home/kcostelo/person/budget-tracking/budget/android/app/build.gradle#L50-L88)**
  ```groovy
  defaultConfig {
      ...
      manifestPlaceholders = [appName: "Cashew"]
  }
  ...
  buildTypes {
      ...
      release {
          signingConfig signingConfigs.release
          manifestPlaceholders = [appName: "Cashew"]
      }
  }
  ```
  *Analysis:* AGP automatically cascades `defaultConfig` placeholders to all build types unless overridden. Setting `manifestPlaceholders = [appName: "Cashew"]` again in `buildTypes.release` is redundant.

- **Duplicated Code — [`budget/android/app/google-services.json`](file:///home/kcostelo/person/budget-tracking/budget/android/app/google-services.json#L60-L113)**
  *Analysis:* The 54-line client block is duplicated verbatim from the release client, including OAuth client IDs with certificate hashes. While required by the `google-services` build plugin lookup, Google Sign-In with OAuth client IDs mapped to `com.budget.tracker_app` will fail for `com.budget.tracker_app.debug` unless explicitly added in the Google Cloud Console.

- **Divergent Behavior / Incomplete Implementation — [`budget/android/app/build.gradle`](file:///home/kcostelo/person/budget-tracking/budget/android/app/build.gradle#L77-L84)**
  ```groovy
  debug {
      applicationIdSuffix ".debug"
      manifestPlaceholders = [appName: "Cashew Dev"]
  }
  profile {
      matchingFallbacks = ['release']
      manifestPlaceholders = [appName: "Cashew Dev"]
  }
  ```
  *Analysis:* The PR description states `applicationIdSuffix ".debug"` was introduced for dev builds, but `profile` has the `Cashew Dev` label without `applicationIdSuffix ".debug"`. This creates inconsistent behavior across build types.

---

## 2. Spec Axis

### (a) Missing or Partial Requirements
- **None.** All core requirements from [Issue #21](https://github.com/kidomarcostelo/budget-tracking/issues/21) are present:
  - *Spec:* `"Debug builds use applicationIdSuffix \".debug\" (com.budget.tracker_app.debug)"` → Implemented in [`budget/android/app/build.gradle`](file:///home/kcostelo/person/budget-tracking/budget/android/app/build.gradle#L75).
  - *Spec:* `"Debug builds display a distinct app name (Cashew Dev) on the Android launcher"` → Implemented via `${appName}` in [`budget/android/app/src/main/AndroidManifest.xml`](file:///home/kcostelo/person/budget-tracking/budget/android/app/src/main/AndroidManifest.xml#L33).
  - *Spec:* `"`google-services.json` recognizes both com.budget.tracker_app and com.budget.tracker_app.debug"` → Implemented in [`budget/android/app/google-services.json`](file:///home/kcostelo/person/budget-tracking/budget/android/app/google-services.json#L60).
  - *Spec:* `"Release builds remain unchanged (com.budget.tracker_app, Cashew)"` → Preserved in `release` build type and `defaultConfig`.

*(Minor tracking note: Section 4 verification checkboxes in [`.scratch/BT-10-debug-app-isolation/task.md`](file:///home/kcostelo/person/budget-tracking/.scratch/BT-10-debug-app-isolation/task.md#L38-L41) remain unchecked `[ ]`).*

### (b) Behaviour Not Asked For (Scope Creep)
- **`profile` Build Type Customization:**
  - *Spec (Issue #21):*
    > *"1. Debug builds use `applicationIdSuffix \".debug\"`..."*  
    > *"3. Release builds remain unchanged (`com.budget.tracker_app`, `Cashew`)."*
  - The diff introduces a custom `profile` build type block in [`budget/android/app/build.gradle`](file:///home/kcostelo/person/budget-tracking/budget/android/app/build.gradle#L81-L84) and records profile build semantics in [`docs/architecture.md`](file:///home/kcostelo/person/budget-tracking/docs/architecture.md#L74). The spec only requested isolating debug builds; altering profile build configuration was not requested.

### (c) Implemented Requirements That Look Wrong
- **Half-Configured `profile` Build Inverts Isolation Guarantees:**
  - *Spec (Issue #21):*
    > *"1. Debug builds use `applicationIdSuffix \".debug\"` (`com.budget.tracker_app.debug`), giving the debug app a completely isolated package name and SQLite database sandboxed from the release app."*  
    > *"4. Both the release app and debug app can be installed simultaneously on the same Android device without conflicts."*
  - While `debug` is properly isolated, `profile` was given `manifestPlaceholders = [appName: "Cashew Dev"]` **without** `applicationIdSuffix ".debug"`.
  - When running `flutter run --profile`, the resulting APK uses package ID `com.budget.tracker_app` while displaying `Cashew Dev` on the launcher. Installing it over a release app will attempt to overwrite the production app or fail with signing signature mismatches, defeating the primary safety goal of Issue #21.

---

## 3. Recommended Remediation

1. **Resolve Profile Build Configuration in [`budget/android/app/build.gradle`](file:///home/kcostelo/person/budget-tracking/budget/android/app/build.gradle):**
   - *Option A (Recommended — keep profile identical to release):* If `profile` is intended to measure production performance, remove the `profile` block or keep its label as `"Cashew"` so production profiling tests true release conditions.
   - *Option B (Isolate profile as a sandbox):* If `profile` is intended as a test build, add `applicationIdSuffix ".debug"` to `profile` as well.
2. **Remove Redundant `manifestPlaceholders` in `buildTypes.release`:**
   - Remove `manifestPlaceholders = [appName: "Cashew"]` from `release` block since it is already defined in `defaultConfig`.
3. **Update Local Task Status:**
   - Mark completed verification steps in [`.scratch/BT-10-debug-app-isolation/task.md`](file:///home/kcostelo/person/budget-tracking/.scratch/BT-10-debug-app-isolation/task.md#L38-L41).

---

## 4. Remediation Applied (2026-11-02)

1. **Profile Build Type Aligned:** Removed the divergent `profile` block in [`budget/android/app/build.gradle`](file:///home/kcostelo/person/budget-tracking/budget/android/app/build.gradle). Profile builds now cleanly inherit the production release package and label (`com.budget.tracker_app`, `Cashew`).
2. **Redundant Placeholders Removed:** Removed `manifestPlaceholders = [appName: "Cashew"]` from `buildTypes.release`; it inherits automatically from `defaultConfig`.
3. **Architecture Docs Updated:** Updated [`docs/architecture.md`](file:///home/kcostelo/person/budget-tracking/docs/architecture.md) to accurately document that `profile` measures production-accurate conditions.
4. **Task Verification Checked:** Verified and checked off all task verification items in [`.scratch/BT-10-debug-app-isolation/task.md`](file:///home/kcostelo/person/budget-tracking/.scratch/BT-10-debug-app-isolation/task.md) following successful GitHub Actions CI runs (`Build Android APK` ✓, `CI Quality Gate` ✓).

