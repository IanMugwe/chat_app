import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_enums.dart';

class ChatConversation {
  final String id;
  final ConversationType type;
  final String? name;
  final String? description;
  final String? imageUrl;
  final String ownerId;
  final List<String> adminIds;
  final List<String> participantIds;
  final ChannelPostingPolicy postingPolicy;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts;
  final int count;
  final bool isPublic;
  final bool deleted;

  const ChatConversation({
    required this.id,
    required this.type,
    this.name,
    this.description,
    this.imageUrl,
    required this.ownerId,
    this.adminIds = const [],
    this.participantIds = const [],
    this.postingPolicy = ChannelPostingPolicy.adminsOnly,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCounts = const {},
    this.count = 0,
    this.isPublic = false,
    this.deleted = false,
  });

  factory ChatConversation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatConversation(
      id: doc.id,
      type: enumFromString(ConversationType.values, data['type']?.toString(), ConversationType.group),
      name: data['name']?.toString() ?? data['title']?.toString(),
      description: data['description']?.toString(),
      imageUrl: data['imageUrl']?.toString(),
      ownerId: data['ownerId']?.toString() ?? '',
      adminIds: ((data['adminIds'] as List?) ?? const []).map((e) => e.toString()).toList(),
      participantIds: ((data['memberIds'] as List?) ?? (data['subscriberIds'] as List?) ?? (data['participantIds'] as List?) ?? const []).map((e) => e.toString()).toList(),
      postingPolicy: enumFromString(ChannelPostingPolicy.values, data['postingPolicy']?.toString(), ChannelPostingPolicy.adminsOnly),
      lastMessage: data['lastMessage']?.toString(),
      lastMessageAt: data['lastMessageAt']?.toDate(),
      unreadCounts: Map<String, int>.from((data['unreadCounts'] ?? {}).map((k, v) => MapEntry(k.toString(), (v as num).toInt()))),
      count: ((data['memberCount'] ?? data['subscriberCount'] ?? 0) as num).toInt(),
      isPublic: data['isPublic'] == true,
      deleted: data['deletedAt'] != null,
    );
  }

  bool canPost(String userId) {
    if (type != ConversationType.channel) return participantIds.contains(userId);
    if (postingPolicy == ChannelPostingPolicy.subscribers) return participantIds.contains(userId);
    return ownerId == userId || adminIds.contains(userId);
  }

  int unreadFor(String userId) => unreadCounts[userId] ?? 0;
}
