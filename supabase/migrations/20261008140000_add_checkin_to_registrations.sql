-- ============================================================================
-- MIGRAÇÃO: SISTEMA DE CHECK-IN E CREDENCIAMENTO ÁGIL PARA RECEPÇÃO DE EVENTOS
-- Adiciona colunas para registrar data/hora da chegada e o recepcionista responsável
-- ============================================================================

ALTER TABLE public.registrations
ADD COLUMN IF NOT EXISTS checked_in_at timestamptz,
ADD COLUMN IF NOT EXISTS checked_in_by uuid;

-- Adiciona constraint de foreign key para profiles caso não exista
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'registrations_checked_in_by_fkey'
  ) THEN
    ALTER TABLE public.registrations
    ADD CONSTRAINT registrations_checked_in_by_fkey
    FOREIGN KEY (checked_in_by) REFERENCES public.profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Índice para acelerar filtros e estatísticas de presentes em tempo real na portaria
CREATE INDEX IF NOT EXISTS idx_registrations_retreat_checkin
ON public.registrations(retreat_id, checked_in_at);
