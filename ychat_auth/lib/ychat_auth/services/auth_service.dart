import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database_service.dart';

class AuthResult {
  final bool success; 
  final String? message;
  final User? user;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
  });
}

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    DatabaseService? databaseService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _databaseService = databaseService ?? DatabaseService();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final DatabaseService _databaseService;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await _databaseService.createUserProfileIfNeeded(user: user);
      }

      return AuthResult(success: true, user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _friendlyAuthError(e));
    } catch (_) {
      return const AuthResult(success: false, message: 'Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await _databaseService.createUserProfileIfNeeded(user: user, fallbackName: name);
        await user.sendEmailVerification();
      }

      return AuthResult(success: true, user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _friendlyAuthError(e));
    } catch (_) {
      return const AuthResult(success: false, message: 'Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const AuthResult(success: false, message: 'Google sign-in cancelled.');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authCredential = await _auth.signInWithCredential(credential);
      final user = authCredential.user;

      if (user != null) {
        await _databaseService.createUserProfileIfNeeded(
          user: user,
          fallbackName: googleUser.displayName,
        );
      }

      return AuthResult(success: true, user: user);
    } on FirebaseAuthException catch (e, stackTrace) {
      developer.log('FirebaseAuthException during Google sign-in', error: e, stackTrace: stackTrace);
      return AuthResult(success: false, message: _friendlyAuthError(e));
    } catch (e, stackTrace) {
      developer.log('Exception during Google sign-in', error: e, stackTrace: stackTrace);
      final errMsg = e.toString().contains('network_error')
          ? 'Network error. Please check your internet connection.'
          : 'Google sign-in failed: ${e.toString().replaceAll('PlatformException', '')}';
      return AuthResult(success: false, message: errMsg);
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true, message: 'Password reset link sent. Check your inbox.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _friendlyAuthError(e));
    } catch (_) {
      return const AuthResult(success: false, message: 'Unable to send reset email. Please try again.');
    }
  }

  Future<AuthResult> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const AuthResult(success: false, message: 'No signed-in user found.');
      await user.sendEmailVerification();
      return const AuthResult(success: true, message: 'Verification email sent.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _friendlyAuthError(e));
    } catch (_) {
      return const AuthResult(success: false, message: 'Unable to resend verification email.');
    }
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    await _databaseService.clearCachedUser(uid);
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please use a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
