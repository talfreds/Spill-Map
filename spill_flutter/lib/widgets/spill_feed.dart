import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/spill_models.dart';
import '../state/map_state.dart';
import 'spill_sheets.dart';

class SpillFeed extends ConsumerWidget {
  const SpillFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spills = ref.watch(spillsProvider);
    final remoteSpills = ref.watch(remoteSpillsProvider);
    final selectedSpillId = ref.watch(selectedSpillIdProvider);
    final spillItems = spills.valueOrNull ?? const <Spill>[];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Spills',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Expanded(
            child: remoteSpills.when(
              data: (_) => _buildFeedBody(
                context: context,
                ref: ref,
                spills: spillItems,
                selectedSpillId: selectedSpillId,
              ),
              loading: () {
                if (spillItems.isNotEmpty) {
                  return _buildFeedBody(
                    context: context,
                    ref: ref,
                    spills: spillItems,
                    selectedSpillId: selectedSpillId,
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
              error: (error, _) {
                if (spillItems.isNotEmpty) {
                  return _buildFeedBody(
                    context: context,
                    ref: ref,
                    spills: spillItems,
                    selectedSpillId: selectedSpillId,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Could not load spills: $error'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tap the map to place a new spill.')),
          );
        },
        tooltip: 'New Spill',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFeedBody({
    required BuildContext context,
    required WidgetRef ref,
    required List<Spill> spills,
    required String? selectedSpillId,
  }) {
    if (spills.isEmpty) {
      return const Center(
        child: Text('No spills yet. Tap the map to create one.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: _buildSpillCards(context, ref, spills, selectedSpillId),
    );
  }

  List<Widget> _buildSpillCards(
    BuildContext context,
    WidgetRef ref,
    List<Spill> spills,
    String? selectedSpillId,
  ) {
    return spills.map((spill) {
      final isSelected = selectedSpillId == spill.id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () async {
            ref.read(selectedSpillIdProvider.notifier).state = spill.id;

            final mapController = ref.read(mapControllerProvider);
            if (mapController != null) {
              await mapController.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(spill.lat, spill.lng),
                ),
              );
            }

            if (context.mounted) {
              await showSpillDetailSheet(
                context: context,
                ref: ref,
                spillId: spill.id,
              );
            }
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
                    spill.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 ${spill.lat.toStringAsFixed(4)}, ${spill.lng.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? Colors.white60 : Colors.black54,
                        ),
                  ),
                  if (spill.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Photo attached',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected ? Colors.white60 : Colors.black54,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
