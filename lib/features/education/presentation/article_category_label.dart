import '../../../l10n/app_localizations.dart';
import '../data/article.dart';

/// Localized section names for [ArticleCategory] (PROJECT_SPEC.md §36).
/// The article bodies themselves stay in the data layer as content; only
/// these short section labels are externalized.
extension ArticleCategoryLabel on ArticleCategory {
  String label(AppLocalizations l10n) => switch (this) {
    ArticleCategory.basics => l10n.articleCategoryBasics,
    ArticleCategory.measuringWell => l10n.articleCategoryMeasuringWell,
    ArticleCategory.workingWithClinician =>
      l10n.articleCategoryWorkingWithClinician,
  };
}
