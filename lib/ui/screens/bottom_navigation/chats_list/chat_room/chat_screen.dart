import 'dart:io';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/models/chat_message.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_room/chat_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_room/chat_widgets.dart';
import 'package:chat_app/ui/widgets/message_bubble.dart';
import 'package:chat_app/ui/widgets/media_service.dart';
import 'package:chat_app/ui/widgets/message_composer.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.receiver});
  final UserModel receiver;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatMessage? replyingTo;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;

    return ChangeNotifierProvider(
      create: (context) => ChatViewmodel(ChatService(), currentUser!, widget.receiver),
      child: Consumer<ChatViewmodel>(builder: (context, model, _) {
        
        Future<void> handleMedia(File? file, MessageType type) async {
          if (file == null) return;
          final url = await MediaService.instance.uploadMedia(file, 'chat_media');
          if (url != null) {
            await model.sendTextMessage(url, type: type);
          }
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: active.backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 10.h),
                    child: Column(
                      children: [
                        35.verticalSpace,
                        _buildHeader(context, name: widget.receiver.name!, activePreset: active),
                        15.verticalSpace,
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(0),
                          reverse: true,
                          itemCount: model.messages.length,
                          separatorBuilder: (_, __) => 10.verticalSpace,
                          itemBuilder: (context, index) {
                            final message = model.messages[index];
                            return MessageBubble(
                              isMine: message.senderId == currentUser!.uid,
                              message: message,
                              onReply: () {
                                setState(() => replyingTo = message);
                              },
                              onEdit: () {
                                final editController = TextEditingController(text: message.text);
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Edit Message'),
                                    content: TextField(controller: editController),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () {
                                          model.editMessage(message.id, editController.text.trim());
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDelete: () => model.deleteMessage(message.id),
                              onStar: () => model.starMessage(message.id, !message.isStarred),
                              onPin: () => model.pinMessage(message.id, !message.isPinned),
                              onForward: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => ForwardDestinationSheet(message: message),
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
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
              MessageComposer(
                controller: model.controller,
                onChanged: (_) {},
                onSend: () async {
                  final text = model.controller.text.trim();
                  if (text.isNotEmpty) {
                    await model.sendTextMessage(
                      text,
                      replyTo: replyingTo?.id,
                      replyPreview: replyingTo?.text,
                    );
                    model.controller.clear();
                    setState(() => replyingTo = null);
                  }
                },
                onImagePick: () async => handleMedia(await MediaService.instance.pickImage(ImageSource.gallery), MessageType.image),
                onCameraPick: () async => handleMedia(await MediaService.instance.pickImage(ImageSource.camera), MessageType.image),
                onFilePick: () async => handleMedia(await MediaService.instance.pickFile(), MessageType.file),
              )
            ],
          ),
        ),
      );
    }),
  );
}

  void _showContextMenu(BuildContext context, ChatViewmodel model, ChatMessage message) {
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.delete), title: const Text('Delete'), onTap: () {
        model.deleteMessage(message.id);
        Navigator.pop(context);
      }),
    ])));
  }

  Row _buildHeader(BuildContext context, {String name = "", required UiThemePreset activePreset}) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6, right: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: activePreset.primaryAccent.withOpacity(0.12),
            ),
            child: Icon(Icons.arrow_back_ios, color: activePreset.primaryAccent, size: 20),
          ),
        ),
        15.horizontalSpace,
        Text(
          name,
          style: h.copyWith(
            fontSize: 20.sp,
            color: activePreset.isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
