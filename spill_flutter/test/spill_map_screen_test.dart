import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spill_flutter/screens/spill_map_screen.dart';
import 'package:spill_flutter/state/map_state.dart';

import 'dart:async';

void main() {
  testWidgets('map shell renders and long press updates pinState', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    final pinDroppedCompleter = Completer<void>();
    addTearDown(container.dispose);
    addTearDown(() {
      if (!pinDroppedCompleter.isCompleted) {
        pinDroppedCompleter.complete();
      }
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: SpillMapScreen(
            onPinDropped: (_, __) => pinDroppedCompleter.future,
            mapBuilder: ({
              required initialTarget,
              required markers,
              required onMapCreated,
              required onTap,
              required onLongPress,
            }) {
              return Container(
                color: Colors.white,
                child: GestureDetector(
                  key: const Key('fake-map'),
                  onLongPress: () {
                    onLongPress(const LatLng(49.2827, -123.1207));
                  },
                  child: const Center(
                    child: Text('Map'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('fake-map')), findsOneWidget);
    expect(container.read(pinStateProvider), isNull);

    await tester.longPress(find.byKey(const Key('fake-map')));
    await tester.pump();

    final pin = container.read(pinStateProvider);
    expect(pin, isNotNull);
    expect(pin!.latitude, closeTo(49.2827, 0.0001));
    expect(pin.longitude, closeTo(-123.1207, 0.0001));

    pinDroppedCompleter.complete();
  });
}
