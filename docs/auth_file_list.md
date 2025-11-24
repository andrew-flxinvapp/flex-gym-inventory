Auth / Onboarding / Sign-in File List

High-level contract
- Inputs: user credentials (email/password), OAuth tokens, onboarding answers, optional profile info, verification links.
- Outputs: authentication state (signed-in user with profile), persisted session (Supabase session + local cache), navigation transitions (to onboarding, main app), error events.
- Error modes: network unavailable, invalid credentials, email unverified, token expiration, malformed input, Supabase errors.

Suggested file structure (paths relative to repo root)

- lib/
  - src/
    - auth/
      - auth_service.dart — Core auth operations (signUp, signIn, signOut, refreshSession, sendPasswordReset, verifyEmail). Talks to Supabase client.
      - supabase_client.dart — Supabase client wrapper/initializer (reads env/config). Exposes typed client to app.
      - auth_repository.dart — Higher-level repository that persists lightweight user/profile to Isar if you want local caching/sync.
      - auth_state.dart — Model for auth state (enum: unknown/unauthenticated/authenticated, user info, session).
      - auth_state_notifier.dart (or auth_provider.dart) — State management (Riverpod/Provider/Bloc) to expose sign-in state reactively.
      - auth_exceptions.dart — Typed exceptions for auth errors (e.g., InvalidCredentials, EmailNotVerified).
      - social_auth.dart — OAuth helper wrappers (Google, Apple) using Supabase OAuth flows.
      - secure_storage.dart — small wrapper around flutter_secure_storage for tokens / secrets (if needed).
      - validators.dart — email/password validators used by forms.
    - onboarding/
      - onboarding_service.dart — Save onboarding progress, compute next steps.
      - onboarding_model.dart — Persisted model (e.g., completedSteps, chosenPreferences).
      - onboarding_state.dart — UI state & helpers.
      - onboarding_flow.dart — small coordinator (routes and next-step logic).
    - screens/
      - auth/
        - login_screen.dart — email/password login UI (uses `AuthForm` or widgets below). Calls `AuthStateNotifier.signIn`.
        - signup_screen.dart — registration screen with name/email/password and optional profile photo step.
        - verify_email_screen.dart — informs user to verify and optionally re-send verification email.
        - forgot_password_screen.dart — request reset; confirm password reset screen (if you process deep links).
        - social_login_buttons.dart — social sign-in buttons for Google/Apple.
        - auth_loading_screen.dart — initial screen while auth state checks/refresh session.
      - onboarding/
        - onboarding_welcome.dart — short intro screen.
        - onboarding_questions.dart — actual onboarding steps (multi-step).
        - onboarding_summary.dart — summary & finish button that marks onboarding complete.
      - app/
        - home_screen.dart — main app entry after auth & onboarding completed.
        - profile_setup_screen.dart — optional profile setup after sign-up.
    - widgets/
      - auth_form.dart — reusable email/password form (fields, validation).
      - oauth_button.dart — social login button widget.
      - error_banner.dart — small UI helper to show non-blocking errors.
    - utils/
      - deep_link_handler.dart — handle incoming links for email verification or password reset.
      - routes.dart — named routes constants for navigation.
      - logging_handler.dart — (already exists) ensure it logs auth events.
- test/
  - unit/
    - auth/
      - auth_service_test.dart — unit tests for `AuthService` (mock Supabase).
      - auth_repository_test.dart — tests for local persistence and translations.
    - onboarding/
      - onboarding_service_test.dart
  - widget/
    - auth/
      - login_screen_test.dart — widget tests for UI validation, button enabling, error messages.
      - signup_screen_test.dart
      - forgot_password_screen_test.dart
    - onboarding/
      - onboarding_flow_test.dart — widget tests for multi-step UI and navigation triggers.
  - integration_test/ (optional; uses flutter integration_test or e2e)
    - auth_flow_test.dart — end-to-end test: sign-up -> verify (if possible in test env) -> onboarding -> main app.
    - login_persistence_test.dart — app restart preserves session and returns to main screen.
- dev/ or scripts/
  - run_supabase_local.sh (optional) — helper to start a local Supabase or a test/mocked backend
- assets/
  - onboarding_images/ (if any)

Minimal responsibilities for each file (implementation hints)
- auth/supabase_client.dart: Initialize Supabase with env vars. Export a singleton client.
- auth/auth_service.dart: Methods: signUp, signIn, signOut, sendPasswordReset, sendVerifyEmail, signInWithProvider, refreshSessionIfNeeded. Wrap Supabase errors.
- auth/auth_repository.dart: Persist minimal profile (id, email, displayName, onboardingComplete) into Isar.
- auth/auth_state_notifier.dart: Restore session on app start, expose sign-in state, methods to signIn/signUp/signOut.
- onboarding/onboarding_service.dart: Persist step completion to Isar or Supabase user metadata.
- deep_link_handler.dart: Parse verification and reset links and call AuthService.

Testing strategy
- Unit tests: mock Supabase client, validate error mapping and success paths.
- Widget tests: validate form behavior, button enable/disable, error messages, navigation triggers.
- Integration tests (optional): run against test Supabase or mocked backend for end-to-end flow.

Dependency & config checklist
- pubspec.yaml: supabase_flutter (or supabase), flutter_secure_storage, mockito/mocktail, integration_test, flutter_test.
- Platform settings: iOS URL schemes, Android intent-filters for OAuth/deep links.
- Environment: SUPABASE_URL and SUPABASE_ANON_KEY in .env or CI secrets.

Edge cases & considerations
- Email verification flow, OAuth redirects, session refresh, onboarding resume.

Next steps
- I can generate skeleton files and example tests or create a script that writes a .docx from this markdown. Let me know which you prefer.
