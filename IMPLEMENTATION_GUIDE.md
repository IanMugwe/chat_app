# ChatApp Implementation Roadmap

This document outlines the architecture and step-by-step implementation plan for transforming the current 1:1 chat app into a robust, media-capable messaging platform supporting groups, files, images, and voice messages.

## 1. Authentication Review
*   **Current State:** The `AuthService` handles `signup`, `login`, and `logout` using `FirebaseAuth`. It performs basic error logging and rethrows exceptions.
*   **Strengths:** Simple, direct, and adheres to standard Firebase Auth patterns.
*   **Recommendations:**
    *   **User Persistence:** The current `AuthService` doesn't explicitly link auth changes to the `database_service.dart` `saveUser` flow during sign-up. It is recommended to update the `signup` method to save user metadata to Firestore immediately upon account creation.
    *   **State Observation:** Ensure the UI layer implements a proper `StreamBuilder` listening to `FirebaseAuth.instance.authStateChanges()` to handle session persistence and automatic redirection to `WrapperScreen`.

## 2. Advanced Messaging & Media Architecture
We are transitioning to a **Component-Based Messaging Model** for reusability across 1:1, group, and channel modules.

### Architectural Principles
*   **Dependency Inversion:** UI components communicate via callbacks, not direct service access.
*   **Polymorphic Messages:** Messages use a `MessageType` enum to decide rendering logic.
*   **Unified Media Service:** A centralized service handles `firebase_storage` interactions and permissions.

## 3. Implementation Steps

### Phase 1: Data Model Refactoring
- [ ] **Refactor `MessageModel`:** Add `MessageType` (text, image, doc, voice), `timestamp`, and `metadata` (for file info).
- [ ] **Create `GroupModel`:** Model for group chats with `groupId`, `name`, and `members` (List of UIDs).

### Phase 2: Core Service Layer
- [ ] **Implement `MediaService`:** Create `lib/core/services/media_service.dart`.
    - Methods: `uploadFile(File, folder)`, `recordAudio()`, `pickDocument()`.
- [ ] **Update `ChatService`:** Add `createGroup(name, members)` and update `saveMessage` to support polymorphic models.

### Phase 3: SmartChatInput Implementation
- [ ] **Create `ChatInputViewModel`:** Manage state (idle, text, recording).
- [ ] **Build `SmartChatInput` Widget:**
    - `MediaActionTray`: Trigger media/document picker.
    - `InputArea`: Growing `TextField`.
    - `DynamicActionContainer`: Toggle between Send (on text) and Voice (on empty).

### Phase 4: UI Integration & Rendering
- [ ] **Build `MessageBubbleFactory`:** A central widget that renders `TextBubble`, `ImageBubble`, `DocBubble`, or `AudioBubble` based on `MessageType`.
- [ ] **Wire UI:** Replace existing text inputs with `SmartChatInput` and update the `StreamBuilder` in `ChatRoomScreen` to use the `MessageBubbleFactory`.

## 4. Usage Guide
1.  **Adding Features:** To add a feature (e.g., location sharing), simply add the type to `MessageType`, add a render case to `MessageBubbleFactory`, and update `SmartChatInput` with a new icon.
2.  **Groups:** Create groups by calling `ChatService.createGroup`. Use the same `ChatRoomScreen` for both 1:1 and group chats, just pass a `groupId` instead of a `chatRoomId`.
