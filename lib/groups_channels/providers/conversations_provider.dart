import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/conversation.dart';
import '../services/chat_repository.dart';

class ConversationsProvider extends ChangeNotifier {
  ConversationsProvider(this._repo);
  final ChatRepository _repo;

  List<ChatConversation> groups = [];
  List<ChatConversation> channels = [];
  bool loading = false;
  Object? error;
  StreamSubscription? _groupsSub;
  StreamSubscription? _channelsSub;

  void watch(String userId) {
    loading = true;
    notifyListeners();
    _groupsSub?.cancel();
    _channelsSub?.cancel();
    _groupsSub = _repo.watchGroups(userId).listen((v) {
      groups = v;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      groups = [];
      error = e;
      loading = false;
      notifyListeners();
    });
    _channelsSub = _repo.watchChannels(userId).listen((v) {
      channels = v;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      channels = [];
      error = e;
      loading = false;
      notifyListeners();
    });
  }

  Future<String> createGroup({
    required String ownerId,
    required String name,
    String? description,
    required List<String> memberIds,
  }) {
    return _repo.createGroup(ownerId: ownerId, name: name, description: description, memberIds: memberIds);
  }

  Future<String> createChannel({
    required String ownerId,
    required String name,
    String? description,
    ChannelPostingPolicy postingPolicy = ChannelPostingPolicy.adminsOnly,
  }) {
    return _repo.createChannel(ownerId: ownerId, name: name, description: description, postingPolicy: postingPolicy);
  }

  Future<void> delete(ChatScope scope, String id) => _repo.softDeleteConversation(scope, id);

  @override
  void dispose() {
    _groupsSub?.cancel();
    _channelsSub?.cancel();
    super.dispose();
  }
}
