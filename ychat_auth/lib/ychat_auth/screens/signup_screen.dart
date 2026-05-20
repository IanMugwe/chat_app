import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/y_user_provider.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!formKey.currentState!.validate()) return;
    final result = await context.read<YUserProvider>().signup(
          name: name.text,
          email: email.text,
          password: password.text,
        );

    if (!mounted) return;
    if (!result.success) {
      YSnack.show(context, result.message ?? 'Signup failed', error: true);
    } else {
      YSnack.show(context, 'Account created. Please verify your email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<YUserProvider>().busy;

    return AuthScaffold(
      title: 'Create your yCHAT account',
      subtitle: 'Start secure messaging with a verified account.',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: name,
              validator: YChatValidators.name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 14),
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
              validator: YChatValidators.password,
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _signup(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),
            const SizedBox(height: 18),
            YPrimaryButton(label: 'Create account', loading: busy, onPressed: _signup),
            const SizedBox(height: 8),
            YTextButton(
              label: 'Already have an account? Sign in',
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
