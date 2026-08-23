/// Grouping used to organize the education library (PROJECT_SPEC.md §15,
/// §16), mirroring the "Basics" / "Measuring well" / "Working with your
/// clinician" sections in the approved design references.
enum ArticleCategory {
  basics('Basics'),
  measuringWell('Measuring well'),
  workingWithClinician('Working with your clinician');

  const ArticleCategory(this.label);

  final String label;
}

/// A single piece of general educational content (PROJECT_SPEC.md §15,
/// §16). Content is informational only — never personalized advice about a
/// user's own readings, and never a numeric BP classification (that
/// requires separate approval; see §14).
final class Article {
  const Article({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.readTimeMinutes,
    required this.reviewed,
    required this.source,
    required this.body,
  });

  final String id;
  final ArticleCategory category;
  final String title;
  final String summary;
  final int readTimeMinutes;
  final DateTime reviewed;
  final String source;
  final List<String> body;
}
