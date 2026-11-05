-- ============================================================================
-- SCRIPT DE SEEDING REAL (CENSO): IGREJA EM BELO HORIZONTE
-- Dados oficiais das planilhas importados com fidelidade estrita.
-- Sem criação de emails, telefones, CPFs ou dados socioeconômicos falsos/inventados.
-- Os discípulos reais (exceto as 3 contas indicadas) tornam-se phantom users e crianças.
-- Contas autenticadas (auth.users): exatamente 3 (Gabriel, Fernando e Clara).
-- ============================================================================

DO $$
DECLARE
  pwd_hash text := '$2a$06$XqL/cRckHcXJ1xzAYPKQUORulnZ8gYmOlK1FwEvihHPa7trFLTl9.'; -- 'senha123'
  gabriel_id   uuid := '5afba49b-ad18-4478-ae3c-0c398bb5b6b2';
  fernando_id  uuid := '2103520c-3b54-4b08-96d0-fbdfd6d40688';
  clara_id     uuid := '0b530795-5001-42f5-a44a-0dbe275abb65';
  flavio_id    uuid := '9e8c8eb7-b83b-4fed-aaf9-df5a5c3c0a72';
  marleide_id  uuid := 'b1ba07d0-2b46-4b64-901a-067d3ba5487b';

  gabriel_auth_id  uuid := '00000000-0000-0000-0000-000000000001';
  fernando_auth_id uuid := '00000000-0000-0000-0000-000000000002';
  clara_auth_id    uuid := '00000000-0000-0000-0000-000000000003';

  -- Retiros
  r_retreat_active uuid := '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc';
  r_retreat_closed uuid := 'a1b2c3d4-e5f6-47a8-b9c0-112233445566';
  r_retreat_draft  uuid := 'b2c3d4e5-f6a7-48b9-c0d1-223344556677';

  -- Quartos do Evento Ativo
  r_act_chale_m1 uuid := 'd1000000-0000-0000-0000-000000000001';
  r_act_chale_m2 uuid := 'd1000000-0000-0000-0000-000000000002';
  r_act_dorm_m3  uuid := 'd1000000-0000-0000-0000-000000000003';
  r_act_chale_f1 uuid := 'd1000000-0000-0000-0000-000000000004';
  r_act_chale_f2 uuid := 'd1000000-0000-0000-0000-000000000005';
  r_act_dorm_f3  uuid := 'd1000000-0000-0000-0000-000000000006';
  r_act_suite_1  uuid := 'd1000000-0000-0000-0000-000000000007';
  r_act_suite_2  uuid := 'd1000000-0000-0000-0000-000000000008';

  -- Quartos do Evento Encerrado
  r_cls_dorm_m1  uuid := 'd2000000-0000-0000-0000-000000000001';
  r_cls_dorm_f1  uuid := 'd2000000-0000-0000-0000-000000000002';
  r_cls_suite_1  uuid := 'd2000000-0000-0000-0000-000000000003';
  r_cls_suite_2  uuid := 'd2000000-0000-0000-0000-000000000004';
  r_cls_chale_m2 uuid := 'd2000000-0000-0000-0000-000000000005';
  r_cls_chale_f2 uuid := 'd2000000-0000-0000-0000-000000000006';

  -- Recursos de Mídia
  m_res_id1  uuid := 'e0000000-0000-0000-0000-000000000001';
  m_res_id2  uuid := 'e0000000-0000-0000-0000-000000000002';
  m_res_id3  uuid := 'e0000000-0000-0000-0000-000000000003';
  m_res_id4  uuid := 'e0000000-0000-0000-0000-000000000004';
  m_res_id5  uuid := 'e0000000-0000-0000-0000-000000000005';
  m_res_id6  uuid := 'e0000000-0000-0000-0000-000000000006';
  m_res_id7  uuid := 'e0000000-0000-0000-0000-000000000007';
  m_res_id8  uuid := 'e0000000-0000-0000-0000-000000000008';
  m_res_id9  uuid := 'e0000000-0000-0000-0000-000000000009';
  m_res_id10 uuid := 'e0000000-0000-0000-0000-000000000010';

  -- Estudos
  study_id1 uuid := 'd0000000-0000-0000-0000-000000000001';
  study_id2 uuid := 'd0000000-0000-0000-0000-000000000002';
  study_id3 uuid := 'd0000000-0000-0000-0000-000000000003';

  -- Steps
  step_id1 uuid := 'f0000000-0000-0000-0000-000000000001';
  step_id2 uuid := 'f0000000-0000-0000-0000-000000000002';
  step_id3 uuid := 'f0000000-0000-0000-0000-000000000003';
  step_id4 uuid := 'f0000000-0000-0000-0000-000000000004';
  step_id5 uuid := 'f0000000-0000-0000-0000-000000000005';
  step_id6 uuid := 'f0000000-0000-0000-0000-000000000006';
  step_id7 uuid := 'f0000000-0000-0000-0000-000000000007';
  step_id8 uuid := 'f0000000-0000-0000-0000-000000000008';

BEGIN
  -- ==========================================================================
  -- 1. LIMPEZA TOTAL ATÔMICA
  -- ==========================================================================
  TRUNCATE 
    public.profiles, 
    public.home_groups, 
    public.sectors, 
    public.posts, 
    public.fellowships, 
    public.retreats, 
    public.registrations, 
    public.retreat_rooms, 
    public.retreat_expenses, 
    public.event_coupons,
    public.event_waitlist,
    public.forms, 
    public.form_submissions, 
    public.media_resources,
    public.studies,
    public.study_steps,
    public.user_study_progress,
    public.study_notes
  CASCADE;
  
  DELETE FROM auth.users;

  -- ==========================================================================
  -- 2. CRIAÇÃO DOS SETORES METROPOLITANOS (6 Setores Reais)
  -- ==========================================================================

  INSERT INTO public.sectors (id, name, created_at) VALUES ('79f4a91d-91ae-47ef-ad6f-dd31d9607ae7', 'São Gabriel/Pampulha', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('56fff349-ed6a-478a-8d1f-343d5754ec5f', 'Venda Nova/Neves', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('4f6e492b-1d03-4766-b2cb-49997cec4b6a', 'Santa Luzia', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('eae6f60f-d201-484a-ae9a-046d9c66dbe9', 'Oeste', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('26f32935-760f-4e1d-989c-bbb217ac6202', 'Betim/Contagem', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('e600f073-d478-41e6-bef7-e2d34b70f2aa', 'Fora da Localidade', now());

  -- ==========================================================================
  -- 3. CRIAÇÃO DOS GRUPOS CASEIROS (35 Grupos Reais das Planilhas)
  -- ==========================================================================

  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', '79f4a91d-91ae-47ef-ad6f-dd31d9607ae7', 'Solimões - BH - Bairro Solimões', 2, '19:30:00', -19.8392, -43.9185, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', '79f4a91d-91ae-47ef-ad6f-dd31d9607ae7', 'Heliópolis - BH - Bairro Heliópolis', 3, '19:30:00', -19.8425, -43.9482, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b73e2026-ca22-46d2-a294-3379ba996162', '79f4a91d-91ae-47ef-ad6f-dd31d9607ae7', 'São Gabriel - BH - Região São Gabriel / Pampulha', 4, '19:30:00', -19.858, -43.916, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', '79f4a91d-91ae-47ef-ad6f-dd31d9607ae7', 'Santa Amélia - BH - Rua Pioneiros da Paz, Santa Amélia / Rua Hildebrando de Oliveira 65, Copacabana', 5, '19:30:00', -19.8361, -43.9724, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', '79f4a91d-91ae-47ef-ad6f-dd31d9607ae7', 'Jardim Vitória - BH - Bairro Vitória / Jardim Vitória', 6, '19:30:00', -19.8456, -43.8891, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3c9a69a9-8258-456a-974e-2983cadd701c', '56fff349-ed6a-478a-8d1f-343d5754ec5f', 'Santa Branca - BH - Rua Norte, 42, Santa Branca - BH', 2, '19:30:00', -19.8268, -43.9685, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '780ea854-7cec-4230-81c9-e4a43041f7bc', '56fff349-ed6a-478a-8d1f-343d5754ec5f', 'Santa Branca - BH - Rua São José do Jacuri, 135, B. Santa Branca', 3, '19:30:00', -19.8245, -43.966, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', '56fff349-ed6a-478a-8d1f-343d5754ec5f', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 (Casa do Marinho) - Maria Helena', 4, '19:30:00', -19.7985, -44.0092, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'eaae323c-6926-4482-b7e1-152da4f9648d', '56fff349-ed6a-478a-8d1f-343d5754ec5f', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 - Maria Helena', 5, '19:30:00', -19.7992, -44.0105, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', '56fff349-ed6a-478a-8d1f-343d5754ec5f', 'Leblon - BH - Rua Olga Pimenta Guimarães, 204 - Leblon', 6, '19:30:00', -19.8115, -43.988, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', '56fff349-ed6a-478a-8d1f-343d5754ec5f', 'Sevilha B - Ribeirão das Neves - Rua São João Del Rei, 270, Sevilha B', 2, '19:30:00', -19.7695, -44.0812, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', '56fff349-ed6a-478a-8d1f-343d5754ec5f', 'Areias - Ribeirão das Neves - Rodízio (Areias / Morro Alto)', 3, '19:30:00', -19.782, -43.985, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', '4f6e492b-1d03-4766-b2cb-49997cec4b6a', 'Santa Matilde - Santa Luzia - Rua Geraldo Ferreira Rabelo, 169, Santa Matilde', 4, '19:30:00', -19.7668, -43.8582, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'd852fddc-538e-4434-9e2f-1872b5f5efba', '4f6e492b-1d03-4766-b2cb-49997cec4b6a', 'Lagoa Santa - Lagoa Santa', 5, '19:30:00', -19.6328, -43.8906, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'bc732207-f7f7-4188-b406-999197ee1a67', '4f6e492b-1d03-4766-b2cb-49997cec4b6a', 'São Benedito - Santa Luzia - Bairro São Benedito', 6, '19:30:00', -19.7825, -43.9145, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '8bb4d727-bff7-4347-8711-097903498d0b', '4f6e492b-1d03-4766-b2cb-49997cec4b6a', 'Fazendinha do Baú - Santa Luzia - Rua Presidente Roosevelt, 1107 - Fazendinha do Baú - Santa Luzia', 2, '19:30:00', -19.7755, -43.872, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', '4f6e492b-1d03-4766-b2cb-49997cec4b6a', 'Córrego das Calçadas - Santa Luzia - Av. Engenheiro Felipe Gabrich, nº 734, Córrego das Calçadas, Santa Luzia', 3, '19:30:00', -19.759, -43.851, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'dc39ae48-1c0a-43dd-9c67-955424049020', '4f6e492b-1d03-4766-b2cb-49997cec4b6a', 'Cristina B - Santa Luzia - Rua Mila Bernardina da Rocha, 85, Cristina B, Santa Luzia/MG', 4, '19:30:00', -19.7762, -43.9248, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', 'eae6f60f-d201-484a-ae9a-046d9c66dbe9', 'Novo Tirol - BH - Rua Macadâmia, 168, Novo Tirol - BH', 5, '19:30:00', -19.9985, -44.0315, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '0300704e-9660-4329-82ec-bae2f470555c', 'eae6f60f-d201-484a-ae9a-046d9c66dbe9', 'Milionários - BH - Rua dos Atleticanos - Milionários', 6, '19:30:00', -19.981, -43.9965, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', 'eae6f60f-d201-484a-ae9a-046d9c66dbe9', 'Tropical / Quintas do Jacuba - Contagem - Estrada Chico Mendes, 900 - Quintas do Jacuba - Contagem', 2, '19:30:00', -19.9265, -44.115, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'de250387-80f7-476c-bd90-3e628d41177a', 'eae6f60f-d201-484a-ae9a-046d9c66dbe9', 'Novo Progresso - Contagem - Rua Paraopeba, 184, Novo Progresso', 3, '19:30:00', -19.898, -44.039, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', 'eae6f60f-d201-484a-ae9a-046d9c66dbe9', 'Bela Vista / Barreiro - Ibirité - Rua Melo de Souza Maia, 101, Bela Vista', 4, '19:30:00', -20.008, -44.052, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'cf018409-11b8-49f4-bda3-1355e961ede8', 'eae6f60f-d201-484a-ae9a-046d9c66dbe9', 'Salgado Filho - BH - Rua Ibiraci, 250 - Bairro Salgado Filho - BH', 5, '19:30:00', -19.9412, -43.9825, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', 'eae6f60f-d201-484a-ae9a-046d9c66dbe9', 'Nova Suíça - BH - Rua Lindolfo de Azevedo, 608, Nova Suíça - BH', 6, '19:30:00', -19.9445, -43.9734, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', '26f32935-760f-4e1d-989c-bbb217ac6202', 'São José - Esmeraldas - Rua Américo França Abreu, 257, São José, Esmeraldas', 2, '19:30:00', -19.7615, -44.314, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', '26f32935-760f-4e1d-989c-bbb217ac6202', 'Jardim Riacho das Pedras - Contagem - Rua Urânio, 114, Jardim Riacho das Pedras - Contagem', 3, '19:30:00', -19.9565, -44.041, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3ab969d3-5651-4fff-80bd-fe37a0172322', '26f32935-760f-4e1d-989c-bbb217ac6202', 'Marimbá - Betim - Sítio da Igreja (Marimbá / Juatuba)', 4, '19:30:00', -19.932, -44.275, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', '26f32935-760f-4e1d-989c-bbb217ac6202', 'Resplendor - Igarapé - Rua Bahia, 131, Resplendor - Igarapé', 5, '19:30:00', -20.068, -44.298, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '19c3d488-f5ec-4c49-92dc-db860e68436c', '26f32935-760f-4e1d-989c-bbb217ac6202', 'Jardim Alterosa / Santo Antônio - Betim - Rua Limoeiro, 337, Santo Antônio - Betim', 6, '19:30:00', -19.961, -44.172, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '68b0180f-7326-4450-aaba-57207a9c9a6f', '26f32935-760f-4e1d-989c-bbb217ac6202', 'Três Barras - Contagem - Rua Gentil Diniz, 441 - Três Barras - Contagem', 2, '19:30:00', -19.9145, -44.0885, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', '26f32935-760f-4e1d-989c-bbb217ac6202', 'Eldorado - Contagem - Rua José Barra do Nascimento, 1971, Eldorado - Contagem', 3, '19:30:00', -19.938, -44.0395, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '23649e02-ef06-432f-bf46-152999cfa58c', '26f32935-760f-4e1d-989c-bbb217ac6202', 'Ponte Alta - Betim - Condomínio Ouro Verde, Bairro Ponte Alta - Betim', 4, '19:30:00', -19.896, -44.203, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '14b033e6-3519-4436-b716-f99189a7b01d', 'e600f073-d478-41e6-bef7-e2d34b70f2aa', 'Interlagos - Sete Lagoas - Rua Antônio Domingos da Silva Filho, 307, B. Interlagos - Sete Lagoas', 5, '19:30:00', -19.4752, -44.2368, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', 'e600f073-d478-41e6-bef7-e2d34b70f2aa', 'Santa Bárbara - Santa Bárbara / Barão de Cocais', 6, '19:30:00', -19.9595, -43.415, now()
  );

  -- ==========================================================================
  -- 4. POVOAMENTO DOS DISCÍPULOS (821 Perfis Reais das Planilhas)
  -- Somente Gabriel, Fernando e Clara recebem dados de contato/autenticação.
  -- Os demais 818 discípulos são armazenados puramente como phantom users / crianças.
  -- ==========================================================================

  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '83dc56e9-4e30-49d8-9b05-156f3482872f', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', 'Solimões', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Presbitério', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b1ba07d0-2b46-4b64-901a-067d3ba5487b', 'Marleide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', 'Solimões', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Esposas dos Presb.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c01e7102-e725-484a-a5e1-f7bcee3a00eb', 'Mateus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Solteiro(a)', 'Solimões', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '38b42dac-e550-4ec2-abf3-48753c42e675', 'Mariana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Solteiro(a)', 'Solimões', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Karina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a21b1d50-ceb5-43b4-8a7a-24526472779e', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '394a6e33-9fa5-47f0-be1b-3ff549951b34', 'Soely', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dc0ad390-9421-454a-a25f-31454fc290dd', 'Cleber', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0c5dcb2f-9f4c-4730-9fe2-3f5c21427c92', 'Ana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '97e4694b-3218-4187-9300-c0f42c79e9be', 'Euller', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1394e852-8f65-41c4-9603-4f0721fea0e9', 'Wellington', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4d3f179a-2501-47d6-9489-1f9657ca3b06', 'Luciana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '71b0b33f-7009-4967-a752-ee5a4acbea9f', 'Edmilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Wellington', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '53491e75-6ff8-447e-8056-4497a20c0c01', 'Joana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luciana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1a171122-d08a-4d37-8bc3-c8ee23409f92', 'Agatha', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2e50c12a-5e01-4671-9dab-045bb5408925', 'Mariângela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cinara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4f397146-3904-4c20-91b9-fdde5ff596cb', 'Breno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '83a50912-99cf-47b1-bc98-80cb9fbaba29', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7802d16e-a1c5-404b-9141-3a15a1e472a7', 'André', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '829596bb-197d-4d12-b116-ae0dd6ddc001', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6e2edad1-ba7f-4aff-ad40-8ea6383a88ff', 'Daniel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '12a25ecf-eed8-4736-9092-e199c32cdaaf', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e923d185-7fb5-4d9a-a07e-5779ddb23869', 'Elis', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2103520c-3b54-4b08-96d0-fbdfd6d40688', 'Fernando Gomes Braga', 'fgb80@yahoo.com', NULL, NULL, '1980-07-18'::date, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, true, false, false, true,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0b530795-5001-42f5-a44a-0dbe275abb65', 'Clara Góes Braga', 'claradiscipula@gmail.com', NULL, NULL, '1983-06-16'::date, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5601fca6-dcbe-4562-9802-f45a8afcce0a', 'Artur', NULL, NULL, NULL, '2019-09-09'::date, NULL, false, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5afba49b-ad18-4478-ae3c-0c398bb5b6b2', 'Gabriel Góes Braga', 'ggoesbraga@gmail.com', NULL, NULL, '2008-04-02'::date, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, true, true,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '28f0fc53-ccf1-4738-b8ca-a4fcc5a265f8', 'Maria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Liberdade', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '27f07df4-afd7-40a5-bc8c-77a96afb0bc6', 'Marina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Liberdade', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9546cfdc-e269-4e57-a7bc-944e5fe4bf0a', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Liberdade', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '30e83f1a-11a3-4126-8a3a-2f7d36f0b394', 'Deia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '788e56dd-a515-49bc-97a3-d2a1d34380aa', 'Marivaldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thiago Duarte', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '222a9f5e-069d-4cb3-9fe1-3f4560b38b2d', 'Luciene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Paulinha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c85b8141-3184-4164-ac5a-71eb58abecaf', 'Ramon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Ouro Preto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c34d4568-7b31-484f-8e06-dcf74b136392', 'Margareth', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Ouro Preto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '34dc7595-4487-4743-aba2-19fab3a44253', 'Renan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Itapuã', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0cd68fba-8240-4008-b4a6-c046e424534a', 'Arlete', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Itapuã', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '166f498c-48be-4ec4-abe3-8aedee69e007', 'Ricardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e535df0a-7307-40dd-8085-077cc52808c2', 'Priscila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91edc2b6-da4b-426b-949c-19bb70bf6c5e', 'Cecília', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2d38acf7-3731-4c05-8565-e19b91691624', 'Hugo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd6be1ebf-2ce8-43fb-b2c8-fb6bc363b497', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Dona Clara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f21319b2-9c6d-4443-8cb1-22d4af1f48a2', 'Sarah', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Casado(a)', 'Dona Clara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3cc4bb4f-201d-46d3-8352-ac6f57dc96e3', 'Matheus', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Dona Clara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aac8a47e-99f8-4ad7-a0e5-332e880ed385', 'Pedro', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Dona Clara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ab77cb34-6607-4aa7-8ed3-db2f72a67384', 'Marlon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6c3575cf-1535-4755-9078-e6799c7cdc6c', 'Maura', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Santa Cruz', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '33030957-f988-4b51-873e-34f03b4c1852', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '43a87279-c2a3-44df-9b70-6b1314934124', 'Samuel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '03d3d166-3090-44a0-805a-b76d19a6210a', 'Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '09d1911d-4681-413c-b258-65596b1e6078', 'Zoraide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Santa Cruz', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6f54c7dd-6bf3-44de-80f2-8e4f992b7a60', 'Miriã', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Ouro Preto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a4e0da27-57f6-4427-9256-2153549abcb6', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Maria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bc32de95-ae0d-4e6e-8853-110b8c274e94', 'Samuel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '39f5e786-724f-48f1-bf6f-21bb789b8d9f', 'Wanderlaine', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Arlete', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd02065b3-c0d9-4a22-b122-8e0838f1ecc8', 'Ismael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4af7a72c-0da6-4a64-bf7d-c55aa68137d7', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fransérgio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6f2576eb-f800-41ee-b80c-57b3359867e8', 'Emerson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3b10f967-608d-470a-96ae-98a898410310', 'Neide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e0fca23e-125a-4eb7-9d12-0a4bda6a02f8', 'Walace', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dc9d344b-2497-4c57-906d-7cd5f7e619ba', 'Sabrina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3559b2ac-d460-4459-bd47-aa48ec3e7bfe', 'Carol', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1de98373-3024-4b8d-ae39-fe3d1848c283', 'Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9707fc03-3279-4be2-b46f-a24dd9ab24d4', 'Fernando', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1c2618fc-7458-43a4-b0ff-a0b29d228dea', 'Adriana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f11a2636-9554-47e6-b9fb-ab08b525d29b', 'Marcelo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '810733a5-3ce6-4f55-9837-fed9f9ab41b5', 'Cristina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cccaf427-9b05-4e59-a2ac-8e7a857a3dd5', 'Tales', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1e49b669-6156-4323-bc26-a92aa3112fd1', 'Edna', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '186f6670-23dd-4279-9b39-cc154c909bfc', 'Thiago', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '59031464-f3b9-4eaf-8b5a-5f156e8476be', 'Ana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e4a3280b-7173-4cae-8995-89d54d20f457', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0e0174b8-c98b-423d-b150-8cad415a0ac3', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '28eb3e84-4847-4cd4-b218-28d055c380fd', 'Carlos Eduardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b62580db-05f2-458d-8e9b-eaa5ffddedbb', 'Joelma', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f71e670f-576d-45a3-8435-9fd0ba68924f', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0600f041-2f00-4ba5-9140-9d3752f3638b', 'Rafael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5aa43d91-c800-4b01-82ae-633d9fdfadfc', 'Ana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4079f663-01a4-4d69-98ab-1d05ce7a6fa0', 'Bruno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '85cbebb3-02c8-4d1b-a33e-0a10a7e89d4a', 'Grace', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6044f1d7-0e39-4598-a7f5-e88fe8b9ea06', 'João', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3826197e-e8b9-4d91-b065-a3212a7a5032', 'Lutero', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6dd3d2ef-0fa4-4f29-b34b-1f0906373ad9', 'Dominique', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8545b45d-627e-4c3b-ad2c-5a6932022a51', 'Kaleu', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ee9ab34-ceea-4f9f-9ff6-b576ea3ff1f6', 'Vivian', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c5f97636-36e9-4717-9baa-b98985d5c429', 'Marilda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91c321ad-6af7-4fc3-a9a7-e02908e8839e', 'Vanessa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9de8acdf-dfff-46fb-8624-ccc908a3defe', 'Enzo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '357a9463-3331-4766-bc69-d6e92de8426d', 'Daniele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ab1f1ed9-4a69-4104-a4a6-d0923d7cce03', 'Luciene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a557f6dd-208f-4185-8264-40871dd5617f', 'Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c214e140-a9e9-4f0b-b61a-e5e24caf2756', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7754fd1e-461b-48a0-9fc8-d84afe26325b', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '535324e0-757b-4c8b-841c-867e0bd48ea8', 'Antonela', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '51a3bc47-e6b0-4608-a7f6-73c70bdd7df6', 'Luiz Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '68a357e5-c22c-44fc-b825-1d477a0d76ea', 'Juliana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9455b964-07a9-4127-9167-362c7db4d19c', 'Amélia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ce46cd12-26bf-46ce-8766-d3db425b0770', 'Felipe', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e06188be-384d-44e3-8ced-0921401067fe', 'Tamara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '68221963-f337-4c98-8375-194da3a2e5de', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '34c0d78b-b7ad-4b95-b1fe-ad4f4747f695', 'Ciça', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6c692f69-7c4a-4af1-993c-e5f631fcf284', 'Mariana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9a26c680-1e45-4f1e-b574-ef5c3f6218c7', 'Henrique', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '20e49021-a76f-4fac-b804-cde96bf3eca7', 'Vivian', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'b73e2026-ca22-46d2-a294-3379ba996162', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0cb227a2-c276-4e02-b7e7-727daef77a2b', 'Eduardo Lopes', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd2c6f368-1999-4a98-b996-f527af0c9410', 'Érica Lopes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '056f1efa-e1fb-4501-b14d-c715230e9279', 'Laura Lopes', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '487f5f4f-0920-4545-8c1b-bab397f93c5c', 'Eduardo Filho', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9a1a9404-6f72-48ea-9902-89f0a908af65', 'Luís Filipe', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2c85e7af-b645-4e9f-817f-c1c46606ce6d', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eduardo Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b6675f94-21df-4be9-85a4-e58d4c2ac727', 'Juliana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érica Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fd01a388-f7d8-4c18-80ed-ddb6de4b524b', 'Henrique Filho', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '181e0994-afc2-4247-884c-c1546ccf24cf', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4bbd0433-d8b7-4c33-abd7-feba3aa9a1e3', 'Lucas Oliveira', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eduardo Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '836ed079-f6af-48ba-9a6f-18afc6b5bca0', 'Raíssa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érica Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3b61f3ac-17d6-47af-9032-803f548aed1a', 'Lian', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'db644e72-02ee-46b5-a13d-3bae9d8409bb', 'Pietro', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e583f2a3-ea7c-4a43-aa50-b27bb0ee3d5f', 'Danilo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eduardo Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd25d3712-71a7-442a-8ebb-9c5943b6a0ef', 'Melry', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érica Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b2553b39-71c6-4b33-b04c-a925df764b8c', 'Henrique', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '41356f18-750e-4c61-bf12-9f1b86749d3b', 'Sofia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1d54d962-4692-4800-8d96-2c009606209d', 'Mateus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Pedreiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Paulo Henrique', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ebe9459a-5008-4364-9bc0-e5ba918460a6', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Pedreiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juliana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bc3af917-f595-4786-8b64-f9dbfdd4f55d', 'Davi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Pedreiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '418532ed-437a-4bdb-a6b6-24d530562f4d', 'Josinha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Pedreiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Paula Emanuela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8eb27ef8-c053-4080-96ca-ac23d469aac3', 'Thiago Bombeiro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '15228aa0-4dd6-4aff-9d62-0a91cd7e6cf8', 'Paula Emanuela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '82dd45db-6b34-40fd-99c4-f5f918667c41', 'Ana Luiza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Karina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '504bd805-ce05-4a2e-8d26-d98809057a3c', 'Aline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ana Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fe099be3-8651-4f90-a06f-7c7fc108f062', 'Thiago Filho', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a2c78812-e577-4855-a98b-074f8ab19ae8', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Céu Azul', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érica Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0b02c06b-e3a9-42d1-a0f7-73156a5fcce5', 'Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Céu Azul', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Didier', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6b78f535-d14f-40cc-a947-b5ca83d4770d', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Céu Azul', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ce50357-665f-4140-a172-90ecc5f8c98a', 'Bruno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Braúnas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eduardo Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f1b261ea-62a7-4b09-971e-2ebb9a1f5b94', 'Miriã', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Casado(a)', 'Braúnas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Raíssa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f499b6a8-3755-4066-9339-525e84fe05d2', 'Nikole', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Braúnas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ana Luiza', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cde6c273-b057-4637-8a86-e72d554db149', 'Brenda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ee1436f0-0657-4257-a61a-e2d1f1c57928', true, false, false, false, false,
    'Solteiro(a)', 'Santa Cruz', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '03c9d7ae-f5e1-4a04-8a04-db72a03af805', 'Ademir', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1ebfc994-a0a7-49fe-9e7d-e5b68694c034', 'Janaína', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1beda4ed-3905-4819-9b72-ae145d40c0bb', 'Emanuela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ee472bcc-ad4e-4494-8e39-49caa170e82c', 'João Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6799c625-cab0-4dd8-af59-5aa393a0e0ef', 'Julião', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8e4f91b5-aa21-404d-874c-7e56c390fc84', 'Darlene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '78a66208-2834-48d1-9c80-e9bdc380ea32', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9101b9f3-757d-471d-8f98-f3878f87d176', 'João Francisco', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Silas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b0c3948e-568f-451a-8d41-2a859e5e7794', 'Ana Beatriz', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '74a38e72-d95c-44fe-bf68-702933ebb38f', 'Elias', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ademir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd8480bea-4379-4eb4-9bbf-3e230a8e9c84', 'Fabiana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ademir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0003c1d2-68a1-4ca2-9d3c-d8ef601c553f', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '75873190-af0f-4f2f-9e77-78c545d51b1e', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carla', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6ff738f2-72ed-4d0e-9580-2f90facfdc93', 'Luiz Filipe', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ademir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb04150e-d431-40f0-93b3-d643eb309d38', 'Jéssica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c2d613f1-2a77-44ac-9ed6-30bf4862863a', 'Ester', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c10db12a-4c72-4621-93f3-0018d14b0927', 'Gabriel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6f23a91d-ba6f-4f44-9930-336e6eb0bab7', 'Thainara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janaína', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '22ac7613-e4ce-4366-9d84-6e1e401c9f3c', 'Lucas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '94cbbff0-79a6-46c8-9871-6314d0bccb0e', 'Laila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jéssica', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c8a353af-79a3-4834-89a9-640d19672370', 'Evenly', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'edc1547a-81e0-432f-9e33-19099e5b3df3', 'Luís', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '301635ba-608c-4562-8846-a9271c88cd22', 'Antony', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '291e1043-7b21-4462-9afa-19a77c5cc011', 'Carla', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janaína', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4dbc1d52-c77a-43ee-a8e6-5e6ca1afbed5', 'Laiana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jéssica', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7a9ac7b5-b8dc-4183-8b59-9f216392cb6f', 'Luciana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janaína', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9a01c865-c092-4da4-aa8b-7e09b766943e', 'Riquelmer', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luiz Filipe', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '786cb449-fd50-4837-b231-dd5bb08a7afa', 'Caíque', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luiz Filipe', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1b888fda-349b-4df6-bd5e-09bf3afa7c37', 'Silas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luiz Filipe', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e668b98e-fd7f-4766-af6f-9797ef9e7bfe', 'Juraci', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carla', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '89a45ff7-b276-4925-ae3a-8a6e1ea835be', 'Luizão', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Julião', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f6116ebb-8d7d-4b36-b283-a18314bc4d88', 'Amanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janaína', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '14ceea4e-0c3d-4f11-85e9-6aec2af7693a', 'Valentina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'afa3596f-9f51-4167-b903-998fd613c701', 'Juscelino', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0c7104d8-12d7-4f25-bcb7-99bcb9be8154', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ademir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '80d39d4c-d1bb-48f2-a63f-443fbeca8cb4', 'Helder', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bb34e22c-b89b-4e16-b11f-239304fd5ed8', 'Vivian', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide / Gina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '88cf4203-9a6c-473c-9d73-b1608ee8b431', 'Jonata', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6963fca1-36f3-4935-9f86-caf837205965', 'Francérgio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '24065499-8fd5-436e-a812-b80cc5ef5a48', 'Juliana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa do André', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3f8105ba-4aee-4d28-88bb-3b05e9e8f697', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Stejane do Magela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f6a2535f-462d-4b18-9601-a9add93fd611', 'Kennedy', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fd865321-ac50-4899-a46c-9a18297dd6a5', 'Bárbara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vivian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '550afe05-4048-4447-a5f1-e3e8180edb3f', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vivian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91e03460-d824-44d7-9569-402cbcff02cb', 'Pricila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lilian do Elvis', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b3335703-0ab4-4e8c-a949-31fc949c853c', 'Luciano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3f08a58a-49d5-455a-947b-3b34570b77ac', 'Lilian', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vivian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ae920030-ba71-42f1-a802-166c4c5a0ae1', 'Tiago', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel da Wanderlaine', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bebfc601-acec-4d1a-b5d5-ef7be99b7bf8', 'Miguel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel da Wanderlaine', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dc907f36-414e-4d24-81c8-fc5e24992557', 'Breno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel da Wanderlaine', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5193c8e3-738c-422f-bcaa-5d041b95d3a4', 'Taiane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Meury', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5d7233a7-cfc7-42c5-822c-7a8fd6840694', 'Henrique', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Danilo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7746c9d3-0e9c-4c7d-ab75-f8fafde6ac3d', 'Rhuan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kennedy', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd0f52040-6a2b-4a3d-b8ae-527159b7f374', 'Gabriele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Bárbara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3b3ffa6c-3651-4ce1-80c4-fe4942a36bc4', 'Vanessa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Bárbara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c50972a8-c012-465e-8f2a-1c6d91c30e87', 'Polyana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marcela do Marcelo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0ddfd5ab-fa7e-421d-a73b-4c47d26f9f59', 'Maria Clara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Taiane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '210ab579-2593-427b-b61e-a8149ae76979', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara do Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6c1d21e9-e234-4a7d-bcf3-b14fe61732f3', 'Júlia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Pricila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6f84ffeb-7cd7-44c2-a5cb-9a2af86d8a1d', 'David', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3c9a69a9-8258-456a-974e-2983cadd701c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jonata', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '90976735-8ffa-49bc-a83f-08ac0ba1ef6b', 'Juarez', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Casado(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4e530a13-634c-40eb-bfbb-75cdc11bcc92', 'Divina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Casado(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '17b191b7-2fa9-4d87-9d02-b70de72c6e7d', 'Argeu', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juarez', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eb956c00-fe27-498c-ac9a-109ec724cd84', 'Lora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Divina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd12bb9b3-03ef-403f-8c23-d2757e5830f4', 'Sérgio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juarez', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0c7a08b7-c694-4247-9384-78f7684a8f46', 'Karina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Divina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8b7f0f9c-2527-4109-810d-97e74741572c', 'Emanuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b379882e-e857-4023-b652-ace29d8abda7', 'Daniel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '32e3dbd1-7837-43f2-bc69-d5889968d10a', 'Lúcia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Divina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '55c4a62a-dd29-4ef2-adcc-63bb51fa4352', 'Mundica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7615efc4-6adc-45ee-a847-91fca1771ca7', 'Janir', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lúcia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e9be6142-d4cd-42f8-8cf0-d171e290dfe7', 'Cristiano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Argeu', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c0cff7be-9aad-4389-ac3b-783f1fdc9dfa', 'Vanessa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0fe8da08-fd5b-4e1e-b10a-884e6b4d2b19', 'Caio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '780ea854-7cec-4230-81c9-e4a43041f7bc', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jonatas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fad32082-0fbb-4c0f-a3d6-44f175147f3b', 'Marinho', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e0c021b5-3aeb-45c0-b63f-3226b11a291c', 'Quênia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '17e08ffe-27cf-44cc-86f2-8195c417e54b', 'Karina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a9e724a7-311c-452b-adc9-78139dc49d18', 'Jonas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jonata', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '10f2efff-a9bf-4e93-a4a5-4ee7c73bb84a', 'Wellington', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b6384c28-b589-4ea0-a152-c332fa63615c', 'Raquel', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd85c0813-d6e5-43d8-8a6a-bb8aa5d90664', 'W. Júnior', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f4b7faed-3a1a-4623-9ac5-9da45b30bffc', 'Carlinho', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '828d72a6-a632-4adc-b497-2dc1dfe0fee5', 'Graziela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rosimeire', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '041f8d12-1bdb-4684-9338-6a1e91f2f8db', 'João', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '10bf51cf-8adc-4777-941d-d86fa0bf833d', 'Alexandre', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9a46667d-67a2-457d-b555-9b637017c3c2', 'Érica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2a6fb28f-1ee0-41c7-a29d-1502a0159c6b', 'Benjamim', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '197f8dd1-f65f-406d-b8e6-2b4e71c4d96e', 'Marcelo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91af39e3-6ccc-41f7-ad63-9e5461451194', 'Eliete', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ad65b39c-6fba-4111-8353-6036446a5ef4', 'Amanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliete', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd49f6858-4aca-4ddc-985b-977ae5404c6c', 'Marcela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Josinha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '17a0709c-7cbb-4ac1-ae26-cb614a26cb63', 'Zezinho', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '16261a18-6bc6-45da-8254-22818ad7b083', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3e629038-47e5-4efb-9fc3-5b96a2490247', 'Cida Santos', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1a4d1815-c679-4da1-b98f-379d0d5aeb84', 'Cida Lopes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a5e57687-a82e-4cb2-bc0d-1bb79a223c92', 'Mateus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Didier', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '33084406-ca3d-4622-808d-27e5bcdca02d', 'Cleuza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '188fca05-b61c-4b2f-8d13-e2a5ee12cd3d', 'Alice', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliete', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '443ac9dd-9f1f-4b54-94c3-6022e34b9c41', 'Roger', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marcone', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2c1016ff-90e6-4a07-8cc2-fd68e50729fa', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carlinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a9acaa74-80ee-4025-8b5c-1e97ecbd3abf', 'Mary', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Graziela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '92b56e73-fc84-461e-b6f9-d17ba36aa5af', 'Filho 1', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '70009efe-e0e1-431d-bf03-93359e97795c', 'Filho 2', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '447aa8ca-d266-4b7a-8dad-f31322f5904f', 'Marly', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7088732e-76c7-4ab7-afc2-620a1ac9e05c', 'Marcone', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fc3551a8-f94b-4181-9db6-53936ac8fd50', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cdf863bb-4d76-41f7-804f-07bf60ec8bb4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8e0d81e0-f88f-4a38-a55a-0e9ac2925683', 'Vera', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vivian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd511c5d7-074b-4487-a6f6-d386c5c26caf', 'Luís', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4d1d7582-bb0c-416f-8270-b6dfd2f86bdc', 'Didier', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jonatas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e9405db4-00d6-4d6e-8c41-8da72a59bf04', 'Winter', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e3f627e3-d700-409d-a83c-98640d9fbe24', 'Fernanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '015ffe96-98d8-4cb9-9318-7fd649f0d3c7', 'Breno', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '85de072a-e7f6-4558-8966-f5faf498fb98', 'Geraldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4a10367e-28e3-467b-b5ba-5974e8c1e117', 'Maria José', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vera', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7de98053-6d08-4881-961c-0a1ac14cb85d', 'Leonardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fc1e957f-854b-4456-b175-0fd4bac83d83', 'Selma', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd66e9e34-cedd-4616-940d-294eb6f7c1f3', 'Rafaela', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9885c5cf-8481-4738-9ad8-4a40fd274cbc', 'Antônia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Maria José', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '39f173aa-c613-46d2-b2e7-b433d7da334a', 'Marcone Júnior', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Winter', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd6ef02d0-1ca8-4d7c-b662-72147442297c', 'Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Winter', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '69d33def-9d99-4556-b54e-4080a1697c1f', 'Karine', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernanda', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2e1ac026-5075-456b-a8aa-1c31be4d3b8c', 'Isadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Natália', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '42e72cc3-34f1-4429-b827-89ff1831d430', 'Isabela', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b3c89d5c-0bed-4126-9fc8-1a821a488d6d', 'Cecília', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b2cdf6d2-b9e4-4368-8cbf-991b90c43fa9', 'Matheus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '75e5e431-2705-410f-b034-62b55d8cd199', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vera', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '17476033-3a01-4523-9df6-29330d310d6a', 'Hadassa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'eaae323c-6926-4482-b7e1-152da4f9648d', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b75043db-1253-4e80-aafa-2bc42470da47', 'Cleber', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', 'Leblon', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e6370749-fd9e-4a6f-beb2-d45e22167f4a', 'Cida', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', 'Leblon', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '75e3d51d-fd8a-4322-9937-2f7539c21d50', 'Sidney', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cleber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7214d4a1-64b1-4eb6-a08d-79ed01912358', 'Suzan', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cfcdbd99-dd51-41be-852e-39b0fee3713d', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Edmilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd44393cd-a50f-45aa-9439-e94986d68aaf', 'Ana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5a44b729-df5e-49c3-80fc-0d87ef7cd921', 'Lucas', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bf6e07f3-e26b-4b32-b33c-5f2556fe63a6', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cleber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '09d0cede-3f38-4faa-9648-ad9f761792ef', 'Hélia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dd0b0f66-9696-44c5-acad-9b6e07e1b2ac', 'Renato', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '83890abf-a186-4469-85b7-c9952740a827', 'Eliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2d9f4370-c597-4c1d-819d-82bc1f1647e5', 'Lavínia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0f3ad4a8-535f-47af-900a-75210881e6a8', 'Valentina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c092bb07-35a1-4b99-9c04-ef60da02708e', 'Ediléia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vera', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9a79839f-7f64-47d8-aa91-93367d5f9957', 'Daiane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Suzan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3b732b1a-fd55-487a-bc49-b5048a651c5a', 'Felipe', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '071de0e5-8dce-4e08-81c4-4ad47dc6bf09', 'Esther', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bd6c4119-c5a3-4cd3-adde-b3d94fbfc502', 'João', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e4965f7a-3288-4aee-a66f-ef67ed0947c0', 'Sandra', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vera', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '849c2c13-a6dd-4991-9954-8a059a074361', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a721b157-1734-4afd-9e9b-97ab0afff0e5', 'Edmilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Felipe', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5d9a97f4-8cac-48a2-b014-bf4239fd5b2a', 'Moisés', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7e7b2895-ef28-4ada-98f9-6b93c4e61da0', 'Ramani', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Débora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9e6b35ce-8b34-42a4-bcc2-343bdb45a12e', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1a8235cf-7f54-4257-b9ee-0f2afcd7eba7', 'Débora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8656d15f-0e7f-4ffc-b6be-638f3c673d62', 'Juliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7876dede-a7a3-490b-9516-bb03eb11318e', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5e9d0524-2484-4853-a857-05f69f088c36', 'Dimas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a3200045-59eb-4a10-bc4a-aed6a715e3c9', 'Nívia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '46fd04b7-c28f-4ee6-85c5-8fa7c5ce1300', 'Artur', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Wellington', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '88d85442-6d95-4f45-b678-0cb676554bd1', 'Heitor', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '23c64fd0-87f8-49ff-8757-539a8c15e608', 'Douglas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9b2eed70-c556-45d4-9243-9b096d28df9a', 'Cristina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '415cb0d3-f80e-4728-8dd4-2a053977e134', 'Gabriel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '002b8cb3-1728-4dae-89a8-4ac05ecbb9e8', 'Felipe', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '19f83197-469e-468a-835a-8d57f01b988c', 'Cláudio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd5935a37-98a3-4723-8e7b-f0c7e0e2b076', 'Cinara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f71f3d28-8228-4db1-9dac-3cc86e4fc123', 'Saulo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3a5d894f-f715-4e2b-8ba6-94a502615145', 'Duardin', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8ad685be-5e51-406f-8d6d-c3ac79bb73b6', 'Angélica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '27c7f748-8465-4476-8a56-8f4f443d42d9', 'Lavínia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kézia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd8313141-a76d-4c2e-98f2-ef6894b4fce5', 'Lara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '56983260-593f-4ab2-ae14-6a6a9c48c808', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dimas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8c0b3db5-99d8-4b9d-855e-c585bdf396ea', 'Aline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nívia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '383a52da-3d1f-446f-8a7a-703b76da2e9e', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8cebbf97-ed52-43ad-a59e-f4e24b38c62d', 'Ana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '00864ef3-af45-4a6c-81ff-c3e0a6cab259', 'Graça', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nívia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5586cc80-0d94-4f79-a631-ea80e3206876', 'Jane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nívia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9db2acf7-6f80-4432-80b1-8ad0b94b830f', 'Kézia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0bbe80ce-d7aa-4489-8133-3cd4f6a45ef7', 'José', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dimas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8ffbfe83-fa4e-46a1-a4ee-d9761fb10973', 'Geralda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nívia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0a723a35-3108-4af4-98ce-2191459629fa', 'Marta', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8e5d2699-f60c-4b40-94f6-450ebd7af456', 'Clara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '815eb69e-6285-46be-937d-ebbd55324192', 'Adriana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cinara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e02fc121-ae1e-4c4f-9460-55ec9c8df222', 'Davi', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Arthur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '72295479-fa8b-4458-b802-f7916e4e3562', 'Wesley', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f5e0a121-576a-48b3-b918-549743bf6f81', 'Elen', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb12f070-7e8d-41de-a6c9-68cb1a598c49', 'Júlia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara (Reginaldo)', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2affe72a-4be0-482c-b9bf-caf6e39ddca4', 'Laura', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '50ed612f-d637-4f23-a52a-a6b5703f2a04', 'Cleiton', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f6deff82-f7c9-4ae2-9dd6-6214cae704f6', 'Milca', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e857a922-43c6-4ead-92d6-d7b549c80871', 'Mateus', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '163aafdd-7f9a-4ff7-a71e-0188050c6195', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '196bb146-4697-4a27-8492-56f34c81deaa', 'Jaime', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8a9ae7fe-4956-40c4-9a76-062162119b71', 'Jacira', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ed2cde16-ad79-4dea-a3fb-91efbd8ca735', 'Rafael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaiminho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f677af89-17ef-4102-892b-20745b7d4417', 'Dona Adélia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '05602915-b9bc-4407-87a1-5df7a82391aa', 'Wagner', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b3ac3988-74dc-46e5-a597-f419a1124449', 'Mariana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5f72dc62-e3fa-4e2d-a205-02802d22b567', 'Beatriz', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '852a035f-20c5-44cc-b36c-8d93790e0df4', 'Rebeca', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e03470fe-0e48-4c75-bea4-274bf6abc8de', 'Ronaldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Wagner', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0928c425-2306-4bca-842e-7d6c4d13e5a1', 'Geraldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Zezinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b69cc61f-f0f4-4ba3-a4c0-d4c6cedde6f8', 'Glória', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ana Laura', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '82f7118f-99ab-4293-8b0a-725b54a46f74', 'Marcos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaiminho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd28c9860-1ffd-440a-b7b9-1e42bf37cd26', 'Rafaela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jacira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6ef7a0ac-7fc2-473d-bb6a-f872dcac6e10', 'Aurora', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f1d0bb8f-d1de-4415-8e2b-59ef5ec2a6bb', 'Maria Tereza', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dab77623-6d4f-41b4-85ed-e2204450f329', 'Welvis', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaiminho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e1468496-9ccd-402b-bb2b-f041e2c73c5b', 'Adriele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jacira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bd11bdc7-8589-47c9-889b-042f7d25378c', 'Bela Maria', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ce2bca19-82e7-4bca-a37b-6aedf1b52ab3', 'Izaque', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaiminho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '031caef3-f3f6-43b3-a7b1-cff747294add', 'Jamile', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jacira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f11b862a-b833-4697-9000-ea3d5f776447', 'Kailaine', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jamile', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '12fdaac2-f819-40fa-9ab8-caf8b004034b', 'Angélica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Mariana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b0be9877-22f4-49c9-9c3d-07e84507d962', 'Davi Cunha', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Casado(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Maria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '06168178-e907-4261-93c3-4f319f9ba1e4', 'Liliane Cunha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Casado(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sâmia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f3c0db48-b03d-492b-9387-affb5ad3409c', 'Diogo Cunha', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel M.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f45822ac-7615-42df-af21-0eb9d9835fa3', 'Thiago Cunha', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael M.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3cadce89-f928-431d-b103-651480e93df7', 'Luana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Imperial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5eafd90c-5091-420c-af72-e9d6b316eb8e', 'Gabriel Leonardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Imperial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Diogo Lima', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6c8334e7-fdc5-4e2a-bd8d-430d07b170e9', 'Giovana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Imperial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '54e4b7c2-5682-4b55-963d-e82d6f3c838e', 'Fátima', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Imperial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb5c2923-52ea-442f-b2c9-5bb7bfa51ff8', 'Krismary', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Miliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4095d2a9-b662-4c65-95ae-1f8462e8e76f', 'Wellinton', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roberto', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '72954596-2dd4-4b5a-a6cd-9bcbb12f3834', 'Miliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leidiane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '41aa53b7-e28c-46c0-a9d2-84e8f9bf001b', 'Gellissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd56cc064-3114-4e3f-8ab6-dec6d8567dcd', 'Kal', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Casado(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Maria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb86217a-edd6-4bfd-86d6-b9ed44adc6fd', 'Tininha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Casado(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sâmia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '13e005ea-5a7a-44ff-b25b-eabffea600eb', 'Davi', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5fb2b370-783a-4d2b-adcc-96338a6cea4d', 'Mateus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '29823848-0f06-4b7d-8365-851464236c4e', 'Lincon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e8940714-eefb-4a99-9148-4af1246828e6', 'Tati', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0a342172-121f-462e-b1e3-cd5a59606134', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Diogo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ef77398-5156-44bc-9251-cf7e622f18f2', 'Samuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3298c8bc-aced-4a2d-8ad3-0252390ed07c', 'Benjamin', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '209bbac1-0ad0-4395-9f19-2499d1f1f9b6', 'Adilon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1764b00f-ecc1-4dd4-ac6c-02e1c9612954', 'Lena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '89e10859-ccb5-4268-a4a8-4d75572ee5f4', 'Luíza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '713859a5-c221-4e7b-8c1a-be3ce54cf05c', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '986c0cbd-679d-434b-9f40-68c7215b3b09', 'Gabriel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ccb5e96f-c7cc-4e6a-8740-e21b4275e834', 'Milena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cf19cd87-4e62-49ec-9245-5eec86261a9f', 'Isabel', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fc07de25-0887-4881-8a50-ec57cf905526', 'Davi', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c8ad0a37-fb0c-4bbd-a4b4-b7148b521857', 'Daniela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aacc797c-07ed-41a2-80b4-b399dab01669', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neto', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b1ad3eb2-2f82-4d24-8f8c-93d3062d4c66', 'Leonardo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '32f4903d-4adf-45c5-ad81-eb9b4c508bb4', 'Bernardo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c2ce6bc1-352a-4be6-a322-8eab716c9e5e', 'Neto', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Diácono', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ffa4842e-9af8-4566-b526-0d1fd04fbfdb', 'Thaís', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '919b9528-4b5c-45ce-8e04-c5cb9e436ab4', 'Mariana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juliana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a4b72b41-e1e7-45a7-b096-2be0a0672cf2', 'Luiz Fernando', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '92384d35-0f90-41a7-a3e9-4a017e60ec21', 'Lucas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1c71a46b-a3cc-4315-9310-803336d71755', 'Amanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cafba1f1-91dd-4cb4-ba83-bac45415c682', 'Benício', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fdbedb0d-25c3-4071-b71e-d714c3441368', 'Augusto', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd852fddc-538e-4434-9e2f-1872b5f5efba', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bf40bfad-bc4c-44d1-bcfc-fb8b12cffc0a', 'Fernando', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b555407c-36fa-4849-bb6d-88f4da5a42ad', 'Sônia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b82446e6-c008-4185-871c-f511181b42ee', 'Miguel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '49f4f371-b537-4dd7-9b1f-d78737dd241e', 'Soninha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cad4ccf2-0057-46fd-85c8-622acdcdec29', 'Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Paulo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b3374bbc-8174-4ec2-9e51-5fc9868f7e8c', 'Daniele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alcione', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aaf4a3d2-9c17-4842-9330-62a305b5a159', 'Lívia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd57ca679-97fd-4a1f-af76-a6b3d86941d2', 'Lavínia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alcione', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '43ee0556-0a9c-4493-b5af-13bac2b34d8b', 'Geovana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alcione', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '19635e5e-90d2-4a29-96cd-6a3a725f4265', 'Emanuele', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1ecaccfa-2234-4fde-a772-41999f6c39df', 'Paulo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'Rio Branco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neto', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f0b376bb-fe55-4589-98d5-1a8d07062f5f', 'Alcione', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'Rio Branco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9fd7d309-8949-4e25-9768-c6cdf988d47b', 'Carol', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'Londrina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4ca6af83-b485-4122-8d95-e4457794ef46', 'Alice', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'Londrina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Mariana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a23df862-6ec4-4874-9cb2-b5e77d2cfd82', 'Abadia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'Floramar', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Soninha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8bbc7f4e-d1f0-45a3-97dd-abc01a01d111', 'Dona Vânia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '16568471-4fad-45e8-a4dc-e9f94f1baf89', 'Aline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'Londrina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carol', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e24d0f98-4465-425c-9923-bc5ac46fa78c', 'Bryan', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'Londrina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '84ff3467-1f52-4a31-9659-9389713282bb', 'Evandro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eddac668-a914-42cd-87f7-e78070c77ed1', 'Jucilene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '52a0eff5-287b-459d-af1f-d1f5708c5b4a', 'Ester', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Solteiro(a)', 'Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd7917e95-3ce0-471c-8202-0ec3a2b35a66', 'Gilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'Juliana', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '96247ee9-87ff-4461-b425-77d4954ea860', 'Liliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'bc732207-f7f7-4188-b406-999197ee1a67', true, false, false, false, false,
    'Casado(a)', 'Juliana', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b06a9fe5-8dec-446b-bcbd-9dfd06ce8580', 'Ricardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Maria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bbc047e5-a6e4-4dd0-afbb-12bac35fe144', 'Auxiliadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sâmia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8d624dd2-6164-455d-a660-da314c3b1cba', 'Jonatham', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Solteiro(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thiago Cunha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6d75ce23-c23c-4a0a-8ff7-bed2ae806216', 'Samuel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Solteiro(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5eb1540a-9f76-4d5c-892c-af6bb3bce959', 'Jésius', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f7aa951a-b0b0-4470-8ac1-198ce1a2ebbe', 'Elisângela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aa0281c5-73ae-4e2d-84d2-e36b0512f9cc', 'Cláudio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jésius', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ca85675f-2fa5-485a-a625-8b81be8d1a64', 'Ivanete', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Elisângela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd7852101-2ae5-4b5f-a169-89a021888df7', 'Brener', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Solteiro(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a4b77ce0-15f2-454c-a10d-44bc14f6dcbd', 'Deivison', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8bb4d727-bff7-4347-8711-097903498d0b', true, false, false, false, false,
    'Solteiro(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4d31e76e-bc8c-42a2-a5ab-167b6f49256c', 'Roberto', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4ae7043d-44f1-4068-ab91-f3d0eeab7ba8', 'Leidiane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b3ecfd33-2aa2-479c-bea5-1a92f73bbb97', 'Rafaela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Gabriela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dab43ae5-3ecb-4ebc-9ec2-0510b6c5b524', 'Rayssa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c9b5a281-d4b0-4c66-a330-c39c06f533a9', 'Ryan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Diogo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c727f032-2743-4d6b-858e-de980d0581bf', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '11d00d6f-7a11-4476-81e8-4da73e434acf', 'Dora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9e7e4221-2193-42d6-9b79-486b1fd5f136', 'Ana Flávia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Miliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '479cf1f8-ed3b-464e-89fc-1c015a4853b1', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '14cf1d8e-c4ab-4bdd-859c-4e1e5d9db1a3', 'Marcos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4db8aecd-7926-4340-ae04-a27a3d2e81cd', 'Leydimere', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e01c671f-905b-4b16-b664-938ac4b186c0', 'Bernardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marcos', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '026c76d2-4ab9-448a-bf21-e3a7324a7010', 'Heitor', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8fdded88-2474-405a-bb8c-78fde9c8a660', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3029f46b-81aa-412b-b2db-175c1ddc07cf', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '89e95742-306f-4ee5-b17f-20bdc11eeb5c', 'Emanuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ab2bbfa6-37f8-4d52-a536-fe18f79383de', 'Lucas', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bd0fa006-8518-4e5c-a361-9eeb7b88e410', 'Álvaro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Esplanada', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roberto', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2f1f2b60-13e5-4b0c-a410-774d8872fd77', 'Gabriela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Casado(a)', 'Esplanada', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leidiane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c64899d3-f418-4136-b359-2e99dec424c2', 'Olívia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Esplanada', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aca382f6-7d57-4668-891e-2575979dc4b5', 'Maria Aparecida', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leidiane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b5e86672-abfd-43c8-92bb-79abeaf95c4b', 'João Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Álvaro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '264157d0-65c9-41a1-88a8-759b06ade187', 'Thaís', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Gabi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '49aeac36-ae38-494b-970e-605dd14fdc2c', 'Cida', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Solteiro(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Josinha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1c1a2281-7a41-4a41-b3a2-744c729d2983', 'Lara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Solteiro(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Karina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f494fe47-b70c-4c5b-8074-80d785be7c27', 'Zinha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Solteiro(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jucilene', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b1eb47a8-0264-44f8-8f9b-29e1022862a1', 'Warley Gabriel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Solteiro(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Maurício', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '13c28296-b4e8-47f6-8598-b5254b095d21', 'Dona Maria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Solteiro(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Andréia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a725ad4d-588e-467f-9462-82a60e8ba2a6', 'Júlio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Casado(a)', 'Belo Vale', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fransérgio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9508d2d2-350e-4a52-8cb1-4a94ae88d626', 'Andréia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Casado(a)', 'Belo Vale', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3b3f8236-cd73-445c-abac-38ac0d5ce453', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Solteiro(a)', 'Belo Vale', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18da0879-0e71-4401-80c3-f1b9820e2d45', 'Diogo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Solteiro(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel M.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '61daf64d-aee5-4c56-84c3-d3839f86f816', 'Maurício', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dc39ae48-1c0a-43dd-9c67-955424049020', true, false, false, false, false,
    'Solteiro(a)', 'Industrial Americano', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael M.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '72d08f64-1e96-4885-bb4d-9258a795a474', 'Júlio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Novo Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5b055d16-a494-432e-91d9-718bd9d025f7', 'Valéria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Novo Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8aa9fde5-377d-43bc-b105-a23e38a4897f', 'Filipe', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Novo Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '63cdc71a-7c76-4699-8669-24dd376f5af3', 'Anderson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Sol Nascente', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Júlio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bcf09900-bfd7-4218-bc09-1238e3c22160', 'Kênia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Sol Nascente', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '48ca17f1-59cf-493c-9f99-c31b92864274', 'João Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Sol Nascente', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João Pedro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2022f6ea-319c-48d1-99a9-d0381f288eb3', 'Arthur', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Sol Nascente', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João Pedro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fcca9a58-8884-4045-a801-0141179e7d2e', 'André', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Vale do Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Júlio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '55a28087-f3c1-4bcd-b095-c5bee6988be1', 'Andréa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Vale do Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aa7c45af-62be-409b-963d-0e5e0d068891', 'Isadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Vale do Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Natália', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '126f60eb-f2dc-4e43-bdf9-bd67a5ae9977', 'Marco André', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Vale do Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b5267032-355b-4607-94a1-0aec6269edc3', 'Genderson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Santa Rosa / Sarzedo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Júlio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4cac4489-e119-436d-8c8a-ca3423f908db', 'Letícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Santa Rosa / Sarzedo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '15e5ea74-1e7d-4250-9cd2-eb9388318281', 'Sérgio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Marilândia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Júlio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bbb06ecb-b796-41d2-adf6-3fb2a73db662', 'Kênia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Marilândia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4b4cd571-6a65-4ebf-b875-a2d50f470f40', 'Priscila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Teixeira Dias', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ccf8b5f-f638-4a73-a7c5-0490b0c189d3', 'Bruno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Lindéia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Genderson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '788e0714-d1d7-4d4a-b15a-225820c4ae45', 'Juliano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Novo Horizonte', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '004180b8-4859-4c36-8849-50bf9b69fcd1', 'Letícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Novo Horizonte', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Beatriz', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '63b49986-0e63-4d9e-bea2-c3058a42e5fa', 'Bernadino', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Anderson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1cdd7881-8fa9-4fd2-bf17-6fc703151f3a', 'Jorgina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f47eb221-9849-446f-9299-2c2a96c3b72b', 'Ricardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Santa Rosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '967897ce-e167-4250-857e-302a934c4cd3', 'Beatriz', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Santa Rosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e0f05d60-716f-4212-9209-4a2be5ba4688', 'Nicole', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Santa Rosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Beatriz', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '43df0878-eadc-4563-9089-0cc0548dd75c', 'Valéria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Lindéia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'A definir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd1652aaf-91af-4098-be85-0d27d4366224', 'Mariza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Maldonado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'A definir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c8a4ba56-d20d-4f47-b497-07de3bffc815', 'Jorge', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Diamante', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '046a62cd-d1a0-454e-a1b9-b774fb4517ea', 'Ana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Casado(a)', 'Diamante', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2669c17f-90d7-4f94-8fb6-1ed8859115f9', 'Amanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Diamante', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3f5be4b8-146f-4809-977d-dec43778f969', 'Cristiane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dffed3fd-e8a0-46b9-8928-b77819ff9a34', true, false, false, false, false,
    'Solteiro(a)', 'Mário Campos', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Letícia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'faaed601-4196-4df0-8438-21bd489e5abc', 'Rafael S. de Moraes', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Casado(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '95f71fa0-6237-4c0b-80fc-d99e2ce0f84d', 'Isabelle C. M. Moraes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Casado(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'db7b0e50-7e01-43f7-ac9f-3f3fc518ee22', 'Beatriz M. de Moraes', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd554c7ab-6f43-4af6-be97-bb017cd921ed', 'Filipe M. de Moraes', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1b832109-2898-4e9f-9fdc-f0fc688c8901', 'André M. de Moraes', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9f6a094c-e3b3-4522-bd49-d442a676e504', 'Ari', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Shibas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '00cf56f2-ddae-4076-9ab1-d4b5761ed7e8', 'Jucieda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f17e8055-eb0b-4518-852d-e861a09b89e1', 'Natally Silvina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Ventosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Isabelle', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '83f933b7-2b28-4ed7-9143-719e1f10b709', 'Wesley Anselmo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Casado(a)', 'Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '50037ebc-403d-45f6-aa98-170dd6ca1f30', 'Evelyn Ellen Dias Anselmo', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Casado(a)', 'Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Isabelle', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '38588ef0-4730-4080-a9f5-2a6bb893cf6f', 'Anna Júlia Dias Anselmo', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara do JP', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e62549aa-cdac-4b01-8001-bd76d69a8850', 'Anna Laura Dias Anselmo', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Zoraide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ea5f68fe-8a6c-412a-b754-8b014617f6c5', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Ventosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dona Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9d22fa36-1329-450e-b8d6-caac02c44d66', 'Lucas Eduardo Luz', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Casado(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ad1c7be3-0954-46da-8525-2ab725a3e949', 'Allina Rodrigues Luz', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Casado(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Isabelle', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b7227538-6294-486d-83d7-f3eb8a43cb5d', 'Carolina Luz', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0d2b5371-4ac1-4c6a-9fb3-2844eec18229', 'Maria Fernanda Luz', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '222722eb-4c77-4949-bf6a-6344473c6d36', 'Leonardo Luz', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '0300704e-9660-4329-82ec-bae2f470555c', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd81b32d8-3361-4785-8f84-47842b070fa7', 'Cláudio Luís dos Santos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Carlos', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '20299992-40a3-464b-af2f-6445fdf3b48c', 'Vânia Lúcia de Paula Santos', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roseli', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fe7e5d23-e677-4219-b369-556310c5424b', 'Nicolas Matheus P. Santos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bb3b59e5-de49-4908-84a2-82ad4c716d15', 'Davi Carlos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '12f1d11a-a53c-4109-a055-82be54fde14f', 'Roseli Gonçalves', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2b66b607-79a7-4fda-aba4-c9d74a61a1c5', 'Júlia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '88350d37-0ca9-412b-b652-bccc89bc1f8e', 'Rafael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd1b8b8c5-dac7-461a-b642-5cfea4baa8d0', 'Daniel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '85f0ba08-787f-44cf-8fb8-f3ee76362b15', 'Lúcio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c49f8547-ffe9-4fba-89f0-4856e09f7324', 'Tatiana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b792ef24-3d87-4abf-9ba8-00d1220a8e03', 'Isadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cc38eb16-e297-4472-ae82-b16f9a07370f', 'Eliza', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '218d21b4-19df-42fa-868a-1c028a20626f', 'Marcelo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '34a64dbc-42d1-4df7-bece-25fd54cbe584', 'Neila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roseli', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cfcb5b30-e5b3-444a-bd96-89516122a62f', 'Enzo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marcelo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7b9606db-afa8-4e1b-a3d8-ebb78e63f7a0', 'Melissa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0ec1ff8c-f44c-477e-861e-daa350347e36', 'Hemerson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lúcio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '357bb926-8ea8-41bb-86e0-32c6b37e417e', 'Joelma', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3434b744-218d-4dfd-b96d-c1c800c6f684', 'Sueli', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Mariana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '17be3ee9-0636-4f9e-b35c-6f48c9c03d34', 'Izadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '00c89878-42db-42ab-a41a-ebf5fbc2aa48', 'Isabel', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '84f92977-7669-43e0-93e0-fac40759ad1c', 'Aparecida (Cida)', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Colonial - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '978b0f64-e4bb-4460-bd70-37d2a75c6f40', 'Alviclênia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fb3afe95-26e3-432f-a08e-84365e975e6a', 'Rosa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Solteiro(a)', 'Ouro Branco - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3c6f6c07-3af7-4103-8a2d-aedc8b8d76bf', 'Ferreira', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Icaivera - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Arthur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '425ec989-d1c8-4a54-90d5-58edca13c06c', 'Gisleia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb', true, false, false, false, false,
    'Casado(a)', 'Icaivera - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Taís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '704f02cd-6fa9-4526-8a4f-012e249354aa', 'Willian', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Casado(a)', 'Novo Progresso', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f2fec21f-655d-4070-bce4-f4c212acf790', 'Dulce', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Casado(a)', 'Novo Progresso', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '54c838b1-40a3-4d4b-81ca-d97ae90e66be', 'Oliveira', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Willian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7f3040e2-7759-40ee-b56f-f28fbe59415b', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dulce', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cf4e3514-aeca-4441-a155-3ebedfd8faf5', 'Eduardo Coutinho', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Willian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b1fa870e-1149-477f-8ca1-6d8da6c5f7e2', 'Mariana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '392ce5d3-1315-4758-9a91-f37f72d649fd', 'Roberto', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Willian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f6555fc8-2176-4de0-9bdd-1271b2dd9664', 'Neusa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dulce', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '99cf2637-cd80-495d-9943-ef17728edcff', 'Aline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alexsandra', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b29e79bd-4039-42ed-ab25-813aa5d3dece', 'Meirielle', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '653951d9-6b0b-46a6-9c81-b89e2f5b7f06', 'Eunice', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7c580151-4ced-4e05-ab0a-0a1e4f22f54e', 'Lucimar', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ece456d-dfe4-44f0-86f2-92502de86cb1', 'Miguel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Oliveira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a7bcc76a-cf00-4302-bc42-cb3bef4ea122', 'Maria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alexsandra', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ed8fa792-ea9c-416f-bc53-cba200a68a54', 'Dalva', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f71bc078-52c8-42f8-9d82-d0cfb2258b7e', 'Lúcia Helena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '82813806-93d8-47c2-a4a8-c5132784ec4d', 'Sirlene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'de250387-80f7-476c-bd90-3e628d41177a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5bc128dc-441c-4717-8a70-50c3400f47f8', 'José Alfredo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Casado(a)', 'Bela Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd6098285-5234-4f63-ae72-2f81b0f47809', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Casado(a)', 'Bela Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4dc5a2c4-6e72-47ef-afa2-fa935bc30f18', 'Isaque', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Solteiro(a)', 'Bela Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1d64e2be-8aac-4540-95cd-92d5cbde61b2', 'Cleber', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Casado(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Alfredo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '24c74460-e6dd-49ab-9921-721fd4ef6055', 'Ila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Casado(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ce6e9e57-a44d-4785-a6f1-25378aa4914d', 'Gabriela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Solteiro(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7e022e15-0e58-45ef-a820-3da4680ed9e7', 'Neide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Solteiro(a)', 'Los Angeles', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd53977c6-fb25-44ae-9751-6e2bef191d24', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Solteiro(a)', 'Los Angeles', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4ad0f26a-462f-4c82-bb53-317081e69cb1', 'Leandro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Casado(a)', 'Bandeirantes', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Genderson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ca67335c-c99a-4c92-9aa3-f766b20f9721', 'Deise', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'ec471e7b-112d-46ab-a2c0-67aa0f24e08d', true, false, false, false, false,
    'Casado(a)', 'Bandeirantes', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5750fd70-f815-4499-88ea-b73bf5d98572', 'Thiago Van Petten', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Casado(a)', 'Nossa Senhora do Carmo - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernandinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8d14b1e3-3c0f-4739-b404-46d72d21cc74', 'Nara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Casado(a)', 'Nossa Senhora do Carmo - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '78a2cebe-8198-43c5-9767-9125f30ee177', 'João', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Nossa Senhora do Carmo - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7b836364-de02-482b-a8cf-21b404a4f19b', 'Augusto', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Nossa Senhora do Carmo - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd566c61f-71a7-46eb-974c-95e87685e5e1', 'Ismar', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Salgado Filho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e12a7909-1947-41d0-905d-9c50893deaf2', 'João Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Casado(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernandinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cfda9987-6152-4144-b413-55fa1d52c2ea', 'Sara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Casado(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18bb1b43-89a2-42e1-80c5-9b4fcc8b1e3f', 'Denise', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Cidade Industrial - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8925f2a8-d2d3-48b8-bf37-3aa2c988ae1a', 'Madalena (Madá)', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Salgado Filho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5b7dd509-d5b5-4c2a-b3df-53bb5796223d', 'Leonardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Funcionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thiago Van Petten', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ec40ba6f-78b4-4246-a145-c44a2bcd338e', 'Tiago (Tiaguinho)', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Jardim América', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João Pedro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4372a4ef-cd4a-4267-9022-c3c60810cd3b', 'Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Shibas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1b171281-cd18-4fb3-b853-76ea6529d92e', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Casado(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thiago Van Petten', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fafb068b-ac68-4ae7-bcbb-f2ff2374af83', 'Natália', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Casado(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0cc0802b-dd49-4277-98ce-b4e744133777', 'Alice', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '81623c57-421d-4150-909b-d6f23846db06', 'Elisa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '32175a59-c0c6-4e02-9050-4d5ceff4127b', 'Mauro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Casado(a)', 'João Pinheiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'David', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '721f2776-a2df-467d-8f67-8c3ded548e64', 'Marlene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Casado(a)', 'João Pinheiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jehane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2e3502b5-ab2d-4e26-8129-325386cf56f3', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cf018409-11b8-49f4-bda3-1355e961ede8', true, false, false, false, false,
    'Solteiro(a)', 'Nova Cintra', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ismar', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4d18f1b0-47b9-41ad-b24b-6fac6ee650aa', 'Jardir', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Casado(a)', 'Nova Suíça', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Regi e Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c5faf10a-0846-46b2-a16e-88ae8b95856e', 'Cida', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Casado(a)', 'Nova Suíça', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c88177e4-1da0-429c-8568-65e4f339bf74', 'Warlei', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Casado(a)', 'Salgado Filho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c184e060-a860-4c2a-a057-edf7ee84372b', 'Alba', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Casado(a)', 'Salgado Filho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Warlei', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e1af9709-5187-4e93-869a-72253199e61c', 'Afrânio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7d922828-7f20-4eb2-83f2-6da6b04c6a0c', 'Helen', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Afrânio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '059aae89-de5f-4eb6-aeba-5536ebafbe25', 'Helena', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c2fdd226-50e2-41f0-8275-191dd071a43a', 'Kátia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Santo Antônio', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '84415144-56b7-48d7-8d94-bfca7ee84bd9', 'Cassinha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Gutierrez', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kátia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c33fa385-9f2b-472b-87af-64dcc572a393', 'Clemência', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Santo Antônio', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Grace', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd94eee52-0dd6-4850-8f8b-cd18a46748bf', 'Bárbara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Santo Antônio', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kátia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0b2665d5-0d81-4c78-acef-1aa26bc92f60', 'Perpétua', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Nova Granada', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '652e8f60-dd83-494b-865d-22e6c2404b29', 'Ágatha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Padre Eustáquio', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '35c3cb0a-b126-4f94-90b0-9ee995a2ed09', 'Maria Luíza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Lourdes', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ágatha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3e09848d-2fc1-4d9b-aa40-d70289a486f8', 'Claudinha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Denise', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b09df62b-0492-418a-8f67-ac5908f2840b', 'Saulo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Casado(a)', 'Floresta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '978c37e3-26a8-4583-bc0d-c454040432f2', 'Kioko', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Casado(a)', 'Floresta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Denise', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e4d6a22b-42d2-415f-bda0-116d819b632b', 'Denise', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Lourdes', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '76461c4c-0bd6-483a-9d93-9a2202db7993', 'Wellington Ferreira (Shibas)', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dbb030e2-1e77-421b-ab83-2631c334f4d3', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíça', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2735d8e3-2902-4f37-8f07-b8596161ee2d', 'Luiz Henrique', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Centro - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b21fb951-c70c-489b-bb83-126b869ad4da', 'Charles Pascoal', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'São José - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2d4f11b7-3864-48ca-8dfb-acac13e3e633', 'Lorena de Freitas', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'São José - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caroline', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'df38623d-f6cb-4386-84b0-e94e4934b9e8', 'Ana Raquel', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'São José - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e795724e-2230-44b6-a330-3c1757eb511e', 'Davi Ribeiro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '59dc55a4-6480-4083-882f-a9fde99f42f2', 'Jehanne', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caroline', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb3cb6e9-02e1-4173-a634-19984ed36dce', 'Gabriel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João Paulo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7a23270b-82ab-4acc-895d-77c6416d1375', 'Samuel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Ribeiro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '862097d4-cd3a-4a69-8228-73e8688d390b', 'Tiago Ribeiro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Ribeiro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0f7e7416-c29b-4d6c-9d1c-3b66c716d5d2', 'Edmilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Ribeiro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '49f67b24-3323-401d-91c1-23153a80de7c', 'Lídia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jehanne', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b477239f-3a53-4839-97fb-02fac90be635', 'Letícia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9e8c8eb7-b83b-4fed-aaf9-df5a5c3c0a72', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91745890-20f0-4a7b-8403-f6a9d8e1974a', 'Darlene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caroline', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '167102df-b678-432e-9cda-ed71346b1d51', 'Davi de Oliveira', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luiz', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '32dd7a78-98cc-4d88-9e92-ba2cdda172bb', 'Jonatas', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '71358ba6-75ad-4b0e-bd17-dbb779210b2e', 'Marisa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jehanne', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '590efd63-54d2-4425-82bb-2ff3baffeaaf', 'Raphael', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0246aa3e-2d7c-49bf-9791-ebdd27c66342', 'Sophia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6f3da312-2192-4fb8-8919-c4a16c67915a', 'Emerson Heleno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '197e0ace-9c04-4d98-9a58-514b92e32b35', 'Caroline Fátima', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Casado(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '854ec463-3917-4885-9a29-163e001b9d57', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caroline', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4758ad71-4434-4679-8fb2-bcf7d9dc5fa4', 'Tiago Heleno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b4e019ee-bae4-4caf-a67b-8399f92b1567', 'Samuel Heleno', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '53985419-10c0-418e-890e-109ecdcd0ffc', 'Isabela Heleno', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '255e80d3-a528-46d1-bb23-82e2842738f2', 'Ilia Fátima', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lorena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ecb61d1-13b5-4f22-bbd1-4cfe44ac0dc5', 'Glaydson José', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'cd60ce0c-a51a-4708-932b-0665e207b3d1', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '94331f45-93dc-4c93-a2fb-243aa9ef0060', 'Alexandre', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5aef5ec9-d89e-4a90-93fa-2b7b835c82db', 'Érica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roseli', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6686e97b-d16a-4c71-a00a-618e05b424bd', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aec174e2-140e-4a46-9fca-a86ca23f9499', 'Valentina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a1a11475-fa9a-4522-8cf7-1fc4bad34c5c', 'Heloísa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f76a602c-8be1-4ab6-b41b-26d71404da4a', 'Tames', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '50122db6-6e32-4e4a-b670-51311e2c483d', 'Michelle', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9771bb72-80bb-4f16-a98e-9ae441c5b4e3', 'Helisa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dd4f1d70-a6ba-491e-89d5-d687558c3969', 'Adelmo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '091cd3e0-1a7c-4020-8742-1615ad4716d1', 'Júnia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '60ea4596-0a6a-49ae-94dc-871eea9debde', 'Neuza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roseli', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a550b788-4faa-4cf5-a657-9cc971f0416e', 'Rosa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ace990f-ceae-473d-b68c-a4d276ced940', 'Juan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5f304ecd-5612-4bc8-b4c5-6305afdf424f', 'Ximena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a9a8cfea-3a01-4fbc-a6ad-c513a5239e17', 'Valentina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8b119e6d-0ec7-4a9b-b954-631dcc26edc4', 'Victória', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f656c101-a004-4edf-848b-a2aaca940767', 'Antonella', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3456c288-6616-449b-ad4f-7a6fa4c2b64e', 'Júnior', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Monte Castelo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6e5bb176-7465-4a41-a54b-5744ddf342ef', 'Silvana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Casado(a)', 'Monte Castelo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '45082e17-ac1f-43a8-ac08-9072b5b294fe', 'Emanuelle', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'f49e0f88-c97b-4ca1-be5e-a7e15906c63b', true, false, false, false, false,
    'Solteiro(a)', 'Monte Castelo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e61f63a4-c117-4fcb-a3b9-0a3180610995', 'Jairo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cléber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd60538f9-f4e2-445d-a05a-48440392b15b', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia (Cléber)', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f53b3f3a-a1be-4613-96f2-6e9d113b6528', 'Camila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ba5f269e-9a1b-4fbf-ad40-6b5d6d9c4a9a', 'Lucas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2432be66-38cf-4425-bd0d-19f773bdb458', 'Leandro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eb58b79f-4fe6-4449-9c7f-c3984f2024c5', 'Eliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carol', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd9aba70a-8782-4fe0-9d76-e4710b6b4a8b', 'Emanuele', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '09c1ae8a-71dd-46d5-a70b-7446b14ef966', 'Geovana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '100a8da8-e765-42df-bc9e-5c6fff953430', 'Davi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9df93b7a-f166-4e1a-8ac8-cfc9d43cf8e7', 'Warley', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Parque Alvorada - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '32ba3595-2b00-4919-9df1-fee06f8f84fe', 'Deise', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Parque Alvorada - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carol', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '881f9d55-2ab5-4c49-a453-11bf6faf387f', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Parque Alvorada - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Camila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9aa684d2-359c-49be-b342-3440ec4a2ebb', 'Jetro', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Parque Alvorada - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a372098d-62fa-4a2d-add7-2cd5038ad667', 'Olício', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Satélite - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2467d6c7-d1f6-4fb9-8fae-eb8f9ce6fe74', 'Luana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Satélite - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4a6769fe-6bd9-445e-b5ea-0a2575cc5bb8', 'Noah', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Satélite - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '31d007a8-7f62-46bd-9af3-e47fa69fa0a2', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Satélite - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91cf41bd-205d-46ac-b61a-d37355a3d1a0', 'Daniel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Centro - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2df675af-78b3-4bfc-907b-d90462fe9608', 'Jéssica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Centro - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9864ebf7-d26e-48b2-b0e1-9e88f02ab7ae', 'Marcos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a9ad90de-d5e4-49ee-b8b5-e7e5ea480953', 'Maria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Casado(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bef22e7b-5a1e-4974-a617-d95d3f5b85ab', 'Emilly', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Camila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '45c21c56-471b-499c-9664-2f74406b7e8d', 'José Maurício', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Vianópolis - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'de6afd7a-cd82-4284-a067-d0ff5ac30523', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leandro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4f9524c7-65fa-4daf-ba9e-c7a06f4ddf7c', 'Mizael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Centro - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '53384c13-e5e0-41bd-b152-8fae18f1424c', 'Helen', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '842dea88-f197-4372-8ec9-cdab040f1a2f', 'Luana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '16944f6e-e0ce-41fd-bbed-179d117e9f42', 'Júlia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3ab969d3-5651-4fff-80bd-fe37a0172322', true, false, false, false, false,
    'Solteiro(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Camila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '819086c6-735b-491f-a51d-c5482cd66ee8', 'William', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Casado(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ronildo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '98114201-94e3-437b-a076-a8855d8129a9', 'Simara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Casado(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '69843d4e-54a6-4b79-ad8d-da49ac601235', 'Wenderson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Casado(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ronildo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7c7de20f-8b09-434f-8344-f182f91f2e04', 'Renata', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Casado(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9b59aee1-535a-4bcc-9e10-97e914cbd507', 'Fátima', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Solteiro(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '38e1116f-4ed8-45e1-9a55-c1948b4e6575', 'Fernando', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Casado(a)', 'Pousada Del Rey', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'William', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '31313de6-b5cc-45b7-87d0-8bc03e7fa5cd', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Casado(a)', 'Pousada Del Rey', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '92adf99c-10e7-4e7e-aea2-abbfc515c2d8', 'Natália', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Solteiro(a)', 'Pousada Del Rey', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marisa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '23b7aaee-933f-4caa-8c31-eff0f4146ebd', 'Bianca', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Solteiro(a)', 'Pousada Del Rey', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '66fa6086-5227-44d1-9f17-6a58985664cd', 'Gláucia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Solteiro(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Renata', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2c813d31-2ae8-4c95-a2b5-deb92f5b6172', 'Fernanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Solteiro(a)', 'Casa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Simone', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c1c5dd14-e38b-4b44-b7c5-ed459023e287', 'Bruno', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Solteiro(a)', 'Casa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ccfd2f57-8f0b-4d22-80e7-05cec082d643', 'Luíza', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4', true, false, false, false, false,
    'Solteiro(a)', 'Casa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7d7ccec7-3b36-4b39-9c6d-ba38c6fa2efb', 'Cléber', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2fc663f3-a8d5-4e1b-a2dc-98520dda38b2', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5e1deedc-c0b6-4dbc-97f1-6027d430cc2d', 'Camilla', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ebd2fc8-a82c-44bc-83de-23628d82eb75', 'Caio Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Niterói', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Arthur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '27a9f505-d6d0-4545-a759-a536e1cfefd3', 'Marina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Niterói', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '85dfa227-5e5f-43d2-ae5e-937147f285ba', 'Marcelo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cléber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ca0d3bd6-62f5-42da-ab0b-2321de784d95', 'Simone', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0f741273-33f1-405d-8b42-8fe638b1b90b', 'Beatriz', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Simone', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '85063129-d8b8-4db8-b675-acd6f168f6ca', 'Maria', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3aab63de-7999-4c10-b96f-d79b613ef069', 'Bruno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Bandeirinhas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '49838a47-3629-462c-9fa3-aa84894b2067', 'Vanusa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Bandeirinhas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5b2a9424-af91-4967-9a18-3d682d04005a', 'Abner', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cléber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b26c7ec3-d2d9-411e-9638-0db835db733a', 'Fabiana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '14df8d6f-9cdb-41cf-bdf6-e9231caa3ea3', 'Levi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd3ed1b3d-e56f-4b1c-b9a2-108dff4ab7c8', 'Sônia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Laranjeiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Simone', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '541833ad-fe7c-434c-82e6-63db1bbcffa8', 'Nely', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Teresópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Priscila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6cf7c14d-7dc7-43ac-82c9-8ca5563e062e', 'Rafaela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Laranjeiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marisa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c7337472-2492-42ed-b980-d94c5f619f74', 'Luís', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Teresópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Abner', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9eac8950-47b0-4612-b4a5-095c656f7054', 'João', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Laranjeiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cléber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'efe99423-c7f0-4080-bb25-bb9e977f72d2', 'Lourdes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Laranjeiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f53f0316-2854-4ca7-b501-7ca0d5ec5d3d', 'Denim', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Bruno', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6415fe87-33e5-48cc-844d-f5ed9eae8be7', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Casado(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '480df268-bceb-4977-b97b-ab65ee539ac3', 'Ismael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '90f1f945-7281-41ef-afa4-a6c26b764a42', 'Isac', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a2efdc40-905a-4f4a-90d8-c8c09d60c721', 'Daniel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd1b1f515-1533-4d37-8dd5-e80d02c82399', 'José Geraldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Teresópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '10583429-b6ad-491f-b864-7addf9d957b4', 'Fagner', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Imbiruçu', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio Vitor', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5be17f42-0ddf-4ddf-a44d-8a0b460fbd95', 'Lauren', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '61db871c-63cb-4e93-9708-81674a7f3961', 'Rosângela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'São Caetano', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Priscila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ffeafebd-ca36-4586-8259-402e0c5fc321', 'Suzi', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '19c3d488-f5ec-4c49-92dc-db860e68436c', true, false, false, false, false,
    'Solteiro(a)', 'Imbiruçu', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lourdes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3df444aa-89f4-4308-a01b-38622242a741', 'Marilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c369a90d-4316-4d4e-a31a-6c13bfb9c996', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cad50075-b15c-481c-a9bd-52d704d6ce6a', 'Benjamin', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ba110cff-557b-45db-a196-c6e8fc8e71a4', 'Gilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6234ade4-b8bb-4611-b3f9-463fb0b4caba', 'Nislândia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '567e63e7-2eab-436c-9751-f467ee816e7f', 'Izabela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Priscila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4a02be01-cd2d-41b3-8ffc-2399b029abdc', 'Ana Luíza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nislândia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '807ab9d1-f95d-420d-97cb-9f340cc4f7e5', 'Rafael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Guilherme', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a9d51b21-df82-4c56-9186-7151224e65a5', 'Wanderluz', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e2487d28-89eb-4394-857c-6f30a8688675', 'Janete', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '72ac0584-82a9-43ff-8487-9eabd29e3ba8', 'Eduarda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c97a861d-fc2f-4c8f-9cee-bc2a9a7c650b', 'Carlos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Guilherme', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0d0cf63e-7521-443c-95bc-f85fc98546e9', 'Dilvano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Dom Bosco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '509e34f6-b484-417c-8223-8408409ce779', 'Edilene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Dom Bosco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8da8e787-202b-4db9-85a2-f8c8e911438b', 'Ana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Dom Bosco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2802e112-f41d-4d6c-ac84-793ba506e93e', 'Josué', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '65dead1d-7158-4122-8d2f-90b636cd173c', 'Lorena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd19d4394-530c-4bf3-b21c-e23293330c5b', 'Miguel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '29a0a71d-d74e-4b0a-95f7-28430ad6142f', 'Emanuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '61a927f1-2168-484a-8629-ede964f204e1', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Califórnia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '155b0a35-78f5-41ed-957e-85daa9539fb4', 'Priscila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Califórnia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Patrícia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '777f2bd4-2e6f-4ccc-be18-da9a817fb91f', 'Suely', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janete', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ee08aed-3fd5-4f3e-8cdc-5b1d4782c23d', 'Filipe', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Guilherme', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '13208420-1f67-46e3-bd1a-0e8e9722dfc8', 'Talita', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Priscila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8e319ea2-f701-4aa9-84db-52dfed631174', 'Benjamin', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ed986db6-452c-4ef3-9340-474b7aca1df9', 'Luciano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lúcio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1bca7d3e-f87d-4ce3-975d-d5896046064a', 'Joana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e4a258f5-3993-4379-ac40-c31d1e35c9f4', 'Raíssa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '916147dd-3a85-4a99-b90c-ab1a9fbf2671', 'Luciana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb8da091-9837-40b9-a842-3105fe329545', 'Abner', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91d8e9b7-fb84-43dc-9f3a-af83946e5076', 'Ranma', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ac2c7cfc-af22-470d-9f45-bc1ce4ce9560', 'Jonata', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bf234e01-d1dd-4270-9ae0-c3e94b81195b', 'Isac', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '68b0180f-7326-4450-aaba-57207a9c9a6f', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '192eefab-7304-454a-a5fa-288e6e267258', 'Artur Cunha', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1e664157-86cd-4f8c-a896-0a05bd145073', 'Thaís Cunha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0a3b75da-8d06-435e-afdc-4dbdc1e38792', 'Isabela Cunha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara (Regis)', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4d4d031e-91fd-4692-8bcf-753d0a2adf9d', 'Júlia Cunha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '49d5c83b-53f5-4118-9ca7-5c9d7420865d', 'Sofia Cunha', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fa38cfc7-728e-4c52-a6bb-c633d2b834fc', 'Douglas Macaúba', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fdc5e5c9-2e6c-4b71-936a-bf6e1f1be73b', 'Carol', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fffb128b-f767-4ded-8b10-91d292ce18b6', 'Gabriel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a1ea11cf-40b5-4960-8359-fc60217a11bd', 'Thiago', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9553e140-a3d3-4602-8dec-deb41f4a3db9', 'Carine', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cce7a9e4-25c8-4ff6-81a8-ed442f5cf5c9', 'Melina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fe41d5e2-d125-416e-a9b7-cbd9f6228751', 'Maria', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7edd7fe4-0dac-457f-933d-b1f57afffa25', 'Diego', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18657a6d-9e7c-40a8-89d8-7e35236bf7d8', 'Gisele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0ca7a178-ef83-4e3e-bed9-f512955413f6', 'Samuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4e2c5470-a9db-4c0c-9cdb-1b25fd7a9eb2', 'Graziele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érika (Alexandre)', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b4f6ab0a-00bd-46a8-9faa-bab8ad46728e', 'Imaculada', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8b4075d4-4d85-4933-90b7-e7ce10f0082e', 'Carlos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ea206d2-8d61-42ff-a7be-fda5c18a6dfb', 'Vinícios', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eea78a25-abf7-4da4-8f48-1b63d240ea68', 'Sônia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4ce658a3-948b-48d8-89b9-55eac05819a2', 'Ana Eloísa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd9a341ba-d9ed-4190-a451-204dbb0c28a1', 'Maria Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bc14bb02-efa4-491f-8402-566daac5c7fd', 'Heitor', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '947a30d4-f34c-4a63-a81a-993b3e2ab741', 'Martim', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'da12dc4e-6934-490a-84bf-a186bb750f12', 'Adriana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cdb95968-a963-47a4-ba61-150a1236156d', 'Laura', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Suzana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '07d5d76a-aae8-47b1-852c-ce98704d4e32', 'Ester', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7956bcd4-33f5-4a18-b769-e463c1861209', 'Gabriel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '07fe5993-afe1-49ab-968d-2aa12f754e44', 'Isaque', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b8fa484b-424c-4fe4-bef7-c1aa6afd3aa4', 'Zélia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4fbc893b-ccae-4394-bf4e-c2877a7a9775', 'Keila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd6089e13-97b8-490e-a11d-b80ea7adb7e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18d50a5c-a531-4324-a680-9832fa857cd2', 'Lucas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Bom Retiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '24af58f5-b953-4455-afdb-0bedf37a64f2', 'Leila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Bom Retiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a953593a-a78f-489e-b0da-4d638f2bd524', 'Ivan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Bom Retiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8bcdd32b-4209-4866-9d8a-783b7a43f6fb', 'Ester', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Bom Retiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dfa88997-39d0-4a9b-b6a3-035104389c44', 'Eliel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Ponte Alta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2011e28d-b353-487e-8bdb-b5aad51d574b', 'Fabíola', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Ponte Alta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c691b79f-90d6-4af5-90a1-fadcbdc676e1', 'Davi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Ponte Alta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e6ad1e84-bb1c-413c-a98a-753162f026c3', 'Ana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Ponte Alta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f2b78013-1604-4338-9838-2feb52f78055', 'Ramon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Itacolomi', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7c6c7261-9358-475e-b24c-1e5d3ea60124', 'Natália', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Itacolomi', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6e349580-00fc-4ca8-be94-444535630811', 'Ravi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Itacolomi', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '618c955f-a79d-46c6-8875-c50601ecec68', 'Melissa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Itacolomi', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '03fe773f-ac9e-46e1-85ad-9322a4980440', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '350000fd-135e-49ad-b022-0684edade46d', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3f2edbdd-c858-4110-9891-12f8b31d1bab', 'Nicole', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '67b02882-2914-4f29-aeb0-0e5067a76539', 'Antônio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Jardim Brasília', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bf9ae785-2817-41a5-a9a5-8e8d97c1cc48', 'Jaqueline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Jardim Brasília', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '117711e7-e97e-4225-81b4-a57644ce925e', 'Verônica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Nossa Senhora das Graças', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3e861846-89e3-41ff-82bd-b81b378d8734', 'Nileide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Niterói', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaque', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '849a3ace-7380-409b-a73e-16d58135403e', 'Fábio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bb39230a-b444-4cb6-a8b6-8340c5559862', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '96d460db-7119-47e5-a68d-01c517316d20', 'Nicole', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a2e62d44-ba3d-415d-9029-606d86d3858e', 'Suzana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6883bac2-0edf-44c2-af2d-77b8566823e5', 'Lorena', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fa5e0052-102e-4967-9f34-8fff528e752c', 'Asaph', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b802b313-1f03-44a1-9431-4fda4df0bdcd', 'Leandro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Vianópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '83358379-36e8-4e78-8270-2997145d144a', 'Tainara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Casado(a)', 'Vianópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a6333ea8-878c-45fb-898f-fd53fd3f0184', 'Théo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '23649e02-ef06-432f-bf46-152999cfa58c', true, false, false, false, false,
    'Solteiro(a)', 'Vianópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '839ead5c-03bb-400b-8212-07b2989cfbb2', 'Cláudio Lopes', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '14b033e6-3519-4436-b716-f99189a7b01d', true, false, false, false, false,
    'Casado(a)', 'Interlagos - Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas Martins', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9f2b6bba-416f-4c5c-a3a1-7fc47ecad0f2', 'Zulmira Lopes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '14b033e6-3519-4436-b716-f99189a7b01d', true, false, false, false, false,
    'Casado(a)', 'Interlagos - Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Welen Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f7e3b4ee-d8a2-4970-a823-05d5f0c3f6d4', 'Cristina Barbosa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '14b033e6-3519-4436-b716-f99189a7b01d', true, false, false, false, false,
    'Solteiro(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Welen Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '16b40c40-4f16-4e7b-8e2b-5c513d7c148f', 'Ismênia Ferreira Rezende', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '14b033e6-3519-4436-b716-f99189a7b01d', true, false, false, false, false,
    'Solteiro(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina Barbosa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '185b445c-6e76-4fee-bf9e-8fb8a138bc99', 'Maria das Graças', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '14b033e6-3519-4436-b716-f99189a7b01d', true, false, false, false, false,
    'Solteiro(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina Barbosa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '555fcf55-c67d-46e2-aa90-bfd324ad4476', 'Samuel Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '14b033e6-3519-4436-b716-f99189a7b01d', true, false, false, false, false,
    'Casado(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Danilo Ferreira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fc6f093e-d58a-42d7-abb5-1fe6547e051e', 'Kamila Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '14b033e6-3519-4436-b716-f99189a7b01d', true, false, false, false, false,
    'Casado(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Melry Laine', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1fe6e1e2-cb71-46e5-ba26-6c1b0d2ea434', 'José Antônio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f3197176-da64-47fa-bd4d-2b9729e50590', 'Eliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1551f859-b707-46cb-8aa5-a900371ac15d', 'Geraldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Wellington', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9100c0ed-3f3e-46be-be53-ae1f33177482', 'Adriana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Raquel', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '72f47467-e296-44f8-b940-69c3803f4155', 'Uyara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Solteiro(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c98b5d32-0e52-4b43-a2fd-67683be9661a', 'Uyrlan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Antônio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '567d3303-f645-4827-87b6-1b11a92a06dc', 'Luíza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '311c1afd-043d-4c4f-a3be-cf0f24d2a7a1', 'Suzana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Solteiro(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '31e355e8-5400-4a0f-b8d6-a763e554866e', 'Welington', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Antônio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a062693d-2dce-4d48-a27e-7a6d1289e2ca', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '239e300a-4790-43cb-8169-b0a563aad46e', 'Nicole', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Solteiro(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2938c47e-bebb-49b0-8927-2b6b967d5881', 'Ariane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Solteiro(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c679abe1-0145-4605-a60c-effaad224d73', 'Hebert', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '723e922e-3b06-446b-bc89-16250583966e', 'Natália', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fab3e3aa-f3fe-4909-8e5a-a9a73b381098', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );

  -- ==========================================================================
  -- 4B. CRIAÇÃO EXCLUSIVA DAS 3 CONTAS AUTENTICADAS (auth.users)
  -- 1. Gabriel Góes Braga (ggoesbraga@gmail.com) - Somente Desenvolvedor
  -- 2. Fernando Gomes Braga (fgb80@yahoo.com) - Presbítero e Líder
  -- 3. Clara Góes Braga (claradiscipula@gmail.com) - Membro comum
  -- Nenhum outro usuário é criado em auth.users; os demais perfis são phantom users.
  -- ==========================================================================
  INSERT INTO auth.users (
    id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
    created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change
  ) VALUES 
    (
      gabriel_auth_id, '00000000-0000-0000-0000-000000000000', 'ggoesbraga@gmail.com', pwd_hash, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('full_name', 'Gabriel Góes Braga'),
      now(), now(), 'authenticated', 'authenticated', '', '', '', ''
    ),
    (
      fernando_auth_id, '00000000-0000-0000-0000-000000000000', 'fgb80@yahoo.com', pwd_hash, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('full_name', 'Fernando Gomes Braga'),
      now(), now(), 'authenticated', 'authenticated', '', '', '', ''
    ),
    (
      clara_auth_id, '00000000-0000-0000-0000-000000000000', 'claradiscipula@gmail.com', pwd_hash, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('full_name', 'Clara Góes Braga'),
      now(), now(), 'authenticated', 'authenticated', '', '', '', ''
    );

  -- Vinculação explícita de user_id nos perfis principais e garantia de avatar_url NULL
  UPDATE public.profiles SET user_id = gabriel_auth_id, avatar_url = NULL WHERE id = gabriel_id;
  UPDATE public.profiles SET user_id = fernando_auth_id, avatar_url = NULL WHERE id = fernando_id;
  UPDATE public.profiles SET user_id = clara_auth_id, avatar_url = NULL WHERE id = clara_id;


  -- ==========================================================================
  -- 5. ATUALIZAR LÍDERES DOS GCs (35 Grupos)
  -- ==========================================================================

  UPDATE public.home_groups SET leader_1_id = '83dc56e9-4e30-49d8-9b05-156f3482872f', leader_2_id = NULL WHERE id = '83a50912-99cf-47b1-bc98-80cb9fbaba29';
  UPDATE public.home_groups SET leader_1_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688', leader_2_id = 'bc32de95-ae0d-4e6e-8853-110b8c274e94' WHERE id = '4af7a72c-0da6-4a64-bf7d-c55aa68137d7';
  UPDATE public.home_groups SET leader_1_id = '28eb3e84-4847-4cd4-b218-28d055c380fd', leader_2_id = 'e4a3280b-7173-4cae-8995-89d54d20f457' WHERE id = 'b73e2026-ca22-46d2-a294-3379ba996162';
  UPDATE public.home_groups SET leader_1_id = '0cb227a2-c276-4e02-b7e7-727daef77a2b', leader_2_id = NULL WHERE id = 'ee1436f0-0657-4257-a61a-e2d1f1c57928';
  UPDATE public.home_groups SET leader_1_id = '03c9d7ae-f5e1-4a04-8a04-db72a03af805', leader_2_id = NULL WHERE id = '0c7104d8-12d7-4f25-bcb7-99bcb9be8154';
  UPDATE public.home_groups SET leader_1_id = '80d39d4c-d1bb-48f2-a63f-443fbeca8cb4', leader_2_id = NULL WHERE id = '3c9a69a9-8258-456a-974e-2983cadd701c';
  UPDATE public.home_groups SET leader_1_id = '90976735-8ffa-49bc-a83f-08ac0ba1ef6b', leader_2_id = NULL WHERE id = '780ea854-7cec-4230-81c9-e4a43041f7bc';
  UPDATE public.home_groups SET leader_1_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b', leader_2_id = NULL WHERE id = 'cdf863bb-4d76-41f7-804f-07bf60ec8bb4';
  UPDATE public.home_groups SET leader_1_id = 'd511c5d7-074b-4487-a6f6-d386c5c26caf', leader_2_id = NULL WHERE id = 'eaae323c-6926-4482-b7e1-152da4f9648d';
  UPDATE public.home_groups SET leader_1_id = 'b75043db-1253-4e80-aafa-2bc42470da47', leader_2_id = NULL WHERE id = 'f3c995aa-76e3-4f0c-bf3f-7f66ccc1c92f';
  UPDATE public.home_groups SET leader_1_id = '23c64fd0-87f8-49ff-8757-539a8c15e608', leader_2_id = '5e9d0524-2484-4853-a857-05f69f088c36' WHERE id = '163aafdd-7f9a-4ff7-a71e-0188050c6195';
  UPDATE public.home_groups SET leader_1_id = '196bb146-4697-4a27-8492-56f34c81deaa', leader_2_id = '05602915-b9bc-4407-87a1-5df7a82391aa' WHERE id = '2f34a3df-a312-40dd-9cf5-7d1a0638e9b4';
  UPDATE public.home_groups SET leader_1_id = 'b0be9877-22f4-49c9-9c3d-07e84507d962', leader_2_id = NULL WHERE id = '7177a5eb-e2ce-46d2-9e65-19dc6ae33d89';
  UPDATE public.home_groups SET leader_1_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e', leader_2_id = NULL WHERE id = 'd852fddc-538e-4434-9e2f-1872b5f5efba';
  UPDATE public.home_groups SET leader_1_id = 'bf40bfad-bc4c-44d1-bcfc-fb8b12cffc0a', leader_2_id = NULL WHERE id = 'bc732207-f7f7-4188-b406-999197ee1a67';
  UPDATE public.home_groups SET leader_1_id = 'b06a9fe5-8dec-446b-bcbd-9dfd06ce8580', leader_2_id = '5eb1540a-9f76-4d5c-892c-af6bb3bce959' WHERE id = '8bb4d727-bff7-4347-8711-097903498d0b';
  UPDATE public.home_groups SET leader_1_id = '4d31e76e-bc8c-42a2-a5ab-167b6f49256c', leader_2_id = 'bd0fa006-8518-4e5c-a361-9eeb7b88e410' WHERE id = 'd25e69e4-1e0b-4d7c-a85a-10f4bb833ed3';
  UPDATE public.home_groups SET leader_1_id = '61daf64d-aee5-4c56-84c3-d3839f86f816', leader_2_id = '18da0879-0e71-4401-80c3-f1b9820e2d45' WHERE id = 'dc39ae48-1c0a-43dd-9c67-955424049020';
  UPDATE public.home_groups SET leader_1_id = '72d08f64-1e96-4885-bb4d-9258a795a474', leader_2_id = NULL WHERE id = 'dffed3fd-e8a0-46b9-8928-b77819ff9a34';
  UPDATE public.home_groups SET leader_1_id = 'faaed601-4196-4df0-8438-21bd489e5abc', leader_2_id = NULL WHERE id = '0300704e-9660-4329-82ec-bae2f470555c';
  UPDATE public.home_groups SET leader_1_id = 'bb3b59e5-de49-4908-84a2-82ad4c716d15', leader_2_id = '85f0ba08-787f-44cf-8fb8-f3ee76362b15' WHERE id = '3efb7c7a-f330-4bff-8ba3-3d5465ea7feb';
  UPDATE public.home_groups SET leader_1_id = '704f02cd-6fa9-4526-8a4f-012e249354aa', leader_2_id = NULL WHERE id = 'de250387-80f7-476c-bd90-3e628d41177a';
  UPDATE public.home_groups SET leader_1_id = '5bc128dc-441c-4717-8a70-50c3400f47f8', leader_2_id = NULL WHERE id = 'ec471e7b-112d-46ab-a2c0-67aa0f24e08d';
  UPDATE public.home_groups SET leader_1_id = 'e12a7909-1947-41d0-905d-9c50893deaf2', leader_2_id = '5750fd70-f815-4499-88ea-b73bf5d98572' WHERE id = 'cf018409-11b8-49f4-bda3-1355e961ede8';
  UPDATE public.home_groups SET leader_1_id = '4d18f1b0-47b9-41ad-b24b-6fac6ee650aa', leader_2_id = NULL WHERE id = 'dbb030e2-1e77-421b-ab83-2631c334f4d3';
  UPDATE public.home_groups SET leader_1_id = '6f3da312-2192-4fb8-8919-c4a16c67915a', leader_2_id = NULL WHERE id = 'cd60ce0c-a51a-4708-932b-0665e207b3d1';
  UPDATE public.home_groups SET leader_1_id = '5ace990f-ceae-473d-b68c-a4d276ced940', leader_2_id = '94331f45-93dc-4c93-a2fb-243aa9ef0060' WHERE id = 'f49e0f88-c97b-4ca1-be5e-a7e15906c63b';
  UPDATE public.home_groups SET leader_1_id = 'e61f63a4-c117-4fcb-a3b9-0a3180610995', leader_2_id = NULL WHERE id = '3ab969d3-5651-4fff-80bd-fe37a0172322';
  UPDATE public.home_groups SET leader_1_id = '819086c6-735b-491f-a51d-c5482cd66ee8', leader_2_id = NULL WHERE id = '351e5fa9-b1a4-4761-9fc9-5e8ddf6f45b4';
  UPDATE public.home_groups SET leader_1_id = '7d7ccec7-3b36-4b39-9c6d-ba38c6fa2efb', leader_2_id = '2ebd2fc8-a82c-44bc-83de-23628d82eb75' WHERE id = '19c3d488-f5ec-4c49-92dc-db860e68436c';
  UPDATE public.home_groups SET leader_1_id = '3df444aa-89f4-4308-a01b-38622242a741', leader_2_id = NULL WHERE id = '68b0180f-7326-4450-aaba-57207a9c9a6f';
  UPDATE public.home_groups SET leader_1_id = '192eefab-7304-454a-a5fa-288e6e267258', leader_2_id = NULL WHERE id = 'd6089e13-97b8-490e-a11d-b80ea7adb7e2';
  UPDATE public.home_groups SET leader_1_id = '18d50a5c-a531-4324-a680-9832fa857cd2', leader_2_id = NULL WHERE id = '23649e02-ef06-432f-bf46-152999cfa58c';
  UPDATE public.home_groups SET leader_1_id = '839ead5c-03bb-400b-8212-07b2989cfbb2', leader_2_id = NULL WHERE id = '14b033e6-3519-4436-b716-f99189a7b01d';
  UPDATE public.home_groups SET leader_1_id = '1fe6e1e2-cb71-46e5-ba26-6c1b0d2ea434', leader_2_id = NULL WHERE id = 'fab3e3aa-f3fe-4909-8e5a-a9a73b381098';

  -- ==========================================================================
  -- 6. ATUALIZAR CASAMENTOS (spouse_id) E FILIAÇÃO (father_id, mother_id)
  -- ==========================================================================

  UPDATE public.profiles SET spouse_id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b' WHERE id = '83dc56e9-4e30-49d8-9b05-156f3482872f';
  UPDATE public.profiles SET spouse_id = '83dc56e9-4e30-49d8-9b05-156f3482872f' WHERE id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b';
  UPDATE public.profiles SET spouse_id = '394a6e33-9fa5-47f0-be1b-3ff549951b34' WHERE id = 'a21b1d50-ceb5-43b4-8a7a-24526472779e';
  UPDATE public.profiles SET spouse_id = 'a21b1d50-ceb5-43b4-8a7a-24526472779e' WHERE id = '394a6e33-9fa5-47f0-be1b-3ff549951b34';
  UPDATE public.profiles SET spouse_id = '0c5dcb2f-9f4c-4730-9fe2-3f5c21427c92' WHERE id = 'dc0ad390-9421-454a-a25f-31454fc290dd';
  UPDATE public.profiles SET spouse_id = 'dc0ad390-9421-454a-a25f-31454fc290dd' WHERE id = '0c5dcb2f-9f4c-4730-9fe2-3f5c21427c92';
  UPDATE public.profiles SET spouse_id = '4d3f179a-2501-47d6-9489-1f9657ca3b06' WHERE id = '1394e852-8f65-41c4-9603-4f0721fea0e9';
  UPDATE public.profiles SET spouse_id = '1394e852-8f65-41c4-9603-4f0721fea0e9' WHERE id = '4d3f179a-2501-47d6-9489-1f9657ca3b06';
  UPDATE public.profiles SET spouse_id = '53491e75-6ff8-447e-8056-4497a20c0c01' WHERE id = '71b0b33f-7009-4967-a752-ee5a4acbea9f';
  UPDATE public.profiles SET spouse_id = '71b0b33f-7009-4967-a752-ee5a4acbea9f' WHERE id = '53491e75-6ff8-447e-8056-4497a20c0c01';
  UPDATE public.profiles SET spouse_id = '829596bb-197d-4d12-b116-ae0dd6ddc001' WHERE id = '7802d16e-a1c5-404b-9141-3a15a1e472a7';
  UPDATE public.profiles SET spouse_id = '7802d16e-a1c5-404b-9141-3a15a1e472a7' WHERE id = '829596bb-197d-4d12-b116-ae0dd6ddc001';
  UPDATE public.profiles SET spouse_id = '12a25ecf-eed8-4736-9092-e199c32cdaaf' WHERE id = '6e2edad1-ba7f-4aff-ad40-8ea6383a88ff';
  UPDATE public.profiles SET spouse_id = '6e2edad1-ba7f-4aff-ad40-8ea6383a88ff' WHERE id = '12a25ecf-eed8-4736-9092-e199c32cdaaf';
  UPDATE public.profiles SET spouse_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = '2103520c-3b54-4b08-96d0-fbdfd6d40688';
  UPDATE public.profiles SET spouse_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688' WHERE id = '0b530795-5001-42f5-a44a-0dbe275abb65';
  UPDATE public.profiles SET spouse_id = '222a9f5e-069d-4cb3-9fe1-3f4560b38b2d' WHERE id = '788e56dd-a515-49bc-97a3-d2a1d34380aa';
  UPDATE public.profiles SET spouse_id = '788e56dd-a515-49bc-97a3-d2a1d34380aa' WHERE id = '222a9f5e-069d-4cb3-9fe1-3f4560b38b2d';
  UPDATE public.profiles SET spouse_id = 'c34d4568-7b31-484f-8e06-dcf74b136392' WHERE id = 'c85b8141-3184-4164-ac5a-71eb58abecaf';
  UPDATE public.profiles SET spouse_id = 'c85b8141-3184-4164-ac5a-71eb58abecaf' WHERE id = 'c34d4568-7b31-484f-8e06-dcf74b136392';
  UPDATE public.profiles SET spouse_id = '0cd68fba-8240-4008-b4a6-c046e424534a' WHERE id = '34dc7595-4487-4743-aba2-19fab3a44253';
  UPDATE public.profiles SET spouse_id = '34dc7595-4487-4743-aba2-19fab3a44253' WHERE id = '0cd68fba-8240-4008-b4a6-c046e424534a';
  UPDATE public.profiles SET spouse_id = 'e535df0a-7307-40dd-8085-077cc52808c2' WHERE id = '166f498c-48be-4ec4-abe3-8aedee69e007';
  UPDATE public.profiles SET spouse_id = '166f498c-48be-4ec4-abe3-8aedee69e007' WHERE id = 'e535df0a-7307-40dd-8085-077cc52808c2';
  UPDATE public.profiles SET spouse_id = 'f21319b2-9c6d-4443-8cb1-22d4af1f48a2' WHERE id = 'd6be1ebf-2ce8-43fb-b2c8-fb6bc363b497';
  UPDATE public.profiles SET spouse_id = 'd6be1ebf-2ce8-43fb-b2c8-fb6bc363b497' WHERE id = 'f21319b2-9c6d-4443-8cb1-22d4af1f48a2';
  UPDATE public.profiles SET spouse_id = '3b10f967-608d-470a-96ae-98a898410310' WHERE id = '6f2576eb-f800-41ee-b80c-57b3359867e8';
  UPDATE public.profiles SET spouse_id = '6f2576eb-f800-41ee-b80c-57b3359867e8' WHERE id = '3b10f967-608d-470a-96ae-98a898410310';
  UPDATE public.profiles SET spouse_id = 'dc9d344b-2497-4c57-906d-7cd5f7e619ba' WHERE id = 'e0fca23e-125a-4eb7-9d12-0a4bda6a02f8';
  UPDATE public.profiles SET spouse_id = 'e0fca23e-125a-4eb7-9d12-0a4bda6a02f8' WHERE id = 'dc9d344b-2497-4c57-906d-7cd5f7e619ba';
  UPDATE public.profiles SET spouse_id = '1c2618fc-7458-43a4-b0ff-a0b29d228dea' WHERE id = '9707fc03-3279-4be2-b46f-a24dd9ab24d4';
  UPDATE public.profiles SET spouse_id = '9707fc03-3279-4be2-b46f-a24dd9ab24d4' WHERE id = '1c2618fc-7458-43a4-b0ff-a0b29d228dea';
  UPDATE public.profiles SET spouse_id = '810733a5-3ce6-4f55-9837-fed9f9ab41b5' WHERE id = 'f11a2636-9554-47e6-b9fb-ab08b525d29b';
  UPDATE public.profiles SET spouse_id = 'f11a2636-9554-47e6-b9fb-ab08b525d29b' WHERE id = '810733a5-3ce6-4f55-9837-fed9f9ab41b5';
  UPDATE public.profiles SET spouse_id = '1e49b669-6156-4323-bc26-a92aa3112fd1' WHERE id = 'cccaf427-9b05-4e59-a2ac-8e7a857a3dd5';
  UPDATE public.profiles SET spouse_id = 'cccaf427-9b05-4e59-a2ac-8e7a857a3dd5' WHERE id = '1e49b669-6156-4323-bc26-a92aa3112fd1';
  UPDATE public.profiles SET spouse_id = '0e0174b8-c98b-423d-b150-8cad415a0ac3' WHERE id = 'e4a3280b-7173-4cae-8995-89d54d20f457';
  UPDATE public.profiles SET spouse_id = 'e4a3280b-7173-4cae-8995-89d54d20f457' WHERE id = '0e0174b8-c98b-423d-b150-8cad415a0ac3';
  UPDATE public.profiles SET spouse_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '28eb3e84-4847-4cd4-b218-28d055c380fd';
  UPDATE public.profiles SET spouse_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb';
  UPDATE public.profiles SET spouse_id = '85cbebb3-02c8-4d1b-a33e-0a10a7e89d4a' WHERE id = '4079f663-01a4-4d69-98ab-1d05ce7a6fa0';
  UPDATE public.profiles SET spouse_id = '4079f663-01a4-4d69-98ab-1d05ce7a6fa0' WHERE id = '85cbebb3-02c8-4d1b-a33e-0a10a7e89d4a';
  UPDATE public.profiles SET spouse_id = '6dd3d2ef-0fa4-4f29-b34b-1f0906373ad9' WHERE id = '3826197e-e8b9-4d91-b065-a3212a7a5032';
  UPDATE public.profiles SET spouse_id = '3826197e-e8b9-4d91-b065-a3212a7a5032' WHERE id = '6dd3d2ef-0fa4-4f29-b34b-1f0906373ad9';
  UPDATE public.profiles SET spouse_id = 'c214e140-a9e9-4f0b-b61a-e5e24caf2756' WHERE id = 'a557f6dd-208f-4185-8264-40871dd5617f';
  UPDATE public.profiles SET spouse_id = 'a557f6dd-208f-4185-8264-40871dd5617f' WHERE id = 'c214e140-a9e9-4f0b-b61a-e5e24caf2756';
  UPDATE public.profiles SET spouse_id = 'e06188be-384d-44e3-8ced-0921401067fe' WHERE id = 'ce46cd12-26bf-46ce-8766-d3db425b0770';
  UPDATE public.profiles SET spouse_id = 'ce46cd12-26bf-46ce-8766-d3db425b0770' WHERE id = 'e06188be-384d-44e3-8ced-0921401067fe';
  UPDATE public.profiles SET spouse_id = '34c0d78b-b7ad-4b95-b1fe-ad4f4747f695' WHERE id = '68221963-f337-4c98-8375-194da3a2e5de';
  UPDATE public.profiles SET spouse_id = '68221963-f337-4c98-8375-194da3a2e5de' WHERE id = '34c0d78b-b7ad-4b95-b1fe-ad4f4747f695';
  UPDATE public.profiles SET spouse_id = 'd2c6f368-1999-4a98-b996-f527af0c9410' WHERE id = '0cb227a2-c276-4e02-b7e7-727daef77a2b';
  UPDATE public.profiles SET spouse_id = '0cb227a2-c276-4e02-b7e7-727daef77a2b' WHERE id = 'd2c6f368-1999-4a98-b996-f527af0c9410';
  UPDATE public.profiles SET spouse_id = 'b6675f94-21df-4be9-85a4-e58d4c2ac727' WHERE id = '2c85e7af-b645-4e9f-817f-c1c46606ce6d';
  UPDATE public.profiles SET spouse_id = '2c85e7af-b645-4e9f-817f-c1c46606ce6d' WHERE id = 'b6675f94-21df-4be9-85a4-e58d4c2ac727';
  UPDATE public.profiles SET spouse_id = '836ed079-f6af-48ba-9a6f-18afc6b5bca0' WHERE id = '4bbd0433-d8b7-4c33-abd7-feba3aa9a1e3';
  UPDATE public.profiles SET spouse_id = '4bbd0433-d8b7-4c33-abd7-feba3aa9a1e3' WHERE id = '836ed079-f6af-48ba-9a6f-18afc6b5bca0';
  UPDATE public.profiles SET spouse_id = 'd25d3712-71a7-442a-8ebb-9c5943b6a0ef' WHERE id = 'e583f2a3-ea7c-4a43-aa50-b27bb0ee3d5f';
  UPDATE public.profiles SET spouse_id = 'e583f2a3-ea7c-4a43-aa50-b27bb0ee3d5f' WHERE id = 'd25d3712-71a7-442a-8ebb-9c5943b6a0ef';
  UPDATE public.profiles SET spouse_id = 'ebe9459a-5008-4364-9bc0-e5ba918460a6' WHERE id = '1d54d962-4692-4800-8d96-2c009606209d';
  UPDATE public.profiles SET spouse_id = '1d54d962-4692-4800-8d96-2c009606209d' WHERE id = 'ebe9459a-5008-4364-9bc0-e5ba918460a6';
  UPDATE public.profiles SET spouse_id = '15228aa0-4dd6-4aff-9d62-0a91cd7e6cf8' WHERE id = '8eb27ef8-c053-4080-96ca-ac23d469aac3';
  UPDATE public.profiles SET spouse_id = '8eb27ef8-c053-4080-96ca-ac23d469aac3' WHERE id = '15228aa0-4dd6-4aff-9d62-0a91cd7e6cf8';
  UPDATE public.profiles SET spouse_id = 'f1b261ea-62a7-4b09-971e-2ebb9a1f5b94' WHERE id = '5ce50357-665f-4140-a172-90ecc5f8c98a';
  UPDATE public.profiles SET spouse_id = '5ce50357-665f-4140-a172-90ecc5f8c98a' WHERE id = 'f1b261ea-62a7-4b09-971e-2ebb9a1f5b94';
  UPDATE public.profiles SET spouse_id = '1ebfc994-a0a7-49fe-9e7d-e5b68694c034' WHERE id = '03c9d7ae-f5e1-4a04-8a04-db72a03af805';
  UPDATE public.profiles SET spouse_id = '03c9d7ae-f5e1-4a04-8a04-db72a03af805' WHERE id = '1ebfc994-a0a7-49fe-9e7d-e5b68694c034';
  UPDATE public.profiles SET spouse_id = '8e4f91b5-aa21-404d-874c-7e56c390fc84' WHERE id = '6799c625-cab0-4dd8-af59-5aa393a0e0ef';
  UPDATE public.profiles SET spouse_id = '6799c625-cab0-4dd8-af59-5aa393a0e0ef' WHERE id = '8e4f91b5-aa21-404d-874c-7e56c390fc84';
  UPDATE public.profiles SET spouse_id = 'd8480bea-4379-4eb4-9bbf-3e230a8e9c84' WHERE id = '74a38e72-d95c-44fe-bf68-702933ebb38f';
  UPDATE public.profiles SET spouse_id = '74a38e72-d95c-44fe-bf68-702933ebb38f' WHERE id = 'd8480bea-4379-4eb4-9bbf-3e230a8e9c84';
  UPDATE public.profiles SET spouse_id = 'cb04150e-d431-40f0-93b3-d643eb309d38' WHERE id = '6ff738f2-72ed-4d0e-9580-2f90facfdc93';
  UPDATE public.profiles SET spouse_id = '6ff738f2-72ed-4d0e-9580-2f90facfdc93' WHERE id = 'cb04150e-d431-40f0-93b3-d643eb309d38';
  UPDATE public.profiles SET spouse_id = '94cbbff0-79a6-46c8-9871-6314d0bccb0e' WHERE id = '22ac7613-e4ce-4366-9d84-6e1e401c9f3c';
  UPDATE public.profiles SET spouse_id = '22ac7613-e4ce-4366-9d84-6e1e401c9f3c' WHERE id = '94cbbff0-79a6-46c8-9871-6314d0bccb0e';
  UPDATE public.profiles SET spouse_id = 'bb34e22c-b89b-4e16-b11f-239304fd5ed8' WHERE id = '80d39d4c-d1bb-48f2-a63f-443fbeca8cb4';
  UPDATE public.profiles SET spouse_id = '80d39d4c-d1bb-48f2-a63f-443fbeca8cb4' WHERE id = 'bb34e22c-b89b-4e16-b11f-239304fd5ed8';
  UPDATE public.profiles SET spouse_id = '24065499-8fd5-436e-a812-b80cc5ef5a48' WHERE id = '6963fca1-36f3-4935-9f86-caf837205965';
  UPDATE public.profiles SET spouse_id = '6963fca1-36f3-4935-9f86-caf837205965' WHERE id = '24065499-8fd5-436e-a812-b80cc5ef5a48';
  UPDATE public.profiles SET spouse_id = 'fd865321-ac50-4899-a46c-9a18297dd6a5' WHERE id = 'f6a2535f-462d-4b18-9601-a9add93fd611';
  UPDATE public.profiles SET spouse_id = 'f6a2535f-462d-4b18-9601-a9add93fd611' WHERE id = 'fd865321-ac50-4899-a46c-9a18297dd6a5';
  UPDATE public.profiles SET spouse_id = '3f08a58a-49d5-455a-947b-3b34570b77ac' WHERE id = 'b3335703-0ab4-4e8c-a949-31fc949c853c';
  UPDATE public.profiles SET spouse_id = 'b3335703-0ab4-4e8c-a949-31fc949c853c' WHERE id = '3f08a58a-49d5-455a-947b-3b34570b77ac';
  UPDATE public.profiles SET spouse_id = '5193c8e3-738c-422f-bcaa-5d041b95d3a4' WHERE id = '5d7233a7-cfc7-42c5-822c-7a8fd6840694';
  UPDATE public.profiles SET spouse_id = '5d7233a7-cfc7-42c5-822c-7a8fd6840694' WHERE id = '5193c8e3-738c-422f-bcaa-5d041b95d3a4';
  UPDATE public.profiles SET spouse_id = '4e530a13-634c-40eb-bfbb-75cdc11bcc92' WHERE id = '90976735-8ffa-49bc-a83f-08ac0ba1ef6b';
  UPDATE public.profiles SET spouse_id = '90976735-8ffa-49bc-a83f-08ac0ba1ef6b' WHERE id = '4e530a13-634c-40eb-bfbb-75cdc11bcc92';
  UPDATE public.profiles SET spouse_id = 'eb956c00-fe27-498c-ac9a-109ec724cd84' WHERE id = '17b191b7-2fa9-4d87-9d02-b70de72c6e7d';
  UPDATE public.profiles SET spouse_id = '17b191b7-2fa9-4d87-9d02-b70de72c6e7d' WHERE id = 'eb956c00-fe27-498c-ac9a-109ec724cd84';
  UPDATE public.profiles SET spouse_id = '0c7a08b7-c694-4247-9384-78f7684a8f46' WHERE id = 'd12bb9b3-03ef-403f-8c23-d2757e5830f4';
  UPDATE public.profiles SET spouse_id = 'd12bb9b3-03ef-403f-8c23-d2757e5830f4' WHERE id = '0c7a08b7-c694-4247-9384-78f7684a8f46';
  UPDATE public.profiles SET spouse_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b';
  UPDATE public.profiles SET spouse_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b' WHERE id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c';
  UPDATE public.profiles SET spouse_id = 'b6384c28-b589-4ea0-a152-c332fa63615c' WHERE id = '10f2efff-a9bf-4e93-a4a5-4ee7c73bb84a';
  UPDATE public.profiles SET spouse_id = '10f2efff-a9bf-4e93-a4a5-4ee7c73bb84a' WHERE id = 'b6384c28-b589-4ea0-a152-c332fa63615c';
  UPDATE public.profiles SET spouse_id = '828d72a6-a632-4adc-b497-2dc1dfe0fee5' WHERE id = 'f4b7faed-3a1a-4623-9ac5-9da45b30bffc';
  UPDATE public.profiles SET spouse_id = 'f4b7faed-3a1a-4623-9ac5-9da45b30bffc' WHERE id = '828d72a6-a632-4adc-b497-2dc1dfe0fee5';
  UPDATE public.profiles SET spouse_id = '9a46667d-67a2-457d-b555-9b637017c3c2' WHERE id = '10bf51cf-8adc-4777-941d-d86fa0bf833d';
  UPDATE public.profiles SET spouse_id = '10bf51cf-8adc-4777-941d-d86fa0bf833d' WHERE id = '9a46667d-67a2-457d-b555-9b637017c3c2';
  UPDATE public.profiles SET spouse_id = '91af39e3-6ccc-41f7-ad63-9e5461451194' WHERE id = '197f8dd1-f65f-406d-b8e6-2b4e71c4d96e';
  UPDATE public.profiles SET spouse_id = '197f8dd1-f65f-406d-b8e6-2b4e71c4d96e' WHERE id = '91af39e3-6ccc-41f7-ad63-9e5461451194';
  UPDATE public.profiles SET spouse_id = '16261a18-6bc6-45da-8254-22818ad7b083' WHERE id = '17a0709c-7cbb-4ac1-ae26-cb614a26cb63';
  UPDATE public.profiles SET spouse_id = '17a0709c-7cbb-4ac1-ae26-cb614a26cb63' WHERE id = '16261a18-6bc6-45da-8254-22818ad7b083';
  UPDATE public.profiles SET spouse_id = 'a9acaa74-80ee-4025-8b5c-1e97ecbd3abf' WHERE id = '2c1016ff-90e6-4a07-8cc2-fd68e50729fa';
  UPDATE public.profiles SET spouse_id = '2c1016ff-90e6-4a07-8cc2-fd68e50729fa' WHERE id = 'a9acaa74-80ee-4025-8b5c-1e97ecbd3abf';
  UPDATE public.profiles SET spouse_id = 'fc3551a8-f94b-4181-9db6-53936ac8fd50' WHERE id = '7088732e-76c7-4ab7-afc2-620a1ac9e05c';
  UPDATE public.profiles SET spouse_id = '7088732e-76c7-4ab7-afc2-620a1ac9e05c' WHERE id = 'fc3551a8-f94b-4181-9db6-53936ac8fd50';
  UPDATE public.profiles SET spouse_id = '8e0d81e0-f88f-4a38-a55a-0e9ac2925683' WHERE id = 'd511c5d7-074b-4487-a6f6-d386c5c26caf';
  UPDATE public.profiles SET spouse_id = 'd511c5d7-074b-4487-a6f6-d386c5c26caf' WHERE id = '8e0d81e0-f88f-4a38-a55a-0e9ac2925683';
  UPDATE public.profiles SET spouse_id = 'e3f627e3-d700-409d-a83c-98640d9fbe24' WHERE id = 'e9405db4-00d6-4d6e-8c41-8da72a59bf04';
  UPDATE public.profiles SET spouse_id = 'e9405db4-00d6-4d6e-8c41-8da72a59bf04' WHERE id = 'e3f627e3-d700-409d-a83c-98640d9fbe24';
  UPDATE public.profiles SET spouse_id = '4a10367e-28e3-467b-b5ba-5974e8c1e117' WHERE id = '85de072a-e7f6-4558-8966-f5faf498fb98';
  UPDATE public.profiles SET spouse_id = '85de072a-e7f6-4558-8966-f5faf498fb98' WHERE id = '4a10367e-28e3-467b-b5ba-5974e8c1e117';
  UPDATE public.profiles SET spouse_id = 'fc1e957f-854b-4456-b175-0fd4bac83d83' WHERE id = '7de98053-6d08-4881-961c-0a1ac14cb85d';
  UPDATE public.profiles SET spouse_id = '7de98053-6d08-4881-961c-0a1ac14cb85d' WHERE id = 'fc1e957f-854b-4456-b175-0fd4bac83d83';
  UPDATE public.profiles SET spouse_id = '69d33def-9d99-4556-b54e-4080a1697c1f' WHERE id = 'd6ef02d0-1ca8-4d7c-b662-72147442297c';
  UPDATE public.profiles SET spouse_id = 'd6ef02d0-1ca8-4d7c-b662-72147442297c' WHERE id = '69d33def-9d99-4556-b54e-4080a1697c1f';
  UPDATE public.profiles SET spouse_id = '75e5e431-2705-410f-b034-62b55d8cd199' WHERE id = 'b2cdf6d2-b9e4-4368-8cbf-991b90c43fa9';
  UPDATE public.profiles SET spouse_id = 'b2cdf6d2-b9e4-4368-8cbf-991b90c43fa9' WHERE id = '75e5e431-2705-410f-b034-62b55d8cd199';
  UPDATE public.profiles SET spouse_id = 'e6370749-fd9e-4a6f-beb2-d45e22167f4a' WHERE id = 'b75043db-1253-4e80-aafa-2bc42470da47';
  UPDATE public.profiles SET spouse_id = 'b75043db-1253-4e80-aafa-2bc42470da47' WHERE id = 'e6370749-fd9e-4a6f-beb2-d45e22167f4a';
  UPDATE public.profiles SET spouse_id = '7214d4a1-64b1-4eb6-a08d-79ed01912358' WHERE id = '75e3d51d-fd8a-4322-9937-2f7539c21d50';
  UPDATE public.profiles SET spouse_id = '75e3d51d-fd8a-4322-9937-2f7539c21d50' WHERE id = '7214d4a1-64b1-4eb6-a08d-79ed01912358';
  UPDATE public.profiles SET spouse_id = '09d0cede-3f38-4faa-9648-ad9f761792ef' WHERE id = 'bf6e07f3-e26b-4b32-b33c-5f2556fe63a6';
  UPDATE public.profiles SET spouse_id = 'bf6e07f3-e26b-4b32-b33c-5f2556fe63a6' WHERE id = '09d0cede-3f38-4faa-9648-ad9f761792ef';
  UPDATE public.profiles SET spouse_id = '83890abf-a186-4469-85b7-c9952740a827' WHERE id = 'dd0b0f66-9696-44c5-acad-9b6e07e1b2ac';
  UPDATE public.profiles SET spouse_id = 'dd0b0f66-9696-44c5-acad-9b6e07e1b2ac' WHERE id = '83890abf-a186-4469-85b7-c9952740a827';
  UPDATE public.profiles SET spouse_id = 'e4965f7a-3288-4aee-a66f-ef67ed0947c0' WHERE id = 'bd6c4119-c5a3-4cd3-adde-b3d94fbfc502';
  UPDATE public.profiles SET spouse_id = 'bd6c4119-c5a3-4cd3-adde-b3d94fbfc502' WHERE id = 'e4965f7a-3288-4aee-a66f-ef67ed0947c0';
  UPDATE public.profiles SET spouse_id = '1a8235cf-7f54-4257-b9ee-0f2afcd7eba7' WHERE id = '9e6b35ce-8b34-42a4-bcc2-343bdb45a12e';
  UPDATE public.profiles SET spouse_id = '9e6b35ce-8b34-42a4-bcc2-343bdb45a12e' WHERE id = '1a8235cf-7f54-4257-b9ee-0f2afcd7eba7';
  UPDATE public.profiles SET spouse_id = 'a3200045-59eb-4a10-bc4a-aed6a715e3c9' WHERE id = '5e9d0524-2484-4853-a857-05f69f088c36';
  UPDATE public.profiles SET spouse_id = '5e9d0524-2484-4853-a857-05f69f088c36' WHERE id = 'a3200045-59eb-4a10-bc4a-aed6a715e3c9';
  UPDATE public.profiles SET spouse_id = '9b2eed70-c556-45d4-9243-9b096d28df9a' WHERE id = '23c64fd0-87f8-49ff-8757-539a8c15e608';
  UPDATE public.profiles SET spouse_id = '23c64fd0-87f8-49ff-8757-539a8c15e608' WHERE id = '9b2eed70-c556-45d4-9243-9b096d28df9a';
  UPDATE public.profiles SET spouse_id = 'd5935a37-98a3-4723-8e7b-f0c7e0e2b076' WHERE id = '19f83197-469e-468a-835a-8d57f01b988c';
  UPDATE public.profiles SET spouse_id = '19f83197-469e-468a-835a-8d57f01b988c' WHERE id = 'd5935a37-98a3-4723-8e7b-f0c7e0e2b076';
  UPDATE public.profiles SET spouse_id = '8ad685be-5e51-406f-8d6d-c3ac79bb73b6' WHERE id = '3a5d894f-f715-4e2b-8ba6-94a502615145';
  UPDATE public.profiles SET spouse_id = '3a5d894f-f715-4e2b-8ba6-94a502615145' WHERE id = '8ad685be-5e51-406f-8d6d-c3ac79bb73b6';
  UPDATE public.profiles SET spouse_id = '8c0b3db5-99d8-4b9d-855e-c585bdf396ea' WHERE id = '56983260-593f-4ab2-ae14-6a6a9c48c808';
  UPDATE public.profiles SET spouse_id = '56983260-593f-4ab2-ae14-6a6a9c48c808' WHERE id = '8c0b3db5-99d8-4b9d-855e-c585bdf396ea';
  UPDATE public.profiles SET spouse_id = '8ffbfe83-fa4e-46a1-a4ee-d9761fb10973' WHERE id = '0bbe80ce-d7aa-4489-8133-3cd4f6a45ef7';
  UPDATE public.profiles SET spouse_id = '0bbe80ce-d7aa-4489-8133-3cd4f6a45ef7' WHERE id = '8ffbfe83-fa4e-46a1-a4ee-d9761fb10973';
  UPDATE public.profiles SET spouse_id = 'f5e0a121-576a-48b3-b918-549743bf6f81' WHERE id = '72295479-fa8b-4458-b802-f7916e4e3562';
  UPDATE public.profiles SET spouse_id = '72295479-fa8b-4458-b802-f7916e4e3562' WHERE id = 'f5e0a121-576a-48b3-b918-549743bf6f81';
  UPDATE public.profiles SET spouse_id = 'f6deff82-f7c9-4ae2-9dd6-6214cae704f6' WHERE id = '50ed612f-d637-4f23-a52a-a6b5703f2a04';
  UPDATE public.profiles SET spouse_id = '50ed612f-d637-4f23-a52a-a6b5703f2a04' WHERE id = 'f6deff82-f7c9-4ae2-9dd6-6214cae704f6';
  UPDATE public.profiles SET spouse_id = '8a9ae7fe-4956-40c4-9a76-062162119b71' WHERE id = '196bb146-4697-4a27-8492-56f34c81deaa';
  UPDATE public.profiles SET spouse_id = '196bb146-4697-4a27-8492-56f34c81deaa' WHERE id = '8a9ae7fe-4956-40c4-9a76-062162119b71';
  UPDATE public.profiles SET spouse_id = 'b3ac3988-74dc-46e5-a597-f419a1124449' WHERE id = '05602915-b9bc-4407-87a1-5df7a82391aa';
  UPDATE public.profiles SET spouse_id = '05602915-b9bc-4407-87a1-5df7a82391aa' WHERE id = 'b3ac3988-74dc-46e5-a597-f419a1124449';
  UPDATE public.profiles SET spouse_id = 'b69cc61f-f0f4-4ba3-a4c0-d4c6cedde6f8' WHERE id = '0928c425-2306-4bca-842e-7d6c4d13e5a1';
  UPDATE public.profiles SET spouse_id = '0928c425-2306-4bca-842e-7d6c4d13e5a1' WHERE id = 'b69cc61f-f0f4-4ba3-a4c0-d4c6cedde6f8';
  UPDATE public.profiles SET spouse_id = 'd28c9860-1ffd-440a-b7b9-1e42bf37cd26' WHERE id = '82f7118f-99ab-4293-8b0a-725b54a46f74';
  UPDATE public.profiles SET spouse_id = '82f7118f-99ab-4293-8b0a-725b54a46f74' WHERE id = 'd28c9860-1ffd-440a-b7b9-1e42bf37cd26';
  UPDATE public.profiles SET spouse_id = 'e1468496-9ccd-402b-bb2b-f041e2c73c5b' WHERE id = 'dab77623-6d4f-41b4-85ed-e2204450f329';
  UPDATE public.profiles SET spouse_id = 'dab77623-6d4f-41b4-85ed-e2204450f329' WHERE id = 'e1468496-9ccd-402b-bb2b-f041e2c73c5b';
  UPDATE public.profiles SET spouse_id = '031caef3-f3f6-43b3-a7b1-cff747294add' WHERE id = 'ce2bca19-82e7-4bca-a37b-6aedf1b52ab3';
  UPDATE public.profiles SET spouse_id = 'ce2bca19-82e7-4bca-a37b-6aedf1b52ab3' WHERE id = '031caef3-f3f6-43b3-a7b1-cff747294add';
  UPDATE public.profiles SET spouse_id = '06168178-e907-4261-93c3-4f319f9ba1e4' WHERE id = 'b0be9877-22f4-49c9-9c3d-07e84507d962';
  UPDATE public.profiles SET spouse_id = 'b0be9877-22f4-49c9-9c3d-07e84507d962' WHERE id = '06168178-e907-4261-93c3-4f319f9ba1e4';
  UPDATE public.profiles SET spouse_id = '72954596-2dd4-4b5a-a6cd-9bcbb12f3834' WHERE id = '4095d2a9-b662-4c65-95ae-1f8462e8e76f';
  UPDATE public.profiles SET spouse_id = '4095d2a9-b662-4c65-95ae-1f8462e8e76f' WHERE id = '72954596-2dd4-4b5a-a6cd-9bcbb12f3834';
  UPDATE public.profiles SET spouse_id = 'cb86217a-edd6-4bfd-86d6-b9ed44adc6fd' WHERE id = 'd56cc064-3114-4e3f-8ab6-dec6d8567dcd';
  UPDATE public.profiles SET spouse_id = 'd56cc064-3114-4e3f-8ab6-dec6d8567dcd' WHERE id = 'cb86217a-edd6-4bfd-86d6-b9ed44adc6fd';
  UPDATE public.profiles SET spouse_id = 'e8940714-eefb-4a99-9148-4af1246828e6' WHERE id = '29823848-0f06-4b7d-8365-851464236c4e';
  UPDATE public.profiles SET spouse_id = '29823848-0f06-4b7d-8365-851464236c4e' WHERE id = 'e8940714-eefb-4a99-9148-4af1246828e6';
  UPDATE public.profiles SET spouse_id = '1764b00f-ecc1-4dd4-ac6c-02e1c9612954' WHERE id = '209bbac1-0ad0-4395-9f19-2499d1f1f9b6';
  UPDATE public.profiles SET spouse_id = '209bbac1-0ad0-4395-9f19-2499d1f1f9b6' WHERE id = '1764b00f-ecc1-4dd4-ac6c-02e1c9612954';
  UPDATE public.profiles SET spouse_id = 'ccb5e96f-c7cc-4e6a-8740-e21b4275e834' WHERE id = '986c0cbd-679d-434b-9f40-68c7215b3b09';
  UPDATE public.profiles SET spouse_id = '986c0cbd-679d-434b-9f40-68c7215b3b09' WHERE id = 'ccb5e96f-c7cc-4e6a-8740-e21b4275e834';
  UPDATE public.profiles SET spouse_id = 'c8ad0a37-fb0c-4bbd-a4b4-b7148b521857' WHERE id = 'fc07de25-0887-4881-8a50-ec57cf905526';
  UPDATE public.profiles SET spouse_id = 'fc07de25-0887-4881-8a50-ec57cf905526' WHERE id = 'c8ad0a37-fb0c-4bbd-a4b4-b7148b521857';
  UPDATE public.profiles SET spouse_id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb' WHERE id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e';
  UPDATE public.profiles SET spouse_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e' WHERE id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb';
  UPDATE public.profiles SET spouse_id = '1c71a46b-a3cc-4315-9310-803336d71755' WHERE id = '92384d35-0f90-41a7-a3e9-4a017e60ec21';
  UPDATE public.profiles SET spouse_id = '92384d35-0f90-41a7-a3e9-4a017e60ec21' WHERE id = '1c71a46b-a3cc-4315-9310-803336d71755';
  UPDATE public.profiles SET spouse_id = 'b555407c-36fa-4849-bb6d-88f4da5a42ad' WHERE id = 'bf40bfad-bc4c-44d1-bcfc-fb8b12cffc0a';
  UPDATE public.profiles SET spouse_id = 'bf40bfad-bc4c-44d1-bcfc-fb8b12cffc0a' WHERE id = 'b555407c-36fa-4849-bb6d-88f4da5a42ad';
  UPDATE public.profiles SET spouse_id = '49f4f371-b537-4dd7-9b1f-d78737dd241e' WHERE id = 'b82446e6-c008-4185-871c-f511181b42ee';
  UPDATE public.profiles SET spouse_id = 'b82446e6-c008-4185-871c-f511181b42ee' WHERE id = '49f4f371-b537-4dd7-9b1f-d78737dd241e';
  UPDATE public.profiles SET spouse_id = 'b3374bbc-8174-4ec2-9e51-5fc9868f7e8c' WHERE id = 'cad4ccf2-0057-46fd-85c8-622acdcdec29';
  UPDATE public.profiles SET spouse_id = 'cad4ccf2-0057-46fd-85c8-622acdcdec29' WHERE id = 'b3374bbc-8174-4ec2-9e51-5fc9868f7e8c';
  UPDATE public.profiles SET spouse_id = 'f0b376bb-fe55-4589-98d5-1a8d07062f5f' WHERE id = '1ecaccfa-2234-4fde-a772-41999f6c39df';
  UPDATE public.profiles SET spouse_id = '1ecaccfa-2234-4fde-a772-41999f6c39df' WHERE id = 'f0b376bb-fe55-4589-98d5-1a8d07062f5f';
  UPDATE public.profiles SET spouse_id = 'eddac668-a914-42cd-87f7-e78070c77ed1' WHERE id = '84ff3467-1f52-4a31-9659-9389713282bb';
  UPDATE public.profiles SET spouse_id = '84ff3467-1f52-4a31-9659-9389713282bb' WHERE id = 'eddac668-a914-42cd-87f7-e78070c77ed1';
  UPDATE public.profiles SET spouse_id = '96247ee9-87ff-4461-b425-77d4954ea860' WHERE id = 'd7917e95-3ce0-471c-8202-0ec3a2b35a66';
  UPDATE public.profiles SET spouse_id = 'd7917e95-3ce0-471c-8202-0ec3a2b35a66' WHERE id = '96247ee9-87ff-4461-b425-77d4954ea860';
  UPDATE public.profiles SET spouse_id = 'bbc047e5-a6e4-4dd0-afbb-12bac35fe144' WHERE id = 'b06a9fe5-8dec-446b-bcbd-9dfd06ce8580';
  UPDATE public.profiles SET spouse_id = 'b06a9fe5-8dec-446b-bcbd-9dfd06ce8580' WHERE id = 'bbc047e5-a6e4-4dd0-afbb-12bac35fe144';
  UPDATE public.profiles SET spouse_id = 'f7aa951a-b0b0-4470-8ac1-198ce1a2ebbe' WHERE id = '5eb1540a-9f76-4d5c-892c-af6bb3bce959';
  UPDATE public.profiles SET spouse_id = '5eb1540a-9f76-4d5c-892c-af6bb3bce959' WHERE id = 'f7aa951a-b0b0-4470-8ac1-198ce1a2ebbe';
  UPDATE public.profiles SET spouse_id = 'ca85675f-2fa5-485a-a625-8b81be8d1a64' WHERE id = 'aa0281c5-73ae-4e2d-84d2-e36b0512f9cc';
  UPDATE public.profiles SET spouse_id = 'aa0281c5-73ae-4e2d-84d2-e36b0512f9cc' WHERE id = 'ca85675f-2fa5-485a-a625-8b81be8d1a64';
  UPDATE public.profiles SET spouse_id = '4ae7043d-44f1-4068-ab91-f3d0eeab7ba8' WHERE id = '4d31e76e-bc8c-42a2-a5ab-167b6f49256c';
  UPDATE public.profiles SET spouse_id = '4d31e76e-bc8c-42a2-a5ab-167b6f49256c' WHERE id = '4ae7043d-44f1-4068-ab91-f3d0eeab7ba8';
  UPDATE public.profiles SET spouse_id = '11d00d6f-7a11-4476-81e8-4da73e434acf' WHERE id = 'c727f032-2743-4d6b-858e-de980d0581bf';
  UPDATE public.profiles SET spouse_id = 'c727f032-2743-4d6b-858e-de980d0581bf' WHERE id = '11d00d6f-7a11-4476-81e8-4da73e434acf';
  UPDATE public.profiles SET spouse_id = '4db8aecd-7926-4340-ae04-a27a3d2e81cd' WHERE id = '14cf1d8e-c4ab-4bdd-859c-4e1e5d9db1a3';
  UPDATE public.profiles SET spouse_id = '14cf1d8e-c4ab-4bdd-859c-4e1e5d9db1a3' WHERE id = '4db8aecd-7926-4340-ae04-a27a3d2e81cd';
  UPDATE public.profiles SET spouse_id = '3029f46b-81aa-412b-b2db-175c1ddc07cf' WHERE id = '8fdded88-2474-405a-bb8c-78fde9c8a660';
  UPDATE public.profiles SET spouse_id = '8fdded88-2474-405a-bb8c-78fde9c8a660' WHERE id = '3029f46b-81aa-412b-b2db-175c1ddc07cf';
  UPDATE public.profiles SET spouse_id = '2f1f2b60-13e5-4b0c-a410-774d8872fd77' WHERE id = 'bd0fa006-8518-4e5c-a361-9eeb7b88e410';
  UPDATE public.profiles SET spouse_id = 'bd0fa006-8518-4e5c-a361-9eeb7b88e410' WHERE id = '2f1f2b60-13e5-4b0c-a410-774d8872fd77';
  UPDATE public.profiles SET spouse_id = '264157d0-65c9-41a1-88a8-759b06ade187' WHERE id = 'b5e86672-abfd-43c8-92bb-79abeaf95c4b';
  UPDATE public.profiles SET spouse_id = 'b5e86672-abfd-43c8-92bb-79abeaf95c4b' WHERE id = '264157d0-65c9-41a1-88a8-759b06ade187';
  UPDATE public.profiles SET spouse_id = '9508d2d2-350e-4a52-8cb1-4a94ae88d626' WHERE id = 'a725ad4d-588e-467f-9462-82a60e8ba2a6';
  UPDATE public.profiles SET spouse_id = 'a725ad4d-588e-467f-9462-82a60e8ba2a6' WHERE id = '9508d2d2-350e-4a52-8cb1-4a94ae88d626';
  UPDATE public.profiles SET spouse_id = '5b055d16-a494-432e-91d9-718bd9d025f7' WHERE id = '72d08f64-1e96-4885-bb4d-9258a795a474';
  UPDATE public.profiles SET spouse_id = '72d08f64-1e96-4885-bb4d-9258a795a474' WHERE id = '5b055d16-a494-432e-91d9-718bd9d025f7';
  UPDATE public.profiles SET spouse_id = 'bcf09900-bfd7-4218-bc09-1238e3c22160' WHERE id = '63cdc71a-7c76-4699-8669-24dd376f5af3';
  UPDATE public.profiles SET spouse_id = '63cdc71a-7c76-4699-8669-24dd376f5af3' WHERE id = 'bcf09900-bfd7-4218-bc09-1238e3c22160';
  UPDATE public.profiles SET spouse_id = '55a28087-f3c1-4bcd-b095-c5bee6988be1' WHERE id = 'fcca9a58-8884-4045-a801-0141179e7d2e';
  UPDATE public.profiles SET spouse_id = 'fcca9a58-8884-4045-a801-0141179e7d2e' WHERE id = '55a28087-f3c1-4bcd-b095-c5bee6988be1';
  UPDATE public.profiles SET spouse_id = '4cac4489-e119-436d-8c8a-ca3423f908db' WHERE id = 'b5267032-355b-4607-94a1-0aec6269edc3';
  UPDATE public.profiles SET spouse_id = 'b5267032-355b-4607-94a1-0aec6269edc3' WHERE id = '4cac4489-e119-436d-8c8a-ca3423f908db';
  UPDATE public.profiles SET spouse_id = 'bbb06ecb-b796-41d2-adf6-3fb2a73db662' WHERE id = '15e5ea74-1e7d-4250-9cd2-eb9388318281';
  UPDATE public.profiles SET spouse_id = '15e5ea74-1e7d-4250-9cd2-eb9388318281' WHERE id = 'bbb06ecb-b796-41d2-adf6-3fb2a73db662';
  UPDATE public.profiles SET spouse_id = '004180b8-4859-4c36-8849-50bf9b69fcd1' WHERE id = '788e0714-d1d7-4d4a-b15a-225820c4ae45';
  UPDATE public.profiles SET spouse_id = '788e0714-d1d7-4d4a-b15a-225820c4ae45' WHERE id = '004180b8-4859-4c36-8849-50bf9b69fcd1';
  UPDATE public.profiles SET spouse_id = '1cdd7881-8fa9-4fd2-bf17-6fc703151f3a' WHERE id = '63b49986-0e63-4d9e-bea2-c3058a42e5fa';
  UPDATE public.profiles SET spouse_id = '63b49986-0e63-4d9e-bea2-c3058a42e5fa' WHERE id = '1cdd7881-8fa9-4fd2-bf17-6fc703151f3a';
  UPDATE public.profiles SET spouse_id = '967897ce-e167-4250-857e-302a934c4cd3' WHERE id = 'f47eb221-9849-446f-9299-2c2a96c3b72b';
  UPDATE public.profiles SET spouse_id = 'f47eb221-9849-446f-9299-2c2a96c3b72b' WHERE id = '967897ce-e167-4250-857e-302a934c4cd3';
  UPDATE public.profiles SET spouse_id = '046a62cd-d1a0-454e-a1b9-b774fb4517ea' WHERE id = 'c8a4ba56-d20d-4f47-b497-07de3bffc815';
  UPDATE public.profiles SET spouse_id = 'c8a4ba56-d20d-4f47-b497-07de3bffc815' WHERE id = '046a62cd-d1a0-454e-a1b9-b774fb4517ea';
  UPDATE public.profiles SET spouse_id = '95f71fa0-6237-4c0b-80fc-d99e2ce0f84d' WHERE id = 'faaed601-4196-4df0-8438-21bd489e5abc';
  UPDATE public.profiles SET spouse_id = 'faaed601-4196-4df0-8438-21bd489e5abc' WHERE id = '95f71fa0-6237-4c0b-80fc-d99e2ce0f84d';
  UPDATE public.profiles SET spouse_id = '00cf56f2-ddae-4076-9ab1-d4b5761ed7e8' WHERE id = '9f6a094c-e3b3-4522-bd49-d442a676e504';
  UPDATE public.profiles SET spouse_id = '9f6a094c-e3b3-4522-bd49-d442a676e504' WHERE id = '00cf56f2-ddae-4076-9ab1-d4b5761ed7e8';
  UPDATE public.profiles SET spouse_id = '50037ebc-403d-45f6-aa98-170dd6ca1f30' WHERE id = '83f933b7-2b28-4ed7-9143-719e1f10b709';
  UPDATE public.profiles SET spouse_id = '83f933b7-2b28-4ed7-9143-719e1f10b709' WHERE id = '50037ebc-403d-45f6-aa98-170dd6ca1f30';
  UPDATE public.profiles SET spouse_id = 'ad1c7be3-0954-46da-8525-2ab725a3e949' WHERE id = '9d22fa36-1329-450e-b8d6-caac02c44d66';
  UPDATE public.profiles SET spouse_id = '9d22fa36-1329-450e-b8d6-caac02c44d66' WHERE id = 'ad1c7be3-0954-46da-8525-2ab725a3e949';
  UPDATE public.profiles SET spouse_id = '20299992-40a3-464b-af2f-6445fdf3b48c' WHERE id = 'd81b32d8-3361-4785-8f84-47842b070fa7';
  UPDATE public.profiles SET spouse_id = 'd81b32d8-3361-4785-8f84-47842b070fa7' WHERE id = '20299992-40a3-464b-af2f-6445fdf3b48c';
  UPDATE public.profiles SET spouse_id = '12f1d11a-a53c-4109-a055-82be54fde14f' WHERE id = 'bb3b59e5-de49-4908-84a2-82ad4c716d15';
  UPDATE public.profiles SET spouse_id = 'bb3b59e5-de49-4908-84a2-82ad4c716d15' WHERE id = '12f1d11a-a53c-4109-a055-82be54fde14f';
  UPDATE public.profiles SET spouse_id = 'c49f8547-ffe9-4fba-89f0-4856e09f7324' WHERE id = '85f0ba08-787f-44cf-8fb8-f3ee76362b15';
  UPDATE public.profiles SET spouse_id = '85f0ba08-787f-44cf-8fb8-f3ee76362b15' WHERE id = 'c49f8547-ffe9-4fba-89f0-4856e09f7324';
  UPDATE public.profiles SET spouse_id = '34a64dbc-42d1-4df7-bece-25fd54cbe584' WHERE id = '218d21b4-19df-42fa-868a-1c028a20626f';
  UPDATE public.profiles SET spouse_id = '218d21b4-19df-42fa-868a-1c028a20626f' WHERE id = '34a64dbc-42d1-4df7-bece-25fd54cbe584';
  UPDATE public.profiles SET spouse_id = '357bb926-8ea8-41bb-86e0-32c6b37e417e' WHERE id = '0ec1ff8c-f44c-477e-861e-daa350347e36';
  UPDATE public.profiles SET spouse_id = '0ec1ff8c-f44c-477e-861e-daa350347e36' WHERE id = '357bb926-8ea8-41bb-86e0-32c6b37e417e';
  UPDATE public.profiles SET spouse_id = '425ec989-d1c8-4a54-90d5-58edca13c06c' WHERE id = '3c6f6c07-3af7-4103-8a2d-aedc8b8d76bf';
  UPDATE public.profiles SET spouse_id = '3c6f6c07-3af7-4103-8a2d-aedc8b8d76bf' WHERE id = '425ec989-d1c8-4a54-90d5-58edca13c06c';
  UPDATE public.profiles SET spouse_id = 'f2fec21f-655d-4070-bce4-f4c212acf790' WHERE id = '704f02cd-6fa9-4526-8a4f-012e249354aa';
  UPDATE public.profiles SET spouse_id = '704f02cd-6fa9-4526-8a4f-012e249354aa' WHERE id = 'f2fec21f-655d-4070-bce4-f4c212acf790';
  UPDATE public.profiles SET spouse_id = '7f3040e2-7759-40ee-b56f-f28fbe59415b' WHERE id = '54c838b1-40a3-4d4b-81ca-d97ae90e66be';
  UPDATE public.profiles SET spouse_id = '54c838b1-40a3-4d4b-81ca-d97ae90e66be' WHERE id = '7f3040e2-7759-40ee-b56f-f28fbe59415b';
  UPDATE public.profiles SET spouse_id = 'b1fa870e-1149-477f-8ca1-6d8da6c5f7e2' WHERE id = 'cf4e3514-aeca-4441-a155-3ebedfd8faf5';
  UPDATE public.profiles SET spouse_id = 'cf4e3514-aeca-4441-a155-3ebedfd8faf5' WHERE id = 'b1fa870e-1149-477f-8ca1-6d8da6c5f7e2';
  UPDATE public.profiles SET spouse_id = 'f6555fc8-2176-4de0-9bdd-1271b2dd9664' WHERE id = '392ce5d3-1315-4758-9a91-f37f72d649fd';
  UPDATE public.profiles SET spouse_id = '392ce5d3-1315-4758-9a91-f37f72d649fd' WHERE id = 'f6555fc8-2176-4de0-9bdd-1271b2dd9664';
  UPDATE public.profiles SET spouse_id = 'd6098285-5234-4f63-ae72-2f81b0f47809' WHERE id = '5bc128dc-441c-4717-8a70-50c3400f47f8';
  UPDATE public.profiles SET spouse_id = '5bc128dc-441c-4717-8a70-50c3400f47f8' WHERE id = 'd6098285-5234-4f63-ae72-2f81b0f47809';
  UPDATE public.profiles SET spouse_id = '24c74460-e6dd-49ab-9921-721fd4ef6055' WHERE id = '1d64e2be-8aac-4540-95cd-92d5cbde61b2';
  UPDATE public.profiles SET spouse_id = '1d64e2be-8aac-4540-95cd-92d5cbde61b2' WHERE id = '24c74460-e6dd-49ab-9921-721fd4ef6055';
  UPDATE public.profiles SET spouse_id = 'ca67335c-c99a-4c92-9aa3-f766b20f9721' WHERE id = '4ad0f26a-462f-4c82-bb53-317081e69cb1';
  UPDATE public.profiles SET spouse_id = '4ad0f26a-462f-4c82-bb53-317081e69cb1' WHERE id = 'ca67335c-c99a-4c92-9aa3-f766b20f9721';
  UPDATE public.profiles SET spouse_id = '8d14b1e3-3c0f-4739-b404-46d72d21cc74' WHERE id = '5750fd70-f815-4499-88ea-b73bf5d98572';
  UPDATE public.profiles SET spouse_id = '5750fd70-f815-4499-88ea-b73bf5d98572' WHERE id = '8d14b1e3-3c0f-4739-b404-46d72d21cc74';
  UPDATE public.profiles SET spouse_id = 'cfda9987-6152-4144-b413-55fa1d52c2ea' WHERE id = 'e12a7909-1947-41d0-905d-9c50893deaf2';
  UPDATE public.profiles SET spouse_id = 'e12a7909-1947-41d0-905d-9c50893deaf2' WHERE id = 'cfda9987-6152-4144-b413-55fa1d52c2ea';
  UPDATE public.profiles SET spouse_id = 'fafb068b-ac68-4ae7-bcbb-f2ff2374af83' WHERE id = '1b171281-cd18-4fb3-b853-76ea6529d92e';
  UPDATE public.profiles SET spouse_id = '1b171281-cd18-4fb3-b853-76ea6529d92e' WHERE id = 'fafb068b-ac68-4ae7-bcbb-f2ff2374af83';
  UPDATE public.profiles SET spouse_id = '721f2776-a2df-467d-8f67-8c3ded548e64' WHERE id = '32175a59-c0c6-4e02-9050-4d5ceff4127b';
  UPDATE public.profiles SET spouse_id = '32175a59-c0c6-4e02-9050-4d5ceff4127b' WHERE id = '721f2776-a2df-467d-8f67-8c3ded548e64';
  UPDATE public.profiles SET spouse_id = 'c5faf10a-0846-46b2-a16e-88ae8b95856e' WHERE id = '4d18f1b0-47b9-41ad-b24b-6fac6ee650aa';
  UPDATE public.profiles SET spouse_id = '4d18f1b0-47b9-41ad-b24b-6fac6ee650aa' WHERE id = 'c5faf10a-0846-46b2-a16e-88ae8b95856e';
  UPDATE public.profiles SET spouse_id = 'c184e060-a860-4c2a-a057-edf7ee84372b' WHERE id = 'c88177e4-1da0-429c-8568-65e4f339bf74';
  UPDATE public.profiles SET spouse_id = 'c88177e4-1da0-429c-8568-65e4f339bf74' WHERE id = 'c184e060-a860-4c2a-a057-edf7ee84372b';
  UPDATE public.profiles SET spouse_id = '7d922828-7f20-4eb2-83f2-6da6b04c6a0c' WHERE id = 'e1af9709-5187-4e93-869a-72253199e61c';
  UPDATE public.profiles SET spouse_id = 'e1af9709-5187-4e93-869a-72253199e61c' WHERE id = '7d922828-7f20-4eb2-83f2-6da6b04c6a0c';
  UPDATE public.profiles SET spouse_id = '978c37e3-26a8-4583-bc0d-c454040432f2' WHERE id = 'b09df62b-0492-418a-8f67-ac5908f2840b';
  UPDATE public.profiles SET spouse_id = 'b09df62b-0492-418a-8f67-ac5908f2840b' WHERE id = '978c37e3-26a8-4583-bc0d-c454040432f2';
  UPDATE public.profiles SET spouse_id = '2d4f11b7-3864-48ca-8dfb-acac13e3e633' WHERE id = 'b21fb951-c70c-489b-bb83-126b869ad4da';
  UPDATE public.profiles SET spouse_id = 'b21fb951-c70c-489b-bb83-126b869ad4da' WHERE id = '2d4f11b7-3864-48ca-8dfb-acac13e3e633';
  UPDATE public.profiles SET spouse_id = '59dc55a4-6480-4083-882f-a9fde99f42f2' WHERE id = 'e795724e-2230-44b6-a330-3c1757eb511e';
  UPDATE public.profiles SET spouse_id = 'e795724e-2230-44b6-a330-3c1757eb511e' WHERE id = '59dc55a4-6480-4083-882f-a9fde99f42f2';
  UPDATE public.profiles SET spouse_id = '49f67b24-3323-401d-91c1-23153a80de7c' WHERE id = '0f7e7416-c29b-4d6c-9d1c-3b66c716d5d2';
  UPDATE public.profiles SET spouse_id = '0f7e7416-c29b-4d6c-9d1c-3b66c716d5d2' WHERE id = '49f67b24-3323-401d-91c1-23153a80de7c';
  UPDATE public.profiles SET spouse_id = '91745890-20f0-4a7b-8403-f6a9d8e1974a' WHERE id = '9e8c8eb7-b83b-4fed-aaf9-df5a5c3c0a72';
  UPDATE public.profiles SET spouse_id = '9e8c8eb7-b83b-4fed-aaf9-df5a5c3c0a72' WHERE id = '91745890-20f0-4a7b-8403-f6a9d8e1974a';
  UPDATE public.profiles SET spouse_id = '197e0ace-9c04-4d98-9a58-514b92e32b35' WHERE id = '6f3da312-2192-4fb8-8919-c4a16c67915a';
  UPDATE public.profiles SET spouse_id = '6f3da312-2192-4fb8-8919-c4a16c67915a' WHERE id = '197e0ace-9c04-4d98-9a58-514b92e32b35';
  UPDATE public.profiles SET spouse_id = '5aef5ec9-d89e-4a90-93fa-2b7b835c82db' WHERE id = '94331f45-93dc-4c93-a2fb-243aa9ef0060';
  UPDATE public.profiles SET spouse_id = '94331f45-93dc-4c93-a2fb-243aa9ef0060' WHERE id = '5aef5ec9-d89e-4a90-93fa-2b7b835c82db';
  UPDATE public.profiles SET spouse_id = '50122db6-6e32-4e4a-b670-51311e2c483d' WHERE id = 'f76a602c-8be1-4ab6-b41b-26d71404da4a';
  UPDATE public.profiles SET spouse_id = 'f76a602c-8be1-4ab6-b41b-26d71404da4a' WHERE id = '50122db6-6e32-4e4a-b670-51311e2c483d';
  UPDATE public.profiles SET spouse_id = '091cd3e0-1a7c-4020-8742-1615ad4716d1' WHERE id = 'dd4f1d70-a6ba-491e-89d5-d687558c3969';
  UPDATE public.profiles SET spouse_id = 'dd4f1d70-a6ba-491e-89d5-d687558c3969' WHERE id = '091cd3e0-1a7c-4020-8742-1615ad4716d1';
  UPDATE public.profiles SET spouse_id = '5f304ecd-5612-4bc8-b4c5-6305afdf424f' WHERE id = '5ace990f-ceae-473d-b68c-a4d276ced940';
  UPDATE public.profiles SET spouse_id = '5ace990f-ceae-473d-b68c-a4d276ced940' WHERE id = '5f304ecd-5612-4bc8-b4c5-6305afdf424f';
  UPDATE public.profiles SET spouse_id = '6e5bb176-7465-4a41-a54b-5744ddf342ef' WHERE id = '3456c288-6616-449b-ad4f-7a6fa4c2b64e';
  UPDATE public.profiles SET spouse_id = '3456c288-6616-449b-ad4f-7a6fa4c2b64e' WHERE id = '6e5bb176-7465-4a41-a54b-5744ddf342ef';
  UPDATE public.profiles SET spouse_id = 'd60538f9-f4e2-445d-a05a-48440392b15b' WHERE id = 'e61f63a4-c117-4fcb-a3b9-0a3180610995';
  UPDATE public.profiles SET spouse_id = 'e61f63a4-c117-4fcb-a3b9-0a3180610995' WHERE id = 'd60538f9-f4e2-445d-a05a-48440392b15b';
  UPDATE public.profiles SET spouse_id = 'eb58b79f-4fe6-4449-9c7f-c3984f2024c5' WHERE id = '2432be66-38cf-4425-bd0d-19f773bdb458';
  UPDATE public.profiles SET spouse_id = '2432be66-38cf-4425-bd0d-19f773bdb458' WHERE id = 'eb58b79f-4fe6-4449-9c7f-c3984f2024c5';
  UPDATE public.profiles SET spouse_id = '32ba3595-2b00-4919-9df1-fee06f8f84fe' WHERE id = '9df93b7a-f166-4e1a-8ac8-cfc9d43cf8e7';
  UPDATE public.profiles SET spouse_id = '9df93b7a-f166-4e1a-8ac8-cfc9d43cf8e7' WHERE id = '32ba3595-2b00-4919-9df1-fee06f8f84fe';
  UPDATE public.profiles SET spouse_id = '2467d6c7-d1f6-4fb9-8fae-eb8f9ce6fe74' WHERE id = 'a372098d-62fa-4a2d-add7-2cd5038ad667';
  UPDATE public.profiles SET spouse_id = 'a372098d-62fa-4a2d-add7-2cd5038ad667' WHERE id = '2467d6c7-d1f6-4fb9-8fae-eb8f9ce6fe74';
  UPDATE public.profiles SET spouse_id = '2df675af-78b3-4bfc-907b-d90462fe9608' WHERE id = '91cf41bd-205d-46ac-b61a-d37355a3d1a0';
  UPDATE public.profiles SET spouse_id = '91cf41bd-205d-46ac-b61a-d37355a3d1a0' WHERE id = '2df675af-78b3-4bfc-907b-d90462fe9608';
  UPDATE public.profiles SET spouse_id = 'a9ad90de-d5e4-49ee-b8b5-e7e5ea480953' WHERE id = '9864ebf7-d26e-48b2-b0e1-9e88f02ab7ae';
  UPDATE public.profiles SET spouse_id = '9864ebf7-d26e-48b2-b0e1-9e88f02ab7ae' WHERE id = 'a9ad90de-d5e4-49ee-b8b5-e7e5ea480953';
  UPDATE public.profiles SET spouse_id = '98114201-94e3-437b-a076-a8855d8129a9' WHERE id = '819086c6-735b-491f-a51d-c5482cd66ee8';
  UPDATE public.profiles SET spouse_id = '819086c6-735b-491f-a51d-c5482cd66ee8' WHERE id = '98114201-94e3-437b-a076-a8855d8129a9';
  UPDATE public.profiles SET spouse_id = '7c7de20f-8b09-434f-8344-f182f91f2e04' WHERE id = '69843d4e-54a6-4b79-ad8d-da49ac601235';
  UPDATE public.profiles SET spouse_id = '69843d4e-54a6-4b79-ad8d-da49ac601235' WHERE id = '7c7de20f-8b09-434f-8344-f182f91f2e04';
  UPDATE public.profiles SET spouse_id = '31313de6-b5cc-45b7-87d0-8bc03e7fa5cd' WHERE id = '38e1116f-4ed8-45e1-9a55-c1948b4e6575';
  UPDATE public.profiles SET spouse_id = '38e1116f-4ed8-45e1-9a55-c1948b4e6575' WHERE id = '31313de6-b5cc-45b7-87d0-8bc03e7fa5cd';
  UPDATE public.profiles SET spouse_id = '2fc663f3-a8d5-4e1b-a2dc-98520dda38b2' WHERE id = '7d7ccec7-3b36-4b39-9c6d-ba38c6fa2efb';
  UPDATE public.profiles SET spouse_id = '7d7ccec7-3b36-4b39-9c6d-ba38c6fa2efb' WHERE id = '2fc663f3-a8d5-4e1b-a2dc-98520dda38b2';
  UPDATE public.profiles SET spouse_id = '27a9f505-d6d0-4545-a759-a536e1cfefd3' WHERE id = '2ebd2fc8-a82c-44bc-83de-23628d82eb75';
  UPDATE public.profiles SET spouse_id = '2ebd2fc8-a82c-44bc-83de-23628d82eb75' WHERE id = '27a9f505-d6d0-4545-a759-a536e1cfefd3';
  UPDATE public.profiles SET spouse_id = 'ca0d3bd6-62f5-42da-ab0b-2321de784d95' WHERE id = '85dfa227-5e5f-43d2-ae5e-937147f285ba';
  UPDATE public.profiles SET spouse_id = '85dfa227-5e5f-43d2-ae5e-937147f285ba' WHERE id = 'ca0d3bd6-62f5-42da-ab0b-2321de784d95';
  UPDATE public.profiles SET spouse_id = '49838a47-3629-462c-9fa3-aa84894b2067' WHERE id = '3aab63de-7999-4c10-b96f-d79b613ef069';
  UPDATE public.profiles SET spouse_id = '3aab63de-7999-4c10-b96f-d79b613ef069' WHERE id = '49838a47-3629-462c-9fa3-aa84894b2067';
  UPDATE public.profiles SET spouse_id = 'b26c7ec3-d2d9-411e-9638-0db835db733a' WHERE id = '5b2a9424-af91-4967-9a18-3d682d04005a';
  UPDATE public.profiles SET spouse_id = '5b2a9424-af91-4967-9a18-3d682d04005a' WHERE id = 'b26c7ec3-d2d9-411e-9638-0db835db733a';
  UPDATE public.profiles SET spouse_id = 'efe99423-c7f0-4080-bb25-bb9e977f72d2' WHERE id = '9eac8950-47b0-4612-b4a5-095c656f7054';
  UPDATE public.profiles SET spouse_id = '9eac8950-47b0-4612-b4a5-095c656f7054' WHERE id = 'efe99423-c7f0-4080-bb25-bb9e977f72d2';
  UPDATE public.profiles SET spouse_id = '6415fe87-33e5-48cc-844d-f5ed9eae8be7' WHERE id = 'f53f0316-2854-4ca7-b501-7ca0d5ec5d3d';
  UPDATE public.profiles SET spouse_id = 'f53f0316-2854-4ca7-b501-7ca0d5ec5d3d' WHERE id = '6415fe87-33e5-48cc-844d-f5ed9eae8be7';
  UPDATE public.profiles SET spouse_id = 'c369a90d-4316-4d4e-a31a-6c13bfb9c996' WHERE id = '3df444aa-89f4-4308-a01b-38622242a741';
  UPDATE public.profiles SET spouse_id = '3df444aa-89f4-4308-a01b-38622242a741' WHERE id = 'c369a90d-4316-4d4e-a31a-6c13bfb9c996';
  UPDATE public.profiles SET spouse_id = '6234ade4-b8bb-4611-b3f9-463fb0b4caba' WHERE id = 'ba110cff-557b-45db-a196-c6e8fc8e71a4';
  UPDATE public.profiles SET spouse_id = 'ba110cff-557b-45db-a196-c6e8fc8e71a4' WHERE id = '6234ade4-b8bb-4611-b3f9-463fb0b4caba';
  UPDATE public.profiles SET spouse_id = 'e2487d28-89eb-4394-857c-6f30a8688675' WHERE id = 'a9d51b21-df82-4c56-9186-7151224e65a5';
  UPDATE public.profiles SET spouse_id = 'a9d51b21-df82-4c56-9186-7151224e65a5' WHERE id = 'e2487d28-89eb-4394-857c-6f30a8688675';
  UPDATE public.profiles SET spouse_id = '509e34f6-b484-417c-8223-8408409ce779' WHERE id = '0d0cf63e-7521-443c-95bc-f85fc98546e9';
  UPDATE public.profiles SET spouse_id = '0d0cf63e-7521-443c-95bc-f85fc98546e9' WHERE id = '509e34f6-b484-417c-8223-8408409ce779';
  UPDATE public.profiles SET spouse_id = '65dead1d-7158-4122-8d2f-90b636cd173c' WHERE id = '2802e112-f41d-4d6c-ac84-793ba506e93e';
  UPDATE public.profiles SET spouse_id = '2802e112-f41d-4d6c-ac84-793ba506e93e' WHERE id = '65dead1d-7158-4122-8d2f-90b636cd173c';
  UPDATE public.profiles SET spouse_id = '155b0a35-78f5-41ed-957e-85daa9539fb4' WHERE id = '61a927f1-2168-484a-8629-ede964f204e1';
  UPDATE public.profiles SET spouse_id = '61a927f1-2168-484a-8629-ede964f204e1' WHERE id = '155b0a35-78f5-41ed-957e-85daa9539fb4';
  UPDATE public.profiles SET spouse_id = '13208420-1f67-46e3-bd1a-0e8e9722dfc8' WHERE id = '2ee08aed-3fd5-4f3e-8cdc-5b1d4782c23d';
  UPDATE public.profiles SET spouse_id = '2ee08aed-3fd5-4f3e-8cdc-5b1d4782c23d' WHERE id = '13208420-1f67-46e3-bd1a-0e8e9722dfc8';
  UPDATE public.profiles SET spouse_id = '1bca7d3e-f87d-4ce3-975d-d5896046064a' WHERE id = 'ed986db6-452c-4ef3-9340-474b7aca1df9';
  UPDATE public.profiles SET spouse_id = 'ed986db6-452c-4ef3-9340-474b7aca1df9' WHERE id = '1bca7d3e-f87d-4ce3-975d-d5896046064a';
  UPDATE public.profiles SET spouse_id = '1e664157-86cd-4f8c-a896-0a05bd145073' WHERE id = '192eefab-7304-454a-a5fa-288e6e267258';
  UPDATE public.profiles SET spouse_id = '192eefab-7304-454a-a5fa-288e6e267258' WHERE id = '1e664157-86cd-4f8c-a896-0a05bd145073';
  UPDATE public.profiles SET spouse_id = 'fdc5e5c9-2e6c-4b71-936a-bf6e1f1be73b' WHERE id = 'fa38cfc7-728e-4c52-a6bb-c633d2b834fc';
  UPDATE public.profiles SET spouse_id = 'fa38cfc7-728e-4c52-a6bb-c633d2b834fc' WHERE id = 'fdc5e5c9-2e6c-4b71-936a-bf6e1f1be73b';
  UPDATE public.profiles SET spouse_id = '9553e140-a3d3-4602-8dec-deb41f4a3db9' WHERE id = 'a1ea11cf-40b5-4960-8359-fc60217a11bd';
  UPDATE public.profiles SET spouse_id = 'a1ea11cf-40b5-4960-8359-fc60217a11bd' WHERE id = '9553e140-a3d3-4602-8dec-deb41f4a3db9';
  UPDATE public.profiles SET spouse_id = '18657a6d-9e7c-40a8-89d8-7e35236bf7d8' WHERE id = '7edd7fe4-0dac-457f-933d-b1f57afffa25';
  UPDATE public.profiles SET spouse_id = '7edd7fe4-0dac-457f-933d-b1f57afffa25' WHERE id = '18657a6d-9e7c-40a8-89d8-7e35236bf7d8';
  UPDATE public.profiles SET spouse_id = 'eea78a25-abf7-4da4-8f48-1b63d240ea68' WHERE id = '5ea206d2-8d61-42ff-a7be-fda5c18a6dfb';
  UPDATE public.profiles SET spouse_id = '5ea206d2-8d61-42ff-a7be-fda5c18a6dfb' WHERE id = 'eea78a25-abf7-4da4-8f48-1b63d240ea68';
  UPDATE public.profiles SET spouse_id = 'da12dc4e-6934-490a-84bf-a186bb750f12' WHERE id = '947a30d4-f34c-4a63-a81a-993b3e2ab741';
  UPDATE public.profiles SET spouse_id = '947a30d4-f34c-4a63-a81a-993b3e2ab741' WHERE id = 'da12dc4e-6934-490a-84bf-a186bb750f12';
  UPDATE public.profiles SET spouse_id = '24af58f5-b953-4455-afdb-0bedf37a64f2' WHERE id = '18d50a5c-a531-4324-a680-9832fa857cd2';
  UPDATE public.profiles SET spouse_id = '18d50a5c-a531-4324-a680-9832fa857cd2' WHERE id = '24af58f5-b953-4455-afdb-0bedf37a64f2';
  UPDATE public.profiles SET spouse_id = '2011e28d-b353-487e-8bdb-b5aad51d574b' WHERE id = 'dfa88997-39d0-4a9b-b6a3-035104389c44';
  UPDATE public.profiles SET spouse_id = 'dfa88997-39d0-4a9b-b6a3-035104389c44' WHERE id = '2011e28d-b353-487e-8bdb-b5aad51d574b';
  UPDATE public.profiles SET spouse_id = '7c6c7261-9358-475e-b24c-1e5d3ea60124' WHERE id = 'f2b78013-1604-4338-9838-2feb52f78055';
  UPDATE public.profiles SET spouse_id = 'f2b78013-1604-4338-9838-2feb52f78055' WHERE id = '7c6c7261-9358-475e-b24c-1e5d3ea60124';
  UPDATE public.profiles SET spouse_id = '350000fd-135e-49ad-b022-0684edade46d' WHERE id = '03fe773f-ac9e-46e1-85ad-9322a4980440';
  UPDATE public.profiles SET spouse_id = '03fe773f-ac9e-46e1-85ad-9322a4980440' WHERE id = '350000fd-135e-49ad-b022-0684edade46d';
  UPDATE public.profiles SET spouse_id = 'bf9ae785-2817-41a5-a9a5-8e8d97c1cc48' WHERE id = '67b02882-2914-4f29-aeb0-0e5067a76539';
  UPDATE public.profiles SET spouse_id = '67b02882-2914-4f29-aeb0-0e5067a76539' WHERE id = 'bf9ae785-2817-41a5-a9a5-8e8d97c1cc48';
  UPDATE public.profiles SET spouse_id = 'bb39230a-b444-4cb6-a8b6-8340c5559862' WHERE id = '849a3ace-7380-409b-a73e-16d58135403e';
  UPDATE public.profiles SET spouse_id = '849a3ace-7380-409b-a73e-16d58135403e' WHERE id = 'bb39230a-b444-4cb6-a8b6-8340c5559862';
  UPDATE public.profiles SET spouse_id = '83358379-36e8-4e78-8270-2997145d144a' WHERE id = 'b802b313-1f03-44a1-9431-4fda4df0bdcd';
  UPDATE public.profiles SET spouse_id = 'b802b313-1f03-44a1-9431-4fda4df0bdcd' WHERE id = '83358379-36e8-4e78-8270-2997145d144a';
  UPDATE public.profiles SET spouse_id = '9f2b6bba-416f-4c5c-a3a1-7fc47ecad0f2' WHERE id = '839ead5c-03bb-400b-8212-07b2989cfbb2';
  UPDATE public.profiles SET spouse_id = '839ead5c-03bb-400b-8212-07b2989cfbb2' WHERE id = '9f2b6bba-416f-4c5c-a3a1-7fc47ecad0f2';
  UPDATE public.profiles SET spouse_id = 'fc6f093e-d58a-42d7-abb5-1fe6547e051e' WHERE id = '555fcf55-c67d-46e2-aa90-bfd324ad4476';
  UPDATE public.profiles SET spouse_id = '555fcf55-c67d-46e2-aa90-bfd324ad4476' WHERE id = 'fc6f093e-d58a-42d7-abb5-1fe6547e051e';
  UPDATE public.profiles SET spouse_id = 'f3197176-da64-47fa-bd4d-2b9729e50590' WHERE id = '1fe6e1e2-cb71-46e5-ba26-6c1b0d2ea434';
  UPDATE public.profiles SET spouse_id = '1fe6e1e2-cb71-46e5-ba26-6c1b0d2ea434' WHERE id = 'f3197176-da64-47fa-bd4d-2b9729e50590';
  UPDATE public.profiles SET spouse_id = '9100c0ed-3f3e-46be-be53-ae1f33177482' WHERE id = '1551f859-b707-46cb-8aa5-a900371ac15d';
  UPDATE public.profiles SET spouse_id = '1551f859-b707-46cb-8aa5-a900371ac15d' WHERE id = '9100c0ed-3f3e-46be-be53-ae1f33177482';
  UPDATE public.profiles SET spouse_id = '567d3303-f645-4827-87b6-1b11a92a06dc' WHERE id = 'c98b5d32-0e52-4b43-a2fd-67683be9661a';
  UPDATE public.profiles SET spouse_id = 'c98b5d32-0e52-4b43-a2fd-67683be9661a' WHERE id = '567d3303-f645-4827-87b6-1b11a92a06dc';
  UPDATE public.profiles SET spouse_id = 'a062693d-2dce-4d48-a27e-7a6d1289e2ca' WHERE id = '31e355e8-5400-4a0f-b8d6-a763e554866e';
  UPDATE public.profiles SET spouse_id = '31e355e8-5400-4a0f-b8d6-a763e554866e' WHERE id = 'a062693d-2dce-4d48-a27e-7a6d1289e2ca';
  UPDATE public.profiles SET spouse_id = '723e922e-3b06-446b-bc89-16250583966e' WHERE id = 'c679abe1-0145-4605-a60c-effaad224d73';
  UPDATE public.profiles SET spouse_id = 'c679abe1-0145-4605-a60c-effaad224d73' WHERE id = '723e922e-3b06-446b-bc89-16250583966e';
  UPDATE public.profiles SET father_id = '83dc56e9-4e30-49d8-9b05-156f3482872f', mother_id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b' WHERE id = 'c01e7102-e725-484a-a5e1-f7bcee3a00eb';
  UPDATE public.profiles SET father_id = '83dc56e9-4e30-49d8-9b05-156f3482872f', mother_id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b' WHERE id = '38b42dac-e550-4ec2-abf3-48753c42e675';
  UPDATE public.profiles SET father_id = '71b0b33f-7009-4967-a752-ee5a4acbea9f', mother_id = '53491e75-6ff8-447e-8056-4497a20c0c01' WHERE id = '1a171122-d08a-4d37-8bc3-c8ee23409f92';
  UPDATE public.profiles SET father_id = '6e2edad1-ba7f-4aff-ad40-8ea6383a88ff', mother_id = '12a25ecf-eed8-4736-9092-e199c32cdaaf' WHERE id = 'e923d185-7fb5-4d9a-a07e-5779ddb23869';
  UPDATE public.profiles SET father_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688', mother_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = '5601fca6-dcbe-4562-9802-f45a8afcce0a';
  UPDATE public.profiles SET father_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688', mother_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = '5afba49b-ad18-4478-ae3c-0c398bb5b6b2';
  UPDATE public.profiles SET father_id = NULL, mother_id = '28f0fc53-ccf1-4738-b8ca-a4fcc5a265f8' WHERE id = '27f07df4-afd7-40a5-bc8c-77a96afb0bc6';
  UPDATE public.profiles SET father_id = NULL, mother_id = '28f0fc53-ccf1-4738-b8ca-a4fcc5a265f8' WHERE id = '9546cfdc-e269-4e57-a7bc-944e5fe4bf0a';
  UPDATE public.profiles SET father_id = NULL, mother_id = '28f0fc53-ccf1-4738-b8ca-a4fcc5a265f8' WHERE id = '30e83f1a-11a3-4126-8a3a-2f7d36f0b394';
  UPDATE public.profiles SET father_id = '166f498c-48be-4ec4-abe3-8aedee69e007', mother_id = 'e535df0a-7307-40dd-8085-077cc52808c2' WHERE id = '91edc2b6-da4b-426b-949c-19bb70bf6c5e';
  UPDATE public.profiles SET father_id = '166f498c-48be-4ec4-abe3-8aedee69e007', mother_id = 'e535df0a-7307-40dd-8085-077cc52808c2' WHERE id = '2d38acf7-3731-4c05-8565-e19b91691624';
  UPDATE public.profiles SET father_id = 'd6be1ebf-2ce8-43fb-b2c8-fb6bc363b497', mother_id = 'f21319b2-9c6d-4443-8cb1-22d4af1f48a2' WHERE id = '3cc4bb4f-201d-46d3-8352-ac6f57dc96e3';
  UPDATE public.profiles SET father_id = 'd6be1ebf-2ce8-43fb-b2c8-fb6bc363b497', mother_id = 'f21319b2-9c6d-4443-8cb1-22d4af1f48a2' WHERE id = 'aac8a47e-99f8-4ad7-a0e5-332e880ed385';
  UPDATE public.profiles SET father_id = NULL, mother_id = '39f5e786-724f-48f1-bf6f-21bb789b8d9f' WHERE id = 'a4e0da27-57f6-4427-9256-2153549abcb6';
  UPDATE public.profiles SET father_id = NULL, mother_id = '39f5e786-724f-48f1-bf6f-21bb789b8d9f' WHERE id = 'bc32de95-ae0d-4e6e-8853-110b8c274e94';
  UPDATE public.profiles SET father_id = 'e0fca23e-125a-4eb7-9d12-0a4bda6a02f8', mother_id = 'dc9d344b-2497-4c57-906d-7cd5f7e619ba' WHERE id = '3559b2ac-d460-4459-bd47-aa48ec3e7bfe';
  UPDATE public.profiles SET father_id = 'e0fca23e-125a-4eb7-9d12-0a4bda6a02f8', mother_id = 'dc9d344b-2497-4c57-906d-7cd5f7e619ba' WHERE id = '1de98373-3024-4b8d-ae39-fe3d1848c283';
  UPDATE public.profiles SET father_id = 'cccaf427-9b05-4e59-a2ac-8e7a857a3dd5', mother_id = '1e49b669-6156-4323-bc26-a92aa3112fd1' WHERE id = '186f6670-23dd-4279-9b39-cc154c909bfc';
  UPDATE public.profiles SET father_id = 'cccaf427-9b05-4e59-a2ac-8e7a857a3dd5', mother_id = '1e49b669-6156-4323-bc26-a92aa3112fd1' WHERE id = '59031464-f3b9-4eaf-8b5a-5f156e8476be';
  UPDATE public.profiles SET father_id = '28eb3e84-4847-4cd4-b218-28d055c380fd', mother_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = 'f71e670f-576d-45a3-8435-9fd0ba68924f';
  UPDATE public.profiles SET father_id = '28eb3e84-4847-4cd4-b218-28d055c380fd', mother_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '0600f041-2f00-4ba5-9140-9d3752f3638b';
  UPDATE public.profiles SET father_id = '28eb3e84-4847-4cd4-b218-28d055c380fd', mother_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '5aa43d91-c800-4b01-82ae-633d9fdfadfc';
  UPDATE public.profiles SET father_id = '4079f663-01a4-4d69-98ab-1d05ce7a6fa0', mother_id = '85cbebb3-02c8-4d1b-a33e-0a10a7e89d4a' WHERE id = '6044f1d7-0e39-4598-a7f5-e88fe8b9ea06';
  UPDATE public.profiles SET father_id = '3826197e-e8b9-4d91-b065-a3212a7a5032', mother_id = '6dd3d2ef-0fa4-4f29-b34b-1f0906373ad9' WHERE id = '8545b45d-627e-4c3b-ad2c-5a6932022a51';
  UPDATE public.profiles SET father_id = '3826197e-e8b9-4d91-b065-a3212a7a5032', mother_id = '6dd3d2ef-0fa4-4f29-b34b-1f0906373ad9' WHERE id = '2ee9ab34-ceea-4f9f-9ff6-b576ea3ff1f6';
  UPDATE public.profiles SET father_id = NULL, mother_id = '91c321ad-6af7-4fc3-a9a7-e02908e8839e' WHERE id = '9de8acdf-dfff-46fb-8624-ccc908a3defe';
  UPDATE public.profiles SET father_id = 'a557f6dd-208f-4185-8264-40871dd5617f', mother_id = 'c214e140-a9e9-4f0b-b61a-e5e24caf2756' WHERE id = '7754fd1e-461b-48a0-9fc8-d84afe26325b';
  UPDATE public.profiles SET father_id = 'a557f6dd-208f-4185-8264-40871dd5617f', mother_id = 'c214e140-a9e9-4f0b-b61a-e5e24caf2756' WHERE id = '535324e0-757b-4c8b-841c-867e0bd48ea8';
  UPDATE public.profiles SET father_id = '68221963-f337-4c98-8375-194da3a2e5de', mother_id = '34c0d78b-b7ad-4b95-b1fe-ad4f4747f695' WHERE id = '6c692f69-7c4a-4af1-993c-e5f631fcf284';
  UPDATE public.profiles SET father_id = '68221963-f337-4c98-8375-194da3a2e5de', mother_id = '34c0d78b-b7ad-4b95-b1fe-ad4f4747f695' WHERE id = '9a26c680-1e45-4f1e-b574-ef5c3f6218c7';
  UPDATE public.profiles SET father_id = '68221963-f337-4c98-8375-194da3a2e5de', mother_id = '34c0d78b-b7ad-4b95-b1fe-ad4f4747f695' WHERE id = '20e49021-a76f-4fac-b804-cde96bf3eca7';
  UPDATE public.profiles SET father_id = '0cb227a2-c276-4e02-b7e7-727daef77a2b', mother_id = 'd2c6f368-1999-4a98-b996-f527af0c9410' WHERE id = '056f1efa-e1fb-4501-b14d-c715230e9279';
  UPDATE public.profiles SET father_id = '0cb227a2-c276-4e02-b7e7-727daef77a2b', mother_id = 'd2c6f368-1999-4a98-b996-f527af0c9410' WHERE id = '487f5f4f-0920-4545-8c1b-bab397f93c5c';
  UPDATE public.profiles SET father_id = '0cb227a2-c276-4e02-b7e7-727daef77a2b', mother_id = 'd2c6f368-1999-4a98-b996-f527af0c9410' WHERE id = '9a1a9404-6f72-48ea-9902-89f0a908af65';
  UPDATE public.profiles SET father_id = '2c85e7af-b645-4e9f-817f-c1c46606ce6d', mother_id = 'b6675f94-21df-4be9-85a4-e58d4c2ac727' WHERE id = 'fd01a388-f7d8-4c18-80ed-ddb6de4b524b';
  UPDATE public.profiles SET father_id = '2c85e7af-b645-4e9f-817f-c1c46606ce6d', mother_id = 'b6675f94-21df-4be9-85a4-e58d4c2ac727' WHERE id = '181e0994-afc2-4247-884c-c1546ccf24cf';
  UPDATE public.profiles SET father_id = '4bbd0433-d8b7-4c33-abd7-feba3aa9a1e3', mother_id = '836ed079-f6af-48ba-9a6f-18afc6b5bca0' WHERE id = '3b61f3ac-17d6-47af-9032-803f548aed1a';
  UPDATE public.profiles SET father_id = '4bbd0433-d8b7-4c33-abd7-feba3aa9a1e3', mother_id = '836ed079-f6af-48ba-9a6f-18afc6b5bca0' WHERE id = 'db644e72-02ee-46b5-a13d-3bae9d8409bb';
  UPDATE public.profiles SET father_id = 'e583f2a3-ea7c-4a43-aa50-b27bb0ee3d5f', mother_id = 'd25d3712-71a7-442a-8ebb-9c5943b6a0ef' WHERE id = 'b2553b39-71c6-4b33-b04c-a925df764b8c';
  UPDATE public.profiles SET father_id = 'e583f2a3-ea7c-4a43-aa50-b27bb0ee3d5f', mother_id = 'd25d3712-71a7-442a-8ebb-9c5943b6a0ef' WHERE id = '41356f18-750e-4c61-bf12-9f1b86749d3b';
  UPDATE public.profiles SET father_id = '1d54d962-4692-4800-8d96-2c009606209d', mother_id = 'ebe9459a-5008-4364-9bc0-e5ba918460a6' WHERE id = 'bc3af917-f595-4786-8b64-f9dbfdd4f55d';
  UPDATE public.profiles SET father_id = '8eb27ef8-c053-4080-96ca-ac23d469aac3', mother_id = '15228aa0-4dd6-4aff-9d62-0a91cd7e6cf8' WHERE id = '82dd45db-6b34-40fd-99c4-f5f918667c41';
  UPDATE public.profiles SET father_id = '8eb27ef8-c053-4080-96ca-ac23d469aac3', mother_id = '15228aa0-4dd6-4aff-9d62-0a91cd7e6cf8' WHERE id = '504bd805-ce05-4a2e-8d26-d98809057a3c';
  UPDATE public.profiles SET father_id = '8eb27ef8-c053-4080-96ca-ac23d469aac3', mother_id = '15228aa0-4dd6-4aff-9d62-0a91cd7e6cf8' WHERE id = 'fe099be3-8651-4f90-a06f-7c7fc108f062';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'a2c78812-e577-4855-a98b-074f8ab19ae8' WHERE id = '0b02c06b-e3a9-42d1-a0f7-73156a5fcce5';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'a2c78812-e577-4855-a98b-074f8ab19ae8' WHERE id = '6b78f535-d14f-40cc-a947-b5ca83d4770d';
  UPDATE public.profiles SET father_id = '5ce50357-665f-4140-a172-90ecc5f8c98a', mother_id = 'f1b261ea-62a7-4b09-971e-2ebb9a1f5b94' WHERE id = 'f499b6a8-3755-4066-9339-525e84fe05d2';
  UPDATE public.profiles SET father_id = '03c9d7ae-f5e1-4a04-8a04-db72a03af805', mother_id = '1ebfc994-a0a7-49fe-9e7d-e5b68694c034' WHERE id = '1beda4ed-3905-4819-9b72-ae145d40c0bb';
  UPDATE public.profiles SET father_id = '03c9d7ae-f5e1-4a04-8a04-db72a03af805', mother_id = '1ebfc994-a0a7-49fe-9e7d-e5b68694c034' WHERE id = 'ee472bcc-ad4e-4494-8e39-49caa170e82c';
  UPDATE public.profiles SET father_id = '6799c625-cab0-4dd8-af59-5aa393a0e0ef', mother_id = '8e4f91b5-aa21-404d-874c-7e56c390fc84' WHERE id = '78a66208-2834-48d1-9c80-e9bdc380ea32';
  UPDATE public.profiles SET father_id = '6799c625-cab0-4dd8-af59-5aa393a0e0ef', mother_id = '8e4f91b5-aa21-404d-874c-7e56c390fc84' WHERE id = '9101b9f3-757d-471d-8f98-f3878f87d176';
  UPDATE public.profiles SET father_id = '6799c625-cab0-4dd8-af59-5aa393a0e0ef', mother_id = '8e4f91b5-aa21-404d-874c-7e56c390fc84' WHERE id = 'b0c3948e-568f-451a-8d41-2a859e5e7794';
  UPDATE public.profiles SET father_id = '74a38e72-d95c-44fe-bf68-702933ebb38f', mother_id = 'd8480bea-4379-4eb4-9bbf-3e230a8e9c84' WHERE id = '0003c1d2-68a1-4ca2-9d3c-d8ef601c553f';
  UPDATE public.profiles SET father_id = '74a38e72-d95c-44fe-bf68-702933ebb38f', mother_id = 'd8480bea-4379-4eb4-9bbf-3e230a8e9c84' WHERE id = '75873190-af0f-4f2f-9e77-78c545d51b1e';
  UPDATE public.profiles SET father_id = '6ff738f2-72ed-4d0e-9580-2f90facfdc93', mother_id = 'cb04150e-d431-40f0-93b3-d643eb309d38' WHERE id = 'c2d613f1-2a77-44ac-9ed6-30bf4862863a';
  UPDATE public.profiles SET father_id = '22ac7613-e4ce-4366-9d84-6e1e401c9f3c', mother_id = '94cbbff0-79a6-46c8-9871-6314d0bccb0e' WHERE id = 'c8a353af-79a3-4834-89a9-640d19672370';
  UPDATE public.profiles SET father_id = '22ac7613-e4ce-4366-9d84-6e1e401c9f3c', mother_id = '94cbbff0-79a6-46c8-9871-6314d0bccb0e' WHERE id = 'edc1547a-81e0-432f-9e33-19099e5b3df3';
  UPDATE public.profiles SET father_id = '22ac7613-e4ce-4366-9d84-6e1e401c9f3c', mother_id = '94cbbff0-79a6-46c8-9871-6314d0bccb0e' WHERE id = '301635ba-608c-4562-8846-a9271c88cd22';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'f6116ebb-8d7d-4b36-b283-a18314bc4d88' WHERE id = '14ceea4e-0c3d-4f11-85e9-6aec2af7693a';
  UPDATE public.profiles SET father_id = '80d39d4c-d1bb-48f2-a63f-443fbeca8cb4', mother_id = 'bb34e22c-b89b-4e16-b11f-239304fd5ed8' WHERE id = '88cf4203-9a6c-473c-9d73-b1608ee8b431';
  UPDATE public.profiles SET father_id = '6963fca1-36f3-4935-9f86-caf837205965', mother_id = '24065499-8fd5-436e-a812-b80cc5ef5a48' WHERE id = '3f8105ba-4aee-4d28-88bb-3b05e9e8f697';
  UPDATE public.profiles SET father_id = NULL, mother_id = '550afe05-4048-4447-a5f1-e3e8180edb3f' WHERE id = '91e03460-d824-44d7-9569-402cbcff02cb';
  UPDATE public.profiles SET father_id = 'b3335703-0ab4-4e8c-a949-31fc949c853c', mother_id = '3f08a58a-49d5-455a-947b-3b34570b77ac' WHERE id = 'ae920030-ba71-42f1-a802-166c4c5a0ae1';
  UPDATE public.profiles SET father_id = 'b3335703-0ab4-4e8c-a949-31fc949c853c', mother_id = '3f08a58a-49d5-455a-947b-3b34570b77ac' WHERE id = 'bebfc601-acec-4d1a-b5d5-ef7be99b7bf8';
  UPDATE public.profiles SET father_id = 'b3335703-0ab4-4e8c-a949-31fc949c853c', mother_id = '3f08a58a-49d5-455a-947b-3b34570b77ac' WHERE id = 'dc907f36-414e-4d24-81c8-fc5e24992557';
  UPDATE public.profiles SET father_id = 'd12bb9b3-03ef-403f-8c23-d2757e5830f4', mother_id = '0c7a08b7-c694-4247-9384-78f7684a8f46' WHERE id = '8b7f0f9c-2527-4109-810d-97e74741572c';
  UPDATE public.profiles SET father_id = 'd12bb9b3-03ef-403f-8c23-d2757e5830f4', mother_id = '0c7a08b7-c694-4247-9384-78f7684a8f46' WHERE id = 'b379882e-e857-4023-b652-ace29d8abda7';
  UPDATE public.profiles SET father_id = NULL, mother_id = '7615efc4-6adc-45ee-a847-91fca1771ca7' WHERE id = 'e9be6142-d4cd-42f8-8cf0-d171e290dfe7';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'c0cff7be-9aad-4389-ac3b-783f1fdc9dfa' WHERE id = '0fe8da08-fd5b-4e1e-b10a-884e6b4d2b19';
  UPDATE public.profiles SET father_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b', mother_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = '17e08ffe-27cf-44cc-86f2-8195c417e54b';
  UPDATE public.profiles SET father_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b', mother_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = 'a9e724a7-311c-452b-adc9-78139dc49d18';
  UPDATE public.profiles SET father_id = '10f2efff-a9bf-4e93-a4a5-4ee7c73bb84a', mother_id = 'b6384c28-b589-4ea0-a152-c332fa63615c' WHERE id = 'd85c0813-d6e5-43d8-8a6a-bb8aa5d90664';
  UPDATE public.profiles SET father_id = 'f4b7faed-3a1a-4623-9ac5-9da45b30bffc', mother_id = '828d72a6-a632-4adc-b497-2dc1dfe0fee5' WHERE id = '041f8d12-1bdb-4684-9338-6a1e91f2f8db';
  UPDATE public.profiles SET father_id = '10bf51cf-8adc-4777-941d-d86fa0bf833d', mother_id = '9a46667d-67a2-457d-b555-9b637017c3c2' WHERE id = '2a6fb28f-1ee0-41c7-a29d-1502a0159c6b';
  UPDATE public.profiles SET father_id = '197f8dd1-f65f-406d-b8e6-2b4e71c4d96e', mother_id = '91af39e3-6ccc-41f7-ad63-9e5461451194' WHERE id = 'ad65b39c-6fba-4111-8353-6036446a5ef4';
  UPDATE public.profiles SET father_id = '197f8dd1-f65f-406d-b8e6-2b4e71c4d96e', mother_id = '91af39e3-6ccc-41f7-ad63-9e5461451194' WHERE id = 'd49f6858-4aca-4ddc-985b-977ae5404c6c';
  UPDATE public.profiles SET father_id = NULL, mother_id = '1a4d1815-c679-4da1-b98f-379d0d5aeb84' WHERE id = 'a5e57687-a82e-4cb2-bc0d-1bb79a223c92';
  UPDATE public.profiles SET father_id = '2c1016ff-90e6-4a07-8cc2-fd68e50729fa', mother_id = 'a9acaa74-80ee-4025-8b5c-1e97ecbd3abf' WHERE id = '92b56e73-fc84-461e-b6f9-d17ba36aa5af';
  UPDATE public.profiles SET father_id = '2c1016ff-90e6-4a07-8cc2-fd68e50729fa', mother_id = 'a9acaa74-80ee-4025-8b5c-1e97ecbd3abf' WHERE id = '70009efe-e0e1-431d-bf03-93359e97795c';
  UPDATE public.profiles SET father_id = 'd511c5d7-074b-4487-a6f6-d386c5c26caf', mother_id = '8e0d81e0-f88f-4a38-a55a-0e9ac2925683' WHERE id = '4d1d7582-bb0c-416f-8270-b6dfd2f86bdc';
  UPDATE public.profiles SET father_id = 'e9405db4-00d6-4d6e-8c41-8da72a59bf04', mother_id = 'e3f627e3-d700-409d-a83c-98640d9fbe24' WHERE id = '015ffe96-98d8-4cb9-9318-7fd649f0d3c7';
  UPDATE public.profiles SET father_id = '7de98053-6d08-4881-961c-0a1ac14cb85d', mother_id = 'fc1e957f-854b-4456-b175-0fd4bac83d83' WHERE id = 'd66e9e34-cedd-4616-940d-294eb6f7c1f3';
  UPDATE public.profiles SET father_id = 'd6ef02d0-1ca8-4d7c-b662-72147442297c', mother_id = '69d33def-9d99-4556-b54e-4080a1697c1f' WHERE id = '2e1ac026-5075-456b-a8aa-1c31be4d3b8c';
  UPDATE public.profiles SET father_id = 'd6ef02d0-1ca8-4d7c-b662-72147442297c', mother_id = '69d33def-9d99-4556-b54e-4080a1697c1f' WHERE id = '42e72cc3-34f1-4429-b827-89ff1831d430';
  UPDATE public.profiles SET father_id = 'd6ef02d0-1ca8-4d7c-b662-72147442297c', mother_id = '69d33def-9d99-4556-b54e-4080a1697c1f' WHERE id = 'b3c89d5c-0bed-4126-9fc8-1a821a488d6d';
  UPDATE public.profiles SET father_id = 'b2cdf6d2-b9e4-4368-8cbf-991b90c43fa9', mother_id = '75e5e431-2705-410f-b034-62b55d8cd199' WHERE id = '17476033-3a01-4523-9df6-29330d310d6a';
  UPDATE public.profiles SET father_id = '75e3d51d-fd8a-4322-9937-2f7539c21d50', mother_id = '7214d4a1-64b1-4eb6-a08d-79ed01912358' WHERE id = 'cfcdbd99-dd51-41be-852e-39b0fee3713d';
  UPDATE public.profiles SET father_id = '75e3d51d-fd8a-4322-9937-2f7539c21d50', mother_id = '7214d4a1-64b1-4eb6-a08d-79ed01912358' WHERE id = 'd44393cd-a50f-45aa-9439-e94986d68aaf';
  UPDATE public.profiles SET father_id = '75e3d51d-fd8a-4322-9937-2f7539c21d50', mother_id = '7214d4a1-64b1-4eb6-a08d-79ed01912358' WHERE id = '5a44b729-df5e-49c3-80fc-0d87ef7cd921';
  UPDATE public.profiles SET father_id = 'dd0b0f66-9696-44c5-acad-9b6e07e1b2ac', mother_id = '83890abf-a186-4469-85b7-c9952740a827' WHERE id = '2d9f4370-c597-4c1d-819d-82bc1f1647e5';
  UPDATE public.profiles SET father_id = 'dd0b0f66-9696-44c5-acad-9b6e07e1b2ac', mother_id = '83890abf-a186-4469-85b7-c9952740a827' WHERE id = '0f3ad4a8-535f-47af-900a-75210881e6a8';
  UPDATE public.profiles SET father_id = NULL, mother_id = '9a79839f-7f64-47d8-aa91-93367d5f9957' WHERE id = '3b732b1a-fd55-487a-bc49-b5048a651c5a';
  UPDATE public.profiles SET father_id = NULL, mother_id = '9a79839f-7f64-47d8-aa91-93367d5f9957' WHERE id = '071de0e5-8dce-4e08-81c4-4ad47dc6bf09';
  UPDATE public.profiles SET father_id = 'bd6c4119-c5a3-4cd3-adde-b3d94fbfc502', mother_id = 'e4965f7a-3288-4aee-a66f-ef67ed0947c0' WHERE id = '849c2c13-a6dd-4991-9954-8a059a074361';
  UPDATE public.profiles SET father_id = NULL, mother_id = '8656d15f-0e7f-4ffc-b6be-638f3c673d62' WHERE id = '7876dede-a7a3-490b-9516-bb03eb11318e';
  UPDATE public.profiles SET father_id = '5e9d0524-2484-4853-a857-05f69f088c36', mother_id = 'a3200045-59eb-4a10-bc4a-aed6a715e3c9' WHERE id = '46fd04b7-c28f-4ee6-85c5-8fa7c5ce1300';
  UPDATE public.profiles SET father_id = '5e9d0524-2484-4853-a857-05f69f088c36', mother_id = 'a3200045-59eb-4a10-bc4a-aed6a715e3c9' WHERE id = '88d85442-6d95-4f45-b678-0cb676554bd1';
  UPDATE public.profiles SET father_id = '23c64fd0-87f8-49ff-8757-539a8c15e608', mother_id = '9b2eed70-c556-45d4-9243-9b096d28df9a' WHERE id = '415cb0d3-f80e-4728-8dd4-2a053977e134';
  UPDATE public.profiles SET father_id = '23c64fd0-87f8-49ff-8757-539a8c15e608', mother_id = '9b2eed70-c556-45d4-9243-9b096d28df9a' WHERE id = '002b8cb3-1728-4dae-89a8-4ac05ecbb9e8';
  UPDATE public.profiles SET father_id = '19f83197-469e-468a-835a-8d57f01b988c', mother_id = 'd5935a37-98a3-4723-8e7b-f0c7e0e2b076' WHERE id = 'f71f3d28-8228-4db1-9dac-3cc86e4fc123';
  UPDATE public.profiles SET father_id = '3a5d894f-f715-4e2b-8ba6-94a502615145', mother_id = '8ad685be-5e51-406f-8d6d-c3ac79bb73b6' WHERE id = '27c7f748-8465-4476-8a56-8f4f443d42d9';
  UPDATE public.profiles SET father_id = '3a5d894f-f715-4e2b-8ba6-94a502615145', mother_id = '8ad685be-5e51-406f-8d6d-c3ac79bb73b6' WHERE id = 'd8313141-a76d-4c2e-98f2-ef6894b4fce5';
  UPDATE public.profiles SET father_id = '56983260-593f-4ab2-ae14-6a6a9c48c808', mother_id = '8c0b3db5-99d8-4b9d-855e-c585bdf396ea' WHERE id = '383a52da-3d1f-446f-8a7a-703b76da2e9e';
  UPDATE public.profiles SET father_id = '56983260-593f-4ab2-ae14-6a6a9c48c808', mother_id = '8c0b3db5-99d8-4b9d-855e-c585bdf396ea' WHERE id = '8cebbf97-ed52-43ad-a59e-f4e24b38c62d';
  UPDATE public.profiles SET father_id = NULL, mother_id = '5586cc80-0d94-4f79-a631-ea80e3206876' WHERE id = '9db2acf7-6f80-4432-80b1-8ad0b94b830f';
  UPDATE public.profiles SET father_id = NULL, mother_id = '0a723a35-3108-4af4-98ce-2191459629fa' WHERE id = '8e5d2699-f60c-4b40-94f6-450ebd7af456';
  UPDATE public.profiles SET father_id = NULL, mother_id = '815eb69e-6285-46be-937d-ebbd55324192' WHERE id = 'e02fc121-ae1e-4c4f-9460-55ec9c8df222';
  UPDATE public.profiles SET father_id = '72295479-fa8b-4458-b802-f7916e4e3562', mother_id = 'f5e0a121-576a-48b3-b918-549743bf6f81' WHERE id = 'cb12f070-7e8d-41de-a6c9-68cb1a598c49';
  UPDATE public.profiles SET father_id = '72295479-fa8b-4458-b802-f7916e4e3562', mother_id = 'f5e0a121-576a-48b3-b918-549743bf6f81' WHERE id = '2affe72a-4be0-482c-b9bf-caf6e39ddca4';
  UPDATE public.profiles SET father_id = '50ed612f-d637-4f23-a52a-a6b5703f2a04', mother_id = 'f6deff82-f7c9-4ae2-9dd6-6214cae704f6' WHERE id = 'e857a922-43c6-4ead-92d6-d7b549c80871';
  UPDATE public.profiles SET father_id = '196bb146-4697-4a27-8492-56f34c81deaa', mother_id = '8a9ae7fe-4956-40c4-9a76-062162119b71' WHERE id = 'ed2cde16-ad79-4dea-a3fb-91efbd8ca735';
  UPDATE public.profiles SET father_id = '196bb146-4697-4a27-8492-56f34c81deaa', mother_id = '8a9ae7fe-4956-40c4-9a76-062162119b71' WHERE id = 'f677af89-17ef-4102-892b-20745b7d4417';
  UPDATE public.profiles SET father_id = '05602915-b9bc-4407-87a1-5df7a82391aa', mother_id = 'b3ac3988-74dc-46e5-a597-f419a1124449' WHERE id = '5f72dc62-e3fa-4e2d-a205-02802d22b567';
  UPDATE public.profiles SET father_id = '05602915-b9bc-4407-87a1-5df7a82391aa', mother_id = 'b3ac3988-74dc-46e5-a597-f419a1124449' WHERE id = '852a035f-20c5-44cc-b36c-8d93790e0df4';
  UPDATE public.profiles SET father_id = '82f7118f-99ab-4293-8b0a-725b54a46f74', mother_id = 'd28c9860-1ffd-440a-b7b9-1e42bf37cd26' WHERE id = '6ef7a0ac-7fc2-473d-bb6a-f872dcac6e10';
  UPDATE public.profiles SET father_id = '82f7118f-99ab-4293-8b0a-725b54a46f74', mother_id = 'd28c9860-1ffd-440a-b7b9-1e42bf37cd26' WHERE id = 'f1d0bb8f-d1de-4415-8e2b-59ef5ec2a6bb';
  UPDATE public.profiles SET father_id = 'dab77623-6d4f-41b4-85ed-e2204450f329', mother_id = 'e1468496-9ccd-402b-bb2b-f041e2c73c5b' WHERE id = 'bd11bdc7-8589-47c9-889b-042f7d25378c';
  UPDATE public.profiles SET father_id = 'b0be9877-22f4-49c9-9c3d-07e84507d962', mother_id = '06168178-e907-4261-93c3-4f319f9ba1e4' WHERE id = 'f3c0db48-b03d-492b-9387-affb5ad3409c';
  UPDATE public.profiles SET father_id = 'b0be9877-22f4-49c9-9c3d-07e84507d962', mother_id = '06168178-e907-4261-93c3-4f319f9ba1e4' WHERE id = 'f45822ac-7615-42df-af21-0eb9d9835fa3';
  UPDATE public.profiles SET father_id = NULL, mother_id = '3cadce89-f928-431d-b103-651480e93df7' WHERE id = '5eafd90c-5091-420c-af72-e9d6b316eb8e';
  UPDATE public.profiles SET father_id = NULL, mother_id = '3cadce89-f928-431d-b103-651480e93df7' WHERE id = '6c8334e7-fdc5-4e2a-bd8d-430d07b170e9';
  UPDATE public.profiles SET father_id = 'd56cc064-3114-4e3f-8ab6-dec6d8567dcd', mother_id = 'cb86217a-edd6-4bfd-86d6-b9ed44adc6fd' WHERE id = '13e005ea-5a7a-44ff-b25b-eabffea600eb';
  UPDATE public.profiles SET father_id = 'd56cc064-3114-4e3f-8ab6-dec6d8567dcd', mother_id = 'cb86217a-edd6-4bfd-86d6-b9ed44adc6fd' WHERE id = '5fb2b370-783a-4d2b-adcc-96338a6cea4d';
  UPDATE public.profiles SET father_id = '29823848-0f06-4b7d-8365-851464236c4e', mother_id = 'e8940714-eefb-4a99-9148-4af1246828e6' WHERE id = '0a342172-121f-462e-b1e3-cd5a59606134';
  UPDATE public.profiles SET father_id = '29823848-0f06-4b7d-8365-851464236c4e', mother_id = 'e8940714-eefb-4a99-9148-4af1246828e6' WHERE id = '2ef77398-5156-44bc-9251-cf7e622f18f2';
  UPDATE public.profiles SET father_id = '29823848-0f06-4b7d-8365-851464236c4e', mother_id = 'e8940714-eefb-4a99-9148-4af1246828e6' WHERE id = '3298c8bc-aced-4a2d-8ad3-0252390ed07c';
  UPDATE public.profiles SET father_id = '209bbac1-0ad0-4395-9f19-2499d1f1f9b6', mother_id = '1764b00f-ecc1-4dd4-ac6c-02e1c9612954' WHERE id = '89e10859-ccb5-4268-a4a8-4d75572ee5f4';
  UPDATE public.profiles SET father_id = '209bbac1-0ad0-4395-9f19-2499d1f1f9b6', mother_id = '1764b00f-ecc1-4dd4-ac6c-02e1c9612954' WHERE id = '713859a5-c221-4e7b-8c1a-be3ce54cf05c';
  UPDATE public.profiles SET father_id = '986c0cbd-679d-434b-9f40-68c7215b3b09', mother_id = 'ccb5e96f-c7cc-4e6a-8740-e21b4275e834' WHERE id = 'cf19cd87-4e62-49ec-9245-5eec86261a9f';
  UPDATE public.profiles SET father_id = 'fc07de25-0887-4881-8a50-ec57cf905526', mother_id = 'c8ad0a37-fb0c-4bbd-a4b4-b7148b521857' WHERE id = 'aacc797c-07ed-41a2-80b4-b399dab01669';
  UPDATE public.profiles SET father_id = 'fc07de25-0887-4881-8a50-ec57cf905526', mother_id = 'c8ad0a37-fb0c-4bbd-a4b4-b7148b521857' WHERE id = 'b1ad3eb2-2f82-4d24-8f8c-93d3062d4c66';
  UPDATE public.profiles SET father_id = 'fc07de25-0887-4881-8a50-ec57cf905526', mother_id = 'c8ad0a37-fb0c-4bbd-a4b4-b7148b521857' WHERE id = '32f4903d-4adf-45c5-ad81-eb9b4c508bb4';
  UPDATE public.profiles SET father_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e', mother_id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb' WHERE id = '919b9528-4b5c-45ce-8e04-c5cb9e436ab4';
  UPDATE public.profiles SET father_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e', mother_id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb' WHERE id = 'a4b72b41-e1e7-45a7-b096-2be0a0672cf2';
  UPDATE public.profiles SET father_id = '92384d35-0f90-41a7-a3e9-4a017e60ec21', mother_id = '1c71a46b-a3cc-4315-9310-803336d71755' WHERE id = 'cafba1f1-91dd-4cb4-ba83-bac45415c682';
  UPDATE public.profiles SET father_id = '92384d35-0f90-41a7-a3e9-4a017e60ec21', mother_id = '1c71a46b-a3cc-4315-9310-803336d71755' WHERE id = 'fdbedb0d-25c3-4071-b71e-d714c3441368';
  UPDATE public.profiles SET father_id = 'cad4ccf2-0057-46fd-85c8-622acdcdec29', mother_id = 'b3374bbc-8174-4ec2-9e51-5fc9868f7e8c' WHERE id = 'aaf4a3d2-9c17-4842-9330-62a305b5a159';
  UPDATE public.profiles SET father_id = 'cad4ccf2-0057-46fd-85c8-622acdcdec29', mother_id = 'b3374bbc-8174-4ec2-9e51-5fc9868f7e8c' WHERE id = 'd57ca679-97fd-4a1f-af76-a6b3d86941d2';
  UPDATE public.profiles SET father_id = 'cad4ccf2-0057-46fd-85c8-622acdcdec29', mother_id = 'b3374bbc-8174-4ec2-9e51-5fc9868f7e8c' WHERE id = '43ee0556-0a9c-4493-b5af-13bac2b34d8b';
  UPDATE public.profiles SET father_id = 'cad4ccf2-0057-46fd-85c8-622acdcdec29', mother_id = 'b3374bbc-8174-4ec2-9e51-5fc9868f7e8c' WHERE id = '19635e5e-90d2-4a29-96cd-6a3a725f4265';
  UPDATE public.profiles SET father_id = NULL, mother_id = '9fd7d309-8949-4e25-9768-c6cdf988d47b' WHERE id = '4ca6af83-b485-4122-8d95-e4457794ef46';
  UPDATE public.profiles SET father_id = NULL, mother_id = '16568471-4fad-45e8-a4dc-e9f94f1baf89' WHERE id = 'e24d0f98-4465-425c-9923-bc5ac46fa78c';
  UPDATE public.profiles SET father_id = '84ff3467-1f52-4a31-9659-9389713282bb', mother_id = 'eddac668-a914-42cd-87f7-e78070c77ed1' WHERE id = '52a0eff5-287b-459d-af1f-d1f5708c5b4a';
  UPDATE public.profiles SET father_id = 'b06a9fe5-8dec-446b-bcbd-9dfd06ce8580', mother_id = 'bbc047e5-a6e4-4dd0-afbb-12bac35fe144' WHERE id = '8d624dd2-6164-455d-a660-da314c3b1cba';
  UPDATE public.profiles SET father_id = 'b06a9fe5-8dec-446b-bcbd-9dfd06ce8580', mother_id = 'bbc047e5-a6e4-4dd0-afbb-12bac35fe144' WHERE id = '6d75ce23-c23c-4a0a-8ff7-bed2ae806216';
  UPDATE public.profiles SET father_id = 'aa0281c5-73ae-4e2d-84d2-e36b0512f9cc', mother_id = 'ca85675f-2fa5-485a-a625-8b81be8d1a64' WHERE id = 'd7852101-2ae5-4b5f-a169-89a021888df7';
  UPDATE public.profiles SET father_id = '4d31e76e-bc8c-42a2-a5ab-167b6f49256c', mother_id = '4ae7043d-44f1-4068-ab91-f3d0eeab7ba8' WHERE id = 'b3ecfd33-2aa2-479c-bea5-1a92f73bbb97';
  UPDATE public.profiles SET father_id = '4d31e76e-bc8c-42a2-a5ab-167b6f49256c', mother_id = '4ae7043d-44f1-4068-ab91-f3d0eeab7ba8' WHERE id = 'dab43ae5-3ecb-4ebc-9ec2-0510b6c5b524';
  UPDATE public.profiles SET father_id = '4d31e76e-bc8c-42a2-a5ab-167b6f49256c', mother_id = '4ae7043d-44f1-4068-ab91-f3d0eeab7ba8' WHERE id = 'c9b5a281-d4b0-4c66-a330-c39c06f533a9';
  UPDATE public.profiles SET father_id = 'c727f032-2743-4d6b-858e-de980d0581bf', mother_id = '11d00d6f-7a11-4476-81e8-4da73e434acf' WHERE id = '9e7e4221-2193-42d6-9b79-486b1fd5f136';
  UPDATE public.profiles SET father_id = 'c727f032-2743-4d6b-858e-de980d0581bf', mother_id = '11d00d6f-7a11-4476-81e8-4da73e434acf' WHERE id = '479cf1f8-ed3b-464e-89fc-1c015a4853b1';
  UPDATE public.profiles SET father_id = '14cf1d8e-c4ab-4bdd-859c-4e1e5d9db1a3', mother_id = '4db8aecd-7926-4340-ae04-a27a3d2e81cd' WHERE id = 'e01c671f-905b-4b16-b664-938ac4b186c0';
  UPDATE public.profiles SET father_id = '14cf1d8e-c4ab-4bdd-859c-4e1e5d9db1a3', mother_id = '4db8aecd-7926-4340-ae04-a27a3d2e81cd' WHERE id = '026c76d2-4ab9-448a-bf21-e3a7324a7010';
  UPDATE public.profiles SET father_id = '8fdded88-2474-405a-bb8c-78fde9c8a660', mother_id = '3029f46b-81aa-412b-b2db-175c1ddc07cf' WHERE id = '89e95742-306f-4ee5-b17f-20bdc11eeb5c';
  UPDATE public.profiles SET father_id = '8fdded88-2474-405a-bb8c-78fde9c8a660', mother_id = '3029f46b-81aa-412b-b2db-175c1ddc07cf' WHERE id = 'ab2bbfa6-37f8-4d52-a536-fe18f79383de';
  UPDATE public.profiles SET father_id = 'bd0fa006-8518-4e5c-a361-9eeb7b88e410', mother_id = '2f1f2b60-13e5-4b0c-a410-774d8872fd77' WHERE id = 'c64899d3-f418-4136-b359-2e99dec424c2';
  UPDATE public.profiles SET father_id = NULL, mother_id = '49aeac36-ae38-494b-970e-605dd14fdc2c' WHERE id = '1c1a2281-7a41-4a41-b3a2-744c729d2983';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'f494fe47-b70c-4c5b-8074-80d785be7c27' WHERE id = 'b1eb47a8-0264-44f8-8f9b-29e1022862a1';
  UPDATE public.profiles SET father_id = 'a725ad4d-588e-467f-9462-82a60e8ba2a6', mother_id = '9508d2d2-350e-4a52-8cb1-4a94ae88d626' WHERE id = '3b3f8236-cd73-445c-abac-38ac0d5ce453';
  UPDATE public.profiles SET father_id = '72d08f64-1e96-4885-bb4d-9258a795a474', mother_id = '5b055d16-a494-432e-91d9-718bd9d025f7' WHERE id = '8aa9fde5-377d-43bc-b105-a23e38a4897f';
  UPDATE public.profiles SET father_id = '63cdc71a-7c76-4699-8669-24dd376f5af3', mother_id = 'bcf09900-bfd7-4218-bc09-1238e3c22160' WHERE id = '48ca17f1-59cf-493c-9f99-c31b92864274';
  UPDATE public.profiles SET father_id = '63cdc71a-7c76-4699-8669-24dd376f5af3', mother_id = 'bcf09900-bfd7-4218-bc09-1238e3c22160' WHERE id = '2022f6ea-319c-48d1-99a9-d0381f288eb3';
  UPDATE public.profiles SET father_id = 'fcca9a58-8884-4045-a801-0141179e7d2e', mother_id = '55a28087-f3c1-4bcd-b095-c5bee6988be1' WHERE id = 'aa7c45af-62be-409b-963d-0e5e0d068891';
  UPDATE public.profiles SET father_id = 'fcca9a58-8884-4045-a801-0141179e7d2e', mother_id = '55a28087-f3c1-4bcd-b095-c5bee6988be1' WHERE id = '126f60eb-f2dc-4e43-bdf9-bd67a5ae9977';
  UPDATE public.profiles SET father_id = 'f47eb221-9849-446f-9299-2c2a96c3b72b', mother_id = '967897ce-e167-4250-857e-302a934c4cd3' WHERE id = 'e0f05d60-716f-4212-9209-4a2be5ba4688';
  UPDATE public.profiles SET father_id = 'c8a4ba56-d20d-4f47-b497-07de3bffc815', mother_id = '046a62cd-d1a0-454e-a1b9-b774fb4517ea' WHERE id = '2669c17f-90d7-4f94-8fb6-1ed8859115f9';
  UPDATE public.profiles SET father_id = 'faaed601-4196-4df0-8438-21bd489e5abc', mother_id = '95f71fa0-6237-4c0b-80fc-d99e2ce0f84d' WHERE id = 'db7b0e50-7e01-43f7-ac9f-3f3fc518ee22';
  UPDATE public.profiles SET father_id = 'faaed601-4196-4df0-8438-21bd489e5abc', mother_id = '95f71fa0-6237-4c0b-80fc-d99e2ce0f84d' WHERE id = 'd554c7ab-6f43-4af6-be97-bb017cd921ed';
  UPDATE public.profiles SET father_id = 'faaed601-4196-4df0-8438-21bd489e5abc', mother_id = '95f71fa0-6237-4c0b-80fc-d99e2ce0f84d' WHERE id = '1b832109-2898-4e9f-9fdc-f0fc688c8901';
  UPDATE public.profiles SET father_id = '83f933b7-2b28-4ed7-9143-719e1f10b709', mother_id = '50037ebc-403d-45f6-aa98-170dd6ca1f30' WHERE id = '38588ef0-4730-4080-a9f5-2a6bb893cf6f';
  UPDATE public.profiles SET father_id = '83f933b7-2b28-4ed7-9143-719e1f10b709', mother_id = '50037ebc-403d-45f6-aa98-170dd6ca1f30' WHERE id = 'e62549aa-cdac-4b01-8001-bd76d69a8850';
  UPDATE public.profiles SET father_id = '9d22fa36-1329-450e-b8d6-caac02c44d66', mother_id = 'ad1c7be3-0954-46da-8525-2ab725a3e949' WHERE id = 'b7227538-6294-486d-83d7-f3eb8a43cb5d';
  UPDATE public.profiles SET father_id = '9d22fa36-1329-450e-b8d6-caac02c44d66', mother_id = 'ad1c7be3-0954-46da-8525-2ab725a3e949' WHERE id = '0d2b5371-4ac1-4c6a-9fb3-2844eec18229';
  UPDATE public.profiles SET father_id = '9d22fa36-1329-450e-b8d6-caac02c44d66', mother_id = 'ad1c7be3-0954-46da-8525-2ab725a3e949' WHERE id = '222722eb-4c77-4949-bf6a-6344473c6d36';
  UPDATE public.profiles SET father_id = 'd81b32d8-3361-4785-8f84-47842b070fa7', mother_id = '20299992-40a3-464b-af2f-6445fdf3b48c' WHERE id = 'fe7e5d23-e677-4219-b369-556310c5424b';
  UPDATE public.profiles SET father_id = 'bb3b59e5-de49-4908-84a2-82ad4c716d15', mother_id = '12f1d11a-a53c-4109-a055-82be54fde14f' WHERE id = '2b66b607-79a7-4fda-aba4-c9d74a61a1c5';
  UPDATE public.profiles SET father_id = 'bb3b59e5-de49-4908-84a2-82ad4c716d15', mother_id = '12f1d11a-a53c-4109-a055-82be54fde14f' WHERE id = '88350d37-0ca9-412b-b652-bccc89bc1f8e';
  UPDATE public.profiles SET father_id = 'bb3b59e5-de49-4908-84a2-82ad4c716d15', mother_id = '12f1d11a-a53c-4109-a055-82be54fde14f' WHERE id = 'd1b8b8c5-dac7-461a-b642-5cfea4baa8d0';
  UPDATE public.profiles SET father_id = '85f0ba08-787f-44cf-8fb8-f3ee76362b15', mother_id = 'c49f8547-ffe9-4fba-89f0-4856e09f7324' WHERE id = 'b792ef24-3d87-4abf-9ba8-00d1220a8e03';
  UPDATE public.profiles SET father_id = '85f0ba08-787f-44cf-8fb8-f3ee76362b15', mother_id = 'c49f8547-ffe9-4fba-89f0-4856e09f7324' WHERE id = 'cc38eb16-e297-4472-ae82-b16f9a07370f';
  UPDATE public.profiles SET father_id = '218d21b4-19df-42fa-868a-1c028a20626f', mother_id = '34a64dbc-42d1-4df7-bece-25fd54cbe584' WHERE id = 'cfcb5b30-e5b3-444a-bd96-89516122a62f';
  UPDATE public.profiles SET father_id = '218d21b4-19df-42fa-868a-1c028a20626f', mother_id = '34a64dbc-42d1-4df7-bece-25fd54cbe584' WHERE id = '7b9606db-afa8-4e1b-a3d8-ebb78e63f7a0';
  UPDATE public.profiles SET father_id = '0ec1ff8c-f44c-477e-861e-daa350347e36', mother_id = '357bb926-8ea8-41bb-86e0-32c6b37e417e' WHERE id = '3434b744-218d-4dfd-b96d-c1c800c6f684';
  UPDATE public.profiles SET father_id = '0ec1ff8c-f44c-477e-861e-daa350347e36', mother_id = '357bb926-8ea8-41bb-86e0-32c6b37e417e' WHERE id = '17be3ee9-0636-4f9e-b35c-6f48c9c03d34';
  UPDATE public.profiles SET father_id = '0ec1ff8c-f44c-477e-861e-daa350347e36', mother_id = '357bb926-8ea8-41bb-86e0-32c6b37e417e' WHERE id = '00c89878-42db-42ab-a41a-ebf5fbc2aa48';
  UPDATE public.profiles SET father_id = '5bc128dc-441c-4717-8a70-50c3400f47f8', mother_id = 'd6098285-5234-4f63-ae72-2f81b0f47809' WHERE id = '4dc5a2c4-6e72-47ef-afa2-fa935bc30f18';
  UPDATE public.profiles SET father_id = '1d64e2be-8aac-4540-95cd-92d5cbde61b2', mother_id = '24c74460-e6dd-49ab-9921-721fd4ef6055' WHERE id = 'ce6e9e57-a44d-4785-a6f1-25378aa4914d';
  UPDATE public.profiles SET father_id = '5750fd70-f815-4499-88ea-b73bf5d98572', mother_id = '8d14b1e3-3c0f-4739-b404-46d72d21cc74' WHERE id = '78a2cebe-8198-43c5-9767-9125f30ee177';
  UPDATE public.profiles SET father_id = '5750fd70-f815-4499-88ea-b73bf5d98572', mother_id = '8d14b1e3-3c0f-4739-b404-46d72d21cc74' WHERE id = '7b836364-de02-482b-a8cf-21b404a4f19b';
  UPDATE public.profiles SET father_id = '1b171281-cd18-4fb3-b853-76ea6529d92e', mother_id = 'fafb068b-ac68-4ae7-bcbb-f2ff2374af83' WHERE id = '0cc0802b-dd49-4277-98ce-b4e744133777';
  UPDATE public.profiles SET father_id = '1b171281-cd18-4fb3-b853-76ea6529d92e', mother_id = 'fafb068b-ac68-4ae7-bcbb-f2ff2374af83' WHERE id = '81623c57-421d-4150-909b-d6f23846db06';
  UPDATE public.profiles SET father_id = 'e1af9709-5187-4e93-869a-72253199e61c', mother_id = '7d922828-7f20-4eb2-83f2-6da6b04c6a0c' WHERE id = '059aae89-de5f-4eb6-aeba-5536ebafbe25';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'c33fa385-9f2b-472b-87af-64dcc572a393' WHERE id = 'd94eee52-0dd6-4850-8f8b-cd18a46748bf';
  UPDATE public.profiles SET father_id = 'b21fb951-c70c-489b-bb83-126b869ad4da', mother_id = '2d4f11b7-3864-48ca-8dfb-acac13e3e633' WHERE id = 'df38623d-f6cb-4386-84b0-e94e4934b9e8';
  UPDATE public.profiles SET father_id = 'e795724e-2230-44b6-a330-3c1757eb511e', mother_id = '59dc55a4-6480-4083-882f-a9fde99f42f2' WHERE id = 'cb3cb6e9-02e1-4173-a634-19984ed36dce';
  UPDATE public.profiles SET father_id = 'e795724e-2230-44b6-a330-3c1757eb511e', mother_id = '59dc55a4-6480-4083-882f-a9fde99f42f2' WHERE id = '7a23270b-82ab-4acc-895d-77c6416d1375';
  UPDATE public.profiles SET father_id = 'e795724e-2230-44b6-a330-3c1757eb511e', mother_id = '59dc55a4-6480-4083-882f-a9fde99f42f2' WHERE id = '862097d4-cd3a-4a69-8228-73e8688d390b';
  UPDATE public.profiles SET father_id = '0f7e7416-c29b-4d6c-9d1c-3b66c716d5d2', mother_id = '49f67b24-3323-401d-91c1-23153a80de7c' WHERE id = 'b477239f-3a53-4839-97fb-02fac90be635';
  UPDATE public.profiles SET father_id = '9e8c8eb7-b83b-4fed-aaf9-df5a5c3c0a72', mother_id = '91745890-20f0-4a7b-8403-f6a9d8e1974a' WHERE id = '167102df-b678-432e-9cda-ed71346b1d51';
  UPDATE public.profiles SET father_id = '9e8c8eb7-b83b-4fed-aaf9-df5a5c3c0a72', mother_id = '91745890-20f0-4a7b-8403-f6a9d8e1974a' WHERE id = '32dd7a78-98cc-4d88-9e92-ba2cdda172bb';
  UPDATE public.profiles SET father_id = NULL, mother_id = '71358ba6-75ad-4b0e-bd17-dbb779210b2e' WHERE id = '590efd63-54d2-4425-82bb-2ff3baffeaaf';
  UPDATE public.profiles SET father_id = NULL, mother_id = '71358ba6-75ad-4b0e-bd17-dbb779210b2e' WHERE id = '0246aa3e-2d7c-49bf-9791-ebdd27c66342';
  UPDATE public.profiles SET father_id = '6f3da312-2192-4fb8-8919-c4a16c67915a', mother_id = '197e0ace-9c04-4d98-9a58-514b92e32b35' WHERE id = '854ec463-3917-4885-9a29-163e001b9d57';
  UPDATE public.profiles SET father_id = '6f3da312-2192-4fb8-8919-c4a16c67915a', mother_id = '197e0ace-9c04-4d98-9a58-514b92e32b35' WHERE id = '4758ad71-4434-4679-8fb2-bcf7d9dc5fa4';
  UPDATE public.profiles SET father_id = '6f3da312-2192-4fb8-8919-c4a16c67915a', mother_id = '197e0ace-9c04-4d98-9a58-514b92e32b35' WHERE id = 'b4e019ee-bae4-4caf-a67b-8399f92b1567';
  UPDATE public.profiles SET father_id = '6f3da312-2192-4fb8-8919-c4a16c67915a', mother_id = '197e0ace-9c04-4d98-9a58-514b92e32b35' WHERE id = '53985419-10c0-418e-890e-109ecdcd0ffc';
  UPDATE public.profiles SET father_id = '6f3da312-2192-4fb8-8919-c4a16c67915a', mother_id = '197e0ace-9c04-4d98-9a58-514b92e32b35' WHERE id = '255e80d3-a528-46d1-bb23-82e2842738f2';
  UPDATE public.profiles SET father_id = '6f3da312-2192-4fb8-8919-c4a16c67915a', mother_id = '197e0ace-9c04-4d98-9a58-514b92e32b35' WHERE id = '5ecb61d1-13b5-4f22-bbd1-4cfe44ac0dc5';
  UPDATE public.profiles SET father_id = '94331f45-93dc-4c93-a2fb-243aa9ef0060', mother_id = '5aef5ec9-d89e-4a90-93fa-2b7b835c82db' WHERE id = '6686e97b-d16a-4c71-a00a-618e05b424bd';
  UPDATE public.profiles SET father_id = '94331f45-93dc-4c93-a2fb-243aa9ef0060', mother_id = '5aef5ec9-d89e-4a90-93fa-2b7b835c82db' WHERE id = 'aec174e2-140e-4a46-9fca-a86ca23f9499';
  UPDATE public.profiles SET father_id = '94331f45-93dc-4c93-a2fb-243aa9ef0060', mother_id = '5aef5ec9-d89e-4a90-93fa-2b7b835c82db' WHERE id = 'a1a11475-fa9a-4522-8cf7-1fc4bad34c5c';
  UPDATE public.profiles SET father_id = 'f76a602c-8be1-4ab6-b41b-26d71404da4a', mother_id = '50122db6-6e32-4e4a-b670-51311e2c483d' WHERE id = '9771bb72-80bb-4f16-a98e-9ae441c5b4e3';
  UPDATE public.profiles SET father_id = '5ace990f-ceae-473d-b68c-a4d276ced940', mother_id = '5f304ecd-5612-4bc8-b4c5-6305afdf424f' WHERE id = 'a9a8cfea-3a01-4fbc-a6ad-c513a5239e17';
  UPDATE public.profiles SET father_id = '5ace990f-ceae-473d-b68c-a4d276ced940', mother_id = '5f304ecd-5612-4bc8-b4c5-6305afdf424f' WHERE id = '8b119e6d-0ec7-4a9b-b954-631dcc26edc4';
  UPDATE public.profiles SET father_id = '5ace990f-ceae-473d-b68c-a4d276ced940', mother_id = '5f304ecd-5612-4bc8-b4c5-6305afdf424f' WHERE id = 'f656c101-a004-4edf-848b-a2aaca940767';
  UPDATE public.profiles SET father_id = '3456c288-6616-449b-ad4f-7a6fa4c2b64e', mother_id = '6e5bb176-7465-4a41-a54b-5744ddf342ef' WHERE id = '45082e17-ac1f-43a8-ac08-9072b5b294fe';
  UPDATE public.profiles SET father_id = 'e61f63a4-c117-4fcb-a3b9-0a3180610995', mother_id = 'd60538f9-f4e2-445d-a05a-48440392b15b' WHERE id = 'f53b3f3a-a1be-4613-96f2-6e9d113b6528';
  UPDATE public.profiles SET father_id = 'e61f63a4-c117-4fcb-a3b9-0a3180610995', mother_id = 'd60538f9-f4e2-445d-a05a-48440392b15b' WHERE id = 'ba5f269e-9a1b-4fbf-ad40-6b5d6d9c4a9a';
  UPDATE public.profiles SET father_id = '2432be66-38cf-4425-bd0d-19f773bdb458', mother_id = 'eb58b79f-4fe6-4449-9c7f-c3984f2024c5' WHERE id = 'd9aba70a-8782-4fe0-9d76-e4710b6b4a8b';
  UPDATE public.profiles SET father_id = '2432be66-38cf-4425-bd0d-19f773bdb458', mother_id = 'eb58b79f-4fe6-4449-9c7f-c3984f2024c5' WHERE id = '09c1ae8a-71dd-46d5-a70b-7446b14ef966';
  UPDATE public.profiles SET father_id = '2432be66-38cf-4425-bd0d-19f773bdb458', mother_id = 'eb58b79f-4fe6-4449-9c7f-c3984f2024c5' WHERE id = '100a8da8-e765-42df-bc9e-5c6fff953430';
  UPDATE public.profiles SET father_id = '9df93b7a-f166-4e1a-8ac8-cfc9d43cf8e7', mother_id = '32ba3595-2b00-4919-9df1-fee06f8f84fe' WHERE id = '881f9d55-2ab5-4c49-a453-11bf6faf387f';
  UPDATE public.profiles SET father_id = '9df93b7a-f166-4e1a-8ac8-cfc9d43cf8e7', mother_id = '32ba3595-2b00-4919-9df1-fee06f8f84fe' WHERE id = '9aa684d2-359c-49be-b342-3440ec4a2ebb';
  UPDATE public.profiles SET father_id = 'a372098d-62fa-4a2d-add7-2cd5038ad667', mother_id = '2467d6c7-d1f6-4fb9-8fae-eb8f9ce6fe74' WHERE id = '4a6769fe-6bd9-445e-b5ea-0a2575cc5bb8';
  UPDATE public.profiles SET father_id = 'a372098d-62fa-4a2d-add7-2cd5038ad667', mother_id = '2467d6c7-d1f6-4fb9-8fae-eb8f9ce6fe74' WHERE id = '31d007a8-7f62-46bd-9af3-e47fa69fa0a2';
  UPDATE public.profiles SET father_id = '9864ebf7-d26e-48b2-b0e1-9e88f02ab7ae', mother_id = 'a9ad90de-d5e4-49ee-b8b5-e7e5ea480953' WHERE id = 'bef22e7b-5a1e-4974-a617-d95d3f5b85ab';
  UPDATE public.profiles SET father_id = '38e1116f-4ed8-45e1-9a55-c1948b4e6575', mother_id = '31313de6-b5cc-45b7-87d0-8bc03e7fa5cd' WHERE id = '92adf99c-10e7-4e7e-aea2-abbfc515c2d8';
  UPDATE public.profiles SET father_id = '38e1116f-4ed8-45e1-9a55-c1948b4e6575', mother_id = '31313de6-b5cc-45b7-87d0-8bc03e7fa5cd' WHERE id = '23b7aaee-933f-4caa-8c31-eff0f4146ebd';
  UPDATE public.profiles SET father_id = NULL, mother_id = '2c813d31-2ae8-4c95-a2b5-deb92f5b6172' WHERE id = 'c1c5dd14-e38b-4b44-b7c5-ed459023e287';
  UPDATE public.profiles SET father_id = NULL, mother_id = '2c813d31-2ae8-4c95-a2b5-deb92f5b6172' WHERE id = 'ccfd2f57-8f0b-4d22-80e7-05cec082d643';
  UPDATE public.profiles SET father_id = '7d7ccec7-3b36-4b39-9c6d-ba38c6fa2efb', mother_id = '2fc663f3-a8d5-4e1b-a2dc-98520dda38b2' WHERE id = '5e1deedc-c0b6-4dbc-97f1-6027d430cc2d';
  UPDATE public.profiles SET father_id = '85dfa227-5e5f-43d2-ae5e-937147f285ba', mother_id = 'ca0d3bd6-62f5-42da-ab0b-2321de784d95' WHERE id = '0f741273-33f1-405d-8b42-8fe638b1b90b';
  UPDATE public.profiles SET father_id = '85dfa227-5e5f-43d2-ae5e-937147f285ba', mother_id = 'ca0d3bd6-62f5-42da-ab0b-2321de784d95' WHERE id = '85063129-d8b8-4db8-b675-acd6f168f6ca';
  UPDATE public.profiles SET father_id = '5b2a9424-af91-4967-9a18-3d682d04005a', mother_id = 'b26c7ec3-d2d9-411e-9638-0db835db733a' WHERE id = '14df8d6f-9cdb-41cf-bdf6-e9231caa3ea3';
  UPDATE public.profiles SET father_id = 'f53f0316-2854-4ca7-b501-7ca0d5ec5d3d', mother_id = '6415fe87-33e5-48cc-844d-f5ed9eae8be7' WHERE id = '480df268-bceb-4977-b97b-ab65ee539ac3';
  UPDATE public.profiles SET father_id = 'f53f0316-2854-4ca7-b501-7ca0d5ec5d3d', mother_id = '6415fe87-33e5-48cc-844d-f5ed9eae8be7' WHERE id = '90f1f945-7281-41ef-afa4-a6c26b764a42';
  UPDATE public.profiles SET father_id = 'f53f0316-2854-4ca7-b501-7ca0d5ec5d3d', mother_id = '6415fe87-33e5-48cc-844d-f5ed9eae8be7' WHERE id = 'a2efdc40-905a-4f4a-90d8-c8c09d60c721';
  UPDATE public.profiles SET father_id = '3df444aa-89f4-4308-a01b-38622242a741', mother_id = 'c369a90d-4316-4d4e-a31a-6c13bfb9c996' WHERE id = 'cad50075-b15c-481c-a9bd-52d704d6ce6a';
  UPDATE public.profiles SET father_id = 'ba110cff-557b-45db-a196-c6e8fc8e71a4', mother_id = '6234ade4-b8bb-4611-b3f9-463fb0b4caba' WHERE id = '567e63e7-2eab-436c-9751-f467ee816e7f';
  UPDATE public.profiles SET father_id = 'ba110cff-557b-45db-a196-c6e8fc8e71a4', mother_id = '6234ade4-b8bb-4611-b3f9-463fb0b4caba' WHERE id = '4a02be01-cd2d-41b3-8ffc-2399b029abdc';
  UPDATE public.profiles SET father_id = 'a9d51b21-df82-4c56-9186-7151224e65a5', mother_id = 'e2487d28-89eb-4394-857c-6f30a8688675' WHERE id = '72ac0584-82a9-43ff-8487-9eabd29e3ba8';
  UPDATE public.profiles SET father_id = 'a9d51b21-df82-4c56-9186-7151224e65a5', mother_id = 'e2487d28-89eb-4394-857c-6f30a8688675' WHERE id = 'c97a861d-fc2f-4c8f-9cee-bc2a9a7c650b';
  UPDATE public.profiles SET father_id = '0d0cf63e-7521-443c-95bc-f85fc98546e9', mother_id = '509e34f6-b484-417c-8223-8408409ce779' WHERE id = '8da8e787-202b-4db9-85a2-f8c8e911438b';
  UPDATE public.profiles SET father_id = '2802e112-f41d-4d6c-ac84-793ba506e93e', mother_id = '65dead1d-7158-4122-8d2f-90b636cd173c' WHERE id = 'd19d4394-530c-4bf3-b21c-e23293330c5b';
  UPDATE public.profiles SET father_id = '2802e112-f41d-4d6c-ac84-793ba506e93e', mother_id = '65dead1d-7158-4122-8d2f-90b636cd173c' WHERE id = '29a0a71d-d74e-4b0a-95f7-28430ad6142f';
  UPDATE public.profiles SET father_id = '2ee08aed-3fd5-4f3e-8cdc-5b1d4782c23d', mother_id = '13208420-1f67-46e3-bd1a-0e8e9722dfc8' WHERE id = '8e319ea2-f701-4aa9-84db-52dfed631174';
  UPDATE public.profiles SET father_id = 'ed986db6-452c-4ef3-9340-474b7aca1df9', mother_id = '1bca7d3e-f87d-4ce3-975d-d5896046064a' WHERE id = 'e4a258f5-3993-4379-ac40-c31d1e35c9f4';
  UPDATE public.profiles SET father_id = 'cb8da091-9837-40b9-a842-3105fe329545', mother_id = NULL WHERE id = '91d8e9b7-fb84-43dc-9f3a-af83946e5076';
  UPDATE public.profiles SET father_id = 'cb8da091-9837-40b9-a842-3105fe329545', mother_id = NULL WHERE id = 'ac2c7cfc-af22-470d-9f45-bc1ce4ce9560';
  UPDATE public.profiles SET father_id = '192eefab-7304-454a-a5fa-288e6e267258', mother_id = '1e664157-86cd-4f8c-a896-0a05bd145073' WHERE id = '0a3b75da-8d06-435e-afdc-4dbdc1e38792';
  UPDATE public.profiles SET father_id = '192eefab-7304-454a-a5fa-288e6e267258', mother_id = '1e664157-86cd-4f8c-a896-0a05bd145073' WHERE id = '4d4d031e-91fd-4692-8bcf-753d0a2adf9d';
  UPDATE public.profiles SET father_id = '192eefab-7304-454a-a5fa-288e6e267258', mother_id = '1e664157-86cd-4f8c-a896-0a05bd145073' WHERE id = '49d5c83b-53f5-4118-9ca7-5c9d7420865d';
  UPDATE public.profiles SET father_id = 'fa38cfc7-728e-4c52-a6bb-c633d2b834fc', mother_id = 'fdc5e5c9-2e6c-4b71-936a-bf6e1f1be73b' WHERE id = 'fffb128b-f767-4ded-8b10-91d292ce18b6';
  UPDATE public.profiles SET father_id = 'a1ea11cf-40b5-4960-8359-fc60217a11bd', mother_id = '9553e140-a3d3-4602-8dec-deb41f4a3db9' WHERE id = 'cce7a9e4-25c8-4ff6-81a8-ed442f5cf5c9';
  UPDATE public.profiles SET father_id = 'a1ea11cf-40b5-4960-8359-fc60217a11bd', mother_id = '9553e140-a3d3-4602-8dec-deb41f4a3db9' WHERE id = 'fe41d5e2-d125-416e-a9b7-cbd9f6228751';
  UPDATE public.profiles SET father_id = '7edd7fe4-0dac-457f-933d-b1f57afffa25', mother_id = '18657a6d-9e7c-40a8-89d8-7e35236bf7d8' WHERE id = '0ca7a178-ef83-4e3e-bed9-f512955413f6';
  UPDATE public.profiles SET father_id = '5ea206d2-8d61-42ff-a7be-fda5c18a6dfb', mother_id = 'eea78a25-abf7-4da4-8f48-1b63d240ea68' WHERE id = '4ce658a3-948b-48d8-89b9-55eac05819a2';
  UPDATE public.profiles SET father_id = '5ea206d2-8d61-42ff-a7be-fda5c18a6dfb', mother_id = 'eea78a25-abf7-4da4-8f48-1b63d240ea68' WHERE id = 'd9a341ba-d9ed-4190-a451-204dbb0c28a1';
  UPDATE public.profiles SET father_id = '5ea206d2-8d61-42ff-a7be-fda5c18a6dfb', mother_id = 'eea78a25-abf7-4da4-8f48-1b63d240ea68' WHERE id = 'bc14bb02-efa4-491f-8402-566daac5c7fd';
  UPDATE public.profiles SET father_id = '947a30d4-f34c-4a63-a81a-993b3e2ab741', mother_id = 'da12dc4e-6934-490a-84bf-a186bb750f12' WHERE id = 'cdb95968-a963-47a4-ba61-150a1236156d';
  UPDATE public.profiles SET father_id = '947a30d4-f34c-4a63-a81a-993b3e2ab741', mother_id = 'da12dc4e-6934-490a-84bf-a186bb750f12' WHERE id = '07d5d76a-aae8-47b1-852c-ce98704d4e32';
  UPDATE public.profiles SET father_id = '947a30d4-f34c-4a63-a81a-993b3e2ab741', mother_id = 'da12dc4e-6934-490a-84bf-a186bb750f12' WHERE id = '7956bcd4-33f5-4a18-b769-e463c1861209';
  UPDATE public.profiles SET father_id = '18d50a5c-a531-4324-a680-9832fa857cd2', mother_id = '24af58f5-b953-4455-afdb-0bedf37a64f2' WHERE id = 'a953593a-a78f-489e-b0da-4d638f2bd524';
  UPDATE public.profiles SET father_id = '18d50a5c-a531-4324-a680-9832fa857cd2', mother_id = '24af58f5-b953-4455-afdb-0bedf37a64f2' WHERE id = '8bcdd32b-4209-4866-9d8a-783b7a43f6fb';
  UPDATE public.profiles SET father_id = 'dfa88997-39d0-4a9b-b6a3-035104389c44', mother_id = '2011e28d-b353-487e-8bdb-b5aad51d574b' WHERE id = 'c691b79f-90d6-4af5-90a1-fadcbdc676e1';
  UPDATE public.profiles SET father_id = 'dfa88997-39d0-4a9b-b6a3-035104389c44', mother_id = '2011e28d-b353-487e-8bdb-b5aad51d574b' WHERE id = 'e6ad1e84-bb1c-413c-a98a-753162f026c3';
  UPDATE public.profiles SET father_id = 'f2b78013-1604-4338-9838-2feb52f78055', mother_id = '7c6c7261-9358-475e-b24c-1e5d3ea60124' WHERE id = '6e349580-00fc-4ca8-be94-444535630811';
  UPDATE public.profiles SET father_id = 'f2b78013-1604-4338-9838-2feb52f78055', mother_id = '7c6c7261-9358-475e-b24c-1e5d3ea60124' WHERE id = '618c955f-a79d-46c6-8875-c50601ecec68';
  UPDATE public.profiles SET father_id = '03fe773f-ac9e-46e1-85ad-9322a4980440', mother_id = '350000fd-135e-49ad-b022-0684edade46d' WHERE id = '3f2edbdd-c858-4110-9891-12f8b31d1bab';
  UPDATE public.profiles SET father_id = '849a3ace-7380-409b-a73e-16d58135403e', mother_id = 'bb39230a-b444-4cb6-a8b6-8340c5559862' WHERE id = '96d460db-7119-47e5-a68d-01c517316d20';
  UPDATE public.profiles SET father_id = '849a3ace-7380-409b-a73e-16d58135403e', mother_id = 'bb39230a-b444-4cb6-a8b6-8340c5559862' WHERE id = 'a2e62d44-ba3d-415d-9029-606d86d3858e';
  UPDATE public.profiles SET father_id = '849a3ace-7380-409b-a73e-16d58135403e', mother_id = 'bb39230a-b444-4cb6-a8b6-8340c5559862' WHERE id = '6883bac2-0edf-44c2-af2d-77b8566823e5';
  UPDATE public.profiles SET father_id = '849a3ace-7380-409b-a73e-16d58135403e', mother_id = 'bb39230a-b444-4cb6-a8b6-8340c5559862' WHERE id = 'fa5e0052-102e-4967-9f34-8fff528e752c';
  UPDATE public.profiles SET father_id = 'b802b313-1f03-44a1-9431-4fda4df0bdcd', mother_id = '83358379-36e8-4e78-8270-2997145d144a' WHERE id = 'a6333ea8-878c-45fb-898f-fd53fd3f0184';
  UPDATE public.profiles SET father_id = '1551f859-b707-46cb-8aa5-a900371ac15d', mother_id = '9100c0ed-3f3e-46be-be53-ae1f33177482' WHERE id = '72f47467-e296-44f8-b940-69c3803f4155';
  UPDATE public.profiles SET father_id = 'c98b5d32-0e52-4b43-a2fd-67683be9661a', mother_id = '567d3303-f645-4827-87b6-1b11a92a06dc' WHERE id = '311c1afd-043d-4c4f-a3be-cf0f24d2a7a1';
  UPDATE public.profiles SET father_id = '31e355e8-5400-4a0f-b8d6-a763e554866e', mother_id = 'a062693d-2dce-4d48-a27e-7a6d1289e2ca' WHERE id = '239e300a-4790-43cb-8169-b0a563aad46e';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '83dc56e9-4e30-49d8-9b05-156f3482872f';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '71b0b33f-7009-4967-a752-ee5a4acbea9f';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '53491e75-6ff8-447e-8056-4497a20c0c01';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '6e2edad1-ba7f-4aff-ad40-8ea6383a88ff';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '12a25ecf-eed8-4736-9092-e199c32cdaaf';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '2103520c-3b54-4b08-96d0-fbdfd6d40688';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '0b530795-5001-42f5-a44a-0dbe275abb65';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '28f0fc53-ccf1-4738-b8ca-a4fcc5a265f8';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '166f498c-48be-4ec4-abe3-8aedee69e007';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'e535df0a-7307-40dd-8085-077cc52808c2';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'd6be1ebf-2ce8-43fb-b2c8-fb6bc363b497';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'f21319b2-9c6d-4443-8cb1-22d4af1f48a2';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '39f5e786-724f-48f1-bf6f-21bb789b8d9f';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'e0fca23e-125a-4eb7-9d12-0a4bda6a02f8';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'dc9d344b-2497-4c57-906d-7cd5f7e619ba';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'cccaf427-9b05-4e59-a2ac-8e7a857a3dd5';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '1e49b669-6156-4323-bc26-a92aa3112fd1';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '28eb3e84-4847-4cd4-b218-28d055c380fd';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '4079f663-01a4-4d69-98ab-1d05ce7a6fa0';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '85cbebb3-02c8-4d1b-a33e-0a10a7e89d4a';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '3826197e-e8b9-4d91-b065-a3212a7a5032';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '6dd3d2ef-0fa4-4f29-b34b-1f0906373ad9';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '91c321ad-6af7-4fc3-a9a7-e02908e8839e';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'a557f6dd-208f-4185-8264-40871dd5617f';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'c214e140-a9e9-4f0b-b61a-e5e24caf2756';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '68221963-f337-4c98-8375-194da3a2e5de';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '34c0d78b-b7ad-4b95-b1fe-ad4f4747f695';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '0cb227a2-c276-4e02-b7e7-727daef77a2b';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'd2c6f368-1999-4a98-b996-f527af0c9410';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '2c85e7af-b645-4e9f-817f-c1c46606ce6d';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'b6675f94-21df-4be9-85a4-e58d4c2ac727';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '4bbd0433-d8b7-4c33-abd7-feba3aa9a1e3';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '836ed079-f6af-48ba-9a6f-18afc6b5bca0';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'e583f2a3-ea7c-4a43-aa50-b27bb0ee3d5f';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'd25d3712-71a7-442a-8ebb-9c5943b6a0ef';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '1d54d962-4692-4800-8d96-2c009606209d';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'ebe9459a-5008-4364-9bc0-e5ba918460a6';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '8eb27ef8-c053-4080-96ca-ac23d469aac3';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '15228aa0-4dd6-4aff-9d62-0a91cd7e6cf8';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'a2c78812-e577-4855-a98b-074f8ab19ae8';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '5ce50357-665f-4140-a172-90ecc5f8c98a';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'f1b261ea-62a7-4b09-971e-2ebb9a1f5b94';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '03c9d7ae-f5e1-4a04-8a04-db72a03af805';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '1ebfc994-a0a7-49fe-9e7d-e5b68694c034';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '6799c625-cab0-4dd8-af59-5aa393a0e0ef';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '8e4f91b5-aa21-404d-874c-7e56c390fc84';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '74a38e72-d95c-44fe-bf68-702933ebb38f';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'd8480bea-4379-4eb4-9bbf-3e230a8e9c84';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '6ff738f2-72ed-4d0e-9580-2f90facfdc93';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'cb04150e-d431-40f0-93b3-d643eb309d38';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '22ac7613-e4ce-4366-9d84-6e1e401c9f3c';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '94cbbff0-79a6-46c8-9871-6314d0bccb0e';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'f6116ebb-8d7d-4b36-b283-a18314bc4d88';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '80d39d4c-d1bb-48f2-a63f-443fbeca8cb4';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'bb34e22c-b89b-4e16-b11f-239304fd5ed8';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '6963fca1-36f3-4935-9f86-caf837205965';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '24065499-8fd5-436e-a812-b80cc5ef5a48';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '550afe05-4048-4447-a5f1-e3e8180edb3f';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'b3335703-0ab4-4e8c-a949-31fc949c853c';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '3f08a58a-49d5-455a-947b-3b34570b77ac';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'd12bb9b3-03ef-403f-8c23-d2757e5830f4';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '0c7a08b7-c694-4247-9384-78f7684a8f46';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '7615efc4-6adc-45ee-a847-91fca1771ca7';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'c0cff7be-9aad-4389-ac3b-783f1fdc9dfa';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '10f2efff-a9bf-4e93-a4a5-4ee7c73bb84a';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'b6384c28-b589-4ea0-a152-c332fa63615c';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'f4b7faed-3a1a-4623-9ac5-9da45b30bffc';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '828d72a6-a632-4adc-b497-2dc1dfe0fee5';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '10bf51cf-8adc-4777-941d-d86fa0bf833d';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '9a46667d-67a2-457d-b555-9b637017c3c2';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '197f8dd1-f65f-406d-b8e6-2b4e71c4d96e';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '91af39e3-6ccc-41f7-ad63-9e5461451194';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '1a4d1815-c679-4da1-b98f-379d0d5aeb84';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '2c1016ff-90e6-4a07-8cc2-fd68e50729fa';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'a9acaa74-80ee-4025-8b5c-1e97ecbd3abf';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'd511c5d7-074b-4487-a6f6-d386c5c26caf';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '8e0d81e0-f88f-4a38-a55a-0e9ac2925683';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'e9405db4-00d6-4d6e-8c41-8da72a59bf04';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'e3f627e3-d700-409d-a83c-98640d9fbe24';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '7de98053-6d08-4881-961c-0a1ac14cb85d';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'fc1e957f-854b-4456-b175-0fd4bac83d83';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'd6ef02d0-1ca8-4d7c-b662-72147442297c';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '69d33def-9d99-4556-b54e-4080a1697c1f';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'b2cdf6d2-b9e4-4368-8cbf-991b90c43fa9';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '75e5e431-2705-410f-b034-62b55d8cd199';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '75e3d51d-fd8a-4322-9937-2f7539c21d50';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '7214d4a1-64b1-4eb6-a08d-79ed01912358';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'dd0b0f66-9696-44c5-acad-9b6e07e1b2ac';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '83890abf-a186-4469-85b7-c9952740a827';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '9a79839f-7f64-47d8-aa91-93367d5f9957';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'bd6c4119-c5a3-4cd3-adde-b3d94fbfc502';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'e4965f7a-3288-4aee-a66f-ef67ed0947c0';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '8656d15f-0e7f-4ffc-b6be-638f3c673d62';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '5e9d0524-2484-4853-a857-05f69f088c36';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'a3200045-59eb-4a10-bc4a-aed6a715e3c9';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '23c64fd0-87f8-49ff-8757-539a8c15e608';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '9b2eed70-c556-45d4-9243-9b096d28df9a';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '19f83197-469e-468a-835a-8d57f01b988c';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'd5935a37-98a3-4723-8e7b-f0c7e0e2b076';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '3a5d894f-f715-4e2b-8ba6-94a502615145';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '8ad685be-5e51-406f-8d6d-c3ac79bb73b6';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '56983260-593f-4ab2-ae14-6a6a9c48c808';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '8c0b3db5-99d8-4b9d-855e-c585bdf396ea';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '5586cc80-0d94-4f79-a631-ea80e3206876';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '0a723a35-3108-4af4-98ce-2191459629fa';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '815eb69e-6285-46be-937d-ebbd55324192';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '72295479-fa8b-4458-b802-f7916e4e3562';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'f5e0a121-576a-48b3-b918-549743bf6f81';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '50ed612f-d637-4f23-a52a-a6b5703f2a04';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'f6deff82-f7c9-4ae2-9dd6-6214cae704f6';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '196bb146-4697-4a27-8492-56f34c81deaa';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '8a9ae7fe-4956-40c4-9a76-062162119b71';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '05602915-b9bc-4407-87a1-5df7a82391aa';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'b3ac3988-74dc-46e5-a597-f419a1124449';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '82f7118f-99ab-4293-8b0a-725b54a46f74';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'd28c9860-1ffd-440a-b7b9-1e42bf37cd26';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'dab77623-6d4f-41b4-85ed-e2204450f329';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'e1468496-9ccd-402b-bb2b-f041e2c73c5b';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'b0be9877-22f4-49c9-9c3d-07e84507d962';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '06168178-e907-4261-93c3-4f319f9ba1e4';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '3cadce89-f928-431d-b103-651480e93df7';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'd56cc064-3114-4e3f-8ab6-dec6d8567dcd';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'cb86217a-edd6-4bfd-86d6-b9ed44adc6fd';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '29823848-0f06-4b7d-8365-851464236c4e';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'e8940714-eefb-4a99-9148-4af1246828e6';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '209bbac1-0ad0-4395-9f19-2499d1f1f9b6';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '1764b00f-ecc1-4dd4-ac6c-02e1c9612954';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '986c0cbd-679d-434b-9f40-68c7215b3b09';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'ccb5e96f-c7cc-4e6a-8740-e21b4275e834';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'fc07de25-0887-4881-8a50-ec57cf905526';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'c8ad0a37-fb0c-4bbd-a4b4-b7148b521857';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '92384d35-0f90-41a7-a3e9-4a017e60ec21';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '1c71a46b-a3cc-4315-9310-803336d71755';
  UPDATE public.profiles SET dependents_count = 4 WHERE id = 'cad4ccf2-0057-46fd-85c8-622acdcdec29';
  UPDATE public.profiles SET dependents_count = 4 WHERE id = 'b3374bbc-8174-4ec2-9e51-5fc9868f7e8c';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '9fd7d309-8949-4e25-9768-c6cdf988d47b';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '16568471-4fad-45e8-a4dc-e9f94f1baf89';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '84ff3467-1f52-4a31-9659-9389713282bb';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'eddac668-a914-42cd-87f7-e78070c77ed1';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'b06a9fe5-8dec-446b-bcbd-9dfd06ce8580';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'bbc047e5-a6e4-4dd0-afbb-12bac35fe144';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'aa0281c5-73ae-4e2d-84d2-e36b0512f9cc';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'ca85675f-2fa5-485a-a625-8b81be8d1a64';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '4d31e76e-bc8c-42a2-a5ab-167b6f49256c';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '4ae7043d-44f1-4068-ab91-f3d0eeab7ba8';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'c727f032-2743-4d6b-858e-de980d0581bf';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '11d00d6f-7a11-4476-81e8-4da73e434acf';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '14cf1d8e-c4ab-4bdd-859c-4e1e5d9db1a3';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '4db8aecd-7926-4340-ae04-a27a3d2e81cd';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '8fdded88-2474-405a-bb8c-78fde9c8a660';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '3029f46b-81aa-412b-b2db-175c1ddc07cf';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'bd0fa006-8518-4e5c-a361-9eeb7b88e410';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '2f1f2b60-13e5-4b0c-a410-774d8872fd77';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '49aeac36-ae38-494b-970e-605dd14fdc2c';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'f494fe47-b70c-4c5b-8074-80d785be7c27';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'a725ad4d-588e-467f-9462-82a60e8ba2a6';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '9508d2d2-350e-4a52-8cb1-4a94ae88d626';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '72d08f64-1e96-4885-bb4d-9258a795a474';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '5b055d16-a494-432e-91d9-718bd9d025f7';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '63cdc71a-7c76-4699-8669-24dd376f5af3';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'bcf09900-bfd7-4218-bc09-1238e3c22160';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'fcca9a58-8884-4045-a801-0141179e7d2e';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '55a28087-f3c1-4bcd-b095-c5bee6988be1';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'f47eb221-9849-446f-9299-2c2a96c3b72b';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '967897ce-e167-4250-857e-302a934c4cd3';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'c8a4ba56-d20d-4f47-b497-07de3bffc815';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '046a62cd-d1a0-454e-a1b9-b774fb4517ea';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'faaed601-4196-4df0-8438-21bd489e5abc';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '95f71fa0-6237-4c0b-80fc-d99e2ce0f84d';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '83f933b7-2b28-4ed7-9143-719e1f10b709';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '50037ebc-403d-45f6-aa98-170dd6ca1f30';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '9d22fa36-1329-450e-b8d6-caac02c44d66';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'ad1c7be3-0954-46da-8525-2ab725a3e949';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'd81b32d8-3361-4785-8f84-47842b070fa7';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '20299992-40a3-464b-af2f-6445fdf3b48c';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'bb3b59e5-de49-4908-84a2-82ad4c716d15';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '12f1d11a-a53c-4109-a055-82be54fde14f';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '85f0ba08-787f-44cf-8fb8-f3ee76362b15';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'c49f8547-ffe9-4fba-89f0-4856e09f7324';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '218d21b4-19df-42fa-868a-1c028a20626f';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '34a64dbc-42d1-4df7-bece-25fd54cbe584';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '0ec1ff8c-f44c-477e-861e-daa350347e36';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '357bb926-8ea8-41bb-86e0-32c6b37e417e';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '5bc128dc-441c-4717-8a70-50c3400f47f8';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'd6098285-5234-4f63-ae72-2f81b0f47809';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '1d64e2be-8aac-4540-95cd-92d5cbde61b2';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '24c74460-e6dd-49ab-9921-721fd4ef6055';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '5750fd70-f815-4499-88ea-b73bf5d98572';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '8d14b1e3-3c0f-4739-b404-46d72d21cc74';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '1b171281-cd18-4fb3-b853-76ea6529d92e';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'fafb068b-ac68-4ae7-bcbb-f2ff2374af83';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'e1af9709-5187-4e93-869a-72253199e61c';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '7d922828-7f20-4eb2-83f2-6da6b04c6a0c';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'c33fa385-9f2b-472b-87af-64dcc572a393';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'b21fb951-c70c-489b-bb83-126b869ad4da';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '2d4f11b7-3864-48ca-8dfb-acac13e3e633';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'e795724e-2230-44b6-a330-3c1757eb511e';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '59dc55a4-6480-4083-882f-a9fde99f42f2';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '0f7e7416-c29b-4d6c-9d1c-3b66c716d5d2';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '49f67b24-3323-401d-91c1-23153a80de7c';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '9e8c8eb7-b83b-4fed-aaf9-df5a5c3c0a72';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '91745890-20f0-4a7b-8403-f6a9d8e1974a';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '71358ba6-75ad-4b0e-bd17-dbb779210b2e';
  UPDATE public.profiles SET dependents_count = 6 WHERE id = '6f3da312-2192-4fb8-8919-c4a16c67915a';
  UPDATE public.profiles SET dependents_count = 6 WHERE id = '197e0ace-9c04-4d98-9a58-514b92e32b35';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '94331f45-93dc-4c93-a2fb-243aa9ef0060';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '5aef5ec9-d89e-4a90-93fa-2b7b835c82db';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'f76a602c-8be1-4ab6-b41b-26d71404da4a';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '50122db6-6e32-4e4a-b670-51311e2c483d';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '5ace990f-ceae-473d-b68c-a4d276ced940';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '5f304ecd-5612-4bc8-b4c5-6305afdf424f';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '3456c288-6616-449b-ad4f-7a6fa4c2b64e';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '6e5bb176-7465-4a41-a54b-5744ddf342ef';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'e61f63a4-c117-4fcb-a3b9-0a3180610995';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'd60538f9-f4e2-445d-a05a-48440392b15b';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '2432be66-38cf-4425-bd0d-19f773bdb458';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'eb58b79f-4fe6-4449-9c7f-c3984f2024c5';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '9df93b7a-f166-4e1a-8ac8-cfc9d43cf8e7';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '32ba3595-2b00-4919-9df1-fee06f8f84fe';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'a372098d-62fa-4a2d-add7-2cd5038ad667';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '2467d6c7-d1f6-4fb9-8fae-eb8f9ce6fe74';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '9864ebf7-d26e-48b2-b0e1-9e88f02ab7ae';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'a9ad90de-d5e4-49ee-b8b5-e7e5ea480953';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '38e1116f-4ed8-45e1-9a55-c1948b4e6575';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '31313de6-b5cc-45b7-87d0-8bc03e7fa5cd';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '2c813d31-2ae8-4c95-a2b5-deb92f5b6172';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '7d7ccec7-3b36-4b39-9c6d-ba38c6fa2efb';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '2fc663f3-a8d5-4e1b-a2dc-98520dda38b2';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '85dfa227-5e5f-43d2-ae5e-937147f285ba';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'ca0d3bd6-62f5-42da-ab0b-2321de784d95';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '5b2a9424-af91-4967-9a18-3d682d04005a';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'b26c7ec3-d2d9-411e-9638-0db835db733a';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'f53f0316-2854-4ca7-b501-7ca0d5ec5d3d';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '6415fe87-33e5-48cc-844d-f5ed9eae8be7';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '3df444aa-89f4-4308-a01b-38622242a741';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'c369a90d-4316-4d4e-a31a-6c13bfb9c996';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'ba110cff-557b-45db-a196-c6e8fc8e71a4';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '6234ade4-b8bb-4611-b3f9-463fb0b4caba';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'a9d51b21-df82-4c56-9186-7151224e65a5';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'e2487d28-89eb-4394-857c-6f30a8688675';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '0d0cf63e-7521-443c-95bc-f85fc98546e9';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '509e34f6-b484-417c-8223-8408409ce779';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '2802e112-f41d-4d6c-ac84-793ba506e93e';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '65dead1d-7158-4122-8d2f-90b636cd173c';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '2ee08aed-3fd5-4f3e-8cdc-5b1d4782c23d';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '13208420-1f67-46e3-bd1a-0e8e9722dfc8';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'ed986db6-452c-4ef3-9340-474b7aca1df9';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '1bca7d3e-f87d-4ce3-975d-d5896046064a';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'cb8da091-9837-40b9-a842-3105fe329545';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '192eefab-7304-454a-a5fa-288e6e267258';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '1e664157-86cd-4f8c-a896-0a05bd145073';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'fa38cfc7-728e-4c52-a6bb-c633d2b834fc';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'fdc5e5c9-2e6c-4b71-936a-bf6e1f1be73b';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'a1ea11cf-40b5-4960-8359-fc60217a11bd';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '9553e140-a3d3-4602-8dec-deb41f4a3db9';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '7edd7fe4-0dac-457f-933d-b1f57afffa25';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '18657a6d-9e7c-40a8-89d8-7e35236bf7d8';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '5ea206d2-8d61-42ff-a7be-fda5c18a6dfb';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'eea78a25-abf7-4da4-8f48-1b63d240ea68';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = '947a30d4-f34c-4a63-a81a-993b3e2ab741';
  UPDATE public.profiles SET dependents_count = 3 WHERE id = 'da12dc4e-6934-490a-84bf-a186bb750f12';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '18d50a5c-a531-4324-a680-9832fa857cd2';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '24af58f5-b953-4455-afdb-0bedf37a64f2';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'dfa88997-39d0-4a9b-b6a3-035104389c44';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '2011e28d-b353-487e-8bdb-b5aad51d574b';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = 'f2b78013-1604-4338-9838-2feb52f78055';
  UPDATE public.profiles SET dependents_count = 2 WHERE id = '7c6c7261-9358-475e-b24c-1e5d3ea60124';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '03fe773f-ac9e-46e1-85ad-9322a4980440';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '350000fd-135e-49ad-b022-0684edade46d';
  UPDATE public.profiles SET dependents_count = 4 WHERE id = '849a3ace-7380-409b-a73e-16d58135403e';
  UPDATE public.profiles SET dependents_count = 4 WHERE id = 'bb39230a-b444-4cb6-a8b6-8340c5559862';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'b802b313-1f03-44a1-9431-4fda4df0bdcd';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '83358379-36e8-4e78-8270-2997145d144a';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '1551f859-b707-46cb-8aa5-a900371ac15d';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '9100c0ed-3f3e-46be-be53-ae1f33177482';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'c98b5d32-0e52-4b43-a2fd-67683be9661a';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '567d3303-f645-4827-87b6-1b11a92a06dc';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = '31e355e8-5400-4a0f-b8d6-a763e554866e';
  UPDATE public.profiles SET dependents_count = 1 WHERE id = 'a062693d-2dce-4d48-a27e-7a6d1289e2ca';

  -- ==========================================================================
  -- 7. ATUALIZAR DISCIPULADO (discipler_id)
  -- ==========================================================================

  UPDATE public.profiles SET discipler_id = '43a87279-c2a3-44df-9b70-6b1314934124' WHERE id = 'c01e7102-e725-484a-a5e1-f7bcee3a00eb';
  UPDATE public.profiles SET discipler_id = '83dc56e9-4e30-49d8-9b05-156f3482872f' WHERE id = 'a21b1d50-ceb5-43b4-8a7a-24526472779e';
  UPDATE public.profiles SET discipler_id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b' WHERE id = '394a6e33-9fa5-47f0-be1b-3ff549951b34';
  UPDATE public.profiles SET discipler_id = '83dc56e9-4e30-49d8-9b05-156f3482872f' WHERE id = 'dc0ad390-9421-454a-a25f-31454fc290dd';
  UPDATE public.profiles SET discipler_id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b' WHERE id = '0c5dcb2f-9f4c-4730-9fe2-3f5c21427c92';
  UPDATE public.profiles SET discipler_id = '83dc56e9-4e30-49d8-9b05-156f3482872f' WHERE id = '97e4694b-3218-4187-9300-c0f42c79e9be';
  UPDATE public.profiles SET discipler_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b' WHERE id = '1394e852-8f65-41c4-9603-4f0721fea0e9';
  UPDATE public.profiles SET discipler_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688' WHERE id = '7802d16e-a1c5-404b-9141-3a15a1e472a7';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = '829596bb-197d-4d12-b116-ae0dd6ddc001';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = '28f0fc53-ccf1-4738-b8ca-a4fcc5a265f8';
  UPDATE public.profiles SET discipler_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688' WHERE id = 'c85b8141-3184-4164-ac5a-71eb58abecaf';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = 'c34d4568-7b31-484f-8e06-dcf74b136392';
  UPDATE public.profiles SET discipler_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688' WHERE id = '34dc7595-4487-4743-aba2-19fab3a44253';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = '0cd68fba-8240-4008-b4a6-c046e424534a';
  UPDATE public.profiles SET discipler_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688' WHERE id = '166f498c-48be-4ec4-abe3-8aedee69e007';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = 'e535df0a-7307-40dd-8085-077cc52808c2';
  UPDATE public.profiles SET discipler_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688' WHERE id = 'd6be1ebf-2ce8-43fb-b2c8-fb6bc363b497';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = 'f21319b2-9c6d-4443-8cb1-22d4af1f48a2';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = '6c3575cf-1535-4755-9078-e6799c7cdc6c';
  UPDATE public.profiles SET discipler_id = '43a87279-c2a3-44df-9b70-6b1314934124' WHERE id = '33030957-f988-4b51-873e-34f03b4c1852';
  UPDATE public.profiles SET discipler_id = '7802d16e-a1c5-404b-9141-3a15a1e472a7' WHERE id = '03d3d166-3090-44a0-805a-b76d19a6210a';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = '09d1911d-4681-413c-b258-65596b1e6078';
  UPDATE public.profiles SET discipler_id = '7802d16e-a1c5-404b-9141-3a15a1e472a7' WHERE id = 'bc32de95-ae0d-4e6e-8853-110b8c274e94';
  UPDATE public.profiles SET discipler_id = '4079f663-01a4-4d69-98ab-1d05ce7a6fa0' WHERE id = '6f2576eb-f800-41ee-b80c-57b3359867e8';
  UPDATE public.profiles SET discipler_id = '85cbebb3-02c8-4d1b-a33e-0a10a7e89d4a' WHERE id = '3b10f967-608d-470a-96ae-98a898410310';
  UPDATE public.profiles SET discipler_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = 'e0fca23e-125a-4eb7-9d12-0a4bda6a02f8';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = 'dc9d344b-2497-4c57-906d-7cd5f7e619ba';
  UPDATE public.profiles SET discipler_id = '0e0174b8-c98b-423d-b150-8cad415a0ac3' WHERE id = '3559b2ac-d460-4459-bd47-aa48ec3e7bfe';
  UPDATE public.profiles SET discipler_id = 'bc32de95-ae0d-4e6e-8853-110b8c274e94' WHERE id = '1de98373-3024-4b8d-ae39-fe3d1848c283';
  UPDATE public.profiles SET discipler_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = '9707fc03-3279-4be2-b46f-a24dd9ab24d4';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '1c2618fc-7458-43a4-b0ff-a0b29d228dea';
  UPDATE public.profiles SET discipler_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = 'f11a2636-9554-47e6-b9fb-ab08b525d29b';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '810733a5-3ce6-4f55-9837-fed9f9ab41b5';
  UPDATE public.profiles SET discipler_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b' WHERE id = 'cccaf427-9b05-4e59-a2ac-8e7a857a3dd5';
  UPDATE public.profiles SET discipler_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = '1e49b669-6156-4323-bc26-a92aa3112fd1';
  UPDATE public.profiles SET discipler_id = 'cccaf427-9b05-4e59-a2ac-8e7a857a3dd5' WHERE id = '186f6670-23dd-4279-9b39-cc154c909bfc';
  UPDATE public.profiles SET discipler_id = '1e49b669-6156-4323-bc26-a92aa3112fd1' WHERE id = '59031464-f3b9-4eaf-8b5a-5f156e8476be';
  UPDATE public.profiles SET discipler_id = '10f2efff-a9bf-4e93-a4a5-4ee7c73bb84a' WHERE id = 'e4a3280b-7173-4cae-8995-89d54d20f457';
  UPDATE public.profiles SET discipler_id = 'b6384c28-b589-4ea0-a152-c332fa63615c' WHERE id = '0e0174b8-c98b-423d-b150-8cad415a0ac3';
  UPDATE public.profiles SET discipler_id = '2103520c-3b54-4b08-96d0-fbdfd6d40688' WHERE id = '28eb3e84-4847-4cd4-b218-28d055c380fd';
  UPDATE public.profiles SET discipler_id = '0b530795-5001-42f5-a44a-0dbe275abb65' WHERE id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb';
  UPDATE public.profiles SET discipler_id = 'e4a3280b-7173-4cae-8995-89d54d20f457' WHERE id = 'f71e670f-576d-45a3-8435-9fd0ba68924f';
  UPDATE public.profiles SET discipler_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = '0600f041-2f00-4ba5-9140-9d3752f3638b';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '5aa43d91-c800-4b01-82ae-633d9fdfadfc';
  UPDATE public.profiles SET discipler_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = '4079f663-01a4-4d69-98ab-1d05ce7a6fa0';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '85cbebb3-02c8-4d1b-a33e-0a10a7e89d4a';
  UPDATE public.profiles SET discipler_id = 'f71e670f-576d-45a3-8435-9fd0ba68924f' WHERE id = '6044f1d7-0e39-4598-a7f5-e88fe8b9ea06';
  UPDATE public.profiles SET discipler_id = 'e4a3280b-7173-4cae-8995-89d54d20f457' WHERE id = '3826197e-e8b9-4d91-b065-a3212a7a5032';
  UPDATE public.profiles SET discipler_id = '0e0174b8-c98b-423d-b150-8cad415a0ac3' WHERE id = '6dd3d2ef-0fa4-4f29-b34b-1f0906373ad9';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = 'c5f97636-36e9-4717-9baa-b98985d5c429';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '91c321ad-6af7-4fc3-a9a7-e02908e8839e';
  UPDATE public.profiles SET discipler_id = 'f71e670f-576d-45a3-8435-9fd0ba68924f' WHERE id = '9de8acdf-dfff-46fb-8624-ccc908a3defe';
  UPDATE public.profiles SET discipler_id = 'ab1f1ed9-4a69-4104-a4a6-d0923d7cce03' WHERE id = '357a9463-3331-4766-bc69-d6e92de8426d';
  UPDATE public.profiles SET discipler_id = '509e34f6-b484-417c-8223-8408409ce779' WHERE id = 'ab1f1ed9-4a69-4104-a4a6-d0923d7cce03';
  UPDATE public.profiles SET discipler_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = 'a557f6dd-208f-4185-8264-40871dd5617f';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = 'c214e140-a9e9-4f0b-b61a-e5e24caf2756';
  UPDATE public.profiles SET discipler_id = 'e4a3280b-7173-4cae-8995-89d54d20f457' WHERE id = '51a3bc47-e6b0-4608-a7f6-73c70bdd7df6';
  UPDATE public.profiles SET discipler_id = '357a9463-3331-4766-bc69-d6e92de8426d' WHERE id = '68a357e5-c22c-44fc-b825-1d477a0d76ea';
  UPDATE public.profiles SET discipler_id = '85cbebb3-02c8-4d1b-a33e-0a10a7e89d4a' WHERE id = '9455b964-07a9-4127-9167-362c7db4d19c';
  UPDATE public.profiles SET discipler_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = 'ce46cd12-26bf-46ce-8766-d3db425b0770';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = 'e06188be-384d-44e3-8ced-0921401067fe';
  UPDATE public.profiles SET discipler_id = '28eb3e84-4847-4cd4-b218-28d055c380fd' WHERE id = '68221963-f337-4c98-8375-194da3a2e5de';
  UPDATE public.profiles SET discipler_id = 'b62580db-05f2-458d-8e9b-eaa5ffddedbb' WHERE id = '34c0d78b-b7ad-4b95-b1fe-ad4f4747f695';
  UPDATE public.profiles SET discipler_id = '83dc56e9-4e30-49d8-9b05-156f3482872f' WHERE id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b';
  UPDATE public.profiles SET discipler_id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b' WHERE id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c';
  UPDATE public.profiles SET discipler_id = '83dc56e9-4e30-49d8-9b05-156f3482872f' WHERE id = '10f2efff-a9bf-4e93-a4a5-4ee7c73bb84a';
  UPDATE public.profiles SET discipler_id = 'b1ba07d0-2b46-4b64-901a-067d3ba5487b' WHERE id = 'b6384c28-b589-4ea0-a152-c332fa63615c';
  UPDATE public.profiles SET discipler_id = '10f2efff-a9bf-4e93-a4a5-4ee7c73bb84a' WHERE id = '10bf51cf-8adc-4777-941d-d86fa0bf833d';
  UPDATE public.profiles SET discipler_id = 'b6384c28-b589-4ea0-a152-c332fa63615c' WHERE id = '9a46667d-67a2-457d-b555-9b637017c3c2';
  UPDATE public.profiles SET discipler_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b' WHERE id = '197f8dd1-f65f-406d-b8e6-2b4e71c4d96e';
  UPDATE public.profiles SET discipler_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = '91af39e3-6ccc-41f7-ad63-9e5461451194';
  UPDATE public.profiles SET discipler_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b' WHERE id = '17a0709c-7cbb-4ac1-ae26-cb614a26cb63';
  UPDATE public.profiles SET discipler_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = '16261a18-6bc6-45da-8254-22818ad7b083';
  UPDATE public.profiles SET discipler_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = '3e629038-47e5-4efb-9fc3-5b96a2490247';
  UPDATE public.profiles SET discipler_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = '1a4d1815-c679-4da1-b98f-379d0d5aeb84';
  UPDATE public.profiles SET discipler_id = 'fad32082-0fbb-4c0f-a3d6-44f175147f3b' WHERE id = '7088732e-76c7-4ab7-afc2-620a1ac9e05c';
  UPDATE public.profiles SET discipler_id = 'e0c021b5-3aeb-45c0-b63f-3226b11a291c' WHERE id = 'fc3551a8-f94b-4181-9db6-53936ac8fd50';
  UPDATE public.profiles SET discipler_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e' WHERE id = '29823848-0f06-4b7d-8365-851464236c4e';
  UPDATE public.profiles SET discipler_id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb' WHERE id = 'e8940714-eefb-4a99-9148-4af1246828e6';
  UPDATE public.profiles SET discipler_id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb' WHERE id = '1764b00f-ecc1-4dd4-ac6c-02e1c9612954';
  UPDATE public.profiles SET discipler_id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb' WHERE id = '89e10859-ccb5-4268-a4a8-4d75572ee5f4';
  UPDATE public.profiles SET discipler_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e' WHERE id = '986c0cbd-679d-434b-9f40-68c7215b3b09';
  UPDATE public.profiles SET discipler_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e' WHERE id = 'fc07de25-0887-4881-8a50-ec57cf905526';
  UPDATE public.profiles SET discipler_id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb' WHERE id = 'c8ad0a37-fb0c-4bbd-a4b4-b7148b521857';
  UPDATE public.profiles SET discipler_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e' WHERE id = 'a4b72b41-e1e7-45a7-b096-2be0a0672cf2';
  UPDATE public.profiles SET discipler_id = 'c2ce6bc1-352a-4be6-a322-8eab716c9e5e' WHERE id = '92384d35-0f90-41a7-a3e9-4a017e60ec21';
  UPDATE public.profiles SET discipler_id = 'ffa4842e-9af8-4566-b526-0d1fd04fbfdb' WHERE id = '1c71a46b-a3cc-4315-9310-803336d71755';
  -- Gabriel Góes Braga discipulado por Fernando (Presbítero) e filho de Fernando e Clara
  UPDATE public.profiles 
  SET discipler_id = fernando_id, father_id = fernando_id, mother_id = clara_id 
  WHERE id = gabriel_id;


  -- ==========================================================================
  -- 8. JUNTAS DE COMPANHEIRISMO (fellowships)
  -- ==========================================================================

  -- Juntas mútuas do presbitério e esposas
  INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
  VALUES (LEAST(fernando_id, flavio_id), GREATEST(fernando_id, flavio_id), now())
  ON CONFLICT DO NOTHING;

  INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
  VALUES (LEAST(clara_id, marleide_id), GREATEST(clara_id, marleide_id), now())
  ON CONFLICT DO NOTHING;


  -- ==========================================================================
  -- 9. PLATAFORMA DE ENSINO & CATEQUESE (Media Resources, Studies, Steps, Progress)
  -- ==========================================================================
  INSERT INTO public.media_resources (id, title, description, type, url, series_name, category, created_at)
  VALUES 
    (m_res_id1, 'O Propósito Eterno de Deus: A Família de Muitos Filhos', 
     'Exposição bíblica profunda sobre o desígnio eterno de Deus em ter muitos filhos semelhantes a Jesus Cristo antes da fundação do mundo (Efésios 1 e Romanos 8).', 
     'video', 'https://www.youtube.com/watch?v=ScMzIvxBSi4', 'O Propósito Eterno', 'Doutrina Central', now() - INTERVAL '30 days'),
    
    (m_res_id2, 'Caderno de Estudo 01: Fundamentos do Propósito Eterno', 
     'Apostila em PDF com referências bíblicas, roteiro de leitura em família e perguntas reflexivas para o discipulado.', 
     'pdf', '/documents/caderno-estudo-01-proposito-eterno.pdf', 'O Propósito Eterno', 'Catequese', now() - INTERVAL '28 days'),

    (m_res_id3, 'Artigo: A Centralidade de Cristo e o Fim da Religiosidade', 
     'Texto meditativo abordando a distinção entre a salvação como meio e a conformidade a Cristo como o objetivo final.', 
     'markdown', 'https://raw.githubusercontent.com/markdown-it/markdown-it/master/README.md', 'O Propósito Eterno', 'Artigo Teológico', now() - INTERVAL '25 days'),

    (m_res_id4, 'Juntas e Ligamentos: Discipulado Vida na Vida', 
     'Como a edificação orgânica acontece através de relacionamentos transparentes de prestação de contas, confissão e ensino mútuo.', 
     'video', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'Juntas e Ligamentos', 'Vida Comum', now() - INTERVAL '20 days'),

    (m_res_id5, 'Caderno de Estudo 02: Relacionamentos de Aliança e Cuidado Mútuo', 
     'Guia prático para reuniões de companheirismo entre discípulos e discipuladores.', 
     'pdf', '/documents/caderno-estudo-02-juntas-e-ligamentos.pdf', 'Juntas e Ligamentos', 'Catequese', now() - INTERVAL '18 days'),

    (m_res_id6, 'O Sacerdócio Universal de Todos os Santos', 
     'Princípios do Novo Testamento que desmistificam a divisão clero/leigo. Todos os discípulos são sacerdotes e ministros em serviço.', 
     'video', 'https://www.youtube.com/watch?v=ScMzIvxBSi4', 'Sacerdócio Universal', 'Eclesiologia Orgânica', now() - INTERVAL '15 days'),

    (m_res_id7, 'Artigo: A Igreja no Bairro e a Dinâmica nas Ruas', 
     'Evangelismo natural pelo testemunho pessoal e amor comunitário expresso na vida cotidiana de Belo Horizonte.', 
     'markdown', 'https://raw.githubusercontent.com/markdown-it/markdown-it/master/README.md', 'Sacerdócio Universal', 'Prática Comunitária', now() - INTERVAL '12 days'),

    (m_res_id8, 'Módulo 03: Prática do Evangelho do Reino nas Casas', 
     'Roteiro de compartilhamento do pão, oração e instrução bíblica mútua para os encontros domiciliares.', 
     'pdf', '/documents/caderno-apoio-evangelismo-natural.pdf', 'Sacerdócio Universal', 'Catequese', now() - INTERVAL '10 days'),

    (m_res_id9, 'Vídeo Institucional: Princípios do Reino e Descentralização', 
     'Palestra introdutória sobre autonomia dos grupos caseiros e serviço diaconal aos necessitados.', 
     'video', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'Vida do Reino', 'Prática Comunitária', now() - INTERVAL '8 days'),

    (m_res_id10, 'Caderno Geral: O Evangelho Segundo Jesus', 
     'Compilação de ensinos práticos dos quatro evangelhos com foco no arrependimento, fé e seguimento radical de Cristo.', 
     'pdf', '/documents/apostila-atos-dos-apostolos.pdf', 'Vida do Reino', 'Fundamentos', now() - INTERVAL '5 days');

  INSERT INTO public.studies (id, title, description, created_by, created_at)
  VALUES
    (study_id1, 'Trilha 1: O Propósito Eterno de Deus', 
     'Compreenda o plano original de Deus desde a eternidade: gerar uma família de muitos filhos que expressem plenamente a natureza e o caráter de Cristo Jesus na terra.', 
     fernando_id, now() - INTERVAL '30 days'),

    (study_id2, 'Trilha 2: Juntas e Ligamentos — O Discipulado Prático', 
     'A dinâmica bíblica de cuidado mútuo, prestação de contas amorosa e edificação diária onde todo santo é ativo na vida comunitária.', 
     fernando_id, now() - INTERVAL '20 days'),

    (study_id3, 'Trilha 3: O Sacerdócio Universal e a Dinâmica nas Casas', 
     'Descentralização, vida familiar nos bairros e operação viva de cada membro como sacerdote do Deus Altíssimo sem hierarquias sacerdotais humanas.', 
     gabriel_id, now() - INTERVAL '15 days');

  INSERT INTO public.study_steps (id, study_id, media_resource_id, sort_order, created_at)
  VALUES
    (step_id1, study_id1, m_res_id1, 1, now() - INTERVAL '30 days'),
    (step_id2, study_id1, m_res_id2, 2, now() - INTERVAL '29 days'),
    (step_id3, study_id1, m_res_id3, 3, now() - INTERVAL '28 days'),
    (step_id4, study_id2, m_res_id4, 1, now() - INTERVAL '20 days'),
    (step_id5, study_id2, m_res_id5, 2, now() - INTERVAL '19 days'),
    (step_id6, study_id3, m_res_id6, 1, now() - INTERVAL '15 days'),
    (step_id7, study_id3, m_res_id7, 2, now() - INTERVAL '14 days'),
    (step_id8, study_id3, m_res_id8, 3, now() - INTERVAL '13 days');

  -- Progresso de Gabriel Góes Braga
  INSERT INTO public.user_study_progress (profile_id, study_id, step_id, completed_at)
  VALUES 
    (gabriel_id, study_id1, step_id1, now() - INTERVAL '7 days'),
    (gabriel_id, study_id1, step_id2, now() - INTERVAL '5 days'),
    (gabriel_id, study_id1, step_id3, now() - INTERVAL '3 days'),
    (gabriel_id, study_id2, step_id4, now() - INTERVAL '1 day')
  ON CONFLICT DO NOTHING;

  INSERT INTO public.study_notes (profile_id, study_id, media_resource_id, title, content)
  VALUES 
    (gabriel_id, study_id1, m_res_id1, 'Meditação sobre Romanos 8:29', 'Deus predestinou Seus filhos para serem conformes à imagem de Seu Filho. Salvação é meio, filiação é objetivo.'),
    (gabriel_id, study_id2, m_res_id4, 'Anotações sobre Efésios 4:16', 'O corpo bem ajustado e consolidado pelo auxílio de todas as juntas segundo a justa cooperação de cada parte efetua o seu próprio aumento.');


  -- ==========================================================================
  -- 10. FORMULÁRIOS DINÂMICOS & SUBMISSÃO REAL
  -- ==========================================================================
  -- 9A. Formulário 1: Inscrição de Retiro de Solteiros
  INSERT INTO public.forms (id, name, description, fields, is_public, created_at, is_active)
  VALUES (
    'form-solteiros-2026',
    'Ficha de Inscrição Oficial - Retiro de Solteiros 2026',
    'Ficha oficial com informações básicas e logísticas para o Retiro de Solteiros.',
    '[
      {
        "id": "mandatory_full_name",
        "type": "text",
        "label": "Nome Completo",
        "placeholder": "Seu nome completo",
        "required": true,
        "helpText": "Nome do participante",
        "options": []
      },
      {
        "id": "mandatory_email",
        "type": "text",
        "label": "E-mail",
        "placeholder": "exemplo@email.com",
        "required": true,
        "helpText": "E-mail para envio de confirmação",
        "validationPreset": "email",
        "options": []
      },
      {
        "id": "mandatory_phone",
        "type": "text",
        "label": "Telefone / WhatsApp",
        "placeholder": "(31) 99999-9999",
        "required": true,
        "helpText": "Telefone com DDD",
        "validationPreset": "phone",
        "options": []
      },
      {
        "id": "mandatory_gender",
        "type": "select",
        "label": "Sexo / Gênero",
        "placeholder": "Selecione o sexo",
        "required": true,
        "helpText": "Para alocação de alojamentos",
        "options": ["Masculino", "Feminino"]
      },
      {
        "id": "mandatory_city_state",
        "type": "text",
        "label": "Cidade / Estado",
        "placeholder": "Belo Horizonte / MG",
        "required": true,
        "helpText": "Cidade e UF de residência",
        "options": []
      },
      {
        "id": "mandatory_birth_date",
        "type": "date",
        "label": "Data de Nascimento / Idade",
        "placeholder": "DD/MM/AAAA",
        "required": true,
        "helpText": "Data de nascimento",
        "options": []
      },
      {
        "id": "tamanho_camiseta",
        "type": "select",
        "label": "Tamanho da Camiseta",
        "placeholder": "Selecione o tamanho",
        "required": true,
        "helpText": "Camiseta oficial do retiro (+R$ 30,00)",
        "options": ["P", "M", "G", "GG"],
        "priceModifiers": { "P": 30, "M": 30, "G": 30, "GG": 30 }
      },
      {
        "id": "transporte",
        "type": "radio",
        "label": "Precisa de Transporte?",
        "placeholder": "",
        "required": true,
        "helpText": "Ônibus executivo da igreja na cidade (+R$ 40,00)",
        "options": ["Sim", "Não"],
        "priceModifiers": { "Sim": 40, "Não": 0 }
      },
      {
        "id": "restricoes_alimentares",
        "type": "text",
        "label": "Restrições Alimentares",
        "placeholder": "Alergias, intolerância à lactose, etc.",
        "required": false,
        "helpText": "Logística da cozinha",
        "options": []
      }
    ]'::jsonb,
    true, now(), true
  ) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, fields = EXCLUDED.fields;

  -- 9B. Formulário 2: Censo de Dons, Talentos e Apoio Mútuo
  INSERT INTO public.forms (id, name, description, fields, is_public, created_at, is_active)
  VALUES (
    'form-censo-dons',
    'Censo da Vida Comum: Dons, Habilidades e Apoio Mútuo',
    'Mapeamento de competências práticas, profissões e disposição de serviço mútuo para a edificação do Corpo.',
    '[
      {
        "id": "mandatory_full_name",
        "type": "text",
        "label": "Nome Completo",
        "placeholder": "Seu nome",
        "required": true,
        "options": []
      },
      {
        "id": "profissao_atual",
        "type": "text",
        "label": "Profissão ou Especialidade",
        "placeholder": "Ex: Eletricista, Enfermeiro, Marceneiro...",
        "required": true,
        "options": []
      },
      {
        "id": "habilidades_apoio",
        "type": "select",
        "label": "Área de Apoio Prático em que Posso Servir",
        "placeholder": "Selecione uma área",
        "required": true,
        "options": [
          "Culinária e Preparo de Alimentos em Eventos",
          "Reparos Elétricos e Hidráulicos",
          "Pintura e Pequenas Obras",
          "Cuidados de Enfermagem e Primeiros Socorros",
          "Transporte e Caronas Solidárias",
          "Música, Áudio e Sonorização",
          "Hospedagem de Irmãos em Trânsito"
        ]
      },
      {
        "id": "disponibilidade",
        "type": "radio",
        "label": "Disponibilidade Principal de Horário",
        "placeholder": "",
        "required": true,
        "options": ["Sábados pela manhã", "Dias úteis à noite", "Flexível para urgências"]
      },
      {
        "id": "observacoes",
        "type": "text",
        "label": "Outros Talentos ou Observações",
        "placeholder": "Compartilhe como gostaria de servir aos santos",
        "required": false,
        "options": []
      }
    ]'::jsonb,
    true, now() - INTERVAL '5 days', true
  ) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, fields = EXCLUDED.fields;

  -- 9C. Formulário 3: Ficha de Solicitação de Apoio Diaconal
  INSERT INTO public.forms (id, name, description, fields, is_public, created_at, is_active)
  VALUES (
    'form-apoio-diaconal',
    'Ficha de Apoio Diaconal e Necessidades Comuns',
    'Canal confidencial para comunicação de necessidades emergenciais e apoio às famílias.',
    '[
      {
        "id": "mandatory_full_name",
        "type": "text",
        "label": "Nome do Solicitante / Contato",
        "placeholder": "Seu nome ou de quem está comunicando",
        "required": true,
        "options": []
      },
      {
        "id": "grupo_caseiro",
        "type": "text",
        "label": "Grupo Caseiro / Setor",
        "placeholder": "Ex: GC São Gabriel, GC Eldorado...",
        "required": true,
        "options": []
      },
      {
        "id": "tipo_necessidade",
        "type": "select",
        "label": "Tipo de Necessidade",
        "placeholder": "Selecione o tipo",
        "required": true,
        "options": ["Alimentação / Cesta", "Remédios / Tratamento", "Reparo Emergencial de Moradia", "Auxílio Desemprego", "Outro"]
      },
      {
        "id": "urgencia",
        "type": "radio",
        "label": "Nível de Urgência",
        "placeholder": "",
        "required": true,
        "options": ["Alta (Até 48h)", "Média (Nesta semana)", "Planejada"]
      },
      {
        "id": "detalhes",
        "type": "text",
        "label": "Descrição da Situação",
        "placeholder": "Explique brevemente para a equipe de diáconos",
        "required": true,
        "options": []
      }
    ]'::jsonb,
    true, now() - INTERVAL '10 days', true
  ) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, fields = EXCLUDED.fields;

  -- 9D. Formulário 4: Inscrição de Retiro de Carnaval 2026
  INSERT INTO public.forms (id, name, description, fields, is_public, created_at, is_active)
  VALUES (
    'form-carnaval-2026',
    'Ficha de Inscrição Oficial - Retiro de Carnaval 2026',
    'Ficha oficial de inscrição e dados logísticos para o Retiro de Carnaval 2026 — O Propósito Eterno.',
    '[
      {
        "id": "mandatory_full_name",
        "type": "text",
        "label": "Nome Completo",
        "placeholder": "Seu nome completo",
        "required": true,
        "helpText": "Nome do participante",
        "options": []
      },
      {
        "id": "mandatory_email",
        "type": "text",
        "label": "E-mail",
        "placeholder": "exemplo@email.com",
        "required": true,
        "helpText": "E-mail para confirmação",
        "validationPreset": "email",
        "options": []
      },
      {
        "id": "mandatory_phone",
        "type": "text",
        "label": "Telefone / WhatsApp",
        "placeholder": "(31) 99999-9999",
        "required": true,
        "helpText": "Telefone com DDD",
        "validationPreset": "phone",
        "options": []
      },
      {
        "id": "mandatory_gender",
        "type": "select",
        "label": "Sexo / Gênero",
        "placeholder": "Selecione o sexo",
        "required": true,
        "helpText": "Para alocação de alojamentos",
        "options": ["Masculino", "Feminino"]
      },
      {
        "id": "mandatory_city_state",
        "type": "text",
        "label": "Cidade / Estado",
        "placeholder": "Belo Horizonte / MG",
        "required": true,
        "helpText": "Cidade e UF de residência",
        "options": []
      },
      {
        "id": "mandatory_birth_date",
        "type": "date",
        "label": "Data de Nascimento / Idade",
        "placeholder": "DD/MM/AAAA",
        "required": true,
        "helpText": "Data de nascimento",
        "options": []
      },
      {
        "id": "transporte",
        "type": "radio",
        "label": "Precisa de Transporte?",
        "placeholder": "",
        "required": false,
        "helpText": "Ônibus executivo da igreja (+R$ 30,00)",
        "options": ["Sim", "Não"],
        "priceModifiers": { "Sim": 30, "Não": 0 }
      },
      {
        "id": "restricoes_alimentares",
        "type": "text",
        "label": "Restrições Alimentares",
        "placeholder": "Alergias, intolerância à lactose, etc.",
        "required": false,
        "helpText": "Logística da cozinha",
        "options": []
      }
    ]'::jsonb,
    true, '2026-01-10 10:00:00+00'::timestamptz, true
  ) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, fields = EXCLUDED.fields;

  -- 9E. Formulário 5: Inscrição de Encontro Metropolitano de Casais 2026
  INSERT INTO public.forms (id, name, description, fields, is_public, created_at, is_active)
  VALUES (
    'form-casais-2026',
    'Ficha de Inscrição - Encontro Metropolitano de Casais 2026',
    'Ficha oficial com informações básicas do casal para o Encontro Metropolitano de Casais nas Casas.',
    '[
      {
        "id": "mandatory_full_name",
        "type": "text",
        "label": "Nome Completo (Responsável)",
        "placeholder": "Seu nome completo",
        "required": true,
        "helpText": "Nome do cônjuge responsável pelo preenchimento",
        "options": []
      },
      {
        "id": "mandatory_email",
        "type": "text",
        "label": "E-mail",
        "placeholder": "exemplo@email.com",
        "required": true,
        "helpText": "E-mail para envio de confirmações",
        "validationPreset": "email",
        "options": []
      },
      {
        "id": "mandatory_phone",
        "type": "text",
        "label": "Telefone / WhatsApp",
        "placeholder": "(31) 99999-9999",
        "required": true,
        "helpText": "Telefone com DDD",
        "validationPreset": "phone",
        "options": []
      },
      {
        "id": "mandatory_gender",
        "type": "select",
        "label": "Sexo / Gênero",
        "placeholder": "Selecione o sexo",
        "required": true,
        "options": ["Masculino", "Feminino"]
      },
      {
        "id": "mandatory_city_state",
        "type": "text",
        "label": "Cidade / Estado",
        "placeholder": "Belo Horizonte / MG",
        "required": true,
        "options": []
      },
      {
        "id": "mandatory_birth_date",
        "type": "date",
        "label": "Data de Nascimento / Idade",
        "placeholder": "DD/MM/AAAA",
        "required": true,
        "options": []
      },
      {
        "id": "nome_conjuge",
        "type": "text",
        "label": "Nome Completo do Cônjuge",
        "placeholder": "Nome completo do esposo/esposa",
        "required": true,
        "helpText": "Para credenciamento e crachás do casal",
        "options": []
      },
      {
        "id": "tempo_casamento",
        "type": "select",
        "label": "Tempo de Casamento",
        "placeholder": "Selecione o tempo",
        "required": true,
        "options": ["Menos de 2 anos", "2 a 5 anos", "6 a 10 anos", "11 a 20 anos", "Mais de 20 anos"]
      },
      {
        "id": "restricoes_alimentares",
        "type": "text",
        "label": "Restrições Alimentares do Casal",
        "placeholder": "Alergias, restrições médicas, etc.",
        "required": false,
        "options": []
      }
    ]'::jsonb,
    true, now() - INTERVAL '3 days', true
  ) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, fields = EXCLUDED.fields;

  -- Submissão de Gabriel Góes Braga para o Censo da Vida Comum
  INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
  VALUES (
    'sub-censo-gabriel',
    'form-censo-dons',
    jsonb_build_object(
      'mandatory_full_name', 'Gabriel Góes Braga',
      'profissao_atual', 'Desenvolvedor de Software',
      'habilidades_apoio', 'Desenvolvimento Web, Sistemas e TI',
      'disponibilidade', 'Sábados pela manhã e noites',
      'observacoes', 'Disponível para apoiar no portal e suporte de TI da igreja.'
    ),
    gabriel_auth_id,
    now() - INTERVAL '2 days'
  ) ON CONFLICT (id) DO NOTHING;


  -- ==========================================================================
  -- 11. CICLO COMPLETO DE EVENTOS & RETIROS
  -- ==========================================================================
  INSERT INTO public.retreats (
    id, title, price, start_date, end_date, description, location_text, max_participants, status, registration_deadline, form_id
  ) VALUES (
    r_retreat_active,
    'Retiro de Solteiros e Jovens 2026',
    350.00,
    '2026-10-10',
    '2026-10-12',
    'Um tempo precioso de reflexão, imersão na palavra e comunhão intensa para todos os jovens e adultos solteiros das nossas comunidades em Belo Horizonte, Contagem e Betim.',
    'Sítio das Palmeiras, Santa Luzia, MG',
    150,
    'ativo',
    '2026-10-05',
    'form-solteiros-2026'
  ) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, form_id = EXCLUDED.form_id;

  INSERT INTO public.retreat_rooms (id, retreat_id, name, gender_type, capacity, notes) VALUES
    (r_act_chale_m1, r_retreat_active, 'Chalé Aliança 01', 'masculino', 10, 'Próximo ao campo de futebol'),
    (r_act_chale_m2, r_retreat_active, 'Chalé Aliança 02', 'masculino', 10, 'Próximo ao refeitório'),
    (r_act_dorm_m3,  r_retreat_active, 'Dormitório Varão 03', 'masculino', 12, 'Beliches duplos'),
    (r_act_chale_f1, r_retreat_active, 'Chalé Graciosa 01', 'feminino', 10, 'Com ar condicionado'),
    (r_act_chale_f2, r_retreat_active, 'Chalé Graciosa 02', 'feminino', 10, 'Próximo ao auditório principal'),
    (r_act_dorm_f3,  r_retreat_active, 'Dormitório Serva 03', 'feminino', 12, 'Próximo à piscina'),
    (r_act_suite_1,  r_retreat_active, 'Suíte Master 01', 'suite', 4, 'Banheiro privativo e frigobar'),
    (r_act_suite_2,  r_retreat_active, 'Suíte Master 02', 'suite', 4, 'Cama de casal e duas de solteiro');

  INSERT INTO public.retreat_expenses (retreat_id, description, category, amount, expense_date, notes) VALUES
    (r_retreat_active, 'Aluguel do Sítio das Palmeiras (3 dias)', 'local', 8500.00, '2026-09-01', 'Sinal de 50% já pago'),
    (r_retreat_active, 'Buffet & Alimentação Completa', 'alimentacao', 5200.00, '2026-09-05', 'Café, almoço e jantar para 120 pessoas'),
    (r_retreat_active, 'Fretamento de Ônibus Executivo (2 ônibus)', 'transporte', 1800.00, '2026-09-10', 'Empresa TransTurismo BH'),
    (r_retreat_active, 'Equipamento de Som e Iluminação', 'som_multimidia', 1200.00, '2026-09-12', 'Mesa de som, microfones e iluminação LED'),
    (r_retreat_active, 'Kits de Boas-Vindas & Canetas', 'outros', 600.00, '2026-09-15', 'Blocos de anotações e canetas gravadas'),
    (r_retreat_active, 'Materiais de Apoio & Crachás', 'material', 450.00, '2026-09-18', 'Impressão de pulseiras e crachás');

  -- Retiro 2: Carnaval (Encerrado)
  INSERT INTO public.retreats (
    id, title, price, start_date, end_date, description, location_text, max_participants, status, registration_deadline, form_id
  ) VALUES (
    r_retreat_closed,
    'Retiro de Carnaval 2026 — O Propósito Eterno',
    300.00,
    '2026-02-14',
    '2026-02-17',
    'Encontro anual de edificação da igreja na cidade durante o feriado de carnaval. Tempos ricos de convivência, estudo bíblico e fortalecimento das alianças.',
    'Recanto da Serra, Betim, MG',
    100,
    'encerrado',
    '2026-02-05',
    'form-carnaval-2026'
  ) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, form_id = EXCLUDED.form_id;

  INSERT INTO public.retreat_rooms (id, retreat_id, name, gender_type, capacity, notes) VALUES
    (r_cls_dorm_m1,  r_retreat_closed, 'Alojamento Getsêmani', 'masculino', 25, 'Ala masculina'),
    (r_cls_dorm_f1,  r_retreat_closed, 'Alojamento Betânia', 'feminino', 25, 'Ala feminina'),
    (r_cls_chale_m2, r_retreat_closed, 'Chalé Oliveiras M', 'masculino', 15, 'Irmãos solteiros'),
    (r_cls_chale_f2, r_retreat_closed, 'Chalé Oliveiras F', 'feminino', 15, 'Irmãs solteiras'),
    (r_cls_suite_1,  r_retreat_closed, 'Suíte Família A', 'familia', 6, 'Família com crianças'),
    (r_cls_suite_2,  r_retreat_closed, 'Suíte Família B', 'suite', 4, 'Idosos e apoio');

  INSERT INTO public.retreat_expenses (retreat_id, description, category, amount, expense_date, notes) VALUES
    (r_retreat_closed, 'Locação do Recanto da Serra (4 diárias)', 'aluguel', 11000.00, '2026-02-01', 'Quitado integralmente'),
    (r_retreat_closed, 'Alimentação Completa (Café, Almoço e Jantar)', 'alimentacao', 7200.00, '2026-02-10', 'Buffet contratado'),
    (r_retreat_closed, 'Transporte Fretado 2 Vans e 1 Ônibus', 'transporte', 2400.00, '2026-02-12', 'Translado Betim e BH'),
    (r_retreat_closed, 'Apostilas Impressas e Crachás', 'material', 800.00, '2026-02-13', 'Gráfica Express'),
    (r_retreat_closed, 'Locação de Caixa Amplificada e Cabos', 'som', 1000.00, '2026-02-14', 'Equipamento extra de sonorização');

  -- Retiro 3: Casais (Rascunho)
  INSERT INTO public.retreats (
    id, title, price, start_date, end_date, description, location_text, max_participants, status, registration_deadline, form_id
  ) VALUES (
    r_retreat_draft,
    'Encontro Metropolitano de Casais nas Casas 2026',
    420.00,
    '2026-11-20',
    '2026-11-22',
    'Final de semana dedicado à edificação dos casamentos, fortalecimento dos lares e comunhão entre os casais de todos os Grupos Caseiros da cidade.',
    'Pousada Morada do Sol, Nova Lima, MG',
    60,
    'rascunho',
    '2026-11-05',
    'form-casais-2026'
  ) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, form_id = EXCLUDED.form_id;


  -- ==========================================================================
  -- 12. MURAL CENTRALIZADO DE NOTÍCIAS, ENCONTROS E AVISOS (13 Posts)
  -- Autores: Fernando Gomes Braga (Presbítero) e Gabriel Góes Braga (Dev)
  -- ==========================================================================
  INSERT INTO public.posts (
    author_id, category, title, content, is_public, is_published,
    event_start_date, event_end_date, event_location,
    media_resource_id, form_id, retreat_id, event_label,
    image_urls, created_at
  ) VALUES 
    -- 1. Geral / Notícia Central (Pública)
    (fernando_id, 'geral', 'Caminhando em Família: Bem-vindos à Igreja em Belo Horizonte',
     'Uma igreja simples, nas casas e pelas ruas de Belo Horizonte, Contagem e Betim. Não temos templos ou clero: somos discípulos de Cristo vivendo em comunhão, edificando uns aos outros e buscando expressar o amor do Pai em nossos bairros.',
     true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     ARRAY['https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '5 days'),

    -- 2. Geral / Diaconia (Interna)
    (gabriel_id, 'geral', 'Mutirão Diaconal de Apoio na Região São Gabriel',
     'Graça e paz, irmãos! No próximo sábado faremos um mutirão de reparos e pintura na casa de uma família assistida no São Gabriel. Quem tiver ferramentas simples (espátula, rolo de pintura, lixas) favor trazer. O almoço comunitário será preparado pelas irmãs no local.',
     false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     ARRAY['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '2 days'),

    -- 3. Oração (Interna)
    (fernando_id, 'oracao', 'Clamor e Intercessão pela Saúde dos Irmãos Idosos e Gestantes',
     'Lembramos toda a igreja de sustentar em oração os nossos irmãos e irmãs mais idosos que têm enfrentado desafios de saúde neste período, assim como as três gestantes que se aproximam do parto. Orem em suas casas e nos encontros semanais dos Grupos Caseiros.',
     false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, now() - INTERVAL '3 days'),

    -- 4. Missões / Evangelismo (Pública)
    (fernando_id, 'missoes', 'Evangelismo Natural e Testemunho nas Universidades e Ruas',
     'Compartilhamos com alegria os frutos do evangelismo despretensioso na Praça da Liberdade e arredores da UFMG. Vários jovens universitários abriram seus corações para o Evangelho e iniciaram conversas de discipulado!',
     true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     ARRAY['https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '4 days'),

    -- 5. Encontro Casual na Cidade (Público)
    (fernando_id, 'encontro', 'Encontro Geral de Louvor e Piquenique no Parque Municipal',
     'Neste domingo nos reuniremos ao ar livre no Parque Municipal de Belo Horizonte para um tempo especial de louvor, oração coletiva e partilha do pão. Traga sua família, toalha de piquenique e algo para compartilhar!',
     true, true, (now() + INTERVAL '4 days' + INTERVAL '9 hours 30 minutes'), (now() + INTERVAL '4 days' + INTERVAL '13 hours'), 'Parque Municipal de Belo Horizonte (próximo ao Coreto)',
     NULL, NULL, NULL, NULL,
     ARRAY['https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '1 day'),

    -- 6. Encontro Casual na Cidade (Interno)
    (fernando_id, 'encontro', 'Vigília e Noite de Oração dos Discípulos',
     'Convocação fraternal para todos os irmãos que desejam buscar mais do Senhor. Teremos momentos de adoração espontânea, clamor pelos enfermos e proclamação da Palavra.',
     false, true, (now() + INTERVAL '8 days' + INTERVAL '22 hours'), (now() + INTERVAL '9 days' + INTERVAL '3 hours'), 'Casa dos irmãos em Venda Nova / Ribeirão das Neves',
     NULL, NULL, NULL, NULL, NULL, now() - INTERVAL '3 days'),

    -- 7. Estudo Vinculado (Público)
    (fernando_id, 'estudo', 'Novo Estudo Disponível: O Propósito Eterno de Deus',
     'Está liberado no módulo de Ensinos da plataforma a primeira etapa da Trilha 1 com vídeo bíblico e material em PDF. Acesse pelo menu principal ou clique no link do estudo abaixo.',
     true, true, NULL, NULL, NULL, m_res_id1, NULL, NULL, 'Trilha 1: O Propósito Eterno de Deus', NULL, now() - INTERVAL '6 days'),

    -- 8. Estudo Vinculado (Interno)
    (fernando_id, 'estudo', 'Material de Discipulado: Juntas e Ligamentos Vida na Vida',
     'Recomendamos fortemente a todos os discipuladores e duplas de companheirismo a leitura do Caderno de Estudo 02. O material traz perguntas profundas de reflexão e transparência mútua.',
     false, true, NULL, NULL, NULL, m_res_id5, NULL, NULL, 'Trilha 2: Juntas e Ligamentos', NULL, now() - INTERVAL '4 days'),

    -- 9. Formulário Vinculado (Interno)
    (gabriel_id, 'formulario', 'Censo da Vida Comum: Mapeamento de Dons e Vocações',
     'Irmãos amados, pedimos a colaboração de todos para preencher a nossa ficha do Censo da Vida Comum. O objetivo não é criar ministérios institucionais, mas identificar os dons de serviço concedidos pelo Espírito.',
     false, true, NULL, NULL, NULL, NULL, 'form-censo-dons', NULL, 'Censo da Vida Comum', NULL, now() - INTERVAL '6 days'),

    -- 10. Formulário Vinculado (Público)
    (fernando_id, 'formulario', 'Canal Confidencial de Apoio Fraterno e Diaconal',
     'Se você ou alguma família do seu Grupo Caseiro está passando por necessidades materiais emergenciais, registre no formulário diaconal.',
     true, true, NULL, NULL, NULL, NULL, 'form-apoio-diaconal', NULL, 'Apoio Diaconal', NULL, now() - INTERVAL '5 days'),

    -- 11. Evento Vinculado: Vagas Abertas (Público)
    (fernando_id, 'evento', 'Inscrições Abertas: Retiro de Solteiros e Jovens 2026',
     'Estão oficialmente abertas as inscrições para o nosso próximo retiro em Santa Luzia! Serão 3 dias intensos de oração, estudo bíblico e edificação.',
     true, true, NULL, NULL, NULL, NULL, NULL, r_retreat_active, 'Retiro de Solteiros e Jovens 2026',
     ARRAY['https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '4 days'),

    -- 12. Evento Vinculado: Transporte e Caronas (Interno)
    (fernando_id, 'evento', 'Organização de Caronas Solidárias para o Retiro de Santa Luzia',
     'Para que ninguém deixe de ir ao retiro por falta de transporte, estamos organizando a malha de caronas solidárias por setor.',
     false, true, NULL, NULL, NULL, NULL, NULL, r_retreat_active, 'Caronas: Retiro de Solteiros 2026', NULL, now() - INTERVAL '2 days'),

    -- 13. Evento Vinculado: Oração e Preparação Espiritual (Público)
    (fernando_id, 'evento', 'Relatório e Gratidão: Frutos do Retiro de Carnaval 2026',
     'Louvamos a Deus pelos dias inesquecíveis que vivemos no Retiro de Carnaval no Recanto da Serra. Dezenas de novos convertidos foram batizados!',
     true, true, NULL, NULL, NULL, NULL, NULL, r_retreat_closed, 'Retiro de Carnaval 2026',
     ARRAY['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '12 days');


  -- ==========================================================================
  -- 13. CUPONS DE DESCONTO E LISTA DE ESPERA
  -- ==========================================================================
  INSERT INTO public.event_coupons (retreat_id, code, discount_percent, target_service_team, is_used, notes)
  VALUES 
    (r_retreat_active, 'LOUVOR100', 100, 'louvor', false, 'Isenção integral para equipe de louvor e instrumentos'),
    (r_retreat_active, 'DIACONIA50', 50, 'cozinha', false, 'Desconto especial para equipe voluntária da cozinha e apoio'),
    (r_retreat_active, 'JOVEM20', 20, 'geral', false, 'Cupom de incentivo aos jovens estudantes');


  -- ==========================================================================
  -- 14. INSCRIÇÕES OFICIAIS NOS RETIROS
  -- Nenhuma inscrição fictícia é gerada para discípulos das planilhas.
  -- Inscrição de Gabriel Góes Braga no Retiro de Solteiros e Carnaval.
  -- ==========================================================================
  
  -- Retiro Ativo (Solteiros e Jovens 2026)
  INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
  VALUES (
    'sub-gabriel-solteiros-real',
    'form-solteiros-2026',
    jsonb_build_object(
      'mandatory_full_name', 'Gabriel Góes Braga',
      'mandatory_email', 'ggoesbraga@gmail.com',
      'mandatory_phone', '(31) 99888-7777',
      'mandatory_gender', 'Masculino',
      'mandatory_city_state', 'Belo Horizonte / MG',
      'mandatory_birth_date', '2008-04-02',
      'tamanho_camiseta', 'G',
      'transporte', 'Não',
      'restricoes_alimentares', 'Nenhuma'
    ),
    gabriel_auth_id,
    now() - INTERVAL '2 days'
  ) ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.registrations (
    retreat_id, profile_id, paid, payment_method, payment_reference, created_at, form_submission_id,
    room_id, room_allocation, guest_data, custom_responses
  )
  VALUES (
    r_retreat_active,
    gabriel_id,
    true,
    'pix',
    'REF-GABRIEL-PIX-REAL-01',
    now() - INTERVAL '2 days',
    'sub-gabriel-solteiros-real',
    r_act_chale_m1,
    'Chalé Aliança 01',
    jsonb_build_object(
      'fullName', 'Gabriel Góes Braga', 'full_name', 'Gabriel Góes Braga',
      'email', 'ggoesbraga@gmail.com', 'phone', '(31) 99888-7777',
      'gender', 'Masculino', 'cityState', 'Belo Horizonte / MG', 'city_state', 'Belo Horizonte / MG',
      'birthDate', '2008-04-02'
    ),
    jsonb_build_object(
      'Nome Completo', 'Gabriel Góes Braga',
      'E-mail', 'ggoesbraga@gmail.com',
      'Telefone / WhatsApp', '(31) 99888-7777',
      'Sexo / Gênero', 'Masculino',
      'Cidade / Estado', 'Belo Horizonte / MG',
      'Data de Nascimento / Idade', '2008-04-02',
      'Tamanho da Camiseta', 'G',
      'Precisa de Transporte?', 'Não',
      'Restrições Alimentares', 'Nenhuma'
    )
  ) ON CONFLICT DO NOTHING;

  -- Retiro Encerrado (Carnaval 2026)
  INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
  VALUES (
    'sub-gabriel-carnaval-real',
    'form-carnaval-2026',
    jsonb_build_object(
      'mandatory_full_name', 'Gabriel Góes Braga',
      'mandatory_email', 'ggoesbraga@gmail.com',
      'mandatory_phone', '(31) 99888-7777',
      'mandatory_gender', 'Masculino',
      'mandatory_city_state', 'Belo Horizonte / MG',
      'mandatory_birth_date', '2008-04-02'
    ),
    gabriel_auth_id,
    now() - INTERVAL '240 days'
  ) ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.registrations (
    retreat_id, profile_id, paid, payment_method, payment_reference, created_at, form_submission_id,
    room_id, room_allocation, guest_data, custom_responses
  )
  VALUES (
    r_retreat_closed,
    gabriel_id,
    true,
    'pix',
    'REF-GABRIEL-PIX-REAL-02',
    now() - INTERVAL '240 days',
    'sub-gabriel-carnaval-real',
    r_cls_dorm_m1,
    'Alojamento Getsêmani',
    jsonb_build_object(
      'fullName', 'Gabriel Góes Braga', 'full_name', 'Gabriel Góes Braga',
      'email', 'ggoesbraga@gmail.com', 'phone', '(31) 99888-7777',
      'gender', 'Masculino', 'cityState', 'Belo Horizonte / MG', 'city_state', 'Belo Horizonte / MG',
      'birthDate', '2008-04-02'
    ),
    jsonb_build_object(
      'Nome Completo', 'Gabriel Góes Braga',
      'Sexo / Gênero', 'Masculino',
      'E-mail', 'ggoesbraga@gmail.com',
      'Telefone / WhatsApp', '(31) 99888-7777',
      'Data de Nascimento / Idade', '2008-04-02'
    )
  ) ON CONFLICT DO NOTHING;

END $$;
