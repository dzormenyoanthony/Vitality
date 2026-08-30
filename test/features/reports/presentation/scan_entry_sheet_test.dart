import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:vitality/core/constants/app_routes.dart';
import 'package:vitality/core/paywall/paywall_providers.dart';
import 'package:vitality/features/reports/data/report_providers.dart';
import 'package:vitality/features/reports/domain/document_scanner_service.dart';
import 'package:vitality/features/reports/presentation/scan_entry_sheet.dart';

import '../../../support/fake_paywall_service.dart';
import '../../../support/pump_app.dart';

/// Records how many times [scan] is invoked, returning no pages — enough
/// to distinguish "the paywall let the scan flow start" from "it didn't"
/// without touching the real camera plugin.
class _FakeDocumentScannerService implements DocumentScannerService {
  int callCount = 0;

  @override
  Future<ScannedDocument?> scan() async {
    callCount++;
    return null;
  }
}

/// A single button wired to [onTap], so `scanWithCamera`/`importFromDevice`
/// (superwall_paywall.md's SCAN REPORT / UPLOAD PDF gates) can be exercised
/// directly without the full Saved Reports screen and its Drift stream.
class _TriggerButton extends ConsumerWidget {
  const _TriggerButton({required this.onTap});

  final Future<void> Function(BuildContext, WidgetRef) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Builder(
        builder: (buttonContext) => ElevatedButton(
          onPressed: () => onTap(buttonContext, ref),
          child: const Text('trigger'),
        ),
      ),
    );
  }
}

void main() {
  group('scanWithCamera (scan_report placement)', () {
    testWidgets('does not open the scanner when the paywall denies access', (
      tester,
    ) async {
      final paywall = FakePaywallService(grantsAccess: false);
      final scanner = _FakeDocumentScannerService();

      await pumpApp(
        tester,
        _TriggerButton(onTap: scanWithCamera),
        overrides: [
          paywallServiceProvider.overrideWithValue(paywall),
          documentScannerServiceProvider.overrideWithValue(scanner),
        ],
      );

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(paywall.registeredPlacements, ['scan_report']);
      expect(scanner.callCount, 0);
    });

    testWidgets('opens the scanner when the paywall grants access', (
      tester,
    ) async {
      final paywall = FakePaywallService(grantsAccess: true);
      final scanner = _FakeDocumentScannerService();
      final router = GoRouter(
        initialLocation: '/trigger',
        routes: [
          GoRoute(
            path: '/trigger',
            builder: (context, state) => Consumer(
              builder: (context, ref, _) =>
                  _TriggerButton(onTap: scanWithCamera),
            ),
          ),
          GoRoute(
            path: AppRoutes.reviewExtracted,
            builder: (context, state) => const Scaffold(body: Text('Review')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paywallServiceProvider.overrideWithValue(paywall),
            documentScannerServiceProvider.overrideWithValue(scanner),
          ],
          child: MaterialApp.router(
            localizationsDelegates: localizationWrappers,
            supportedLocales: testSupportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(paywall.registeredPlacements, ['scan_report']);
      expect(scanner.callCount, 1);
    });
  });

  group('importFromDevice (upload_pdf_report placement)', () {
    testWidgets('does not attempt an import when the paywall denies access', (
      tester,
    ) async {
      final paywall = FakePaywallService(grantsAccess: false);

      await pumpApp(
        tester,
        _TriggerButton(onTap: importFromDevice),
        overrides: [paywallServiceProvider.overrideWithValue(paywall)],
      );

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(paywall.registeredPlacements, ['upload_pdf_report']);
      // The import flow never ran, so it never hit the file-picker plugin
      // and never surfaced its (caught) failure as a snackbar.
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('attempts the import when the paywall grants access', (
      tester,
    ) async {
      final paywall = FakePaywallService(grantsAccess: true);

      await pumpApp(
        tester,
        _TriggerButton(onTap: importFromDevice),
        overrides: [paywallServiceProvider.overrideWithValue(paywall)],
      );

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(paywall.registeredPlacements, ['upload_pdf_report']);
      // The file-picker plugin has no test-harness implementation, so the
      // gated import flow running (rather than being skipped) shows up as
      // its caught-failure snackbar.
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
