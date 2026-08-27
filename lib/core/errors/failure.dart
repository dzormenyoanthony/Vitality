/// Base type for user-facing failures.
///
/// Repositories and use cases return a [Failure] instead of throwing raw
/// exceptions, so the presentation layer never has to handle or display
/// internal stack traces (CLAUDE.md §12).
sealed class Failure {
  const Failure(this.message);

  /// A short, understandable message safe to show to the user.
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Please try again.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}

/// The user backed out of a flow themselves (e.g. dismissed the Google
/// account picker) — distinct from [ValidationFailure] so callers can
/// choose not to display this as an error at all, rather than showing a
/// false "something went wrong" message for a normal cancel.
final class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Sign-in was cancelled.']);
}

/// Extracts a safe, user-facing message from anything a repository might
/// throw. Non-[Failure] errors (a bug, an unmapped exception) fall back to
/// a generic message rather than surfacing internals (CLAUDE.md §12).
String friendlyMessage(Object error) {
  return error is Failure ? error.message : const UnexpectedFailure().message;
}
