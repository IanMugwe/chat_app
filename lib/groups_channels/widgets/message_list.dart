import 'package:flutter/material.dart';
import 'package:chat_app/core/models/chat_message.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onReact,
    this.loading = false,
  });

  final List<ChatMessage> messages;
  final String currentUserId;
  final void Function(ChatMessage message) onReply;
  final void Function(ChatMessage message) onEdit;
  final void Function(ChatMessage message) onDelete;
  final void Function(ChatMessage message, String emoji) onReact;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (messages.isEmpty) return const Center(child: Text('No messages yet'));
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final m = messages[i];
        return MessageBubble(
          message: m,
          isMine: m.senderId == currentUserId,
          onReply: () => onReply(m),
          onEdit: () => onEdit(m),
          onDelete: () => onDelete(m),
          onReact: (e) => onReact(m, e),
        );
      },
    );
  }
}
