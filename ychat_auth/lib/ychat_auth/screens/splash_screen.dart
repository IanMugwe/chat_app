import 'package:flutter/material.dart';
import '../widgets/ychat_auth_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.message = 'Preparing yCHAT...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YChatAuthColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'ychat-logo',
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(colors: [YChatAuthColors.red, YChatAuthColors.redDark]),
                ),
                alignment: Alignment.center,
                child: const Text('yC', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 22),
            const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.2)),
            const SizedBox(height: 14),
            Text(message, style: const TextStyle(color: YChatAuthColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
