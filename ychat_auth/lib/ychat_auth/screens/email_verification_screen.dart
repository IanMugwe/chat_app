import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/y_user_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/ychat_auth_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});
  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? timer;
  int remaining = 60;
  bool refreshing = false;
  bool resending = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    timer?.cancel();
    setState(() => remaining = 60);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (remaining <= 1) {
        t.cancel();
        setState(() => remaining = 0);
      } else {
        setState(() => remaining--);
      }
    });
  }

  Future<void> _resend() async {
    if (remaining > 0) return;
    setState(() => resending = true);
    final result = await context.read<YUserProvider>().resendVerificationEmail();
    if (!mounted) return;
    setState(() => resending = false);
    YSnack.show(context, result.message ?? 'Verification email sent', error: !result.success);
    if (result.success) _startCooldown();
  }

  Future<void> _refresh() async {
    setState(() => refreshing = true);
    await context.read<YUserProvider>().refreshVerification();
    if (!mounted) return;
    setState(() => refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<YUserProvider>();
    final email = provider.firebaseUser?.email ?? 'your email';

    return AuthScaffold(
      title: 'Verify your email',
      subtitle: 'We sent a verification link to $email. Verify before accessing yCHAT.',
      child: Column(
        children: [
          const Icon(Icons.mark_email_unread_outlined, size: 58, color: YChatAuthColors.red),
          const SizedBox(height: 16),
          const Text(
            'Open your email inbox, tap the verification link, then return here and press “I Have Verified”.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: YChatAuthColors.textDark,
              height: 1.4,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          YPrimaryButton(label: 'I Have Verified', loading: refreshing || provider.busy, onPressed: _refresh),
          const SizedBox(height: 12),
          YPrimaryButton(
            label: remaining > 0 ? 'Resend in ${remaining}s' : 'Resend verification email',
            loading: resending,
            onPressed: remaining > 0 ? null : _resend,
          ),
          const SizedBox(height: 10),
          YTextButton(label: 'Sign out', onPressed: () => context.read<YUserProvider>().logout()),
        ],
      ),
    );
  }
}
