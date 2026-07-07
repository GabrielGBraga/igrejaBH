-- Migration to create forms and form submissions tables
-- Created at: 2026-06-26 00:00:00 UTC

-- 1. Create public.forms table
CREATE TABLE IF NOT EXISTS public.forms (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  fields JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  is_public BOOLEAN DEFAULT false NOT NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Enable RLS on forms
ALTER TABLE public.forms ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Allow SELECT on forms for everyone if public, or authenticated" ON public.forms;
DROP POLICY IF EXISTS "Allow ALL on forms for leadership" ON public.forms;

-- forms SELECT policy: Anyone can select public forms, authenticated users can select all forms
CREATE POLICY "Allow SELECT on forms for everyone if public, or authenticated"
ON public.forms
FOR SELECT
USING (
  is_public = true
  OR
  auth.role() = 'authenticated'
);

-- forms ALL policy: Only leadership (is_dev, is_presbyter, can_post) can insert, update, delete
CREATE POLICY "Allow ALL on forms for leadership"
ON public.forms
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid()
    AND (
      profiles.is_dev = true
      OR profiles.is_presbyter = true
      OR profiles.can_post = true
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid()
    AND (
      profiles.is_dev = true
      OR profiles.is_presbyter = true
      OR profiles.can_post = true
    )
  )
);


-- 2. Create public.form_submissions table
CREATE TABLE IF NOT EXISTS public.form_submissions (
  id TEXT PRIMARY KEY,
  form_id TEXT REFERENCES public.forms(id) ON DELETE CASCADE NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  data JSONB NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Enable RLS on form_submissions
ALTER TABLE public.form_submissions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Allow INSERT on submissions if form is public or user is authenticated" ON public.form_submissions;
DROP POLICY IF EXISTS "Allow SELECT on submissions for leadership" ON public.form_submissions;
DROP POLICY IF EXISTS "Allow UPDATE/DELETE on submissions for leadership" ON public.form_submissions;

-- form_submissions INSERT policy: Anyone can submit to public forms, only authenticated users can submit to private forms
CREATE POLICY "Allow INSERT on submissions if form is public or user is authenticated"
ON public.form_submissions
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.forms
    WHERE forms.id = form_submissions.form_id
    AND (
      forms.is_public = true
      OR
      (auth.role() = 'authenticated' AND (form_submissions.user_id = auth.uid() OR form_submissions.user_id IS NULL))
    )
  )
);

-- form_submissions SELECT policy: Only leadership can view submissions
CREATE POLICY "Allow SELECT on submissions for leadership"
ON public.form_submissions
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND (
      profiles.is_dev = true
      OR profiles.is_presbyter = true
      OR profiles.can_post = true
    )
  )
);

-- form_submissions UPDATE/DELETE policy: Only leadership can modify submissions
CREATE POLICY "Allow UPDATE/DELETE on submissions for leadership"
ON public.form_submissions
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND (
      profiles.is_dev = true
      OR profiles.is_presbyter = true
      OR profiles.can_post = true
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND (
      profiles.is_dev = true
      OR profiles.is_presbyter = true
      OR profiles.can_post = true
    )
  )
);
