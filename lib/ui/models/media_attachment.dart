class MediaAttachment {
  final String id;
  final String url;
  final String storagePath;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? thumbnailUrl;

  const MediaAttachment({
    required this.id,
    required this.url,
    required this.storagePath,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.thumbnailUrl,
  });

  factory MediaAttachment.fromMap(Map<String, dynamic> data) {
    return MediaAttachment(
      id: data['id']?.toString() ?? '',
      url: data['url']?.toString() ?? '',
      storagePath: data['storagePath']?.toString() ?? '',
      fileName: data['fileName']?.toString() ?? '',
      mimeType: data['mimeType']?.toString() ?? 'application/octet-stream',
      sizeBytes: (data['sizeBytes'] as num?)?.toInt() ?? 0,
      thumbnailUrl: data['thumbnailUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'url': url,
        'storagePath': storagePath,
        'fileName': fileName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      };
}
