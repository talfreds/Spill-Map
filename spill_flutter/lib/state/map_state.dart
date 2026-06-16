import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final mapControllerProvider = StateProvider<GoogleMapController?>((ref) {
  return null;
});

class PinStateNotifier extends StateNotifier<LatLng?> {
  PinStateNotifier() : super(null);

  void setPin(LatLng point) {
    state = point;
  }

  void clearPin() {
    state = null;
  }
}

final pinStateProvider = StateNotifierProvider<PinStateNotifier, LatLng?>((ref) {
  return PinStateNotifier();
});
