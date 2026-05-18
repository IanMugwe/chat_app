import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chats_list_screen.dart';
import 'package:chat_app/ui/screens/settings/settings_screen.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/groups_channels/yohpal_chat_groups_channels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    final screens = [
      const ChatsListScreen(),
      GroupsListScreen(
        currentUserId: currentUser?.uid ?? '',
        currentUserName: currentUser?.name ?? '',
      ),
      ChannelsListScreen(
        currentUserId: currentUser?.uid ?? '',
        currentUserName: currentUser?.name ?? '',
      ),
      const SettingsScreen(),
    ];

    const items = [
      BottomNavigationBarItem(
        label: "Chats",
        icon: BottomNavIcon(icon: Icons.chat_bubble_outline_rounded),
        activeIcon: BottomNavIcon(icon: Icons.chat_bubble_rounded),
      ),
      BottomNavigationBarItem(
        label: "Groups",
        icon: BottomNavIcon(icon: Icons.groups_outlined),
        activeIcon: BottomNavIcon(icon: Icons.groups_rounded),
      ),
      BottomNavigationBarItem(
        label: "Channels",
        icon: BottomNavIcon(icon: Icons.campaign_outlined),
        activeIcon: BottomNavIcon(icon: Icons.campaign_rounded),
      ),
      BottomNavigationBarItem(
        label: "Settings",
        icon: BottomNavIcon(icon: Icons.settings_outlined),
        activeIcon: BottomNavIcon(icon: Icons.settings_rounded),
      ),
    ];
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomNavigationViewmodel()),
        ChangeNotifierProvider(create: (context) => ConversationsProvider(ChatRepository())),
      ],
      child: Consumer<BottomNavigationViewmodel>(builder: (context, model, _) {
        return currentUser == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                body: screens[model.currentIndex],
                bottomNavigationBar: CustomNavBar(
                  currentIndex: model.currentIndex,
                  onTap: model.setIndex,
                  items: items,
                ));
      }),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    required this.items,
  });

  final int currentIndex;
  final void Function(int)? onTap;
  final List<BottomNavigationBarItem> items;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(30.0),
      topRight: Radius.circular(30.0),
    );

    return Container(
        decoration: const BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          ),
        ));
  }
}

class BottomNavIcon extends StatelessWidget {
  const BottomNavIcon({super.key, required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Icon(
        icon,
        size: 26,
      ),
    );
  }
}
