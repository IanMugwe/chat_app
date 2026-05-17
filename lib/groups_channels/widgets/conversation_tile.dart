import 'package:flutter/material.dart';
import '../models/conversation.dart';

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
      leading: CircleAvatar(
        backgroundImage: conversation.imageUrl == null ? null : NetworkImage(conversation.imageUrl!),
        child: conversation.imageUrl == null ? Text((conversation.name ?? '?').characters.first.toUpperCase()) : null,
      ),
      title: Text(conversation.name ?? 'Untitled'),
      subtitle: Text(conversation.lastMessage ?? conversation.description ?? ''),
      trailing: unread > 0 ? CircleAvatar(radius: 12, child: Text('$unread', style: const TextStyle(fontSize: 11))) : null,
      onTap: onTap,
    );
  }
}
