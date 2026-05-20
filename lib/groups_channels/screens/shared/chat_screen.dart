import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/conversation.dart';
import 'package:chat_app/core/models/chat_message.dart';
import 'package:chat_app/core/models/media_attachment.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

        final uiTheme = Provider.of<UiThemeProvider>(context);
        final active = uiTheme.activePreset;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(65.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: active.isDark ? Colors.white : Colors.black87, size: 16.r),
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                              if (widget.scope == ChatScope.channel) {
                                return ChannelInfoScreen(conversation: widget.conversation, currentUserId: widget.currentUserId);
                              }
                              return GroupInfoScreen(conversation: widget.conversation, currentUserId: widget.currentUserId);
                            }));
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18.r,
                                backgroundColor: active.primaryAccent.withOpacity(0.12),
                                child: Text(
                                  (widget.conversation.name ?? '?')[0].toUpperCase(),
                                  style: TextStyle(color: active.primaryAccent, fontWeight: FontWeight.bold, fontSize: 14.sp),
                                ),
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.conversation.name ?? 'Chat',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: h.copyWith(
                                        fontSize: 15.sp,
                                        color: active.isDark ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    2.verticalSpace,
                                    Text(
                                      widget.scope == ChatScope.channel ? 'Channel Room' : 'Group Room',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: active.primaryAccent.withOpacity(0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(Icons.videocam_outlined, color: active.isDark ? Colors.white70 : Colors.black54, size: 22.r),
                      14.horizontalSpace,
                      Icon(Icons.phone_outlined, color: active.isDark ? Colors.white70 : Colors.black54, size: 20.r),
                      14.horizontalSpace,
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                            if (widget.scope == ChatScope.channel) {
                              return ChannelInfoScreen(conversation: widget.conversation, currentUserId: widget.currentUserId);
                            }
                            return GroupInfoScreen(conversation: widget.conversation, currentUserId: widget.currentUserId);
                          }));
                        },
                        child: Icon(Icons.info_outline_rounded, color: active.isDark ? Colors.white70 : Colors.black54, size: 20.r),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: active.backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: [
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
                  color: active.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(children: [
                    Expanded(child: Text('Replying to: ${replyingTo?.text ?? "Media"}', maxLines: 1, overflow: TextOverflow.ellipsis, style: body.copyWith(color: active.isDark ? Colors.white70 : grey))),
                    IconButton(onPressed: () => setState(() => replyingTo = null), icon: Icon(Icons.close, color: active.primaryAccent)),
                  ]),
                ),
              if (canPost)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: MessageComposer(
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
                  ),
                )
              else
                SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Text('Only admins can post in this channel.', style: TextStyle(color: active.isDark ? Colors.white54 : grey)))),
            ]),
          ),
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
