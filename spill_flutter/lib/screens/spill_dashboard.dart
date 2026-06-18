import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/spill_feed.dart';
import 'spill_map_screen.dart';

class SpillDashboard extends ConsumerWidget {
  const SpillDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if we have enough horizontal space for the split layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      // Stack layout for mobile
      return const SpillMapScreen();
    }

    // Row layout for desktop (30% feed, 70% map)
    return Row(
      children: [
        // SpillFeed - 30% width
        SizedBox(
          width: screenWidth * 0.3,
          child: const SpillFeed(),
        ),
        // Divider
        Container(
          width: 1,
          color: Colors.black,
        ),
        // GoogleMap - 70% width
        const Expanded(
          child: SpillMapScreen(
            fullScreen: true,
          ),
        ),
      ],
    );
  }
}
