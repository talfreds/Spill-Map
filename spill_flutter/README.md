# Spill Flutter Shell

## Setup from repo root

Run the following from the repository root:

```bash
npm run flutter:install
npm run flutter:pub:get
```

## Google Maps API key

All platforms (Web, Android, iOS) use `String.fromEnvironment('MAPS_API_KEY')` to load the API key from the build environment.

**Web**: The root script `npm run flutter:web:prepare-env` injects `GOOGLE_API_KEY` from `.env` into [web/index.html](web/index.html) at runtime.

**Android & iOS**: Pass the key via `--dart-define` when running on device:
```bash
../.tooling/flutter/bin/flutter run -d <device-id> --dart-define=MAPS_API_KEY=$GOOGLE_API_KEY
```

The key should be enabled for Maps SDK for Android, Maps SDK for iOS, Maps JavaScript API, and Places API.

TODO before production:
- Use dedicated `prod` key separate from development.
- Apply HTTP referrer restrictions for web domains.
- Restrict key to only required Maps/Places APIs.
- Rotate development-exposed keys before release.

## Run in Codespaces web preview

```bash
npm run flutter:web:run
```

Then open the forwarded port preview in Codespaces.

## Verification test

Run:

```bash
npm run flutter:test
```

The widget test in [test/spill_map_screen_test.dart](test/spill_map_screen_test.dart) checks:
- The map shell widget renders.
- A long-press action updates the Riverpod pin state.

## Testing on Android

### Setup
```bash
npm run flutter:android:setup
```

Then add the API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_API_KEY_HERE" />
```

Or pass via build argument:
```bash
cd spill_flutter
../.tooling/flutter/bin/flutter run -d <device-id> --dart-define=MAPS_API_KEY=$GOOGLE_API_KEY
```

### Run on Android Emulator
```bash
# List available emulators
../.tooling/flutter/bin/flutter emulators

# Launch an emulator
../.tooling/flutter/bin/flutter emulators --launch Pixel_5

# Run the app
../.tooling/flutter/bin/flutter run -d emulator-5554 --dart-define=MAPS_API_KEY=$GOOGLE_API_KEY
```

### Run on Android Device
```bash
# List devices
../.tooling/flutter/bin/flutter devices

# Run the app
../.tooling/flutter/bin/flutter run -d <device-id> --dart-define=MAPS_API_KEY=$GOOGLE_API_KEY
```

## Testing on iOS

### Setup
```bash
npm run flutter:ios:setup
```

Then add the API key to `ios/Runner/Info.plist`:
```xml
<key>MAPS_API_KEY</key>
<string>YOUR_GOOGLE_API_KEY_HERE</string>
```

Or pass via build argument:
```bash
cd spill_flutter
../.tooling/flutter/bin/flutter run -d <device-id> --dart-define=MAPS_API_KEY=$GOOGLE_API_KEY
```

### Run on iOS Simulator
```bash
# Open simulator
open -a Simulator

# List connected devices
../.tooling/flutter/bin/flutter devices

# Run the app
../.tooling/flutter/bin/flutter run -d <device-id> --dart-define=MAPS_API_KEY=$GOOGLE_API_KEY
```

### Run on Physical iOS Device
```bash
# Requires provisioning profile setup in Xcode
../.tooling/flutter/bin/flutter run -d <device-id> --dart-define=MAPS_API_KEY=$GOOGLE_API_KEY
```
