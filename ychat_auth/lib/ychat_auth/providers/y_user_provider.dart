import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/y_user_profile.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

enum AuthGateState {
  booting, 
  unauthenticated,
  emailNotVerified,
  authenticated,
  error,
}

class YUserProvider extends ChangeNotifier {
  YUserProvider({
    AuthService? authService,
    DatabaseService? databaseService,
  })  : _authService = authService ?? AuthService(),
        _databaseService = databaseService ?? DatabaseService();

  final AuthService _authService;
  final DatabaseService _databaseService;

  StreamSubscription<User?>? _authSub;
  bool _started = false;
  bool _disposed = false;

  AuthGateState _state = AuthGateState.booting;
  YUserProfile? _profile;
  String? _errorMessage;
  bool _busy = false;

  AuthGateState get state => _state;
  YUserProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get busy => _busy;
  User? get firebaseUser => _authService.currentUser;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final current = _authService.currentUser;
    if (current != null) {
      unawaited(_handleUser(current));
    }

    _authSub = _authService.authStateChanges.listen(
      (user) => unawaited(_handleUser(user)),
      onError: (Object error) {
        _setState(AuthGateState.error, errorMessage: error.toString());
      },
    );
  }

  Future<void> _handleUser(User? user) async {
    if (_disposed) return;

    if (user == null) {
      _profile = null;
      _setState(AuthGateState.unauthenticated);
      return;
    }

    if (!user.emailVerified) {
      _profile = null;
      _setState(AuthGateState.emailNotVerified);
      return;
    }

    _setState(AuthGateState.booting);

    try {
      await _databaseService.createUserProfileIfNeeded(user: user);
      
      // Retry logic for profile loading to handle slight propagation delay
      YUserProfile? loadedProfile;
      for (int i = 0; i < 3; i++) {
        loadedProfile = await _databaseService.getCurrentUserProfile(forceRefresh: true);
        if (loadedProfile != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (loadedProfile == null) {
        _setState(AuthGateState.error, errorMessage: 'Profile could not be loaded.');
        return;
      }

      _profile = loadedProfile;
      _setState(AuthGateState.authenticated);
    } catch (e) {
      _setState(AuthGateState.error, errorMessage: e.toString());
    }
  }

  Future<AuthResult> login(String email, String password) async {
    _setBusy(true);
    try {
      return await _authService.signInWithEmail(email: email, password: password);
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    try {
      return await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthResult> googleSignIn() async {
    _setBusy(true);
    try {
      return await _authService.signInWithGoogle();
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthResult> sendPasswordReset(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<AuthResult> resendVerificationEmail() {
    return _authService.resendEmailVerification();
  }

  Future<void> refreshVerification() async {
    _setBusy(true);
    try {
      final verified = await _authService.reloadAndCheckEmailVerified();
      final user = _authService.currentUser;
      if (verified && user != null) {
        await _handleUser(user);
      } else {
        _setState(AuthGateState.emailNotVerified);
      }
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _profile = null;
    _setState(AuthGateState.unauthenticated);
  }

  void _setState(AuthGateState next, {String? errorMessage}) {
    if (_disposed) return;
    _state = next;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  void _setBusy(bool value) {
    if (_disposed) return;
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authSub?.cancel();
    super.dispose();
  }
}
