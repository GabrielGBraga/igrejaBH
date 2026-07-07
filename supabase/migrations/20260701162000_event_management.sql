-- Adiciona novas colunas à tabela retreats para suporte a descrição, capacidade, local e formulários customizados
ALTER TABLE public.retreats 
ADD COLUMN IF NOT EXISTS description text,
ADD COLUMN IF NOT EXISTS location_text text,
ADD COLUMN IF NOT EXISTS max_participants integer DEFAULT 100,
ADD COLUMN IF NOT EXISTS status text DEFAULT 'ativo',
ADD COLUMN IF NOT EXISTS image_url text,
ADD COLUMN IF NOT EXISTS form_id text REFERENCES public.forms(id) ON DELETE SET NULL;

-- Adiciona novas colunas à tabela registrations para logística de quartos e financeiro
ALTER TABLE public.registrations
ADD COLUMN IF NOT EXISTS room_allocation text,
ADD COLUMN IF NOT EXISTS payment_method text DEFAULT 'pix',
ADD COLUMN IF NOT EXISTS payment_reference text,
ADD COLUMN IF NOT EXISTS notes text;

-- Cria políticas RLS de administração para a tabela retreats
CREATE POLICY "Presbíteros e devs podem gerenciar retiros" ON public.retreats
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true)
  )
);

-- Cria políticas RLS de administração para a tabela registrations
CREATE POLICY "Presbíteros, deacons e liderança podem ver todas as inscrições" ON public.registrations
FOR SELECT TO authenticated
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

CREATE POLICY "Presbíteros, deacons e liderança podem atualizar todas as inscrições" ON public.registrations
FOR UPDATE TO authenticated
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

CREATE POLICY "Presbíteros, deacons e liderança podem deletar inscrições" ON public.registrations
FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  )
);

-- Adiciona coluna is_active na tabela de formulários
ALTER TABLE public.forms ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT true;

-- Adiciona coluna registration_deadline na tabela de retiros
ALTER TABLE public.retreats ADD COLUMN IF NOT EXISTS registration_deadline date;

-- Permite que qualquer usuário (autenticado ou anônimo) crie inscrições
CREATE POLICY "Permitir inserção de inscrições para todos" ON public.registrations FOR INSERT WITH CHECK (true);
