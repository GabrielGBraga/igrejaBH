-- Migration: Centralize and remodel posts (news, announcements, casual encounters, and linked updates)
-- Drops the old posts table and creates a unified, performant news system.

-- 1. Drop existing posts and post_category
DROP TABLE IF EXISTS public.posts CASCADE;
DROP TYPE IF EXISTS public.post_category CASCADE;

-- 2. Create post_category enum
CREATE TYPE public.post_category AS ENUM (
  'geral',
  'oracao',
  'missoes',
  'encontro',
  'estudo',
  'formulario',
  'evento'
);

-- 3. Create posts table
CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category public.post_category NOT NULL DEFAULT 'geral',
  is_public BOOLEAN NOT NULL DEFAULT false,
  is_published BOOLEAN NOT NULL DEFAULT true,
  author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  image_urls TEXT[] DEFAULT NULL,
  
  -- Encontros casuais e reuniões periódicas da igreja na cidade
  event_start_date TIMESTAMPTZ DEFAULT NULL,
  event_end_date TIMESTAMPTZ DEFAULT NULL,
  event_location TEXT DEFAULT NULL,

  -- Vínculos explícitos opcionais
  media_resource_id UUID REFERENCES public.media_resources(id) ON DELETE CASCADE,
  form_id TEXT REFERENCES public.forms(id) ON DELETE CASCADE,
  retreat_id UUID REFERENCES public.retreats(id) ON DELETE CASCADE,
  event_label TEXT DEFAULT NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT check_single_relation CHECK (
    num_nonnulls(media_resource_id, form_id, retreat_id) <= 1
  )
);

-- 4. Create Indexes for High Performance
CREATE INDEX idx_posts_published_public_created ON public.posts (is_published, is_public, created_at DESC);
CREATE INDEX idx_posts_event_start_date ON public.posts (event_start_date) WHERE event_start_date IS NOT NULL;
CREATE INDEX idx_posts_category ON public.posts (category);
CREATE INDEX idx_posts_media_resource_id ON public.posts (media_resource_id) WHERE media_resource_id IS NOT NULL;
CREATE INDEX idx_posts_form_id ON public.posts (form_id) WHERE form_id IS NOT NULL;
CREATE INDEX idx_posts_retreat_id ON public.posts (retreat_id) WHERE retreat_id IS NOT NULL;
CREATE INDEX idx_posts_author_id ON public.posts (author_id) WHERE author_id IS NOT NULL;

-- 5. Enable RLS
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- 6. Permissions / Grants
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.posts TO authenticated;
GRANT SELECT ON TABLE public.posts TO anon;

-- 7. RLS Policies
CREATE POLICY "Allow public read for public published posts"
ON public.posts
FOR SELECT
TO anon
USING (is_published = true AND is_public = true);

CREATE POLICY "Allow authenticated read for posts"
ON public.posts
FOR SELECT
TO authenticated
USING (
  (is_published = true AND is_public = true)
  OR
  (
    is_published = true AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.user_id = (SELECT auth.uid())
        AND profiles.is_church_linked = true
    )
  )
  OR
  (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = posts.author_id
        AND profiles.user_id = (SELECT auth.uid())
    )
  )
  OR
  (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.user_id = (SELECT auth.uid())
        AND (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
    )
  )
);

CREATE POLICY "Allow authorized users to insert posts"
ON public.posts
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = (SELECT auth.uid())
      AND (
        profiles.can_post = true 
        OR profiles.is_presbyter = true 
        OR profiles.is_deacon = true 
        OR profiles.is_dev = true
      )
  )
);

CREATE POLICY "Allow authors and leaders to update posts"
ON public.posts
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = (SELECT auth.uid())
      AND (
        profiles.id = posts.author_id
        OR profiles.is_presbyter = true
        OR profiles.is_deacon = true
        OR profiles.is_dev = true
      )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = (SELECT auth.uid())
      AND (
        profiles.id = posts.author_id
        OR profiles.is_presbyter = true
        OR profiles.is_deacon = true
        OR profiles.is_dev = true
      )
  )
);

CREATE POLICY "Allow authors and leaders to delete posts"
ON public.posts
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = (SELECT auth.uid())
      AND (
        profiles.id = posts.author_id
        OR profiles.is_presbyter = true
        OR profiles.is_deacon = true
        OR profiles.is_dev = true
      )
  )
);
