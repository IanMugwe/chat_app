import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/conversation.dart';
import 'package:chat_app/core/models/member.dart';
import 'package:chat_app/core/models/chat_message.dart';
import 'package:chat_app/core/models/media_attachment.dart';
import 'chat_paths.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(ChatScope scope) =>
      _db.collection(ChatPaths.collectionFor(scope));

  DocumentReference<Map<String, dynamic>> _doc(ChatScope scope, String id) => _col(scope).doc(id);

  CollectionReference<Map<String, dynamic>> _messages(ChatScope scope, String id) =>
      _doc(scope, id).collection('messages');

  Stream<List<ChatConversation>> watchGroups(String userId) {
    return _db.collection('groups')
        .where('memberIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map(ChatConversation.fromDoc)
            .where((c) => !c.deleted)
            .toList());
  }

  Stream<List<ChatConversation>> watchChannels(String userId) {
    return _db.collection('channels')
        .where('subscriberIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map(ChatConversation.fromDoc)
            .where((c) => !c.deleted)
            .toList());
  }

  Future<String> createGroup({
    required String ownerId,
    required String name,
    String? description,
    String? imageUrl,
    required List<String> memberIds,
    bool isPublic = false,
  }) async {
    final now = FieldValue.serverTimestamp();
    final ids = {...memberIds, ownerId}.toList();
    final ref = _db.collection('groups').doc();
    final batch = _db.batch();
    batch.set(ref, {
      'type': enumName(ConversationType.group),
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'adminIds': [ownerId],
      'memberIds': ids,
      'memberCount': ids.length,
      'isPublic': isPublic,
      'unreadCounts': {for (final id in ids) id: 0},
      'createdAt': now,
      'updatedAt': now,
      'lastMessageAt': now,
    });
    for (final id in ids) {
      batch.set(ref.collection('members').doc(id), {
        'role': id == ownerId ? enumName(MemberRole.owner) : enumName(MemberRole.member),
        'muted': false,
        'joinedAt': now,
      });
    }
    await batch.commit();
    return ref.id;
  }

  Future<String> createChannel({
    required String ownerId,
    required String name,
    String? description,
    String? imageUrl,
    ChannelPostingPolicy postingPolicy = ChannelPostingPolicy.adminsOnly,
    bool isPublic = true,
  }) async {
    final now = FieldValue.serverTimestamp();
    final ref = _db.collection('channels').doc();
    await ref.set({
      'type': enumName(ConversationType.channel),
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'adminIds': [ownerId],
      'subscriberIds': [ownerId],
      'subscriberCount': 1,
      'postingPolicy': enumName(postingPolicy),
      'isPublic': isPublic,
      'unreadCounts': {ownerId: 0},
      'createdAt': now,
      'updatedAt': now,
      'lastMessageAt': now,
    });
    await ref.collection('subscribers').doc(ownerId).set({
      'role': enumName(MemberRole.owner),
      'muted': false,
      'joinedAt': now,
    });
    return ref.id;
  }

  Future<void> updateConversation({
    required ChatScope scope,
    required String id,
    String? name,
    String? description,
    String? imageUrl,
    ChannelPostingPolicy? postingPolicy,
  }) async {
    await _doc(scope, id).update({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (postingPolicy != null) 'postingPolicy': enumName(postingPolicy),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDeleteConversation(ChatScope scope, String id) async {
    await _doc(scope, id).update({'deletedAt': FieldValue.serverTimestamp()});
  }

  Future<void> joinGroup(String groupId, String userId) async {
    final ref = _db.collection('groups').doc(groupId);
    await _db.runTransaction((tx) async {
      tx.update(ref, {
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
        'unreadCounts.$userId': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(ref.collection('members').doc(userId), {
        'role': enumName(MemberRole.member),
        'muted': false,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    final ref = _db.collection('groups').doc(groupId);
    await _db.runTransaction((tx) async {
      tx.update(ref, {
        'memberIds': FieldValue.arrayRemove([userId]),
        'memberCount': FieldValue.increment(-1),
        'unreadCounts.$userId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.delete(ref.collection('members').doc(userId));
    });
  }

  Future<void> subscribeChannel(String channelId, String userId) async {
    final ref = _db.collection('channels').doc(channelId);
    await _db.runTransaction((tx) async {
      tx.update(ref, {
        'subscriberIds': FieldValue.arrayUnion([userId]),
        'subscriberCount': FieldValue.increment(1),
        'unreadCounts.$userId': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(ref.collection('subscribers').doc(userId), {
        'role': enumName(MemberRole.subscriber),
        'muted': false,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> unsubscribeChannel(String channelId, String userId) async {
    final ref = _db.collection('channels').doc(channelId);
    await _db.runTransaction((tx) async {
      tx.update(ref, {
        'subscriberIds': FieldValue.arrayRemove([userId]),
        'subscriberCount': FieldValue.increment(-1),
        'unreadCounts.$userId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.delete(ref.collection('subscribers').doc(userId));
    });
  }

  Stream<List<ConversationMember>> watchMembers(ChatScope scope, String conversationId) {
    final sub = ChatPaths.membershipSubcollection(scope);
    return _doc(scope, conversationId).collection(sub).snapshots().map(
          (s) => s.docs.map((d) => ConversationMember.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<ChatMessage>> watchLatestMessages({
    required ChatScope scope,
    required String conversationId,
    int limit = 30,
  }) {
    return _messages(scope, conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromDoc(d, scope, conversationId)).toList());
  }

  Future<List<ChatMessage>> fetchOlderMessages({
    required ChatScope scope,
    required String conversationId,
    required DocumentSnapshot lastDoc,
    int limit = 30,
  }) async {
    final snap = await _messages(scope, conversationId)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();
    return snap.docs.map((d) => ChatMessage.fromDoc(d, scope, conversationId)).toList();
  }

  Future<void> sendMessage({
    required ChatScope scope,
    required String conversationId,
    required String senderId,
    required String senderName,
    String? text,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? replyPreview,
    List<MediaAttachment> attachments = const [],
    List<String> mentions = const [],
  }) async {
    final parent = _doc(scope, conversationId);
    final msgRef = parent.collection('messages').doc();
    final parentSnap = await parent.get();
    final parentData = parentSnap.data() ?? {};
    final ids = _participantIds(scope, parentData);
    final unread = <String, Object>{};
    for (final id in ids) {
      if (id != senderId) unread['unreadCounts.$id'] = FieldValue.increment(1);
    }
    final batch = _db.batch();
    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'type': enumName(type),
      'status': enumName(MessageStatus.sent),
      if (text != null) 'text': text,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      if (replyPreview != null) 'replyPreview': replyPreview,
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'mentions': mentions,
      'reactions': {},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(parent, {
      'lastMessage': _lastMessageText(type, text),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      ...unread,
    });
    await batch.commit();
  }

  Future<void> editMessage({
    required ChatScope scope,
    required String conversationId,
    required String messageId,
    required String text,
  }) async {
    await _messages(scope, conversationId).doc(messageId).update({
      'text': text,
      'status': enumName(MessageStatus.edited),
      'editedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMessage({
    required ChatScope scope,
    required String conversationId,
    required String messageId,
  }) async {
    await _messages(scope, conversationId).doc(messageId).update({
      'text': null,
      'attachments': [],
      'status': enumName(MessageStatus.deleted),
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> react({
    required ChatScope scope,
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
    required bool add,
  }) async {
    await _messages(scope, conversationId).doc(messageId).update({
      'reactions.$emoji': add ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> starMessage({
    required ChatScope scope,
    required String conversationId,
    required String messageId,
    required bool isStarred,
  }) async {
    await _messages(scope, conversationId).doc(messageId).update({
      'isStarred': isStarred,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> pinMessage({
    required ChatScope scope,
    required String conversationId,
    required String messageId,
    required bool isPinned,
  }) async {
    await _messages(scope, conversationId).doc(messageId).update({
      'isPinned': isPinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markRead({
    required ChatScope scope,
    required String conversationId,
    required String userId,
  }) async {
    final parent = _doc(scope, conversationId);
    await _db.runTransaction((tx) async {
      tx.update(parent, {'unreadCounts.$userId': 0});
      tx.set(parent.collection('reads').doc(userId), {
        'readAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> lastMessageDoc(ChatScope scope, String conversationId) async {
    final s = await _messages(scope, conversationId).orderBy('createdAt', descending: true).limit(1).get();
    return s.docs.isEmpty ? null : s.docs.first;
  }

  List<String> _participantIds(ChatScope scope, Map<String, dynamic> data) {
    final key = scope == ChatScope.channel ? 'subscriberIds' : scope == ChatScope.group ? 'memberIds' : 'participantIds';
    return ((data[key] as List?) ?? const []).map((e) => e.toString()).toList();
  }

  String _lastMessageText(MessageType type, String? text) {
    if (type == MessageType.text) return text ?? '';
    if (type == MessageType.image) return '📷 Photo';
    if (type == MessageType.video) return '🎥 Video';
    if (type == MessageType.audio) return '🎧 Audio';
    return '📎 File';
  }
}
