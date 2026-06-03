-- ================================================================
-- HealthAI — COMPLETE SETUP (run this once in Supabase SQL Editor)
-- Dashboard → SQL Editor → New query → paste everything → Run
-- Safe to re-run: every statement uses IF NOT EXISTS / ON CONFLICT DO NOTHING
-- ================================================================

-- ────────────────────────────────────────────────────────────────
-- 1. USERS TABLE
-- ────────────────────────────────────────────────────────────────

create table if not exists public.users (
  id                   uuid primary key references auth.users(id) on delete cascade,
  email                text not null,
  full_name            text,
  age                  integer check (age >= 1 and age <= 120),
  gender               text check (gender in ('Male', 'Female', 'Other')),
  avatar_url           text,
  -- Extended profile fields (added in v3)
  phone                text,
  height_cm            numeric,
  weight_kg            numeric,
  blood_group          text,
  allergies            text[] not null default '{}',
  chronic_conditions   text[] not null default '{}',
  current_medications  text[] not null default '{}',
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- Add extended columns to existing tables (safe if already present)
alter table public.users add column if not exists phone               text;
alter table public.users add column if not exists height_cm           numeric;
alter table public.users add column if not exists weight_kg           numeric;
alter table public.users add column if not exists blood_group         text;
alter table public.users add column if not exists allergies           text[] not null default '{}';
alter table public.users add column if not exists chronic_conditions  text[] not null default '{}';
alter table public.users add column if not exists current_medications text[] not null default '{}';

-- ────────────────────────────────────────────────────────────────
-- 2. USERS RLS
-- ────────────────────────────────────────────────────────────────

alter table public.users enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'users' and policyname = 'users_select_own'
  ) then
    create policy "users_select_own" on public.users for select using (auth.uid() = id);
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'users' and policyname = 'users_insert_own'
  ) then
    create policy "users_insert_own" on public.users for insert with check (auth.uid() = id);
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'users' and policyname = 'users_update_own'
  ) then
    create policy "users_update_own" on public.users for update
      using (auth.uid() = id) with check (auth.uid() = id);
  end if;
end $$;

-- ────────────────────────────────────────────────────────────────
-- 3. AUTO-UPDATE updated_at TRIGGER
-- ────────────────────────────────────────────────────────────────

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at
  before update on public.users
  for each row execute function public.set_updated_at();

-- ────────────────────────────────────────────────────────────────
-- 4. AUTO-CREATE PROFILE ON AUTH SIGNUP TRIGGER
-- ────────────────────────────────────────────────────────────────

create or replace function public.handle_new_auth_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.users (id, email, full_name, age, gender)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'full_name',
    (new.raw_user_meta_data ->> 'age')::integer,
    new.raw_user_meta_data ->> 'gender'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

-- ────────────────────────────────────────────────────────────────
-- 5. SYMPTOM ANALYSES TABLE
-- ────────────────────────────────────────────────────────────────

create table if not exists public.symptom_analyses (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  symptoms      text[]      not null default '{}',
  duration      text,
  severity      integer     check (severity >= 1 and severity <= 10),
  personal_data jsonb       default '{}',
  ai_response   jsonb       default '{}',
  risk_level    text        check (risk_level in ('low', 'moderate', 'high')),
  created_at    timestamptz not null default now()
);

alter table public.symptom_analyses enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'symptom_analyses' and policyname = 'analyses_select_own'
  ) then
    create policy "analyses_select_own" on public.symptom_analyses for select using (auth.uid() = user_id);
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'symptom_analyses' and policyname = 'analyses_insert_own'
  ) then
    create policy "analyses_insert_own" on public.symptom_analyses for insert with check (auth.uid() = user_id);
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'symptom_analyses' and policyname = 'analyses_delete_own'
  ) then
    create policy "analyses_delete_own" on public.symptom_analyses for delete using (auth.uid() = user_id);
  end if;
end $$;

create index if not exists idx_analyses_user_created
  on public.symptom_analyses(user_id, created_at desc);

-- ────────────────────────────────────────────────────────────────
-- 6. STORAGE: avatars bucket + policies
-- ────────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
  values ('avatars', 'avatars', true)
  on conflict (id) do nothing;

-- Drop existing storage policies before re-creating (idempotent)
drop policy if exists "avatars_public_read"  on storage.objects;
drop policy if exists "avatars_own_insert"   on storage.objects;
drop policy if exists "avatars_own_update"   on storage.objects;
drop policy if exists "avatars_own_delete"   on storage.objects;

-- Anyone can view avatar images (public bucket)
create policy "avatars_public_read"
  on storage.objects for select
  using (bucket_id = 'avatars');

-- Authenticated users may only write to their own folder: {userId}/avatar.*
create policy "avatars_own_insert"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create policy "avatars_own_update"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'avatars'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create policy "avatars_own_delete"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'avatars'
    and split_part(name, '/', 1) = auth.uid()::text
  );

-- ────────────────────────────────────────────────────────────────
-- 7. GRANTS
-- ────────────────────────────────────────────────────────────────

grant usage on schema public to anon, authenticated;
grant all on public.users to authenticated;
grant select, insert, delete on public.symptom_analyses to authenticated;
