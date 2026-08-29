# tool/

Repo maintenance scripts. Run all of these from the repository root.

## `check_hardcoded_strings.dart`

Localization guardrail for PROJECT_SPEC.md §36: fails if a user-facing
string literal is hard-coded in the widget tree instead of coming from
`AppLocalizations`.

```bash
dart run tool/check_hardcoded_strings.dart
```

It scans `lib/**/*.dart` for the argument positions where user copy almost
always appears (`Text('…')`, `TextSpan(text: '…')`, `labelText:` /
`hintText:` / `helperText:` / `tooltip:` / `semanticLabel:` `'…'`,
`Semantics(label: '…')`) and reports any bare string literal with two or
more letters.

A short in-file allowlist covers content that is deliberately not
localized: the generated localizations, article bodies (data-layer
content), the data-export CSV schema (an interchange format with
spec-pinned English headers, §28), and backend/auth error messages mapped
from provider error codes.

There is no CI pipeline in this repo yet. When one is added, run this
script alongside `flutter analyze` and `flutter test`.
