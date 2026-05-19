import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_enums.dart';
import '../models/chat_message.dart';
import '../models/media_attachment.dart';

class ChatService {
  final _fire = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    String? text,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? replyPreview,
    List<MediaAttachment> attachments = const [],
  }) async {
    final msgRef = _fire.collection("chatRooms").doc(chatRoomId).collection("messages").doc();
    final message = ChatMessage(
      id: msgRef.id,
      conversationId: chatRoomId,
      scope: ChatScope.direct,
      senderId: senderId,
      senderName: senderName,
      type: type,
      status: MessageStatus.sent,
      text: text,
      replyToMessageId: replyToMessageId,
      replyPreview: replyPreview,
      attachments: attachments,
      createdAt: DateTime.now(),
    );

    await msgRef.set(message.toCreateMap());
    
    // Update last message in parent room
    await _fire.collection("chatRooms").doc(chatRoomId).update({
      "lastMessage": text ?? "📎 Attachment",
      "lastMessageAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _fire
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromDoc(d, ChatScope.direct, chatRoomId)).toList());
  }

  Future<void> editMessage(String chatRoomId, String messageId, String text) async {
    await _fire.collection("chatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({
      'text': text,
      'status': enumName(MessageStatus.edited),
    });
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    await _fire.collection("chatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({
      'status': enumName(MessageStatus.deleted),
      'text': null,
      'attachments': [],
    });
  }

  Future<void> starMessage(String chatRoomId, String messageId, bool isStarred) async {
    await _fire.collection("chatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({
      'isStarred': isStarred,
    });
  }

  Future<void> pinMessage(String chatRoomId, String messageId, bool isPinned) async {
    await _fire.collection("chatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({
      'isPinned': isPinned,
    });
  }
}
