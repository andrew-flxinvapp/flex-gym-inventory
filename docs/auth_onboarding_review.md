# Auth & Onboarding Review — Flex Gym Inventory

Date: 2026-01-20

Purpose: a concise, printable analysis of the current login / signup / onboarding implementation, gaps to address before testing, and prioritized next steps.

**Files Reviewed**
- `lib/main.dart`
- `lib/routes/routes.dart`
- `lib/src/screens/login.dart`
- `lib/src/screens/signup.dart`
- `lib/src/screens/verify_email.dart`
- `lib/src/screens/opt_notifications.dart`
- `lib/src/screens/onboarding_feature_one.dart`
- `lib/src/screens/onboarding_feature_two.dart`
- `lib/src/screens/welcome.dart`
- `lib/src/screens/onboarding_complete.dart`
- `lib/src/screens/startup_router.dart`
- `lib/src/repositories/auth_repository.dart`
- `lib/src/repositories/onboarding_repository.dart`
- `lib/view_models/login_view_model.dart`
- `lib/view_models/sign_up_view_model.dart`
- `lib/view_models/auth_view_model.dart`
- `test/view_models/*` (sign up and login tests)


**What’s Present (Working Foundations)**
- Route map and screens for the full onboarding flow are implemented and wired in `routes/routes.dart`.
- `AuthRepository` wraps Supabase auth flows (magic link, signUp, signOut) and maps errors to `AuthException` for cleaner handling.
- `OnboardingRepository` writes `user_metadata` fields (`onboardingComplete`, `notificationsOn`) to Supabase.
- Deeplink handling exists in `main.dart`. It calls `Supabase.instance.client.auth.getSessionFromUrl(uri)` and navigates to verify-email when appropriate.
- Deeplink handling exists in `main.dart`. It calls `Supabase.instance.client.auth.getSessionFromUrl(uri)` and navigates to verify-email when appropriate.
- Platform registration for a custom deep-link scheme has been added in this repo (custom-scheme approach):
  - Android: `android/app/src/main/AndroidManifest.xml` includes an `intent-filter` for `flexgyminv://auth`.
  - iOS: `ios/Runner/Info.plist` includes `CFBundleURLTypes` registering the `flexgyminv` scheme.
  These changes enable opening the app from Supabase magic links when Supabase is configured to redirect to `flexgyminv://auth`.
- View models exist for login and signup with unit tests in `test/view_models/`.


**Concrete Gaps & Risks (blocking reliable testing now)**
1. Inconsistent view-model usage -COMPLETE-
- `signup.dart` uses `AuthViewModel` (generic) while a dedicated `SignUpViewModel` exists with validation and tests. `login.dart` calls Supabase directly but `LoginViewModel` contains validation and tests.
- Why it matters: inconsistent usage affects testability, duplicate logic, and makes UI behavior harder to assert in widget tests.

2. Signup UI fields are not wired or persisted -COMPLETE-
- `signup.dart` shows First/Last Name fields but they have no controllers and aren’t saved to Supabase. The `SignUpViewModel` expects a password, but the UI provides no password field.
- Why it matters: tests expect password handling; user data (names) won't be stored unless you add metadata handling.

3. Password vs magic-link mismatch -COMPLETE-
- Repos and VMs support both magic-link and password flows, but the UI is inconsistent. `AuthRepository.signUp` falls back to magic link if password is null.
- Decide which sign-up method you want and align UI, VMs, tests, and repository accordingly.

4. Startup routing ignores onboarding status -COMPLETE-
- `StartupRouterScreen` checks only for a session; it sends a logged-in user straight to dashboard. It should inspect `OnboardingRepository.isOnboardingComplete` and route to onboarding if needed.

5. Validation and UX
- `login.dart` lacks client-side validation for empty or malformed email; `LoginViewModel` has it. `signup.dart` has no email/password validation wired into the UI.

6. Message handling inconsistency
- Some screens rely on local `_message` variables, some use view model messages. Pick one approach for consistent SnackBar/inline feedback behavior.

7. Notifications flow limited
- `OptNotificationsScreen` writes `notificationsOn` metadata but does not request platform push notification permission or manage device tokens (FCM/APNs).

8. Tests coverage gaps
- Unit tests exist for VMs but there are no widget or integration tests for the UI screens, deeplink handling, or `StartupRouterScreen` routing logic.


**Minimal Fixes (to enable reliable manual and automated testing quickly)**
- Standardize screens to use their dedicated view models:
  - Wire `signup.dart` to `SignUpViewModel` (bind `emailController`, `passwordController`).
  - Wire `login.dart` to `LoginViewModel.sendMagicLink()` for validation and message handling.

- Decide sign-up flow and align stacks:
  - Option A (recommended for initial testing): Use password sign-up (add password field in `signup.dart`, call `signUp(email, password)`). Update tests to match UI if needed.
  - Option B: Magic-link only — remove password expectation in `SignUpViewModel` & tests, and update UI text to reflect magic-link behavior.

- Persist first/last name if you want them stored:
  - Add `Map<String,dynamic>? userMetadata` param to `AuthRepository.signUp`, or call `updateUser(UserAttributes(data: {...}))` after account creation.

- Update `StartupRouterScreen` to check onboarding metadata and route to either onboarding flow or dashboard.

- Wire consistent message handling: display VM messages via `ScaffoldMessenger` or inline text consistently across screens.

- Add a small widget test for `StartupRouterScreen` that mocks `SupabaseClient` / `OnboardingRepository` metadata and verifies routing.


**Recommended API changes (small & backward-compatible)**
- `AuthRepository.signUp(String email, {String? password, Map<String,dynamic>? userMetadata})` — if `userMetadata` is present, after signUp call `updateUser` (or include it in initial signUp if Supabase supports it).
- Add `AuthRepository.reconcileLocalUser()` caller points post sign-in if you plan to sync to Isar.


**Prioritized Next Steps (pick one to start with)**
1) Wire UI -> ViewModel: Update `signup.dart` and `login.dart` to use `SignUpViewModel` and `LoginViewModel` respectively. Add password input to signup.
2) Update `StartupRouterScreen`: check `OnboardingRepository.isOnboardingComplete` and route accordingly; add a widget test for routing.
3) Add `userMetadata` support to `AuthRepository.signUp` and persist first/last name from the signup screen.
4) Add widget/integration tests for login/signup/verify-email flows (mock `AuthRepository`/Supabase).


**Quick Checklist (for manual testers)**
- [ ] Set `.env` with `SUPABASE_URL` and `SUPABASE_ANON_KEY` for the test Supabase project.
- [ ] Confirm Supabase redirect/site URL is set to the custom scheme used by the app: `flexgyminv://auth`.
- [ ] Run the app and confirm deeplink handler navigates to `VerifyEmailScreen` after a magic-link click.
- [ ] Attempt sign-up and confirm whether email verification is expected (magic link) or immediate login (password flow).
- [ ] For public testing, ensure `StartupRouterScreen` routes new users through onboarding.

Test commands (quick):

Android emulator/device (replace `com.your.package.name` with your app id):

```bash
adb shell am start -a android.intent.action.VIEW -d "flexgyminv://auth#access_token=TEST&refresh_token=TEST" com.your.package.name
```

iOS Simulator:

```bash
xcrun simctl openurl booted "flexgyminv://auth#access_token=TEST&refresh_token=TEST"
```

End-to-end (recommended):
- In Supabase Auth settings set the redirect/site URL to `flexgyminv://auth`.
- Send a magic link to an email that you can open on the same device. Clicking the magic link should open the app and your `main.dart` deeplink handler should call `getSessionFromUrl` and then navigate to the startup router.


**Commands / How to run tests**
- Run unit tests:

```bash
cd flex_gym_inventory
flutter test test/view_models/sign_up_view_model_test.dart
flutter test test/view_models/login_view_model_test.dart
```

- Run all tests:

```bash
flutter test
```


**Printing / Docx options**
- This is a Markdown file (`docs/auth_onboarding_review.md`) created in the repo. You can print it directly from a Markdown viewer or convert to DOCX with `pandoc`:

```bash
# Convert markdown -> docx (requires pandoc)
pandoc docs/auth_onboarding_review.md -o docs/auth_onboarding_review.docx
```


**Where I saved this**
- `flex_gym_inventory/docs/auth_onboarding_review.md`


**If you want, I can next:**
- Implement option (1): wire `signup.dart` and `login.dart` to their view models and add a password field to `signup.dart` (I can apply patches and run unit/widget tests).  
- Or convert the Markdown to a `.docx` file in the repo for printing.


---

If you'd like the DOCX now, tell me which option to convert (create a `.docx` in `docs/`), or say which code change you'd like me to implement first.
