# yCHAT Auth Testing Checklist

## Startup

- [ ] Fresh install opens SplashScreen.
- [ ] Unauthenticated user lands on LoginScreen.
- [ ] Existing verified user opens BottomNavigationScreen without profile flash.
- [ ] Existing unverified user lands on EmailVerificationScreen.
- [ ] Wrapper does not show double spinners.

## Email signup

- [ ] Signup creates Firebase user.
- [ ] Signup creates `yusers/{uid}` profile.
- [ ] Verification email sends automatically.
- [ ] Unverified user cannot access home.

## Email verification

- [ ] Resend button has 60-second cooldown.
- [ ] “I Have Verified” reloads Firebase user.
- [ ] Verified user proceeds to home instantly.
- [ ] Sign out works.

## Login

- [ ] Correct email/password logs in.
- [ ] Wrong password shows friendly error.
- [ ] Disabled/unknown account shows friendly error.

## Google Sign-In

- [ ] Cancelled sign-in does not crash.
- [ ] First-time Google user creates `yusers/{uid}`.
- [ ] Existing Google user profile is preserved.
- [ ] Logout clears session.

## Forgot password

- [ ] Invalid email shows inline validation.
- [ ] Request disables button while loading.
- [ ] Success snackbar shown.
- [ ] Firebase reset email is received.

## Performance

- [ ] No artificial splash delay.
- [ ] Profile read cached after login.
- [ ] No duplicate auth listeners.
- [ ] No setState during build.
- [ ] Firestore offline cache works.

## Rules

- [ ] User can read own yusers document.
- [ ] User cannot read another user document.
- [ ] User cannot change uid/email through update.
