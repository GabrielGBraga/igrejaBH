-- Migration: Add status, cancellation_reason and cancelled_at to registrations table
-- Issue #80: feat(eventos): novos status de inscrição (confirmado, presente, cancelado) e histórico de cancelamento

-- 1. Add status column with check constraint and default
ALTER TABLE public.registrations
ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'confirmado'
CHECK (status IN ('confirmado', 'presente', 'cancelado'));

-- 2. Add cancellation tracking columns
ALTER TABLE public.registrations
ADD COLUMN IF NOT EXISTS cancellation_reason text;

ALTER TABLE public.registrations
ADD COLUMN IF NOT EXISTS cancelled_at timestamptz;

-- 3. Migrate any existing registrations with null status to 'confirmado'
UPDATE public.registrations
SET status = 'confirmado'
WHERE status IS NULL;

-- 4. Create index on retreat_id and status for high-performance capacity queries
CREATE INDEX IF NOT EXISTS idx_registrations_retreat_status
ON public.registrations (retreat_id, status);

-- 5. Ensure RLS policies allow disciples to view and update/cancel their own registrations
DROP POLICY IF EXISTS "Discipulos podem ver suas proprias inscricoes" ON public.registrations;
CREATE POLICY "Discipulos podem ver suas proprias inscricoes" ON public.registrations
FOR SELECT TO authenticated
USING (
  profile_id IN (
    SELECT id FROM public.profiles WHERE user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Discipulos podem atualizar suas proprias inscricoes" ON public.registrations;
CREATE POLICY "Discipulos podem atualizar suas proprias inscricoes" ON public.registrations
FOR UPDATE TO authenticated
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
