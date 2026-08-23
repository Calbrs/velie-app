/// Field validation helpers (Swahili messages).
abstract class Validators {
  static String? validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Tafadhali jaza jina lako';
    if (v.length < 2) return 'Jina ni fupi mno';
    return null;
  }

  /// Expects the digits AFTER the +255 prefix (e.g. "712 345 678").
  static String? validateOwnerPhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'Tafadhali jaza namba ya simu';
    if (digits.length != 9) return 'Namba ya simu lazima iwe na tarakimu 9';
    return null;
  }

  static String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Tafadhali jaza password';
    if (v.length < 6) return 'Password lazima iwe na herufi 6 au zaidi';
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return 'Tafadhali rudia password';
    if (value != password) return 'Password hazilingani';
    return null;
  }

  static String? validateCaption(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Tafadhali andika caption';
    if (v.length > 2200) return 'Caption imezidi herufi 2200';
    return null;
  }
}
