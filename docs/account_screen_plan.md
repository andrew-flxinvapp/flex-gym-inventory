# Account Screen Implementation Plan

This document outlines a clear, incremental plan to implement `account.dart`, which will merge data from Supabase and Isar and expose a robust, testable UI.

## Goals
- Display and edit user account data (profile, email, avatar, settings, subscriptions, linked devices).
- Keep local cache in Isar synchronized with Supabase and support offline edits.
- Provide a resilient, testable, and secure implementation with clear conflict-resolution.

## High-Level Plan

1. Requirements
   - Enumerate fields and flows: read-only profile, editable fields, avatar upload, sign-out, delete account, subscription status, linked devices.
   - Prioritize read vs write UX and which fields require immediate consistency.

2. Models
   - Define DTOs and Isar schema: `Account`, `Profile`, `Settings`, `Subscription`, `Device`.
   - Add mapping functions: Supabase row ↔ DTO ↔ Isar object.

3. Services
   - `SupabaseService`: auth, realtime (subscriptions), storage (avatars), CRUD helpers.
   - `IsarService`: open DB, provide typed DAOs, migrations, query helpers.

4. Repository
   - `AccountRepository` to orchestrate reads/writes, mapping, caching, and merge logic.
   - Expose streams (or `AsyncValue`/`ValueNotifier`) for UI consumption.

5. Sync strategy
   - Read-through cache: prefer Isar, fallback to Supabase if missing or stale.
   - Realtime updates from Supabase should update Isar and notify UI.
   - Queue local writes when offline; flush when online.

6. Conflict resolution
   - Use timestamps/versioning and a policy (LWW or field-level merge).
   - Surface manual merge UI only for high-value conflicts.

7. State management
   - Implement `AccountViewModel` (Riverpod/Bloc/Provider) with clear APIs: `load()`, `refresh()`, `updateField()`, `updateAvatar()`, `signOut()`, `deleteAccount()`.

8. UI (`account.dart`)
   - Scaffold loading/error/empty/content states.
   - Display profile summary, editable sections, avatar uploader, subscription info, and device list.
   - Use optimistic updates with rollback on failure and user-visible error messages.

9. Security & validation
   - Enforce client-side validation and mirror checks server-side (RLS policies in Supabase).
   - Keep sensitive fields encrypted or excluded from local cache when necessary.

10. Migrations & maintenance
   - Track Isar schema versions and provide migration steps and tests.

11. Tests & CI
   - Unit tests for mapping, repository logic, and conflict resolution (mock Supabase).
   - Integration tests for sync behavior and widget tests for `account.dart` UI states.

12. Performance
   - Index common Isar fields, paginate large lists, debounce writes, and limit realtime payloads.

## Checklist / Implementation Steps
- [ ] Define DTOs and Isar schemas.
- [ ] Implement `SupabaseService` and `IsarService`.
- [ ] Implement `AccountRepository` with sync + conflict logic.
- [ ] Create `AccountViewModel` and wire state management.
- [ ] Scaffold `lib/src/screens/account.dart` UI and wire to view model.
- [ ] Add tests (unit, integration, widget).
- [ ] Run migration and manual QA.

## Next Steps
- If you want, I can scaffold the services, repository, models, and a minimal `account.dart` UI now.

---
Created as a concise plan to guide development and testing of `account.dart`.
