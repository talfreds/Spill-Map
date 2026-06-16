import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/map_state.dart';

class SpillFeed extends ConsumerWidget {
  const SpillFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSpill = ref.watch(selectedSpillProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Recent Spills',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          // Sample spill cards
          ..._buildSpillCards(context, ref, selectedSpill),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewSpillDialog(context);
        },
        tooltip: 'New Spill',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> _buildSpillCards(
    BuildContext context,
    WidgetRef ref,
    String? selectedSpill,
  ) {
    // Sample spills for demonstration
    final spills = [
      {
        'id': 'spill_1',
        'title': 'Coffee Spot',
        'description': 'Great new coffee place downtown',
        'location': 'Downtown',
      },
      {
        'id': 'spill_2',
        'title': 'Park Trail',
        'description': 'Beautiful walking trail with views',
        'location': 'Mountain View',
      },
      {
        'id': 'spill_3',
        'title': 'Restaurant Review',
        'description': 'Amazing sushi restaurant',
        'location': 'Westside',
      },
    ];

    return spills.map((spill) {
      final isSelected = selectedSpill == spill['id'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            ref.read(selectedSpillProvider.notifier).state = spill['id'];
          },
          child: Card(
            color: isSelected ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Colors.black,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spill['title']!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spill['description']!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.white70 : Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 ${spill['location']!}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? Colors.white60 : Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showNewSpillDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Spill'),
          content: const Text('Add a new spill at a location on the map.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
