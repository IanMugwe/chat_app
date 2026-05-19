import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/chat_message.dart';
import 'package:chat_app/core/models/media_attachment.dart';
import '../services/chat_repository.dart';

class ChatRoomProvider extends ChangeNotifier {
  ChatRoomProvider(this._repo);
  final ChatRepository _repo;

  List<ChatMessage> messages = [];
  bool loading = false;
  bool loadingOlder = false;
  Object? error;
  StreamSubscription? _sub;

  void watch({required ChatScope scope, required String conversationId}) {
    loading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _repo.watchLatestMessages(scope: scope, conversationId: conversationId).listen((v) {
      messages = v;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      error = e;
      loading = false;
      notifyListeners();
    });
  }

  Future<void> sendText({
    required ChatScope scope,
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    String? replyToMessageId,
    String? replyPreview,
    List<String> mentions = const [],
  }) async {
    await _repo.sendMessage(
      scope: scope,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      replyToMessageId: replyToMessageId,
      replyPreview: replyPreview,
      mentions: mentions,
    );
  }

  Future<void> sendMedia({
    required ChatScope scope,
    required String conversationId,
    required String senderId,
    required String senderName,
    required MessageType type,
    String? caption,
    required List<MediaAttachment> attachments,
  }) {
    return _repo.sendMessage(
      scope: scope,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      type: type,
      text: caption,
      attachments: attachments,
    );
  }

  Future<void> edit(ChatScope scope, String conversationId, String messageId, String text) =>
      _repo.editMessage(scope: scope, conversationId: conversationId, messageId: messageId, text: text);

  Future<void> delete(ChatScope scope, String conversationId, String messageId) =>
      _repo.deleteMessage(scope: scope, conversationId: conversationId, messageId: messageId);

  Future<void> react(ChatScope scope, String conversationId, String messageId, String emoji, String userId, bool add) =>
      _repo.react(scope: scope, conversationId: conversationId, messageId: messageId, emoji: emoji, userId: userId, add: add);

  Future<void> starMessage(ChatScope scope, String conversationId, String messageId, bool isStarred) async {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final oldMessage = messages[index];
      messages[index] = ChatMessage(
        id: oldMessage.id,
        conversationId: oldMessage.conversationId,
        scope: oldMessage.scope,
        senderId: oldMessage.senderId,
        senderName: oldMessage.senderName,
        type: oldMessage.type,
        status: oldMessage.status,
        text: oldMessage.text,
        replyToMessageId: oldMessage.replyToMessageId,
        replyPreview: oldMessage.replyPreview,
        attachments: oldMessage.attachments,
        mentions: oldMessage.mentions,
        reactions: oldMessage.reactions,
        createdAt: oldMessage.createdAt,
        updatedAt: oldMessage.updatedAt,
        deletedAt: oldMessage.deletedAt,
        isPinned: oldMessage.isPinned,
        isStarred: isStarred,
      );
      notifyListeners();

      try {
        await _repo.starMessage(scope: scope, conversationId: conversationId, messageId: messageId, isStarred: isStarred);
      } catch (e) {
        messages[index] = oldMessage;
        notifyListeners();
      }
    }
  }

  Future<void> pinMessage(ChatScope scope, String conversationId, String messageId, bool isPinned) async {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final oldMessage = messages[index];
      messages[index] = ChatMessage(
        id: oldMessage.id,
        conversationId: oldMessage.conversationId,
        scope: oldMessage.scope,
        senderId: oldMessage.senderId,
        senderName: oldMessage.senderName,
        type: oldMessage.type,
        status: oldMessage.status,
        text: oldMessage.text,
        replyToMessageId: oldMessage.replyToMessageId,
        replyPreview: oldMessage.replyPreview,
        attachments: oldMessage.attachments,
        mentions: oldMessage.mentions,
        reactions: oldMessage.reactions,
        createdAt: oldMessage.createdAt,
        updatedAt: oldMessage.updatedAt,
        deletedAt: oldMessage.deletedAt,
        isPinned: isPinned,
        isStarred: oldMessage.isStarred,
      );
      notifyListeners();

      try {
        await _repo.pinMessage(scope: scope, conversationId: conversationId, messageId: messageId, isPinned: isPinned);
      } catch (e) {
        messages[index] = oldMessage;
        notifyListeners();
      }
    }
  }

  Future<void> markRead(ChatScope scope, String conversationId, String userId) =>
      _repo.markRead(scope: scope, conversationId: conversationId, userId: userId);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
