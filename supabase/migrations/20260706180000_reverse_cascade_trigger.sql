-- Migration to automatically delete form_submissions when the referencing registration is deleted (reverse cascade)
-- Created at: 2026-07-06 18:00:00 UTC

CREATE OR REPLACE FUNCTION public.delete_associated_form_submission()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.form_submission_id IS NOT NULL THEN
    DELETE FROM public.form_submissions WHERE id = OLD.form_submission_id;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_delete_associated_form_submission ON public.registrations;
CREATE TRIGGER trigger_delete_associated_form_submission
AFTER DELETE ON public.registrations
FOR EACH ROW
EXECUTE FUNCTION public.delete_associated_form_submission();
