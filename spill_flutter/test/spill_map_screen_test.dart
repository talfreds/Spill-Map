import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spill_flutter/screens/spill_map_screen.dart';
import 'package:spill_flutter/state/map_state.dart';

void main() {
  testWidgets('map shell renders and long press updates pinState', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: SpillMapScreen(
            onPinDropped: (_, __) async {},
            mapBuilder: ({
              required initialTarget,
              required markers,
              required onMapCreated,
              required onLongPress,
            }) {
              return GestureDetector(
                key: const Key('fake-map'),
                onLongPress: () {
                  onLongPress(const LatLng(49.2827, -123.1207));
                },
                child: const SizedBox.expand(),
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
  });
}
