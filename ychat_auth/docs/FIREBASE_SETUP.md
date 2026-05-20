# yCHAT Firebase Authentication Setup

## FlutterFire setup

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart`.

## Enable sign-in providers

In Firebase Console:

1. Authentication → Sign-in method.
2. Enable Email/Password.
3. Enable Google.

## Android setup

Required:

- `android/app/google-services.json`
- package name must match Firebase app
- add SHA-1 and SHA-256 fingerprints in Firebase Console
- re-download `google-services.json` after adding SHA fingerprints

Command:

```bash
cd android
./gradlew signingReport
```

Copy SHA-1 and SHA-256 from debug and release variants.

## iOS setup

Required:

- `ios/Runner/GoogleService-Info.plist`
- Bundle ID must match Firebase iOS app
- add reversed client ID URL scheme

In Xcode:

1. Runner → Info → URL Types.
2. Add URL scheme from `GoogleService-Info.plist`: `REVERSED_CLIENT_ID`.

## Firestore

Root collection:

```text
yusers/{uid}
```

Required fields:

```json
{
  "uid": "firebase uid",
  "email": "user@email.com",
  "name": "User Name",
  "profilePic": "https://...",
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp",
  "status": "active"
}
```

## Production notes

- Enforce App Check before public release.
- Use release SHA fingerprints, not only debug fingerprints.
- Brand verification and password reset email templates in Firebase Console.
- Add support email and app domain branding.
