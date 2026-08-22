# Vitaly — Hypertension Monitoring App
## Product & Technical Specification

**Version:** 1.0
**Status:** Approved MVP Specification
**Platform:** Flutter / Android-first
**Primary Health Focus:** Blood Pressure & Hypertension Monitoring

---[google-services.json](../../Downloads/google-services.json)

# 1. Product Overview

Vitaly is a mobile application designed to help users consistently record, monitor, and understand their blood-pressure measurements over time.

Vitaly is a monitoring, tracking, education, and habit-support application.

Vitaly is NOT intended in the MVP to:

- diagnose hypertension
- diagnose medical conditions
- prescribe medication
- change medication dosage
- recommend stopping medication
- replace a healthcare professional
- provide emergency medical diagnosis

The application should help users organize their blood-pressure information so they can better understand their measurements and, where appropriate, discuss them with a qualified healthcare professional.

---

# 2. Product Vision

Make blood-pressure monitoring simple enough that users actually do it consistently.

The core product philosophy is:

> Record → Understand → Stay Consistent → Share With Your Healthcare Professional

The experience should be simple for users with little technical or medical knowledge.

---

# 3. Target Users

Primary users include:

- adults monitoring their blood pressure
- people advised by a healthcare professional to monitor BP at home
- people interested in tracking their BP trends
- caregivers helping another person maintain a BP log

The MVP focuses primarily on individual users.

---

# 4. Core MVP Functionality

The MVP includes:

1. User onboarding
2. Account authentication
3. Blood-pressure recording
4. Blood-pressure history
5. Trend visualization
6. Reminders
7. Educational content
8. Profile and settings
9. Privacy and security controls

---

# 5. Blood Pressure Measurement

Each blood-pressure reading contains:

- id
- systolic
- diastolic
- pulse
- timestamp
- notes
- measurementContext
- createdAt
- updatedAt

## Systolic

An integer representing systolic blood pressure in mmHg.

## Diastolic

An integer representing diastolic blood pressure in mmHg.

## Pulse

An optional integer representing heart rate in beats per minute (bpm).

## Timestamp

The date and time at which the measurement was taken.

## Notes

Optional free-text information entered by the user.

Examples may include:

- Felt stressed
- After exercise
- Forgot medication
- Had coffee

## Measurement Context

Optional predefined context:

- morning
- evening
- beforeMedication
- afterMedication
- afterExercise
- afterMeal
- other

The user may leave the context blank.

---

# 6. Recording a Blood Pressure Reading

The primary action in Vitaly is:

> Record BP

The user should be able to record a measurement quickly.

The flow is:

Home → Record BP → Enter systolic and diastolic → Enter optional pulse → Select optional context → Add optional notes → Save.

The form must clearly display:

- mmHg for blood pressure
- bpm for pulse

---

# 7. Input Validation

The application must validate user input.

Validation includes:

- required systolic value
- required diastolic value
- optional pulse
- integer and numeric validation
- prevention of malformed values
- explicitly approved acceptable input ranges

Validation boundaries must not be presented as medical diagnostic thresholds.

The application must distinguish between:

> This value is outside the range accepted by the application.

and:

> You have hypertension.

The application must not generate the second statement through basic input validation.

Exact accepted input ranges must be explicitly approved before implementation.

---

# 8. Blood Pressure History

Users must be able to view previous measurements.

History supports:

- chronological ordering
- date
- time
- systolic
- diastolic
- pulse
- context
- notes

Users can open an individual reading to view its details.

---

# 9. Editing and Deleting Measurements

Users can:

- edit an incorrect reading
- delete a reading

Deletion requires confirmation.

A deleted reading cannot be silently removed without user confirmation.

---

# 10. Dashboard

The home dashboard provides a simple overview.

It should show:

- a greeting
- the latest blood-pressure reading
- the latest pulse when available
- when the latest reading was recorded
- recent readings
- a 7-day trend summary
- the next reminder
- educational content

The exact visual design may evolve during UI implementation.

---

# 11. Trends

Vitaly should visualize blood-pressure measurements over time.

Supported periods:

- 7 days
- 30 days
- 90 days
- all available history

Trend views may display:

- systolic trend
- diastolic trend
- pulse trend when pulse data is available

Charts should remain simple and understandable.

The MVP may calculate and display simple mathematical information such as:

- average systolic reading
- average diastolic reading
- average pulse when available
- number of readings
- measurement frequency
- changes in recorded values over time

These calculations must not be presented as medical diagnoses.

---

# 12. Trend Language

Vitaly must use careful, non-diagnostic language.

Examples of acceptable language include:

> Your average systolic reading over the last 7 days was X mmHg.

> Your readings varied over the last 30 days.

> You recorded fewer readings this week than last week.

> You have recorded X readings during this period.

Vitaly must not automatically state:

- You have hypertension.
- Your medication is not working.
- Your blood pressure is cured.
- You are safe.
- You do not need to see a doctor.

Trend calculations and visualizations must not automatically become diagnoses or treatment recommendations.

---

# 13. Medical Safety

Vitaly must not provide individualized diagnosis or treatment decisions in the MVP.

The application must not:

- diagnose hypertension
- diagnose complications or other medical conditions
- recommend medication changes
- recommend medication dosages
- tell users to stop medication
- prescribe medication
- claim to replace healthcare professionals
- provide automated treatment recommendations
- provide emergency medical diagnosis

Vitaly may provide tracking, organization, visualization, reminders, and general educational information within the approved product scope.

---

# 14. Concerning Readings

Vitaly may not invent or independently choose medical thresholds for concerning readings.

The initial implementation must not automatically classify a reading as:

- normal
- elevated
- stage 1
- stage 2
- crisis

unless the exact classification standard, thresholds, wording, safety behavior, and authoritative source are explicitly approved before implementation.

Until those requirements are approved, the application should focus on displaying user-entered measurements and mathematical trends without diagnostic interpretation.

Vitaly must not provide false reassurance or make emergency decisions for the user.

---

# 15. Educational Content

Vitaly should provide general educational information about:

- what blood pressure is
- systolic pressure
- diastolic pressure
- how to measure blood pressure consistently
- why consistent monitoring matters
- factors that can affect readings
- general lifestyle factors associated with blood pressure
- general medication adherence education
- when users should consider seeking advice from a qualified healthcare professional

Educational content must be informational and must not be presented as personalized medical treatment.

Before production release, medical educational content should be based on approved authoritative sources and reviewed appropriately.

Do not invent medical educational content sources.

---

# 16. Measurement Technique Education

Vitaly may educate users about general blood-pressure measurement practices.

Potential topics include:

- resting before measurement
- appropriate positioning
- correct cuff placement
- avoiding unnecessary activity immediately before measurement
- taking measurements consistently
- recording measurements accurately

Exact medical instructions must be based on approved authoritative guidance before production release.

---

# 17. Reminders

Users should be able to create reminders to measure and record their blood pressure.

Each reminder may include:

- label
- time
- repeat schedule
- enabled or disabled status

Initial reminder schedules may support:

- every day
- selected days of the week

Users must be able to:

- create a reminder
- edit a reminder
- disable a reminder
- delete a reminder

Notification permission should only be requested when the user creates or enables a reminder.

Notifications are for habit and measurement reminders, not for emergency medical diagnosis.

---

# 18. Medication Tracking

Medication tracking is not required for the first implementation of the MVP.

The architecture may remain extensible enough to support it later.

If medication tracking is added in a future approved phase, the initial feature may focus on:

- medication name
- reminder schedule
- taken
- not taken

Vitaly must not recommend medication changes or dosages.

---

# 19. Onboarding

The MVP onboarding should collect only information necessary for the approved product experience.

Initial onboarding should include:

- account creation or sign-in
- preferred name or first name
- basic application preferences

Age, sex, height, weight, medical history, diagnosis information, and medication information must not be required merely to create an account unless a future approved feature specifically requires them.

Onboarding should also explain:

- the purpose of Vitaly
- that users record and monitor their own measurements
- that Vitaly does not provide diagnosis or treatment decisions

---

# 20. Authentication

The authentication provider must be explicitly selected before authentication implementation begins.

The approved provider should support:

- secure account creation
- secure sign-in
- session persistence
- secure sign-out
- account deletion support
- appropriate password and credential handling where applicable

Do not implement a custom authentication system unless explicitly approved.

Do not begin Phase 2 authentication implementation until the authentication provider has been selected.

---

# 21. Backend and Data Storage

The backend provider and database architecture must be explicitly selected before production backend integration begins.

The backend must support, as required by the approved MVP:

- user authentication
- user profiles
- blood-pressure readings
- reminders
- synchronization across supported devices
- account deletion

The implementation must not invent production API contracts.

Before backend implementation, the following must be defined:

- backend provider
- database structure
- authentication integration
- authorization rules
- API or data-access architecture
- synchronization behavior
- error handling approach
- environment configuration

---

# 22. Local Storage and Offline Support

Vitaly should support appropriate local persistence.

Local storage may be used for:

- cached measurements
- user preferences
- application state
- temporary offline data

Sensitive information must use appropriate secure storage mechanisms where required.

Offline behavior should be designed so that user data is not silently deleted or overwritten.

The intended synchronization flow is:

Online → save and synchronize.

Offline → save locally where supported.

Connection restored → synchronize according to the approved synchronization rules.

The exact local database or storage technology must be selected as part of the approved architecture.

---

# 23. Notifications

Notifications are primarily intended for:

- blood-pressure measurement reminders
- user-configured application reminders
- approved educational reminders

Notifications must not:

- diagnose medical conditions
- provide automated treatment decisions
- tell users that they are medically safe
- make emergency medical decisions

Users must be able to control reminder notifications.

---

# 24. Profile and Settings

The profile and settings area may include:

- preferred name
- email or account identifier
- notification preferences
- reminder preferences
- theme preference
- privacy settings
- sign out
- account deletion

Only information necessary for the product should be collected or displayed.

---

# 25. Privacy and Data Protection

Blood-pressure measurements are health-related information and must be treated as sensitive.

Vitaly must:

- minimize unnecessary data collection
- avoid unnecessary logging of health information
- protect user authentication credentials
- avoid hard-coded secrets
- use secure communication where network communication is required
- provide appropriate account deletion functionality
- avoid exposing user health information in notifications where possible
- clearly separate development configuration from production secrets

The exact legal and privacy requirements for each launch market must be reviewed before public release.

---

# 26. Analytics

Product analytics may measure general product events such as:

- app opened
- onboarding completed
- blood-pressure reading recorded
- reminder created
- educational content opened

Analytics should avoid collecting unnecessary health data.

Actual blood-pressure values must not be sent to analytics systems unless there is an explicitly approved privacy, security, and legal basis for doing so.

---

# 27. Monetization

Vitaly is intended to support a freemium business model.

Potential free features include:

- blood-pressure recording
- basic history
- basic trends
- basic reminders
- educational content

Potential premium features may include:

- advanced trend analysis
- extended historical analytics
- reports
- PDF or CSV export
- advanced reminders
- future medication tracking
- future caregiver or family features

Premium features must not prevent users from accessing their basic recorded health information.

Exact pricing and subscription plans will be determined separately.

---

# 28. Reports and Data Export

A future approved feature may allow users to generate reports from their recorded data.

Potential report contents include:

- selected date range
- recorded readings
- simple averages
- simple trends
- measurement frequency
- user-entered notes

Reports should clearly indicate that the information is based on user-recorded measurements and is not a medical diagnosis.

PDF or CSV export must not be implemented until the export format, privacy handling, and technical requirements are approved.

---

# 29. Design System

Vitaly should use a modern, clean, and accessible Material 3 design system.

The existing Phase 1 foundation uses Material 3 default typography.

Design priorities are:

- calm
- trustworthy
- clear
- accessible
- modern
- minimal

The interface should avoid unnecessary visual complexity.

Brand-specific colors and typography may be introduced later through an approved design system update.

---

# 30. Navigation

The expected high-level application flow is:

Authentication → Onboarding → Main application.

The main application should provide access to:

- Dashboard
- Record BP
- History
- Trends
- Education
- Profile and Settings

The existing GoRouter foundation should continue to be used unless there is an explicitly approved technical reason to change it.

---

# 31. Technical Stack and Architecture

Vitaly is built on Flutter, Android-first, with the following architectural principles:

- a clear separation between presentation, domain, and data layers
- feature-based folder structure rather than a purely layer-based one, so each feature (recording, history, trends, reminders, education, profile) is self-contained
- a single source of truth for blood-pressure data, with local storage as the offline-first cache and the backend as the sync target once selected
- dependency injection for testability, rather than hard-wired singletons
- no direct UI dependency on backend-specific SDKs; access should go through a repository abstraction so the backend provider can be swapped without rewriting features

The exact package choices for state management, local database, and networking must be confirmed before Phase 2 implementation, consistent with Sections 20–22.

---

# 32. State Management

State management should follow a predictable, testable pattern rather than ad-hoc setState usage for anything beyond trivial local widget state.

Requirements:

- feature state (readings, reminders, trends) should be observable and independently testable from the UI
- loading, error, and empty states must be modeled explicitly for every screen that reads from local storage or the backend
- state related to a blood-pressure reading in progress (the Record BP flow) must not be lost on minor interruptions such as a rotation or a brief backgrounding of the app
- the specific state management package (e.g. Provider, Riverpod, Bloc) must be selected and approved before broad implementation, and used consistently across features

---

# 33. Error Handling and Resilience

Vitaly must handle failure states gracefully rather than silently failing or crashing.

The application must:

- distinguish between validation errors, local storage errors, and network/sync errors, and message each differently
- never lose a user-entered reading due to a transient error; a failed save should be retried or clearly surfaced, not discarded
- avoid technical stack traces or raw exception text in user-facing UI
- log errors in a way that supports debugging without capturing sensitive health values (see Section 26)
- degrade gracefully when offline, per the synchronization behavior defined in Section 22

---

# 34. Performance

Given that Record BP is the core, most-frequent action, performance priorities are:

- the Record BP flow should open and be ready for input with minimal delay
- history and trend screens should load smoothly even as the number of stored readings grows over months of daily use
- chart rendering (Section 11) should remain responsive at all supported time ranges (7/30/90 days/all history)
- local storage reads/writes should not block the UI thread

Specific performance budgets (e.g. target load times) may be defined during implementation but are not fixed in this specification.

---

# 35. Accessibility

Vitaly should be usable by people with a range of abilities, consistent with the "accessible" design priority in Section 29.

Requirements include:

- sufficient color contrast for all text and key UI elements, including chart labels
- readable font sizes with support for the system's text-scaling settings
- screen-reader labels for all interactive elements, including the Record BP form fields and units (mmHg, bpm)
- touch targets sized appropriately for users who may have reduced dexterity
- charts should not rely on color alone to convey meaning (e.g. systolic vs. diastolic lines should be distinguishable beyond color)

---

# 36. Internationalization and Localization

The MVP should be structured to support localization even if only one language ships initially.

Requirements:

- all user-facing strings must be externalized rather than hard-coded, to support future translation
- date, time, and number formatting should respect device locale settings
- units (mmHg, bpm) are expected to remain constant across locales unless a future approved feature introduces unit preferences

The initial supported language(s) and target launch markets must be confirmed separately.

---

# 37. Testing Strategy

Vitaly should be tested at multiple levels appropriate to a health-adjacent application:

- unit tests for validation logic (Section 7), trend calculations (Section 11), and any date/time handling
- widget tests for the Record BP flow, history list, and trend charts
- integration tests covering the offline-save-then-sync flow described in Section 22
- specific test coverage for the language used in trend summaries and educational content, to confirm no diagnostic or treatment claims are surfaced (Sections 12–14)

Given the medical-safety constraints in this document, any change to trend language, validation messaging, or educational content should include a review step confirming it stays within the non-diagnostic scope approved in Sections 12–15.

---

# 38. Release and Deployment

Release readiness for the MVP depends on the approvals and selections flagged throughout this document, including:

- authentication provider (Section 20)
- backend provider and data architecture (Section 21)
- local storage technology (Section 22)
- accepted input validation ranges (Section 7)
- concerning-reading classification approach, if any (Section 14)
- authoritative sources for educational content (Sections 15–16)

Environment configuration must clearly separate development, staging, and production, with no production secrets present in development builds (Section 25).

A phased rollout (e.g. internal testing, closed beta, public release) is expected but the exact phases and criteria are not fixed in this specification.

---

# 39. Roadmap and Future Phases

Features explicitly deferred beyond the MVP, pending future approval, include:

- medication tracking (Section 18)
- PDF/CSV reports and data export (Section 28)
- caregiver or family features (Section 27)
- advanced trend analysis and extended historical analytics (Section 27)
- concerning-reading classification against an approved medical standard (Section 14)

None of these should be implemented ahead of the MVP without explicit approval of their respective scope, sources, and safety review, consistent with the caution expressed throughout Sections 13–16.

---

# 40. Open Questions and Risks

The following remain open and must be resolved before the relevant implementation work begins:

- **Authentication provider** — not yet selected (Section 20)
- **Backend provider and database architecture** — not yet selected (Section 21)
- **Local storage technology** — not yet selected (Section 22)
- **State management package** — not yet selected (Section 32)
- **Accepted input validation ranges** — not yet approved (Section 7)
- **Concerning-reading classification standard, if pursued** — not yet approved, and may remain out of scope for MVP (Section 14)
- **Authoritative sources for educational content** — not yet identified (Sections 15–16)
- **Export format and privacy handling for reports** — not yet approved (Section 28)
- **Legal/privacy requirements per launch market** — not yet reviewed (Section 25)

**Key risk:** because Vitaly touches health data and hypertension-adjacent language, the primary product risk is scope creep into diagnostic or treatment territory — through trend language, classification labels, or educational content — without the explicit review process described in Sections 12–16. All contributors should treat that boundary as a hard constraint, not a style preference.