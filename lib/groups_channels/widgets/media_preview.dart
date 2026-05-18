import 'package:flutter/material.dart';
import '../models/media_attachment.dart';
import '../../ui/widgets/image_media_widget.dart';
import '../../ui/widgets/file_media_widget.dart';
import '../../ui/widgets/voice_media_widget.dart';

class MediaPreview extends StatelessWidget {
  const MediaPreview({super.key, required this.attachments, this.isOutgoing = false});
  final List<MediaAttachment> attachments;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: attachments.map((a) {
          final mime = a.mimeType.toLowerCase();
          
          if (mime.startsWith('image/')) {
            return ImageMediaWidget(
              url: a.url,
            );
          } else if (mime.startsWith('audio/')) {
            return VoiceMediaWidget(
              isOutgoing: isOutgoing,
            );
          } else {
            return FileMediaWidget(
              fileName: a.fileName,
              fileSizeBytes: a.sizeBytes,
              isOutgoing: isOutgoing,
            );
          }
        }).toList(),
      ),
    );
  }
}
