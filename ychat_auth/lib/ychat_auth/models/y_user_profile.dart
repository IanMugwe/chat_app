import 'package:cloud_firestore/cloud_firestore.dart';

class YUserProfile { 
  final String uid;
  final String email;
  final String name;
  final String? profilePic;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const YUserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.profilePic,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory YUserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return YUserProfile.fromMap(doc.data() ?? <String, dynamic>{}, fallbackUid: doc.id);
  }

  factory YUserProfile.fromMap(Map<String, dynamic> data, {String? fallbackUid}) {
    return YUserProfile(
      uid: (data['uid'] ?? fallbackUid ?? '') as String,
      email: (data['email'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      profilePic: data['profilePic'] as String?,
      status: (data['status'] ?? 'active') as String,
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePic': profilePic,
      'status': status,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
