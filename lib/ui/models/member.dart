import 'chat_enums.dart';

class ConversationMember {
  final String userId;
  final MemberRole role;
  final DateTime? joinedAt;
  final bool muted;

  const ConversationMember({
    required this.userId,
    required this.role,
    this.joinedAt,
    this.muted = false,
  });

  factory ConversationMember.fromMap(String userId, Map<String, dynamic> data) {
    return ConversationMember(
      userId: userId,
      role: enumFromString(MemberRole.values, data['role']?.toString(), MemberRole.member),
      joinedAt: data['joinedAt']?.toDate(),
      muted: data['muted'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'role': enumName(role),
        'muted': muted,
        'joinedAt': joinedAt,
      };
}
