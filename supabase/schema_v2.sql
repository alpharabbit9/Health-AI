-- HealthAI Schema v2 — Symptom Analyses
-- Run this in Supabase Dashboard → SQL Editor

-- ─── symptom_analyses ────────────────────────────────────────
create table if not exists public.symptom_analyses (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  symptoms     text[]        not null default '{}',
  duration     text,
  severity     integer       check (severity >= 1 and severity <= 10),
  personal_data jsonb        default '{}',
  ai_response  jsonb         default '{}',
  risk_level   text          check (risk_level in ('low', 'moderate', 'high')),
  created_at   timestamptz   not null default now()
);

-- Enable RLS
alter table public.symptom_analyses enable row level security;

-- Policies
create policy "analyses_select_own"
  on public.symptom_analyses for select
  using (auth.uid() = user_id);

create policy "analyses_insert_own"
  on public.symptom_analyses for insert
  with check (auth.uid() = user_id);

create policy "analyses_delete_own"
  on public.symptom_analyses for delete
  using (auth.uid() = user_id);

-- Index for fast per-user history queries
create index if not exists idx_analyses_user_created
  on public.symptom_analyses(user_id, created_at desc);

-- Grants
grant usage on schema public to anon, authenticated;
grant select, insert, delete on public.symptom_analyses to authenticated;

-- ─── Storage: avatars bucket ──────────────────────────────────
-- Run this block AFTER enabling Storage in your Supabase project.

insert into storage.buckets (id, name, public)
  values ('avatars', 'avatars', true)
  on conflict (id) do nothing;

-- Anyone can view avatar images (public bucket).
create policy "avatars_public_read"
  on storage.objects for select
  using (bucket_id = 'avatars');

-- Users may upload only to their own folder ({userId}/avatar.*).
create policy "avatars_own_insert"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users may replace their own avatar.
create policy "avatars_own_update"
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users may delete their own avatar.
create policy "avatars_own_delete"
  on storage.objects for delete
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
