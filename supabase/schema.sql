-- ============================================================
-- PetPocket – Supabase Schema
-- Run this entire file in the Supabase SQL Editor
-- Order matters: tables referenced by FK must exist first
-- ============================================================

-- ──────────────────────────────────────────────
-- PROFILES  (extends Supabase Auth users)
-- Never store passwords here – Auth handles that
-- ──────────────────────────────────────────────
CREATE TABLE profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  photo_url  TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────
-- PETS
-- ──────────────────────────────────────────────
CREATE TABLE pets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  gender        TEXT CHECK (gender IN ('Male', 'Female')),
  date_of_birth DATE,                         -- use DOB, not age (age goes stale)
  breed         TEXT,
  species       TEXT,
  photo_url     TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────
-- DIETARY RESTRICTIONS
-- One row per item (allergy or restricted food)
-- ──────────────────────────────────────────────
CREATE TABLE dietary_restrictions (
  id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  type   TEXT NOT NULL CHECK (type IN ('allergy', 'restricted')),
  item   TEXT NOT NULL
);

-- ──────────────────────────────────────────────
-- FEEDING MEALS  (Food category)
-- ──────────────────────────────────────────────
CREATE TABLE feeding_meals (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  meal_name   TEXT NOT NULL,
  time        TEXT NOT NULL,        -- e.g. "8:00 AM"
  amount      TEXT NOT NULL,        -- e.g. "1 Cup Dry Kibble"
  notes       TEXT,
  icon_name   TEXT,                 -- SF Symbol name
  media_url   TEXT,                 -- Supabase Storage URL
  media_type  TEXT CHECK (media_type IN ('photo', 'video')),
  sort_order  INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────
-- CARE ITEMS  (Waste + Care Notes categories)
-- Covers cards, section titles, and quote items
-- ──────────────────────────────────────────────
CREATE TABLE care_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  category    TEXT NOT NULL CHECK (category IN ('waste', 'care', 'emergency')),
  item_type   TEXT NOT NULL CHECK (item_type IN ('card', 'section_title', 'quote')),
  title       TEXT,
  content     TEXT,
  icon        TEXT,                 -- SF Symbol name
  style       TEXT DEFAULT 'normal' CHECK (style IN ('normal', 'alert')),
  sort_order  INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────
-- EMERGENCY CONTACTS
-- ──────────────────────────────────────────────
CREATE TABLE emergency_contacts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  role        TEXT,                 -- e.g. "Has spare key"
  phone       TEXT,
  initial     CHAR(1),              -- for avatar display
  sort_order  INTEGER DEFAULT 0
);

-- ──────────────────────────────────────────────
-- VET CLINICS
-- ──────────────────────────────────────────────
CREATE TABLE vet_clinics (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  address     TEXT,
  phone       TEXT,
  latitude    DOUBLE PRECISION,
  longitude   DOUBLE PRECISION,
  is_primary  BOOLEAN DEFAULT false
);

-- ──────────────────────────────────────────────
-- ACCESS CODES  (6-digit invite codes for sitters)
-- ──────────────────────────────────────────────
CREATE TABLE access_codes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  created_by  UUID NOT NULL REFERENCES profiles(id),
  code        TEXT NOT NULL UNIQUE,
  expires_at  TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '48 hours'),
  used_at     TIMESTAMPTZ,
  used_by     UUID REFERENCES profiles(id),
  status      TEXT NOT NULL DEFAULT 'pending'
              CHECK (status IN ('pending', 'used', 'expired')),
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────
-- PET ACCESS  (active sitter <-> pet relationships)
-- Created when a sitter successfully redeems a code
-- ──────────────────────────────────────────────
CREATE TABLE pet_access (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id           UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  sitter_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  access_code_id   UUID REFERENCES access_codes(id),
  role             TEXT DEFAULT 'sitter' CHECK (role IN ('sitter', 'viewer')),
  start_date       TIMESTAMPTZ DEFAULT now(),
  end_date         TIMESTAMPTZ,
  is_active        BOOLEAN DEFAULT true,
  created_at       TIMESTAMPTZ DEFAULT now(),
  UNIQUE (pet_id, sitter_id)
);

-- ──────────────────────────────────────────────
-- CLARIFY THREADS  (chat context per pet+category)
-- ──────────────────────────────────────────────
CREATE TABLE clarify_threads (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  category    TEXT NOT NULL CHECK (category IN ('food', 'waste', 'care', 'emergency')),
  title       TEXT NOT NULL,
  created_by  UUID NOT NULL REFERENCES profiles(id),
  is_resolved BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────
-- CLARIFY MESSAGES  (individual chat messages)
-- Enable Realtime on this table for live chat
-- ──────────────────────────────────────────────
CREATE TABLE clarify_messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id   UUID NOT NULL REFERENCES clarify_threads(id) ON DELETE CASCADE,
  sender_id   UUID NOT NULL REFERENCES profiles(id),
  message     TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────
-- DEVICE TOKENS  (FCM tokens for push notifications)
-- One user can have multiple devices
-- ──────────────────────────────────────────────
CREATE TABLE device_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  fcm_token   TEXT NOT NULL,
  platform    TEXT DEFAULT 'ios' CHECK (platform IN ('ios', 'android')),
  device_name TEXT,                 -- e.g. "Naufal's iPhone 15"
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, fcm_token)
);

-- ──────────────────────────────────────────────
-- NOTIFICATION LOGS
-- ──────────────────────────────────────────────
CREATE TABLE notification_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      UUID REFERENCES pets(id),
  sender_id   UUID REFERENCES profiles(id),     -- who triggered it (NULL = system)
  receiver_id UUID NOT NULL REFERENCES profiles(id),
  type        TEXT NOT NULL,                    -- 'new_message' | 'meal_reminder' | 'access_granted' | 'emergency'
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  data        JSONB,                            -- custom payload for deep-linking
  sent_at     TIMESTAMPTZ DEFAULT now(),
  read_at     TIMESTAMPTZ                       -- NULL = unread
);

-- ──────────────────────────────────────────────
-- AUTO-UPDATE updated_at TRIGGER
-- ──────────────────────────────────────────────
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER trg_pets_updated_at
  BEFORE UPDATE ON pets
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER trg_feeding_meals_updated_at
  BEFORE UPDATE ON feeding_meals
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER trg_care_items_updated_at
  BEFORE UPDATE ON care_items
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER trg_clarify_threads_updated_at
  BEFORE UPDATE ON clarify_threads
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER trg_device_tokens_updated_at
  BEFORE UPDATE ON device_tokens
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- ──────────────────────────────────────────────
-- AUTO-CREATE PROFILE ON SIGN UP
-- Fires when a new user registers via Supabase Auth
-- ──────────────────────────────────────────────
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
