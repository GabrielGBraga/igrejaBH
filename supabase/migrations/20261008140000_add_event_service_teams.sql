-- Migration: Add service_team to registrations and target_service_team to event_coupons
-- Issue #83: Organização de equipes de serviço (voluntariado) e cupons de isenção para servidores

-- 1. Add service_team column to registrations
ALTER TABLE public.registrations
ADD COLUMN IF NOT EXISTS service_team text;

-- 2. Add target_service_team column to event_coupons
ALTER TABLE public.event_coupons
ADD COLUMN IF NOT EXISTS target_service_team text;

-- 3. Indexes for fast filtering
CREATE INDEX IF NOT EXISTS idx_registrations_service_team ON public.registrations(service_team);
CREATE INDEX IF NOT EXISTS idx_event_coupons_target_service_team ON public.event_coupons(target_service_team);

-- 4. Update validate_coupon to return target_service_team
CREATE OR REPLACE FUNCTION public.validate_coupon(
  p_code text,
  p_retreat_id text DEFAULT NULL,
  p_form_id text DEFAULT NULL,
  p_cpf text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_coupon public.event_coupons%ROWTYPE;
  v_retreat_uuid uuid := NULL;
  v_clean_input_cpf text := NULL;
  v_clean_coupon_cpf text := NULL;
BEGIN
  IF p_retreat_id IS NOT NULL AND p_retreat_id <> '' THEN
    BEGIN
      v_retreat_uuid := p_retreat_id::uuid;
    EXCEPTION WHEN OTHERS THEN
      v_retreat_uuid := NULL;
    END;
  END IF;

  SELECT * INTO v_coupon
  FROM public.event_coupons
  WHERE UPPER(TRIM(code)) = UPPER(TRIM(p_code))
    AND is_used = false
    AND (v_retreat_uuid IS NULL OR retreat_id IS NULL OR retreat_id = v_retreat_uuid)
    AND (p_form_id IS NULL OR p_form_id = '' OR form_id IS NULL OR form_id = p_form_id);

  IF NOT FOUND THEN
    RETURN jsonb_build_object('valid', false, 'message', 'Código de desconto ou isenção inválido ou já utilizado.');
  END IF;

  -- Verify CPF if registered on the coupon
  IF v_coupon.cpf IS NOT NULL AND TRIM(v_coupon.cpf) <> '' THEN
    v_clean_coupon_cpf := regexp_replace(v_coupon.cpf, '\D', '', 'g');
    IF p_cpf IS NOT NULL AND TRIM(p_cpf) <> '' THEN
      v_clean_input_cpf := regexp_replace(p_cpf, '\D', '', 'g');
      IF v_clean_input_cpf <> v_clean_coupon_cpf THEN
        RETURN jsonb_build_object('valid', false, 'message', 'Este código está vinculado a outro CPF.');
      END IF;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'valid', true,
    'coupon_id', v_coupon.id,
    'code', v_coupon.code,
    'discount_percent', COALESCE(v_coupon.discount_percent, 100),
    'target_service_team', v_coupon.target_service_team,
    'requires_cpf', (v_coupon.cpf IS NOT NULL AND TRIM(v_coupon.cpf) <> '')
  );
END;
$$;

-- 5. Update redeem_coupon to return target_service_team
CREATE OR REPLACE FUNCTION public.redeem_coupon(
  p_code text,
  p_user_name text DEFAULT NULL,
  p_user_email text DEFAULT NULL,
  p_retreat_id text DEFAULT NULL,
  p_form_id text DEFAULT NULL,
  p_cpf text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_coupon public.event_coupons%ROWTYPE;
  v_retreat_uuid uuid := NULL;
  v_clean_input_cpf text := NULL;
  v_clean_coupon_cpf text := NULL;
BEGIN
  IF p_retreat_id IS NOT NULL AND p_retreat_id <> '' THEN
    BEGIN
      v_retreat_uuid := p_retreat_id::uuid;
    EXCEPTION WHEN OTHERS THEN
      v_retreat_uuid := NULL;
    END;
  END IF;

  SELECT * INTO v_coupon
  FROM public.event_coupons
  WHERE UPPER(TRIM(code)) = UPPER(TRIM(p_code))
    AND is_used = false
    AND (v_retreat_uuid IS NULL OR retreat_id IS NULL OR retreat_id = v_retreat_uuid)
    AND (p_form_id IS NULL OR p_form_id = '' OR form_id IS NULL OR form_id = p_form_id)
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Código de desconto ou isenção inválido ou já utilizado.');
  END IF;

  -- Strict CPF check if coupon has CPF linked
  IF v_coupon.cpf IS NOT NULL AND TRIM(v_coupon.cpf) <> '' THEN
    v_clean_coupon_cpf := regexp_replace(v_coupon.cpf, '\D', '', 'g');
    IF p_cpf IS NULL OR TRIM(p_cpf) = '' THEN
      RETURN jsonb_build_object('success', false, 'message', 'O CPF é obrigatório para resgatar este código.');
    END IF;
    v_clean_input_cpf := regexp_replace(p_cpf, '\D', '', 'g');
    IF v_clean_input_cpf <> v_clean_coupon_cpf THEN
      RETURN jsonb_build_object('success', false, 'message', 'O CPF informado não corresponde ao CPF cadastrado para este código.');
    END IF;
  END IF;

  UPDATE public.event_coupons
  SET is_used = true,
      used_by_name = p_user_name,
      used_by_email = p_user_email,
      used_at = now()
  WHERE id = v_coupon.id;

  RETURN jsonb_build_object(
    'success', true,
    'coupon_id', v_coupon.id,
    'code', v_coupon.code,
    'discount_percent', COALESCE(v_coupon.discount_percent, 100),
    'target_service_team', v_coupon.target_service_team
  );
END;
$$;

-- 6. Trigger to automatically stamp service_team from coupon when registration is created
CREATE OR REPLACE FUNCTION public.sync_registration_service_team_from_coupon()
RETURNS trigger AS $$
DECLARE
  v_code text;
  v_team text;
BEGIN
  -- If service_team is already set, keep it
  IF NEW.service_team IS NOT NULL AND TRIM(NEW.service_team) <> '' THEN
    RETURN NEW;
  END IF;

  -- If payment_reference has coupon code, extract it
  IF NEW.payment_reference IS NOT NULL AND NEW.payment_reference ILIKE '%Cupom:%' THEN
    v_code := substring(NEW.payment_reference from 'Cupom:\s*([A-Za-z0-9_-]+)');
    IF v_code IS NOT NULL THEN
      SELECT target_service_team INTO v_team
      FROM public.event_coupons
      WHERE UPPER(TRIM(code)) = UPPER(TRIM(v_code))
      LIMIT 1;

      IF v_team IS NOT NULL AND TRIM(v_team) <> '' THEN
        NEW.service_team := v_team;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_registration_service_team_from_coupon ON public.registrations;
CREATE TRIGGER trg_sync_registration_service_team_from_coupon
BEFORE INSERT OR UPDATE ON public.registrations
FOR EACH ROW
EXECUTE FUNCTION public.sync_registration_service_team_from_coupon();

-- 7. Grant execute permissions
GRANT EXECUTE ON FUNCTION public.validate_coupon(text, text, text, text) TO anon, authenticated, public;
GRANT EXECUTE ON FUNCTION public.redeem_coupon(text, text, text, text, text, text) TO anon, authenticated, public;
