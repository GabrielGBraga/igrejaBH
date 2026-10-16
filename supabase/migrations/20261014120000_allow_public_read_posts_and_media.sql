-- Migration: Allow public (anon) read access to published posts, media resources, studies and study steps
-- This allows the dynamic landing page and Ensinos section to display published news, updates, teachings,
-- apostilas and articles to unauthenticated visitors seeking to know the community and learn freely.

-- 1. Policy for public.posts: Allow public anon read for published posts
DROP POLICY IF EXISTS "Allow anon read for published posts" ON public.posts;
CREATE POLICY "Allow anon read for published posts"
ON public.posts
FOR SELECT
TO anon
USING (is_published = true);

-- 2. Policy for public.media_resources: Allow public anon read for media resources
DROP POLICY IF EXISTS "Allow anon read for media_resources" ON public.media_resources;
CREATE POLICY "Allow anon read for media_resources"
ON public.media_resources
FOR SELECT
TO anon
USING (true);

-- 3. Policy for public.studies: Allow public anon read for studies
DROP POLICY IF EXISTS "Allow anon read for studies" ON public.studies;
CREATE POLICY "Allow anon read for studies"
ON public.studies
FOR SELECT
TO anon
USING (true);

-- 4. Policy for public.study_steps: Allow public anon read for study steps
DROP POLICY IF EXISTS "Allow anon read for study_steps" ON public.study_steps;
CREATE POLICY "Allow anon read for study_steps"
ON public.study_steps
FOR SELECT
TO anon
USING (true);

-- 5. Storage policy: Allow public anon read on ensinos bucket
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'ensinos') THEN
    UPDATE storage.buckets SET public = true WHERE id = 'ensinos';
  END IF;
END $$;

DROP POLICY IF EXISTS "Allow anon read on ensinos bucket" ON storage.objects;
CREATE POLICY "Allow anon read on ensinos bucket"
ON storage.objects
FOR SELECT
TO anon
USING (bucket_id = 'ensinos');
