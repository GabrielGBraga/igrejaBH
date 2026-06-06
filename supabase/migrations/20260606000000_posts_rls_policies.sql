-- Migration to configure Row Level Security (RLS) policies on public.posts
-- Created at: 2026-06-06 00:00:00 UTC

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Usuários autenticados podem ver postagens" ON public.posts;
DROP POLICY IF EXISTS "Allow SELECT on posts for author or published" ON public.posts;
DROP POLICY IF EXISTS "Allow INSERT on posts for authorized authors" ON public.posts;
DROP POLICY IF EXISTS "Allow UPDATE on posts for author or leadership" ON public.posts;
DROP POLICY IF EXISTS "Allow DELETE on posts for author or leadership" ON public.posts;

-- 1. SELECT Policy
-- Authenticated users can see posts if is_published = true OR if they are the author of the post.
CREATE POLICY "Allow SELECT on posts for author or published"
ON public.posts
FOR SELECT
TO authenticated
USING (
  is_published = true 
  OR 
  (EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = posts.author_id 
    AND profiles.user_id = auth.uid()
  ))
);

-- 2. INSERT Policy
-- Authenticated users whose profile has can_post = true OR is_presbyter = true OR is_deacon = true OR is_dev = true,
-- AND whose profile id matches posts.author_id.
CREATE POLICY "Allow INSERT on posts for authorized authors"
ON public.posts
FOR INSERT
TO authenticated
WITH CHECK (
  (EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = posts.author_id 
    AND profiles.user_id = auth.uid()
    AND (
      profiles.can_post = true 
      OR profiles.is_presbyter = true 
      OR profiles.is_deacon = true 
      OR profiles.is_dev = true
    )
  ))
);

-- 3. UPDATE Policy
-- Allow the author of the post OR leadership (devs/presbyters/deacons) to update the post.
CREATE POLICY "Allow UPDATE on posts for author or leadership"
ON public.posts
FOR UPDATE
TO authenticated
USING (
  (EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = posts.author_id 
    AND profiles.user_id = auth.uid()
  ))
  OR
  (EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  ))
)
WITH CHECK (
  (EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = posts.author_id 
    AND profiles.user_id = auth.uid()
  ))
  OR
  (EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  ))
);

-- 4. DELETE Policy
-- Allow the author of the post OR leadership (devs/presbyters/deacons) to delete the post.
CREATE POLICY "Allow DELETE on posts for author or leadership"
ON public.posts
FOR DELETE
TO authenticated
USING (
  (EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = posts.author_id 
    AND profiles.user_id = auth.uid()
  ))
  OR
  (EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  ))
);
