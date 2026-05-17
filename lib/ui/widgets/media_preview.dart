import 'package:flutter/material.dart';
import 'package:chat_app/ui/models/chat_message.dart';

class MediaPreview extends StatelessWidget {
  const MediaPreview({super.key, required this.attachments});
  final List<dynamic> attachments; // Using dynamic for simplicity until fully migrated

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: attachments.map((a) {
        // Simple preview logic
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.attach_file), SizedBox(width: 4), Text('File')]),
        );
      }).toList(),
    );
  }
}
