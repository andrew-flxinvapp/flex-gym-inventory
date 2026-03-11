-- SQL for Supabase: create a provider-agnostic device_tokens table
-- Run this in your Supabase SQL editor

CREATE TABLE IF NOT EXISTS public.device_tokens (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL,
  token text NOT NULL,
  platform text NOT NULL,
  device_id text,
  last_seen_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Unique constraint to avoid duplicate token rows for same user
CREATE UNIQUE INDEX IF NOT EXISTS device_tokens_user_token_idx
  ON public.device_tokens (user_id, token);

-- Useful index for queries by user
CREATE INDEX IF NOT EXISTS device_tokens_user_idx
  ON public.device_tokens (user_id);
