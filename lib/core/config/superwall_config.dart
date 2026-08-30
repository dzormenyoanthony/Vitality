/// The Superwall public API key, supplied at build time rather than
/// hard-coded in source (CLAUDE.md §10).
///
/// Superwall's key is a *publishable* key (safe to ship inside a compiled
/// app, like a Stripe publishable key) but it still must not sit in
/// version control as a literal: run/build with
/// `--dart-define=SUPERWALL_API_KEY=pk_...`, or put that same flag in a
/// gitignored `config/superwall.json` and pass
/// `--dart-define-from-file=config/superwall.json`.
///
/// Empty when unset — [isConfigured] lets startup code skip initialization
/// gracefully instead of calling the SDK with a blank key.
abstract final class SuperwallConfig {
  static const String apiKey = String.fromEnvironment('SUPERWALL_API_KEY');

  static bool get isConfigured => apiKey.isNotEmpty;
}
