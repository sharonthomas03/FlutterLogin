import 'package:flutter/material.dart';
import '../features/auth/view/login_view.dart';
import '../features/auth/view/register_view.dart';
import '../features/profile/view/profile_view.dart';
import '../features/auth/model/user_model.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case profile:
        final user = settings.arguments as User;
        return MaterialPageRoute(builder: (_) => ProfileView(user: user));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
