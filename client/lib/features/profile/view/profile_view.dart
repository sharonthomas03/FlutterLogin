import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/widget/theme_toggle_button.dart';
import '../../../core/utils/app_toast.dart';
import '../../auth/model/user_model.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../../auth/view/login_view.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../widget/profile_info_card.dart';
import '../widget/edit_profile_dialog.dart';

class ProfileView extends StatefulWidget {
  final User user;

  const ProfileView({super.key, required this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final profileViewModel = context.read<ProfileViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    try {
      final updatedUser = await profileViewModel.updateProfile(
        user: currentUser,
        username: usernameController.text,
        email: emailController.text,
        bio: bioController.text,
      );

      if (!mounted) return;

      setState(() {
        currentUser = updatedUser;
      });
      authViewModel.updateCurrentUser(updatedUser);

      Navigator.pop(context);
      AppToast.show(context, "Profile Updated");
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, profileViewModel.errorMessage ?? e.toString());
    }
  }

  Future<void> logout() async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  Future<void> showEditProfileDialog() async {
    usernameController.text = currentUser.username;
    emailController.text = currentUser.email;
    bioController.text = currentUser.bio;

    await showDialog(
      context: context,
      builder: (context) {
        return Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            return EditProfileDialog(
              usernameController: usernameController,
              emailController: emailController,
              bioController: bioController,
              isSaving: viewModel.isSaving,
              onSave: saveProfile,
            );
          },
        );
      },
    );
  }

  String get displayName {
    final trimmed = currentUser.username.trim();
    return trimmed.isEmpty ? 'User' : trimmed;
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final pageGradient = isDark
        ? const [Color(0xFF050816), Color(0xFF0B1220), Color(0xFF121A2B)]
        : const [Color(0xFFF7FAFF), Color(0xFFEEF4FF), Color(0xFFE8F7F4)];

    final cardGradient = isDark
        ? const [Color(0xFF161F34), Color(0xFF0F172A)]
        : const [Color(0xFFFFFFFF), Color(0xFFF7FBFF)];

    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFD9E7FF);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.30)
        : const Color(0xFF9FB9E8).withValues(alpha: 0.26);

    final titleColor = isDark ? Colors.white : const Color(0xFF14213D);
    final buttonForeground = isDark ? const Color(0xFF04111F) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        actions: [
          const ThemeToggleButton(),
          TextButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text("Logout"),
            style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: pageGradient,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: cardGradient,
                  ),
                  border: Border.all(color: cardBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF60A5FA), Color(0xFF2DD4BF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF60A5FA,
                              ).withValues(alpha: 0.28),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF04111F)
                                : Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ProfileInfoCard(user: currentUser),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: showEditProfileDialog,
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text("Edit Profile"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: buttonForeground,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
