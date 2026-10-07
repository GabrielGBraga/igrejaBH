-- Sincronização bidirecional do campo spouse_id em profiles
CREATE OR REPLACE FUNCTION public.handle_profiles_spouse_sync()
RETURNS TRIGGER AS $$
BEGIN
  -- Evitar recursão infinita no trigger
  IF pg_trigger_depth() > 1 THEN
    RETURN NEW;
  END IF;

  -- 1. Se o cônjuge anterior foi removido ou alterado, desvincula o ex-cônjuge
  IF TG_OP = 'UPDATE' THEN
    IF OLD.spouse_id IS NOT NULL AND (NEW.spouse_id IS NULL OR NEW.spouse_id <> OLD.spouse_id) THEN
      UPDATE public.profiles
      SET spouse_id = NULL
      WHERE id = OLD.spouse_id AND spouse_id = OLD.id;
    END IF;
  END IF;

  -- 2. Se um novo cônjuge foi definido
  IF NEW.spouse_id IS NOT NULL AND (TG_OP = 'INSERT' OR OLD.spouse_id IS NULL OR NEW.spouse_id <> OLD.spouse_id) THEN
    -- Desvincula caso o novo cônjuge estivesse vinculado a outra pessoa
    UPDATE public.profiles
    SET spouse_id = NULL
    WHERE spouse_id = NEW.spouse_id AND id <> NEW.id;

    -- Vincula o novo cônjuge de volta a este perfil
    UPDATE public.profiles
    SET spouse_id = NEW.id
    WHERE id = NEW.spouse_id AND (spouse_id IS NULL OR spouse_id <> NEW.id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_sync_profiles_spouse ON public.profiles;

CREATE TRIGGER trigger_sync_profiles_spouse
AFTER INSERT OR UPDATE OF spouse_id ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.handle_profiles_spouse_sync();
