-- Migration: Make dependents_count nullable in profiles
-- Created at: 2026-07-07 22:50:00 UTC

ALTER TABLE public.profiles ALTER COLUMN dependents_count DROP NOT NULL;
