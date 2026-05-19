import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_enums.dart';
import 'media_attachment.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final ChatScope scope;
  final String senderId;
  final String? senderName;
  final MessageType type;
  final MessageStatus status;
  final String? text;
  final String? replyToMessageId;
  final String? replyPreview;
  final List<MediaAttachment> attachments;
  final List<String> mentions;
  final Map<String, List<String>> reactions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool isPinned;
  final bool isStarred;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.scope,
    required this.senderId,
    this.senderName,
    required this.type,
    required this.status,
    this.text,
    this.replyToMessageId,
    this.replyPreview,
    this.attachments = const [],
    this.mentions = const [],
    this.reactions = const {},
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isPinned = false,
    this.isStarred = false,
  });

  bool get isDeleted => status == MessageStatus.deleted || deletedAt != null;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc, ChatScope scope, String conversationId) {
    final data = doc.data() ?? {};
    final rawReactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    return ChatMessage(
      id: doc.id,
      conversationId: conversationId,
      scope: scope,
      senderId: data['senderId']?.toString() ?? '',
      senderName: data['senderName']?.toString(),
      type: enumFromString(MessageType.values, data['type']?.toString(), MessageType.text),
      status: enumFromString(MessageStatus.values, data['status']?.toString(), MessageStatus.sent),
      text: data['text']?.toString(),
      replyToMessageId: data['replyToMessageId']?.toString(),
      replyPreview: data['replyPreview']?.toString(),
      attachments: ((data['attachments'] as List?) ?? const [])
          .map((e) => MediaAttachment.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      mentions: ((data['mentions'] as List?) ?? const []).map((e) => e.toString()).toList(),
      reactions: rawReactions.map((k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList())),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      deletedAt: data['deletedAt']?.toDate(),
      isPinned: data['isPinned'] as bool? ?? false,
      isStarred: data['isStarred'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'senderId': senderId,
        if (senderName != null) 'senderName': senderName,
        'type': enumName(type),
        'status': enumName(status),
        if (text != null) 'text': text,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (replyPreview != null) 'replyPreview': replyPreview,
        'attachments': attachments.map((e) => e.toMap()).toList(),
        'mentions': mentions,
        'reactions': reactions,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPinned': isPinned,
        'isStarred': isStarred,
      };
}
