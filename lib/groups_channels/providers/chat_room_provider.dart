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

  Future<void> markRead(ChatScope scope, String conversationId, String userId) =>
      _repo.markRead(scope: scope, conversationId: conversationId, userId: userId);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
