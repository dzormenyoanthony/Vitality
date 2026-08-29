import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/i18n/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/article.dart';
import 'article_category_label.dart';
import 'education_providers.dart';

/// A single educational article (PROJECT_SPEC.md §15, §16). General
/// information only — reviewed date and source are always shown so the
/// content is clearly informational rather than personalized advice.
///
/// The "How to take a reading at home" article gets the richer numbered-step
/// + illustrated cuff-placement layout from `design_references/Measure
/// well.png`; every other article keeps the plain flowing-paragraph layout.
class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({required this.articleId, super.key});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final article = ref.watch(articleByIdProvider(articleId));

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.educationTitle)),
        body: Center(child: Text(l10n.articleNotFound)),
      );
    }

    final reviewedLabel = formatMonthYearFull(context, article.reviewed);

    return Scaffold(
      appBar: AppBar(title: Text(article.category.label(l10n))),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(article.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.articleDetailMetaLine(article.readTimeMinutes, reviewedLabel),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (article.id == 'how-to-measure-at-home')
            ..._measuringAtHomeBody(context, article)
          else
            for (final paragraph in article.body) ...[
              Text(paragraph, style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.md),
            ],
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.articleSourceLine(article.source), style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.articleDisclaimer, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// The intro paragraph is [article.body]'s first entry, verbatim. The rest
/// of this layout re-presents the same already-approved sentences from
/// [article.body] (the "before you measure" and "while you measure"
/// paragraphs) as a numbered list and a trailing paragraph — no new claims,
/// just a closer visual match to `design_references/Measure well.png`.
List<Widget> _measuringAtHomeBody(BuildContext context, Article article) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context);
  return [
    Text(article.body.first, style: theme.textTheme.bodyLarge),
    const SizedBox(height: AppSpacing.lg),
    _SectionLabel(l10n.measureWellBeforeYouMeasure),
    const SizedBox(height: AppSpacing.sm),
    _NumberedStep(number: '01', text: l10n.measureWellStep1),
    _NumberedStep(number: '02', text: l10n.measureWellStep2),
    _NumberedStep(number: '03', text: l10n.measureWellStep3),
    const SizedBox(height: AppSpacing.sm),
    _SectionLabel(l10n.measureWellCuffPlacement),
    const SizedBox(height: AppSpacing.sm),
    const _CuffPlacementDiagram(),
    const SizedBox(height: AppSpacing.lg),
    Text(l10n.measureWellCuffParagraph, style: theme.textTheme.bodyLarge),
    const SizedBox(height: AppSpacing.md),
    Text(article.body[3], style: theme.textTheme.bodyLarge),
    const SizedBox(height: AppSpacing.md),
  ];
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: AppColors.dashboardAccentTeal),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              number,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.dashboardAccentTeal,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// Simplified illustration of correct cuff placement — an arm with the cuff
/// centred over it, a "heart level" reference line, a device readout, and
/// the "2 cm above the elbow crease" callout — matching
/// `design_references/Measure well.png`. Purely illustrative, not a
/// real reading (the device numbers are fixed placeholders).
class _CuffPlacementDiagram extends StatelessWidget {
  const _CuffPlacementDiagram();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accents.mintBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 170,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 36,
                  child: Row(
                    children: [
                      _DashedLine(color: accents.mintForeground),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.measureWellHeartLevel,
                        style: theme.textTheme.labelSmall?.copyWith(color: accents.mintForeground),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 68,
                  right: 78,
                  top: 58,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.onboardingIllustrationBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
                Positioned(
                  left: 130,
                  top: 42,
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.dashboardAccentTeal,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '128',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          l10n.measureWellDiagramReadingUnit,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 80,
                  right: 0,
                  top: 128,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 60, height: 1.5, color: theme.colorScheme.error),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.measureWellElbowCallout,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.measureWellDiagramCaption,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Container(width: 8, height: 2, color: color),
          ),
      ],
    );
  }
}
