import 'package:cloud_firestore/cloud_firestore.dart';

class Spill {
  const Spill({
    required this.id,
    required this.userId,
    required this.lat,
    required this.lng,
    required this.message,
    required this.timestamp,
    this.imageUrl,
  });

  final String id;
  final String userId;
  final double lat;
  final double lng;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;

  String get displayUserName => _formatUserName(userId);

  factory Spill.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    return Spill(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
      message: data['message'] as String? ?? '',
      imageUrl: data['image_url'] as String?,
      timestamp: _readTimestamp(data['timestamp']) ?? DateTime.now().toUtc(),
    );
  }

  factory Spill.fromBackendJson(Map<String, dynamic> json) {
    return Spill(
      id: json['spill_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      message: json['message'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      timestamp:
          _readTimestamp(json['timestamp']) ?? DateTime.now().toUtc(),
    );
  }
}

class SpillComment {
  const SpillComment({
    required this.id,
    required this.spillId,
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  final String id;
  final String spillId;
  final String userId;
  final String message;
  final DateTime timestamp;

  String get displayUserName => _formatUserName(userId);

  factory SpillComment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return SpillComment(
      id: doc.id,
      spillId: data['spill_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      message: data['message'] as String? ?? '',
      timestamp: _readTimestamp(data['timestamp']) ?? DateTime.now().toUtc(),
    );
  }

  factory SpillComment.fromBackendJson(Map<String, dynamic> json) {
    return SpillComment(
      id: json['comment_id'] as String? ?? '',
      spillId: json['spill_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp:
          _readTimestamp(json['timestamp']) ?? DateTime.now().toUtc(),
    );
  }
}

DateTime? _readTimestamp(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is Timestamp) {
    return value.toDate().toUtc();
  }

  if (value is DateTime) {
    return value.toUtc();
  }

  if (value is String) {
    return DateTime.tryParse(value)?.toUtc();
  }

  return null;
}

String _formatUserName(String userId) {
  if (userId.startsWith('anonymous-')) {
    final suffix = userId.substring('anonymous-'.length);
    final shortId = suffix.length >= 6 ? suffix.substring(0, 6) : suffix;
    return 'Anonymous #${shortId.toUpperCase()}';
  }

  return userId;
}
