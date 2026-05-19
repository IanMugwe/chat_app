import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/conversation.dart';
import 'package:chat_app/core/models/chat_message.dart';
import 'package:chat_app/core/models/media_attachment.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/ui/widgets/message_composer.dart';
import 'package:chat_app/ui/widgets/media_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/chat_room_provider.dart';
import '../../services/chat_repository.dart';
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
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatRoomProvider(widget.repository)
        ..watch(scope: widget.scope, conversationId: widget.conversation.id)
        ..markRead(widget.scope, widget.conversation.id, widget.currentUserId),
      child: Consumer<ChatRoomProvider>(builder: (context, room, _) {
        final canPost = widget.conversation.canPost(widget.currentUserId);

        Future<void> handleMedia(File? file, MessageType type) async {
          if (file == null) return;
          final url = await MediaService.instance.uploadMedia(file, 'chat_media');
          if (url != null) {
            final fileName = file.path.split('/').last;
            final attachment = MediaAttachment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              url: url,
              storagePath: 'chat_media/$fileName',
              fileName: fileName,
              mimeType: type == MessageType.image ? 'image/jpeg' : 'application/octet-stream',
              sizeBytes: await file.length(),
            );
            await room.sendMedia(
              scope: widget.scope,
              conversationId: widget.conversation.id,
              senderId: widget.currentUserId,
              senderName: widget.currentUserName,
              type: type,
              attachments: [attachment],
            );
          }
        }

        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: primary),
            title: Text(
              widget.conversation.name ?? 'Chat',
              style: h.copyWith(color: primary, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: primary),
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
                onStar: (m) => room.starMessage(widget.scope, widget.conversation.id, m.id, !m.isStarred),
                onPin: (m) => room.pinMessage(widget.scope, widget.conversation.id, m.id, !m.isPinned),
              ),
            ),
            if (replyingTo != null)
              Container(
                color: const Color(0xFFF5F5F5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  Expanded(child: Text('Replying to: ${replyingTo?.text ?? "Media"}', maxLines: 1, overflow: TextOverflow.ellipsis, style: body.copyWith(color: grey))),
                  IconButton(onPressed: () => setState(() => replyingTo = null), icon: const Icon(Icons.close, color: primary)),
                ]),
              ),
            if (canPost)
              MessageComposer(
                controller: _controller,
                onChanged: (_) {},
                onSend: () async {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    await room.sendText(
                      scope: widget.scope,
                      conversationId: widget.conversation.id,
                      senderId: widget.currentUserId,
                      senderName: widget.currentUserName,
                      text: text,
                      replyToMessageId: replyingTo?.id,
                      replyPreview: replyingTo?.text,
                    );
                    _controller.clear();
                    setState(() => replyingTo = null);
                  }
                },
                onImagePick: () async => handleMedia(await MediaService.instance.pickImage(ImageSource.gallery), MessageType.image),
                onCameraPick: () async => handleMedia(await MediaService.instance.pickImage(ImageSource.camera), MessageType.image),
                onFilePick: () async => handleMedia(await MediaService.instance.pickFile(), MessageType.file),
              )
            else
              const SafeArea(child: Padding(padding: EdgeInsets.all(12), child: Text('Only admins can post in this channel.', style: TextStyle(color: grey)))),
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
