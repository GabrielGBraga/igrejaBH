-- Migration: Resilient CPF check and user linking (ignoring punctuation differences)
-- Created at: 2026-10-29 12:00:00 UTC

-- 1. Resilient check_cpf_registration RPC
CREATE OR REPLACE FUNCTION public.check_cpf_registration(p_cpf text)
RETURNS TABLE (
  exists_profile boolean,
  is_linked boolean,
  has_baptism_date boolean,
  profile_id uuid,
  full_name text,
  email text,
  phone text,
  birth_date date,
  baptism_date date,
  gender text,
  marital_status text,
  address_zip_code text,
  address_street text,
  address_number text,
  address_neighborhood text,
  address_city text,
  address_state text,
  address_complement text,
  occupation text,
  education_level text,
  employment_status text,
  household_income text,
  dependents_count integer,
  housing_status text,
  drivers_license text
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r_profile public.profiles%ROWTYPE;
BEGIN
  SELECT * INTO r_profile
  FROM public.profiles
  WHERE regexp_replace(COALESCE(cpf, ''), '\D', '', 'g') = regexp_replace(COALESCE(p_cpf, ''), '\D', '', 'g')
    AND regexp_replace(COALESCE(cpf, ''), '\D', '', 'g') <> '';

  IF NOT FOUND THEN
    exists_profile := false;
    is_linked := false;
    has_baptism_date := false;
    profile_id := null;
    full_name := null;
    email := null;
    phone := null;
    birth_date := null;
    baptism_date := null;
    gender := null;
    marital_status := null;
    address_zip_code := null;
    address_street := null;
    address_number := null;
    address_neighborhood := null;
    address_city := null;
    address_state := null;
    address_complement := null;
    occupation := null;
    education_level := null;
    employment_status := null;
    household_income := null;
    dependents_count := null;
    housing_status := null;
    drivers_license := null;
    RETURN NEXT;
  ELSE
    exists_profile := true;
    is_linked := (r_profile.user_id IS NOT NULL);
    has_baptism_date := (r_profile.baptism_date IS NOT NULL);
    profile_id := r_profile.id;
    full_name := r_profile.full_name;
    email := r_profile.email;
    phone := r_profile.phone;
    birth_date := r_profile.birth_date;
    baptism_date := r_profile.baptism_date;
    gender := r_profile.gender;
    marital_status := r_profile.marital_status;
    address_zip_code := r_profile.address_zip_code;
    address_street := r_profile.address_street;
    address_number := r_profile.address_number;
    address_neighborhood := r_profile.address_neighborhood;
    address_city := r_profile.address_city;
    address_state := r_profile.address_state;
    address_complement := r_profile.address_complement;
    occupation := r_profile.occupation;
    education_level := r_profile.education_level;
    employment_status := r_profile.employment_status;
    household_income := r_profile.household_income;
    dependents_count := r_profile.dependents_count;
    housing_status := r_profile.housing_status;
    drivers_license := r_profile.drivers_license;
    RETURN NEXT;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.check_cpf_registration(text) TO anon, authenticated;

-- 2. Resilient handle_new_user trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  existing_profile_id uuid;
  user_cpf text;
  user_phone text;
  clean_cpf text;
BEGIN
  user_cpf := new.raw_user_meta_data->>'cpf';
  user_phone := new.raw_user_meta_data->>'phone';
  clean_cpf := regexp_replace(COALESCE(user_cpf, ''), '\D', '', 'g');

  -- 1. Buscar perfil existente pelo CPF limpo
  IF clean_cpf <> '' THEN
    SELECT id INTO existing_profile_id
    FROM public.profiles
    WHERE regexp_replace(COALESCE(cpf, ''), '\D', '', 'g') = clean_cpf;
  END IF;

  -- 2. Se não encontrar pelo CPF, buscar pelo e-mail
  IF existing_profile_id IS NULL AND new.email IS NOT NULL AND new.email <> '' THEN
    SELECT id INTO existing_profile_id
    FROM public.profiles
    WHERE lower(email) = lower(new.email);
  END IF;

  -- 3. Vincular ou criar novo perfil
  IF existing_profile_id IS NOT NULL THEN
    UPDATE public.profiles
    SET 
      user_id = new.id,
      email = COALESCE(NULLIF(email, ''), new.email),
      phone = COALESCE(NULLIF(phone, ''), user_phone),
      cpf = COALESCE(NULLIF(cpf, ''), user_cpf),
      full_name = COALESCE(NULLIF(full_name, ''), COALESCE(new.raw_user_meta_data->>'full_name', '')),
      avatar_url = COALESCE(NULLIF(avatar_url, ''), COALESCE(new.raw_user_meta_data->>'avatar_url', '')),
      is_church_linked = true
    WHERE id = existing_profile_id;
  ELSE
    INSERT INTO public.profiles (
      user_id, 
      full_name, 
      email, 
      phone,
      cpf, 
      avatar_url,
      is_church_linked
    )
    VALUES (
      new.id, 
      COALESCE(new.raw_user_meta_data->>'full_name', ''),
      new.email,
      user_phone,
      user_cpf,
      COALESCE(new.raw_user_meta_data->>'avatar_url', ''),
      false
    );
  END IF;
  RETURN new;
END;
$function$;
