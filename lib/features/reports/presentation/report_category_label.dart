import '../../../l10n/app_localizations.dart';
import '../domain/saved_report.dart';

/// Localized labels for the user-chosen [ReportCategory] tag, shared by the
/// Saved Reports locker and the review screen (PROJECT_SPEC.md §36). Takes
/// an [AppLocalizations] because the enum is rendered from more than one
/// widget with no single owner.
extension ReportCategoryLabel on ReportCategory {
  String label(AppLocalizations l10n) => switch (this) {
    ReportCategory.bpReport => l10n.reportCategoryBpReport,
    ReportCategory.labResults => l10n.reportCategoryLabResults,
    ReportCategory.prescriptions => l10n.reportCategoryPrescriptions,
    ReportCategory.ecg => l10n.reportCategoryEcg,
    ReportCategory.other => l10n.reportCategoryOther,
  };
}
