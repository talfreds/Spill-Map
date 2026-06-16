import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../state/map_state.dart';

typedef SpillMapBuilder = Widget Function({
  required LatLng initialTarget,
  required Set<Marker> markers,
  required void Function(GoogleMapController controller) onMapCreated,
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
    final markers = <Marker>{
      if (pin != null)
        Marker(
          markerId: const MarkerId('temp-pin'),
          position: pin,
        ),
    };

    final builder = mapBuilder ?? _defaultMapBuilder;

    final mapWidget = builder(
      initialTarget: _vancouver,
      markers: markers,
      onMapCreated: (controller) {
        ref.read(mapControllerProvider.notifier).state = controller;
      },
      onLongPress: (latLng) async {
        ref.read(pinStateProvider.notifier).setPin(latLng);
        final showSheet = onPinDropped ?? _showSpillSheet;
        await showSheet(context, latLng);
      },
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
      onLongPress: onLongPress,
    );
  }

  Future<void> _showSpillSheet(BuildContext context, LatLng point) {
    final text =
        'Spilling a thought at [${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}]';

    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.black, width: 2),
      ),
      builder: (context) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      },
    );
  }
}
