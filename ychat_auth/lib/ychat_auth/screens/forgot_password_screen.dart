import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/y_user_provider.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/ychat_auth_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  bool loading = false;
  bool sent = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final result = await context.read<YUserProvider>().sendPasswordReset(email.text);
    if (!mounted) return;
    setState(() {
      loading = false;
      sent = result.success;
    });
    YSnack.show(
      context,
      result.message ?? (result.success ? 'Reset email sent' : 'Unable to send reset email'),
      error: !result.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'Enter your email and we will send a secure reset link.',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            if (sent)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Check your inbox and follow the reset link to create a new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: YChatAuthColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            TextFormField(
              controller: email,
              validator: YChatValidators.email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 18),
            YPrimaryButton(label: sent ? 'Send again' : 'Send reset link', loading: loading, onPressed: _submit),
            const SizedBox(height: 8),
            YTextButton(label: 'Back to login', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
