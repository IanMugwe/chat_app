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
import 'package:chat_app/ui/screens/other/user_profile_screen.dart';
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
      create: (context) =>
          ChatViewmodel(ChatService(), currentUser!, widget.receiver),
      child: Consumer<ChatViewmodel>(builder: (context, model, _) {
        Future<void> handleMedia(File? file, MessageType type) async {
          if (file == null) return;
          final url =
              await MediaService.instance.uploadMedia(file, 'chat_media');
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 1.sw * 0.05, vertical: 10.h),
                    child: Column(
                      children: [
                        35.verticalSpace,
                        _buildHeader(context,
                            name: widget.receiver.name!, activePreset: active),
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
                                  final editController =
                                      TextEditingController(text: message.text);
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Edit Message'),
                                      content:
                                          TextField(controller: editController),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () {
                                            model.editMessage(message.id,
                                                editController.text.trim());
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDelete: () => model.deleteMessage(message.id),
                                onStar: () => model.starMessage(
                                    message.id, !message.isStarred),
                                onPin: () => model.pinMessage(
                                    message.id, !message.isPinned),
                                onForward: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => ForwardDestinationSheet(
                                        message: message),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      Expanded(
                          child: Text(
                              'Replying to: ${replyingTo?.text ?? "Media"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: body.copyWith(color: grey))),
                      IconButton(
                          onPressed: () => setState(() => replyingTo = null),
                          icon: const Icon(Icons.close, color: primary)),
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
                  onImagePick: () async => handleMedia(
                      await MediaService.instance
                          .pickImage(ImageSource.gallery),
                      MessageType.image),
                  onCameraPick: () async => handleMedia(
                      await MediaService.instance.pickImage(ImageSource.camera),
                      MessageType.image),
                  onFilePick: () async => handleMedia(
                      await MediaService.instance.pickFile(), MessageType.file),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showContextMenu(
      BuildContext context, ChatViewmodel model, ChatMessage message) {
    showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
                child: Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () {
                    model.deleteMessage(message.id);
                    Navigator.pop(context);
                  }),
            ])));
  }

  Row _buildHeader(BuildContext context,
      {String name = "", required UiThemePreset activePreset}) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activePreset.isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: activePreset.isDark ? Colors.white : Colors.black87,
                size: 16.r),
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(user: widget.receiver),
                ),
              );
            },
            child: Row(
              children: [
                Stack(
                  children: [
                    widget.receiver.imageUrl == null
                        ? CircleAvatar(
                            radius: 18.r,
                            backgroundColor:
                                activePreset.primaryAccent.withOpacity(0.12),
                            child: Text(
                              (widget.receiver.name != null &&
                                      widget.receiver.name!.isNotEmpty)
                                  ? widget.receiver.name![0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: activePreset.primaryAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 18.r,
                            backgroundImage:
                                NetworkImage(widget.receiver.imageUrl!),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 9.r,
                        width: 9.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // online green
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: activePreset.isDark
                                ? const Color(0xFF1E1C24)
                                : Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                10.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: h.copyWith(
                          fontSize: 15.sp,
                          color: activePreset.isDark
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      2.verticalSpace,
                      Text(
                        'Online now',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: activePreset.primaryAccent.withOpacity(0.85),
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
        Icon(Icons.videocam_outlined,
            color: activePreset.isDark ? Colors.white70 : Colors.black54,
            size: 22.r),
        14.horizontalSpace,
        Icon(Icons.phone_outlined,
            color: activePreset.isDark ? Colors.white70 : Colors.black54,
            size: 20.r),
        14.horizontalSpace,
        Icon(Icons.more_vert_rounded,
            color: activePreset.isDark ? Colors.white70 : Colors.black54,
            size: 20.r),
      ],
    );
  }
}
