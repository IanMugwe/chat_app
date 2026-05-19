import 'package:flutter/material.dart';
import 'package:chat_app/core/models/conversation.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final unread = conversation.unreadFor(currentUserId);
    return ListTile(
      tileColor: white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: conversation.imageUrl == null
          ? CircleAvatar(
              backgroundColor: primary.withOpacity(0.1),
              radius: 25.r,
              child: Text(
                (conversation.name ?? '?').characters.first.toUpperCase(),
                style: h.copyWith(color: primary, fontSize: 20.sp),
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
        style: body.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black87),
      ),
      subtitle: Text(
        conversation.lastMessage ?? conversation.description ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: body.copyWith(color: grey, fontSize: 14.sp),
      ),
      trailing: unread > 0
          ? CircleAvatar(
              radius: 10.r,
              backgroundColor: primary,
              child: Text(
                '$unread',
                style: small.copyWith(color: white, fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
