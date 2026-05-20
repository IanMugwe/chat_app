import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static Future<void> initialize({FirebaseOptions? options}) async {
    if (_initialized) return;

    if (options != null) {
      await Firebase.initializeApp(
        options: options,
      );
    } else {
      await Firebase.initializeApp();
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    _initialized = true;
  }
}
