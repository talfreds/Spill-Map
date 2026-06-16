import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/spill_models.dart';
import '../services/spill_service.dart';

final mapControllerProvider = StateProvider<GoogleMapController?>((ref) {
  return null;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final spillServiceProvider = Provider<SpillService>((ref) {
  return SpillService();
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

class LocalSpillsNotifier extends StateNotifier<Map<String, Spill>> {
  LocalSpillsNotifier() : super(const {});

  void upsert(Spill spill) {
    state = {
      ...state,
      spill.id: spill,
    };
  }
}

final localSpillsProvider =
    StateNotifierProvider<LocalSpillsNotifier, Map<String, Spill>>((ref) {
      return LocalSpillsNotifier();
    });

final remoteSpillsProvider = StreamProvider<List<Spill>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore.collection('spills').snapshots().map((snapshot) {
    final spills = snapshot.docs.map(Spill.fromFirestore).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return spills;
  });
});

final spillsProvider = Provider<AsyncValue<List<Spill>>>((ref) {
  final remoteSpills = ref.watch(remoteSpillsProvider);
  final localSpills = ref.watch(localSpillsProvider);
  final localItems = localSpills.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return remoteSpills.when(
    data: (items) {
      final merged = <String, Spill>{
        ...localSpills,
        for (final spill in items) spill.id: spill,
      };

      final spills = merged.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return AsyncValue.data(spills);
    },
    loading: () => AsyncValue.data(localItems),
    error: (error, stackTrace) {
      if (localItems.isNotEmpty) {
        return AsyncValue.data(localItems);
      }

      return AsyncValue.error(error, stackTrace);
    },
  );
});

final spillCommentsProvider =
    StreamProvider.family<List<SpillComment>, String>((ref, spillId) {
      final firestore = ref.watch(firestoreProvider);

      return firestore
          .collection('spill_comments')
          .where('spill_id', isEqualTo: spillId)
          .snapshots()
          .map((snapshot) {
            final comments = snapshot.docs.map(SpillComment.fromFirestore).toList()
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
            return comments;
          });
    });

final selectedSpillIdProvider = StateProvider<String?>((ref) {
  return null;
});

final selectedSpillProvider = Provider<Spill?>((ref) {
  final selectedSpillId = ref.watch(selectedSpillIdProvider);
  final spills = ref.watch(spillsProvider).valueOrNull ?? const <Spill>[];

  if (selectedSpillId == null) {
    return null;
  }

  for (final spill in spills) {
    if (spill.id == selectedSpillId) {
      return spill;
    }
  }

  return null;
});

final spillByIdProvider = Provider.family<Spill?, String>((ref, spillId) {
  final spills = ref.watch(spillsProvider).valueOrNull ?? const <Spill>[];

  for (final spill in spills) {
    if (spill.id == spillId) {
      return spill;
    }
  }

  return null;
});
