import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/spill_models.dart';
import '../state/map_state.dart';
import '../widgets/auth_sheet.dart';
import '../widgets/spill_sheets.dart';

typedef SpillMapBuilder = Widget Function({
  required LatLng initialTarget,
  required Set<Marker> markers,
  required void Function(GoogleMapController controller) onMapCreated,
  required void Function(LatLng latLng) onTap,
  required void Function(LatLng latLng) onLongPress,
});

class SpillMapScreen extends ConsumerWidget {
  const SpillMapScreen({
    super.key,
    this.mapBuilder,
    this.onPinDropped,
    this.fullScreen = false,
  });

  final SpillMapBuilder? mapBuilder;
  final Future<void> Function(BuildContext context, LatLng point)? onPinDropped;
  
  /// If true, returns just the map widget without Scaffold for use in dashboards.
  /// If false, returns full screen with Scaffold.
  final bool fullScreen;

  static const LatLng _vancouver = LatLng(49.2827, -123.1207);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pin = ref.watch(pinStateProvider);
    final spills = ref.watch(spillsProvider);
    final remoteSpills = ref.watch(remoteSpillsProvider);
    final selectedSpillId = ref.watch(selectedSpillIdProvider);
    final authState = ref.watch(authStateProvider);

    final markers = <Marker>{
      if (pin != null)
        Marker(
          markerId: const MarkerId('temp-pin'),
          position: pin,
        ),
      ..._buildSpillMarkers(
        context: context,
        ref: ref,
        spills: spills.valueOrNull ?? const <Spill>[],
        selectedSpillId: selectedSpillId,
      ),
    };

    final builder = mapBuilder ?? _defaultMapBuilder;
    final mapWidget = Stack(
      children: [
        builder(
          initialTarget: _vancouver,
          markers: markers,
          onMapCreated: (controller) {
            ref.read(mapControllerProvider.notifier).state = controller;
          },
          onTap: (latLng) async {
            await _handlePointSelection(context, ref, latLng);
          },
          onLongPress: (latLng) async {
            await _handlePointSelection(context, ref, latLng);
          },
        ),
        Positioned(
          top: 16,
          left: 16,
          child: _AuthStatusButton(
            label: authState.valueOrNull?.email ?? 'Post as guest',
            onPressed: () => showAuthSheet(context: context, ref: ref),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: remoteSpills.when(
            data: (_) => const SizedBox.shrink(),
            loading: () => const _MapStatusCard(label: 'Loading spills...'),
            error: (error, _) => _MapStatusCard(
              label: 'Could not load spills',
              detail: error.toString(),
            ),
          ),
        ),
      ],
    );

    if (fullScreen) {
      return mapWidget;
    }

    return Scaffold(
      body: mapWidget,
    );
  }

  Widget _defaultMapBuilder({
    required LatLng initialTarget,
    required Set<Marker> markers,
    required void Function(GoogleMapController controller) onMapCreated,
    required void Function(LatLng latLng) onTap,
    required void Function(LatLng latLng) onLongPress,
  }) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 12,
      ),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: markers,
      onMapCreated: onMapCreated,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Set<Marker> _buildSpillMarkers({
    required BuildContext context,
    required WidgetRef ref,
    required List<Spill> spills,
    required String? selectedSpillId,
  }) {
    return spills
        .map(
          (spill) => Marker(
            markerId: MarkerId(spill.id),
            position: LatLng(spill.lat, spill.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              selectedSpillId == spill.id
                  ? BitmapDescriptor.hueAzure
                  : BitmapDescriptor.hueRed,
            ),
            onTap: () {
              showSpillDetailSheet(
                context: context,
                ref: ref,
                spillId: spill.id,
              );
            },
          ),
        )
        .toSet();
  }

  Future<void> _handlePointSelection(
    BuildContext context,
    WidgetRef ref,
    LatLng point,
  ) async {
    ref.read(pinStateProvider.notifier).setPin(point);

    try {
      final showSheet = onPinDropped ?? _showSpillSheet;
      await showSheet(context, point);
    } finally {
      ref.read(pinStateProvider.notifier).clearPin();
    }
  }

  Future<void> _showSpillSheet(BuildContext context, LatLng point) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => NewSpillSheet(point: point),
    );
  }
}

class _AuthStatusButton extends StatelessWidget {
  const _AuthStatusButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(999),
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: const Icon(Icons.person_outline),
        label: Text(label),
      ),
    );
  }
}

class _MapStatusCard extends StatelessWidget {
  const _MapStatusCard({
    required this.label,
    this.detail,
  });

  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              if (detail != null) ...[
                const SizedBox(height: 4),
                SizedBox(
                  width: 220,
                  child: Text(
                    detail!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
