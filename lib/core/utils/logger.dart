import 'dart:developer' as developer;

/// Single choke point for app logging.
///
/// Routing all logging through here (rather than scattered `print()`/
/// `debugPrint()` calls) gives later phases one place to enforce "never log
/// passwords, tokens, or health measurements" (PROJECT_SPEC.md §32).
abstract final class AppLogger {
  static void info(String message) {
    developer.log(message, name: 'vitaly');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'vitaly',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
