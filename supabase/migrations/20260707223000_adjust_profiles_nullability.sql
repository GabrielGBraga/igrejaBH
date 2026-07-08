-- Migration: Adjust profiles table column nullability
-- Created at: 2026-07-07 22:30:00 UTC

-- 1. Make socioeconomic columns nullable
ALTER TABLE public.profiles ALTER COLUMN drivers_license DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN education_level DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN employment_status DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN household_income DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN housing_status DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN occupation DROP NOT NULL;

-- 2. Ensure boolean columns and created_at do not allow NULL values and have correct defaults
UPDATE public.profiles SET is_presbyter = false WHERE is_presbyter IS NULL;
UPDATE public.profiles SET is_deacon = false WHERE is_deacon IS NULL;
UPDATE public.profiles SET is_dev = false WHERE is_dev IS NULL;
UPDATE public.profiles SET can_post = false WHERE can_post IS NULL;
UPDATE public.profiles SET created_at = now() WHERE created_at IS NULL;

ALTER TABLE public.profiles ALTER COLUMN is_presbyter SET NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN is_presbyter SET DEFAULT false;

ALTER TABLE public.profiles ALTER COLUMN is_deacon SET NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN is_deacon SET DEFAULT false;

ALTER TABLE public.profiles ALTER COLUMN is_dev SET NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN is_dev SET DEFAULT false;

ALTER TABLE public.profiles ALTER COLUMN can_post SET NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN can_post SET DEFAULT false;

ALTER TABLE public.profiles ALTER COLUMN created_at SET NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN created_at SET DEFAULT now();
