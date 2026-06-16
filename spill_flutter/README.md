# Spill Flutter Shell

## Setup from repo root

Run the following from the repository root:

```bash
npm run flutter:install
npm run flutter:pub:get
```

## Google Maps API key

The web loader in [web/index.html](web/index.html) uses a placeholder token.
The root script `npm run flutter:web:prepare-env` injects `GOOGLE_API_KEY` from root `.env`.
This key should be enabled for Maps SDK for Android, Maps SDK for iOS, Maps JavaScript API, and Places API.

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
