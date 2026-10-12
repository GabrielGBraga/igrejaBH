drop index if exists "public"."idx_event_coupons_code";
drop index if exists "public"."idx_event_coupons_form_id";
drop index if exists "public"."idx_event_coupons_retreat_id";
  create table "public"."event_waitlist" (
    "id" uuid not null default gen_random_uuid(),
    "retreat_id" uuid not null,
    "full_name" text not null,
    "cpf" text,
    "phone" text not null,
    "email" text not null,
    "city_state" text,
    "travel_mode" text,
    "notes" text,
    "status" text not null default 'aguardando'::text,
    "created_at" timestamp with time zone not null default now()
      );
alter table "public"."event_waitlist" enable row level security;
alter table "public"."event_coupons" add column "target_service_team" text;
alter table "public"."registrations" add column "checked_in_at" timestamp with time zone;
alter table "public"."registrations" add column "checked_in_by" uuid;
alter table "public"."registrations" add column "service_team" text;
alter table "public"."retreats" add column "spreadsheet_data" jsonb default '{}'::jsonb;
CREATE UNIQUE INDEX event_waitlist_pkey ON public.event_waitlist USING btree (id);
CREATE INDEX idx_event_coupons_target_service_team ON public.event_coupons USING btree (target_service_team);
CREATE INDEX idx_event_waitlist_retreat_created ON public.event_waitlist USING btree (retreat_id, created_at);
CREATE INDEX idx_registrations_retreat_checkin ON public.registrations USING btree (retreat_id, checked_in_at);
CREATE INDEX idx_registrations_service_team ON public.registrations USING btree (service_team);
CREATE INDEX idx_study_notes_media_resource_id ON public.study_notes USING btree (media_resource_id);
CREATE INDEX idx_study_notes_profile_id ON public.study_notes USING btree (profile_id);
CREATE INDEX idx_study_notes_study_id ON public.study_notes USING btree (study_id);
alter table "public"."event_waitlist" add constraint "event_waitlist_pkey" PRIMARY KEY using index "event_waitlist_pkey";
alter table "public"."event_waitlist" add constraint "event_waitlist_retreat_id_fkey" FOREIGN KEY (retreat_id) REFERENCES public.retreats(id) ON DELETE CASCADE not valid;
alter table "public"."event_waitlist" validate constraint "event_waitlist_retreat_id_fkey";
alter table "public"."event_waitlist" add constraint "event_waitlist_status_check" CHECK ((status = ANY (ARRAY['aguardando'::text, 'chamado'::text, 'inscrito'::text, 'desistiu'::text]))) not valid;
alter table "public"."event_waitlist" validate constraint "event_waitlist_status_check";
alter table "public"."registrations" add constraint "registrations_checked_in_by_fkey" FOREIGN KEY (checked_in_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;
alter table "public"."registrations" validate constraint "registrations_checked_in_by_fkey";
set check_function_bodies = off;
CREATE OR REPLACE FUNCTION public.patch_retreat_sheet_metadata(p_retreat_id uuid, p_sheet_name text, p_metadata jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE public.retreats
  SET spreadsheet_data = jsonb_set(
    COALESCE(spreadsheet_data, '{}'::jsonb),
    ARRAY['_sheets', p_sheet_name],
    p_metadata,
    true
  )
  WHERE id = p_retreat_id;
END;
$function$
;
CREATE OR REPLACE FUNCTION public.patch_retreat_spreadsheet_cell(p_retreat_id uuid, p_sheet_name text, p_cell_coord text, p_value jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE public.retreats
  SET spreadsheet_data = jsonb_set(
    COALESCE(spreadsheet_data, '{}'::jsonb),
    ARRAY[p_sheet_name, p_cell_coord],
    p_value,
    true
  )
  WHERE id = p_retreat_id;
END;
$function$
;
CREATE OR REPLACE FUNCTION public.sync_registration_service_team_from_coupon()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.handle_profiles_spouse_sync()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Prevent recursive loops
  IF pg_trigger_depth() > 1 THEN
    RETURN NEW;
  END IF;
  -- 1. If spouse was removed or changed, unlink the former spouse
  IF TG_OP = 'UPDATE' THEN
    IF OLD.spouse_id IS NOT NULL AND (NEW.spouse_id IS NULL OR NEW.spouse_id <> OLD.spouse_id) THEN
      UPDATE public.profiles
      SET spouse_id = NULL
      WHERE id = OLD.spouse_id AND spouse_id = OLD.id;
    END IF;
  END IF;
  -- 2. If new spouse is set
  IF NEW.spouse_id IS NOT NULL AND (TG_OP = 'INSERT' OR OLD.spouse_id IS NULL OR NEW.spouse_id <> OLD.spouse_id) THEN
    -- If the new partner is currently linked to someone else, unlink that former person
    UPDATE public.profiles
    SET spouse_id = NULL
    WHERE spouse_id = NEW.spouse_id AND id <> NEW.id;
    -- Link the new partner back to this profile
    UPDATE public.profiles
    SET spouse_id = NEW.id
    WHERE id = NEW.spouse_id AND (spouse_id IS NULL OR spouse_id <> NEW.id);
  END IF;
  RETURN NEW;
END;
$function$
;
CREATE OR REPLACE FUNCTION public.redeem_coupon(p_code text, p_user_name text DEFAULT NULL::text, p_user_email text DEFAULT NULL::text, p_retreat_id text DEFAULT NULL::text, p_form_id text DEFAULT NULL::text, p_cpf text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.validate_coupon(p_code text, p_retreat_id text DEFAULT NULL::text, p_form_id text DEFAULT NULL::text, p_cpf text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;
  create policy "Liderança e devs podem atualizar lista de espera"
  on "public"."event_waitlist"
  as permissive
  for update
  to authenticated
using (((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true) OR (profiles.is_deacon = true))))) OR (EXISTS ( SELECT 1
   FROM public.home_groups
  WHERE ((home_groups.leader_1_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.user_id = auth.uid()))) OR (home_groups.leader_2_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.user_id = auth.uid()))))))))
with check (((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true) OR (profiles.is_deacon = true))))) OR (EXISTS ( SELECT 1
   FROM public.home_groups
  WHERE ((home_groups.leader_1_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.user_id = auth.uid()))) OR (home_groups.leader_2_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.user_id = auth.uid()))))))));
  create policy "Liderança e devs podem deletar da lista de espera"
  on "public"."event_waitlist"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true) OR (profiles.is_deacon = true))))));
  create policy "Liderança e devs podem visualizar lista de espera"
  on "public"."event_waitlist"
  as permissive
  for select
  to authenticated
using (((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true) OR (profiles.is_deacon = true))))) OR (EXISTS ( SELECT 1
   FROM public.home_groups
  WHERE ((home_groups.leader_1_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.user_id = auth.uid()))) OR (home_groups.leader_2_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.user_id = auth.uid()))))))));
  create policy "Permitir inserção na lista de espera para todos"
  on "public"."event_waitlist"
  as permissive
  for insert
  to public
with check (true);
CREATE TRIGGER trg_sync_registration_service_team_from_coupon BEFORE INSERT OR UPDATE ON public.registrations FOR EACH ROW EXECUTE FUNCTION public.sync_registration_service_team_from_coupon();
