import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app_provider.dart';
import 'app/app_theme.dart';
import 'app/theme_notifier.dart';
import 'features/auth/view/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProvider.providers,
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FlutterLogin',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
