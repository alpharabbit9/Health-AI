-- ─────────────────────────────────────────────────────────────────────────────
-- HealthAI Admin Schema Migration
-- Run this in Supabase SQL Editor (Project → SQL Editor → New Query)
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Add role column to users ──────────────────────────────────────────────
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user';

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active';

-- Promote a user to admin (replace with your admin user's UUID)
-- UPDATE users SET role = 'admin' WHERE email = 'your-admin@example.com';

-- ── 1b. SECURITY DEFINER admin check ─────────────────────────────────────────
-- IMPORTANT: admin policies MUST use this function, never an inline
-- "EXISTS (SELECT ... FROM users)" — that recurses (Postgres error 42P17)
-- because the subquery re-triggers the same policy on the users table.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated;

-- ── 2. doctors table ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS doctors (
  id            UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  name          TEXT        NOT NULL,
  specialization TEXT       NOT NULL,
  hospital      TEXT,
  phone         TEXT,
  email         TEXT,
  address       TEXT,
  availability  TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS doctors_specialization_idx ON doctors (specialization);

-- ── 3. health_tips table ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS health_tips (
  id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT        NOT NULL,
  description TEXT        NOT NULL,
  category    TEXT        NOT NULL DEFAULT 'General',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS health_tips_category_idx ON health_tips (category);

-- ── 4. feedback table ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS feedback (
  id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  title      TEXT        NOT NULL,
  message    TEXT        NOT NULL,
  type       TEXT        NOT NULL DEFAULT 'feedback',  -- feedback | suggestion | bug
  status     TEXT        NOT NULL DEFAULT 'pending',   -- pending | resolved
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS feedback_user_id_idx ON feedback (user_id);
CREATE INDEX IF NOT EXISTS feedback_status_idx  ON feedback (status);

-- ── 5. RLS: users table ──────────────────────────────────────────────────────
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist before recreating
DROP POLICY IF EXISTS "Users can view own profile"         ON users;
DROP POLICY IF EXISTS "Users can insert own profile"         ON users;
DROP POLICY IF EXISTS "Users can update own profile"       ON users;
DROP POLICY IF EXISTS "Admins can view all users"          ON users;
DROP POLICY IF EXISTS "Admins can update all users"        ON users;

CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can update all users" ON users
  FOR UPDATE USING (public.is_admin());

-- ── 6. RLS: doctors table ────────────────────────────────────────────────────
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view doctors"   ON doctors;
DROP POLICY IF EXISTS "Admins manage doctors"     ON doctors;

CREATE POLICY "Anyone can view doctors" ON doctors
  FOR SELECT USING (true);

CREATE POLICY "Admins manage doctors" ON doctors
  FOR ALL USING (public.is_admin());

-- ── 7. RLS: health_tips table ────────────────────────────────────────────────
ALTER TABLE health_tips ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view health_tips"  ON health_tips;
DROP POLICY IF EXISTS "Admins manage health_tips"    ON health_tips;

CREATE POLICY "Anyone can view health_tips" ON health_tips
  FOR SELECT USING (true);

CREATE POLICY "Admins manage health_tips" ON health_tips
  FOR ALL USING (public.is_admin());

-- ── 8. RLS: feedback table ───────────────────────────────────────────────────
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can submit feedback"     ON feedback;
DROP POLICY IF EXISTS "Users can view own feedback"   ON feedback;
DROP POLICY IF EXISTS "Admins manage feedback"        ON feedback;

CREATE POLICY "Users can submit feedback" ON feedback
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own feedback" ON feedback
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins manage feedback" ON feedback
  FOR ALL USING (public.is_admin());

-- ── 9. RLS: symptom_analyses (admin view all) ────────────────────────────────
ALTER TABLE symptom_analyses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own analyses"  ON symptom_analyses;
DROP POLICY IF EXISTS "Users can insert analyses"    ON symptom_analyses;
DROP POLICY IF EXISTS "Users can delete analyses"    ON symptom_analyses;
DROP POLICY IF EXISTS "Admins can view all analyses" ON symptom_analyses;

CREATE POLICY "Users can view own analyses" ON symptom_analyses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert analyses" ON symptom_analyses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete analyses" ON symptom_analyses
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all analyses" ON symptom_analyses
  FOR SELECT USING (public.is_admin());
