import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/spill_service.dart';
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
    final messageController = TextEditingController();
    final spillService = SpillService();
    String? imageUrl;
    bool isUploadingPhoto = false;
    bool isSubmitting = false;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.black, width: 2),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickPhoto() async {
              setModalState(() {
                isUploadingPhoto = true;
              });

              try {
                final uploadedUrl = await spillService.pickAndUploadPhoto();
                setModalState(() {
                  imageUrl = uploadedUrl;
                });
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Photo upload failed: $error')),
                  );
                }
              } finally {
                setModalState(() {
                  isUploadingPhoto = false;
                });
              }
            }

            Future<void> submitSpill() async {
              final message = messageController.text.trim();
              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message is required.')),
                );
                return;
              }

              setModalState(() {
                isSubmitting = true;
              });

              try {
                await spillService.createSpill(
                  lat: point.latitude,
                  lng: point.longitude,
                  message: message,
                  imageUrl: imageUrl,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Spill posted.')),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Create spill failed: $error')),
                  );
                }
              } finally {
                setModalState(() {
                  isSubmitting = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New spill at ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: messageController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: isUploadingPhoto || isSubmitting ? null : pickPhoto,
                        icon: const Icon(Icons.photo_library),
                        label: Text(isUploadingPhoto ? 'Uploading...' : 'Add Photo'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          imageUrl == null ? 'No photo attached' : 'Photo attached',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSubmitting || isUploadingPhoto ? null : submitSpill,
                      child: Text(isSubmitting ? 'Posting...' : 'Post Spill'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(messageController.dispose);
  }
}
