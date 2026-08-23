import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/education/data/article_repository.dart';
import 'package:vitality/features/education/presentation/article_detail_screen.dart';

void main() {
  testWidgets('renders the article title, source, and safety footer', (tester) async {
    final article = ArticleRepository.all().first;

    // Article bodies are taller than the default test viewport; enlarge it
    // so the source/footer at the bottom are laid out without scrolling.
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: ArticleDetailScreen(articleId: article.id)),
      ),
    );
    await tester.pump();

    expect(find.text(article.title), findsOneWidget);
    expect(find.textContaining('Source: ${article.source}'), findsOneWidget);
    expect(find.textContaining('contact a clinician or emergency services'), findsOneWidget);
  });

  testWidgets('shows a fallback message for an unknown article id', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ArticleDetailScreen(articleId: 'does-not-exist')),
      ),
    );
    await tester.pump();

    expect(find.text('This article is no longer available.'), findsOneWidget);
  });
}
