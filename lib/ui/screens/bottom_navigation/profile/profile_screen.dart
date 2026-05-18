import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person_rounded,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Name & Username
            Text(
              'John Doe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '@john_doe',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Bio
            Text(
              '"Building cool apps"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Edit Profile Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 40),
            
            // Account Info Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Info',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildInfoTile(context, Icons.email_rounded, 'Email', 'john.doe@example.com'),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildInfoTile(context, Icons.phone_rounded, 'Phone', '+1 234 567 8900'),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildInfoTile(context, Icons.alternate_email_rounded, 'Username', '@john_doe'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Logout Button
            CustomButton(
              text: "Logout",
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).clearUser();
                AuthService().logout();
                // Optionally pop the profile screen if needed, but wrapper usually handles state
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

