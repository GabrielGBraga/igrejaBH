-- Criar tabela de anotações de estudos e materiais
CREATE TABLE IF NOT EXISTS public.study_notes (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    study_id uuid REFERENCES public.studies(id) ON DELETE CASCADE,
    media_resource_id uuid REFERENCES public.media_resources(id) ON DELETE CASCADE,
    title text NOT NULL DEFAULT '',
    content text NOT NULL DEFAULT '',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CONSTRAINT chk_study_notes_target CHECK (study_id IS NOT NULL OR media_resource_id IS NOT NULL)
);

-- Ativar Row Level Security (RLS)
ALTER TABLE public.study_notes ENABLE ROW LEVEL SECURITY;

-- Índices parciais para garantir unicidade:
-- 1 anotação por estudo por discípulo
CREATE UNIQUE INDEX IF NOT EXISTS study_notes_profile_study_idx 
ON public.study_notes (profile_id, study_id) 
WHERE study_id IS NOT NULL AND media_resource_id IS NULL;

-- 1 anotação por material de mídia por discípulo
CREATE UNIQUE INDEX IF NOT EXISTS study_notes_profile_media_idx 
ON public.study_notes (profile_id, media_resource_id) 
WHERE media_resource_id IS NOT NULL;

-- Políticas RLS (estritamente privado para o discípulo autor da anotação)
DROP POLICY IF EXISTS "Usuários podem ver suas próprias anotações" ON public.study_notes;
DROP POLICY IF EXISTS "Usuários podem criar suas próprias anotações" ON public.study_notes;
DROP POLICY IF EXISTS "Usuários podem atualizar suas próprias anotações" ON public.study_notes;
DROP POLICY IF EXISTS "Usuários podem excluir suas próprias anotações" ON public.study_notes;

CREATE POLICY "Usuários podem ver suas próprias anotações"
ON public.study_notes FOR SELECT TO authenticated
USING (
    profile_id IN (
        SELECT id FROM public.profiles WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Usuários podem criar suas próprias anotações"
ON public.study_notes FOR INSERT TO authenticated
WITH CHECK (
    profile_id IN (
        SELECT id FROM public.profiles WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Usuários podem atualizar suas próprias anotações"
ON public.study_notes FOR UPDATE TO authenticated
USING (
    profile_id IN (
        SELECT id FROM public.profiles WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    profile_id IN (
        SELECT id FROM public.profiles WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Usuários podem excluir suas próprias anotações"
ON public.study_notes FOR DELETE TO authenticated
USING (
    profile_id IN (
        SELECT id FROM public.profiles WHERE user_id = auth.uid()
    )
);
