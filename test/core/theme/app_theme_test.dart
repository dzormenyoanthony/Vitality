import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vitality/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light() produces a light-brightness Material 3 theme', () {
      final theme = AppTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('dark() produces a dark-brightness Material 3 theme', () {
      final theme = AppTheme.dark();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });
  });
}
