-- Migration: 20261021120000_simplify_gestao_rls_policies.sql
-- Description: Unify and simplify RLS policies for Gestão do Corpo (Tier 2 Leaders and Tier 3 Deacons/Presbyters/Devs)

-- 1. Trigger to protect sensitive profile roles (is_dev, is_presbyter, is_deacon, can_post)
CREATE OR REPLACE FUNCTION public.protect_profile_roles_on_write()
RETURNS TRIGGER AS $$
BEGIN
  IF (OLD.is_dev IS DISTINCT FROM NEW.is_dev OR
      OLD.is_presbyter IS DISTINCT FROM NEW.is_presbyter OR
      OLD.is_deacon IS DISTINCT FROM NEW.is_deacon OR
      OLD.can_post IS DISTINCT FROM NEW.can_post) THEN
    
    -- Only devs or presbyters can change leadership / administrative flags
    IF NOT EXISTS (
      SELECT 1 FROM public.profiles
      WHERE user_id = auth.uid() AND (is_dev = true OR is_presbyter = true)
    ) THEN
      RAISE EXCEPTION 'Apenas presbíteros ou desenvolvedores podem alterar funções de liderança.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_protect_profile_roles ON public.profiles;
CREATE TRIGGER trg_protect_profile_roles
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_profile_roles_on_write();


-- 2. Update policies for public.profiles

DROP POLICY IF EXISTS "Permitir atualização de perfis fantasmas para liderança" ON public.profiles;
DROP POLICY IF EXISTS "Permitir inserção de perfis para liderança" ON public.profiles;
DROP POLICY IF EXISTS "Permitir exclusão de perfis fantasmas para liderança" ON public.profiles;
DROP POLICY IF EXISTS "Liderança pode atualizar perfis" ON public.profiles;
DROP POLICY IF EXISTS "Liderança pode inserir perfis" ON public.profiles;
DROP POLICY IF EXISTS "Liderança pode excluir perfis provisórios" ON public.profiles;

-- INSERT: Devs, presbyters, deacons can insert profiles. Home group leaders can insert profiles into their group.
CREATE POLICY "Liderança pode inserir perfis"
ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (
  -- Tier 3: Dev, Presbyter, Deacon
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.user_id = auth.uid()
    AND (p.is_dev = true OR p.is_presbyter = true OR p.is_deacon = true)
  )
  OR
  -- Tier 2: Leader inserting into their own home group
  (
    home_group_id IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.home_groups hg
      JOIN public.profiles leader ON (hg.leader_1_id = leader.id OR hg.leader_2_id = leader.id)
      WHERE leader.user_id = auth.uid() AND hg.id = home_group_id
    )
  )
);

-- UPDATE: In addition to own profile, Tier 3 can update any profile, and Tier 2 can update profiles in their group
CREATE POLICY "Liderança pode atualizar perfis"
ON public.profiles
FOR UPDATE
TO authenticated
USING (
  -- Own profile
  auth.uid() = user_id
  OR
  -- Tier 3: Dev, Presbyter, Deacon
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.user_id = auth.uid()
    AND (p.is_dev = true OR p.is_presbyter = true OR p.is_deacon = true)
  )
  OR
  -- Tier 2: Leader of the group the profile currently belongs to
  EXISTS (
    SELECT 1 FROM public.home_groups hg
    JOIN public.profiles leader ON (hg.leader_1_id = leader.id OR hg.leader_2_id = leader.id)
    WHERE leader.user_id = auth.uid() AND hg.id = profiles.home_group_id
  )
)
WITH CHECK (
  -- Own profile
  auth.uid() = user_id
  OR
  -- Tier 3: Dev, Presbyter, Deacon
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.user_id = auth.uid()
    AND (p.is_dev = true OR p.is_presbyter = true OR p.is_deacon = true)
  )
  OR
  -- Tier 2: Leader can only keep or assign profile to their own group
  EXISTS (
    SELECT 1 FROM public.home_groups hg
    JOIN public.profiles leader ON (hg.leader_1_id = leader.id OR hg.leader_2_id = leader.id)
    WHERE leader.user_id = auth.uid() AND hg.id = home_group_id
  )
);

-- DELETE: Provisory profiles (user_id IS NULL) can be deleted by Tier 3, or by Tier 2 if in their group
CREATE POLICY "Liderança pode excluir perfis provisórios"
ON public.profiles
FOR DELETE
TO authenticated
USING (
  user_id IS NULL
  AND (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.user_id = auth.uid()
      AND (p.is_dev = true OR p.is_presbyter = true OR p.is_deacon = true)
    )
    OR
    EXISTS (
      SELECT 1 FROM public.home_groups hg
      JOIN public.profiles leader ON (hg.leader_1_id = leader.id OR hg.leader_2_id = leader.id)
      WHERE leader.user_id = auth.uid() AND hg.id = profiles.home_group_id
    )
  )
);


-- 3. Update policies for public.home_groups

DROP POLICY IF EXISTS "Devs e presbiteros podem gerenciar grupos caseiros" ON public.home_groups;
DROP POLICY IF EXISTS "Liderança ampla pode gerenciar grupos caseiros" ON public.home_groups;
DROP POLICY IF EXISTS "Líderes podem atualizar seu próprio grupo" ON public.home_groups;

-- Tier 3 (Devs, Presbyters, Deacons) can manage (INSERT, UPDATE, DELETE) all home groups
CREATE POLICY "Liderança ampla pode gerenciar grupos caseiros"
ON public.home_groups
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  )
);

-- Tier 2: Group leaders can UPDATE their own group
CREATE POLICY "Líderes podem atualizar seu próprio grupo"
ON public.home_groups
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.user_id = auth.uid()
    AND (p.id = home_groups.leader_1_id OR p.id = home_groups.leader_2_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.user_id = auth.uid()
    AND (p.id = home_groups.leader_1_id OR p.id = home_groups.leader_2_id)
  )
);


-- 4. Update policies for public.sectors

DROP POLICY IF EXISTS "Allow write access for presbyters and devs" ON public.sectors;
DROP POLICY IF EXISTS "Allow write access for leadership" ON public.sectors;

CREATE POLICY "Allow write access for leadership"
ON public.sectors
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND (is_presbyter = true OR is_dev = true OR is_deacon = true)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND (is_presbyter = true OR is_dev = true OR is_deacon = true)
  )
);


-- 5. Update policies for public.fellowships

DROP POLICY IF EXISTS "Liderança pode gerenciar comunhões" ON public.fellowships;

-- Tier 3 can manage all fellowships
CREATE POLICY "Liderança ampla pode gerenciar comunhões"
ON public.fellowships
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  )
  OR
  -- Tier 2 leader can manage fellowship if either brother belongs to leader's group
  EXISTS (
    SELECT 1 FROM public.home_groups hg
    JOIN public.profiles leader ON (hg.leader_1_id = leader.id OR hg.leader_2_id = leader.id)
    JOIN public.profiles pa ON pa.id = fellowships.member_a_id
    JOIN public.profiles pb ON pb.id = fellowships.member_b_id
    WHERE leader.user_id = auth.uid()
    AND (pa.home_group_id = hg.id OR pb.home_group_id = hg.id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  )
  OR
  EXISTS (
    SELECT 1 FROM public.home_groups hg
    JOIN public.profiles leader ON (hg.leader_1_id = leader.id OR hg.leader_2_id = leader.id)
    JOIN public.profiles pa ON pa.id = fellowships.member_a_id
    JOIN public.profiles pb ON pb.id = fellowships.member_b_id
    WHERE leader.user_id = auth.uid()
    AND (pa.home_group_id = hg.id OR pb.home_group_id = hg.id)
  )
);
