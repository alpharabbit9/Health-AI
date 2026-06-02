-- ============================================================
-- HealthAI — Run this in your Supabase SQL Editor
-- Dashboard → SQL Editor → New query → paste → Run
-- ============================================================

-- ─── 1. Users table ──────────────────────────────────────
create table if not exists public.users (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  full_name   text,
  age         integer check (age >= 1 and age <= 120),
  gender      text check (gender in ('Male', 'Female', 'Other')),
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ─── 2. Row-Level Security ───────────────────────────────
alter table public.users enable row level security;

-- Users can read their own row
create policy "users_select_own"
  on public.users for select
  using (auth.uid() = id);

-- Users can insert their own row (used by client after signup)
create policy "users_insert_own"
  on public.users for insert
  with check (auth.uid() = id);

-- Users can update their own row
create policy "users_update_own"
  on public.users for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ─── 3. Auto-update updated_at ───────────────────────────
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger users_set_updated_at
  before update on public.users
  for each row execute function public.set_updated_at();

-- ─── 4. Trigger: auto-create profile on auth signup ──────
-- This ensures a profile row always exists even if the client
-- call fails (belt-and-suspenders with the client-side insert).
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
  on conflict (id) do nothing; -- safe to re-run; client insert wins if it arrives first
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

-- ─── 5. Grant permissions ────────────────────────────────
grant usage on schema public to anon, authenticated;
grant all on public.users to authenticated;
