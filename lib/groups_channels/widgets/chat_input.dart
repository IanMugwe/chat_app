import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    required this.onAttach,
    this.replyPreview,
    this.onCancelReply,
  });

  final void Function(String text) onSend;
  final VoidCallback onAttach;
  final String? replyPreview;
  final VoidCallback? onCancelReply;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (widget.replyPreview != null)
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(child: Text('Replying to: ${widget.replyPreview}', maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(onPressed: widget.onCancelReply, icon: const Icon(Icons.close)),
            ]),
          ),
        Row(children: [
          IconButton(onPressed: widget.onAttach, icon: const Icon(Icons.attach_file)),
          Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 5, decoration: const InputDecoration(hintText: 'Message'))),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              widget.onSend(text);
              controller.clear();
            },
          ),
        ]),
      ]),
    );
  }
}
