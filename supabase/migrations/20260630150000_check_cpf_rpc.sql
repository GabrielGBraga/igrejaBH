-- Migration: Create check_cpf_registration RPC to securely check CPF eligibility for signup
-- Created at: 2026-06-30 15:00:00 UTC

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
  WHERE cpf = p_cpf;

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
