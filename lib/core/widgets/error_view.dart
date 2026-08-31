import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Shared error state with an understandable message and an optional retry
/// action (PROJECT_SPEC.md §12: "do not expose raw stack traces...",
/// §24: errors should provide a useful next action).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // A scrollable Center, not a bare one: at large system text sizes the
    // message can wrap to enough lines that icon + message + retry button
    // no longer fit the available height — scrolling keeps everything
    // reachable instead of overflowing (CLAUDE.md §8).
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).commonTryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
