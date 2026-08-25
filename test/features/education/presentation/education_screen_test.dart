import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/education/data/article_repository.dart';
import 'package:vitality/features/education/presentation/education_screen.dart';

void main() {
  testWidgets('renders category headers and article titles', (tester) async {
    // The full article list is taller than the default test viewport;
    // enlarge it so every item is laid out without needing to scroll.
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: EducationScreen()),
      ),
    );
    await tester.pump();

    // Once as the featured card's category badge, once as the section
    // header for the rest of the Basics articles.
    expect(find.text('BASICS'), findsNWidgets(2));
    expect(find.text('MEASURING WELL'), findsOneWidget);
    expect(find.text('WORKING WITH YOUR CLINICIAN'), findsOneWidget);

    for (final article in ArticleRepository.all()) {
      expect(find.text(article.title), findsOneWidget);
    }
  });
}
