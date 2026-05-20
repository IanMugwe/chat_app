# Migration Notes for Existing Users

If your current app already has users in another collection:

1. Create a one-time migration script or admin tool.
2. For each Firebase Auth user, create `yusers/{uid}`.
3. Preserve:
   - uid
   - email
   - display name
   - photo URL
   - status
4. Do not overwrite existing `yusers/{uid}` if it already exists.
5. Keep old profile collection read-only until migration is validated.

Recommended profile status values:

```text
active
disabled
deleted
pending
```

The shipped auth service uses `createUserProfileIfNeeded()` so existing profiles are preserved and only missing profiles are provisioned.
