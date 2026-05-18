import 'dart:io';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/models/chat_message.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_room/chat_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_room/chat_widgets.dart';
import 'package:chat_app/ui/widgets/media_service.dart';
import 'package:chat_app/ui/widgets/message_composer.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.receiver});
  final UserModel receiver;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    return ChangeNotifierProvider(
      create: (context) => ChatViewmodel(ChatService(), currentUser!, receiver),
      child: Consumer<ChatViewmodel>(builder: (context, model, _) {
        
        Future<void> handleMedia(File? file, MessageType type) async {
          if (file == null) return;
          final url = await MediaService.instance.uploadMedia(file, 'chat_media');
          if (url != null) {
            await model.sendTextMessage(url, type: type);
          }
        }

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 10.h),
                  child: Column(
                    children: [
                      35.verticalSpace,
                      _buildHeader(context, name: receiver.name!),
                      15.verticalSpace,
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(0),
                          reverse: true,
                          itemCount: model.messages.length,
                          separatorBuilder: (_, __) => 10.verticalSpace,
                          itemBuilder: (context, index) {
                            final message = model.messages[index];
                            return ChatBubble(
                              isCurrentUser: message.senderId == currentUser!.uid,
                              message: message,
                              onLongPress: () => _showContextMenu(context, model, message),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              MessageComposer(
                controller: model.controller,
                onChanged: (_) {},
                onSend: () async {
                  final text = model.controller.text.trim();
                  if (text.isNotEmpty) {
                    await model.sendTextMessage(text);
                    model.controller.clear();
                  }
                },
                onImagePick: () async => handleMedia(await MediaService.instance.pickImage(ImageSource.gallery), MessageType.image),
                onCameraPick: () async => handleMedia(await MediaService.instance.pickImage(ImageSource.camera), MessageType.image),
                onFilePick: () async => handleMedia(await MediaService.instance.pickFile(), MessageType.file),
              )
            ],
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

  Row _buildHeader(BuildContext context, {String name = ""}) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: grey.withOpacity(0.15)),
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        15.horizontalSpace,
        Text(name, style: h.copyWith(fontSize: 20.sp)),
      ],
    );
  }
}
