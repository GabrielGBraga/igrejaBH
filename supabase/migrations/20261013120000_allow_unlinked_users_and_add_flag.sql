-- Migração: Suporte a usuários não vinculados à igreja (contas de estudos/visitantes)
-- Adiciona coluna is_church_linked, torna cpf e birth_date anuláveis para não vinculados,
-- atualiza a trigger handle_new_user() e cria trigger de proteção para is_church_linked.

-- 1. Adicionar coluna is_church_linked a profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_church_linked boolean NOT NULL DEFAULT false;

-- 2. Atualizar perfis existentes como vinculados (já que representam discípulos ou pré-cadastros da igreja)
UPDATE public.profiles 
SET is_church_linked = true 
WHERE is_church_linked = false;

-- 3. Permitir que cpf e birth_date sejam nulos para perfis de visitantes/estudos
ALTER TABLE public.profiles ALTER COLUMN cpf DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN birth_date DROP NOT NULL;

-- 4. Atualizar a trigger handle_new_user() para acomodar novos usuários não vinculados
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  existing_profile_id uuid;
  user_cpf text;
  user_phone text;
BEGIN
  -- Obter CPF e telefone do metadata do usuário, se houver
  user_cpf := new.raw_user_meta_data->>'cpf';
  user_phone := new.raw_user_meta_data->>'phone';

  -- 1. Tentar buscar perfil existente pelo CPF (pré-cadastro feito pela liderança)
  IF user_cpf IS NOT NULL AND user_cpf <> '' THEN
    SELECT id INTO existing_profile_id
    FROM public.profiles
    WHERE cpf = user_cpf;
  END IF;

  -- 2. Se não encontrar pelo CPF, tentar buscar pelo e-mail
  IF existing_profile_id IS NULL AND new.email IS NOT NULL AND new.email <> '' THEN
    SELECT id INTO existing_profile_id
    FROM public.profiles
    WHERE email = new.email;
  END IF;

  -- 3. Vincular ou criar novo perfil
  IF existing_profile_id IS NOT NULL THEN
    -- Atualizar o perfil existente vinculando-o ao novo usuário de autenticação
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
    -- Criar um novo perfil não vinculado para quem está criando conta de estudos
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

-- 5. Trigger de proteção para is_church_linked
CREATE OR REPLACE FUNCTION public.handle_is_church_linked_protection()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.is_church_linked IS DISTINCT FROM NEW.is_church_linked) THEN
        -- Apenas liderança (presbíteros, diáconos, devs ou líderes de GC) pode alterar o vínculo
        IF NOT EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() 
            AND (is_dev = true OR is_presbyter = true OR is_deacon = true)
        ) AND NOT EXISTS (
            SELECT 1 FROM public.home_groups hg
            JOIN public.profiles p ON p.user_id = auth.uid()
            WHERE hg.leader_1_id = p.id OR hg.leader_2_id = p.id
        ) THEN
            NEW.is_church_linked := OLD.is_church_linked;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS protect_is_church_linked_on_update ON public.profiles;
CREATE TRIGGER protect_is_church_linked_on_update
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_is_church_linked_protection();
