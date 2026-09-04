/// Superwall placement identifiers gating Vitaly's premium features
/// (PROJECT_SPEC.md §27). These must match the placement names created in
/// the Superwall dashboard exactly, or a placement will never resolve to a
/// campaign/paywall.
abstract final class PaywallPlacements {
  static const String scanReport = 'scan_report';
  static const String uploadPdfReport = 'upload_pdf_report';
  static const String exportReportData = 'export_report_data';

  /// A recurring nudge for signed-in users without an active subscription:
  /// registered right after onboarding, on every later cold start, and on
  /// every return to the foreground. Unlike the placements above it gates
  /// nothing: everyone reaches the dashboard whether or not they purchase.
  /// The campaign for this placement must stay configured "not gated" in
  /// the Superwall dashboard, with a non-subscriber audience rule (and any
  /// desired frequency capping) controlling how often it actually
  /// presents — the app just registers it every time.
  static const String onboardingComplete = 'onboarding_complete';
}
