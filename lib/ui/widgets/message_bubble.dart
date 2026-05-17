import 'package:flutter/material.dart';
import '../../core/models/message_model.dart';
import 'media_preview.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
  });

  final ChatMessage message;
  final bool isMine;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? Colors.blueAccent : Colors.grey.shade200;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMenu(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (message.replyPreview != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                child: Text(message.replyPreview!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            if (message.isDeleted)
              const Text('This message was deleted', style: TextStyle(fontStyle: FontStyle.italic))
            else ...[
              if (message.text != null) Text(message.text!),
              MediaPreview(attachments: message.attachments),
            ],
          ]),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.reply), title: const Text('Reply'), onTap: () { Navigator.pop(context); onReply(); }),
          if (isMine) ListTile(leading: const Icon(Icons.edit), title: const Text('Edit'), onTap: () { Navigator.pop(context); onEdit(); }),
          if (isMine) ListTile(leading: const Icon(Icons.delete), title: const Text('Delete'), onTap: () { Navigator.pop(context); onDelete(); }),
        ]),
      ),
    );
  }
}
