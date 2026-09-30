-- Migration: Enforce 1-to-1 unique relationship between retreats and custom forms
-- Ensures that no two events can share the same form_id, preventing data and lifecycle state conflicts

-- 1. Partial Unique Index: guarantees at storage level that form_id cannot be shared among retreats
-- (while allowing multiple retreats to have form_id IS NULL for the default form)
CREATE UNIQUE INDEX IF NOT EXISTS idx_retreats_unique_form_id 
ON public.retreats (form_id) 
WHERE form_id IS NOT NULL;

-- 2. Trigger function to provide a friendly, descriptive error message if a conflict occurs
CREATE OR REPLACE FUNCTION public.check_retreat_form_uniqueness()
RETURNS TRIGGER AS $$
DECLARE
  v_existing_title text;
BEGIN
  IF NEW.form_id IS NOT NULL THEN
    SELECT title INTO v_existing_title
    FROM public.retreats
    WHERE form_id = NEW.form_id
      AND (NEW.id IS NULL OR id != NEW.id)
    LIMIT 1;

    IF FOUND THEN
      RAISE EXCEPTION 'O formulário selecionado já está vinculado ao evento "%". Cada evento deve possuir sua própria ficha de inscrição exclusiva. Caso deseje reutilizar a estrutura, duplique o formulário na Gestão de Formulários.', v_existing_title;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_retreat_form_uniqueness ON public.retreats;

CREATE TRIGGER trigger_check_retreat_form_uniqueness
BEFORE INSERT OR UPDATE OF form_id ON public.retreats
FOR EACH ROW
EXECUTE FUNCTION public.check_retreat_form_uniqueness();
