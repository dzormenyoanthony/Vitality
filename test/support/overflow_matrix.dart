import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A representative device profile for the responsiveness audit
/// (superwall_paywall.md's sibling task: the cross-device text-scaling
/// audit). Logical pixels, `devicePixelRatio` fixed at 1.0 — same
/// convention already used by this repo's other tests that set
/// `tester.view.physicalSize` directly.
class DeviceProfile {
  const DeviceProfile(this.name, this.size);

  final String name;
  final Size size;
}

/// A small older/budget Android phone (~320dp wide — Android's historical
/// "smallest width" baseline).
const smallPhone = DeviceProfile('small phone (320x640)', Size(320, 640));

/// A modern tall-screen flagship, ~9:20 — matches the emulator the app
/// looked correct on, and the 6.7"-class device a real tester reported
/// problems on.
const tall9x20Phone = DeviceProfile('tall 9:20 phone (360x800)', Size(360, 800));

/// An older/shorter-aspect phone (~16:9, e.g. pre-2017 devices still in
/// use), where vertical space is at a premium compared to the tall phones
/// above.
const shortAspectPhone = DeviceProfile(
  'short-aspect phone (360x640)',
  Size(360, 640),
);

/// A large modern phone/phablet.
const largePhone = DeviceProfile('large phone (480x960)', Size(480, 960));

const overflowMatrixDevices = [
  smallPhone,
  tall9x20Phone,
  shortAspectPhone,
  largePhone,
];

/// System text-scale steps to probe. Android's own "Font size" setting
/// tops out at 200%, but combined with a large "Display size" the
/// *effective* scale users report can run higher — 3x is deliberately
/// beyond what Android exposes directly, to catch layouts that are only
/// marginally safe at 2x.
const overflowMatrixTextScales = [1.3, 2.0, 3.0];

/// Pumps a fresh [builder] for every combination of [overflowMatrixDevices]
/// x [overflowMatrixTextScales] and collects every combo where the pump
/// throws (almost always a `RenderFlex overflowed` assertion), rather than
/// failing on the first one — so a single test run surfaces every broken
/// combination for a screen at once instead of one failure per `flutter
/// test` invocation.
///
/// [builder] must build the full app (`MaterialApp`/`ProviderScope` and
/// all) fresh each call — screens that hold their own `Timer`/stream
/// state don't tolerate being reused across `pumpWidget` calls.
Future<void> expectNoOverflowAcrossDevices(
  WidgetTester tester,
  Widget Function() builder, {
  List<DeviceProfile> devices = overflowMatrixDevices,
  List<double> textScales = overflowMatrixTextScales,
}) async {
  final failures = <String>[];
  // takeException() alone only returns the summary line (e.g. "A RenderFlex
  // overflowed by 16 pixels on the bottom"), not the offending widget's
  // file/line — installing a handler captures the full FlutterErrorDetails
  // (which does include the creator chain and source location) instead.
  final original = FlutterError.onError;
  String? lastDetails;
  FlutterError.onError = (details) {
    lastDetails = details.toString();
    original?.call(details);
  };
  try {
    for (final device in devices) {
      for (final scale in textScales) {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        lastDetails = null;
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: builder(),
          ),
        );
        await tester.pump();
        final error = tester.takeException();
        if (error != null) {
          failures.add(
            '${device.name} @ ${scale}x textScale:\n${lastDetails ?? error}',
          );
        }
      }
    }
  } finally {
    FlutterError.onError = original;
    tester.view.reset();
  }
  expect(failures, isEmpty, reason: failures.join('\n\n'));
}
