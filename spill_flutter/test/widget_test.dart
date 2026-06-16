import 'package:flutter_test/flutter_test.dart';

import 'package:spill_flutter/theme/spill_theme.dart';

void main() {
  testWidgets('Spill theme uses expected scaffold background color',
      (WidgetTester tester) async {
    final theme = SpillTheme.light();
    expect(theme.scaffoldBackgroundColor, SpillTheme.background);
  });
}
