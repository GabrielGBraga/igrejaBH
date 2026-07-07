-- Create media_type enum if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'media_type') THEN
        CREATE TYPE public.media_type AS ENUM ('video', 'pdf', 'markdown');
    END IF;
END$$;

-- Create media_resources table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.media_resources (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title text NOT NULL,
    description text,
    type public.media_type NOT NULL,
    url text NOT NULL,
    series_name text,
    category text,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS for media_resources
ALTER TABLE public.media_resources ENABLE ROW LEVEL SECURITY;

-- Recreate policies for media_resources to be safe
DROP POLICY IF EXISTS "Usuários autenticados podem ver recursos de mídia" ON public.media_resources;
DROP POLICY IF EXISTS "Permitir leitura para todos autenticados" ON public.media_resources;
DROP POLICY IF EXISTS "Permitir inserção para liderança" ON public.media_resources;
DROP POLICY IF EXISTS "Permitir delete para liderança" ON public.media_resources;

CREATE POLICY "Usuários autenticados podem ver recursos de mídia" ON public.media_resources FOR SELECT TO authenticated USING (true);
CREATE POLICY "Permitir leitura para todos autenticados" ON public.media_resources FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Permitir inserção para liderança" ON public.media_resources FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE profiles.user_id = auth.uid() AND (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)));
CREATE POLICY "Permitir delete para liderança" ON public.media_resources FOR DELETE USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.user_id = auth.uid() AND (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)));

-- Create ensinos storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('ensinos', 'ensinos', true)
ON CONFLICT (id) DO NOTHING;

-- Ensinos storage policies
DROP POLICY IF EXISTS "Allow read access to ensinos bucket for authenticated users" ON storage.objects;
DROP POLICY IF EXISTS "Allow leadership to manage objects in ensinos bucket" ON storage.objects;

CREATE POLICY "Allow read access to ensinos bucket for authenticated users"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'ensinos');

CREATE POLICY "Allow leadership to manage objects in ensinos bucket"
ON storage.objects FOR ALL TO authenticated
USING (
  bucket_id = 'ensinos' AND
  (EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid() AND
          (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  ))
)
WITH CHECK (
  bucket_id = 'ensinos' AND
  (EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid() AND
          (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  ))
);

-- Studies (Estudos) Table
CREATE TABLE IF NOT EXISTS public.studies (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title text NOT NULL,
    description text,
    created_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Enable RLS for studies
ALTER TABLE public.studies ENABLE ROW LEVEL SECURITY;

-- Policies for studies
DROP POLICY IF EXISTS "Allow authenticated users to read studies" ON public.studies;
DROP POLICY IF EXISTS "Allow leadership to manage studies" ON public.studies;

CREATE POLICY "Allow authenticated users to read studies"
ON public.studies FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Allow leadership to manage studies"
ON public.studies FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid() AND
          (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid() AND
          (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  )
);

-- Study Steps (Etapas dos Estudos) Table
CREATE TABLE IF NOT EXISTS public.study_steps (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    study_id uuid NOT NULL REFERENCES public.studies(id) ON DELETE CASCADE,
    media_resource_id uuid NOT NULL REFERENCES public.media_resources(id) ON DELETE CASCADE,
    sort_order integer NOT NULL,
    created_at timestamptz DEFAULT now(),
    CONSTRAINT study_steps_study_id_sort_order_key UNIQUE (study_id, sort_order),
    CONSTRAINT study_steps_study_id_media_resource_id_key UNIQUE (study_id, media_resource_id)
);

-- Enable RLS for study_steps
ALTER TABLE public.study_steps ENABLE ROW LEVEL SECURITY;

-- Policies for study_steps
DROP POLICY IF EXISTS "Allow authenticated users to read study steps" ON public.study_steps;
DROP POLICY IF EXISTS "Allow leadership to manage study steps" ON public.study_steps;

CREATE POLICY "Allow authenticated users to read study steps"
ON public.study_steps FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Allow leadership to manage study steps"
ON public.study_steps FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid() AND
          (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid() AND
          (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)
  )
);

-- User Study Progress (Progresso do Usuário nos Estudos) Table
CREATE TABLE IF NOT EXISTS public.user_study_progress (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    study_id uuid NOT NULL REFERENCES public.studies(id) ON DELETE CASCADE,
    step_id uuid NOT NULL REFERENCES public.study_steps(id) ON DELETE CASCADE,
    completed_at timestamptz DEFAULT now(),
    CONSTRAINT user_study_progress_profile_id_step_id_key UNIQUE (profile_id, step_id)
);

-- Enable RLS for user_study_progress
ALTER TABLE public.user_study_progress ENABLE ROW LEVEL SECURITY;

-- Policies for user_study_progress
DROP POLICY IF EXISTS "Allow users to read their own progress" ON public.user_study_progress;
DROP POLICY IF EXISTS "Allow users to insert their own progress" ON public.user_study_progress;
DROP POLICY IF EXISTS "Allow users to delete their own progress" ON public.user_study_progress;

CREATE POLICY "Allow users to read their own progress"
ON public.user_study_progress FOR SELECT TO authenticated
USING (
  profile_id IN (
    SELECT id FROM public.profiles WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Allow users to insert their own progress"
ON public.user_study_progress FOR INSERT TO authenticated
WITH CHECK (
  profile_id IN (
    SELECT id FROM public.profiles WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Allow users to delete their own progress"
ON public.user_study_progress FOR DELETE TO authenticated
USING (
  profile_id IN (
    SELECT id FROM public.profiles WHERE user_id = auth.uid()
  )
);
