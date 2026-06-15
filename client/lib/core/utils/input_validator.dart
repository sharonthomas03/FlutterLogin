class InputValidator {
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
}
