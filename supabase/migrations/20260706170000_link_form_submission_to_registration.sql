-- Migration to link form submissions to registrations
-- Created at: 2026-07-06 17:00:00 UTC

-- Add form_submission_id column to public.registrations referencing public.form_submissions
ALTER TABLE public.registrations 
ADD COLUMN IF NOT EXISTS form_submission_id text REFERENCES public.form_submissions(id) ON DELETE CASCADE;
