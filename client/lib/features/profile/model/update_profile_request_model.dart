class UpdateProfileRequestModel {
  final String username;
  final String email;
  final String bio;

  UpdateProfileRequestModel({
    required this.username,
    required this.email,
    required this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username.trim(),
      'email': email.trim(),
      'bio': bio.trim(),
    };
  }
}
