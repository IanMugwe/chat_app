import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/media_attachment.dart';
import 'chat_paths.dart';

class MediaUploadService {
  MediaUploadService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  Future<MediaAttachment> uploadMessageMedia({
    required ChatScope scope,
    required String conversationId,
    required String messageId,
    required File file,
    required String fileName,
    required String mimeType,
  }) async {
    _validate(mimeType, await file.length());
    final id = _uuid.v4();
    final path = 'chat/${ChatPaths.collectionFor(scope)}/$conversationId/$messageId/${id}_$fileName';
    final ref = _storage.ref(path);
    final task = await ref.putFile(file, SettableMetadata(contentType: mimeType));
    final url = await task.ref.getDownloadURL();
    return MediaAttachment(
      id: id,
      url: url,
      storagePath: path,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: await file.length(),
    );
  }

  void _validate(String mimeType, int sizeBytes) {
    final allowed = <String>{
      'image/jpeg', 'image/png', 'image/webp',
      'video/mp4', 'video/quicktime',
      'audio/mpeg', 'audio/mp4', 'audio/aac', 'audio/wav',
      'application/pdf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    if (!allowed.contains(mimeType)) {
      throw Exception('Unsupported file type: $mimeType');
    }
    final max = mimeType.startsWith('video/') ? 100 * 1024 * 1024 : 25 * 1024 * 1024;
    if (sizeBytes > max) throw Exception('File too large');
  }
}
