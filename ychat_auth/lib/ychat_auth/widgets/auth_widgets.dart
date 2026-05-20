import 'package:flutter/material.dart';
import 'ychat_auth_theme.dart';

class YPrimaryButton extends StatelessWidget {
  const YPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: onPressed == null || loading ? 0.75 : 1,
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: YChatAuthColors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: loading ? null : onPressed,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
        ),
      ),
    );
  }
}

class YTextButton extends StatelessWidget {
  const YTextButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: YChatAuthColors.red,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class YSnack {
  static void show(BuildContext context, String message, {bool error = false}) {
    final bg = error ? YChatAuthColors.red : const Color(0xFF262626);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      );
  }
}

