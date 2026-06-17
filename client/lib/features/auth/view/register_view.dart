import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/widget/theme_toggle_button.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        actions: const [ThemeToggleButton()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.secondary.withValues(alpha: 0.10),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 420,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.secondary.withValues(
                          alpha: 0.16,
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          color: colorScheme.secondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Create account',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set up your profile in a few quick steps.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 28),
                      AuthTextField(
                        controller: usernameController,
                        labelText: 'Username',
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: passwordController,
                        labelText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}
