import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../data/article.dart';
import 'education_providers.dart';

/// Educational content library (PROJECT_SPEC.md §15, §16): general
/// information about blood pressure and measurement, grouped by category.
/// Never personalized advice about the user's own readings.
class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final articles = ref.watch(articlesProvider);
    final byCategory = <ArticleCategory, List<Article>>{
      for (final category in ArticleCategory.values)
        category: articles.where((a) => a.category == category).toList(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'General information about blood pressure and measurement. Not '
            'advice about your own readings.',
            style: theme.textTheme.bodyLarge,
          ),
          for (final category in ArticleCategory.values)
            if (byCategory[category]!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                category.label.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Column(
                  children: [
                    for (final article in byCategory[category]!)
                      _ArticleTile(article: article),
                  ],
                ),
              ),
            ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Sources listed on each article. If you feel unwell, contact a '
            'clinician or emergency services.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push(AppRoutes.educationArticlePath(article.id)),
      title: Text(article.title),
      subtitle: Text('${article.summary} · ${article.readTimeMinutes} min'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
