class YChatValidators {
  YChatValidators._();

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 2) return 'Enter your full name';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    if (!ok) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Use letters and numbers';
    }
    return null;
  }
}
