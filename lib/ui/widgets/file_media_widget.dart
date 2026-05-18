import 'package:flutter/material.dart';

/// Renders a non-image file attachment (PDF, docx, zip, etc.)
/// Shows file icon, name, and human-readable size.
class FileMediaWidget extends StatelessWidget {
  final String fileName;
  final int? fileSizeBytes;
  final bool isOutgoing;

  const FileMediaWidget({
    super.key,
    required this.fileName,
    this.fileSizeBytes,
    this.isOutgoing = false,
  });

  @override
  Widget build(BuildContext context) {
    final ext = fileName.split('.').last.toUpperCase();
    final color = isOutgoing ? Colors.white.withOpacity(0.15) : Theme.of(context).colorScheme.primary.withOpacity(0.08);
    final textColor = isOutgoing ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final subColor = isOutgoing ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon badge
          Container(
            width: 40,
            height: 48,
            decoration: BoxDecoration(
              color: isOutgoing ? Colors.white24 : Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                ext.length > 4 ? ext.substring(0, 4) : ext,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isOutgoing ? Colors.white : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name + size
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
                ),
                if (fileSizeBytes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatSize(fileSizeBytes!),
                    style: TextStyle(fontSize: 11, color: subColor),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.download_rounded, size: 18, color: isOutgoing ? Colors.white70 : Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
