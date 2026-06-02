-- ============================================================
-- PetPocket – Storage Buckets
-- Run in Supabase SQL Editor AFTER schema.sql + rls.sql
-- ============================================================

-- Private bucket: feeding photos/videos, care media
INSERT INTO storage.buckets (id, name, public)
VALUES ('pet-media', 'pet-media', false);

-- Public bucket: pet avatar thumbnails (faster, no signed URLs needed)
INSERT INTO storage.buckets (id, name, public)
VALUES ('pet-avatars', 'pet-avatars', true);

-- ──────────────────────────────────────────────
-- pet-media RLS (private)
-- Files are stored as: {owner_id}/{pet_id}/{filename}
-- ──────────────────────────────────────────────

CREATE POLICY "Owners can manage their pet media"
ON storage.objects FOR ALL
USING (
  bucket_id = 'pet-media'
  AND auth.uid()::TEXT = (storage.foldername(name))[1]
);

CREATE POLICY "Active sitters can view pet media"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'pet-media'
  AND EXISTS (
    SELECT 1 FROM pets p
    JOIN pet_access pa ON pa.pet_id = p.id
    WHERE pa.sitter_id = auth.uid()
      AND pa.is_active  = true
      AND p.owner_id::TEXT = (storage.foldername(name))[1]
  )
);

-- ──────────────────────────────────────────────
-- pet-avatars RLS (public read)
-- Files stored as: {owner_id}/{pet_id}/avatar
-- ──────────────────────────────────────────────

CREATE POLICY "Anyone can view pet avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'pet-avatars');

CREATE POLICY "Owners can upload their pet avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'pet-avatars'
  AND auth.uid()::TEXT = (storage.foldername(name))[1]
);

CREATE POLICY "Owners can update their pet avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'pet-avatars'
  AND auth.uid()::TEXT = (storage.foldername(name))[1]
);
