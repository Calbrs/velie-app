import 'package:dio/dio.dart';

import 'api_client.dart';

/// A message sent from the admin panel.
/// `audience` is `announcement` (all users) or `direct` (this user only).
class AdminMessageModel {
  AdminMessageModel({
    required this.id,
    required this.audience,
    this.title,
    required this.message,
    required this.createdAt,
    required this.viewed,
  });

  final int id;
  final String audience;
  final String? title;
  final String message;
  final DateTime createdAt;
  bool viewed;

  bool get isDirect => audience == 'direct';

  factory AdminMessageModel.fromJson(Map<String, dynamic> json) {
    return AdminMessageModel(
      id: (json['id'] as num).toInt(),
      audience: json['audience'] as String? ?? 'announcement',
      title: json['title'] as String?,
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      viewed: json['viewed'] as bool? ?? false,
    );
  }
}

/// Mirrors `routes/messages.js` (`/api/messages`). Viewed messages are
/// soft-hidden server-side per user; the app just filters them out locally.
class MessageService {
  MessageService({ApiClient? client}) : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  Future<List<AdminMessageModel>> listMessages() async {
    try {
      final res = await _api.dio.get('/messages');
      final data = res.data as Map<String, dynamic>;
      final list = data['messages'] as List<dynamic>? ?? <dynamic>[];
      return list
          .map((e) => AdminMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Records a view so the message disappears from this user's inbox.
  Future<void> markViewed(int id) async {
    try {
      await _api.dio.post('/messages/$id/view');
    } on DioException {
      rethrow;
    }
  }
}
