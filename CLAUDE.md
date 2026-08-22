# Vitaly — Claude Code Instructions

## 1. Project Overview

Vitaly is a Flutter application designed to provide users with a reliable, accessible, and privacy-conscious health monitoring and wellness experience.

The application must be developed as a production-quality Flutter application rather than as a prototype or throwaway demo.

The primary target is Android. The project should remain architecturally ready for iOS.

---

## 2. Source of Truth

Before implementing any feature:

1. Read `PROJECT_SPEC.md`.
2. Inspect the existing project structure.
3. Understand the existing architecture before modifying it.
4. Do not contradict requirements in `PROJECT_SPEC.md`.
5. If a requirement is ambiguous, identify the ambiguity before making a major architectural decision.
6. Do not invent major product features without explicit approval.

`PROJECT_SPEC.md` defines what Vitaly should do.

`CLAUDE.md` defines how Claude Code should work on the project.

---

## 3. General Development Rules

* Use Flutter and Dart.
* Prefer clean, maintainable, production-quality code.
* Follow Dart and Flutter conventions.
* Keep widgets reasonably small and reusable.
* Avoid unnecessarily complicated abstractions.
* Do not duplicate business logic.
* Keep business logic separate from presentation.
* Use meaningful names for files, classes, variables, functions, and routes.
* Avoid magic numbers and unexplained constants.
* Add comments only where they improve understanding.
* Do not leave TODOs for core functionality unless explicitly approved.
* Do not implement fake functionality and present it as complete functionality.

---

## 4. Existing Project

Before changing files, inspect:

* `pubspec.yaml`
* `lib/`
* `test/`
* `android/`
* `ios/`
* configuration files
* existing dependencies
* existing routing
* existing state-management implementation

Preserve useful existing work.

Do not delete or replace existing functionality without first understanding why it exists.

---

## 5. Architecture

Use a scalable architecture appropriate for a production Flutter application.

Prefer separation similar to:

```text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── networking/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   └── feature_name/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

Do not create unnecessary folders simply for the sake of architecture.

The final architecture should remain understandable to another developer.

---

## 6. State Management

Use one consistent state-management approach throughout the application.

Do not introduce multiple state-management systems without a strong reason.

Before adding a state-management dependency, inspect the current project and `PROJECT_SPEC.md`.

Keep UI state separate from business/data state where appropriate.

---

## 7. Navigation

Use a centralized and predictable navigation strategy.

Routes should be named clearly.

Authentication-protected screens must not be accessible to unauthenticated users unless explicitly required by the specification.

Handle:

* authenticated state
* unauthenticated state
* loading state
* errors
* deep links where applicable

---

## 8. UI/UX

Vitaly should feel like a polished modern application.

Prioritize:

* accessibility
* readable typography
* consistent spacing
* clear hierarchy
* responsive layouts
* touch-friendly controls
* meaningful loading states
* meaningful empty states
* useful error states
* appropriate animations
* dark/light theme compatibility where required

Do not sacrifice usability for visual effects.

Avoid excessive animation.

---

## 9. Health and Safety

Vitaly is a health-related application.

Do not make unsupported medical claims.

Do not present Vitaly as a replacement for a qualified healthcare professional unless the specification explicitly defines an appropriately regulated medical function.

Where appropriate:

* distinguish monitoring from diagnosis
* distinguish informational content from medical advice
* encourage professional care for concerning situations
* avoid falsely reassuring users
* avoid unnecessarily alarming users

Health-related outputs must be carefully worded.

Do not invent medical thresholds, diagnoses, treatments, medications, or clinical recommendations.

If medical rules or thresholds are required, they must come from an explicitly approved source/specification.

---

## 10. Privacy and Security

Treat health-related information as sensitive.

Never:

* hard-code passwords
* hard-code API keys
* commit secrets
* log sensitive health information unnecessarily
* expose authentication tokens
* store sensitive information insecurely
* include real user health data in test fixtures

Use secure storage mechanisms where required.

Use environment/configuration mechanisms for secrets.

Never place production secrets directly in source code.

---

## 11. Data Handling

All data models should be explicit and typed.

Handle:

* null values
* missing data
* malformed data
* network failures
* timeouts
* authentication failures
* offline conditions
* server errors

Do not assume that API responses will always be valid.

---

## 12. Error Handling

Every important asynchronous operation should have appropriate loading, success, and failure states.

Errors shown to users should be understandable.

Do not expose raw stack traces or internal exceptions to users.

Log technical information only when appropriate and without exposing sensitive data.

---

## 13. Dependencies

Before adding a package:

1. Check whether the functionality can reasonably be implemented with existing Flutter/Dart capabilities.
2. Check whether an existing dependency already provides the functionality.
3. Prefer mature and actively maintained packages.
4. Avoid unnecessary dependencies.
5. Explain why a new dependency is needed.

Do not add packages merely for convenience.

---

## 14. Testing

Every significant feature should include appropriate tests.

Prefer:

* unit tests for business logic
* widget tests for important UI behavior
* integration tests for critical user flows

Tests must be deterministic.

Do not disable tests merely to make the build pass.

Before declaring a feature complete, run relevant tests.

---

## 15. Code Quality

Before considering a task complete, run:

```bash
flutter analyze
```

and relevant tests:

```bash
flutter test
```

Fix errors and meaningful warnings introduced by the implementation.

Do not hide analyzer errors by disabling rules unless explicitly justified.

---

## 16. Git

Make changes in small, logical increments.

Before major changes, inspect Git status.

Do not delete or overwrite user work without confirmation.

Do not commit:

* secrets
* API keys
* credentials
* generated sensitive data
* local machine configuration

Use `.gitignore` appropriately.

---

## 17. Working Procedure

For every significant task:

### Step 1 — Understand

Read `PROJECT_SPEC.md` and inspect the current implementation.

### Step 2 — Plan

Briefly explain:

* what will change
* which files will change
* dependencies required
* potential risks

### Step 3 — Implement

Make the smallest coherent set of changes needed.

### Step 4 — Verify

Run appropriate:

```bash
flutter analyze
flutter test
```

and run the application when appropriate.

### Step 5 — Report

Explain:

* what was implemented
* files changed
* tests performed
* any remaining issues
* any decisions that require user approval

---

## 18. Do Not Do This

Do not:

* rewrite the entire application unnecessarily
* delete working code without justification
* create placeholder features and call them complete
* invent backend APIs
* invent medical rules
* invent credentials
* expose secrets
* make destructive changes without warning
* modify Android/iOS configuration unnecessarily
* add packages without justification
* ignore failing tests
* ignore analyzer errors
* make large architectural changes without explaining them

---

## 19. Before Starting a Major Feature

If a feature affects architecture, authentication, health calculations, personal data, backend infrastructure, payments, notifications, or deployment:

Stop and explain the proposed approach before implementing it if the requirements are not already explicit in `PROJECT_SPEC.md`.

---

## 20. Definition of Done

A feature is not complete merely because it compiles.

A feature is complete when:

* it follows `PROJECT_SPEC.md`
* the UI works correctly
* loading/error/empty states are handled
* relevant tests exist
* `flutter analyze` passes
* relevant tests pass
* no secrets are exposed
* no obvious security/privacy issue was introduced
* the implementation is maintainable
