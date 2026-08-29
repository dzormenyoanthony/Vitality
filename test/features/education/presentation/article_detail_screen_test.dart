import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/analytics/analytics_providers.dart';
import 'package:vitality/features/education/data/article_repository.dart';
import 'package:vitality/features/education/presentation/article_detail_screen.dart';

import '../../../support/fake_analytics_service.dart';
import '../../../support/pump_app.dart';

void main() {
  testWidgets('renders the article title, source, and safety footer, and logs the open', (tester) async {
    final article = ArticleRepository.all().first;
    final analytics = FakeAnalyticsService();

    // Article bodies are taller than the default test viewport; enlarge it
    // so the source/footer at the bottom are laid out without scrolling.
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
        child: MaterialApp(
          localizationsDelegates: localizationWrappers,
          supportedLocales: testSupportedLocales,
          home: ArticleDetailScreen(articleId: article.id),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(article.title), findsOneWidget);
    expect(find.textContaining('Source: ${article.source}'), findsOneWidget);
    expect(find.textContaining('contact a clinician or emergency services'), findsOneWidget);
    // PROJECT_SPEC.md §26 — educational content opened, keyed by content slug.
    expect(analytics.events, ['educational_content_opened:${article.id}']);
  });

  testWidgets('shows a fallback message for an unknown article id', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: localizationWrappers,
          supportedLocales: testSupportedLocales,
          home: ArticleDetailScreen(articleId: 'does-not-exist'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('This article is no longer available.'), findsOneWidget);
  });
}
