import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/article.dart';
import '../data/article_repository.dart';

/// All available educational articles (PROJECT_SPEC.md §15, §16). Static
/// content, so a plain [Provider] rather than a stream/repository provider.
final articlesProvider = Provider<List<Article>>((ref) => ArticleRepository.all());

final articleByIdProvider = Provider.family<Article?, String>(
  (ref, id) => ArticleRepository.byId(id),
);
