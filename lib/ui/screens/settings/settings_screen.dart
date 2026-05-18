import 'package:flutter/material.dart';
import '../bottom_navigation/profile/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.person_rounded,
            title: 'Profile',
            subtitle: 'Edit your profile and account details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Message and group alerts',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.palette_rounded,
            title: 'Appearance',
            subtitle: 'Theme, wallpapers, and chat colors',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.lock_rounded,
            title: 'Privacy',
            subtitle: 'Security, privacy, and blocked users',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.help_rounded,
            title: 'Help & Support',
            subtitle: 'FAQ, contact us, and app info',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Theme.of(context).colorScheme.onSurface;
    final iconColor = isDestructive ? Colors.red : Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
