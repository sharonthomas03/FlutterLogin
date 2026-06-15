import 'user_model.dart';

class AuthResponseModel {
  final User user;
  final String token;

  AuthResponseModel({required this.user, required this.token});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: User.fromAuthJson(json),
      token: json['token'] as String,
    );
  }
}
