class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  final String bio;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    this.bio = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username.trim(),
      'email': email.trim(),
      'password': password,
      'bio': bio.trim(),
    };
  }
}
