import 'package:flutter/material.dart';

class SmartChatInput extends StatefulWidget {
  const SmartChatInput({
    super.key,
    required this.onSend,
    this.replyPreview,
    this.onCancelReply,
  });

  final Function(String) onSend;
  final String? replyPreview;
  final VoidCallback? onCancelReply;

  @override
  State<SmartChatInput> createState() => _SmartChatInputState();
}

class _SmartChatInputState extends State<SmartChatInput> {
  final controller = TextEditingController();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (widget.replyPreview != null)
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(child: Text('Replying: ${widget.replyPreview}', maxLines: 1)),
              IconButton(onPressed: widget.onCancelReply, icon: const Icon(Icons.close, size: 16))
            ]),
          ),
        Row(children: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Message...'))),
          GestureDetector(
            onLongPressStart: (_) => setState(() => isRecording = true),
            onLongPressEnd: (_) => setState(() => isRecording = false),
            child: IconButton(
              icon: Icon(controller.text.isNotEmpty ? Icons.send : (isRecording ? Icons.mic_off : Icons.mic)),
              onPressed: controller.text.isNotEmpty ? () {
                widget.onSend(controller.text.trim());
                controller.clear();
              } : null,
            ),
          )
        ]),
      ]),
    );
  }
}
