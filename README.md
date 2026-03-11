# Flex Gym Inventory

Flex Gym Inventory 

Lightweight. Powerful. Purpose-Built.

## Description

Flex Gym Inventory is a lightweight, powerful mobile app designed for home and small gym owners to track, manage, and organize their equipment. 

Built in Flutter for iOS and Android.

## Build in Public

This app is being developed in public to share the process, learn out loud, and invite feedback from fellow lifters and developers.

Follow along:
-	Instagram: @flxinv.app
-	Bluesky: @flxinvapp.bsky.social
-	Twitter/X: @flxinvapp
- Substack: www.substack.com/@heavydevco




## Features

- Add and manage multiple gym locations
- Track equipment with custom categories
# Flex Gym Inventory

Lightweight mobile app to track and manage gym equipment — built with Flutter for iOS and Android.

Status: In development (public)

What is this
- Purpose: track equipment across multiple gym locations, view history, and export CSVs.
- Target: small gyms, garage gyms, and individual owners who need a simple inventory tool.

Quick start (development)
1. Install Flutter (stable channel) and ensure Dart 3.
2. From the project root:

```bash
cd flex_gym_inventory
flutter pub get
flutter run
```

Prerequisites
- Flutter SDK (stable)
- Xcode (for iOS) or Android Studio (for Android)
- Optional: Supabase project (for auth). Provide `SUPABASE_URL` and `SUPABASE_ANON_KEY` via environment variables for local testing.

Project structure (high level)
- `lib/` — app code (routes, screens, widgets, view_models)
- `android/`, `ios/` — platform runners and configuration
- `test/` — unit and widget tests
- `docs/` — design notes and onboarding docs (see `docs/auth_onboarding_review.md`)

Auth & onboarding
- Uses Supabase magic-link authentication by default. See `docs/auth_onboarding_review.md` for flow, gaps, and recommended fixes.

Notifications
- The app requests runtime notification permission on iOS and Android. No push provider is configured by default — follow docs in `docs/` before enabling server push.

Running tests
```bash
cd flex_gym_inventory
flutter test
# or run a specific test
flutter test test/view_models/sign_up_view_model_test.dart
```

Development notes
- iOS: enable the "Push Notifications" capability in Xcode when you integrate APNs.
- Android: Android 13+ requires `POST_NOTIFICATIONS` runtime permission (already added to the manifest).
- Keep secrets out of VCS; use environment variables or a local `.env` not checked into source control.

Contributing
- Open issues or PRs. Keep changes small and include tests for new behavior.

License & contact
- This repository is authored by the project owner. Contact via repository issues or the social links below for collaboration.

Social
- Bluesky: @heavydevco.bsky.social
- X/Twitter: @heavydevco
