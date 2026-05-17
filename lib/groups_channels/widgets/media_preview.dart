import 'package:flutter/material.dart';
import '../models/media_attachment.dart';

class MediaPreview extends StatelessWidget {
  const MediaPreview({super.key, required this.attachments});
  final List<MediaAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: attachments.map((a) {
        if (a.mimeType.startsWith('image/')) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(a.url, width: 180, height: 180, fit: BoxFit.cover),
          );
        }
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.attach_file),
            const SizedBox(width: 8),
            Flexible(child: Text(a.fileName, overflow: TextOverflow.ellipsis)),
          ]),
        );
      }).toList(),
    );
  }
}
