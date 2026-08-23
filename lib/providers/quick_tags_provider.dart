import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A reusable quick tag: a short [title] shown as the chip label, plus the
/// longer [content] that gets inserted into a caption when the tag is used.
@immutable
class QuickTag {
  final String title;
  final String content;

  const QuickTag({required this.title, required this.content});

  Map<String, dynamic> toJson() => {'title': title, 'content': content};

  factory QuickTag.fromJson(Map<String, dynamic> json) => QuickTag(
        title: '${json['title'] ?? ''}',
        content: '${json['content'] ?? ''}',
      );
}

/// A globally reusable quick-tag library (persisted on-device). Tags created
/// here are available across all posts — they are shown by their [title]
/// wherever tags are offered, and their [content] is what gets inserted.
class QuickTagsProvider extends ChangeNotifier {
  static const _key = 'velie_quick_tags';

  List<QuickTag> _tags = [];

  List<QuickTag> get tags => List.unmodifiable(_tags);

  /// Loads persisted tags once. Safe to call repeatedly.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as List;
      _tags = decoded
          .map((e) => QuickTag.fromJson(e as Map<String, dynamic>))
          .where((t) => t.title.trim().isNotEmpty)
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_tags.map((t) => t.toJson()).toList()));
  }

  Future<void> add(QuickTag tag) async {
    // Avoid duplicate titles: replace in place, append otherwise.
    final idx = _tags.indexWhere((t) => t.title.trim() == tag.title.trim());
    if (idx >= 0) {
      _tags[idx] = tag;
    } else {
      _tags.add(tag);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String title) async {
    _tags.removeWhere((t) => t.title.trim() == title.trim());
    notifyListeners();
    await _persist();
  }

  /// Resets the in-memory tag list (called on logout by the session). The
  /// persisted copy is already removed by the session wipe.
  void reset() {
    _tags = [];
    notifyListeners();
  }
}
