-- ============================================================================
-- MIGRAÇÃO: TRIGGER DE BANCO DE DADOS PARA VALIDAR CAMPOS OBRIGATÓRIOS
-- Garante em nível de PostgreSQL que inscrições em eventos tenham os dados base
-- ============================================================================

CREATE OR REPLACE FUNCTION public.validate_registration_mandatory_fields()
RETURNS TRIGGER AS $$
DECLARE
  v_guest jsonb;
  v_full_name text;
  v_email text;
  v_phone text;
  v_gender text;
BEGIN
  v_guest := NEW.guest_data;

  -- Se guest_data for informado, validar presença de full_name, email, phone e gender
  IF v_guest IS NOT NULL AND v_guest != '{}'::jsonb THEN
    v_full_name := COALESCE(v_guest->>'full_name', v_guest->>'fullName');
    v_email := v_guest->>'email';
    v_phone := v_guest->>'phone';
    v_gender := v_guest->>'gender';

    IF v_full_name IS NULL OR length(trim(v_full_name)) = 0 THEN
      RAISE EXCEPTION 'Erro de validação: O nome completo do participante é obrigatório.';
    END IF;

    IF v_email IS NULL OR length(trim(v_email)) = 0 THEN
      RAISE EXCEPTION 'Erro de validação: O e-mail do participante é obrigatório.';
    END IF;

    IF v_phone IS NULL OR length(trim(v_phone)) = 0 THEN
      RAISE EXCEPTION 'Erro de validação: O telefone de contato é obrigatório.';
    END IF;

    IF v_gender IS NULL OR length(trim(v_gender)) = 0 THEN
      RAISE EXCEPTION 'Erro de validação: O sexo/gênero é obrigatório para alocação de alojamentos.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_registration_mandatory_fields ON public.registrations;

CREATE TRIGGER check_registration_mandatory_fields
  BEFORE INSERT OR UPDATE ON public.registrations
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_registration_mandatory_fields();
