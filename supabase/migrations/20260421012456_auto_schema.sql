drop extension if exists "pg_net";

drop policy "UsuÃ¡rios podem ver suas prÃ³prias comunhÃµes" on "public"."fellowships";

drop policy "UsuÃ¡rios autenticados podem ver grupos caseiros" on "public"."home_groups";

drop policy "Permitir delete para lideranÃ§a" on "public"."media_resources";

drop policy "Permitir inserÃ§Ã£o para lideranÃ§a" on "public"."media_resources";

drop policy "UsuÃ¡rios autenticados podem ver recursos de mÃ­dia" on "public"."media_resources";

drop policy "UsuÃ¡rios autenticados podem ver postagens" on "public"."posts";

drop policy "UsuÃ¡rios autenticados podem ver perfis" on "public"."profiles";

drop policy "UsuÃ¡rios podem atualizar seus prÃ³prios perfis" on "public"."profiles";

drop policy "UsuÃ¡rios podem criar suas prÃ³prias inscriÃ§Ãµes" on "public"."registrations";

drop policy "UsuÃ¡rios podem ver suas prÃ³prias inscriÃ§Ãµes" on "public"."registrations";

drop policy "UsuÃ¡rios autenticados podem ver retiros" on "public"."retreats";

drop policy "Devs e presbiteros podem gerenciar grupos caseiros" on "public"."home_groups";

alter table "public"."fellowships" drop constraint "fellowships_member_a_id_fkey";

alter table "public"."fellowships" drop constraint "fellowships_member_b_id_fkey";

alter table "public"."posts" drop constraint "posts_author_id_fkey";

alter table "public"."profiles" drop constraint "profiles_discipler_id_fkey";

alter table "public"."profiles" drop constraint "profiles_father_id_fkey";

alter table "public"."profiles" drop constraint "profiles_home_group_id_fkey";

alter table "public"."profiles" drop constraint "profiles_mother_id_fkey";

alter table "public"."profiles" drop constraint "profiles_spouse_id_fkey";

alter table "public"."registrations" drop constraint "registrations_profile_id_fkey";

alter table "public"."registrations" drop constraint "registrations_retreat_id_fkey";

alter table "public"."posts" alter column "category" drop default;

alter table "public"."posts" alter column category type "public"."post_category" using category::text::"public"."post_category";

alter table "public"."posts" alter column "category" set default 'noticia'::public.post_category;

alter table "public"."posts" alter column "category" set not null;

alter table "public"."retreats" alter column "price" set data type numeric(10,2) using "price"::numeric(10,2);

CREATE INDEX idx_profiles_father_id ON public.profiles USING btree (father_id);

CREATE INDEX idx_profiles_mother_id ON public.profiles USING btree (mother_id);

CREATE INDEX idx_profiles_spouse_id ON public.profiles USING btree (spouse_id);

alter table "public"."fellowships" add constraint "fellowships_member_a_id_fkey" FOREIGN KEY (member_a_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."fellowships" validate constraint "fellowships_member_a_id_fkey";

alter table "public"."fellowships" add constraint "fellowships_member_b_id_fkey" FOREIGN KEY (member_b_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."fellowships" validate constraint "fellowships_member_b_id_fkey";

alter table "public"."posts" add constraint "posts_author_id_fkey" FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."posts" validate constraint "posts_author_id_fkey";

alter table "public"."profiles" add constraint "profiles_discipler_id_fkey" FOREIGN KEY (discipler_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."profiles" validate constraint "profiles_discipler_id_fkey";

alter table "public"."profiles" add constraint "profiles_father_id_fkey" FOREIGN KEY (father_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."profiles" validate constraint "profiles_father_id_fkey";

alter table "public"."profiles" add constraint "profiles_home_group_id_fkey" FOREIGN KEY (home_group_id) REFERENCES public.home_groups(id) ON DELETE SET NULL not valid;

alter table "public"."profiles" validate constraint "profiles_home_group_id_fkey";

alter table "public"."profiles" add constraint "profiles_mother_id_fkey" FOREIGN KEY (mother_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."profiles" validate constraint "profiles_mother_id_fkey";

alter table "public"."profiles" add constraint "profiles_spouse_id_fkey" FOREIGN KEY (spouse_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."profiles" validate constraint "profiles_spouse_id_fkey";

alter table "public"."registrations" add constraint "registrations_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."registrations" validate constraint "registrations_profile_id_fkey";

alter table "public"."registrations" add constraint "registrations_retreat_id_fkey" FOREIGN KEY (retreat_id) REFERENCES public.retreats(id) ON DELETE CASCADE not valid;

alter table "public"."registrations" validate constraint "registrations_retreat_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.profiles (user_id, full_name, avatar_url)
  VALUES (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    COALESCE(new.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN new;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.rls_auto_enable()
 RETURNS event_trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$
;


  create policy "Usuários podem ver suas próprias comunhões"
  on "public"."fellowships"
  as permissive
  for select
  to authenticated
using (((auth.uid() = member_a_id) OR (auth.uid() = member_b_id)));



  create policy "Usuários autenticados podem ver grupos caseiros"
  on "public"."home_groups"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Permitir delete para liderança"
  on "public"."media_resources"
  as permissive
  for delete
  to public
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_presbyter = true) OR (profiles.is_deacon = true) OR (profiles.is_dev = true))))));



  create policy "Permitir inserção para liderança"
  on "public"."media_resources"
  as permissive
  for insert
  to public
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_presbyter = true) OR (profiles.is_deacon = true) OR (profiles.is_dev = true))))));



  create policy "Usuários autenticados podem ver recursos de mídia"
  on "public"."media_resources"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Usuários autenticados podem ver postagens"
  on "public"."posts"
  as permissive
  for select
  to authenticated
using ((is_published = true));



  create policy "Usuários autenticados podem ver perfis"
  on "public"."profiles"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Usuários podem atualizar seus próprios perfis"
  on "public"."profiles"
  as permissive
  for update
  to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "Usuários podem criar suas próprias inscrições"
  on "public"."registrations"
  as permissive
  for insert
  to authenticated
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.user_id = auth.uid()))));



  create policy "Usuários podem ver suas próprias inscrições"
  on "public"."registrations"
  as permissive
  for select
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.user_id = auth.uid()))));



  create policy "Usuários autenticados podem ver retiros"
  on "public"."retreats"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Devs e presbiteros podem gerenciar grupos caseiros"
  on "public"."home_groups"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true))))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true))))));


CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


  create policy "Authenticated Upload"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'post-images'::text));



  create policy "Authenticated users can upload avatars"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'avatars'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Public Access"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'avatars'::text));



  create policy "Users can update their own avatar"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));




