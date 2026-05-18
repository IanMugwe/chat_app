import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_list_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:chat_app/ui/screens/ai_chat/ai_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    return ChangeNotifierProvider(
      create: (context) => ChatListViewmodel(DatabaseService(), currentUser!),
      child: Consumer<ChatListViewmodel>(builder: (context, model, _) {
        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: white,
            elevation: 0.5,
            title: Text(
              'yCHAT',
              style: h.copyWith(color: primary, fontSize: 22.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: primary),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: primary),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: CustomTextfield(
                  isSearch: true,
                  hintText: "Search chats or messages",
                  onChanged: model.search,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Row(
                  children: [
                    _buildCategoryChip('All', isActive: true),
                    8.horizontalSpace,
                    _buildCategoryChip('Unread', count: 42),
                    8.horizontalSpace,
                    _buildCategoryChip('Favorites'),
                    8.horizontalSpace,
                    _buildCategoryChip('Groups', count: 8),
                    8.horizontalSpace,
                    _buildCategoryChip('+'),
                  ],
                ),
              ),
              8.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, color: grey, size: 24.r),
                    16.horizontalSpace,
                    Text(
                      'Archived',
                      style: body.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black87),
                    ),
                    const Spacer(),
                    Text(
                      '1',
                      style: small.copyWith(color: primary, fontWeight: FontWeight.bold, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
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
                    backgroundColor: primary.withOpacity(0.12),
                    elevation: 2,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatScreen()),
                      );
                    },
                    child: const Icon(Icons.auto_awesome, color: primary, size: 20),
                  ),
                ),
                12.verticalSpace,
                FloatingActionButton(
                  heroTag: 'new_chat',
                  backgroundColor: primary,
                  elevation: 4,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Start New Chat feature coming soon!'),
                        backgroundColor: primary,
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

  Widget _buildCategoryChip(String label, {bool isActive = false, int? count}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive 
            ? primary.withOpacity(0.12) 
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: body.copyWith(
              color: isActive ? primary : Colors.black87,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13.sp,
            ),
          ),
          if (count != null) ...[
            4.horizontalSpace,
            Text(
              '$count',
              style: small.copyWith(
                color: isActive ? primary : Colors.grey,
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
    return ListTile(
      onTap: onTap,
      tileColor: white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: user.imageUrl == null
          ? CircleAvatar(
              backgroundColor: primary.withOpacity(0.1),
              radius: 25.r,
              child: Text(
                user.name![0].toUpperCase(),
                style: h.copyWith(color: primary, fontSize: 20.sp),
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
        style: body.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black87),
      ),
      subtitle: Text(
        user.lastMessage != null ? user.lastMessage!["content"] : "No messages yet",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: body.copyWith(color: grey, fontSize: 14.sp),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            user.lastMessage == null ? "" : getTime(),
            style: small.copyWith(color: grey),
          ),
          6.verticalSpace,
          user.unreadCounter == 0 || user.unreadCounter == null
              ? const SizedBox(height: 18)
              : CircleAvatar(
                  radius: 9.r,
                  backgroundColor: primary,
                  child: Text(
                    "${user.unreadCounter}",
                    style: small.copyWith(color: white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                )
        ],
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
