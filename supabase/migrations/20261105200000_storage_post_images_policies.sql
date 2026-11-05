-- Migration: Add missing RLS policies for post-images storage bucket
-- Enables public read and authenticated management for post images and event banners

-- 1. Ensure bucket post-images is public
UPDATE storage.buckets SET public = true WHERE id = 'post-images';

-- 2. Allow public SELECT on post-images bucket
DROP POLICY IF EXISTS "Public Access to post-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to post-images" ON storage.objects;
CREATE POLICY "Allow public read access to post-images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'post-images');

-- 3. Allow authenticated UPDATE on post-images bucket
DROP POLICY IF EXISTS "Allow authenticated update to post-images" ON storage.objects;
CREATE POLICY "Allow authenticated update to post-images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'post-images')
WITH CHECK (bucket_id = 'post-images');

-- 4. Allow authenticated DELETE on post-images bucket
DROP POLICY IF EXISTS "Allow authenticated delete to post-images" ON storage.objects;
CREATE POLICY "Allow authenticated delete to post-images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'post-images');
