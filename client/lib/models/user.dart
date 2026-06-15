class User {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.token,
  });

  factory User.fromAuthJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    return User(
      id: userJson['id'] as String,
      username: userJson['username'] as String,
      email: userJson['email'] as String,
      bio: (userJson['bio'] ?? '') as String,
      token: json['token'] as String,
    );
  }

  factory User.fromStoredJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      bio: (json['bio'] ?? '') as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? bio,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      token: token ?? this.token,
    );
  }
}
