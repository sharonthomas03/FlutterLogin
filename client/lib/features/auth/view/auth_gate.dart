import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';
import '../viewmodel/auth_view_model.dart';
import 'login_view.dart';
import '../../profile/view/profile_view.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = context.read<AuthViewModel>().checkSavedUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginView();
        }

        return ProfileView(user: user);
      },
    );
  }
}
