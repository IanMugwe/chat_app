import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/conversation.dart';
import 'package:chat_app/core/models/chat_message.dart';
import '../../providers/chat_room_provider.dart';
import '../../services/chat_repository.dart';
import '../../widgets/chat_input.dart';
import '../../widgets/message_list.dart';
import '../groups/group_info_screen.dart';
import '../channels/channel_info_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.scope,
    required this.conversation,
    required this.currentUserId,
    required this.currentUserName,
    required this.repository,
  });

  final ChatScope scope;
  final ChatConversation conversation;
  final String currentUserId;
  final String currentUserName;
  final ChatRepository repository;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatMessage? replyingTo;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatRoomProvider(widget.repository)
        ..watch(scope: widget.scope, conversationId: widget.conversation.id)
        ..markRead(widget.scope, widget.conversation.id, widget.currentUserId),
      child: Consumer<ChatRoomProvider>(builder: (context, room, _) {
        final canPost = widget.conversation.canPost(widget.currentUserId);
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.conversation.name ?? 'Chat'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) {
                  if (widget.scope == ChatScope.channel) {
                    return ChannelInfoScreen(conversation: widget.conversation, currentUserId: widget.currentUserId);
                  }
                  return GroupInfoScreen(conversation: widget.conversation, currentUserId: widget.currentUserId);
                })),
              )
            ],
          ),
          body: Column(children: [
            Expanded(
              child: MessageList(
                messages: room.messages,
                currentUserId: widget.currentUserId,
                loading: room.loading,
                onReply: (m) => setState(() => replyingTo = m),
                onEdit: (m) => _edit(context, room, m),
                onDelete: (m) => room.delete(widget.scope, widget.conversation.id, m.id),
                onReact: (m, e) => room.react(widget.scope, widget.conversation.id, m.id, e, widget.currentUserId, true),
              ),
            ),
            if (canPost)
              ChatInput(
                replyPreview: replyingTo?.text,
                onCancelReply: () => setState(() => replyingTo = null),
                onAttach: () {},
                onSend: (text) async {
                  await room.sendText(
                    scope: widget.scope,
                    conversationId: widget.conversation.id,
                    senderId: widget.currentUserId,
                    senderName: widget.currentUserName,
                    text: text,
                    replyToMessageId: replyingTo?.id,
                    replyPreview: replyingTo?.text,
                  );
                  setState(() => replyingTo = null);
                },
              )
            else
              const SafeArea(child: Padding(padding: EdgeInsets.all(12), child: Text('Only admins can post in this channel.'))),
          ]),
        );
      }),
    );
  }

  Future<void> _edit(BuildContext context, ChatRoomProvider room, ChatMessage m) async {
    final c = TextEditingController(text: m.text ?? '');
    final text = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: const Text('Edit message'),
      content: TextField(controller: c, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Save')),
      ],
    ));
    if (text != null && text.isNotEmpty) {
      await room.edit(widget.scope, widget.conversation.id, m.id, text);
    }
  }
}
