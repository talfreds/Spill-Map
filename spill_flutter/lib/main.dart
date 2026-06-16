import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/firebase_runtime_config.dart';
import 'screens/spill_dashboard.dart';
import 'theme/spill_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseRuntimeConfig.options);

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
