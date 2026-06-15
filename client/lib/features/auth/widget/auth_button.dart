import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(isLoading ? "Loading..." : text),
        ),
      ),
    );
  }
}
