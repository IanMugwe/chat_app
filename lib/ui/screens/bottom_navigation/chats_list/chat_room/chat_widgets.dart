import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/models/message_model.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class BottomField extends StatelessWidget {
  const BottomField({super.key, this.onTap, this.onChanged, this.controller, required this.onAttach});
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: grey.withOpacity(0.2),
      padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 25.h),
      child: Row(
        children: [
          PopupMenuButton<String>(
            icon: CircleAvatar(radius: 20.r, backgroundColor: white, child: const Icon(Icons.add)),
            onSelected: (value) => onAttach(),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'image', child: ListTile(leading: Icon(Icons.image), title: Text('Image'))),
              const PopupMenuItem(value: 'doc', child: ListTile(leading: Icon(Icons.description), title: Text('Document'))),
            ],
          ),
          10.horizontalSpace,
          Expanded(
            child: CustomTextfield(
              controller: controller,
              isChatText: true,
              hintText: "Write message..",
              onChanged: onChanged,
              onTap: onTap,
            ),
          ),
          10.horizontalSpace,
          IconButton(onPressed: onTap, icon: const Icon(Icons.send, color: primary)),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, this.isCurrentUser = true, required this.message, required this.onLongPress});
  final bool isCurrentUser;
  final ChatMessage message;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints: BoxConstraints(maxWidth: 1.sw * 0.75),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCurrentUser ? primary : grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isDeleted)
                const Text('This message was deleted', style: TextStyle(fontStyle: FontStyle.italic))
              else
                Text(message.text ?? '', style: body.copyWith(color: isCurrentUser ? white : null)),
              5.verticalSpace,
              Text(
                message.createdAt != null ? DateFormat('hh:mm a').format(message.createdAt!) : '',
                style: small.copyWith(color: isCurrentUser ? white : null),
              )
            ],
          ),
        ),
      ),
    );
  }
}

