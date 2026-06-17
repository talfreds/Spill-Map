import 'package:flutter/foundation.dart';
import 'dart:html' as html;

/// Configuration for Spill Map application.
/// 
/// Environment variables injected at build time:
/// - MAPS_API_KEY: Google Maps API key
/// - BACKEND_BASE_URL: (Optional) Explicit backend URL for production
/// 
/// For development (Codespaces, localhost), the backend URL is auto-detected.
/// For production, set BACKEND_BASE_URL explicitly.

class SpillConfig {
  /// Google Maps API key for all platforms (Web, Android, iOS).
  /// Injected from environment variable MAPS_API_KEY at build time.
  static const String mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

  /// Base URL for the FastAPI backend.
  /// 
  /// Resolution order:
  /// 1. Explicit BACKEND_BASE_URL env var (for production)
  /// 2. Auto-detect from current hostname (for Codespaces/localhost dev)
  /// 3. Default to localhost:8000 (local mobile/desktop dev)
  static String get backendBaseUrl {
    // Check for explicit production URL
    const explicitUrl = String.fromEnvironment('BACKEND_BASE_URL', defaultValue: '');
    if (explicitUrl.isNotEmpty) {
      return explicitUrl;
    }
    
    // Auto-detect for web development
    if (kIsWeb) {
      final hostname = html.window.location.hostname ?? 'localhost';
      final protocol = html.window.location.protocol.replaceAll(':', '');
      
      // For GitHub Codespaces: fluffy-space-chainsaw-x9rr4gpqw75f6qqr-8080.app.github.dev
      // maps to fluffy-space-chainsaw-x9rr4gpqw75f6qqr-8000.app.github.dev
      if (hostname.contains('.app.github.dev')) {
        return '$protocol://${hostname.replaceAll('-8080.', '-8000.')}'; 
      }
      
      // Local web development
      return '$protocol://localhost:8000';
    }
    
    // Mobile/desktop platforms default to localhost
    return 'http://localhost:8000';
  }
}
