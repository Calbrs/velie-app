import 'package:flutter/foundation.dart';

import '../core/constants/post_status.dart';
import '../models/post_schedule_model.dart';
import '../services/schedule_service.dart';

/// Post queue: list, filter, retry, delete.
class QueueProvider extends ChangeNotifier {
  QueueProvider({ScheduleService? service}) : _service = service ?? ScheduleService();

  final ScheduleService _service;

  List<PostScheduleModel> _posts = [];
  PostStatus? _filter;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  int? _businessId;
  final Set<int> _busyIds = {};

  List<PostScheduleModel> get posts => _posts;
  PostStatus? get filter => _filter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<int> get busyIds => _busyIds;

  List<PostScheduleModel> get filteredPosts {
    var list = _filter == null
        ? _posts
        : _posts.where((p) => p.status == _filter).toList();
    
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.caption.toLowerCase().contains(q)).toList();
    }

    list.sort((a, b) => (b.scheduledTime ?? b.createdAt ?? DateTime(1970))
        .compareTo(a.scheduledTime ?? a.createdAt ?? DateTime(1970)));
    return list;
  }

  void setBusinessId(int? id) {
    if (id != _businessId) {
      _businessId = id;
      refresh();
    }
  }

  void setFilter(PostStatus? value) {
    if (_filter != value) {
      _filter = value;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  bool isBusy(int id) => _busyIds.contains(id);

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

  Future<void> retry(int postId) async {
    if (_busyIds.contains(postId)) return;
    _busyIds.add(postId);
    notifyListeners();
    try {
      final updated = await _service.retryPost(postId);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        _posts[index] = updated;
      }
    } catch (e) {
      _error = '$e';
    } finally {
      _busyIds.remove(postId);
      notifyListeners();
    }
  }

  /// Refreshes a single post (e.g. to pull a fresh Status viewer count).
  Future<void> refreshOne(int postId) async {
    try {
      final updated = await _service.getPost(postId);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        _posts[index] = updated;
      } else {
        _posts.add(updated);
      }
      notifyListeners();
    } catch (e) {
      _error = '$e';
    }
  }

  Future<void> delete(int postId) async {
    if (_busyIds.contains(postId)) return;
    _busyIds.add(postId);
    notifyListeners();
    try {
      await _service.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
    } catch (e) {
      _error = '$e';
    } finally {
      _busyIds.remove(postId);
      notifyListeners();
    }
  }
}
