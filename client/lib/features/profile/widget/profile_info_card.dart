import 'package:flutter/material.dart';
import '../../auth/model/user_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final User user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final roleValue = user.role.isNotEmpty
        ? '${user.role[0].toUpperCase()}${user.role.substring(1)}'
        : 'User';

    return Column(
      children: [
        _ProfileDetailTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        const SizedBox(height: 16),
        _ProfileDetailTile(
          icon: Icons.edit_note_rounded,
          label: 'Bio',
          value: user.bio.isEmpty
              ? 'Flutter developer building clean and modern experiences.'
              : user.bio,
        ),
        const SizedBox(height: 16),
        _ProfileDetailTile(
          icon: Icons.admin_panel_settings_outlined,
          label: 'Role',
          value: roleValue,
        ),
      ],
    );
  }
}

class _ProfileDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tileColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : const Color(0xFFF7FAFF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFDCE8F8);
    final iconBackground = isDark
        ? const Color(0xFF60A5FA).withValues(alpha: 0.14)
        : const Color(0xFF3B82F6).withValues(alpha: 0.10);
    final iconColor = isDark
        ? const Color(0xFF93C5FD)
        : const Color(0xFF2563EB);
    final labelColor = isDark
        ? const Color(0xFF93A4C3)
        : const Color(0xFF64748B);
    final valueColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
