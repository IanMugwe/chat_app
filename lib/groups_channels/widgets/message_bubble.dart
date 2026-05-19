import 'package:flutter/material.dart';
import 'package:chat_app/core/models/chat_message.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'media_preview.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onReact,
  });

  final ChatMessage message;
  final bool isMine;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(String emoji) onReact;

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? primary : grey.withOpacity(0.12);
    final textStyle = body.copyWith(color: isMine ? white : Colors.black87);
    final timeStyle = small.copyWith(color: isMine ? white.withOpacity(0.7) : grey);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMenu(context),
        child: Container(
          constraints: BoxConstraints(maxWidth: 1.sw * 0.75),
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMine && message.senderName != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    message.senderName!,
                    style: small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primary,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              if (message.replyPreview != null)
                Container(
                  padding: EdgeInsets.all(8.r),
                  margin: EdgeInsets.only(bottom: 6.h),
                  decoration: BoxDecoration(
                    color: isMine ? white.withOpacity(0.15) : Colors.black.withOpacity(.05),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    message.replyPreview!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: small.copyWith(color: isMine ? white : Colors.black87),
                  ),
                ),
              if (message.isDeleted)
                Text(
                  'This message was deleted',
                  style: textStyle.copyWith(fontStyle: FontStyle.italic),
                )
              else ...[
                if (message.text != null && message.text!.isNotEmpty)
                  Text(message.text!, style: textStyle),
                if (message.attachments != null && message.attachments!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: MediaPreview(attachments: message.attachments, isOutgoing: isMine),
                  ),
              ],
              if (message.reactions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Wrap(
                    spacing: 4,
                    children: message.reactions.entries
                        .where((e) => e.value.isNotEmpty)
                        .map((e) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: isMine ? white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                '${e.key} ${e.value.length}',
                                style: small.copyWith(fontSize: 10.sp, color: isMine ? white : Colors.black54),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              4.verticalSpace,
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  message.createdAt != null ? DateFormat('hh:mm a').format(message.createdAt!) : '',
                  style: timeStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.reply, color: primary), title: const Text('Reply'), onTap: () { Navigator.pop(context); onReply(); }),
          if (isMine) ListTile(leading: const Icon(Icons.edit, color: primary), title: const Text('Edit'), onTap: () { Navigator.pop(context); onEdit(); }),
          if (isMine) ListTile(leading: const Icon(Icons.delete, color: primary), title: const Text('Delete'), onTap: () { Navigator.pop(context); onDelete(); }),
          ListTile(leading: const Text('👍', style: TextStyle(fontSize: 20)), title: const Text('React 👍'), onTap: () { Navigator.pop(context); onReact('👍'); }),
        ]),
      ),
    );
  }
}
