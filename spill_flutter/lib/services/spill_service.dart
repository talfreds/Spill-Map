import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/spill_config.dart';
import '../models/spill_models.dart';

class SpillService {
  SpillService({
    ImagePicker? imagePicker,
    http.Client? httpClient,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _httpClient = httpClient ?? http.Client();

  final ImagePicker _imagePicker;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> _createUploadUrl({
    required String fileName,
    required String contentType,
  }) async {
    final uri = Uri.parse('${SpillConfig.backendBaseUrl}/spill/upload-url');
    final response = await _httpClient.post(
      uri,
      headers: await _buildJsonHeaders(),
      body: jsonEncode({
        'file_name': fileName,
        'content_type': contentType,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Failed to get upload URL: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _guessContentType(XFile image) {
    final mime = image.mimeType;
    if (mime != null && mime.startsWith('image/')) {
      return mime;
    }

    final lower = image.name.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/jpeg';
  }

  Future<String?> _getCurrentUserIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not obtain Firebase ID token.');
    }

    return idToken;
  }

  Future<Map<String, String>> _buildJsonHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final idToken = await _getCurrentUserIdToken();
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }

    return headers;
  }

  Future<String?> pickAndUploadPhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Sign in to upload a photo.');
    }

    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      return null;
    }

    final fileBytes = await image.readAsBytes();
    final contentType = _guessContentType(image);
    final uploadData = await _createUploadUrl(
      fileName: image.name,
      contentType: contentType,
    );

    final uploadUrl = uploadData['upload_url'] as String?;
    final publicUrl = uploadData['public_url'] as String?;
    if (uploadUrl == null || publicUrl == null) {
      throw Exception('Upload URL response is missing required fields.');
    }

    final uploadResponse = await _httpClient.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: fileBytes,
    );

    if (uploadResponse.statusCode >= 400) {
      throw Exception('Image upload failed with status ${uploadResponse.statusCode}.');
    }

    return publicUrl;
  }

  Future<Spill> createSpill({
    required double lat,
    required double lng,
    required String message,
    String? imageUrl,
  }) async {
    final uri = Uri.parse('${SpillConfig.backendBaseUrl}/spill/create');
    final payload = {
      'lat': lat,
      'lng': lng,
      'message': message,
      'image_url': imageUrl,
    };

    final response = await _httpClient.post(
      uri,
      headers: await _buildJsonHeaders(),
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw Exception('Failed to create spill: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Spill.fromBackendJson(body);
  }

  Future<SpillComment> addComment({
    required String spillId,
    required String message,
  }) async {
    final uri = Uri.parse('${SpillConfig.backendBaseUrl}/spill/$spillId/comments');
    final response = await _httpClient.post(
      uri,
      headers: await _buildJsonHeaders(),
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Failed to add comment: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return SpillComment.fromBackendJson(body);
  }
}
