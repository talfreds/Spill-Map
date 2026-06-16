/// Configuration for Spill Map application.
/// 
/// The API key is loaded from the environment at compile time using:
/// ```
/// const String apiKey = String.fromEnvironment('MAPS_API_KEY');
/// ```
/// 
/// This ensures the key is injected during the build process without
/// hardcoding sensitive values in the source code.

class SpillConfig {
  /// Google Maps API key for all platforms (Web, Android, iOS).
  /// Injected from environment variable MAPS_API_KEY at build time.
  static const String mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

  /// Base URL for the FastAPI backend.
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
