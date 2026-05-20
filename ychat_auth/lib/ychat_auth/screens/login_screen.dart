import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/y_user_provider.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!formKey.currentState!.validate()) return;
    final result = await context.read<YUserProvider>().login(email.text, password.text);
    if (!mounted) return;
    if (!result.success) YSnack.show(context, result.message ?? 'Login failed', error: true);
  }

  Future<void> _google() async {
    final result = await context.read<YUserProvider>().googleSignIn();
    if (!mounted) return;
    if (!result.success && result.message != 'Google sign-in cancelled.') {
      YSnack.show(context, result.message ?? 'Google sign-in failed', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<YUserProvider>().busy;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Securely sign in to continue your yCHAT conversations.',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: email,
              validator: YChatValidators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: password,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: YTextButton(
                label: 'Forgot password?',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
              ),
            ),
            YPrimaryButton(label: 'Sign in', loading: busy, onPressed: _login),
            const SizedBox(height: 12),
            YPrimaryButton(label: 'Continue with Google', icon: Icons.g_mobiledata, loading: busy, onPressed: _google),
            const SizedBox(height: 8),
            YTextButton(
              label: 'Create a new account',
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignupScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
