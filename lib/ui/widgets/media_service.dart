import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class MediaService {
  static final MediaService instance = MediaService._internal();
  MediaService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickFile() async {
    final FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<String?> uploadMedia(File file, String folder) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final Reference ref = _storage.ref().child(folder).child(fileName);
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading media: $e');
      return null;
    }
  }
}
