import 'package:flutter/material.dart';
import 'package:chat_app/core/models/conversation.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;
    final unread = conversation.unreadFor(currentUserId);

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
          leading: conversation.imageUrl == null
              ? CircleAvatar(
                  backgroundColor: active.primaryAccent.withOpacity(0.12),
                  radius: 25.r,
                  child: Text(
                    (conversation.name ?? '?').characters.first.toUpperCase(),
                    style: h.copyWith(color: active.primaryAccent, fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                )
              : ClipOval(
                  child: Image.network(
                    conversation.imageUrl!,
                    height: 50.r,
                    width: 50.r,
                    fit: BoxFit.cover,
                  ),
                ),
          title: Text(
            conversation.name ?? 'Untitled',
            style: body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: active.isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            conversation.lastMessage ?? conversation.description ?? 'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: body.copyWith(
              color: active.isDark ? Colors.white54 : grey,
              fontSize: 14.sp,
            ),
          ),
          trailing: unread > 0
              ? CircleAvatar(
                  radius: 9.r,
                  backgroundColor: active.primaryAccent,
                  child: Text(
                    '$unread',
                    style: small.copyWith(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
