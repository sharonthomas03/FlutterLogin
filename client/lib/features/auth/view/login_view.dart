import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_toast.dart';
import '../viewmodel/auth_view_model.dart';
import '../widget/auth_text_field.dart';
import '../widget/auth_button.dart';
import 'register_view.dart';
import '../../profile/view/profile_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final authViewModel = context.read<AuthViewModel>();
    try {
      final user = await authViewModel.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileView(user: user!)),
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, authViewModel.errorMessage ?? e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  AuthTextField(
                    controller: emailController,
                    labelText: "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: passwordController,
                    labelText: "Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  AuthButton(
                    onPressed: login,
                    text: "Login",
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterView(),
                        ),
                      );
                    },
                    child: const Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
