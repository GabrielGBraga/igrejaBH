-- Migration consolidada limpa
-- Data: 2026-04-26

-- Removendo triggers e políticas que serão recriadas (para evitar erro de 'já existe')
drop trigger if exists "protect_is_dev_on_update" on "public"."profiles";
drop policy if exists "Devs e presbiteros podem gerenciar grupos caseiros" on "public"."home_groups";
drop policy if exists "Permitir delete para liderança" on "public"."media_resources";
drop policy if exists "Permitir inserção para liderança" on "public"."media_resources";
drop policy if exists "Usuários podem criar suas próprias inscrições" on "public"."registrations";
drop policy if exists "Usuários podem ver suas próprias inscrições" on "public"."registrations";

-- Criação da tabela de teste de auditoria (Alvo do nosso teste de RLS)
create table if not exists "public"."audit_test_vulnerability" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "data" text
);

alter table "public"."audit_test_vulnerability" enable row level security;

-- Index e PK
do $$
begin
    if not exists (select 1 from pg_indexes where indexname = 'audit_test_vulnerability_pkey') then
        create unique index audit_test_vulnerability_pkey on public.audit_test_vulnerability using btree (id);
    end if;
end $$;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'audit_test_vulnerability_pkey') then
        alter table "public"."audit_test_vulnerability" add constraint "audit_test_vulnerability_pkey" primary key using index "audit_test_vulnerability_pkey";
    end if;
end $$;

-- Recriando as políticas originais do sistema
create policy "Devs e presbiteros podem gerenciar grupos caseiros"
on "public"."home_groups"
as permissive for all to public
using ((exists (select 1 from profiles where profiles.user_id = auth.uid() and (profiles.is_dev = true or profiles.is_presbyter = true))))
with check ((exists (select 1 from profiles where profiles.user_id = auth.uid() and (profiles.is_dev = true or profiles.is_presbyter = true))));

create policy "Permitir delete para liderança"
on "public"."media_resources"
as permissive for delete to public
using ((exists (select 1 from profiles where profiles.user_id = auth.uid() and (profiles.is_presbyter = true or profiles.is_deacon = true or profiles.is_dev = true))));

create policy "Permitir inserção para liderança"
on "public"."media_resources"
as permissive for insert to public
with check ((exists (select 1 from profiles where profiles.user_id = auth.uid() and (profiles.is_presbyter = true or profiles.is_deacon = true or profiles.is_dev = true))));

create policy "Usuários podem criar suas próprias inscrições"
on "public"."registrations"
as permissive for insert to authenticated
with check ((profile_id in (select profiles.id from profiles where profiles.user_id = auth.uid())));

create policy "Usuários podem ver suas próprias inscrições"
on "public"."registrations"
as permissive for select to authenticated
using ((profile_id in (select profiles.id from profiles where profiles.user_id = auth.uid())));

-- Trigger de proteção is_dev
create trigger protect_is_dev_on_update before update on public.profiles for each row execute function handle_is_dev_protection();
