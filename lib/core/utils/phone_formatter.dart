import '../constants/app_constants.dart';

/// Phone formatting with fixed +255 (Tanzania) prefix.
abstract class PhoneFormatter {
  /// Prefix shown in the field.
  static const String prefix = AppConstants.phonePrefix;

  /// Take a phone string that may already contain the prefix or not, and
  /// return a normalized E.164 form, e.g. `+255712345678`.
  ///
  /// Accepts the local formats too: a leading `0` trunk prefix (`0712 345 678`)
  /// is dropped, so the same number always normalizes to one value (this is
  /// what prevents a number from being registered twice in different forms).
  static String toE164(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    final withCountry = digits.replaceFirst(RegExp(r'^0'), '').replaceFirst(RegExp(r'^255'), '');
    final body = withCountry.length > 9
        ? withCountry.substring(withCountry.length - 9)
        : withCountry.padLeft(9, '0');
    return '$prefix$body';
  }

  /// Format only the trailing 9 digits while typing, e.g. `712 345 678`.
  /// A leading `0` trunk prefix is ignored while typing.
  static String formatWhileTyping(String digitsOnly) {
    final digits = digitsOnly.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0'), '');
    final limited = digits.length > 9 ? digits.substring(digits.length - 9) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 3 || i == 6) buffer.write(' ');
      buffer.write(limited[i]);
    }
    return buffer.toString();
  }
}
