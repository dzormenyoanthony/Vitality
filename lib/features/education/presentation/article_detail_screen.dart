import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import 'education_providers.dart';

/// A single educational article (PROJECT_SPEC.md §15, §16). General
/// information only — reviewed date and source are always shown so the
/// content is clearly informational rather than personalized advice.
class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({required this.articleId, super.key});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final article = ref.watch(articleByIdProvider(articleId));

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learn')),
        body: const Center(child: Text('This article is no longer available.')),
      );
    }

    final reviewed = article.reviewed;
    final reviewedLabel =
        '${_monthName(reviewed.month)} ${reviewed.year}';

    return Scaffold(
      appBar: AppBar(title: Text(article.category.label)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(article.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${article.readTimeMinutes} min read · Reviewed $reviewedLabel · '
            'General information',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final paragraph in article.body) ...[
            Text(paragraph, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text('Source: ${article.source}', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This is general information, not personalized medical advice. '
            'If you feel unwell, contact a clinician or emergency services.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  static String _monthName(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}
