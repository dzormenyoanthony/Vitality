/// Superwall placement identifiers gating Vitaly's premium features
/// (PROJECT_SPEC.md §27). These must match the placement names created in
/// the Superwall dashboard exactly, or a placement will never resolve to a
/// campaign/paywall.
abstract final class PaywallPlacements {
  static const String scanReport = 'scan_report';
  static const String uploadPdfReport = 'upload_pdf_report';
  static const String exportReportData = 'export_report_data';
}
