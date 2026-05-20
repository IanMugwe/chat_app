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
    final msgRef = _fire.collection("ychatRooms").doc(chatRoomId).collection("messages").doc();
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
    
    // Extract participants from chatRoomId (assuming format is uid1_uid2)
    List<String> participants = chatRoomId.split('_');
    if (participants.length != 2) participants = [senderId]; // fallback

    // Update last message in parent room, create if not exists
    await _fire.collection("ychatRooms").doc(chatRoomId).set({
      "lastMessage": text ?? "📎 Attachment",
      "lastMessageAt": FieldValue.serverTimestamp(),
      "participants": participants,
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserChats(String userId) {
    return _fire
        .collection("ychatRooms")
        .where("participants", arrayContains: userId)
        .orderBy("lastMessageAt", descending: true)
        .snapshots();
  }

  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _fire
        .collection("ychatRooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromDoc(d, ChatScope.direct, chatRoomId)).toList());
  }

  Future<void> editMessage(String chatRoomId, String messageId, String text) async {
    await _fire.collection("ychatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({
      'text': text,
      'status': enumName(MessageStatus.edited),
    });
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    await _fire.collection("ychatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({
      'status': enumName(MessageStatus.deleted),
      'text': null,
      'attachments': [],
    });
  }

  Future<void> starMessage(String chatRoomId, String messageId, bool isStarred) async {
    await _fire.collection("ychatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({
      'isStarred': isStarred,
    });
  }

  Future<void> pinMessage(String chatRoomId, String messageId, bool isPinned) async {
    await _fire.collection("ychatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({
      'isPinned': isPinned,
    });
  }
}
