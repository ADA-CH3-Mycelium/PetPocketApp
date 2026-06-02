-- ============================================================
-- PetPocket – Row Level Security (RLS) Policies
-- Run AFTER schema.sql
-- ============================================================

-- ──────────────────────────────────────────────
-- Helper: true if current user is an active sitter for a pet
-- ──────────────────────────────────────────────
CREATE OR REPLACE FUNCTION is_active_sitter(p_pet_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM pet_access
    WHERE pet_id    = p_pet_id
      AND sitter_id = auth.uid()
      AND is_active = true
      AND (end_date IS NULL OR end_date > now())
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ──────────────────────────────────────────────
-- Helper: true if current user owns a pet
-- ──────────────────────────────────────────────
CREATE OR REPLACE FUNCTION is_pet_owner(p_pet_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM pets
    WHERE id = p_pet_id AND owner_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ──────────────────────────────────────────────
-- PROFILES
-- ──────────────────────────────────────────────
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- Collaborators need to see each other's name/avatar in chat
CREATE POLICY "Collaborators can view each other profiles"
  ON profiles FOR SELECT
  USING (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM pet_access pa
      JOIN pets p ON p.id = pa.pet_id
      WHERE pa.is_active = true
        AND (p.owner_id = auth.uid() OR pa.sitter_id = auth.uid())
        AND (p.owner_id = profiles.id  OR pa.sitter_id = profiles.id)
    )
  );

-- ──────────────────────────────────────────────
-- PETS
-- ──────────────────────────────────────────────
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners have full access to their pets"
  ON pets FOR ALL USING (owner_id = auth.uid());

CREATE POLICY "Active sitters can view assigned pets"
  ON pets FOR SELECT USING (is_active_sitter(id));

-- ──────────────────────────────────────────────
-- DIETARY RESTRICTIONS
-- ──────────────────────────────────────────────
ALTER TABLE dietary_restrictions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner full access" ON dietary_restrictions FOR ALL USING (is_pet_owner(pet_id));
CREATE POLICY "Sitter read"       ON dietary_restrictions FOR SELECT USING (is_active_sitter(pet_id));

-- ──────────────────────────────────────────────
-- FEEDING MEALS
-- ──────────────────────────────────────────────
ALTER TABLE feeding_meals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner full access" ON feeding_meals FOR ALL USING (is_pet_owner(pet_id));
CREATE POLICY "Sitter read"       ON feeding_meals FOR SELECT USING (is_active_sitter(pet_id));

-- ──────────────────────────────────────────────
-- CARE ITEMS
-- ──────────────────────────────────────────────
ALTER TABLE care_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner full access" ON care_items FOR ALL USING (is_pet_owner(pet_id));
CREATE POLICY "Sitter read"       ON care_items FOR SELECT USING (is_active_sitter(pet_id));

-- ──────────────────────────────────────────────
-- EMERGENCY CONTACTS
-- ──────────────────────────────────────────────
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner full access" ON emergency_contacts FOR ALL USING (is_pet_owner(pet_id));
CREATE POLICY "Sitter read"       ON emergency_contacts FOR SELECT USING (is_active_sitter(pet_id));

-- ──────────────────────────────────────────────
-- VET CLINICS
-- ──────────────────────────────────────────────
ALTER TABLE vet_clinics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner full access" ON vet_clinics FOR ALL USING (is_pet_owner(pet_id));
CREATE POLICY "Sitter read"       ON vet_clinics FOR SELECT USING (is_active_sitter(pet_id));

-- ──────────────────────────────────────────────
-- ACCESS CODES
-- ──────────────────────────────────────────────
ALTER TABLE access_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner can manage codes for their pets"
  ON access_codes FOR ALL USING (is_pet_owner(pet_id));

-- Any authenticated user can look up a pending code to redeem it
CREATE POLICY "Authenticated users can look up a pending code"
  ON access_codes FOR SELECT
  USING (auth.uid() IS NOT NULL AND status = 'pending' AND expires_at > now());

-- ──────────────────────────────────────────────
-- PET ACCESS
-- ──────────────────────────────────────────────
ALTER TABLE pet_access ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners can manage access for their pets"
  ON pet_access FOR ALL USING (is_pet_owner(pet_id));

CREATE POLICY "Sitters can view their own access records"
  ON pet_access FOR SELECT USING (sitter_id = auth.uid());

-- ──────────────────────────────────────────────
-- CLARIFY THREADS
-- ──────────────────────────────────────────────
ALTER TABLE clarify_threads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner full access to threads"
  ON clarify_threads FOR ALL USING (is_pet_owner(pet_id));

CREATE POLICY "Sitter can view threads"
  ON clarify_threads FOR SELECT USING (is_active_sitter(pet_id));

CREATE POLICY "Sitter can create threads"
  ON clarify_threads FOR INSERT
  WITH CHECK (is_active_sitter(pet_id) AND auth.uid() = created_by);

-- ──────────────────────────────────────────────
-- CLARIFY MESSAGES
-- ──────────────────────────────────────────────
ALTER TABLE clarify_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Participants can read messages"
  ON clarify_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clarify_threads ct
      WHERE ct.id = thread_id
        AND (is_pet_owner(ct.pet_id) OR is_active_sitter(ct.pet_id))
    )
  );

CREATE POLICY "Participants can send messages"
  ON clarify_messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM clarify_threads ct
      WHERE ct.id = thread_id
        AND (is_pet_owner(ct.pet_id) OR is_active_sitter(ct.pet_id))
    )
  );

-- ──────────────────────────────────────────────
-- DEVICE TOKENS
-- ──────────────────────────────────────────────
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage only their own tokens"
  ON device_tokens FOR ALL USING (auth.uid() = user_id);

-- ──────────────────────────────────────────────
-- NOTIFICATION LOGS
-- ──────────────────────────────────────────────
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view notifications sent to them"
  ON notification_logs FOR SELECT USING (auth.uid() = receiver_id);

CREATE POLICY "Users can mark notifications read"
  ON notification_logs FOR UPDATE USING (auth.uid() = receiver_id);
