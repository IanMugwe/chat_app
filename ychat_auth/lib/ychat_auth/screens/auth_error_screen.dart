import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/y_user_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';

class AuthErrorScreen extends StatelessWidget {
  const AuthErrorScreen({super.key, required this.message});

  final String message;
 
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Something went wrong',
      subtitle: message,
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 58, color: Colors.redAccent),
          const SizedBox(height: 16),
          YPrimaryButton(label: 'Sign out and retry', onPressed: () => context.read<YUserProvider>().logout()),
        ],
      ),
    );
  }
}
