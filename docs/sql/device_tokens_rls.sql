-- Supabase-ready SQL: enable RLS and add policies for `device_tokens`
-- Run this in your Supabase project's SQL editor.

-- 1) Ensure RLS is enabled (safe to run repeatedly)
ALTER TABLE IF EXISTS public.device_tokens ENABLE ROW LEVEL SECURITY;

-- 2) Deny public access explicitly (optional but explicit)
REVOKE ALL ON public.device_tokens FROM public;

-- 3) Policy: allow authenticated users to SELECT/INSERT/UPDATE/DELETE
--    only rows where auth.uid() == user_id
CREATE POLICY IF NOT EXISTS "Users can manage their tokens"
  ON public.device_tokens
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 4) Notes:
-- - Supabase "service_role" key bypasses RLS and can be used by trusted
--   server-side code to send pushes.
-- - If you have serverless functions that should act as users, call them
--   with the authenticated user's JWT so they run under that user's
--   identity and the policy applies.
-- - To test locally, insert a row with a known user_id (use your auth user's
--   id). When using the SQL editor in Supabase (server-side), you can run
--   as a superuser or service role to seed test data.

-- Optional: make sure there's a safe upsert function for clients that don't
-- want to rely on `.upsert()` client-side semantics. Example (server-side):
-- CREATE OR REPLACE FUNCTION public.upsert_device_token(
--   p_user_id uuid, p_token text, p_platform text, p_device_id text DEFAULT NULL)
-- RETURNS void LANGUAGE sql AS $$
-- INSERT INTO public.device_tokens (user_id, token, platform, device_id, last_seen_at)
-- VALUES (p_user_id, p_token, p_platform, p_device_id, now())
-- ON CONFLICT (user_id, token) DO UPDATE SET last_seen_at = EXCLUDED.last_seen_at;
-- $$;

-- End of file
