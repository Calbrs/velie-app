import 'package:flutter/foundation.dart';

import '../core/constants/post_status.dart';
import '../models/post_schedule_model.dart';
import '../services/schedule_service.dart';

/// Dashboard stats + recent posts.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider({ScheduleService? service}) : _service = service ?? ScheduleService();

  final ScheduleService _service;

  List<PostScheduleModel> _posts = [];
  bool _isLoading = false;
  String? _error;
  int? _businessId;

  List<PostScheduleModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingCount => _posts.where((p) => p.status == PostStatus.pending).length;
  int get sentCount => _posts.where((p) => p.status == PostStatus.sent).length;
  int get failedCount => _posts.where((p) => p.status == PostStatus.failed).length;

  List<PostScheduleModel> get recentPosts {
    final sorted = [..._posts]..sort((a, b) => (b.scheduledTime ?? b.createdAt ?? DateTime(1970))
        .compareTo(a.scheduledTime ?? a.createdAt ?? DateTime(1970)));
    return sorted.take(5).toList();
  }

  void setBusinessId(int? id) {
    if (id != _businessId) {
      _businessId = id;
      refresh();
    }
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final newPosts = await _service.listPosts(businessId: _businessId);
      _posts = newPosts;
    } catch (e) {
      if (!silent) _error = '$e';
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }
}
