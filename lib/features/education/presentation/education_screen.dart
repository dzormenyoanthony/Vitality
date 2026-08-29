import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/i18n/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/article.dart';
import 'article_category_label.dart';
import 'education_providers.dart';

/// Per-article icon, cycling through the same 4-accent palette used
/// elsewhere in the app (mint/coral/purple/blue) in reading order — purely
/// decorative categorization, never a severity signal (PROJECT_SPEC.md §9,
/// §14). Matches `design_references/Learn.png`.
const _rowIcons = [
  Icons.monitor_heart_outlined,
  Icons.scatter_plot_outlined,
  Icons.devices_outlined,
  Icons.favorite_border,
  Icons.medication_outlined,
  Icons.description_outlined,
  Icons.show_chart,
];

/// Educational content library (PROJECT_SPEC.md §15, §16): general
/// information about blood pressure and measurement, grouped by category.
/// Never personalized advice about the user's own readings.
///
/// Visual design matches `design_references/Learn.png`: the first Basics
/// article is featured as a large card, and every other article (including
/// the rest of Basics) is a flat icon row grouped under its category.
class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final articles = ref.watch(articlesProvider);
    final byCategory = <ArticleCategory, List<Article>>{
      for (final category in ArticleCategory.values)
        category: articles.where((a) => a.category == category).toList(),
    };
    final basics = byCategory[ArticleCategory.basics]!;
    final featured = basics.isNotEmpty ? basics.first : null;
    final remainingBasics = basics.length > 1 ? basics.sublist(1) : const <Article>[];

    var rowIndex = 0;
    final pairs = accents.accents;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(l10n.educationTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.educationIntro,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (featured != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _FeaturedArticleCard(
                article: featured,
                categoryLabel: ArticleCategory.basics.label(l10n),
              ),
            ],
            if (remainingBasics.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                ArticleCategory.basics.label(l10n).toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(color: AppColors.dashboardAccentTeal),
              ),
              const Divider(height: AppSpacing.md),
              for (var i = 0; i < remainingBasics.length; i++) ...[
                _ArticleRow(
                  article: remainingBasics[i],
                  icon: _rowIcons[rowIndex % _rowIcons.length],
                  colors: pairs[rowIndex++ % pairs.length],
                ),
                if (i != remainingBasics.length - 1) const Divider(height: 1),
              ],
            ],
            for (final category in ArticleCategory.values.skip(1))
              if (byCategory[category]!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  category.label(l10n).toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(color: AppColors.dashboardAccentTeal),
                ),
                const Divider(height: AppSpacing.md),
                for (var i = 0; i < byCategory[category]!.length; i++) ...[
                  _ArticleRow(
                    article: byCategory[category]![i],
                    icon: _rowIcons[rowIndex % _rowIcons.length],
                    colors: pairs[rowIndex++ % pairs.length],
                  ),
                  if (i != byCategory[category]!.length - 1) const Divider(height: 1),
                ],
              ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.educationFooter,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  const _FeaturedArticleCard({required this.article, required this.categoryLabel});

  final Article article;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;

    return Material(
      color: accents.mintBackground,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        onTap: () => context.push(AppRoutes.educationArticlePath(article.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.dashboardAccentCoral,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  categoryLabel.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                article.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.articleReviewedLine(
                  article.readTimeMinutes,
                  formatMonthYear(context, article.reviewed),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article, required this.icon, required this.colors});

  final Article article;
  final IconData icon;
  final (Color background, Color foreground) colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => context.push(AppRoutes.educationArticlePath(article.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.$1,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: colors.$2, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    l10n.articleRowSubtitle(article.summary, article.readTimeMinutes),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
