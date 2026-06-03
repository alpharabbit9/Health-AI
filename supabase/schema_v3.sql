-- HealthAI Schema v3 — Extended User Profile
-- Run this in Supabase Dashboard → SQL Editor AFTER schema.sql

-- Add extra profile columns to the users table.
-- safe to re-run: ADD COLUMN IF NOT EXISTS never fails on second run.

alter table public.users
  add column if not exists phone               text,
  add column if not exists height_cm           numeric,
  add column if not exists weight_kg           numeric,
  add column if not exists blood_group         text,
  add column if not exists allergies           text[]  not null default '{}',
  add column if not exists chronic_conditions  text[]  not null default '{}',
  add column if not exists current_medications text[]  not null default '{}';

-- Grant update rights on the new columns (inherits from existing grant, but safe to re-run)
grant all on public.users to authenticated;
