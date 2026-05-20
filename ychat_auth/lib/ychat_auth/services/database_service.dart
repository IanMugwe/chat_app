import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/y_user_profile.dart';

class DatabaseService {
  DatabaseService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static final Map<String, YUserProfile> _memoryProfileCache = {};
  static final Map<String, Future<YUserProfile?>> _inFlightReads = {};

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('yusers');

  Future<void> createUserProfileIfNeeded({
    required User user,
    String? fallbackName,
  }) async {
    final ref = _users.doc(user.uid);

    try {
      final snapshot = await ref.get().timeout(const Duration(seconds: 4));
      
      final Map<String, dynamic> data = {
        'uid': user.uid,
        'email': user.email ?? '',
        'name': _safeName(user.displayName, fallbackName, user.email),
        if (user.photoURL != null) 'profilePic': user.photoURL,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!snapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await ref.set(data, SetOptions(merge: true));
    } catch (_) {
      // Offline-first resilient fallback write
      await ref.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': _safeName(user.displayName, fallbackName, user.email),
        if (user.photoURL != null) 'profilePic': user.photoURL,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await getCurrentUserProfile(forceRefresh: true);
  }

  Future<YUserProfile?> getCurrentUserProfile({
    bool forceRefresh = false,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    if (!forceRefresh && _memoryProfileCache.containsKey(user.uid)) {
      return _memoryProfileCache[user.uid];
    }

    final inFlightKey = '${user.uid}:$forceRefresh';
    if (!forceRefresh && _inFlightReads.containsKey(inFlightKey)) {
      return _inFlightReads[inFlightKey]!;
    }

    final future = _readProfile(user.uid).timeout(
      timeout,
      onTimeout: () => _memoryProfileCache[user.uid],
    );

    _inFlightReads[inFlightKey] = future;
    try {
      return await future;
    } finally {
      _inFlightReads.remove(inFlightKey);
    }
  }

  Future<YUserProfile?> _readProfile(String uid) async {
    final doc = await _users.doc(uid).get(const GetOptions(source: Source.serverAndCache));
    if (!doc.exists) return null;

    final profile = YUserProfile.fromFirestore(doc);
    _memoryProfileCache[uid] = profile;
    return profile;
  }

  Stream<YUserProfile?> currentUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _users.doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final profile = YUserProfile.fromFirestore(doc);
      _memoryProfileCache[user.uid] = profile;
      return profile;
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? profilePic,
    String? status,
  }) async {
    await _users.doc(uid).set({
      if (name != null) 'name': name,
      if (profilePic != null) 'profilePic': profilePic,
      if (status != null) 'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await getCurrentUserProfile(forceRefresh: true);
  }

  Future<void> clearCachedUser([String? uid]) async {
    if (uid == null) {
      _memoryProfileCache.clear();
    } else {
      _memoryProfileCache.remove(uid);
    }
    _inFlightReads.clear();
  }

  String _safeName(String? displayName, String? fallbackName, String? email) {
    final raw = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : fallbackName?.trim().isNotEmpty == true
            ? fallbackName!.trim()
            : email?.split('@').first.trim();

    return raw?.isNotEmpty == true ? raw! : 'yCHAT User';
  }
}
