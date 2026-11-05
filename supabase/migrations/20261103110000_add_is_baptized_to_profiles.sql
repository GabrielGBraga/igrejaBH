-- Adiciona coluna is_baptized para indicar se o discípulo é batizado nas águas
-- Se is_baptized = true, a data exata do batismo (baptism_date) é opcional.

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_baptized boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.profiles.is_baptized IS 
'Indica se o discípulo já é batizado nas águas. A data exata de batismo (baptism_date) torna-se opcional quando este campo é verdadeiro.';

-- Backfill de dados existentes:
-- 1. Quem já possui data de batismo é batizado
-- 2. Presbíteros, diáconos e devs são batizados
-- 3. Adultos com discipulador cadastrado ou cônjuge também são batizados
UPDATE public.profiles
SET is_baptized = true
WHERE baptism_date IS NOT NULL
   OR is_presbyter = true
   OR is_deacon = true
   OR is_dev = true
   OR discipler_id IS NOT NULL
   OR spouse_id IS NOT NULL;

-- Atualizar RPC check_cpf_registration para considerar is_baptized
DROP FUNCTION IF EXISTS public.check_cpf_registration(text);
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
  drivers_license text,
  is_baptized boolean
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
    is_baptized := false;
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
    is_baptized := (r_profile.is_baptized = true OR r_profile.baptism_date IS NOT NULL);
    -- has_baptism_date mantido como true se for batizado ou tiver data, permitindo o fluxo de SignUp
    has_baptism_date := (r_profile.is_baptized = true OR r_profile.baptism_date IS NOT NULL);
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
