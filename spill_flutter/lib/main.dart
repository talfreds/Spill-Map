import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/spill_dashboard.dart';
import 'theme/spill_theme.dart';

void main() {
  runApp(const ProviderScope(child: SpillApp()));
}

class SpillApp extends StatelessWidget {
  const SpillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spill',
      theme: SpillTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const SpillDashboard(),
    );
  }
}
