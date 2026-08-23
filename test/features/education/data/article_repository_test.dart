import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/education/data/article_repository.dart';

void main() {
  test('returns a non-empty list of articles', () {
    expect(ArticleRepository.all(), isNotEmpty);
  });

  test('every article has a unique id', () {
    final ids = ArticleRepository.all().map((a) => a.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every article cites a non-empty source and has body content', () {
    for (final article in ArticleRepository.all()) {
      expect(article.source, isNotEmpty, reason: article.id);
      expect(article.body, isNotEmpty, reason: article.id);
    }
  });

  test('no article mentions numeric BP classification staging', () {
    // Staging thresholds are gated behind a separate, not-yet-approved
    // decision (PROJECT_SPEC.md §14) and must never appear as "education".
    for (final article in ArticleRepository.all()) {
      final text = article.body.join(' ').toLowerCase();
      expect(text, isNot(contains('stage 1')));
      expect(text, isNot(contains('stage 2')));
      expect(text, isNot(contains('hypertensive crisis')));
    }
  });

  test('byId returns the matching article, and null for an unknown id', () {
    final first = ArticleRepository.all().first;
    expect(ArticleRepository.byId(first.id), same(first));
    expect(ArticleRepository.byId('does-not-exist'), isNull);
  });
}
