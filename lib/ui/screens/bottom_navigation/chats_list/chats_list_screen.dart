import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_list_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:chat_app/ui/screens/ai_chat/ai_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;

    return ChangeNotifierProvider(
      create: (context) => ChatListViewmodel(DatabaseService(), currentUser!),
      child: Consumer<ChatListViewmodel>(builder: (context, model, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: active.isDark ? Colors.white : Colors.black87,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search chats or messages...',
                      hintStyle: TextStyle(
                        color: active.isDark ? Colors.white38 : Colors.black38,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: model.search,
                  )
                : Text(
                    'ychat',
                    style: h.copyWith(
                      color: active.isDark ? Colors.white : Colors.black87,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
            actions: [
              _buildTopActionIcon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      model.search('');
                    }
                  });
                },
                active,
              ),
              _buildTopActionIcon(Icons.camera_alt_outlined, () {}, active),
              _buildTopActionIcon(Icons.more_vert_rounded, () {}, active),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: active.backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.verticalSpace,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Row(
                    children: [
                      _buildCategoryChip('All', isActive: true, activePreset: active),
                      8.horizontalSpace,
                      _buildCategoryChip('Unread', count: 4, activePreset: active),
                      8.horizontalSpace,
                      _buildCategoryChip('Favorites', activePreset: active),
                      8.horizontalSpace,
                      _buildCategoryChip('Groups', count: 8, activePreset: active),
                      8.horizontalSpace,
                      _buildCategoryChip('Channels', count: 3, activePreset: active),
                    ],
                  ),
                ),
                10.verticalSpace,
                const Divider(height: 1, color: Colors.transparent),
              model.state == ViewState.loading
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : model.users.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text("No Users yet"),
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            itemCount: model.filteredUsers.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            itemBuilder: (context, index) {
                              final user = model.filteredUsers[index];
                              return ChatTile(
                                user: user,
                                onTap: () => Navigator.pushNamed(
                                    context, chatRoom,
                                    arguments: user),
                              );
                            },
                          ),
                        )
            ],
          ),
        ),
        floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 12.h, right: 4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 42.r,
                  width: 42.r,
                  child: FloatingActionButton(
                    heroTag: 'ai_chat',
                    backgroundColor: active.primaryAccent.withOpacity(0.15),
                    elevation: 2,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatScreen()),
                      );
                    },
                    child: Icon(Icons.auto_awesome, color: active.primaryAccent, size: 20),
                  ),
                ),
                12.verticalSpace,
                FloatingActionButton(
                  heroTag: 'new_chat',
                  backgroundColor: active.primaryAccent,
                  elevation: 4,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Start New Chat feature coming soon!'),
                        backgroundColor: active.primaryAccent,
                      ),
                    );
                  },
                  child: const Icon(Icons.chat, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTopActionIcon(IconData icon, VoidCallback onTap, UiThemePreset activePreset) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      height: 36.r,
      width: 36.r,
      decoration: BoxDecoration(
        color: activePreset.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Icon(icon, color: activePreset.isDark ? Colors.white70 : Colors.black87, size: 18.r),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isActive = false, int? count, required UiThemePreset activePreset}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive 
            ? activePreset.primaryAccent 
            : (activePreset.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isActive ? Colors.transparent : (activePreset.isDark ? Colors.white12 : Colors.black12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: body.copyWith(
              color: isActive ? Colors.white : (activePreset.isDark ? Colors.white70 : Colors.black87),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13.sp,
            ),
          ),
          if (count != null) ...[
            4.horizontalSpace,
            Text(
              '$count',
              style: small.copyWith(
                color: isActive ? Colors.white70 : activePreset.primaryAccent,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, this.onTap, required this.user});
  final UserModel user;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Container(
        decoration: BoxDecoration(
          color: active.isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: active.isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: user.imageUrl == null
              ? CircleAvatar(
                  backgroundColor: active.primaryAccent.withOpacity(0.12),
                  radius: 25.r,
                  child: Text(
                    user.name![0].toUpperCase(),
                    style: h.copyWith(color: active.primaryAccent, fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                )
              : ClipOval(
                  child: Image.network(
                    user.imageUrl!,
                    height: 50.r,
                    width: 50.r,
                    fit: BoxFit.cover,
                  ),
                ),
          title: Text(
            user.name!,
            style: body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: active.isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            user.lastMessage != null ? user.lastMessage!["content"] : "No messages yet",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: body.copyWith(
              color: active.isDark ? Colors.white54 : grey,
              fontSize: 14.sp,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user.lastMessage == null ? "" : getTime(),
                style: small.copyWith(color: active.isDark ? Colors.white38 : grey),
              ),
              6.verticalSpace,
              user.unreadCounter == 0 || user.unreadCounter == null
                  ? const SizedBox(height: 18)
                  : CircleAvatar(
                      radius: 9.r,
                      backgroundColor: active.primaryAccent,
                      child: Text(
                        "${user.unreadCounter}",
                        style: small.copyWith(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  String getTime() {
    DateTime now = DateTime.now();

    DateTime lastMessageTime = user.lastMessage == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(user.lastMessage!["timestamp"]);

    int minutes = now.difference(lastMessageTime).inMinutes % 60;

    if (minutes < 60) {
      return "$minutes minutes ago";
    } else {
      return "${now.difference(lastMessageTime).inHours % 24} hours ago";
    }
  }
}
