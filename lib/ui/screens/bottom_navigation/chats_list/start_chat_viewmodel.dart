import 'dart:developer';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/services/database_service.dart';

class StartChatViewmodel extends BaseViewmodel {
  final DatabaseService _db;
  final UserModel _currentUser;

  StartChatViewmodel(this._db, this._currentUser) {
    fetchUsers();
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

  fetchUsers() async {
    try {
      setViewState(ViewState.loading);
      
      _db.fetchUserStream(_currentUser.uid!).listen((data) {
        _users = data.docs.map((e) => UserModel.fromMap(e.data())).toList();
        _filteredUsers = users;
        setViewState(ViewState.idle);
        notifyListeners();
      });

    } catch (e) {
      setViewState(ViewState.idle);
      log("Error Fetching Users: $e");
    }
  }
}
