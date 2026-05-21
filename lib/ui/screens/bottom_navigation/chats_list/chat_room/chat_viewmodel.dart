import 'dart:async';
import 'package:chat_app/core/models/chat_message.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/models/media_attachment.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatViewmodel extends BaseViewmodel {
  final ChatService _chatService;
  final UserModel _currentUser;
  final UserModel _receiver;

  StreamSubscription? _subscription;

  ChatViewmodel(this._chatService, this._currentUser, this._receiver) {
    getChatRoom();
    _subscription = _chatService.getMessages(chatRoomId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  String chatRoomId = "";
  List<ChatMessage> _messages = [];
  final List<ChatMessage> _pendingMessages = [];
  final _messageController = TextEditingController();

  List<ChatMessage> get messages => [..._pendingMessages, ..._messages];
  TextEditingController get controller => _messageController;

  getChatRoom() {
    if (_currentUser.uid!.hashCode > _receiver.uid!.hashCode) {
      chatRoomId = "${_currentUser.uid}_${_receiver.uid}";
    } else {
      chatRoomId = "${_receiver.uid}_${_currentUser.uid}";
    }
  }

  void addPendingMessage(ChatMessage message) {
    _pendingMessages.insert(0, message);
    notifyListeners();
  }

  void removePendingMessage(String id) {
    _pendingMessages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> sendTextMessage(String text, {MessageType type = MessageType.text, String? replyTo, String? replyPreview, List<MediaAttachment> attachments = const []}) async {
    try {
      await _chatService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: _currentUser.uid!,
        senderName: _currentUser.name!,
        text: text,
        type: type,
        replyToMessageId: replyTo,
        replyPreview: replyPreview,
        attachments: attachments,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editMessage(String messageId, String text) async =>
      await _chatService.editMessage(chatRoomId, messageId, text);

  Future<void> deleteMessage(String messageId) async =>
      await _chatService.deleteMessage(chatRoomId, messageId);

  Future<void> starMessage(String messageId, bool isStarred) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final oldMessage = _messages[index];
      _messages[index] = ChatMessage(
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
        await _chatService.starMessage(chatRoomId, messageId, isStarred);
      } catch (e) {
        _messages[index] = oldMessage;
        notifyListeners();
      }
    }
  }

  Future<void> pinMessage(String messageId, bool isPinned) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final oldMessage = _messages[index];
      _messages[index] = ChatMessage(
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
        await _chatService.pinMessage(chatRoomId, messageId, isPinned);
      } catch (e) {
        _messages[index] = oldMessage;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }
}
