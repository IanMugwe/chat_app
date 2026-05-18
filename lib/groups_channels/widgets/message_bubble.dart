import 'package:flutter/material.dart';
import '../models/message.dart';
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
    final bg = isMine ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade100;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMenu(context),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!isMine && message.senderName != null)
              Text(message.senderName!, style: Theme.of(context).textTheme.labelSmall),
            if (message.replyPreview != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(.05), borderRadius: BorderRadius.circular(8)),
                child: Text(message.replyPreview!, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            if (message.isDeleted)
              const Text('This message was deleted', style: TextStyle(fontStyle: FontStyle.italic))
            else ...[
              if (message.text != null && message.text!.isNotEmpty) Text(message.text!),
              MediaPreview(attachments: message.attachments, isOutgoing: isMine),
            ],
            if (message.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 4,
                  children: message.reactions.entries
                      .where((e) => e.value.isNotEmpty)
                      .map((e) => Chip(label: Text('${e.key} ${e.value.length}'), visualDensity: VisualDensity.compact))
                      .toList(),
                ),
              ),
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
          ListTile(leading: const Text('👍'), title: const Text('React'), onTap: () { Navigator.pop(context); onReact('👍'); }),
        ]),
      ),
    );
  }
}
