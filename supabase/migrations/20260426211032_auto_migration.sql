drop trigger if exists "protect_is_dev_on_update" on "public"."profiles";

drop policy "Devs e presbiteros podem gerenciar grupos caseiros" on "public"."home_groups";

drop policy "Permitir delete para liderança" on "public"."media_resources";

drop policy "Permitir inserção para liderança" on "public"."media_resources";

drop policy "Usuários podem criar suas próprias inscrições" on "public"."registrations";

drop policy "Usuários podem ver suas próprias inscrições" on "public"."registrations";

revoke delete on table "public"."test" from "anon";

revoke insert on table "public"."test" from "anon";

revoke references on table "public"."test" from "anon";

revoke select on table "public"."test" from "anon";

revoke trigger on table "public"."test" from "anon";

revoke truncate on table "public"."test" from "anon";

revoke update on table "public"."test" from "anon";

revoke delete on table "public"."test" from "authenticated";

revoke insert on table "public"."test" from "authenticated";

revoke references on table "public"."test" from "authenticated";

revoke select on table "public"."test" from "authenticated";

revoke trigger on table "public"."test" from "authenticated";

revoke truncate on table "public"."test" from "authenticated";

revoke update on table "public"."test" from "authenticated";

revoke delete on table "public"."test" from "service_role";

revoke insert on table "public"."test" from "service_role";

revoke references on table "public"."test" from "service_role";

revoke select on table "public"."test" from "service_role";

revoke trigger on table "public"."test" from "service_role";

revoke truncate on table "public"."test" from "service_role";

revoke update on table "public"."test" from "service_role";

alter table "public"."test" drop constraint "test_pkey";

drop index if exists "public"."test_pkey";

drop table "public"."test";


  create table "public"."audit_test_vulnerability" (
    "id" uuid not null,
    "data" text
      );


alter table "public"."audit_test_vulnerability" enable row level security;

CREATE UNIQUE INDEX audit_test_vulnerability_pkey ON public.audit_test_vulnerability USING btree (id);

alter table "public"."audit_test_vulnerability" add constraint "audit_test_vulnerability_pkey" PRIMARY KEY using index "audit_test_vulnerability_pkey";

grant delete on table "public"."audit_test_vulnerability" to "anon";

grant insert on table "public"."audit_test_vulnerability" to "anon";

grant references on table "public"."audit_test_vulnerability" to "anon";

grant select on table "public"."audit_test_vulnerability" to "anon";

grant trigger on table "public"."audit_test_vulnerability" to "anon";

grant truncate on table "public"."audit_test_vulnerability" to "anon";

grant update on table "public"."audit_test_vulnerability" to "anon";

grant delete on table "public"."audit_test_vulnerability" to "authenticated";

grant insert on table "public"."audit_test_vulnerability" to "authenticated";

grant references on table "public"."audit_test_vulnerability" to "authenticated";

grant select on table "public"."audit_test_vulnerability" to "authenticated";

grant trigger on table "public"."audit_test_vulnerability" to "authenticated";

grant truncate on table "public"."audit_test_vulnerability" to "authenticated";

grant update on table "public"."audit_test_vulnerability" to "authenticated";

grant delete on table "public"."audit_test_vulnerability" to "service_role";

grant insert on table "public"."audit_test_vulnerability" to "service_role";

grant references on table "public"."audit_test_vulnerability" to "service_role";

grant select on table "public"."audit_test_vulnerability" to "service_role";

grant trigger on table "public"."audit_test_vulnerability" to "service_role";

grant truncate on table "public"."audit_test_vulnerability" to "service_role";

grant update on table "public"."audit_test_vulnerability" to "service_role";


  create policy "Devs e presbiteros podem gerenciar grupos caseiros"
  on "public"."home_groups"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true))))))
with check ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_dev = true) OR (profiles.is_presbyter = true))))));



  create policy "Permitir delete para liderança"
  on "public"."media_resources"
  as permissive
  for delete
  to public
using ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_presbyter = true) OR (profiles.is_deacon = true) OR (profiles.is_dev = true))))));



  create policy "Permitir inserção para liderança"
  on "public"."media_resources"
  as permissive
  for insert
  to public
with check ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.user_id = auth.uid()) AND ((profiles.is_presbyter = true) OR (profiles.is_deacon = true) OR (profiles.is_dev = true))))));



  create policy "Usuários podem criar suas próprias inscrições"
  on "public"."registrations"
  as permissive
  for insert
  to authenticated
with check ((profile_id IN ( SELECT profiles.id
   FROM profiles
  WHERE (profiles.user_id = auth.uid()))));



  create policy "Usuários podem ver suas próprias inscrições"
  on "public"."registrations"
  as permissive
  for select
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM profiles
  WHERE (profiles.user_id = auth.uid()))));


CREATE TRIGGER protect_is_dev_on_update BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION handle_is_dev_protection();



