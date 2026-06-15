import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app_provider.dart';
import 'app/app_theme.dart';
import 'features/auth/view/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProvider.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FlutterLogin',
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
