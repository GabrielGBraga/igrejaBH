drop policy "Liderança pode ver todas as comunhões" on "public"."fellowships";
drop policy "Allow DELETE on posts for author or leadership" on "public"."posts";
drop policy "Allow INSERT on posts for authorized authors" on "public"."posts";
drop policy "Allow SELECT on posts for author or published" on "public"."posts";
drop policy "Allow UPDATE on posts for author or leadership" on "public"."posts";
alter table "public"."registrations" drop constraint "registrations_profile_id_fkey";
alter table "public"."profiles" add column "dependents_count" integer not null default 0;
alter table "public"."profiles" add column "drivers_license" text not null;
alter table "public"."profiles" add column "education_level" text not null;
alter table "public"."profiles" add column "employment_status" text not null;
alter table "public"."profiles" add column "household_income" text not null;
alter table "public"."profiles" add column "housing_status" text not null;
alter table "public"."profiles" add column "occupation" text not null;
alter table "public"."registrations" alter column "id" set default gen_random_uuid();
alter table "public"."retreats" alter column "id" set default gen_random_uuid();
alter table "public"."retreats" alter column "price" set data type numeric using "price"::numeric;
alter table "public"."registrations" add constraint "registrations_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;
alter table "public"."registrations" validate constraint "registrations_profile_id_fkey";
set check_function_bodies = off;
CREATE OR REPLACE FUNCTION public.sync_home_group_leaders()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$ BEGIN IF NEW.leader_1_id IS NOT NULL THEN UPDATE public.profiles SET home_group_id = NEW.id WHERE id = NEW.leader_1_id; END IF; IF NEW.leader_2_id IS NOT NULL THEN UPDATE public.profiles SET home_group_id = NEW.id WHERE id = NEW.leader_2_id; END IF; RETURN NEW; END; $function$
;
  drop policy if exists "Liderança pode gerenciar comunhões" on "public"."fellowships";
  create policy "Liderança pode gerenciar comunhões"
  on "public"."fellowships"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true) OR (profiles.is_deacon = true))))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true) OR (profiles.is_deacon = true))))));
  create policy "Usuários autenticados podem ver postagens"
  on "public"."posts"
  as permissive
  for select
  to authenticated
using (((is_published = true) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = posts.author_id) AND (profiles.user_id = auth.uid()))))));
  create policy "Usuários com permissão podem criar postagens"
  on "public"."posts"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = posts.author_id) AND (profiles.user_id = auth.uid()) AND ((profiles.can_post = true) OR (profiles.is_presbyter = true) OR (profiles.is_deacon = true) OR (profiles.is_dev = true))))));
  create policy "Usuários podem atualizar suas próprias postagens ou lideranç"
  on "public"."posts"
  as permissive
  for update
  to authenticated
using (((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = posts.author_id) AND (profiles.user_id = auth.uid())))) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_presbyter = true) OR (profiles.is_deacon = true) OR (profiles.is_dev = true)))))))
with check (((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = posts.author_id) AND (profiles.user_id = auth.uid())))) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_presbyter = true) OR (profiles.is_deacon = true) OR (profiles.is_dev = true)))))));
  create policy "Usuários podem deletar suas próprias postagens ou liderança"
  on "public"."posts"
  as permissive
  for delete
  to authenticated
using (((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = posts.author_id) AND (profiles.user_id = auth.uid())))) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_presbyter = true) OR (profiles.is_deacon = true) OR (profiles.is_dev = true)))))));
CREATE TRIGGER trg_sync_home_group_leaders AFTER INSERT OR UPDATE OF leader_1_id, leader_2_id ON public.home_groups FOR EACH ROW EXECUTE FUNCTION public.sync_home_group_leaders();
