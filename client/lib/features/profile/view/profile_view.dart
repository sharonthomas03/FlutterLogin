import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_toast.dart';
import '../../auth/model/user_model.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../../auth/view/login_view.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../widget/profile_info_card.dart';
import '../widget/edit_profile_dialog.dart';

class ProfileView extends StatefulWidget {
  final User user;

  const ProfileView({
    super.key,
    required this.user,
  });

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
      MaterialPageRoute(
        builder: (_) => const LoginView(),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          TextButton(
            onPressed: logout,
            child: const Text("Logout"),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "User Details",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                ProfileInfoCard(user: currentUser),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: showEditProfileDialog,
                    child: const Text("Edit Profile"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
