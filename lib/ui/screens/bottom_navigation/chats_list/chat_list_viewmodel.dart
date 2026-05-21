import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/chat_service.dart';

class ChatListViewmodel extends BaseViewmodel {
  final DatabaseService _db;
  final UserModel _currentUser;

  ChatListViewmodel(this._db, this._currentUser) {
    fetchChats();
  }

  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];

  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;

  search(String value) {
    _filteredUsers =
        _users.where((e) => e.name!.toLowerCase().contains(value.toLowerCase())).toList();
    notifyListeners();
  }

  fetchChats() {
    try {
      setViewState(ViewState.loading);
      
      ChatService().getUserChats(_currentUser.uid!).listen((data) async {
        if (data.docs.isEmpty) {
          _users = [];
          _filteredUsers = [];
          setViewState(ViewState.idle);
          notifyListeners();
          return;
        }

        final futures = data.docs.map((doc) async {
          final roomData = doc.data();
          final participants = List<String>.from(roomData['participants'] ?? []);
          
          if (participants.isEmpty) return null;
          
          // Find other user id
          final otherUserId = participants.firstWhere((id) => id != _currentUser.uid!, orElse: () => participants[0]);
          
          // Fetch other user's profile
          final otherUserMap = await _db.loadUser(otherUserId);
          if (otherUserMap != null) {
            UserModel user = UserModel.fromMap(otherUserMap);
            
            // Format lastMessage to match UserModel expectations
            final lastMessageText = roomData['lastMessage'];
            final lastMessageAt = roomData['lastMessageAt'];
            
            if (lastMessageText != null) {
              user = UserModel(
                uid: user.uid,
                name: user.name,
                email: user.email,
                imageUrl: user.imageUrl,
                lastMessage: {
                  'content': lastMessageText,
                  'timestamp': lastMessageAt != null ? (lastMessageAt as Timestamp).millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch,
                },
                unreadCounter: roomData['unreadCounts']?[_currentUser.uid!] ?? 0,
              );
            }
            return user;
          }
          return null;
        });
        
        final resolvedUsers = await Future.wait(futures);
        _users = resolvedUsers.whereType<UserModel>().toList();
        _filteredUsers = _users;
        
        setViewState(ViewState.idle);
        notifyListeners();
      });

    } catch (e) {
      setViewState(ViewState.idle);
      log("Error Fetching Chats: $e");
    }
  }
}
