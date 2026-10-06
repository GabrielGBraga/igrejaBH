-- Migration: Add event_coupons, presentation_page to forms, and has_payment to retreats

-- 1. Add has_payment to retreats
ALTER TABLE public.retreats 
ADD COLUMN IF NOT EXISTS has_payment boolean DEFAULT true;

-- 2. Add presentation_page to forms
ALTER TABLE public.forms 
ADD COLUMN IF NOT EXISTS presentation_page jsonb DEFAULT NULL;

-- 3. Create event_coupons table
CREATE TABLE IF NOT EXISTS public.event_coupons (
  id text PRIMARY KEY DEFAULT ('cpn-' || substr(md5(random()::text), 1, 10)),
  code text NOT NULL UNIQUE,
  retreat_id uuid REFERENCES public.retreats(id) ON DELETE CASCADE,
  form_id text REFERENCES public.forms(id) ON DELETE CASCADE,
  cpf text,
  is_used boolean NOT NULL DEFAULT false,
  used_by_name text,
  used_by_email text,
  used_at timestamptz,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_event_coupons_code ON public.event_coupons(code);
CREATE INDEX IF NOT EXISTS idx_event_coupons_retreat_id ON public.event_coupons(retreat_id);
CREATE INDEX IF NOT EXISTS idx_event_coupons_form_id ON public.event_coupons(form_id);
CREATE INDEX IF NOT EXISTS idx_event_coupons_cpf ON public.event_coupons(cpf);

-- Enable RLS
ALTER TABLE public.event_coupons ENABLE ROW LEVEL SECURITY;

-- Policy: Only managers/presbyters/deacons/can_post can manage coupons
DROP POLICY IF EXISTS "Gestores e presbiteros podem gerenciar cupons" ON public.event_coupons;
CREATE POLICY "Gestores e presbiteros podem gerenciar cupons"
ON public.event_coupons
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.user_id = auth.uid()
      AND (
        profiles.is_dev = true
        OR profiles.is_presbyter = true
        OR profiles.is_deacon = true
        OR profiles.can_post = true
      )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.user_id = auth.uid()
      AND (
        profiles.is_dev = true
        OR profiles.is_presbyter = true
        OR profiles.is_deacon = true
        OR profiles.can_post = true
      )
  )
);

-- RPC: validate_coupon
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
    RETURN jsonb_build_object('valid', false, 'message', 'Código de isenção inválido ou já utilizado.');
  END IF;

  -- Verify CPF if registered on the coupon
  IF v_coupon.cpf IS NOT NULL AND TRIM(v_coupon.cpf) <> '' THEN
    v_clean_coupon_cpf := regexp_replace(v_coupon.cpf, '\D', '', 'g');
    IF p_cpf IS NOT NULL AND TRIM(p_cpf) <> '' THEN
      v_clean_input_cpf := regexp_replace(p_cpf, '\D', '', 'g');
      IF v_clean_input_cpf <> v_clean_coupon_cpf THEN
        RETURN jsonb_build_object('valid', false, 'message', 'Este código de isenção está vinculado a outro CPF.');
      END IF;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'valid', true,
    'coupon_id', v_coupon.id,
    'code', v_coupon.code,
    'requires_cpf', (v_coupon.cpf IS NOT NULL AND TRIM(v_coupon.cpf) <> '')
  );
END;
$$;

-- RPC: redeem_coupon
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
    RETURN jsonb_build_object('success', false, 'message', 'Código de isenção inválido ou já utilizado.');
  END IF;

  -- Strict CPF check if coupon has CPF linked
  IF v_coupon.cpf IS NOT NULL AND TRIM(v_coupon.cpf) <> '' THEN
    v_clean_coupon_cpf := regexp_replace(v_coupon.cpf, '\D', '', 'g');
    IF p_cpf IS NULL OR TRIM(p_cpf) = '' THEN
      RETURN jsonb_build_object('success', false, 'message', 'O CPF é obrigatório para resgatar este código de isenção.');
    END IF;
    v_clean_input_cpf := regexp_replace(p_cpf, '\D', '', 'g');
    IF v_clean_input_cpf <> v_clean_coupon_cpf THEN
      RETURN jsonb_build_object('success', false, 'message', 'O CPF informado não corresponde ao CPF cadastrado para este código de isenção.');
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
    'code', v_coupon.code
  );
END;
$$;
