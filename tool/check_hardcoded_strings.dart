// Fails if a user-facing string literal is hard-coded in the widget tree
// instead of coming from AppLocalizations (PROJECT_SPEC.md §36).
//
// Run from the repo root:
//   dart run tool/check_hardcoded_strings.dart
//
// It is intentionally a lint-by-grep, not a full analyzer: it flags the
// argument positions where user copy almost always appears —
//   Text('...'), Text.rich(TextSpan(text: '...')),
//   labelText:/hintText:/helperText:/tooltip:/semanticLabel: '...',
//   Semantics(label: '...'), SnackBar(content: Text('...'))
// — when the value is a bare string literal containing two or more letters.
//
// Allowlisted files hold content that is deliberately not localized:
// data-layer article/CSV content, mapped backend error messages, and the
// generated localizations themselves. See the comments on each entry.

import 'dart:io';

/// Files whose string literals are deliberately not routed through
/// AppLocalizations. Keep this list short and commented.
const _allowlist = <String>{
  // Generated + hand-written localization sources.
  'lib/l10n/app_localizations.dart',
  'lib/l10n/app_localizations_en.dart',
  // Article bodies are content, kept in the data layer by decision; they
  // still need an approved-source review before any change (§15, §37).
  'lib/features/education/data/article_repository.dart',
  // The data export CSV has a schema with exact English column names that
  // a clinician's tools parse (PROJECT_SPEC.md §28) — it is an interchange
  // format, not localized UI.
  'lib/features/data_export/domain/bp_readings_csv.dart',
  // Backend/auth error strings are mapped from provider error codes deep
  // in the data layer; localizing them needs an error-code -> key refactor
  // tracked separately.
  'lib/core/errors/failure.dart',
  'lib/features/authentication/data/firebase_auth_repository.dart',
  'lib/features/authentication/data/fake_auth_repository.dart',
};

final _patterns = <RegExp>[
  RegExp(r'''\bText\(\s*['"]([^'"]*[A-Za-z]{2}[^'"]*)['"]'''),
  RegExp(r'''\bTextSpan\(\s*text:\s*['"]([^'"]*[A-Za-z]{2}[^'"]*)['"]'''),
  RegExp(
    r'''\b(?:labelText|hintText|helperText|tooltip|semanticLabel|semanticsLabel):\s*['"]([^'"]*[A-Za-z]{2}[^'"]*)['"]''',
  ),
  RegExp(r'''\bSemantics\(\s*label:\s*['"]([^'"]*[A-Za-z]{2}[^'"]*)['"]'''),
];

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Run this from the repository root.');
    exit(2);
  }

  final violations = <String>[];
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll(r'\', '/');
    if (_allowlist.contains(path)) continue;
    if (path.endsWith('.g.dart')) continue;

    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimLeft().startsWith('//')) continue;
      for (final pattern in _patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          violations.add('$path:${i + 1}: ${match.group(1)}');
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('OK: no hard-coded user-facing strings in lib/.');
    return;
  }

  stderr.writeln(
    'Hard-coded user-facing string(s) found — route these through '
    'AppLocalizations (PROJECT_SPEC.md §36):',
  );
  for (final v in violations) {
    stderr.writeln('  $v');
  }
  exit(1);
}
