Start implementing the Superwall paywall integration for Vitaly.

Do this carefully and step by step. First inspect the current project, its Flutter dependencies, authentication setup, routing, existing premium-related code, and the current implementations of Scan Report, Upload/Import PDF Report, and Export Report/Data.

The goal is to add Superwall without redesigning the app or breaking existing functionality.

PREMIUM FEATURES TO PROTECT:

1. Scan BP Report
2. Upload/import a PDF report for extracting or filling BP readings
3. Export reports or user data

Create these Superwall placement identifiers:

- scan_report
- upload_pdf_report
- export_report_data

REQUIRED BEHAVIOUR:

SCAN REPORT:
When the user taps "Scan BP Report":
→ Trigger the Superwall placement "scan_report"
→ If the user has premium access, continue into the existing scanner flow
→ If the user does not have access, present the Superwall paywall
→ If the paywall is dismissed without access, do not open the scanner
→ If access is successfully granted, allow the user to continue

UPLOAD/IMPORT PDF:
When the user taps the PDF upload/import action:
→ Trigger "upload_pdf_report"
→ Check/show the Superwall paywall before opening the file picker
→ Only allow the PDF import flow to continue when premium access is granted

EXPORT:
When the user taps Export Report or Export Data:
→ Trigger "export_report_data"
→ Check/show the Superwall paywall before generating or exposing any export file
→ Only continue with the export when premium access is granted

ARCHITECTURE REQUIREMENTS:

- Use the official Superwall Flutter SDK.
- Integrate Superwall according to its current official Flutter documentation.
- Do not hard-code secret credentials.
- Do not place secret keys insecurely in the Flutter source.
- Keep premium access logic centralized.
- Do not duplicate paywall logic across multiple screens.
- Create or use a reusable premium/paywall access service consistent with the existing Vitaly architecture.
- Ensure users cannot bypass the premium gate through direct navigation or another entry point.
- Keep the existing UI unchanged unless a loading state is genuinely required.
- Do not modify unrelated features or completed screen designs.
- Preserve the existing Firebase authentication and navigation flow.

PAYMENT AND ACCESS:

For now, integrate Superwall as the paywall and entitlement/access layer in a way that is compatible with the existing project architecture.

If a separate purchase/subscription provider such as RevenueCat is required for the production purchase flow, do not guess or silently create a second subscription system. Inspect the existing project and clearly identify the correct integration architecture before implementing purchases.

Handle:
- Paywall presentation
- Paywall dismissal
- Purchase success
- Purchase cancellation
- Purchase failure
- Restore purchases
- App restart with an active subscription

IMPORTANT:
Do not merely add the Superwall package and stop. Fully wire the three premium actions to the paywall flow.

IMPLEMENTATION ORDER:

1. Inspect the current project and identify the correct integration points.
2. Add/configure the Superwall Flutter SDK.
3. Initialize Superwall correctly during app startup.
4. Create the centralized premium/paywall access layer.
5. Add the three placements.
6. Connect Scan BP Report.
7. Connect Upload/Import PDF Report.
8. Connect Export Report/Data.
9. Verify the protected feature only executes after access is granted.
10. Test non-premium and premium flows as far as the current environment allows.
11. Run flutter analyze and the relevant tests/build.
12. Fix all errors introduced by the implementation.

Before finishing, give me a short report containing:
- What was implemented
- The exact placement IDs used
- Which files were changed
- What manual setup I still need to do in the Superwall dashboard
- Whether Google Play Console or App Store Connect setup is still required
- Whether another service such as RevenueCat is required for actual subscription purchases

Start by inspecting the existing project, then implement the integration. Do not redesign the UI.