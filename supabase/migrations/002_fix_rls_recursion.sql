-- ─────────────────────────────────────────────────────────────────────────────
-- HealthAI — Fix RLS infinite recursion + ensure profile columns
-- Run this ONCE in Supabase SQL Editor (Project → SQL Editor → New Query).
--
-- WHY: 001_admin_schema.sql created admin policies that do
--        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
--      directly inside a policy ON the users table. Evaluating that subquery
--      re-triggers the same policy → Postgres aborts with
--        42P17: infinite recursion detected in policy for relation "users"
--      which makes EVERY read/write on users (and any table whose policy
--      references users) fail. That is why the admin role can't be read back
--      after login and why profile data won't save.
--
-- FIX: move the admin check into a SECURITY DEFINER function. It runs as the
--      function owner and therefore BYPASSES RLS, so there is no recursion.
-- Safe to re-run.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. SECURITY DEFINER admin check (no recursion) ───────────────────────────
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated;

-- ── 2. Ensure role/status + extended profile columns exist ───────────────────
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS role   TEXT NOT NULL DEFAULT 'user';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS phone               text;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS height_cm           numeric;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS weight_kg           numeric;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS blood_group         text;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS allergies           text[] NOT NULL DEFAULT '{}';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS chronic_conditions  text[] NOT NULL DEFAULT '{}';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS current_medications text[] NOT NULL DEFAULT '{}';

-- ── 3. users — recreate policies without recursion ───────────────────────────
DROP POLICY IF EXISTS "Admins can view all users"   ON public.users;
DROP POLICY IF EXISTS "Admins can update all users" ON public.users;
DROP POLICY IF EXISTS "Admins can delete users"     ON public.users;

CREATE POLICY "Admins can view all users" ON public.users
  FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can update all users" ON public.users
  FOR UPDATE USING (public.is_admin());

CREATE POLICY "Admins can delete users" ON public.users
  FOR DELETE USING (public.is_admin());

-- ── 4. doctors ───────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Admins manage doctors" ON public.doctors;
CREATE POLICY "Admins manage doctors" ON public.doctors
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ── 5. health_tips ───────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Admins manage health_tips" ON public.health_tips;
CREATE POLICY "Admins manage health_tips" ON public.health_tips
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ── 6. feedback ──────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Admins manage feedback" ON public.feedback;
CREATE POLICY "Admins manage feedback" ON public.feedback
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ── 7. symptom_analyses ──────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Admins can view all analyses" ON public.symptom_analyses;
CREATE POLICY "Admins can view all analyses" ON public.symptom_analyses
  FOR SELECT USING (public.is_admin());

-- ── 8. Promote your admin user(s) — EDIT the email then uncomment ────────────
-- UPDATE public.users SET role = 'admin' WHERE email = 'your-admin@example.com';
