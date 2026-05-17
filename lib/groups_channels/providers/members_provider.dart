import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_enums.dart';
import '../models/member.dart';
import '../services/chat_repository.dart';

class MembersProvider extends ChangeNotifier {
  MembersProvider(this._repo);
  final ChatRepository _repo;

  List<ConversationMember> members = [];
  bool loading = false;
  Object? error;
  StreamSubscription? _sub;

  void watch(ChatScope scope, String conversationId) {
    loading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _repo.watchMembers(scope, conversationId).listen((v) {
      members = v;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      error = e;
      loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
