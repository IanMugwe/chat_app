# yCHAT Flutter Firebase Auth Codebase

This pack provides a production-ready authentication module for yCHAT using:

- Flutter
- Firebase Auth
- Cloud Firestore
- Google Sign-In
- Provider / ChangeNotifier
- Root Firestore collection: `yusers`

## Paste paths

Copy `lib/ychat_auth/` into your Flutter app.

Copy:
- `firestore.rules`
- `pubspec_dependencies.yaml`
- `docs/`

Then wire the wrapper in your app entry point.

## Minimal integration

```dart
await FirebaseBootstrap.initialize();

runApp(
  ChangeNotifierProvider(
    create: (_) => YUserProvider(),
    child: MaterialApp(
      theme: yChatDarkTheme(),
      home: YChatAuthWrapper(
        homeBuilder: (_, profile) => BottomNavigationScreen(),
      ),
    ),
  ),
);
```

## Required setup

```bash
flutter pub add provider firebase_core firebase_auth cloud_firestore google_sign_in shared_preferences
dart pub global activate flutterfire_cli
flutterfire configure
```

## Architecture

```text
Wrapper
→ Firebase auth state
→ unauthenticated: Login / Signup
→ authenticated but emailVerified false: EmailVerificationScreen
→ authenticated and verified: cached yusers profile
→ BottomNavigationScreen
```
