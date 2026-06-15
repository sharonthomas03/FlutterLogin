import 'package:flutter/material.dart';

class EditProfileDialog extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController bioController;
  final bool isSaving;
  final VoidCallback onSave;

  const EditProfileDialog({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.bioController,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Profile"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Bio",
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : onSave,
          child: Text(
            isSaving ? "Saving..." : "Save",
          ),
        ),
      ],
    );
  }
}
