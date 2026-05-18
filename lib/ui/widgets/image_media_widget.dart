import 'dart:io';
import 'package:flutter/material.dart';

/// Renders an image from a URL or local path with loading skeleton & error fallback.
class ImageMediaWidget extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;

  const ImageMediaWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
  });

  /// Returns true for local file paths (file://, /storage/, content://, etc.)
  bool get _isLocal =>
      url.startsWith('/') ||
      url.startsWith('file://') ||
      url.startsWith('content://');

  /// Returns true only for valid remote URLs
  bool get _isRemote =>
      url.startsWith('http://') || url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final double defaultHeight = height ?? 200;
    final double defaultWidth = width ?? double.infinity;
    final Color placeholderColor = Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF22181B) 
        : const Color(0xFFF1EEF0);

    // Guard: empty or blank URL — show error placeholder immediately
    if (url.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildError(context, defaultWidth, defaultHeight, placeholderColor),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _isLocal
          ? Image.file(
              File(url.replaceFirst('file://', '')),
              width: defaultWidth,
              height: defaultHeight,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildError(context, defaultWidth, defaultHeight, placeholderColor),
            )
          : _isRemote
              ? Image.network(
                  url,
                  width: defaultWidth,
                  height: defaultHeight,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: defaultWidth,
                      height: defaultHeight,
                      color: placeholderColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => _buildError(context, defaultWidth, defaultHeight, placeholderColor),
                )
              // Fallback: unrecognised scheme — treat as local file
              : Image.file(
                  File(url),
                  width: defaultWidth,
                  height: defaultHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildError(context, defaultWidth, defaultHeight, placeholderColor),
                ),
    );
  }

  Widget _buildError(BuildContext context, double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 6),
          Text('Failed to load image', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }
}
