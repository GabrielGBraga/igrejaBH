-- Migration: 20261021144500_allow_leader_transfer_group.sql
-- Description: Allow leaders to transfer profiles between home groups

DROP POLICY IF EXISTS "Liderança pode atualizar perfis" ON public.profiles;

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
  -- Tier 2: Any leader of a home group (can transfer brother to another group or keep in group)
  EXISTS (
    SELECT 1 FROM public.home_groups hg
    JOIN public.profiles leader ON (hg.leader_1_id = leader.id OR hg.leader_2_id = leader.id)
    WHERE leader.user_id = auth.uid()
  )
);
