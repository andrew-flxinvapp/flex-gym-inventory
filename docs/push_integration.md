Push integration (provider-agnostic)

This document describes a minimal, provider-agnostic setup to prepare the
app and backend to accept device tokens for push notifications. It avoids
locking you into a specific push provider (FCM/OneSignal/APNs) while giving
clear steps to integrate later.

1) Database: `device_tokens` table
- A lightweight table stores tokens you obtain from the device.
- See `docs/sql/create_device_tokens.sql` for a recommended schema and
  indexes. Run that SQL in your Supabase project's SQL editor.

Recommended columns:
- `id` (uuid primary key)
- `user_id` (uuid) — reference to auth.users.id
- `token` (text) — provider token (APNs/FCM/OneSignal)
- `platform` (text) — `ios`, `android`, or provider name
- `device_id` (text) — optional device identifier
- `last_seen_at` (timestamptz) — update when token is refreshed
- `created_at` (timestamptz)

2) Supabase security notes
- Use Row Level Security (RLS) policies to ensure only the authenticated
  user can insert/update their own tokens.
- Example policy (SQL):

  -- enable RLS
  ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

  -- allow authenticated users to upsert their tokens
  CREATE POLICY "Users can manage their tokens"
    ON public.device_tokens
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

3) App-side: persist tokens (provider-agnostic)
- When your chosen provider returns a device token, call the app's
  repository method `AuthRepository.upsertDeviceToken(...)` to persist it.
- The app already includes a `registerDeviceToken` method that writes a
  `lastDeviceToken` value to user metadata as a fallback, and the new
  `upsertDeviceToken` method inserts/upserts into the `device_tokens`
  table.

4) Token lifecycle
- When the app starts, refresh or request the token and call upsert.
- On logout, optionally remove the token from the table.
- On token refresh (provider SDK event), update the row's `last_seen_at`.

5) Sending notifications
- Build a server-side function or use a third-party service. Fetch tokens
  from `device_tokens` and send via the appropriate provider API.
- Avoid sending sensitive data in push payloads.

6) Testing
- Use real devices when testing APNs; Android emulators can receive FCM
  in many cases but real devices are more reliable.
- For early manual tests, call `registerDeviceToken` with a fake token and
  verify the row appears in the Supabase table.

7) Migration to provider-specific features
- When you pick a provider, add provider SDK initialization and token
  retrieval in the app. Keep the `device_tokens` table as the canonical
  store of tokens — this makes provider changes easier later.
