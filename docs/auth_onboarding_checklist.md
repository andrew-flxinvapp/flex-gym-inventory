## Auth & Onboarding - Repo-aware Checklist

Generated: 2025-11-17

This file is a repo-aware checklist for implementing and verifying the Sign-in / Signup / Onboarding flow for this Flutter app (Supabase + Isar). It marks recommended source/test files as Present or Missing and includes short notes and next steps.

Legend
- Present — file exists in the repository (path shown)
- Missing — file not found (recommended name & location)
- Notes — short guidance about role and integration

---

## Core initialization & wiring

- `lib/main.dart` — Present
  - Notes: Supabase is initialized (reads SUPABASE_URL / SUPABASE_ANON_KEY from dotenv). App-level startup wiring present.

- `lib/service/supabase_service.dart` — Present
  - Notes: Low-level Supabase client wrapper with `currentUser` getter. Good place to add helper methods (signIn, signUp, resend, signOut).

- `lib/providers/auth_providers.dart` — Present
  - Notes: Contains a provider that maps `Supabase.instance.client.auth.onAuthStateChange` to a reactive user stream. Useful for app-wide auth state.

## Screens / UI

- `lib/src/screens/login.dart` — Present
  - Notes: Uses `Supabase.instance.client.auth.signInWithOtp(email: ...)` to send a magic link. Contains UI but needs ViewModel/service wiring (loading, errors).

- `lib/src/screens/signup.dart` — Present
  - Notes: Basic sign-up form; navigates to `verify_email`. Needs to call AuthRepository or Supabase sign-up path and persist metadata if required.

- `lib/src/screens/verify_email.dart` — Present
  - Notes: Static instructions screen. Placeholder for an email string. "Resend magic link" currently only navigates to `'/opt-notifications'` — needs resend logic and optional deep-link/polling to complete sign-in.

- `lib/src/screens/welcome.dart` — Present
  - Notes: Onboarding/welcome UI exists and is wired in routes.

- `lib/src/screens/onboarding_feature_one.dart` — Present

- `lib/src/screens/onboarding_feature_two.dart` — Present

- `lib/src/screens/onboarding_upgrade.dart` — Present (imported in `routes.dart`)

- `lib/src/screens/onboarding_complete.dart` — Present

- `lib/src/screens/opt_notifications.dart` — Present

- `lib/src/screens/social_proof.dart` — Present

Recommended (optional) UI to add:
- `lib/src/screens/auth_loading.dart` — Missing
  - Purpose: Small screen shown while checking session / restoring token before routing.

- `lib/src/screens/profile_onboarding.dart` — Missing
  - Purpose: Collect user profile details (displayName, gym preferences) after auth if required.

## Auth domain layer (services / repositories / models)

- `lib/src/models/user_model.dart` — Missing
  - Notes: If you persist user metadata locally in Isar, add a `User` model (userId, email, displayName, prefs).

- `lib/src/repositories/auth_repository.dart` — Missing
  - Purpose: Encapsulate auth flows (signInWithMagicLink, signUp, resendMagicLink, signOut, currentUser), map Supabase errors to domain errors, and reconcile Supabase user with local Isar user record.

- `lib/src/data/user_local_repository.dart` — Missing
  - Purpose: Isar-backed local user store (save/load profile, preferences).

Notes: You currently have `lib/service/supabase_service.dart` (low-level) and `lib/providers/auth_providers.dart` (auth state stream). Adding an `AuthRepository` that depends on the Supabase service will improve testability and centralize logic.

## ViewModels / State Management

- `lib/src/viewmodels/login_viewmodel.dart` — Missing
  - Purpose: Encapsulate login logic, validation, loading/error state, and call into `AuthRepository`.

- `lib/src/viewmodels/signup_viewmodel.dart` — Missing

- `lib/src/viewmodels/auth_viewmodel.dart` — Missing
  - Purpose: Observe `auth_providers.dart`, manage high-level routing decisions (home vs onboarding), sign-out, and session restoration.

If you use Riverpod/Provider/Bloc, add providers/controllers that wrap these viewmodels — I did not find these in the scan.

## Deep-link / Magic-link handling

- Deep-link handler / universal link listener — Missing
  - Recommended: `lib/src/services/deeplink_service.dart` or `lib/src/utils/deeplink_handler.dart`
  - Purpose: Listen for incoming links (e.g., via `uni_links` or platform APIs). When the user taps the Supabase magic link, the app should capture the link and allow Supabase to complete the sign-in/redirect flow. Currently no deep-link handler was found.

Notes on magic-link UX: Without a deep-link handler the user must manually return to the app and the app may not detect the completed session. Implementing deep-link or universal link handling is important to provide a seamless magic-link sign-in.

## Routing

- `lib/routes/routes.dart` — Present
  - Notes: Routes for `signup`, `login`, `verify_email`, `welcome`, `onboarding_*`, and `opt-notifications` are declared. Good — route wiring exists.

## Tests (recommended)

Unit tests (Missing)
- `test/services/supabase_service_test.dart` — Missing
- `test/repositories/auth_repository_test.dart` — Missing
- `test/viewmodels/login_viewmodel_test.dart` — Missing

Widget tests (Missing)
- `test/widgets/login_screen_test.dart` — Missing
- `test/widgets/verify_email_screen_test.dart` — Missing

Integration / E2E (optional)
- `integration_test/auth_flow_test.dart` — Missing (hard to fully automate magic links; consider mocks or a test Supabase project)

## Logging / Error reporting

- `lib/utilities/error_handler.dart` — Present
  - Notes: Has been updated to accept StackTrace and forward to `LogHandler`. Good place to surface friendly auth error messages.

- `lib/utilities/logging_handler.dart` — Present
  - Notes: Centralized logging implemented. Consider adding Sentry/Crashlytics hooks for production.

## Misc / Helpers

- `lib/src/widgets/onboarding_topappbar.dart` — Present
  - Notes: Shared UI used across onboarding screens.

- Buttons referenced by some screens (e.g., `primary_button.dart`) — verify presence. Some imports are present but commented out; widgets may exist elsewhere.

## Presence summary (short)

Present (confirmed):
- `lib/main.dart`
- `lib/service/supabase_service.dart`
- `lib/providers/auth_providers.dart`
- `lib/routes/routes.dart`
- `lib/src/screens/login.dart`
- `lib/src/screens/signup.dart`
- `lib/src/screens/verify_email.dart`
- `lib/src/screens/welcome.dart`
- `lib/src/screens/onboarding_feature_one.dart`
- `lib/src/screens/onboarding_feature_two.dart`
- `lib/src/screens/onboarding_upgrade.dart`
- `lib/src/screens/onboarding_complete.dart`
- `lib/src/screens/opt_notifications.dart`
- `lib/src/screens/social_proof.dart`
- `lib/utilities/error_handler.dart`
- `lib/utilities/logging_handler.dart`
- `lib/src/models/wishlist_model.dart` (contains `userId` field)

Missing / Recommended to add:
- `lib/src/repositories/auth_repository.dart`
- `lib/src/models/user_model.dart`
- `lib/src/data/user_local_repository.dart`
- `lib/src/viewmodels/login_viewmodel.dart`
- `lib/src/viewmodels/signup_viewmodel.dart`
- `lib/src/viewmodels/auth_viewmodel.dart`
- `lib/src/services/deeplink_service.dart`
- Test files under `test/` and `integration_test/` for auth flows

## Recommended next steps (concrete)

1. Add an `AuthRepository` that wraps `supabase_service` with methods:
   - signInWithEmailMagicLink(email)
   - signUp(email, metadata)
   - resendMagicLink(email)
   - signOut()
   - currentUser()
   This centralizes Supabase logic and improves testability.

2. Add `AuthViewModel` (or Riverpod providers) that:
   - Observes `auth_providers.dart` for session changes
   - Drives top-level navigation (home vs onboarding)
   - Exposes sign-in/sign-up actions for UI screens

3. Implement a `deeplink_service.dart` using `uni_links` (or platform deep link handling) to capture magic links and let the app complete the sign-in flow automatically.

4. Add a small `user_model.dart` (Isar) and `user_local_repository.dart` if you want to persist user preferences offline and reconcile local state with Supabase identities.

5. Add unit and widget tests for `AuthRepository`, `AuthViewModel`, `login.dart`, and `verify_email.dart`.

Notes: This checklist is intentionally pragmatic — it prioritizes small, testable units (AuthRepository and AuthViewModel) and the deeplink handler which is the main missing piece for a smooth magic-link UX. If you prefer a different approach (password auth, OAuth, or email+password), I can adapt the recommended files.

----
Completion: saved to `docs/auth_onboarding_checklist.md` in the repository.
