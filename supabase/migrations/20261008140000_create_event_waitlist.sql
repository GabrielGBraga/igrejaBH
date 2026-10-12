-- Migration: Criar tabela event_waitlist para lista de espera automática de retiros e encontros
-- Issue #81: feat(eventos): lista de espera automática (waitlist) com mini-formulário após lotação

CREATE TABLE IF NOT EXISTS public.event_waitlist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  retreat_id uuid REFERENCES public.retreats(id) ON DELETE CASCADE NOT NULL,
  full_name text NOT NULL,
  cpf text,
  phone text NOT NULL,
  email text NOT NULL,
  city_state text,
  travel_mode text,
  notes text,
  status text DEFAULT 'aguardando' NOT NULL CHECK (status IN ('aguardando', 'chamado', 'inscrito', 'desistiu')),
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Índice para busca rápida ordenada cronologicamente por retiro
CREATE INDEX IF NOT EXISTS idx_event_waitlist_retreat_created 
ON public.event_waitlist (retreat_id, created_at ASC);

-- Habilitar Row Level Security (RLS)
ALTER TABLE public.event_waitlist ENABLE ROW LEVEL SECURITY;

-- 1. Qualquer pessoa (pública ou autenticada) pode entrar na lista de espera
CREATE POLICY "Permitir inserção na lista de espera para todos" 
ON public.event_waitlist
FOR INSERT 
WITH CHECK (true);

-- 2. Presbíteros, diáconos, liderança e devs podem visualizar a lista de espera
CREATE POLICY "Liderança e devs podem visualizar lista de espera" 
ON public.event_waitlist
FOR SELECT 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  ) OR EXISTS (
    SELECT 1 FROM public.home_groups
    WHERE home_groups.leader_1_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
    OR home_groups.leader_2_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
  )
);

-- 3. Presbíteros, diáconos, liderança e devs podem atualizar status da lista de espera
CREATE POLICY "Liderança e devs podem atualizar lista de espera" 
ON public.event_waitlist
FOR UPDATE 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  ) OR EXISTS (
    SELECT 1 FROM public.home_groups
    WHERE home_groups.leader_1_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
    OR home_groups.leader_2_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  ) OR EXISTS (
    SELECT 1 FROM public.home_groups
    WHERE home_groups.leader_1_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
    OR home_groups.leader_2_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
  )
);

-- 4. Presbíteros, diáconos e devs podem deletar registros da lista de espera
CREATE POLICY "Liderança e devs podem deletar da lista de espera" 
ON public.event_waitlist
FOR DELETE 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  )
);
