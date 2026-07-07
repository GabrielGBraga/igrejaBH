-- Migração: Adicionar coluna email a profiles, restrição UNIQUE no CPF, atualizar trigger de registro por CPF/E-mail e adicionar RLS de gestão

-- 1. Adicionar coluna email a profiles
ALTER TABLE public.profiles ADD COLUMN email text;

-- 2. Migrar e-mails dos usuários autenticados existentes para seus perfis
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.user_id = u.id AND p.email IS NULL;

-- 3. Adicionar restrição UNIQUE à coluna email
ALTER TABLE public.profiles ADD CONSTRAINT profiles_email_key UNIQUE (email);

-- 4. Normalizar CPFs vazios para NULL antes de aplicar a restrição UNIQUE
UPDATE public.profiles
SET cpf = NULL
WHERE cpf = '';

-- 5. Adicionar restrição UNIQUE à coluna cpf
ALTER TABLE public.profiles ADD CONSTRAINT profiles_cpf_key UNIQUE (cpf);

-- 6. Atualizar a trigger function handle_new_user() para vincular por CPF primeiro, depois E-mail
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  existing_profile_id uuid;
  user_cpf text;
BEGIN
  -- Obter o CPF do metadata do usuário, se houver
  user_cpf := new.raw_user_meta_data->>'cpf';

  -- 1. Tentar buscar perfil existente pelo CPF
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
      cpf = COALESCE(NULLIF(cpf, ''), user_cpf),
      full_name = COALESCE(NULLIF(full_name, ''), COALESCE(new.raw_user_meta_data->>'full_name', '')),
      avatar_url = COALESCE(NULLIF(avatar_url, ''), COALESCE(new.raw_user_meta_data->>'avatar_url', ''))
    WHERE id = existing_profile_id;
  ELSE
    -- Criar um novo perfil se não existir nenhum correspondente
    INSERT INTO public.profiles (user_id, full_name, email, cpf, avatar_url)
    VALUES (
      new.id, 
      COALESCE(new.raw_user_meta_data->>'full_name', ''),
      new.email,
      user_cpf,
      COALESCE(new.raw_user_meta_data->>'avatar_url', '')
    );
  END IF;
  RETURN new;
END;
$function$;

-- 7. Criar políticas RLS para permitir inserção de perfis provisórios por liderança
CREATE POLICY "Permitir inserção de perfis para liderança"
ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (
  -- O usuário inserindo precisa ser líder de GC, diácono, presbítero ou dev
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.user_id = auth.uid()
    AND (
      p.is_dev = true OR 
      p.is_presbyter = true OR 
      p.is_deacon = true OR
      EXISTS (
        SELECT 1 FROM public.home_groups hg
        WHERE hg.leader_1_id = p.id OR hg.leader_2_id = p.id
      )
    )
  )
  AND (
    -- Evitar que diáconos ou líderes comuns elevem outros perfis a funções administrativas
    (
      is_dev IS NOT TRUE AND
      is_presbyter IS NOT TRUE AND
      is_deacon IS NOT TRUE
    )
    OR EXISTS (
      SELECT 1 FROM public.profiles p2
      WHERE p2.user_id = auth.uid() AND (p2.is_dev = true OR p2.is_presbyter = true)
    )
  )
);

-- 8. Criar políticas RLS para atualização de perfis provisórios por liderança
CREATE POLICY "Permitir atualização de perfis fantasmas para liderança"
ON public.profiles
FOR UPDATE
TO authenticated
USING (
  -- Apenas perfis provisórios (sem conta associada)
  user_id IS NULL
  AND EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.user_id = auth.uid()
    AND (
      p.is_dev = true OR 
      p.is_presbyter = true OR 
      p.is_deacon = true OR
      EXISTS (
        SELECT 1 FROM public.home_groups hg
        WHERE hg.leader_1_id = p.id OR hg.leader_2_id = p.id
      )
    )
  )
)
WITH CHECK (
  -- Impedir promoção de cargo por não-admin
  (
    is_dev IS NOT TRUE AND
    is_presbyter IS NOT TRUE AND
    is_deacon IS NOT TRUE
  )
  OR EXISTS (
    SELECT 1 FROM public.profiles p2
    WHERE p2.user_id = auth.uid() AND (p2.is_dev = true OR p2.is_presbyter = true)
  )
);

-- 9. Criar políticas RLS para deleção de perfis provisórios por liderança
CREATE POLICY "Permitir exclusão de perfis fantasmas para liderança"
ON public.profiles
FOR DELETE
TO authenticated
USING (
  -- Apenas perfis provisórios (sem conta associada)
  user_id IS NULL
  AND EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.user_id = auth.uid()
    AND (
      p.is_dev = true OR 
      p.is_presbyter = true OR 
      p.is_deacon = true OR
      EXISTS (
        SELECT 1 FROM public.home_groups hg
        WHERE hg.leader_1_id = p.id OR hg.leader_2_id = p.id
      )
    )
  )
);
