import 'package:flutter/material.dart';
import '../../auth/model/user_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final User user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Username: ${user.username}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          "Email: ${user.email}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          "Bio: ${user.bio.isEmpty ? 'No bio yet' : user.bio}",
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
