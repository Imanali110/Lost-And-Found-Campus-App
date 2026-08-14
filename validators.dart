// lib/utils/validators.dart
class V {
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Too short';
    return null;
  }

  static String? roll(String? v) {
    if (v == null || v.trim().isEmpty) return 'Roll number is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!v.contains('@')) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  static String? required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    if (v.trim().length < 3) return '$field is too short';
    return null;
  }
}
