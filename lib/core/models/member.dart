import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_enums.dart';

class ConversationMember {
  final String userId;
  final MemberRole role;
  final bool muted;
  final DateTime joinedAt;

  const ConversationMember({
    required this.userId,
    required this.role,
    required this.muted,
    required this.joinedAt,
  });

  factory ConversationMember.fromMap(String userId, Map<String, dynamic> data) {
    return ConversationMember(
      userId: userId,
      role: enumFromString(MemberRole.values, data['role']?.toString(), MemberRole.member),
      muted: data['muted'] == true,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'role': enumName(role),
        'muted': muted,
        'joinedAt': joinedAt,
      };
}
