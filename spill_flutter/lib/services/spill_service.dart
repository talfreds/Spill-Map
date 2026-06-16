import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/spill_config.dart';

class SpillService {
  SpillService({
    ImagePicker? imagePicker,
    FirebaseStorage? storage,
    http.Client? httpClient,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _storage = storage ?? FirebaseStorage.instance,
        _httpClient = httpClient ?? http.Client();

  final ImagePicker _imagePicker;
  final FirebaseStorage _storage;
  final http.Client _httpClient;

  Future<String?> pickAndUploadPhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be signed in to upload a photo.');
    }

    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      return null;
    }

    final fileBytes = await image.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    final storageRef = _storage
        .ref()
        .child('spill_images/${user.uid}/$fileName');

    await storageRef.putData(
      fileBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return storageRef.getDownloadURL();
  }

  Future<void> createSpill({
    required double lat,
    required double lng,
    required String message,
    String? imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be signed in to create a spill.');
    }

    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not obtain Firebase ID token.');
    }

    final uri = Uri.parse('${SpillConfig.backendBaseUrl}/spill/create');
    final payload = {
      'lat': lat,
      'lng': lng,
      'message': message,
      'image_url': imageUrl,
    };

    final response = await _httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw Exception('Failed to create spill: ${response.body}');
    }
  }
}
