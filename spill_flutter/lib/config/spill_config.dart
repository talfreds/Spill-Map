import 'package:flutter/foundation.dart';
import 'dart:html' as html;

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
  /// Auto-detects for web (maps app port to backend port on same domain).
  /// Falls back to localhost:8000 for other platforms or local development.
  static String get backendBaseUrl {
    if (kIsWeb) {
      final hostname = html.window.location.hostname ?? 'localhost';
      final protocol = html.window.location.protocol.replaceAll(':', '');
      
      // For Codespaces: fluffy-space-chainsaw-x9rr4gpqw75f6qqr-8080.app.github.dev
      // becomes fluffy-space-chainsaw-x9rr4gpqw75f6qqr-8000.app.github.dev
      if (hostname.contains('.app.github.dev')) {
        return '$protocol://${hostname.replaceAll('-8080.', '-8000.')}'; 
      }
      
      // Local development
      return '$protocol://localhost:8000';
    }
    
    // Mobile platforms default to localhost
    return 'http://localhost:8000';
  }
}
