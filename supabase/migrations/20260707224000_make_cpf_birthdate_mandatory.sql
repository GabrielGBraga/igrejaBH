-- Migration: Make CPF and birth_date mandatory in profiles, make role/permission flags nullable
-- Created at: 2026-07-07 22:40:00 UTC

-- 1. For existing rows in production that might have NULL CPF or birth_date, update them to have valid fallback values
WITH numbered_nulls AS (
  SELECT id, ROW_NUMBER() OVER () as rn
  FROM public.profiles
  WHERE cpf IS NULL
)
UPDATE public.profiles p
SET cpf = '999999999' || LPAD(n.rn::text, 2, '0')
FROM numbered_nulls n
WHERE p.id = n.id;

UPDATE public.profiles SET birth_date = '1900-01-01' WHERE birth_date IS NULL;

-- 2. Alter columns to NOT NULL
ALTER TABLE public.profiles ALTER COLUMN cpf SET NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN birth_date SET NOT NULL;

-- 3. Revert role/permission columns back to nullable (dropping NOT NULL)
ALTER TABLE public.profiles ALTER COLUMN is_presbyter DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN is_deacon DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN is_dev DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN can_post DROP NOT NULL;
