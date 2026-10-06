-- Migration: Add discount_percent to event_coupons and update RPCs

-- 1. Add discount_percent column (1 to 100, default 100)
ALTER TABLE public.event_coupons
ADD COLUMN IF NOT EXISTS discount_percent integer NOT NULL DEFAULT 100 CHECK (discount_percent >= 1 AND discount_percent <= 100);

-- 2. Update validate_coupon to return discount_percent
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
    'requires_cpf', (v_coupon.cpf IS NOT NULL AND TRIM(v_coupon.cpf) <> '')
  );
END;
$$;

-- 3. Update redeem_coupon to return discount_percent
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
    'discount_percent', COALESCE(v_coupon.discount_percent, 100)
  );
END;
$$;
