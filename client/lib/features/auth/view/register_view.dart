import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_toast.dart';
import '../viewmodel/auth_view_model.dart';
import '../widget/auth_text_field.dart';
import '../widget/auth_button.dart';
import '../../profile/view/profile_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final authViewModel = context.read<AuthViewModel>();
    try {
      final user = await authViewModel.register(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        bio: bioController.text,
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
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 400,
              child: Column(
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  AuthTextField(
                    controller: usernameController,
                    labelText: 'Username',
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: bioController,
                    labelText: 'Bio (optional)',
                    maxLines: 3,
                    alignLabelWithHint: true,
                  ),
                  const SizedBox(height: 20),
                  AuthButton(
                    onPressed: register,
                    text: 'Register',
                    isLoading: isLoading,
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
