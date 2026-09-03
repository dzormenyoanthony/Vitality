/// Superwall placement identifiers gating Vitaly's premium features
/// (PROJECT_SPEC.md §27). These must match the placement names created in
/// the Superwall dashboard exactly, or a placement will never resolve to a
/// campaign/paywall.
abstract final class PaywallPlacements {
  static const String scanReport = 'scan_report';
  static const String uploadPdfReport = 'upload_pdf_report';
  static const String exportReportData = 'export_report_data';

  /// Shown once, right after a user finishes onboarding, before the
  /// dashboard. Unlike the placements above it gates nothing: Superwall
  /// skips it for users with an active subscription, and everyone else
  /// reaches the dashboard whether or not they purchase. The campaign for
  /// this placement must be configured "not gated" in the Superwall
  /// dashboard.
  static const String onboardingComplete = 'onboarding_complete';
}
