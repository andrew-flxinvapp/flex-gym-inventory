## Auth testing status — Signup & Magic Link

Date: 2025-12-16

This document summarizes what is ready and what still needs work to manually or automatically test the signup / magic-link authentication flow (Supabase + deeplinks) in this repo.

### Quick verdict

- You can manually test magic-link sign-in today using the existing **Sign In** screen and a real device. The app initializes Supabase and listens for incoming links to complete sign-in.
- The Sign Up and Verify screens are present but need small wiring changes (signup/resend actions) before they fully exercise sign-up/resend flows end-to-end.

### What is present and working

- Supabase initialization: `lib/main.dart` initializes Supabase using `flutter_dotenv` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
- Login UI (magic link): `lib/src/screens/login.dart` calls `Supabase.instance.client.auth.signInWithOtp(email: email)` and shows status messages — good for sending magic links.
- Deeplink listener: `lib/service/deeplink_service.dart` listens for initial/incoming links using `app_links` and forwards URIs to a registered handler.
- Deeplink handler + session restore: `main.dart` registers a handler that calls `Supabase.instance.client.auth.getSessionFromUrl(uri)` and navigates on successful sign-in (this is the correct flow to complete magic-link sign-in).
- Auth layer: `lib/src/repositories/auth_repository.dart` and `lib/view_models/auth_view_model.dart` exist and implement signInWithMagicLink/signUp/resendMagicLink/signOut and small error mapping logic — good for testability.
- Low-level wrapper: `lib/service/supabase_service.dart` exposes `sendMagicLink`, `signOut`, and `currentUser`.

### What is missing / not wired yet

- Signup screen wiring:
  - `lib/src/screens/signup.dart` currently contains form inputs and an enabled/disabled Sign Up button but does NOT call `AuthRepository.signUp` or the view model. The button just navigates to the verify screen.
- Verify email screen (resend):
  - `lib/src/screens/verify_email.dart` is static. The "Resend magic link" button navigates to `/opt-notifications` and does not call `resendMagicLink`.
- End-to-end tests: integration tests that automate magic-link flows are missing (understandable — magic links are hard to fully automate without a test Supabase project or mocks).
- CI/test mocks: there are no Supabase client mocks or harnesses for reliably simulating link clicks in automated tests.

### Important environment / infra notes

- .env: Make sure `.env` at app root contains `SUPABASE_URL` and `SUPABASE_ANON_KEY` for local runs (loaded via `flutter_dotenv`).
- Supabase Auth settings: Your Supabase project must include the redirect URL(s) or link handling settings that target your app (custom scheme or universal links). If the redirect configured in Supabase doesn't match the link your app handles, tapping the magic link will open a browser instead of delivering tokens to the app.

### How to manually test (recommended)

1. Confirm `.env` contains your Supabase URL and anon key.
2. Ensure your Supabase project's Auth > Settings has redirect URLs / deep link settings for your app (match iOS/Android configuration).
3. Run the app on a physical device (magic links generally work best when tapped on the same device):

```bash
# list devices
flutter devices

# run on a device (or specify -d <id>)
flutter run
```

4. In the app, open the Sign In screen, enter a reachable email on that device, and tap "Sign In".
5. Open the email on the device and tap the magic link. The app's `DeeplinkService` should capture the URI; `main.dart` will call `getSessionFromUrl(uri)` and, on success, navigate into the app. Verify that `Supabase.instance.client.auth.currentUser` is non-null.

### Quick, low-risk fixes I can implement now

- Wire `SignupScreen` to use the existing `AuthViewModel` or call `AuthRepository.signUp` so the Sign Up button actually requests a magic link or signs up (minimal change: add an email controller and call repository.signUp).
- Update `VerifyEmailScreen` to call `AuthRepository.resendMagicLink(email)` (or use the ViewModel) instead of navigating to `/opt-notifications`.
- Add small UI feedback after deep-link sign-in completes (e.g., a toast/log) to make it obvious the session was restored.

Files to edit for those fixes (minimal):

- `lib/src/screens/signup.dart` (hook up email controller and call repository/viewmodel)
- `lib/src/screens/verify_email.dart` (implement resend logic)
- optionally: `lib/src/screens/login.dart` to use `AuthViewModel` instead of calling Supabase directly (consistency)

### Prioritized next steps

1. Wire Signup and Verify screens (low effort, improves manual testing).
2. Add a small integration test scaffold that mocks `AuthRepository` for UI tests (can't fully automate magic link without infrastructure, but you can test UI flows and error states).
3. Add docs about Supabase redirect configuration (copy the specific redirect URL your app expects) into this repo's `docs/` so teammates can configure the Supabase project correctly.

### Status checklist (repo-aware)

- [x] Supabase initialized (`lib/main.dart`) — Present
- [x] Login screen sends magic link (`lib/src/screens/login.dart`) — Present
- [x] Deeplink service (`lib/service/deeplink_service.dart`) — Present
- [x] Deeplink handler & session restore (`lib/main.dart`) — Present
- [x] Auth repository & viewmodel (`lib/src/repositories/auth_repository.dart`, `lib/view_models/auth_view_model.dart`) — Present
- [ ] Signup screen wiring (`lib/src/screens/signup.dart`) — Needs wiring
- [ ] Verify/resend wiring (`lib/src/screens/verify_email.dart`) — Needs wiring
- [ ] Integration tests for auth flow — Missing

---

If you want, I can apply the minimal wiring changes to `signup.dart` and `verify_email.dart` now and run a quick smoke-check (static analysis/build). Which would you prefer: implement the wiring now, or keep code edits for later and just run manual tests using the Login screen?

