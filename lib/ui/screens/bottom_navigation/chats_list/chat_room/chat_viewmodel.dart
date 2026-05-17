import 'dart:async';
import 'package:chat_app/core/models/message_model.dart';
import 'package:chat_app/core/models/user_model.dart';
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
  final _messageController = TextEditingController();

  List<ChatMessage> get messages => _messages;
  TextEditingController get controller => _messageController;

  getChatRoom() {
    if (_currentUser.uid!.hashCode > _receiver.uid!.hashCode) {
      chatRoomId = "${_currentUser.uid}_${_receiver.uid}";
    } else {
      chatRoomId = "${_receiver.uid}_${_currentUser.uid}";
    }
  }

  Future<void> sendTextMessage(String text, {String? replyTo, String? replyPreview}) async {
    try {
      await _chatService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: _currentUser.uid!,
        senderName: _currentUser.name!,
        text: text,
        replyToMessageId: replyTo,
        replyPreview: replyPreview,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editMessage(String messageId, String text) async =>
      await _chatService.editMessage(chatRoomId, messageId, text);

  Future<void> deleteMessage(String messageId) async =>
      await _chatService.deleteMessage(chatRoomId, messageId);

  @override
  void dispose() {
    _subscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }
}
