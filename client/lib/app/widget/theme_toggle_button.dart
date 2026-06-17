import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IconButton(
      tooltip: themeNotifier.isDarkMode
          ? 'Switch to light mode'
          : 'Switch to dark mode',
      style: IconButton.styleFrom(
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFEAF2FF),
        foregroundColor: theme.colorScheme.onSurface,
      ),
      onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
      icon: Icon(
        themeNotifier.isDarkMode
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
      ),
    );
  }
}
