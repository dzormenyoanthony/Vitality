import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/features/reports/presentation/saved_reports_screen.dart';

void main() {
  test('formats sub-megabyte sizes in whole kilobytes', () {
    expect(formatFileSize(640 * 1024), '640 KB');
    expect(formatFileSize(0), '0 KB');
  });

  test('formats megabyte-and-up sizes with one decimal', () {
    expect(formatFileSize((1.8 * 1024 * 1024).round()), '1.8 MB');
    expect(formatFileSize(1024 * 1024), '1.0 MB');
  });
}
