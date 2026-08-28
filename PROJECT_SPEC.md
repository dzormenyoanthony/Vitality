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

- an introductory carousel explaining the app, shown before an account exists
- preferred name or first name
- account creation or sign-in
- basic application preferences

For a brand-new user, the introductory carousel and name collection happen
*before* account creation: Onboarding → Authentication → Main application
(see §30). A user who already has an account, or who has completed
onboarding on this device before, is not shown the carousel again.

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

Vitaly implements two distinct exports; do not conflate them:

**Trends PDF summary** (Section 11) — a non-diagnostic PDF of a selected
Trends period (summary sentences plus the individual readings in that
period), shared via the system share sheet. This was already approved and
implemented before the full data export below.

**Full data export** — approved scope, implemented as a single ZIP package
so scanned/saved report files (images/PDFs, which a CSV cannot contain) can
travel alongside the reading data:

```text
vitaly_data_export_YYYY-MM-DD.zip
│
├── vitaly_bp_readings_YYYY-MM-DD.csv
│
└── scanned_reports/
    ├── report_<id>.<ext>              (single-page report)
    └── report_<id>_page_<n>.<ext>     (multi-page report)
```

The CSV contains exactly: Date, Time, Systolic (mmHg), Diastolic (mmHg),
Pulse (bpm) if available, Notes if available, Measurement Context if
available, Reading Source ("Manual Entry" or "Imported Report"), and
Related Report ID (the `scanned_reports/report_<id>...` this reading came
from, when applicable — ties a CSV row back to its original document).

`scanned_reports/` contains every saved report file belonging to the
signed-in user, read from local storage only — never another user's files,
and never anything from Firebase Storage. Each file's original extension is
preserved as stored on-device. A report file that can't be read (missing,
not yet synced to this device) is left out of the ZIP and the user is told
which one before the export completes — never silently dropped.

Export flow: user selects "Export data" in Settings → Vitaly collects
approved BP readings → generates the CSV → retrieves the user's saved
report files → packages both into one ZIP
(`vitaly_data_export_YYYY-MM-DD.zip`) → opens the native system Share/Save
flow.

This is a copy of the user's own data for their own use (e.g. sharing with
a clinician) — it must not be presented as, or contain, a diagnosis.

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

The expected high-level application flow depends on the user's state:

- Brand-new user (no account, first time on this device): Onboarding
  (introductory carousel + preferred name) → Authentication (account
  creation) → Main application.
- Existing user who is not currently signed in: Authentication (sign in)
  → Main application. The onboarding carousel is not shown again.
- Returning user who is already authenticated and has completed
  onboarding: Main application directly.

A device-local record of onboarding completion (independent of any one
account) determines which of these applies, since the decision must be
made before it's known whether the visitor has an account at all.

The main application should provide access to:

- Dashboard
- Record BP
- History
- Trends
- Education
- Profile and Settings

The existing GoRouter foundation should continue to be used unless there is an explicitly approved technical reason to change it.

# VITALY — FEATURE SPECIFICATION
## BP REPORT SCANNING + BP READING STATUS CLASSIFICATION

> This specification covers ONLY these two features:
>
> 1. Scan BP Report & Saved Reports
> 2. BP Reading Status & Range Classification
>
> Do not modify or implement unrelated features while working on this specification.
>
> Implementation order:
>
> PHASE 1 → Scan BP Report & Saved Reports
> PHASE 2 → BP Reading Status & Range Classification

---

# PHASE 1 — SCAN BP REPORT & SAVED REPORTS

## 1. Feature Objective

Vitaly must allow users to scan a physical blood-pressure report or import an existing report/document from their device.

Vitaly should preserve the original report and, where possible, use OCR to identify relevant information such as blood-pressure readings.

The workflow must be:

SCAN / IMPORT
→ OCR / EXTRACTION
→ REVIEW
→ USER EDITS / CONFIRMS
→ SAVE ORIGINAL REPORT
→ OPTIONAL: ADD CONFIRMED BP READINGS TO BP HISTORY

OCR must never automatically create health records.

---

## 2. Entry Point

Provide a clear:

> Scan BP Report

action.

The action should be accessible from appropriate locations such as:

- Dashboard
- Saved Reports
- Reports

The user must also be able to import an existing image or supported document from their device.

---

## 3. Scanning & Import

Support:

- Camera-based document scanning.
- Importing images.
- Importing PDFs where supported.
- Multiple-page reports.
- Preview before saving.
- Retaking a scan.
- Removing unwanted pages.
- Reordering pages where practical.

The original document must always be preserved.

A report must still be saveable even if OCR fails.

---

## 4. OCR & Data Extraction

After scanning/importing, Vitaly may process the document using OCR.

Potentially extract:

- Systolic BP.
- Diastolic BP.
- Pulse.
- Date.
- Weight.
- Other clearly identifiable numerical measurements.
- Relevant text from the report.

OCR results are UNCONFIRMED until reviewed by the user.

Do not assume OCR output is accurate.

---

## 5. Review Extracted Information

After extraction, display a dedicated:

> Review Extracted Information

screen.

Example:

    Blood Pressure

    Systolic
    136 mmHg

    Diastolic
    84 mmHg

    Pulse
    72 bpm

    Date
    22 Aug 2026

The user MUST be able to:

- Edit an extracted value.
- Delete an incorrect value.
- Add a missing value.
- Correct the date.
- Correct other extracted information where appropriate.
- Confirm the information.
- Cancel the extraction.

Clearly indicate that the information was extracted from the report until the user confirms it.

---

## 6. Mandatory User Confirmation

Vitaly must require explicit user confirmation before extracted BP values can be added to BP History.

Correct flow:

OCR RESULT
→ USER REVIEWS
→ USER EDITS IF NECESSARY
→ USER CONFIRMS
→ VALUE BECOMES ELIGIBLE FOR BP HISTORY

Never implement:

OCR
→ AUTOMATIC BP HISTORY ENTRY

Never implement:

OCR
→ AUTOMATIC CLASSIFICATION

---

## 7. Multiple BP Readings

A single report may contain multiple BP readings.

Vitaly must allow the user to review each detected reading individually.

Example:

    Detected readings:

    22 Aug — 08:00
    136 / 84

    22 Aug — 14:00
    129 / 81

    22 Aug — 20:00
    142 / 90

The user must be able to:

- Confirm individual readings.
- Edit individual readings.
- Delete incorrect readings.
- Select which confirmed readings should be added to BP History.

Do not assume every number detected by OCR is a blood-pressure measurement.

---

## 8. Save Original Report

After the review process, Vitaly must save the original scanned/imported document.

The original document must remain available even when:

- OCR fails.
- OCR produces incorrect values.
- The user rejects extracted values.
- No BP value is detected.

The original document must NOT be replaced by OCR text.

OCR/extracted information must remain separate from the original document.

---

## 9. Saved Report Data

Each saved report must contain, at minimum:

- reportId
- userId
- documentReference
- documentType
- title
- createdAt
- updatedAt
- reportDate, if available
- pageCount
- ocrStatus
- extractedData
- confirmedData
- source

Conceptual structure:

    SavedReport
    ├── reportId
    ├── userId
    ├── documentReference
    ├── documentType
    ├── title
    ├── reportDate
    ├── pageCount
    ├── ocrStatus
    ├── extractedData
    ├── confirmedData
    ├── source
    ├── createdAt
    └── updatedAt

Follow the existing Vitaly architecture and database conventions when implementing the actual model.

---

## 10. Saved Reports Screen

Create a dedicated:

> Saved Reports

screen.

Only reports belonging to the authenticated user may be displayed.

Each report card should provide information such as:

    BP Review Report
    22 Aug 2026
    2 pages

    View Report >

Users must be able to:

- View a report.
- Rename a report.
- View report details.
- Delete a report.
- Share/export where supported.

**Document locker redesign (approved, implemented):** per
`design_references/My document locker.png`, the Saved Reports screen was
rebuilt as a "document locker" — a storage-usage hero card (file count,
total size, Upload/Scan actions), category filter chips, and a date-
grouped card list. This introduced a real, user-chosen
`ReportCategory` (BP report / Lab results / Prescriptions / ECG / Other)
and an optional free-text provider/source label per report — both purely
organizational metadata the user assigns themselves; Vitaly never infers
or validates a document's medical category (Section 9, 14). Reports saved
before this existed default to `bpReport` with no provider.

---

## 11. Report Viewer

Create a report viewer for the original document.

Where technically supported, provide:

- Multi-page viewing.
- Zoom.
- Scrolling.
- Page navigation.
- Full-screen viewing.

The original document must remain available.

Extracted information should be displayed separately from the original document.

---

## 12. Linking Confirmed Readings to BP History

After reviewing extracted information, provide an action such as:

> Add confirmed readings to BP History

Only user-confirmed readings may be added.

Imported readings must retain their source.

Example:

    Source: Imported Report

This must remain distinguishable from:

    Source: Manual Entry

Once confirmed and added to BP History, the imported reading must use the same BP data model and classification engine as manually entered readings.

---

## 13. OCR Failure

If Vitaly cannot reliably extract information, display:

> We couldn't reliably read this report.

Provide options to:

- Retry.
- Scan again.
- Import another image/document.
- Save the original report without extracted information.

OCR failure must never prevent the user from saving the original report.

---

## 14. OCR Confidence

If the OCR system provides confidence information, low-confidence medical values should be clearly identified for review.

Example:

    Systolic
    136 mmHg
    Needs review

If confidence information is unavailable, treat all extracted health values as unconfirmed by default.

---

## 15. Medical Safety Requirements

The scanning feature is an information extraction and document organization feature.

It is NOT a diagnostic system.

Vitaly must NOT:

- Diagnose hypertension.
- Diagnose any disease.
- Interpret a doctor's diagnosis as Vitaly's own diagnosis.
- Recommend treatment.
- Recommend medication changes.
- Recommend medication dosage.
- Recommend starting medication.
- Recommend stopping medication.
- Recommend increasing medication.
- Determine whether the user is medically safe.
- Determine whether the user is medically unsafe.
- Automatically create a treatment plan.

If the scanned report contains text such as:

    Hypertension

Vitaly may preserve or display that text as part of the original report.

Vitaly must NOT convert it into:

    You have hypertension.

---

## 16. Privacy & Security

Saved reports may contain sensitive health information.

Requirements:

- Every report must belong to an authenticated user.
- Users must only access their own reports.
- Firebase/database security rules must enforce user-level authorization.
- Private document references must not be publicly accessible.
- Report contents must not be sent to analytics.
- OCR-extracted health information must not be unnecessarily logged.
- Users must be able to delete reports.
- Account deletion must appropriately handle saved reports.
- Caregiver access must not automatically expose reports unless explicitly permitted by Vitaly's existing permission model.

If an external OCR service is used, its privacy, security, data-processing, and regulatory implications must be reviewed before implementation.

---

# PHASE 2 — BP READING STATUS & RANGE CLASSIFICATION

## 17. Feature Objective

Vitaly must provide simple visual feedback when displaying an individual BP reading or calculated BP average.

The purpose is to help users understand where their recorded measurement falls relative to the blood-pressure reference ranges selected for Vitaly.

The system describes the RECORDED READING.

It does NOT diagnose the USER.

---

## 18. Central Classification Engine

Create one centralized service:

    BPClassificationService

All BP classification throughout Vitaly must use this service.

Do NOT create separate classification logic for:

- Dashboard.
- BP History.
- Trends.
- Reports.
- Scanned readings.

The service should receive:

    systolic
    diastolic

and return a classification object containing:

- Category.
- Display label.
- Description.
- Visual status.
- Reference range.
- Category severity/order.

---

## 19. Reference Ranges

The initial implementation should use the clinically reviewed blood-pressure reference framework selected for Vitaly.

Proposed initial categories:

### NORMAL

Systolic:

    < 120

AND

Diastolic:

    < 80

Display:

> Looks good

---

### ELEVATED

Systolic:

    120–129

AND

Diastolic:

    < 80

Display:

> Worth keeping an eye on

---

### HIGHER CATEGORY

Systolic:

    130–139

OR

Diastolic:

    80–89

Display:

> Higher than the usual range

---

### HIGH CATEGORY

Systolic:

    ≥ 140

OR

Diastolic:

    ≥ 90

Display:

> This reading is high

The exact reference framework and user-facing wording MUST be clinically reviewed before production launch.

Do not present the reference ranges as a diagnosis.

---

## 20. Mixed Systolic & Diastolic Categories

Evaluate systolic and diastolic independently.

If the two values fall into different categories, use the higher applicable category.

Example:

    128 / 86

The systolic value falls into the elevated range while the diastolic value falls into the higher category.

Therefore the overall displayed classification should use the higher applicable category.

Never average systolic and diastolic values together for classification.

---

## 21. Visual Status System

Use:

    NORMAL
    Green
    "Looks good"

    ELEVATED
    Yellow
    "Worth keeping an eye on"

    HIGHER CATEGORY
    Orange
    "Higher than the usual range"

    HIGH CATEGORY
    Red
    "This reading is high"

Color must NEVER be the only method of communicating status.

Always combine:

- Color.
- Text.
- Optional icon.

The interface must remain understandable for users with color-vision deficiencies.

---

## 22. Individual Reading Display

Example:

    Latest Reading

    136 / 84 mmHg

    🟠 Higher than the usual range

    Recorded 8:42 AM

The numerical BP reading must remain prominent.

The status should provide context without visually replacing the actual measurement.

---

## 23. Average Reading Display

The classification engine must also support calculated averages.

Example:

    30-Day Average

    136 / 84 mmHg

    🟠 Higher than the usual range

    Average of 20 recorded readings

Clearly identify the value as an average.

Do not present an average as a newly measured BP reading.

Use wording such as:

> Average of 20 recorded readings

instead of:

> Your blood pressure is 136/84.

---

## 24. "Why Am I Seeing This?"

Users should be able to select:

> Why am I seeing this?

Vitaly should explain the classification using the actual recorded values.

Example:

    Why am I seeing this?

    Your recorded blood pressure was
    136/84 mmHg.

    The systolic value falls within the
    130–139 range and the diastolic
    value falls within the 80–89 range.

    This classification describes this
    recorded reading. It is not a diagnosis.

The explanation must be generated from the classification data rather than duplicated separately across screens.

---

## 25. Dashboard Integration

The Dashboard should display the classification for the latest confirmed BP reading.

Example:

    Latest Reading

    136 / 84

    🟠 Higher than the usual range

Do not display diagnostic statements.

---

## 26. BP History Integration

Every applicable BP history record should display its classification.

Example:

    136 / 84
    🟠 Higher than the usual range

    22 Aug 2026 · 8:42 AM

The same BPClassificationService must be used.

---

## 27. Trends Integration

Vitaly may show category changes in calculated averages.

Example:

    Last month
    🟠 Higher than the usual range

    This month
    🟡 Worth keeping an eye on

Use descriptive language:

> Your average recorded reading moved from the higher category to the elevated category.

Do NOT say:

> Your hypertension improved.

Category movement must not be treated as a medical diagnosis.

---

## 28. Reports Integration

Generated BP reports may display:

- Individual readings.
- Calculated averages.
- Classification.
- The reference category used.

The report must clearly distinguish between:

- Measured values.
- Calculated averages.
- Classification.

Do not generate diagnostic conclusions.

---

## 29. Approved User-Facing Language

Preferred:

> Looks good

> Worth keeping an eye on

> Higher than the usual range

> This reading is high

Avoid:

> You have hypertension.

> You are unhealthy.

> You are in danger.

> Your hypertension is getting worse.

> You need medication.

> You need to increase your medication.

> You should stop your medication.

> You are medically safe.

> You are cured.

The system describes the measurement, not the user's medical condition.

---

## 30. No Automatic Emergency Decisions

The classification engine must NOT independently determine that the user is experiencing a medical emergency.

Do not introduce emergency instructions solely from arbitrary thresholds.

If Vitaly later introduces emergency or urgent-care guidance, the exact clinical thresholds, logic, wording, and user experience must undergo appropriate clinical and regulatory review before implementation.

---

## 31. Centralized Reference Configuration

Do NOT scatter numerical thresholds throughout the codebase.

Create a centralized configuration such as:

    BPReferenceRanges

The BPClassificationService must read its thresholds from this configuration.

The reference framework must be versioned so that future clinical updates can be implemented without rewriting the application.

Do not hard-code thresholds independently inside UI components.

---

## 32. Testing Requirements

Create unit tests for BPClassificationService.

Test:

- Normal readings.
- Elevated readings.
- Higher-category readings.
- High readings.
- Systolic-only category changes.
- Diastolic-only category changes.
- Mixed-category readings.
- Boundary values.
- Average readings.
- Missing optional pulse values.

Explicitly test:

    119 / 79
    120 / 79
    129 / 79
    130 / 79
    130 / 80
    139 / 89
    140 / 89
    139 / 90

Classification must be deterministic.

---

# 33. INTEGRATION BETWEEN THE TWO FEATURES

The two features must connect through this exact workflow:

    USER SCANS REPORT
            ↓
    OCR EXTRACTS POSSIBLE BP VALUES
            ↓
    USER REVIEWS VALUES
            ↓
    USER EDITS / DELETES / CORRECTS
            ↓
    USER CONFIRMS
            ↓
    ORIGINAL REPORT IS SAVED
            ↓
    USER OPTIONALLY ADDS CONFIRMED BP VALUES
            ↓
    VALUES ENTER BP HISTORY
            ↓
    BPClassificationService EVALUATES CONFIRMED VALUES
            ↓
    VITALY DISPLAYS BP STATUS

IMPORTANT:

OCR output alone must NEVER:

- Enter BP History.
- Trigger BP classification.
- Generate a diagnosis.
- Generate treatment recommendations.

Only user-confirmed BP values may enter the BP classification workflow.

---

# 34. Overall Regulatory/Product Boundary

These two features are intended to:

- Record information.
- Extract information.
- Organize information.
- Calculate averages.
- Classify recorded measurements according to a selected reference framework.
- Display understandable status information.

They must NOT independently:

- Diagnose diseases.
- Prescribe medication.
- Recommend medication changes.
- Create treatment plans.
- Determine that a user has hypertension.
- Determine that a user is medically safe.
- Make autonomous clinical decisions.

If implementation of either feature requires functionality beyond these boundaries, STOP implementation of that part and flag it for product, clinical, and regulatory review.

---

# 35. Combined Definition of Done

## Scan BP Report

The feature is complete when the user can:

1. Tap "Scan BP Report".
2. Scan or import a report.
3. Preview the document.
4. Process the document using OCR where supported.
5. Review extracted information.
6. Edit incorrect values.
7. Delete incorrect values.
8. Add missing information.
9. Confirm extracted information.
10. Save the original document.
11. View the document later in Saved Reports.
12. Rename the report.
13. Delete the report.
14. Save the original report even if OCR fails.
15. Optionally add confirmed BP readings to BP History.
16. See that imported readings have the source "Imported Report".

## BP Reading Status

The feature is complete when the user can:

1. See a status for an individual BP reading.
2. See a status for calculated BP averages.
3. Understand why the status was assigned.
4. See the status consistently across Dashboard, BP History, Trends, and Reports.
5. See accessible text and visual indicators.
6. Receive descriptive feedback without receiving a diagnosis.
7. Have all classifications generated by the centralized BPClassificationService.

## Combined Requirement

A confirmed BP value extracted from a scanned report must behave exactly like a manually entered BP value after confirmation, while retaining:

    Source: Imported Report

No unconfirmed OCR result may enter BP History or trigger BP classification.

---

# 36. IMPLEMENTATION ORDER

Claude must implement these features in the following order.

## PHASE 1

Implement:

> Scan BP Report & Saved Reports

Complete the entire feature, including:

- Scanning/import.
- OCR.
- Review.
- Editing.
- Deleting incorrect extracted values.
- User confirmation.
- Original document storage.
- Saved Reports.
- Report viewer.
- Report deletion.
- OCR failure handling.
- Security/privacy requirements.
- Optional linking of confirmed readings to BP History.

Run tests and fix issues before moving to Phase 2.

## PHASE 2

Implement:

> BP Reading Status & Range Classification

Complete:

- Central BPClassificationService.
- Reference range configuration.
- Classification logic.
- Green/yellow/orange/red status system.
- User-facing wording.
- Dashboard integration.
- BP History integration.
- Trends integration.
- Average classification.
- Explanation/"Why am I seeing this?" functionality.
- Unit tests and boundary tests.

Then integrate Phase 2 with the confirmed readings produced by Phase 1.

Do NOT implement unrelated features as part of this specification.
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

Features still deferred, pending future approval, include:

- medication tracking (Section 18)
- caregiver or family features (Section 27)
- advanced trend analysis and extended historical analytics (Section 27)

Two items originally listed here have since been approved and implemented,
and are no longer deferred:

- concerning-reading classification against an approved (versioned)
  reference-range standard (Section 14; see the BP Reading Status & Range
  Classification feature spec below)
- PDF and full ZIP data export (Section 28)

None of the still-deferred items should be implemented ahead of explicit approval of their respective scope, sources, and safety review, consistent with the caution expressed throughout Sections 13–16.

---

# 40. Open Questions and Risks

**Resolved:**

- **Authentication provider** — Firebase Authentication (email/password and Google Sign-In), implemented and verified live (Section 20).
- **Backend provider and database architecture** — Firebase: Cloud Firestore (sync) and Firebase Storage (scanned report files) (Section 21).
- **Local storage technology** — Drift (SQLite), local-first with Firestore sync; schema currently at v5 (Section 22).
- **State management package** — Riverpod, used consistently throughout (Section 32).
- **Accepted input validation ranges** — implemented in `ReadingValidator`: systolic 60–260 mmHg, diastolic 30–150 mmHg, pulse 30–220 bpm, worded as application-accepted ranges rather than diagnostic thresholds (Section 7).
- **Concerning-reading classification standard** — pursued and implemented as `BPClassificationService` against versioned (v1) reference ranges, categorizing systolic/diastolic independently and taking the higher-severity category; see the full BP Reading Status & Range Classification feature spec below (Sections 17–32 of that feature spec, referenced from Section 14).
- **Authoritative sources for educational content** — existing articles cite the American Heart Association (heart.org) (Sections 15–16).
- **Export format and privacy handling for reports** — approved and implemented: a non-diagnostic Trends-summary PDF, and a full data export (BP readings CSV + the user's own saved report files) packaged as one ZIP and shared via the system Share/Save flow (Section 28).

**Still open — must be resolved before the relevant work begins:**

- **Legal/privacy requirements per launch market** — not yet reviewed; no market-specific legal review has been performed (Section 25).

**Key risk:** because Vitaly touches health data and hypertension-adjacent language, the primary product risk is scope creep into diagnostic or treatment territory — through trend language, classification labels, or educational content — without the explicit review process described in Sections 12–16. All contributors should treat that boundary as a hard constraint, not a style preference.