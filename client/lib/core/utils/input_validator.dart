class InputValidator {
  // ── Boolean helpers (kept for existing usages) ────────────────────────────

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidUsername(String username) {
    return username.trim().isNotEmpty;
  }

  // ── String? validators for use with TextFormField ─────────────────────────
  // Return null when the value is valid, or an error message when it is not.

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    if (!isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password cannot be empty';
    }
    if (!isValidPassword(value.trim())) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
