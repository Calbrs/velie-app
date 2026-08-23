import 'package:intl/intl.dart';

/// Date/time formatting helpers for Velie (Swahili-friendly).
abstract class DateTimeFormatter {
  static final DateFormat _full = DateFormat('d MMM yyyy · HH:mm');
  static final DateFormat _short = DateFormat('d MMM · HH:mm');
  static final DateFormat _dayMonth = DateFormat('d MMM yyyy');
  static final DateFormat _time = DateFormat('HH:mm');

  static String full(DateTime? value) =>
      value == null ? '-' : _full.format(value.toLocal());

  static String short(DateTime? value) =>
      value == null ? '-' : _short.format(value.toLocal());

  static String dayMonth(DateTime? value) =>
      value == null ? '-' : _dayMonth.format(value.toLocal());

  static String time(DateTime? value) =>
      value == null ? '-' : _time.format(value.toLocal());

  static String relative(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return 'sasa hivi';
    if (diff.inHours < 1) return 'dakika ${diff.inMinutes} zilizopita';
    if (diff.inDays < 1) return 'saa ${diff.inHours} zilizopita';
    if (diff.inDays < 7) return 'siku ${diff.inDays} zilizopita';
    return _short.format(local);
  }

  /// Parse a DateTime from the API (ISO 8601) — returns null on failure.
  static DateTime? parse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
