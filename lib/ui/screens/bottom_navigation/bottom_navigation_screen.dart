import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chats_list_screen.dart';
import 'package:chat_app/ui/screens/settings/settings_screen.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/groups_channels/yohpal_chat_groups_channels.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;

    final borderRadius = BorderRadius.circular(32.r);

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: active.isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.85),
          borderRadius: borderRadius,
          border: Border.all(
            color: active.isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(active.isDark ? 0.3 : 0.08),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedItemColor: active.primaryAccent,
            unselectedItemColor: active.isDark ? Colors.white38 : Colors.grey,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp, color: active.primaryAccent),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 11.sp, color: Colors.grey),
          ),
        ),
      ),
    );
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
        size: 24,
      ),
    );
  }
}
