-- Criar política de select na tabela fellowships para a liderança
create policy "Liderança pode ver todas as comunhões"
on "public"."fellowships"
as permissive
for select
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.user_id = auth.uid()
    and (
      p.is_dev = true or 
      p.is_presbyter = true or 
      p.is_deacon = true or
      exists (
        select 1 from public.home_groups hg
        where hg.leader_1_id = p.id or hg.leader_2_id = p.id
      )
    )
  )
);
