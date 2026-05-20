import 'package:chat_app/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:ychat_auth/ychat_auth.dart';

class UserProvider extends ChangeNotifier {
  final YUserProvider _yUserProvider;

  UserProvider(this._yUserProvider) {
    _yUserProvider.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  UserModel? _currentUser;

  UserModel? get user => _currentUser;

  void _onAuthChanged() {
    final profile = _yUserProvider.profile;
    if (profile != null) {
      _currentUser = UserModel(
        uid: profile.uid,
        name: profile.name,
        email: profile.email,
        imageUrl: profile.profilePic,
      );
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  void clearUser() {
    _yUserProvider.logout();
  }

  Future<void> loadUser(String uid) async {
    // Legacy support: the profile is now loaded reactively by YUserProvider.
    // This method is a no-op to maintain compilation compatibility with legacy screens.
  }

  @override
  void dispose() {
    _yUserProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}
