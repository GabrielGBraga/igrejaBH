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
  gabriel_id   uuid := '78f2aca3-0542-4105-b741-549a54be30ff';
  fernando_id  uuid := '76385bbe-a540-4638-8013-609b49a6a2fe';
  clara_id     uuid := 'd490eba5-fbb2-4281-9777-d8226e71aa9f';
  flavio_id    uuid := '32b950d9-6474-4e1e-a513-555280617278';
  marleide_id  uuid := '9c9ad423-9cd4-46c8-acd4-05e1053d9896';

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

  INSERT INTO public.sectors (id, name, created_at) VALUES ('9ba41bb8-bf08-4c36-80a9-c2a14601c01f', 'São Gabriel/Pampulha', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('f0e10612-68c5-42ba-8128-71ab7cc963b2', 'Venda Nova/Neves', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('644b16f0-ecae-498b-a286-50b458bb170b', 'Santa Luzia', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('b41b6cf5-7aeb-4696-9ba0-b92040827e76', 'Oeste', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('df335314-1c68-4a93-af0e-161be81a1cf4', 'Betim/Contagem', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('1b101594-bab6-46b5-916a-d84f355bab3f', 'Fora da Localidade', now());

  -- ==========================================================================
  -- 3. CRIAÇÃO DOS GRUPOS CASEIROS (35 Grupos Reais das Planilhas)
  -- ==========================================================================

  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', '9ba41bb8-bf08-4c36-80a9-c2a14601c01f', 'Solimões - BH - Bairro Solimões', 2, '19:30:00', -19.8392, -43.9185, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '00500a12-bfa8-4555-94e1-aeb4ab033573', '9ba41bb8-bf08-4c36-80a9-c2a14601c01f', 'Heliópolis - BH - Bairro Heliópolis', 3, '19:30:00', -19.8425, -43.9482, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '789dae9f-84df-4b2f-b4be-473752444c8f', '9ba41bb8-bf08-4c36-80a9-c2a14601c01f', 'São Gabriel - BH - Região São Gabriel / Pampulha', 4, '19:30:00', -19.858, -43.916, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', '9ba41bb8-bf08-4c36-80a9-c2a14601c01f', 'Santa Amélia - BH - Rua Pioneiros da Paz, Santa Amélia / Rua Hildebrando de Oliveira 65, Copacabana', 5, '19:30:00', -19.8361, -43.9724, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', '9ba41bb8-bf08-4c36-80a9-c2a14601c01f', 'Jardim Vitória - BH - Bairro Vitória / Jardim Vitória', 6, '19:30:00', -19.8456, -43.8891, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', 'f0e10612-68c5-42ba-8128-71ab7cc963b2', 'Santa Branca - BH - Rua Norte, 42, Santa Branca - BH', 2, '19:30:00', -19.8268, -43.9685, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', 'f0e10612-68c5-42ba-8128-71ab7cc963b2', 'Santa Branca - BH - Rua São José do Jacuri, 135, B. Santa Branca', 3, '19:30:00', -19.8245, -43.966, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', 'f0e10612-68c5-42ba-8128-71ab7cc963b2', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 (Casa do Marinho) - Maria Helena', 4, '19:30:00', -19.7985, -44.0092, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', 'f0e10612-68c5-42ba-8128-71ab7cc963b2', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 - Maria Helena', 5, '19:30:00', -19.7992, -44.0105, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '09782827-90f8-404c-9018-2308258a795c', 'f0e10612-68c5-42ba-8128-71ab7cc963b2', 'Leblon - BH - Rua Olga Pimenta Guimarães, 204 - Leblon', 6, '19:30:00', -19.8115, -43.988, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '2764260c-e49f-4cbd-9daa-0803989641d3', 'f0e10612-68c5-42ba-8128-71ab7cc963b2', 'Sevilha B - Ribeirão das Neves - Rua São João Del Rei, 270, Sevilha B', 2, '19:30:00', -19.7695, -44.0812, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'baa7dafb-99d5-4812-bc48-3b5642a82365', 'f0e10612-68c5-42ba-8128-71ab7cc963b2', 'Areias - Ribeirão das Neves - Rodízio (Areias / Morro Alto)', 3, '19:30:00', -19.782, -43.985, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', '644b16f0-ecae-498b-a286-50b458bb170b', 'Santa Matilde - Santa Luzia - Rua Geraldo Ferreira Rabelo, 169, Santa Matilde', 4, '19:30:00', -19.7668, -43.8582, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', '644b16f0-ecae-498b-a286-50b458bb170b', 'Lagoa Santa - Lagoa Santa', 5, '19:30:00', -19.6328, -43.8906, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e86669d4-fd46-4053-b003-b2e19603ab3c', '644b16f0-ecae-498b-a286-50b458bb170b', 'São Benedito - Santa Luzia - Bairro São Benedito', 6, '19:30:00', -19.7825, -43.9145, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', '644b16f0-ecae-498b-a286-50b458bb170b', 'Fazendinha do Baú - Santa Luzia - Rua Presidente Roosevelt, 1107 - Fazendinha do Baú - Santa Luzia', 2, '19:30:00', -19.7755, -43.872, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', '644b16f0-ecae-498b-a286-50b458bb170b', 'Córrego das Calçadas - Santa Luzia - Av. Engenheiro Felipe Gabrich, nº 734, Córrego das Calçadas, Santa Luzia', 3, '19:30:00', -19.759, -43.851, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', '644b16f0-ecae-498b-a286-50b458bb170b', 'Cristina B - Santa Luzia - Rua Mila Bernardina da Rocha, 85, Cristina B, Santa Luzia/MG', 4, '19:30:00', -19.7762, -43.9248, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '38438326-8b6f-41e4-894f-5514e834a762', 'b41b6cf5-7aeb-4696-9ba0-b92040827e76', 'Novo Tirol - BH - Rua Macadâmia, 168, Novo Tirol - BH', 5, '19:30:00', -19.9985, -44.0315, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', 'b41b6cf5-7aeb-4696-9ba0-b92040827e76', 'Milionários - BH - Rua dos Atleticanos - Milionários', 6, '19:30:00', -19.981, -43.9965, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', 'b41b6cf5-7aeb-4696-9ba0-b92040827e76', 'Tropical / Quintas do Jacuba - Contagem - Estrada Chico Mendes, 900 - Quintas do Jacuba - Contagem', 2, '19:30:00', -19.9265, -44.115, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', 'b41b6cf5-7aeb-4696-9ba0-b92040827e76', 'Novo Progresso - Contagem - Rua Paraopeba, 184, Novo Progresso', 3, '19:30:00', -19.898, -44.039, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '64791204-ba0c-4881-b13f-f14d2ceeac20', 'b41b6cf5-7aeb-4696-9ba0-b92040827e76', 'Bela Vista / Barreiro - Ibirité - Rua Melo de Souza Maia, 101, Bela Vista', 4, '19:30:00', -20.008, -44.052, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'bf4cb59b-2698-4530-aeb4-fb4522387152', 'b41b6cf5-7aeb-4696-9ba0-b92040827e76', 'Salgado Filho - BH - Rua Ibiraci, 250 - Bairro Salgado Filho - BH', 5, '19:30:00', -19.9412, -43.9825, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', 'b41b6cf5-7aeb-4696-9ba0-b92040827e76', 'Nova Suíça - BH - Rua Lindolfo de Azevedo, 608, Nova Suíça - BH', 6, '19:30:00', -19.9445, -43.9734, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '03acbb31-1865-4ed9-be93-b16da9be65b2', 'df335314-1c68-4a93-af0e-161be81a1cf4', 'São José - Esmeraldas - Rua Américo França Abreu, 257, São José, Esmeraldas', 2, '19:30:00', -19.7615, -44.314, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', 'df335314-1c68-4a93-af0e-161be81a1cf4', 'Jardim Riacho das Pedras - Contagem - Rua Urânio, 114, Jardim Riacho das Pedras - Contagem', 3, '19:30:00', -19.9565, -44.041, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '827ab195-4359-478b-9826-17dc7c69f545', 'df335314-1c68-4a93-af0e-161be81a1cf4', 'Marimbá - Betim - Sítio da Igreja (Marimbá / Juatuba)', 4, '19:30:00', -19.932, -44.275, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', 'df335314-1c68-4a93-af0e-161be81a1cf4', 'Resplendor - Igarapé - Rua Bahia, 131, Resplendor - Igarapé', 5, '19:30:00', -20.068, -44.298, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '66077532-f18c-43b8-b205-adb8eb21dca1', 'df335314-1c68-4a93-af0e-161be81a1cf4', 'Jardim Alterosa / Santo Antônio - Betim - Rua Limoeiro, 337, Santo Antônio - Betim', 6, '19:30:00', -19.961, -44.172, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '83f01f9e-4107-42e2-83ee-a37cef34f184', 'df335314-1c68-4a93-af0e-161be81a1cf4', 'Três Barras - Contagem - Rua Gentil Diniz, 441 - Três Barras - Contagem', 2, '19:30:00', -19.9145, -44.0885, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '4320d5da-ec05-4d97-9118-03d326fae3e2', 'df335314-1c68-4a93-af0e-161be81a1cf4', 'Eldorado - Contagem - Rua José Barra do Nascimento, 1971, Eldorado - Contagem', 3, '19:30:00', -19.938, -44.0395, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '04a6bc60-55cd-4da5-9512-4b2be231863e', 'df335314-1c68-4a93-af0e-161be81a1cf4', 'Ponte Alta - Betim - Condomínio Ouro Verde, Bairro Ponte Alta - Betim', 4, '19:30:00', -19.896, -44.203, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db', '1b101594-bab6-46b5-916a-d84f355bab3f', 'Interlagos - Sete Lagoas - Rua Antônio Domingos da Silva Filho, 307, B. Interlagos - Sete Lagoas', 5, '19:30:00', -19.4752, -44.2368, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'f607a18b-e503-4039-a662-51ac41abfff9', '1b101594-bab6-46b5-916a-d84f355bab3f', 'Santa Bárbara - Santa Bárbara / Barão de Cocais', 6, '19:30:00', -19.9595, -43.415, now()
  );

  -- ==========================================================================
  -- 4. POVOAMENTO DOS DISCÍPULOS (821 Perfis Reais das Planilhas)
  -- Somente Gabriel, Fernando e Clara recebem dados de contato/autenticação.
  -- Os demais 818 discípulos são armazenados puramente como phantom users / crianças.
  -- ==========================================================================

  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd10f39b4-92c7-4967-9a82-69ad771457a1', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', 'Solimões', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Presbitério', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9c9ad423-9cd4-46c8-acd4-05e1053d9896', 'Marleide', NULL, NULL, NULL, NULL, NULL, 'F',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', 'Solimões', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Esposas dos Presb.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '69eecf4a-7ba6-4c53-be51-ed9d202715e8', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Solteiro(a)', 'Solimões', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9bc168a1-d18c-4adf-bc64-805ee05ec8c0', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Solteiro(a)', 'Solimões', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Karina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ed56e011-a066-49c8-8233-e3b5f50140af', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, 'M',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a52a6748-767f-4c5d-b6c4-3cd96572cd59', 'Soely', NULL, NULL, NULL, NULL, NULL, 'F',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '57d74b4b-3280-497a-87fc-9929e70eddcd', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b48c1d94-9e72-445b-b469-4a2c00a74e99', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '266c8e68-4192-47a8-9f1e-10708d388e54', 'Euller', NULL, NULL, NULL, NULL, NULL, 'M',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2092d89f-7c41-4cde-9666-72db932250e5', 'Wellington', NULL, NULL, NULL, NULL, NULL, 'M',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2c08372b-4163-45f2-b106-ee4fe57cd0c9', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18199521-b88c-45ba-8973-194040fe970b', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Wellington', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6b604757-d4ef-40d7-beb0-514888126d1e', 'Joana', NULL, NULL, NULL, NULL, NULL, 'F',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luciana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '581bef00-4815-40fa-b731-7152debcbc7c', 'Agatha', NULL, NULL, NULL, NULL, NULL, 'F',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd5fcc2c3-8eab-4c2d-8d30-973ee2af3b11', 'Mariângela', NULL, NULL, NULL, NULL, NULL, 'F',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cinara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '81d39675-8c42-4015-919e-ded8f919ecbb', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    '4650dacd-e1f8-4f2c-a11a-47da76f39fea', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6717d16b-3add-4977-a824-a9c6bc2f9c13', 'André', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f1acb2a6-60ed-43ca-927b-7737c7a799b5', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '95da0514-9444-4f29-a788-9d782b842895', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eaffce78-f113-4ead-aa0d-5ae9a8c5a110', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '133bfc28-1807-4762-9986-176a0ead795c', 'Elis', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '76385bbe-a540-4638-8013-609b49a6a2fe', 'Fernando Gomes Braga', 'fgb80@yahoo.com', NULL, NULL, '1980-07-18'::date, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, true, false, false, true,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd490eba5-fbb2-4281-9777-d8226e71aa9f', 'Clara Góes Braga', 'claradiscipula@gmail.com', NULL, NULL, '1983-06-16'::date, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '777363ae-fa07-4e54-b1dc-3a994e33839b', 'Artur', NULL, NULL, NULL, '2019-09-09'::date, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '78f2aca3-0542-4105-b741-549a54be30ff', 'Gabriel Góes Braga', 'ggoesbraga@gmail.com', NULL, NULL, '2008-04-02'::date, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, true, true,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '842cb647-a695-438e-bde3-21c1d435ed6b', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Liberdade', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '19ee4823-f87d-4aa2-b33b-513cbf18384c', 'Marina', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Liberdade', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7357b7aa-ec4c-4b46-ba88-83fe74926a5b', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Liberdade', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2a0a50f4-2b4e-474d-9e7d-13bbc4ce844a', 'Deia', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eb88342d-ad13-4b1a-9059-e5ff58db0ead', 'Marivaldo', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thiago Duarte', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8774e4d7-3520-464a-9ba9-3ef1d0c6e261', 'Luciene', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Boa Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Paulinha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0f0f28df-102c-4071-894e-389e41360cb1', 'Ramon', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Ouro Preto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a23f3eb2-c9e5-495b-84c3-ecc4670bcb26', 'Margareth', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Ouro Preto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c163c8a6-d96f-4980-8242-fe3e94f85fb7', 'Renan', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Itapuã', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '93ce9392-ac77-4f5b-a4a0-bc3fa8ee0644', 'Arlete', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Itapuã', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '075eabfb-81bd-4211-a4dd-a20b3e7fed47', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '451700ce-7eff-49d7-a787-f99a9eda2f8e', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '885c1205-df30-4b76-a404-4f78abeda3d4', 'Cecília', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91aac336-92ac-4490-9c85-14d3830fdf9b', 'Hugo', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6ed4afbd-1081-4c81-be12-f03628822bba', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Dona Clara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1dc0ac57-4bbb-46b5-abae-938828807b02', 'Sarah', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Dona Clara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '30999b0d-f37c-45f2-99ba-67f30e20a4bb', 'Matheus', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Dona Clara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6c852113-aeb7-44a8-b6df-e73b57f27071', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Dona Clara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e6345948-7ca7-407a-974e-d3b256c02a01', 'Marlon', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1989e812-e291-4e83-89b3-b848aef84570', 'Maura', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Santa Cruz', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dc8f98f8-306b-47ce-b650-645fed3c2f65', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd9431731-50c0-44f2-947d-dc88a309b3d6', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '30039d06-4756-40f8-8d7d-2a91466fc5b9', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1b10c655-7452-4b91-820e-4b4a47fe12f6', 'Zoraide', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Santa Cruz', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bff3470a-e860-4fe7-b1c1-d58e3f82b33b', 'Miriã', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Ouro Preto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '60bda50a-fc5d-4436-9034-234fc4200356', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Maria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2020229d-7979-4cbb-8fab-f021f18b825e', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18cbb5f8-0567-41a9-974b-1182d38942d5', 'Wanderlaine', NULL, NULL, NULL, NULL, NULL, 'F',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Casado(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Arlete', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b376daa3-36e7-4dae-80b5-03fad0badd10', 'Ismael', NULL, NULL, NULL, NULL, NULL, 'M',
    '00500a12-bfa8-4555-94e1-aeb4ab033573', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fransérgio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a3c9a07c-017c-4c35-a164-9fca6da79b4c', 'Emerson', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '70d7271f-0612-4434-9bab-d8c5ad38bb86', 'Neide', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '094adf18-1186-4802-a0c2-01852547ca63', 'Walace', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8103138f-6084-4eb2-b852-be3d55cd19ba', 'Sabrina', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '13f92f18-e27a-409d-a2a6-461e2da8ef4b', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7581ff85-77d8-4f7e-8f48-2ef15f39fa7c', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '38644b54-ac21-4bfd-8444-85619f985a83', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ee51a38f-1fa5-4a3a-bf56-403db185980b', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2bf1deac-98cb-43ab-878e-aa8d559cca75', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '584fa9fb-c171-46f5-8196-1a056d89527b', 'Cristina', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '31ca95d0-c658-4dc9-8116-8048726048f3', 'Tales', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '88505968-39c9-4785-aa66-1eed08165c32', 'Edna', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dbb46454-9eff-4e9e-85e0-46b10d664ade', 'Thiago', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8f2c7cd0-dc24-4fcd-8da5-7c8f18af2f26', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '62cdd14f-499e-4fd7-bfc8-60c7d79eca68', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '02bf68cb-e556-4b65-a89e-7b236d235693', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eb49b757-df17-400b-ae00-8e0cd3397de1', 'Carlos Eduardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '77da84a6-4557-4582-a4ca-5d11246e5e99', 'Joelma', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9bd2e2fa-4e02-4ece-aaa4-3fcf13265ebf', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1ed2f9fb-b2d6-4bbb-8d52-56e641fb9048', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b2dff33d-b4b7-41d5-94e5-d2a8f8516d93', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a573ee8c-e8c2-4501-b484-dfef25e04a6c', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '299d81b7-08b1-4fa6-b026-f45a65c684e0', 'Grace', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9c9f8af5-87de-4405-b5cb-32d8b6d5b2ab', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9cb51b1b-c865-4d6e-a6c9-29730d247a65', 'Lutero', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8bcec8d5-0fdf-402d-a963-61de788fc967', 'Dominique', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bb6baa23-618f-484f-ae33-349e641e8d19', 'Kaleu', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd256d873-e62b-48a5-b174-58f2cfefd55b', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8b5b308b-d51a-49de-b525-694ddb924372', 'Marilda', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f10adea6-2436-468e-b214-937f20a4e094', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1681cb6a-b484-4030-bfb1-b33aea39ca9d', 'Enzo', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9029c57c-8190-40e6-bf07-a46caa76baa2', 'Daniele', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '86e61bad-d320-4bfc-9941-f61b6fae964c', 'Luciene', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'efa67ef3-8431-4adf-817b-3485bdf5526e', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '86c3cf40-e6be-4004-a67b-30a8e1bc6801', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '930c2e88-4c8c-46bc-8e28-da953c85e383', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '072a6edb-b5df-4906-80d0-b9dac1e96fe2', 'Antonela', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3b4775c4-d7d4-43c2-8153-52345ac65971', 'Luiz Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'df674479-c6c1-4105-afe0-1b5f1660954e', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '529addb2-b920-40b8-ab0d-e2a56ac50201', 'Amélia', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '135eb50a-71cd-4534-8edc-4d70e441f992', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9471ce5d-592b-43a5-b642-eca9376ade77', 'Tamara', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd601c038-8bef-439d-8abd-8e441694e063', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '54b85487-74c4-47fc-9a54-4a7ad7440ce2', 'Ciça', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9107e676-25c7-447b-a76a-225065d0f7e3', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f51523ee-bb76-4f72-8888-6b2188619b51', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0a426482-c3d2-410c-97bc-d99ba99739dc', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    '789dae9f-84df-4b2f-b4be-473752444c8f', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd1952ca6-0fc8-4d25-bb5c-27e539f5e1eb', 'Eduardo Lopes', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '70215bab-9e3d-4a7c-94e4-762e1a164792', 'Érica Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8d3c3b62-5639-4c6d-9645-1568a467d2b2', 'Laura Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '180da680-795d-4398-94f2-51382ef42017', 'Eduardo Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '65ae8c33-5a09-4085-85fd-a55a5c03a3c6', 'Luís Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e3186275-49bc-4908-8bb0-1a703d6e04f4', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eduardo Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7e7eccaf-13ba-4a6e-8314-25a385bd99e1', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érica Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e1e0f36e-1be0-457a-974e-c655061d1b21', 'Henrique Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b376638a-df6f-42b7-bf6d-11e1567d00d4', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Santa Amélia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18a9e871-da19-4167-ae79-0a0f4d7ee177', 'Lucas Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eduardo Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8497d209-25dd-4c37-848a-71a5ce583a4e', 'Raíssa', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érica Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fa032bf6-7835-4f28-9033-62a4bfd4e0f9', 'Lian', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dbf1815b-7a91-4bf3-8df0-2101132816d0', 'Pietro', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2be9bae1-598f-4ef9-8bae-29c5b7f8ec75', 'Danilo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eduardo Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '91a31c18-cc8e-4cb8-ace6-1dba6277426c', 'Melry', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érica Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '90f386fd-e904-41a7-bcf9-66dc29d656cb', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '48e17972-1250-4cb9-b914-b784fbfd7d18', 'Sofia', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Xangrilá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '432d4817-9d00-43de-b3cb-980b6f076573', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Pedreiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Paulo Henrique', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '550512f2-af6c-4275-b162-28eaabd2f610', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Pedreiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juliana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '83c13cf4-fced-45c7-9049-119cb42d37de', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Pedreiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '55682a0b-aee3-41be-a884-db217e239e59', 'Josinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Pedreiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Paula Emanuela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'baa8946b-a7c8-4644-9ac0-60d4ee5b1fd8', 'Thiago Bombeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '92bcf7d0-2e22-43f6-a552-223cd710b0f4', 'Paula Emanuela', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '73f8b067-2e21-4311-93ef-7a2993707e6e', 'Ana Luiza', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Karina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '299032c6-38e3-4fcb-b55c-e4707d1f8a53', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ana Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ab07bca1-c5de-48db-879b-24c22123f0e8', 'Thiago Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Atlântico', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2f962c77-17f1-4a34-ab50-4a916dd3ea67', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Céu Azul', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érica Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a01be850-e0a9-43bc-a1fe-71a8fc25584a', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Céu Azul', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Didier', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2e5727d8-17e5-48e4-aa72-2730570ca9c7', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Céu Azul', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '738e96d7-e9b4-4ef0-ad0e-3fb8c58cb409', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Braúnas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eduardo Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e92ae35a-3b83-4244-be87-6c7b66a093e5', 'Miriã', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Casado(a)', 'Braúnas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Raíssa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a0b35b86-18dc-4430-b580-c4f3f70618cf', 'Nikole', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Braúnas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ana Luiza', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0b2e794b-3cba-4f4c-9075-ab23b13869df', 'Brenda', NULL, NULL, NULL, NULL, NULL, 'F',
    '5396eee2-7aa4-4f85-ba46-5941f198a06d', true, false, false, false, false,
    'Solteiro(a)', 'Santa Cruz', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '20537b91-617f-4d87-85b9-3ce0577c9b5c', 'Ademir', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '291c477b-a8b1-4b96-b0fe-464ffb3a657c', 'Janaína', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b00066d5-47c3-4988-95a3-763ee97d1a2d', 'Emanuela', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f5007e1f-aeb9-4d95-a9ee-4cc8932b947c', 'João Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f384022d-8284-4319-af6e-9fbe52e69d6f', 'Julião', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '859de62b-bf20-4d15-be6d-04ff434704ca', 'Darlene', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7973d621-acd9-4a74-a822-1786b5228c88', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7caabacf-7c91-46ec-a4a7-941888c13ff6', 'João Francisco', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Silas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '17f06228-eca9-4d91-8d81-b74b52d5e6a3', 'Ana Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Vitória', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8f015bf8-de81-46bc-a02e-0e3c73981164', 'Elias', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ademir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3fe1a147-3ca9-4bd0-8b52-7a37bfb4bc91', 'Fabiana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ademir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '419726d2-28e9-45b8-ada5-af16261fc6b8', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ba92a123-3194-4f2e-a414-50d373ddc563', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carla', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4f545f60-8a6c-46b3-98e7-5e9a9241b39c', 'Luiz Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ademir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a0eef8b7-9ebe-4f37-bfd7-da7af7b5af42', 'Jéssica', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd8343644-12d9-401d-bbfb-61fcea213ed4', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6afc1c07-abcf-4d89-8d14-3cad677bc983', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3d78a352-6bb1-450a-8712-00495b786544', 'Thainara', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janaína', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2e1b4dcf-50cd-47bd-b89a-4f39199fdb61', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '21edf05f-e86a-4d56-a79b-f6e05fc1e228', 'Laila', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jéssica', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5634795a-7a89-43bc-89a3-00f1b83c712c', 'Evenly', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eb67e65f-5448-486c-a475-2f0bebe20f02', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ad388656-640d-49cc-8373-7af2d241f6c8', 'Antony', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '00534fa3-c6ef-4c3f-a51f-208c3bf96d14', 'Carla', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janaína', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '265871c7-cba4-4919-b2f3-9304c02802bf', 'Laiana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jéssica', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd6ba18a9-2133-4d46-b498-f3d0071398c5', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janaína', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'adf25e27-b33b-4b3e-8883-925b2d39f04b', 'Riquelmer', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luiz Filipe', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4c741e03-5094-4b07-8196-7081cc7feba5', 'Caíque', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luiz Filipe', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b5134207-2639-4bcf-b6cc-5facbe589416', 'Silas', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luiz Filipe', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '45b27fd4-053d-48a3-99e6-480edebca775', 'Juraci', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carla', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '54871c87-626a-4dad-8813-e16f90301e1f', 'Luizão', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Julião', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b3cc8109-5fd1-48cb-b536-cdbd634ea728', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janaína', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '193d59e6-b5e3-4f04-9008-76cbcda9645f', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f85f166b-18e3-4a53-97b5-dd305bf60484', 'Juscelino', NULL, NULL, NULL, NULL, NULL, 'M',
    'e36115b1-cdf7-42d4-b957-bd9f616cbe46', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ademir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a648effe-54bf-4d50-9a1e-4772e71bbe3e', 'Helder', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '827269bb-113e-48b7-ae0a-df513f706c0c', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide / Gina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c4e1d3af-f84e-4538-95ad-4caec8679e9d', 'Jonata', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7079bc19-c16e-40e1-94fc-adfac82af3e5', 'Francérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2bf5aa3a-d062-405c-bb4f-d647ab8c6f07', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa do André', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f8623d2a-9a5e-407d-8ae0-7d2123193852', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Stejane do Magela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ebad0a7-908d-48b6-a9c1-d4ba7a78ab3e', 'Kennedy', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e89dbd5d-af0f-47f2-823c-5c0f2c6b304d', 'Bárbara', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vivian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c478a18b-66d5-4d01-8d19-772bec78c79c', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vivian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ba92a9ad-c6ba-47e0-bab5-a26e10a426ce', 'Pricila', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lilian do Elvis', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '30e1a2ae-6be3-4203-9068-372425d39a05', 'Luciano', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1f346268-7371-47f7-bb24-51808b5823aa', 'Lilian', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vivian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '323415e6-7758-4811-a6ee-c40800b01a23', 'Tiago', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel da Wanderlaine', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4cd8736c-4f46-404e-a15b-89d289e37581', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel da Wanderlaine', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6143721e-4a3c-41d4-980c-40297a14c17d', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel da Wanderlaine', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '97e8a600-d08b-421b-8d1b-9a28daf5a7be', 'Taiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Meury', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0d390dc3-aa8a-4863-a8c7-dfc2ebdca5cb', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Danilo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5e8f6611-b47a-4e14-b5a0-05108a032a1a', 'Rhuan', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kennedy', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e058c838-45e1-4dec-b7b9-22a0279de6b5', 'Gabriele', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Bárbara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ebdf38c5-4138-4346-91a8-bc69e2b2b286', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Bárbara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6d23f3ce-223c-4e16-9df5-020ad353c64f', 'Polyana', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marcela do Marcelo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c643e035-bf9e-4246-a84e-30074d309b89', 'Maria Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Taiane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ddccfc6-88d2-46a9-a8e4-ed24bcdd6c4f', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara do Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb57816e-170f-4381-9c6c-1b8093759ec1', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Pricila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '43836ae4-9166-4290-aada-a3a3e92db1b0', 'David', NULL, NULL, NULL, NULL, NULL, 'M',
    '46d15d87-d30e-4ac0-9991-3749a4f72c67', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jonata', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7af0ac74-e184-4e33-bb80-bd12b75bc1cb', 'Juarez', NULL, NULL, NULL, NULL, NULL, 'M',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '173d4037-e958-4821-95a9-79e7299e94b9', 'Divina', NULL, NULL, NULL, NULL, NULL, 'F',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', 'Santa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'be0ca2d4-8557-4d83-a075-0c942654646e', 'Argeu', NULL, NULL, NULL, NULL, NULL, 'M',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juarez', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6052821f-8200-493d-827d-52ffe6b6aa34', 'Lora', NULL, NULL, NULL, NULL, NULL, 'F',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Divina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '53105f33-5e45-45e6-960a-4992d916d7f7', 'Sérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juarez', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1d636a29-8d27-493a-9973-e35e74476c54', 'Karina', NULL, NULL, NULL, NULL, NULL, 'F',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Divina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8e012c82-8158-4b0b-a0dd-4d14de6d4a3a', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9eb079bb-b5b6-4e51-8514-b056f3f5b4dd', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6865e9b5-da03-4e23-b1d9-66ffd576b76e', 'Lúcia', NULL, NULL, NULL, NULL, NULL, 'F',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Divina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '93a14e1a-7ce3-45b4-8e45-914bcd8c217a', 'Mundica', NULL, NULL, NULL, NULL, NULL, 'F',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a79f053e-25b7-46fd-bdea-1901ba8328e7', 'Janir', NULL, NULL, NULL, NULL, NULL, 'F',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lúcia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cf5751da-3cec-4a07-a3a0-9bd18e08a16b', 'Cristiano', NULL, NULL, NULL, NULL, NULL, 'M',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Argeu', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '721c5d9e-004f-4848-986f-1264faacdfae', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c8d77dab-1aaf-4893-865b-708b3a426ed9', 'Caio', NULL, NULL, NULL, NULL, NULL, 'M',
    '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jonatas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5b92e638-151a-4e3d-8e80-c8712d01ae8d', 'Marinho', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9dedb40f-0760-4b7d-8819-aac8f5c47fde', 'Quênia', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9a9d5fe9-fe73-4b69-b604-22f09e0b59b5', 'Karina', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '403f70f4-f04b-47b1-b4e8-8b6719188947', 'Jonas', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jonata', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1a6883bd-6cd3-4b77-b3d0-2d316b80a676', 'Wellington', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bc3cb641-22c2-4740-97c5-de8bfb35aebc', 'Raquel', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f160cf79-8be3-4a28-ac0b-8fd417450e41', 'W. Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '49069bca-a1ca-4346-b1eb-aa00419a5c81', 'Carlinho', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cd5dabff-935b-499d-991c-d5b06494981f', 'Graziela', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rosimeire', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5b83aa0c-916f-4e7e-b10a-6982209769d9', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aa3d2a3c-7f0c-467b-bf85-2952cca85639', 'Alexandre', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e86f8f13-6779-4961-907a-1c8c6fa870b1', 'Érica', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e363ccc4-8a99-4919-ae43-879ce4ccd49e', 'Benjamim', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7e630638-b948-429e-b5e0-1f0ff0dcaa30', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3550ae89-e7cc-426d-bbb5-3bc74cf2775e', 'Eliete', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ff27768d-39cd-4e79-b9e2-ae187ab7664c', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliete', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0c4559ac-eb29-4aec-be00-533cfdc1c57b', 'Marcela', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Josinha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '83133cf2-3975-4311-8806-3cba0bffeaab', 'Zezinho', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8e8fc92d-956e-4c2b-a9fd-1eafcc4f99a3', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c1baf135-aeef-45ed-9373-bd9cad49d2e4', 'Cida Santos', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7db85295-7a6a-4fef-ac5d-530737b9de8b', 'Cida Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2a3eb895-768b-4ff2-bb77-4218c6431631', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Didier', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '11d3beb5-92a8-49aa-b18c-3008af05e9a0', 'Cleuza', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd65df36f-15e2-4c45-bca8-bef61dd4b20f', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliete', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cfaea95a-9b18-4ece-9ec8-b379275952c1', 'Roger', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marcone', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e1439e40-56c7-4d8f-9e0e-2de14aa23470', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carlinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4b26e83c-029a-44d9-ba6d-ddfd24a22371', 'Mary', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Graziela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6965a4f8-1a2f-4169-bba2-68db6d4b3cd4', 'Filho 1', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '24e24b6a-73ca-4b95-9e4c-2b93d3cbb95b', 'Filho 2', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4c93de6b-b737-4f41-8423-3a27b7afa9dd', 'Marly', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida Lopes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0ababef1-5f5d-436e-8abd-4c06321a96fb', 'Marcone', NULL, NULL, NULL, NULL, NULL, 'M',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e329ffd2-65d6-4202-9969-432a4fe276af', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, 'F',
    '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '983f9a5f-0ade-42ef-afe0-263ce1440ad2', 'Vera', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vivian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '959b2fae-5169-4dea-a573-5f4bb069fbc3', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '152cefab-a0b0-49f0-8d48-e6dfa630f6fb', 'Didier', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', 'Maria Helena', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jonatas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3a24ed42-84e7-4591-90a4-8a1d5f3e94a5', 'Winter', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2642fe06-67a6-4311-8fdf-e99729e30ab0', 'Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8f079d27-b2b2-4e41-abee-5d291bddcc86', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd9eec09c-4d55-4394-9b46-cfeb465535fa', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0f0e3aa4-63d3-448c-a2d3-5f58458804ff', 'Maria José', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vera', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd387f54a-2404-4d75-8abf-ec8e15e2b192', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '97ccb0b0-481c-49ee-9c2b-2f7cc8dff8d7', 'Selma', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a87f0c0e-3451-4e7c-8944-6fa2b3a3ac47', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4a8b4e13-083e-4467-8b0b-7dccd960b615', 'Antônia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Maria José', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1e17f5df-05cb-442a-96b2-cc8421907e40', 'Marcone Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Winter', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '19e646e3-8ee2-4759-bce9-271eb6210b0f', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Winter', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cc099159-251d-4faf-bcaf-98498a7f6e53', 'Karine', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernanda', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bd947417-1ea2-418d-a055-65817a86a42a', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Natália', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7da20361-8881-4494-b296-eeb7dc4b43fb', 'Isabela', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aab2ea78-c623-49ba-a2eb-18feec255606', 'Cecília', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5bf8572e-cab5-43f6-9f15-9df1cee486e0', 'Matheus', NULL, NULL, NULL, NULL, NULL, 'M',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b039b08d-0e01-4bdc-b987-3ab6f901e3a1', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vera', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '80588dd5-54c3-4f20-862d-a46e811b9eee', 'Hadassa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '526cc3b4-cb7a-4b0a-b89d-6c1064ddd257', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', 'Leblon', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a9073378-aa09-4134-945a-aec6e223b4f8', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', 'Leblon', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5aeda46e-fc73-49f3-9df8-a981e1f36d5f', 'Sidney', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cleber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f11fa2bd-91cf-4be9-8abf-c5982da1bd68', 'Suzan', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c26078c2-2bdd-4dc1-b560-4628bb57aea4', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Edmilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '83a538e0-dbc7-4ccd-ae80-0c68496cd7de', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4332ba7f-05a0-4a12-b963-9044e6a0fbf7', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '98e013bb-c845-4a01-9f29-e30418085f80', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cleber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '09b74721-af05-489b-9fa8-51aeca18c043', 'Hélia', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1d1cdf88-22c8-4687-883f-b1dd4b8fd4b0', 'Renato', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb63660a-b0f6-421b-9b5b-06fdaf28de9c', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4bf188b3-00b1-4e9b-adc7-25a4b71f2f34', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '814458ef-8078-412b-97c7-343887eb4063', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '150ea6d5-90a4-4715-b67e-05ce2b5d96a7', 'Ediléia', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vera', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fa45817b-3c0a-4b86-95ec-321028d8a7ce', 'Daiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Suzan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '58a5cdee-8bd2-409f-ab45-b567841e54f8', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '789c375b-e6a5-411c-9f37-6b6b187f2e29', 'Esther', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b97783df-67db-4a60-ad67-dcb6b4ddf9fa', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '11d54fe2-8e08-4557-b6aa-9d8fe99ce3e9', 'Sandra', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Vera', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1ca82797-5aac-4631-8573-fda8becdc21c', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8ccec2c9-6f00-494e-b684-4f5f4a2500a5', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Felipe', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd5682306-a727-454c-bd4a-5e365c3eceb6', 'Moisés', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c03fdb23-23d3-4aac-850e-053ec42d6279', 'Ramani', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Débora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd2486560-7e90-4ec9-947b-aa53900f970a', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ed4c0016-fa08-4317-ac7b-d4851c1fb11a', 'Débora', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fe0bd1dc-263d-4d5e-94bb-fe6084f53c99', 'Juliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c3a4e350-77f5-4c87-b1ed-d3300697cefb', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '09782827-90f8-404c-9018-2308258a795c', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '01cffd07-e218-42d6-89f9-c12af443e8fe', 'Dimas', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dacf9dd1-d154-47a3-af1b-9f5663eb172e', 'Nívia', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aaea23b4-a61f-4591-a396-9209c20f9bf4', 'Artur', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Wellington', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ea6ee148-3d17-4e6f-a678-5ab5a616f020', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '28bab668-c8b2-4246-b2ca-d4a3329e88b2', 'Douglas', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ff747f86-e7fa-414a-996b-2962be8a6743', 'Cristina', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9138a49b-cb8c-4b52-86c1-e1abb8c5e08f', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7303622e-0996-437a-bcd2-bd90701cd504', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', 'Sevilha B', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '61bb229d-5043-4586-a1cb-b5e7809b9a42', 'Cláudio', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b9c1eb03-54db-4bf2-88a6-226be1640d57', 'Cinara', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5f9cac0f-a150-4031-8916-303254cfc6d4', 'Saulo', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '22f124a9-befb-447e-8e8c-e16d14c14f40', 'Duardin', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '43f76c8d-5a51-4323-90b4-20542b056dd7', 'Angélica', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '673d0b5d-9bbc-4267-bb1b-024bdd480e75', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kézia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0bb3c97c-d1bd-4e1e-9b02-ead785f42bd1', 'Lara', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '770b9d65-c331-466a-854f-4134401e8154', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dimas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cf1d34ee-2080-4088-b5d8-d7731199901a', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nívia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cc10d9de-3840-4c7c-b09b-d582d71fbdf4', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '05283e93-f2cf-4c81-93b3-c64b6a304a33', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3cec0763-1953-48e0-8299-9d867010060b', 'Graça', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nívia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '42b30ef3-1e05-4617-b53c-5198b7962ff2', 'Jane', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nívia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7a3857df-05a4-45ab-920e-70662c8d88ca', 'Kézia', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '300309cf-bc6b-4b04-8680-25c794dcf29b', 'José', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dimas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '233b4286-6217-4db6-a7b9-735f7d08f9e3', 'Geralda', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nívia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4498bead-79fc-44d6-bace-4c8100526dac', 'Marta', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '10459fa6-49d9-4e07-bad9-8f01954881e0', 'Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '52416985-e4a7-4a49-b4b0-433878205c4d', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cinara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '70f111a7-ed80-4cb9-8df9-a57b334042a5', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Arthur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cc31648e-f28f-422a-a4e4-d4f6d4a8a081', 'Wesley', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '93a88ed5-e784-4d6b-a69c-d7debb496bf3', 'Elen', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f65fbc27-1b20-4f70-a155-5cb2e034426b', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara (Reginaldo)', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '933d612d-44d4-4314-b93b-4c704564f331', 'Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'dc23aa70-fbb4-4b81-9d74-3e5543cca2cb', 'Cleiton', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2a75f8bc-d048-437f-85f3-f2c0f94dee00', 'Milca', NULL, NULL, NULL, NULL, NULL, 'F',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3691fc35-2237-4afd-8520-851c5c1bbc1f', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    '2764260c-e49f-4cbd-9daa-0803989641d3', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '60d5d00e-1ad7-43df-8cd4-a78be04e6f66', 'Jaime', NULL, NULL, NULL, NULL, NULL, 'M',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '20eb0250-1390-4a45-8abd-3f3ba349d2c3', 'Jacira', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1090ac20-36e4-4513-aa5a-1bbbdcad75a0', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaiminho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3d4ba9ec-ebd0-4013-a8d4-74896f1ff537', 'Dona Adélia', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ffeca61-7cd6-4cf1-adc6-d48959409cb0', 'Wagner', NULL, NULL, NULL, NULL, NULL, 'M',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9ae11fee-96fb-4c81-a6cd-57af2541291f', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '03a773d6-637f-41a4-adb3-3bf7fa3ab362', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b8b4f899-40ce-4dde-908d-96e407622fae', 'Rebeca', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', 'Areias / Morro Alto', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '80451c2f-40e8-4dc3-bd77-892771918cf9', 'Ronaldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Wagner', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1eacbe73-b7b9-4b19-b4f8-4396f357f975', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Zezinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a8403eae-74c6-4fef-a79f-2847d04efcec', 'Glória', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ana Laura', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b02b4f4f-5b40-4085-a3c9-82db4c266582', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaiminho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '37a7eca7-d590-4f26-8fda-d63a6377914e', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jacira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '82682c32-09ec-4d57-b696-b7ced5cfc50f', 'Aurora', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5318dcf2-79e5-4ce1-abd5-bc4df72634cd', 'Maria Tereza', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a3f3e01d-de9f-4355-afd9-163ef2baa6ab', 'Welvis', NULL, NULL, NULL, NULL, NULL, 'M',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaiminho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ba920b1c-2c4f-46c3-ab83-4eef8c657c4a', 'Adriele', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jacira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '95330e5e-f741-4ea7-a125-9f51deb9365e', 'Bela Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '667b7671-f41e-411c-9c09-650bdf3c3fbf', 'Izaque', NULL, NULL, NULL, NULL, NULL, 'M',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaiminho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8b01e7d2-fdb5-4873-beec-0f255c9c1be3', 'Jamile', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jacira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '152cddca-fcde-405f-b238-e1b47d1f7928', 'Kailaine', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jamile', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '76361e98-ddd7-4231-b672-7840cb82ae4c', 'Angélica', NULL, NULL, NULL, NULL, NULL, 'F',
    'baa7dafb-99d5-4812-bc48-3b5642a82365', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Mariana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '39ba647e-b4c9-4d9d-a376-c7b4b5b05ee1', 'Davi Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Casado(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Maria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18cb4392-3c16-46ff-bbac-96af09d8c07c', 'Liliane Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Casado(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sâmia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9ae46d62-0e98-4b65-89c8-1cc7f87106f0', 'Diogo Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Solteiro(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel M.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '31c9b3bd-8224-442f-b8df-77a210303c7d', 'Thiago Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Solteiro(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael M.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5a9dab15-3181-461b-8979-220324e65540', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Casado(a)', 'Imperial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3769e1a2-b80f-4c23-9328-7d7e2d733e55', 'Gabriel Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Casado(a)', 'Imperial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Diogo Lima', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7bf2a8a1-1d38-413b-a2b5-77663f2a3255', 'Giovana', NULL, NULL, NULL, NULL, NULL, 'F',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Solteiro(a)', 'Imperial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9807a7a8-6fb1-4e80-a88d-dc2f2c6b5345', 'Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Solteiro(a)', 'Imperial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '54e51a0d-57dc-4acc-8e2e-c2a91309fdb2', 'Krismary', NULL, NULL, NULL, NULL, NULL, 'F',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Solteiro(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Miliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '255b5be3-2f4d-45b8-ae42-f41dc52596f5', 'Wellinton', NULL, NULL, NULL, NULL, NULL, 'M',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roberto', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0dc1bb25-5c61-4473-a337-2e2d2f66e3a9', 'Miliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leidiane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '583f91ae-6c21-4560-945a-9933fda65cd6', 'Gellissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5a1d7c3c-cf7f-4c14-ad35-6377e89fbc6c', 'Kal', NULL, NULL, NULL, NULL, NULL, 'M',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Casado(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Maria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fbd6a317-24a5-41f9-8da1-f3aa22a33cbf', 'Tininha', NULL, NULL, NULL, NULL, NULL, 'F',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Casado(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sâmia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '923b7ec5-8573-4ee7-92b2-740b3fbbc5fa', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ccc39429-4095-48eb-9336-3b128d779337', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    '9a52e5a9-3676-4492-809f-2daf46fd1e77', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3bb28abb-1e36-4b4c-86be-39ede123499b', 'Lincon', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cdcb7800-a3c8-44c9-b782-d0cc98431d61', 'Tati', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c4622e4a-ee68-4645-91c3-7537d8c0b75b', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Diogo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7b72a571-653f-41a2-a491-191dcc7b9841', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a483ef3f-4ffb-4a60-8c7d-b1e5034c47e3', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '04691149-7822-419e-af0c-0abc4ca89778', 'Adilon', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Helder', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '134164ad-c0fb-4c9b-ba42-a512c1aad399', 'Lena', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '36710d40-c124-4852-85d8-c8100d14adaf', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '67f26cae-b7bc-4b15-84e3-c8f5e20d51af', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1f3eb3b0-f1c2-4c9f-a202-5d52180e8bc5', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'abfa588a-96e0-468a-85f2-c63a08d5cc96', 'Milena', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd1c45d05-e092-47cf-8894-ac568acf70ac', 'Isabel', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e9754ebb-7614-4040-9d7f-5b741d07b633', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a1e470e1-3742-444f-8834-8f5891892096', 'Daniela', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b548c3fa-15bb-4883-8243-c2f793f32ecf', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neto', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bfbbefbe-e661-4882-9f41-c6b6c6e5564e', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a59946d3-9c25-40fd-b87b-dd2f98990461', 'Bernardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '060c9b8a-9173-4c73-afb1-348868616c14', 'Neto', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Diácono', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '94734ad2-5b56-4a13-99a1-e8ea21226daa', 'Thaís', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'acf35bab-e798-4f35-b02b-1f86a8259c81', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juliana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e527af2d-6f17-459c-aefe-e24cbeb824fe', 'Luiz Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c0dff264-dc84-45d6-9a4e-da18d047dd73', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '81a0a170-8930-48f2-b505-8cd13b9883c2', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Casado(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '568fdb5d-b1c2-4756-88d9-c335ef1c9a13', 'Benício', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9a4e1669-97cf-47c7-8335-8a3b9737244d', 'Augusto', NULL, NULL, NULL, NULL, NULL, 'M',
    '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c', true, false, false, false, false,
    'Solteiro(a)', 'Lagoa Santa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2677d29f-1562-41cd-9165-d007e2ebd21c', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3d98a907-ca71-444c-a6e6-c91e31d9ff5c', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b348d9cf-050a-4d0c-a8e2-e1120dc44ce9', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e69c3258-eecc-422d-aad5-72c658281486', 'Soninha', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6f91d776-8634-4ece-94ae-f3994a84d1a5', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Paulo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2c668ccd-0f93-41b2-8743-66b74b4b533b', 'Daniele', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alcione', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8c0ccb5c-4000-4b4f-aad3-69e04bdd7c13', 'Lívia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '908e7313-c386-4f4a-9e7e-c625851ea6bd', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alcione', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1bc4e464-f763-4338-8e96-8e0185ffa4d6', 'Geovana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alcione', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '388126b0-bd32-4968-be8b-3e0de8ba6d47', 'Emanuele', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '461cb7b4-aa06-4eb9-bef5-480815827ebe', 'Paulo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'Rio Branco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neto', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '757b9efb-8eda-4fd7-8405-7576e2aa32dd', 'Alcione', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'Rio Branco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '959fd92d-74b9-4833-b680-01c649ed6708', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'Londrina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8ff43458-bfc4-4e86-bfa0-3b95a31b5ef3', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'Londrina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Mariana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f0774771-5baa-478f-a0e5-a96372e2bf32', 'Abadia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'Floramar', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Soninha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '29a24143-84ff-4f2f-a24b-a4980d41e85a', 'Dona Vânia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b4d865c4-14ff-4d3e-b41f-9a2865d9d1a6', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'Londrina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carol', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '968867ff-0c83-4604-9a4a-23d81d82c8ea', 'Bryan', NULL, NULL, NULL, NULL, NULL, 'M',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'Londrina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a0a8c1f3-b85b-4651-909e-4676c741b2b9', 'Evandro', NULL, NULL, NULL, NULL, NULL, 'M',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '12bd3171-e22d-4d74-b50d-91c8a20dc721', 'Jucilene', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7a300727-8223-4ec9-9564-9044b6803756', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Solteiro(a)', 'Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4fa95ea1-a476-4748-b497-89ae3e5585f8', 'Gilson', NULL, NULL, NULL, NULL, NULL, 'M',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'Juliana', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernando', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0b1b930d-73f2-4de5-a858-75faa09fd567', 'Liliane', NULL, NULL, NULL, NULL, NULL, 'F',
    'e86669d4-fd46-4053-b003-b2e19603ab3c', true, false, false, false, false,
    'Casado(a)', 'Juliana', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ff78bac-b9be-4f2b-82e3-b072780d15b8', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Maria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5d5d13b8-48b6-4458-a9d0-bb5aae9c215e', 'Auxiliadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sâmia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'baa69c40-b455-4530-b4d0-eb1d9eef8c50', 'Jonatham', NULL, NULL, NULL, NULL, NULL, 'M',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Solteiro(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thiago Cunha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a668b606-1d7e-49f5-ad6a-8d7f3179ce39', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Solteiro(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fd3b4ca9-f0f3-4e55-a710-718bbbc4ff96', 'Jésius', NULL, NULL, NULL, NULL, NULL, 'M',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '563ec794-3f1b-431a-9d37-f3d88b351158', 'Elisângela', NULL, NULL, NULL, NULL, NULL, 'F',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8c7eeb03-e45d-4b66-8d61-f45d482b344b', 'Cláudio', NULL, NULL, NULL, NULL, NULL, 'M',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jésius', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bed91864-53a2-4c6e-b35d-ba593e895143', 'Ivanete', NULL, NULL, NULL, NULL, NULL, 'F',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Casado(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Elisângela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ac2aaff-4b7a-4c6b-a3f6-5212098db9ed', 'Brener', NULL, NULL, NULL, NULL, NULL, 'M',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Solteiro(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6c06275f-784c-4b4b-bae8-586c73512efc', 'Deivison', NULL, NULL, NULL, NULL, NULL, 'M',
    '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb', true, false, false, false, false,
    'Solteiro(a)', 'Fazendinha do Baú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e4b579fe-e0da-4041-a958-a78e79c805dd', 'Roberto', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7c4dce9c-31a4-47ad-898d-402428f5afc3', 'Leidiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd74d0414-54ff-4280-b4af-b98e42b163bc', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Gabriela', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '443e0ff8-f2b0-476e-8655-dd84dc998390', 'Rayssa', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6b9c249e-34ed-4091-b48e-1e79669a4f08', 'Ryan', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Diogo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c3dee27d-46b7-4b6f-b312-7e0a1f5e3ca8', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f8fc3a94-f3fd-4467-a992-52262a94b14a', 'Dora', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8728bf62-2837-434f-94df-0ec476efc828', 'Ana Flávia', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Miliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8122c13c-b1a1-4749-bf2c-6016c6a0d81e', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a6ca3f63-53e2-407b-a9fa-ae1f9c695380', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b9181151-41c7-441a-90a6-949a703ae525', 'Leydimere', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dora', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2401b302-07c6-49e1-9255-f761e4eebb67', 'Bernardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marcos', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'da9f0ce9-0bc4-48c0-892e-400bd72edfdf', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8a9a91d2-1bf6-40a1-8a45-e858192d0fb2', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '947b92b9-c68d-4f75-a8cd-5785f3e1b00c', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Liliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5f7f3124-4088-41e2-ad70-4057634c6b52', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8c3d244b-6ea8-46df-8291-f3898d806424', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Córrego das Calçadas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7cc5d3fd-5602-41b8-a8b0-2a601502657c', 'Álvaro', NULL, NULL, NULL, NULL, NULL, 'M',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Esplanada', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roberto', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e7f688c6-a018-4870-9f61-ec7be9da2b24', 'Gabriela', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Casado(a)', 'Esplanada', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leidiane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6032d844-5ec8-42af-a542-9681d754b965', 'Olívia', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Esplanada', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '11e60cb0-d0dd-4e65-b82c-479c49bc4a7a', 'Maria Aparecida', NULL, NULL, NULL, NULL, NULL, 'F',
    '3380d492-b8a0-4b4a-b532-fbde9e288f0e', true, false, false, false, false,
    'Solteiro(a)', 'Kennedy', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leidiane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1d980dc9-edef-4d20-8f4e-06b5ca740b25', 'João Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Álvaro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '520c80c9-aa39-4e3b-b2dc-25f244134337', 'Thaís', NULL, NULL, NULL, NULL, NULL, 'F',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Casado(a)', 'São Benedito', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Gabi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0db56617-d98d-4388-b983-734f2986111e', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Solteiro(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Josinha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '79159b7e-a0c3-470b-b914-55aa147cebb4', 'Lara', NULL, NULL, NULL, NULL, NULL, 'F',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Solteiro(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Karina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '06d3daf5-c876-4098-b629-a15511ab4f91', 'Zinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Casado(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jucilene', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cc48aec5-2f4c-4cdb-8e61-4680e3df8c83', 'Warley Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Casado(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Maurício', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a0fe8728-4da2-46fe-b905-09f048aac2b7', 'Dona Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Solteiro(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Andréia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '949959ee-1dd0-409e-b9f8-32ed32900042', 'Júlio', NULL, NULL, NULL, NULL, NULL, 'M',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Casado(a)', 'Belo Vale', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fransérgio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e95ff5f1-2d83-4d91-b128-9b90e3545799', 'Andréia', NULL, NULL, NULL, NULL, NULL, 'F',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Casado(a)', 'Belo Vale', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sônia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '952e38d0-ef7a-4c11-85f4-b7cbe0b2bfda', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Solteiro(a)', 'Belo Vale', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '796d53cc-857c-4dc2-a2ab-004f6a37324c', 'Diogo', NULL, NULL, NULL, NULL, NULL, 'M',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Solteiro(a)', 'Santa Matilde', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Samuel M.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '20e07137-576a-499e-8fda-2bbc44badc2d', 'Maurício', NULL, NULL, NULL, NULL, NULL, 'M',
    '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3', true, false, false, false, false,
    'Solteiro(a)', 'Industrial Americano', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael M.', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '75140740-0ff3-4301-80e2-d690e8c3631a', 'Júlio', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Novo Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9aa0ae66-d55f-4866-a489-2adfeb6986f0', 'Valéria', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Novo Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2f01b03a-0434-4734-ab14-6a6e91bd2004', 'Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Novo Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6d436adf-b847-406e-bc81-08edec7082d5', 'Anderson', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Sol Nascente', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Júlio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3bf01b20-b2d7-4a79-ac09-dfe57cb53f85', 'Kênia', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Sol Nascente', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b8f53adb-3c46-4cb5-9472-964e3cdb24ba', 'João Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Sol Nascente', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João Pedro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ad212dd4-6d1f-4bb5-b541-4516c2908322', 'Arthur', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Sol Nascente', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João Pedro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bac00a53-6c8b-4e62-a103-377d2b317a9b', 'André', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Vale do Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Júlio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e71efd7c-f1fb-4657-b177-222ffbbe45f3', 'Andréa', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Vale do Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd488d792-354b-47bc-a6af-7a269a4f1cb9', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Vale do Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Natália', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0d081af7-f83d-4d99-9633-e388c59f5a6c', 'Marco André', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Vale do Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b0169324-5c7e-490f-a060-50ffffb76fcc', 'Genderson', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Santa Rosa / Sarzedo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Júlio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ab486074-4430-4145-a18e-a057cc12ea24', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Santa Rosa / Sarzedo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '01eb5520-da87-40b5-81eb-e38425e82968', 'Sérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Marilândia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Júlio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c6cd2239-d26e-49f0-9f83-f983b0bce48b', 'Kênia', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Marilândia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ccb38acb-db50-4ce8-90eb-56fc56b2e414', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Teixeira Dias', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'efaa3472-4733-478f-870c-e1f6ab7bf919', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Lindéia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Genderson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b5da54bb-bbb8-4761-a7a7-56e2d3067853', 'Juliano', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Novo Horizonte', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ricardo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f759ea07-6f82-4d13-8e86-4aa62bd8743c', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Novo Horizonte', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Beatriz', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2a2b6b04-2392-4488-9907-fcb1ca1ef972', 'Bernadino', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Anderson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e12a6c53-a805-4a5c-a371-56565afdd0ea', 'Jorgina', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Jatobá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a1e245a9-a9e8-40fa-b5e7-c77f8254f413', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Santa Rosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ac525d55-2834-4af2-8998-525a077c5131', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Santa Rosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6779cd64-d9a5-4f1e-86de-f0c6ec3648b2', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Santa Rosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Beatriz', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ea87628f-c075-4fb6-af3f-f32ef60b210f', 'Valéria', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Lindéia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'A definir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ab297f8e-d31a-4699-9e98-cbef89b24f5f', 'Mariza', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Maldonado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'A definir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6eb8f32f-32c9-42fd-9bc8-c1eb531f8f64', 'Jorge', NULL, NULL, NULL, NULL, NULL, 'M',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Diamante', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0a10e106-c70e-4577-83b4-4fd3692e19bc', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Casado(a)', 'Diamante', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '42d488be-edde-4df9-9117-e2d1c256a95b', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Diamante', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6b15653d-44d5-4912-8951-f8ffe628638a', 'Cristiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '38438326-8b6f-41e4-894f-5514e834a762', true, false, false, false, false,
    'Solteiro(a)', 'Mário Campos', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Letícia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '60f23c80-fef9-4368-87c8-4fad26594ad8', 'Rafael S. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Casado(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3941c095-38e1-48ce-a448-493641f2b4dc', 'Isabelle C. M. Moraes', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Casado(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'df4ca1be-3d48-4d9e-b860-106303126eab', 'Beatriz M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '844cf6a5-101d-4f55-b65a-c57ba6c44973', 'Filipe M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ac734394-c100-4219-81d8-4fcf7102a2ac', 'André M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Milionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e9b7b08d-8b13-4757-b553-b7e7fbee5209', 'Ari', NULL, NULL, NULL, NULL, NULL, 'M',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Shibas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9480e978-7d5f-4bc1-ba15-22616f3c2a62', 'Jucieda', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '62b05e0d-e68d-4589-92b1-57ee159be2b9', 'Natally Silvina', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Ventosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Isabelle', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3be62807-f4e5-4bf4-8d97-2d1311753175', 'Wesley Anselmo', NULL, NULL, NULL, NULL, NULL, 'M',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Casado(a)', 'Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '92f70a03-0c90-4011-b42f-2d96b9072737', 'Evelyn Ellen Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Casado(a)', 'Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Isabelle', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9fce86ca-22d0-4baa-81d3-78afaff0256b', 'Anna Júlia Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara do JP', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5dd7aebb-6d01-4160-90f3-7ee58a93b506', 'Anna Laura Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Tirol', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Zoraide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fee9a12d-f9ae-46a7-b0b1-5efc03728a14', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Ventosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dona Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e4dc0ee6-6287-431d-acf5-0c62d50cb4cd', 'Lucas Eduardo Luz', NULL, NULL, NULL, NULL, NULL, 'M',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Casado(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Rafael', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3ad0382a-7f9b-4371-8bda-1c55d3a90e0e', 'Allina Rodrigues Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Casado(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Isabelle', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '33cb1e8d-98f3-4c10-b053-d8be68f7c31c', 'Carolina Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '798cf288-c38b-4544-8423-f92af5397a93', 'Maria Fernanda Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2f46f6d9-3bb2-4a89-bf67-675dfb61673e', 'Leonardo Luz', NULL, NULL, NULL, NULL, NULL, 'M',
    '22e95001-26cc-4b11-aca6-06ddb854bc6d', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '577a8a70-5414-44ed-b9e2-2992cdb0e083', 'Cláudio Luís dos Santos', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Carlos', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '306da3f7-8b19-4248-8cdf-2c2df9002d8b', 'Vânia Lúcia de Paula Santos', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roseli', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '72214bda-5a03-4ae8-a0bb-55e4ca67bca2', 'Nicolas Matheus P. Santos', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4b33e034-5341-4e8a-a7cc-e86aa07de102', 'Davi Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '153aeb2c-be7c-4ef1-bd7c-a3b3da2370f1', 'Roseli Gonçalves', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '90c13038-0cfb-48b9-b255-f50973813084', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '43cee65e-86e9-40ea-97ed-f2ebb121a014', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '093f68c1-99c9-4adc-9f78-e82b12b9f26d', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '64fed90e-bed3-477b-b296-e3284bd747c3', 'Lúcio', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '62c5805d-ffe9-421f-b0ac-2df896b149d9', 'Tatiana', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '52b93bc1-d5c0-40e1-81a9-69f474c83543', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fa1bd922-ad4f-4696-b684-57bc7e8be418', 'Eliza', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tropical - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '39817ad5-f1e9-41d2-8a36-327b874917cb', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eeb05682-ff4e-47c3-801e-72417c44fa17', 'Neila', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roseli', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fa28fa92-7095-4a97-84c6-5759e4029598', 'Enzo', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marcelo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5af65d2f-06f8-43f1-9fa7-445d7b276af3', 'Melissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'df359988-6e42-4170-adbc-0770f27492d8', 'Hemerson', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lúcio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3bd2fa63-835c-425d-b59c-4f5e7347dc5d', 'Joelma', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1c69449a-9c16-4386-975c-4e544bf83203', 'Sueli', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Mariana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b4cb8420-4a0d-4ca6-93b7-4fa08558fce4', 'Izadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '14dfc1a0-db47-478e-97ba-3613fef0ba76', 'Isabel', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Tupã - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8b57df6a-273b-4d5a-b433-5d653962a0cf', 'Aparecida (Cida)', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Colonial - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b1ff634d-52d8-4d92-8980-5f9fac0bbc0e', 'Alviclênia', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Petrolândia - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '038ce34b-d0a0-4de6-9b01-e52c9b3f3ea0', 'Rosa', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Solteiro(a)', 'Ouro Branco - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a6bd54a5-7ba6-459e-87c1-6b59e27efec6', 'Ferreira', NULL, NULL, NULL, NULL, NULL, 'M',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Icaivera - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Arthur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1d932706-4669-4b65-8216-2e27ad245971', 'Gisleia', NULL, NULL, NULL, NULL, NULL, 'F',
    '4c9a7389-ba43-4fbb-b635-f03229f9eade', true, false, false, false, false,
    'Casado(a)', 'Icaivera - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Taís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '27dcb3c1-c18e-4218-80b4-05d0a1b8a5ab', 'Willian', NULL, NULL, NULL, NULL, NULL, 'M',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Casado(a)', 'Novo Progresso', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '11cfdb38-c2d1-43fc-b83d-5bfaf42fbbbb', 'Dulce', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Casado(a)', 'Novo Progresso', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bedd45d3-8d32-4efd-8147-7534488b749a', 'Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Willian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '16333488-0d3b-4795-8597-9dcb7d9dc128', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dulce', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c98f9811-3687-423e-aff0-82190ae57698', 'Eduardo Coutinho', NULL, NULL, NULL, NULL, NULL, 'M',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Willian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '56633d3f-4763-4a50-a729-697468846aaf', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Larissa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4696bddf-98ff-4307-97ea-82fcb9ff317f', 'Roberto', NULL, NULL, NULL, NULL, NULL, 'M',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Willian', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e055729a-4b76-4528-b260-4f2b1a0eeeff', 'Neusa', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Dulce', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0de7c8f5-3c6b-4d96-86cc-6517864b6d4b', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alexsandra', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1c010aad-7734-43b9-a03a-9a0d908de466', 'Meirielle', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0ea4fd24-2aea-4a34-a052-5c8fd3b5742a', 'Eunice', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cfcce2bb-8eef-47dc-8eb5-ac713f8c2a60', 'Lucimar', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ed84c6a-a5f1-4c66-8394-e8ab6ac026b5', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Oliveira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '892fd5a9-a4fe-4932-85de-2cfa459f61d6', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Alexsandra', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fde67b87-f300-4595-b0c5-3f778fb15b93', 'Dalva', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '59e886a3-f6f1-4608-921d-8e77a4623ea8', 'Lúcia Helena', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '96ecc10b-a3a7-4fbd-9269-9f7a3b822ef3', 'Sirlene', NULL, NULL, NULL, NULL, NULL, 'F',
    '9baef366-eb8b-409c-bfdb-363fb9cc5b0a', true, false, false, false, false,
    'Solteiro(a)', NULL, 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Neusa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '81659905-131f-4a84-aafb-1ab3d9f0693d', 'José Alfredo', NULL, NULL, NULL, NULL, NULL, 'M',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Casado(a)', 'Bela Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ed73084d-85c8-420d-b6ae-a404985a3138', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Casado(a)', 'Bela Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ef6ce8ca-85f3-4942-a155-050ca4116b3b', 'Isaque', NULL, NULL, NULL, NULL, NULL, 'M',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Solteiro(a)', 'Bela Vista', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'de2648cb-4bac-436d-b4d5-a97741b3e50f', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Casado(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Alfredo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '75d62d1e-646c-4f27-b61f-1736ff071923', 'Ila', NULL, NULL, NULL, NULL, NULL, 'F',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Casado(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'be328eeb-a952-4c7f-be08-a6f96c1ab356', 'Gabriela', NULL, NULL, NULL, NULL, NULL, 'F',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Solteiro(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Valéria', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6ed6b4a7-c085-4e59-86a0-8542d3380ec1', 'Neide', NULL, NULL, NULL, NULL, NULL, 'F',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Solteiro(a)', 'Los Angeles', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b7768fff-f421-4596-bdd3-c7ce279df56f', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, 'F',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Solteiro(a)', 'Los Angeles', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7205e063-55e5-41b9-906b-8cc83e2f9b0d', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Casado(a)', 'Bandeirantes', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Genderson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7f3b532f-5421-4b9f-8ba0-2e717ddc1f93', 'Deise', NULL, NULL, NULL, NULL, NULL, 'F',
    '64791204-ba0c-4881-b13f-f14d2ceeac20', true, false, false, false, false,
    'Casado(a)', 'Bandeirantes', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a6dfb526-08b9-452d-bc99-7384ffb0e521', 'Thiago Van Petten', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Casado(a)', 'Nossa Senhora do Carmo - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernandinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '52b16034-cbcf-4896-a7b2-7336375ffe30', 'Nara', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Casado(a)', 'Nossa Senhora do Carmo - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a31ce4ca-beed-465b-993c-f76976c3673f', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Nossa Senhora do Carmo - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f0d995e6-5117-472f-bace-a139b34b0d89', 'Augusto', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Nossa Senhora do Carmo - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5dd10ed6-4dc2-4fc1-ad6f-4c6f44e90f29', 'Ismar', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Salgado Filho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f7d3c8ab-4309-4b4f-a235-da8204f07b86', 'João Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Casado(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Fernandinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '10ee34d4-888d-4409-88df-699a366c8cef', 'Sara', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Casado(a)', 'Barreiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Clara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ffdbfa25-274f-48c1-85a5-dbffe97785d7', 'Denise', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Cidade Industrial - Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '64a12542-4a5d-4126-b9f7-c5de6e0eafdd', 'Madalena (Madá)', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Salgado Filho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b14a40cd-e49b-495b-ab95-2527ab75a71d', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Funcionários', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thiago Van Petten', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9ad2638d-73fc-4d45-9cce-c39385015883', 'Tiago (Tiaguinho)', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Jardim América', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João Pedro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '03661168-950f-4354-b233-397b08bff48e', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíssa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Shibas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0961cec1-bf5a-4cf8-aba3-c89efd4421bf', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Casado(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thiago Van Petten', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '374dc646-b0ad-4830-b353-6b12f5ff2561', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Casado(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aa5acfc5-035e-44ae-9dc2-45b1d7b8df50', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '01d9b464-7053-4f22-8815-874c13796ed8', 'Elisa', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '09ff0348-354e-43c2-b372-181bac3bddfb', 'Mauro', NULL, NULL, NULL, NULL, NULL, 'M',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Casado(a)', 'João Pinheiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'David', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a2a83320-2e09-4258-a3d5-8aaacbb043e0', 'Marlene', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Casado(a)', 'João Pinheiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jehane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '57df42f7-0dc0-4c71-8f65-2f14e15ba866', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'bf4cb59b-2698-4530-aeb4-fb4522387152', true, false, false, false, false,
    'Solteiro(a)', 'Nova Cintra', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ismar', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '747b38d7-b84b-4039-9033-6fee34f9bddf', 'Jardir', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Casado(a)', 'Nova Suíça', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Regi e Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '75208da3-b8ba-486e-8665-e765a183883b', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Casado(a)', 'Nova Suíça', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a9702713-6d0a-48dd-b1da-cb915ad1ce71', 'Warlei', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Casado(a)', 'Salgado Filho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd9f00b9c-8e29-42c2-8874-1801b2f0290e', 'Alba', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Casado(a)', 'Salgado Filho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Warlei', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6936238c-4151-4795-92e8-1b238739f7ed', 'Afrânio', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0257e477-a7b6-4121-a5a8-27919652d373', 'Helen', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Afrânio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fd84b5f8-115e-4bc8-8ae7-9cd5b84d10a7', 'Helena', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '53e99fe6-d062-432b-8520-0d56ced4eb27', 'Kátia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Santo Antônio', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '03249386-a827-4dc3-b732-13775f6a2119', 'Cassinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Gutierrez', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kátia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f9c91c0c-0f5f-4e65-9f1d-a34005b2ec9d', 'Clemência', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Santo Antônio', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Grace', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0d8468f5-1153-4c5d-840e-5d0b1717d331', 'Bárbara', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Santo Antônio', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Kátia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '38adb185-a124-48df-bad7-dd9f5e1697a1', 'Perpétua', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Nova Granada', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3abe52ae-99d4-4946-b1ac-7dddb50bd36a', 'Ágatha', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Padre Eustáquio', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '74745f41-8358-4ef6-9bd9-5bb65d351ffd', 'Maria Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Lourdes', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ágatha', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '265e932d-f3d9-4d23-84d8-c03f5f3a46e8', 'Claudinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Grajaú', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Denise', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7fb7dc20-c84e-4590-9f05-10156435ee5f', 'Saulo', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Casado(a)', 'Floresta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jardir', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '107ca685-65b8-4780-bc0f-c943e09aa8ef', 'Kioko', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Casado(a)', 'Floresta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Denise', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8042ae68-bd1a-431e-96f8-6669581e2937', 'Denise', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Lourdes', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cida', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c247c8d9-b8c0-4733-bd26-678c24bfc892', 'Wellington Ferreira (Shibas)', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a447ab1-0b6a-4b93-ba2c-0026ca85b730', true, false, false, false, false,
    'Solteiro(a)', 'Nova Suíça', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '643a895a-771e-4c2c-8ddd-6be6ad1a3687', 'Luiz Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Centro - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4f6caee5-fe21-4c66-b050-28a3766c802c', 'Charles Pascoal', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'São José - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f1eedb72-e58a-4905-8b59-d6db370a2b32', 'Lorena de Freitas', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'São José - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caroline', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f338f154-5c97-4529-8b12-9b90478740bd', 'Ana Raquel', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'São José - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c3fc759d-6814-46ad-b336-01c59a63da94', 'Davi Ribeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c6ca5e65-7c90-4d00-b1d9-d9c03744a72c', 'Jehanne', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caroline', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b188890f-2349-4b52-9793-08b5811f7ba8', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João Paulo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'faea37be-2052-43c2-b3a5-bda548e27549', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Ribeiro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '246a7e2a-f9a3-43b7-bc6e-1e729bb0aad9', 'Tiago Ribeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Zona Rural - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Ribeiro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '722a8040-c020-4878-a2aa-0424f57d868d', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi Ribeiro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '32f624ea-0788-480e-b963-0d5fa2bd24d6', 'Lídia', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jehanne', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bf98590e-ccc0-4929-835c-ba1e9846d679', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '32b950d9-6474-4e1e-a513-555280617278', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1bd07e79-5900-4d35-960c-f7b6f6b7c5a6', 'Darlene', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caroline', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '868474c4-058b-47c8-a89e-660cc7a54ee9', 'Davi de Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Luiz', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4b4383f1-0c5e-48e3-82ef-1ac67dae9231', 'Jonatas', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '251b4abd-0ebb-49f5-8773-1cba771cb36d', 'Marisa', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jehanne', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b008f08b-016d-4067-8e31-aa26ad8196b5', 'Raphael', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2ab6692a-78b5-4c50-b2ca-fd04799988c2', 'Sophia', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Santa Quitéria - Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '15b6d388-0772-477d-91b1-bc3504a0bb21', 'Emerson Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c986ba93-3f40-44ba-82b6-7147178a2c67', 'Caroline Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Casado(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a2476a67-ac0e-4e9d-8bf5-014df04e39c2', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caroline', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f6071af1-02bc-4fa5-a75e-3ac318dd792f', 'Tiago Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f81d2bdc-4497-460f-a60b-b759afdec6a9', 'Samuel Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb9ba05f-c74c-4bd2-8270-3b2ada1297a7', 'Isabela Heleno', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a60c8589-0c72-419a-b414-d48a10c78dde', 'Ilia Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lorena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b8b2e930-80b1-42cd-a0dd-530afb3de1a7', 'Glaydson José', NULL, NULL, NULL, NULL, NULL, 'M',
    '03acbb31-1865-4ed9-be93-b16da9be65b2', true, false, false, false, false,
    'Solteiro(a)', 'Gentileza - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '01de7ea5-c4fe-4330-a5db-e90ee9b75999', 'Alexandre', NULL, NULL, NULL, NULL, NULL, 'M',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Davi', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fe58ac90-83fc-4708-bc8e-d7a7f2080fe9', 'Érica', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roseli', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '99d320d6-b38c-4b4d-85f0-771f1765b166', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3bac8349-bdeb-4f5c-8837-846f9fee43f1', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9ac2d7c2-17bf-464d-9333-89e0735c493e', 'Heloísa', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '111fc211-6520-4e68-ad30-d99663fb7f12', 'Tames', NULL, NULL, NULL, NULL, NULL, 'M',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4c496562-332f-4350-8713-36deb6c0ab95', 'Michelle', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '20a8f04e-66ec-4fbd-ade3-80b59ac244dd', 'Helisa', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a794e044-0c16-479d-a039-b544402e1422', 'Adelmo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1355f355-3402-4c7b-9fa8-aa7a1e426c2d', 'Júnia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '84aa6d0e-1b1d-4f31-b25d-11d740f79eef', 'Neuza', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Roseli', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '086d8459-48a2-4cfa-8dfa-ea5b36cc36d1', 'Rosa', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Água Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6a6a3f14-83fa-4a44-b0cb-f33de4ba029c', 'Juan', NULL, NULL, NULL, NULL, NULL, 'M',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Reginaldo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4f8be18d-1754-481e-ab8f-870005082348', 'Ximena', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bf3c75f0-aa5e-4484-ac75-deff7f6617d5', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bd3b3e72-18ca-42d0-a49e-276e85afc13c', 'Victória', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'de2e7b1c-98c1-440b-995d-eeb21e4b3a53', 'Antonella', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18e11abb-1bd3-4901-aacf-177af5aa8960', 'Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Monte Castelo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Juan', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4d4704b4-9513-403d-8499-17c560f45254', 'Silvana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Casado(a)', 'Monte Castelo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ximena', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a7b300d0-4d15-40ef-89db-47167abb3cc9', 'Emanuelle', NULL, NULL, NULL, NULL, NULL, 'F',
    'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c', true, false, false, false, false,
    'Solteiro(a)', 'Monte Castelo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f80cfe6c-f07f-4461-852c-b8a3ed25d767', 'Jairo', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cléber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ff3f31ab-7908-484b-811d-6c9300452d95', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia (Cléber)', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a7d8cac8-b9f6-4a47-9f76-a64e8be90ce1', 'Camila', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '22afaae9-68d7-4aaa-8925-5bf6674b526e', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '84006fda-8503-4753-9bf5-3df051516634', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4ddbc50f-0c2b-4d34-90a5-6b1229b900cc', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carol', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f9c4ebef-9a80-4e30-96d6-c8ce1ff81ca7', 'Emanuele', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '28f4a5d3-fcfe-49af-b514-22b5f8177e32', 'Geovana', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '76c416c9-b8e8-4644-9b80-04458484213b', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4dc5a04a-3281-4cee-968a-bc61d83f1210', 'Warley', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Parque Alvorada - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Emerson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '18b71168-2c8d-4a0b-9858-f547f3b67c5e', 'Deise', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Parque Alvorada - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Carol', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bc3d80bb-72b8-46ae-b92f-75891d217d49', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Parque Alvorada - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Camila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '8c884b5a-603f-4c43-82dd-38eaba21bbdd', 'Jetro', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Parque Alvorada - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'aa0cb027-08d8-4433-92fe-6bd9e4a7eec6', 'Olício', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Satélite - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '58f5593b-6ccd-4576-b9ba-3a327901c487', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Satélite - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4ea36c0f-71e4-49e7-ab1d-7c8d9b91ad13', 'Noah', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Satélite - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9bdc7d0d-388d-40a8-b3ee-d0408cf5c19e', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Satélite - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4a5f5788-797a-45f1-b6d7-e3f6e77745eb', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Centro - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ed35496c-3a32-410c-8757-cd3abebc4a67', 'Jéssica', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Centro - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '93ea2784-ac7a-4374-8e8c-7b3337858f2b', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cef669da-d59e-4963-af3c-a18cb59a0a9c', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Casado(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fd34f447-bdf8-4e79-a13f-98e18127662b', 'Emilly', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Camila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4742e5f7-bf73-4f66-b3db-df0808d764e1', 'José Maurício', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Vianópolis - Betim', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bf083089-62f6-4b73-b83f-f4e97aa32645', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leandro', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd14de9ad-0328-4fa6-a37f-83a22cc6dbbc', 'Mizael', NULL, NULL, NULL, NULL, NULL, 'M',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Centro - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jairo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'abb2613a-ebc8-4032-b320-e373038c6987', 'Helen', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Marimbá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'de69b251-743b-4bbd-94fa-2b432eab389c', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0c0d6a63-c59b-46b4-806c-d5df2e98cb3f', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '827ab195-4359-478b-9826-17dc7c69f545', true, false, false, false, false,
    'Solteiro(a)', 'Boa Vista - Juatuba', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Camila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9d85386a-2977-44f0-abf2-ca36fb815f2d', 'William', NULL, NULL, NULL, NULL, NULL, 'M',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Casado(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ronildo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c474b9e3-67e9-4639-a1b3-2a210b64148e', 'Simara', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Casado(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f0968a66-f3e9-400c-bc80-32affb37034b', 'Wenderson', NULL, NULL, NULL, NULL, NULL, 'M',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Casado(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Ronildo', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '903d0419-b1bd-46a5-9537-a5a8b99b3c1d', 'Renata', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Casado(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1c3ddc19-41db-44fd-a8f0-3c0a34b166e7', 'Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Solteiro(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f85afe51-62f0-4587-871e-a09c1030b1fe', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Casado(a)', 'Pousada Del Rey', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'William', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '52a865e0-cd3c-45cf-9db7-6312f51cbe3e', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Casado(a)', 'Pousada Del Rey', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f59a384f-2223-4afd-aa0a-e95e0c214c31', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Solteiro(a)', 'Pousada Del Rey', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marisa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bedc2468-4c37-4434-9ead-95e68a42f126', 'Bianca', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Solteiro(a)', 'Pousada Del Rey', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '475be6c5-18f6-4600-8979-e70e90e4aa9f', 'Gláucia', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Solteiro(a)', 'Resplendor', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Renata', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7a05ad9b-21d4-46b3-88a4-9df066afb94d', 'Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Solteiro(a)', 'Casa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Simone', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3b8b46fb-8aff-4205-bae5-e356e7a2fb1a', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Solteiro(a)', 'Casa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '69f5a2e2-b8be-47f3-8273-fc387c929a34', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '36b7c8fe-ff4d-46fc-9809-b5381810ca35', true, false, false, false, false,
    'Solteiro(a)', 'Casa Branca', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '83893c76-725f-448b-b55c-791bba040776', 'Cléber', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '55f6d5f6-2e1e-472d-b08a-477a87ca34a6', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '895a6259-65e3-42a1-a3a4-0b5080733540', 'Camilla', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cláudia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f07fb6d8-6385-492f-a864-9c10519a2c7f', 'Caio Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Niterói', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Arthur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '145c5222-1c13-48a9-8eef-0a206fe1f549', 'Marina', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Niterói', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3c2c1c31-bad2-428d-b1c1-1e98fee4bfd5', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cléber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5e193f39-6b9f-414e-bcde-98599d93adf5', 'Simone', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '495a32dc-f4d4-430d-a675-493e5bf9f466', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Simone', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a41f4c5c-d0ac-46de-9a87-47d0df1fda09', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2de6beb6-fef1-4f67-b588-946d9ad6889b', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Bandeirinhas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0e444243-f06a-497e-ae34-29e52db8d1ab', 'Vanusa', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Bandeirinhas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0210b6d7-2bee-4b12-b998-facc98d5e391', 'Abner', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cléber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e0da7c6c-7b50-4845-a29a-e50c020311e1', 'Fabiana', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '046b9437-4d75-498f-9091-6ba825d8d942', 'Levi', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Jardim Alterosa', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '16ca23d1-8a79-4fec-b571-89b5802f93f4', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Laranjeiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Simone', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ae55dad1-8b02-4b04-8fa2-3a6c2f2e7617', 'Nely', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Teresópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Priscila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '72792e8b-2ff3-4ff8-a333-9c6d86c84a83', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Laranjeiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marisa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '527ee3ae-b58e-40b2-b9a6-8576a94fa153', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Teresópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Abner', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5299325a-efc6-4992-9c13-cd875e2e0810', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Laranjeiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cléber', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4f35c61f-1da4-4882-b94f-f54369d8eab5', 'Lourdes', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Laranjeiras', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '2705d104-941d-41ed-aa42-ca742dcb51db', 'Denim', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Bruno', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '467666c6-93ce-4458-821c-a54ef6a7dd3b', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Casado(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '40288a12-55f1-4774-80b9-566949babf48', 'Ismael', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ca9c295c-146c-4547-af57-40d91de534b5', 'Isac', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3f7f941f-8fce-46a7-a365-cc992467c40d', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Morada do Trevo', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '04093db6-27cb-4c6f-84f6-ae09813baedd', 'José Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Teresópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'João', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '223b87e0-8722-4554-9b06-70e8e8c5ee29', 'Fagner', NULL, NULL, NULL, NULL, NULL, 'M',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Imbiruçu', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio Vitor', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '807b3d52-dc17-4263-8a26-b5d2230c3b25', 'Lauren', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Renascer', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nara', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ef6a97cb-f2b7-414d-b97c-4785077ee7ee', 'Rosângela', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'São Caetano', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Priscila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '00b06a7c-d266-4416-8d74-1a07a4984b90', 'Suzi', NULL, NULL, NULL, NULL, NULL, 'F',
    '66077532-f18c-43b8-b205-adb8eb21dca1', true, false, false, false, false,
    'Solteiro(a)', 'Imbiruçu', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lourdes', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a863cacd-926d-4dbf-b533-d22e45d80139', 'Marilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd7f09103-d5db-4df4-b30c-9f41a5a1f33d', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '9b88b8e5-e42a-4535-9dfe-21bb83b52c9b', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3be39136-25f7-4c76-b912-68867a128786', 'Gilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bb48c596-0afe-4438-ac36-eccc37ce7f1e', 'Nislândia', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '999e816a-05d3-41a3-8d8a-17a48c16a35e', 'Izabela', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Priscila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4e08f97d-4f9d-48fb-9d85-b24db502ab35', 'Ana Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Nislândia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7bfbc3a8-a811-4757-b046-24eee561707b', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Guilherme', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7840225c-8d31-4ca8-aeae-a627fcae7c4e', 'Wanderluz', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f8f7d7a8-d9d0-4666-a254-858eb78f1bc3', 'Janete', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b3e7623a-3743-4d91-ad75-92a9527d71be', 'Eduarda', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Joelma', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b7a61e05-fc64-4dc5-b24f-1ac6b2ae37d6', 'Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Guilherme', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7a3513b1-9ad3-4f99-a56e-f361f8738812', 'Dilvano', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Dom Bosco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '78a85e6b-6af6-463b-9775-20f19af29e6e', 'Edilene', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Dom Bosco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5699e7ef-6769-444f-89db-bc8800071738', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Dom Bosco', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'be3216a8-a15e-41f7-94fb-cf03402e4328', 'Josué', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'eedb5897-a1b1-4656-9066-c6d82289bf03', 'Lorena', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '544b01f8-a1f6-4425-9913-aa39035ce596', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '190d674e-6c67-4d3b-9555-8603d2db2873', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0db29e6a-c54a-44e6-93b1-9bf2f4052433', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Califórnia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marilson', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '963e2e20-b96f-411f-b77a-58400ece2293', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Califórnia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Patrícia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5826ad0d-ad6e-451c-84cf-708d71f6e21d', 'Suely', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Janete', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c29c03e9-40f4-4a49-95d9-c70f011d4002', 'Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Guilherme', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '426ad53a-a1ef-4472-ab9b-a42a06879e51', 'Talita', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Priscila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '588c1bf6-986f-49b7-a199-c3ba39487d8a', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '02c0f4ec-7d50-4314-af0a-5ef9758dcd11', 'Luciano', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lúcio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ab518771-bb8d-4399-b516-2d912164dfe8', 'Joana', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Casado(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Tatiana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c68989a1-e2d8-4ce7-bc6d-15a68d4c8292', 'Raíssa', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '50102a04-9499-4ba6-8f01-792ef89096d2', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e1a3052a-79d6-4bb5-bf7a-a19b88ba18f3', 'Abner', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '88001175-a896-46ee-8372-d22b2e255f83', 'Ranma', NULL, NULL, NULL, NULL, NULL, 'F',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cae2d2e9-173a-48fa-9a49-52bde41244bc', 'Jonata', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '755cca78-a90d-4e9f-bd2d-02f1f40e7026', 'Isac', NULL, NULL, NULL, NULL, NULL, 'M',
    '83f01f9e-4107-42e2-83ee-a37cef34f184', true, false, false, false, false,
    'Solteiro(a)', 'Contagem', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f85efaba-9cf9-44a9-bae8-fdaf808ebe77', 'Artur Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '908f6a9f-f179-4492-9778-a1d617623be6', 'Thaís Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0b6e11c0-28b7-4d60-8508-160fab7e6e1e', 'Isabela Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Sara (Regis)', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e28e76c0-d13f-41bb-9d0f-447aaee328f5', 'Júlia Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1066a960-6088-4925-b731-4ea27bc7a3da', 'Sofia Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '96dc0c0f-88b8-4e7d-a2ab-1e08712c8b06', 'Douglas Macaúba', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '58b4b501-3778-40a5-82be-6cc8c86dd3af', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '794837e7-a382-4ee3-8e96-f9759370af81', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7effff7e-ff89-4ea1-957d-f09afb0bafe2', 'Thiago', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cf3c4250-2e8b-4779-adf8-d1bc6cd281f0', 'Carine', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '3bac46fe-d2f8-4b11-bc0e-87496bfbbe50', 'Melina', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'fac15d86-4066-41c3-8908-cff49ad3e522', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Betânia', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f1d794c5-eeaf-438f-a083-61e37db7f481', 'Diego', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '14ad3d68-7bdf-4ae0-9586-0041f218d732', 'Gisele', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '13b0029d-6203-4918-a0ea-d5e0b8129ab8', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '34857cb8-8b87-44de-b7cc-d3d73a85dba8', 'Graziele', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Érika (Alexandre)', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b1a60326-126f-4071-be7f-116b9057bdb8', 'Imaculada', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c13c725b-3137-4c43-a8e9-15e540325e36', 'Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1656669f-a404-4b39-94b4-02fde1f89672', 'Vinícios', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Artur', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd1c42487-08d1-4cf9-b697-77cf9246cf61', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '96a58cd2-1995-4185-b20b-a92b9ebc51e7', 'Ana Eloísa', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '01eed741-7f47-4b43-9d50-3e9d2345bb93', 'Maria Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '38f49a15-36d2-451e-8d60-4ff8ab93d731', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1ed8b73d-1a8a-46e2-b0aa-6ba8360db32f', 'Martim', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f3beee46-fb10-49c0-a584-df0fab331614', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Casado(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '86689f21-374b-47f2-9313-f02f33fd819f', 'Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Suzana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '20b18900-1d5a-4617-8f98-b29314a10cf3', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd0fd103a-198e-4ef8-9d2c-6fdc70f0b448', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0691343d-9160-44da-ac60-8dc1b5a859b6', 'Isaque', NULL, NULL, NULL, NULL, NULL, 'M',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Riacho', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd31a81ca-ada5-41bd-acd1-3f2d40991bad', 'Zélia', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '5ff875ff-8322-4c09-945a-1175571bb0d3', 'Keila', NULL, NULL, NULL, NULL, NULL, 'F',
    '4320d5da-ec05-4d97-9118-03d326fae3e2', true, false, false, false, false,
    'Solteiro(a)', 'Eldorado', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Thaís', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '10f27076-8ad1-4b6c-96b6-0bcfce118d21', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Bom Retiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e4fb9fdc-8ef5-40d5-99c5-a79638f569fc', 'Leila', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Bom Retiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Martim', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '19de1bab-d871-440e-8bb8-d9ac5660f3b6', 'Ivan', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Bom Retiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Caio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6ed21ce0-d15a-46d6-938e-e46bc0192bf6', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Bom Retiro', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '23868771-e51d-46a5-a2bc-d2680ecd2194', 'Eliel', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Ponte Alta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a8f224cf-d8b8-4c91-aea0-2080a88ccde4', 'Fabíola', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Ponte Alta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0ad14a21-1b97-4ccb-a41f-887c0ac7cf7a', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Ponte Alta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a040ae8f-ab01-4c18-9411-b3b3c00d676c', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Ponte Alta', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '563b566b-c35d-46ec-9583-72b47d07281d', 'Ramon', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Itacolomi', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'bfe75fc9-f016-44e7-90f5-2aa7a745383b', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Itacolomi', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '091f9dc9-92bd-4685-853c-5d80c7e86921', 'Ravi', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Itacolomi', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '55d77b7f-629b-4cd2-9b0b-2ad824f983b4', 'Melissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Itacolomi', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e245e00f-8c14-490e-88ef-ba6a0a10b43f', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '775b69aa-09b8-40fb-90a5-b8147eefe466', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '64abdbd3-d317-4637-9b2e-4535716a9cae', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Esmeraldas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f6bcf7f9-945d-4272-bdc2-75021465bc1c', 'Antônio', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Jardim Brasília', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '1e692cbb-dde9-4f45-823c-6686487116f5', 'Jaqueline', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Jardim Brasília', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '64b449c0-96b8-41a3-86df-16a57cf2bdd8', 'Verônica', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Nossa Senhora das Graças', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Leila', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '02d456d5-b395-4a96-a362-fb2e7476badf', 'Nileide', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Niterói', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Jaque', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f04dda79-d9e1-475d-928c-a5dce6bd5834', 'Fábio', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6a392324-bef0-4715-ab94-85a334eb2d91', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '34d024c4-6173-4469-9e95-07d489c9f665', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ac1a10a0-153d-4eb3-a105-14803f82c0df', 'Suzana', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ebb403e9-ec1f-44b6-875a-9fe7e03d4c84', 'Lorena', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6a0889e7-71ce-4414-87aa-678557370e0f', 'Asaph', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Colonial', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6fa2d7da-daeb-4cea-9b02-fea2168bfb01', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Vianópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd7096cec-4242-458a-9999-6ec2bfc84eb2', 'Tainara', NULL, NULL, NULL, NULL, NULL, 'F',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Casado(a)', 'Vianópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Lucas', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a5bdf968-9e12-4d84-8bc7-1d40b25f8a79', 'Théo', NULL, NULL, NULL, NULL, NULL, 'M',
    '04a6bc60-55cd-4da5-9512-4b2be231863e', true, false, false, false, false,
    'Solteiro(a)', 'Vianópolis', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7d4c46f0-4ed3-4bf6-ae29-98c1df090fca', 'Cláudio Lopes', NULL, NULL, NULL, NULL, NULL, 'M',
    '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db', true, false, false, false, false,
    'Casado(a)', 'Interlagos - Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Douglas Martins', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'cb31b953-06da-43eb-8b0e-af0b9390a0ae', 'Zulmira Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db', true, false, false, false, false,
    'Casado(a)', 'Interlagos - Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Welen Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '7ef881ab-7e0d-4d21-87bd-8eb74904a379', 'Cristina Barbosa', NULL, NULL, NULL, NULL, NULL, 'F',
    '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db', true, false, false, false, false,
    'Solteiro(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Welen Cristina', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'd5314492-4f0c-410f-844b-e0328304bc5a', 'Ismênia Ferreira Rezende', NULL, NULL, NULL, NULL, NULL, 'F',
    '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db', true, false, false, false, false,
    'Solteiro(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina Barbosa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '62c7254d-5c57-491d-ade0-34071ca96681', 'Maria das Graças', NULL, NULL, NULL, NULL, NULL, 'F',
    '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db', true, false, false, false, false,
    'Solteiro(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Cristina Barbosa', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b45ce3b0-9910-4544-b199-0a91fddd9ce9', 'Samuel Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, 'M',
    '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db', true, false, false, false, false,
    'Casado(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Danilo Ferreira', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '07193709-1bc4-41ec-bddc-02c409210275', 'Kamila Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, 'F',
    '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db', true, false, false, false, false,
    'Casado(a)', 'Sete Lagoas', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Melry Laine', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '4778ed70-4974-4e5a-ab7b-f4d50c257bd5', 'José Antônio', NULL, NULL, NULL, NULL, NULL, 'M',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Marinho', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '015ef6dc-288f-4266-ae6c-7eb878294df3', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Quênia', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'e4cb38f5-0fc2-4af1-9431-23e61e51bf0b', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Wellington', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0a60cc91-b996-4028-8175-a8c8858a67cd', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Raquel', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f0731d7b-5533-4415-87e3-fc5fba5e2287', 'Uyara', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Solteiro(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a4a5df28-ad0a-4eb7-9373-299ec6573932', 'Uyrlan', NULL, NULL, NULL, NULL, NULL, 'M',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Antônio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '94be688c-539d-4a7d-b1fc-b829d40c3692', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '835cd260-fd18-4184-ae80-6bf27b21a158', 'Suzana', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Solteiro(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ce7f1091-e6a6-40f5-9aa6-6a1dd38d34c5', 'Welington', NULL, NULL, NULL, NULL, NULL, 'M',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'José Antônio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'c1134a6f-178d-40fa-affd-6d94d8fae52f', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Eliane', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'f6de8a28-dcb2-4453-b41d-dfeec0ed42fd', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Solteiro(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '68e36a98-50b2-41e9-806e-d00fd37c580a', 'Ariane', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Solteiro(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Adriana', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '05374aa2-ab3c-4909-9393-e0dd371f36f4', 'Hebert', NULL, NULL, NULL, NULL, NULL, 'M',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
    'Casado(a)', 'Santa Bárbara', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'ad1328a6-078f-4e85-835b-6a422cf12fdb', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    'f607a18b-e503-4039-a662-51ac41abfff9', true, false, false, false, false,
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

  -- Vinculação explícita de user_id nos perfis principais
  UPDATE public.profiles SET user_id = gabriel_auth_id WHERE id = gabriel_id;
  UPDATE public.profiles SET user_id = fernando_auth_id WHERE id = fernando_id;
  UPDATE public.profiles SET user_id = clara_auth_id WHERE id = clara_id;


  -- ==========================================================================
  -- 5. ATUALIZAR LÍDERES DOS GCs (35 Grupos)
  -- ==========================================================================

  UPDATE public.home_groups SET leader_1_id = 'd10f39b4-92c7-4967-9a82-69ad771457a1', leader_2_id = NULL WHERE id = '4650dacd-e1f8-4f2c-a11a-47da76f39fea';
  UPDATE public.home_groups SET leader_1_id = '76385bbe-a540-4638-8013-609b49a6a2fe', leader_2_id = '2020229d-7979-4cbb-8fab-f021f18b825e' WHERE id = '00500a12-bfa8-4555-94e1-aeb4ab033573';
  UPDATE public.home_groups SET leader_1_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1', leader_2_id = '62cdd14f-499e-4fd7-bfc8-60c7d79eca68' WHERE id = '789dae9f-84df-4b2f-b4be-473752444c8f';
  UPDATE public.home_groups SET leader_1_id = 'd1952ca6-0fc8-4d25-bb5c-27e539f5e1eb', leader_2_id = NULL WHERE id = '5396eee2-7aa4-4f85-ba46-5941f198a06d';
  UPDATE public.home_groups SET leader_1_id = '20537b91-617f-4d87-85b9-3ce0577c9b5c', leader_2_id = NULL WHERE id = 'e36115b1-cdf7-42d4-b957-bd9f616cbe46';
  UPDATE public.home_groups SET leader_1_id = 'a648effe-54bf-4d50-9a1e-4772e71bbe3e', leader_2_id = NULL WHERE id = '46d15d87-d30e-4ac0-9991-3749a4f72c67';
  UPDATE public.home_groups SET leader_1_id = '7af0ac74-e184-4e33-bb80-bd12b75bc1cb', leader_2_id = NULL WHERE id = '30ca5fe2-0981-4900-8db9-6ba7c6cc0cb2';
  UPDATE public.home_groups SET leader_1_id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d', leader_2_id = NULL WHERE id = '86fed0c9-3cea-4a3a-abd5-7f54e82d28b8';
  UPDATE public.home_groups SET leader_1_id = '959b2fae-5169-4dea-a573-5f4bb069fbc3', leader_2_id = NULL WHERE id = 'e2fa43ed-bb4e-4422-a77e-f51e9cb6c452';
  UPDATE public.home_groups SET leader_1_id = '526cc3b4-cb7a-4b0a-b89d-6c1064ddd257', leader_2_id = NULL WHERE id = '09782827-90f8-404c-9018-2308258a795c';
  UPDATE public.home_groups SET leader_1_id = '28bab668-c8b2-4246-b2ca-d4a3329e88b2', leader_2_id = '01cffd07-e218-42d6-89f9-c12af443e8fe' WHERE id = '2764260c-e49f-4cbd-9daa-0803989641d3';
  UPDATE public.home_groups SET leader_1_id = '60d5d00e-1ad7-43df-8cd4-a78be04e6f66', leader_2_id = '5ffeca61-7cd6-4cf1-adc6-d48959409cb0' WHERE id = 'baa7dafb-99d5-4812-bc48-3b5642a82365';
  UPDATE public.home_groups SET leader_1_id = '39ba647e-b4c9-4d9d-a376-c7b4b5b05ee1', leader_2_id = NULL WHERE id = '9a52e5a9-3676-4492-809f-2daf46fd1e77';
  UPDATE public.home_groups SET leader_1_id = '060c9b8a-9173-4c73-afb1-348868616c14', leader_2_id = NULL WHERE id = '6ec2e0df-6b9f-4f7d-915a-b945cff55c0c';
  UPDATE public.home_groups SET leader_1_id = '2677d29f-1562-41cd-9165-d007e2ebd21c', leader_2_id = NULL WHERE id = 'e86669d4-fd46-4053-b003-b2e19603ab3c';
  UPDATE public.home_groups SET leader_1_id = '2ff78bac-b9be-4f2b-82e3-b072780d15b8', leader_2_id = 'fd3b4ca9-f0f3-4e55-a710-718bbbc4ff96' WHERE id = '9148f457-4658-4cc8-8fcb-eaa22ff2a2fb';
  UPDATE public.home_groups SET leader_1_id = 'e4b579fe-e0da-4041-a958-a78e79c805dd', leader_2_id = '7cc5d3fd-5602-41b8-a8b0-2a601502657c' WHERE id = '3380d492-b8a0-4b4a-b532-fbde9e288f0e';
  UPDATE public.home_groups SET leader_1_id = '20e07137-576a-499e-8fda-2bbc44badc2d', leader_2_id = '796d53cc-857c-4dc2-a2ab-004f6a37324c' WHERE id = '91cb3ff8-9bfc-4a65-a379-18d6c8d644e3';
  UPDATE public.home_groups SET leader_1_id = '75140740-0ff3-4301-80e2-d690e8c3631a', leader_2_id = NULL WHERE id = '38438326-8b6f-41e4-894f-5514e834a762';
  UPDATE public.home_groups SET leader_1_id = '60f23c80-fef9-4368-87c8-4fad26594ad8', leader_2_id = NULL WHERE id = '22e95001-26cc-4b11-aca6-06ddb854bc6d';
  UPDATE public.home_groups SET leader_1_id = '4b33e034-5341-4e8a-a7cc-e86aa07de102', leader_2_id = '64fed90e-bed3-477b-b296-e3284bd747c3' WHERE id = '4c9a7389-ba43-4fbb-b635-f03229f9eade';
  UPDATE public.home_groups SET leader_1_id = '27dcb3c1-c18e-4218-80b4-05d0a1b8a5ab', leader_2_id = NULL WHERE id = '9baef366-eb8b-409c-bfdb-363fb9cc5b0a';
  UPDATE public.home_groups SET leader_1_id = '81659905-131f-4a84-aafb-1ab3d9f0693d', leader_2_id = NULL WHERE id = '64791204-ba0c-4881-b13f-f14d2ceeac20';
  UPDATE public.home_groups SET leader_1_id = 'f7d3c8ab-4309-4b4f-a235-da8204f07b86', leader_2_id = 'a6dfb526-08b9-452d-bc99-7384ffb0e521' WHERE id = 'bf4cb59b-2698-4530-aeb4-fb4522387152';
  UPDATE public.home_groups SET leader_1_id = '747b38d7-b84b-4039-9033-6fee34f9bddf', leader_2_id = NULL WHERE id = '8a447ab1-0b6a-4b93-ba2c-0026ca85b730';
  UPDATE public.home_groups SET leader_1_id = '15b6d388-0772-477d-91b1-bc3504a0bb21', leader_2_id = NULL WHERE id = '03acbb31-1865-4ed9-be93-b16da9be65b2';
  UPDATE public.home_groups SET leader_1_id = '6a6a3f14-83fa-4a44-b0cb-f33de4ba029c', leader_2_id = '01de7ea5-c4fe-4330-a5db-e90ee9b75999' WHERE id = 'b4cfb8ac-be3e-4afa-a686-aacd79c79e6c';
  UPDATE public.home_groups SET leader_1_id = 'f80cfe6c-f07f-4461-852c-b8a3ed25d767', leader_2_id = NULL WHERE id = '827ab195-4359-478b-9826-17dc7c69f545';
  UPDATE public.home_groups SET leader_1_id = '9d85386a-2977-44f0-abf2-ca36fb815f2d', leader_2_id = NULL WHERE id = '36b7c8fe-ff4d-46fc-9809-b5381810ca35';
  UPDATE public.home_groups SET leader_1_id = '83893c76-725f-448b-b55c-791bba040776', leader_2_id = 'f07fb6d8-6385-492f-a864-9c10519a2c7f' WHERE id = '66077532-f18c-43b8-b205-adb8eb21dca1';
  UPDATE public.home_groups SET leader_1_id = 'a863cacd-926d-4dbf-b533-d22e45d80139', leader_2_id = NULL WHERE id = '83f01f9e-4107-42e2-83ee-a37cef34f184';
  UPDATE public.home_groups SET leader_1_id = 'f85efaba-9cf9-44a9-bae8-fdaf808ebe77', leader_2_id = NULL WHERE id = '4320d5da-ec05-4d97-9118-03d326fae3e2';
  UPDATE public.home_groups SET leader_1_id = '10f27076-8ad1-4b6c-96b6-0bcfce118d21', leader_2_id = NULL WHERE id = '04a6bc60-55cd-4da5-9512-4b2be231863e';
  UPDATE public.home_groups SET leader_1_id = '7d4c46f0-4ed3-4bf6-ae29-98c1df090fca', leader_2_id = NULL WHERE id = '6f3832b4-1a02-48e3-bbf3-8fcb75aef0db';
  UPDATE public.home_groups SET leader_1_id = '4778ed70-4974-4e5a-ab7b-f4d50c257bd5', leader_2_id = NULL WHERE id = 'f607a18b-e503-4039-a662-51ac41abfff9';

  -- ==========================================================================
  -- 6. ATUALIZAR CASAMENTOS (spouse_id) E FILIAÇÃO (father_id, mother_id)
  -- ==========================================================================

  UPDATE public.profiles SET spouse_id = '9c9ad423-9cd4-46c8-acd4-05e1053d9896' WHERE id = 'd10f39b4-92c7-4967-9a82-69ad771457a1';
  UPDATE public.profiles SET spouse_id = 'd10f39b4-92c7-4967-9a82-69ad771457a1' WHERE id = '9c9ad423-9cd4-46c8-acd4-05e1053d9896';
  UPDATE public.profiles SET spouse_id = 'a52a6748-767f-4c5d-b6c4-3cd96572cd59' WHERE id = 'ed56e011-a066-49c8-8233-e3b5f50140af';
  UPDATE public.profiles SET spouse_id = 'ed56e011-a066-49c8-8233-e3b5f50140af' WHERE id = 'a52a6748-767f-4c5d-b6c4-3cd96572cd59';
  UPDATE public.profiles SET spouse_id = 'b48c1d94-9e72-445b-b469-4a2c00a74e99' WHERE id = '57d74b4b-3280-497a-87fc-9929e70eddcd';
  UPDATE public.profiles SET spouse_id = '57d74b4b-3280-497a-87fc-9929e70eddcd' WHERE id = 'b48c1d94-9e72-445b-b469-4a2c00a74e99';
  UPDATE public.profiles SET spouse_id = '2c08372b-4163-45f2-b106-ee4fe57cd0c9' WHERE id = '2092d89f-7c41-4cde-9666-72db932250e5';
  UPDATE public.profiles SET spouse_id = '2092d89f-7c41-4cde-9666-72db932250e5' WHERE id = '2c08372b-4163-45f2-b106-ee4fe57cd0c9';
  UPDATE public.profiles SET spouse_id = '6b604757-d4ef-40d7-beb0-514888126d1e' WHERE id = '18199521-b88c-45ba-8973-194040fe970b';
  UPDATE public.profiles SET spouse_id = '18199521-b88c-45ba-8973-194040fe970b' WHERE id = '6b604757-d4ef-40d7-beb0-514888126d1e';
  UPDATE public.profiles SET spouse_id = 'f1acb2a6-60ed-43ca-927b-7737c7a799b5' WHERE id = '6717d16b-3add-4977-a824-a9c6bc2f9c13';
  UPDATE public.profiles SET spouse_id = '6717d16b-3add-4977-a824-a9c6bc2f9c13' WHERE id = 'f1acb2a6-60ed-43ca-927b-7737c7a799b5';
  UPDATE public.profiles SET spouse_id = 'eaffce78-f113-4ead-aa0d-5ae9a8c5a110' WHERE id = '95da0514-9444-4f29-a788-9d782b842895';
  UPDATE public.profiles SET spouse_id = '95da0514-9444-4f29-a788-9d782b842895' WHERE id = 'eaffce78-f113-4ead-aa0d-5ae9a8c5a110';
  UPDATE public.profiles SET spouse_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '76385bbe-a540-4638-8013-609b49a6a2fe';
  UPDATE public.profiles SET spouse_id = '76385bbe-a540-4638-8013-609b49a6a2fe' WHERE id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f';
  UPDATE public.profiles SET spouse_id = '8774e4d7-3520-464a-9ba9-3ef1d0c6e261' WHERE id = 'eb88342d-ad13-4b1a-9059-e5ff58db0ead';
  UPDATE public.profiles SET spouse_id = 'eb88342d-ad13-4b1a-9059-e5ff58db0ead' WHERE id = '8774e4d7-3520-464a-9ba9-3ef1d0c6e261';
  UPDATE public.profiles SET spouse_id = 'a23f3eb2-c9e5-495b-84c3-ecc4670bcb26' WHERE id = '0f0f28df-102c-4071-894e-389e41360cb1';
  UPDATE public.profiles SET spouse_id = '0f0f28df-102c-4071-894e-389e41360cb1' WHERE id = 'a23f3eb2-c9e5-495b-84c3-ecc4670bcb26';
  UPDATE public.profiles SET spouse_id = '93ce9392-ac77-4f5b-a4a0-bc3fa8ee0644' WHERE id = 'c163c8a6-d96f-4980-8242-fe3e94f85fb7';
  UPDATE public.profiles SET spouse_id = 'c163c8a6-d96f-4980-8242-fe3e94f85fb7' WHERE id = '93ce9392-ac77-4f5b-a4a0-bc3fa8ee0644';
  UPDATE public.profiles SET spouse_id = '451700ce-7eff-49d7-a787-f99a9eda2f8e' WHERE id = '075eabfb-81bd-4211-a4dd-a20b3e7fed47';
  UPDATE public.profiles SET spouse_id = '075eabfb-81bd-4211-a4dd-a20b3e7fed47' WHERE id = '451700ce-7eff-49d7-a787-f99a9eda2f8e';
  UPDATE public.profiles SET spouse_id = '1dc0ac57-4bbb-46b5-abae-938828807b02' WHERE id = '6ed4afbd-1081-4c81-be12-f03628822bba';
  UPDATE public.profiles SET spouse_id = '6ed4afbd-1081-4c81-be12-f03628822bba' WHERE id = '1dc0ac57-4bbb-46b5-abae-938828807b02';
  UPDATE public.profiles SET spouse_id = '18cbb5f8-0567-41a9-974b-1182d38942d5' WHERE id = '2020229d-7979-4cbb-8fab-f021f18b825e';
  UPDATE public.profiles SET spouse_id = '2020229d-7979-4cbb-8fab-f021f18b825e' WHERE id = '18cbb5f8-0567-41a9-974b-1182d38942d5';
  UPDATE public.profiles SET spouse_id = '70d7271f-0612-4434-9bab-d8c5ad38bb86' WHERE id = 'a3c9a07c-017c-4c35-a164-9fca6da79b4c';
  UPDATE public.profiles SET spouse_id = 'a3c9a07c-017c-4c35-a164-9fca6da79b4c' WHERE id = '70d7271f-0612-4434-9bab-d8c5ad38bb86';
  UPDATE public.profiles SET spouse_id = '8103138f-6084-4eb2-b852-be3d55cd19ba' WHERE id = '094adf18-1186-4802-a0c2-01852547ca63';
  UPDATE public.profiles SET spouse_id = '094adf18-1186-4802-a0c2-01852547ca63' WHERE id = '8103138f-6084-4eb2-b852-be3d55cd19ba';
  UPDATE public.profiles SET spouse_id = 'ee51a38f-1fa5-4a3a-bf56-403db185980b' WHERE id = '38644b54-ac21-4bfd-8444-85619f985a83';
  UPDATE public.profiles SET spouse_id = '38644b54-ac21-4bfd-8444-85619f985a83' WHERE id = 'ee51a38f-1fa5-4a3a-bf56-403db185980b';
  UPDATE public.profiles SET spouse_id = '584fa9fb-c171-46f5-8196-1a056d89527b' WHERE id = '2bf1deac-98cb-43ab-878e-aa8d559cca75';
  UPDATE public.profiles SET spouse_id = '2bf1deac-98cb-43ab-878e-aa8d559cca75' WHERE id = '584fa9fb-c171-46f5-8196-1a056d89527b';
  UPDATE public.profiles SET spouse_id = '88505968-39c9-4785-aa66-1eed08165c32' WHERE id = '31ca95d0-c658-4dc9-8116-8048726048f3';
  UPDATE public.profiles SET spouse_id = '31ca95d0-c658-4dc9-8116-8048726048f3' WHERE id = '88505968-39c9-4785-aa66-1eed08165c32';
  UPDATE public.profiles SET spouse_id = '02bf68cb-e556-4b65-a89e-7b236d235693' WHERE id = '62cdd14f-499e-4fd7-bfc8-60c7d79eca68';
  UPDATE public.profiles SET spouse_id = '62cdd14f-499e-4fd7-bfc8-60c7d79eca68' WHERE id = '02bf68cb-e556-4b65-a89e-7b236d235693';
  UPDATE public.profiles SET spouse_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = 'eb49b757-df17-400b-ae00-8e0cd3397de1';
  UPDATE public.profiles SET spouse_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = '77da84a6-4557-4582-a4ca-5d11246e5e99';
  UPDATE public.profiles SET spouse_id = '299d81b7-08b1-4fa6-b026-f45a65c684e0' WHERE id = 'a573ee8c-e8c2-4501-b484-dfef25e04a6c';
  UPDATE public.profiles SET spouse_id = 'a573ee8c-e8c2-4501-b484-dfef25e04a6c' WHERE id = '299d81b7-08b1-4fa6-b026-f45a65c684e0';
  UPDATE public.profiles SET spouse_id = '8bcec8d5-0fdf-402d-a963-61de788fc967' WHERE id = '9cb51b1b-c865-4d6e-a6c9-29730d247a65';
  UPDATE public.profiles SET spouse_id = '9cb51b1b-c865-4d6e-a6c9-29730d247a65' WHERE id = '8bcec8d5-0fdf-402d-a963-61de788fc967';
  UPDATE public.profiles SET spouse_id = 'f10adea6-2436-468e-b214-937f20a4e094' WHERE id = '1681cb6a-b484-4030-bfb1-b33aea39ca9d';
  UPDATE public.profiles SET spouse_id = '1681cb6a-b484-4030-bfb1-b33aea39ca9d' WHERE id = 'f10adea6-2436-468e-b214-937f20a4e094';
  UPDATE public.profiles SET spouse_id = '86c3cf40-e6be-4004-a67b-30a8e1bc6801' WHERE id = 'efa67ef3-8431-4adf-817b-3485bdf5526e';
  UPDATE public.profiles SET spouse_id = 'efa67ef3-8431-4adf-817b-3485bdf5526e' WHERE id = '86c3cf40-e6be-4004-a67b-30a8e1bc6801';
  UPDATE public.profiles SET spouse_id = '9471ce5d-592b-43a5-b642-eca9376ade77' WHERE id = '135eb50a-71cd-4534-8edc-4d70e441f992';
  UPDATE public.profiles SET spouse_id = '135eb50a-71cd-4534-8edc-4d70e441f992' WHERE id = '9471ce5d-592b-43a5-b642-eca9376ade77';
  UPDATE public.profiles SET spouse_id = '54b85487-74c4-47fc-9a54-4a7ad7440ce2' WHERE id = 'd601c038-8bef-439d-8abd-8e441694e063';
  UPDATE public.profiles SET spouse_id = 'd601c038-8bef-439d-8abd-8e441694e063' WHERE id = '54b85487-74c4-47fc-9a54-4a7ad7440ce2';
  UPDATE public.profiles SET spouse_id = '70215bab-9e3d-4a7c-94e4-762e1a164792' WHERE id = 'd1952ca6-0fc8-4d25-bb5c-27e539f5e1eb';
  UPDATE public.profiles SET spouse_id = 'd1952ca6-0fc8-4d25-bb5c-27e539f5e1eb' WHERE id = '70215bab-9e3d-4a7c-94e4-762e1a164792';
  UPDATE public.profiles SET spouse_id = '7e7eccaf-13ba-4a6e-8314-25a385bd99e1' WHERE id = 'e3186275-49bc-4908-8bb0-1a703d6e04f4';
  UPDATE public.profiles SET spouse_id = 'e3186275-49bc-4908-8bb0-1a703d6e04f4' WHERE id = '7e7eccaf-13ba-4a6e-8314-25a385bd99e1';
  UPDATE public.profiles SET spouse_id = '8497d209-25dd-4c37-848a-71a5ce583a4e' WHERE id = '18a9e871-da19-4167-ae79-0a0f4d7ee177';
  UPDATE public.profiles SET spouse_id = '18a9e871-da19-4167-ae79-0a0f4d7ee177' WHERE id = '8497d209-25dd-4c37-848a-71a5ce583a4e';
  UPDATE public.profiles SET spouse_id = '91a31c18-cc8e-4cb8-ace6-1dba6277426c' WHERE id = '2be9bae1-598f-4ef9-8bae-29c5b7f8ec75';
  UPDATE public.profiles SET spouse_id = '2be9bae1-598f-4ef9-8bae-29c5b7f8ec75' WHERE id = '91a31c18-cc8e-4cb8-ace6-1dba6277426c';
  UPDATE public.profiles SET spouse_id = '550512f2-af6c-4275-b162-28eaabd2f610' WHERE id = '432d4817-9d00-43de-b3cb-980b6f076573';
  UPDATE public.profiles SET spouse_id = '432d4817-9d00-43de-b3cb-980b6f076573' WHERE id = '550512f2-af6c-4275-b162-28eaabd2f610';
  UPDATE public.profiles SET spouse_id = '92bcf7d0-2e22-43f6-a552-223cd710b0f4' WHERE id = 'baa8946b-a7c8-4644-9ac0-60d4ee5b1fd8';
  UPDATE public.profiles SET spouse_id = 'baa8946b-a7c8-4644-9ac0-60d4ee5b1fd8' WHERE id = '92bcf7d0-2e22-43f6-a552-223cd710b0f4';
  UPDATE public.profiles SET spouse_id = '2f962c77-17f1-4a34-ab50-4a916dd3ea67' WHERE id = 'a01be850-e0a9-43bc-a1fe-71a8fc25584a';
  UPDATE public.profiles SET spouse_id = 'a01be850-e0a9-43bc-a1fe-71a8fc25584a' WHERE id = '2f962c77-17f1-4a34-ab50-4a916dd3ea67';
  UPDATE public.profiles SET spouse_id = 'e92ae35a-3b83-4244-be87-6c7b66a093e5' WHERE id = '738e96d7-e9b4-4ef0-ad0e-3fb8c58cb409';
  UPDATE public.profiles SET spouse_id = '738e96d7-e9b4-4ef0-ad0e-3fb8c58cb409' WHERE id = 'e92ae35a-3b83-4244-be87-6c7b66a093e5';
  UPDATE public.profiles SET spouse_id = '291c477b-a8b1-4b96-b0fe-464ffb3a657c' WHERE id = '20537b91-617f-4d87-85b9-3ce0577c9b5c';
  UPDATE public.profiles SET spouse_id = '20537b91-617f-4d87-85b9-3ce0577c9b5c' WHERE id = '291c477b-a8b1-4b96-b0fe-464ffb3a657c';
  UPDATE public.profiles SET spouse_id = '859de62b-bf20-4d15-be6d-04ff434704ca' WHERE id = 'f384022d-8284-4319-af6e-9fbe52e69d6f';
  UPDATE public.profiles SET spouse_id = 'f384022d-8284-4319-af6e-9fbe52e69d6f' WHERE id = '859de62b-bf20-4d15-be6d-04ff434704ca';
  UPDATE public.profiles SET spouse_id = '3fe1a147-3ca9-4bd0-8b52-7a37bfb4bc91' WHERE id = '8f015bf8-de81-46bc-a02e-0e3c73981164';
  UPDATE public.profiles SET spouse_id = '8f015bf8-de81-46bc-a02e-0e3c73981164' WHERE id = '3fe1a147-3ca9-4bd0-8b52-7a37bfb4bc91';
  UPDATE public.profiles SET spouse_id = 'a0eef8b7-9ebe-4f37-bfd7-da7af7b5af42' WHERE id = '4f545f60-8a6c-46b3-98e7-5e9a9241b39c';
  UPDATE public.profiles SET spouse_id = '4f545f60-8a6c-46b3-98e7-5e9a9241b39c' WHERE id = 'a0eef8b7-9ebe-4f37-bfd7-da7af7b5af42';
  UPDATE public.profiles SET spouse_id = '21edf05f-e86a-4d56-a79b-f6e05fc1e228' WHERE id = '2e1b4dcf-50cd-47bd-b89a-4f39199fdb61';
  UPDATE public.profiles SET spouse_id = '2e1b4dcf-50cd-47bd-b89a-4f39199fdb61' WHERE id = '21edf05f-e86a-4d56-a79b-f6e05fc1e228';
  UPDATE public.profiles SET spouse_id = '827269bb-113e-48b7-ae0a-df513f706c0c' WHERE id = 'a648effe-54bf-4d50-9a1e-4772e71bbe3e';
  UPDATE public.profiles SET spouse_id = 'a648effe-54bf-4d50-9a1e-4772e71bbe3e' WHERE id = '827269bb-113e-48b7-ae0a-df513f706c0c';
  UPDATE public.profiles SET spouse_id = '2bf5aa3a-d062-405c-bb4f-d647ab8c6f07' WHERE id = '7079bc19-c16e-40e1-94fc-adfac82af3e5';
  UPDATE public.profiles SET spouse_id = '7079bc19-c16e-40e1-94fc-adfac82af3e5' WHERE id = '2bf5aa3a-d062-405c-bb4f-d647ab8c6f07';
  UPDATE public.profiles SET spouse_id = 'e89dbd5d-af0f-47f2-823c-5c0f2c6b304d' WHERE id = '5ebad0a7-908d-48b6-a9c1-d4ba7a78ab3e';
  UPDATE public.profiles SET spouse_id = '5ebad0a7-908d-48b6-a9c1-d4ba7a78ab3e' WHERE id = 'e89dbd5d-af0f-47f2-823c-5c0f2c6b304d';
  UPDATE public.profiles SET spouse_id = '1f346268-7371-47f7-bb24-51808b5823aa' WHERE id = '30e1a2ae-6be3-4203-9068-372425d39a05';
  UPDATE public.profiles SET spouse_id = '30e1a2ae-6be3-4203-9068-372425d39a05' WHERE id = '1f346268-7371-47f7-bb24-51808b5823aa';
  UPDATE public.profiles SET spouse_id = '97e8a600-d08b-421b-8d1b-9a28daf5a7be' WHERE id = '0d390dc3-aa8a-4863-a8c7-dfc2ebdca5cb';
  UPDATE public.profiles SET spouse_id = '0d390dc3-aa8a-4863-a8c7-dfc2ebdca5cb' WHERE id = '97e8a600-d08b-421b-8d1b-9a28daf5a7be';
  UPDATE public.profiles SET spouse_id = '173d4037-e958-4821-95a9-79e7299e94b9' WHERE id = '7af0ac74-e184-4e33-bb80-bd12b75bc1cb';
  UPDATE public.profiles SET spouse_id = '7af0ac74-e184-4e33-bb80-bd12b75bc1cb' WHERE id = '173d4037-e958-4821-95a9-79e7299e94b9';
  UPDATE public.profiles SET spouse_id = '6052821f-8200-493d-827d-52ffe6b6aa34' WHERE id = 'be0ca2d4-8557-4d83-a075-0c942654646e';
  UPDATE public.profiles SET spouse_id = 'be0ca2d4-8557-4d83-a075-0c942654646e' WHERE id = '6052821f-8200-493d-827d-52ffe6b6aa34';
  UPDATE public.profiles SET spouse_id = '1d636a29-8d27-493a-9973-e35e74476c54' WHERE id = '53105f33-5e45-45e6-960a-4992d916d7f7';
  UPDATE public.profiles SET spouse_id = '53105f33-5e45-45e6-960a-4992d916d7f7' WHERE id = '1d636a29-8d27-493a-9973-e35e74476c54';
  UPDATE public.profiles SET spouse_id = 'a79f053e-25b7-46fd-bdea-1901ba8328e7' WHERE id = 'cf5751da-3cec-4a07-a3a0-9bd18e08a16b';
  UPDATE public.profiles SET spouse_id = 'cf5751da-3cec-4a07-a3a0-9bd18e08a16b' WHERE id = 'a79f053e-25b7-46fd-bdea-1901ba8328e7';
  UPDATE public.profiles SET spouse_id = '721c5d9e-004f-4848-986f-1264faacdfae' WHERE id = 'c8d77dab-1aaf-4893-865b-708b3a426ed9';
  UPDATE public.profiles SET spouse_id = 'c8d77dab-1aaf-4893-865b-708b3a426ed9' WHERE id = '721c5d9e-004f-4848-986f-1264faacdfae';
  UPDATE public.profiles SET spouse_id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde' WHERE id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d';
  UPDATE public.profiles SET spouse_id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d' WHERE id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde';
  UPDATE public.profiles SET spouse_id = 'bc3cb641-22c2-4740-97c5-de8bfb35aebc' WHERE id = '1a6883bd-6cd3-4b77-b3d0-2d316b80a676';
  UPDATE public.profiles SET spouse_id = '1a6883bd-6cd3-4b77-b3d0-2d316b80a676' WHERE id = 'bc3cb641-22c2-4740-97c5-de8bfb35aebc';
  UPDATE public.profiles SET spouse_id = 'cd5dabff-935b-499d-991c-d5b06494981f' WHERE id = '49069bca-a1ca-4346-b1eb-aa00419a5c81';
  UPDATE public.profiles SET spouse_id = '49069bca-a1ca-4346-b1eb-aa00419a5c81' WHERE id = 'cd5dabff-935b-499d-991c-d5b06494981f';
  UPDATE public.profiles SET spouse_id = 'e86f8f13-6779-4961-907a-1c8c6fa870b1' WHERE id = 'aa3d2a3c-7f0c-467b-bf85-2952cca85639';
  UPDATE public.profiles SET spouse_id = 'aa3d2a3c-7f0c-467b-bf85-2952cca85639' WHERE id = 'e86f8f13-6779-4961-907a-1c8c6fa870b1';
  UPDATE public.profiles SET spouse_id = '3550ae89-e7cc-426d-bbb5-3bc74cf2775e' WHERE id = '7e630638-b948-429e-b5e0-1f0ff0dcaa30';
  UPDATE public.profiles SET spouse_id = '7e630638-b948-429e-b5e0-1f0ff0dcaa30' WHERE id = '3550ae89-e7cc-426d-bbb5-3bc74cf2775e';
  UPDATE public.profiles SET spouse_id = '8e8fc92d-956e-4c2b-a9fd-1eafcc4f99a3' WHERE id = '83133cf2-3975-4311-8806-3cba0bffeaab';
  UPDATE public.profiles SET spouse_id = '83133cf2-3975-4311-8806-3cba0bffeaab' WHERE id = '8e8fc92d-956e-4c2b-a9fd-1eafcc4f99a3';
  UPDATE public.profiles SET spouse_id = '7db85295-7a6a-4fef-ac5d-530737b9de8b' WHERE id = '2a3eb895-768b-4ff2-bb77-4218c6431631';
  UPDATE public.profiles SET spouse_id = '2a3eb895-768b-4ff2-bb77-4218c6431631' WHERE id = '7db85295-7a6a-4fef-ac5d-530737b9de8b';
  UPDATE public.profiles SET spouse_id = '4b26e83c-029a-44d9-ba6d-ddfd24a22371' WHERE id = 'e1439e40-56c7-4d8f-9e0e-2de14aa23470';
  UPDATE public.profiles SET spouse_id = 'e1439e40-56c7-4d8f-9e0e-2de14aa23470' WHERE id = '4b26e83c-029a-44d9-ba6d-ddfd24a22371';
  UPDATE public.profiles SET spouse_id = 'e329ffd2-65d6-4202-9969-432a4fe276af' WHERE id = '0ababef1-5f5d-436e-8abd-4c06321a96fb';
  UPDATE public.profiles SET spouse_id = '0ababef1-5f5d-436e-8abd-4c06321a96fb' WHERE id = 'e329ffd2-65d6-4202-9969-432a4fe276af';
  UPDATE public.profiles SET spouse_id = '983f9a5f-0ade-42ef-afe0-263ce1440ad2' WHERE id = '959b2fae-5169-4dea-a573-5f4bb069fbc3';
  UPDATE public.profiles SET spouse_id = '959b2fae-5169-4dea-a573-5f4bb069fbc3' WHERE id = '983f9a5f-0ade-42ef-afe0-263ce1440ad2';
  UPDATE public.profiles SET spouse_id = '2642fe06-67a6-4311-8fdf-e99729e30ab0' WHERE id = '3a24ed42-84e7-4591-90a4-8a1d5f3e94a5';
  UPDATE public.profiles SET spouse_id = '3a24ed42-84e7-4591-90a4-8a1d5f3e94a5' WHERE id = '2642fe06-67a6-4311-8fdf-e99729e30ab0';
  UPDATE public.profiles SET spouse_id = '0f0e3aa4-63d3-448c-a2d3-5f58458804ff' WHERE id = 'd9eec09c-4d55-4394-9b46-cfeb465535fa';
  UPDATE public.profiles SET spouse_id = 'd9eec09c-4d55-4394-9b46-cfeb465535fa' WHERE id = '0f0e3aa4-63d3-448c-a2d3-5f58458804ff';
  UPDATE public.profiles SET spouse_id = '97ccb0b0-481c-49ee-9c2b-2f7cc8dff8d7' WHERE id = 'd387f54a-2404-4d75-8abf-ec8e15e2b192';
  UPDATE public.profiles SET spouse_id = 'd387f54a-2404-4d75-8abf-ec8e15e2b192' WHERE id = '97ccb0b0-481c-49ee-9c2b-2f7cc8dff8d7';
  UPDATE public.profiles SET spouse_id = 'cc099159-251d-4faf-bcaf-98498a7f6e53' WHERE id = '19e646e3-8ee2-4759-bce9-271eb6210b0f';
  UPDATE public.profiles SET spouse_id = '19e646e3-8ee2-4759-bce9-271eb6210b0f' WHERE id = 'cc099159-251d-4faf-bcaf-98498a7f6e53';
  UPDATE public.profiles SET spouse_id = 'b039b08d-0e01-4bdc-b987-3ab6f901e3a1' WHERE id = '5bf8572e-cab5-43f6-9f15-9df1cee486e0';
  UPDATE public.profiles SET spouse_id = '5bf8572e-cab5-43f6-9f15-9df1cee486e0' WHERE id = 'b039b08d-0e01-4bdc-b987-3ab6f901e3a1';
  UPDATE public.profiles SET spouse_id = 'a9073378-aa09-4134-945a-aec6e223b4f8' WHERE id = '526cc3b4-cb7a-4b0a-b89d-6c1064ddd257';
  UPDATE public.profiles SET spouse_id = '526cc3b4-cb7a-4b0a-b89d-6c1064ddd257' WHERE id = 'a9073378-aa09-4134-945a-aec6e223b4f8';
  UPDATE public.profiles SET spouse_id = 'f11fa2bd-91cf-4be9-8abf-c5982da1bd68' WHERE id = '5aeda46e-fc73-49f3-9df8-a981e1f36d5f';
  UPDATE public.profiles SET spouse_id = '5aeda46e-fc73-49f3-9df8-a981e1f36d5f' WHERE id = 'f11fa2bd-91cf-4be9-8abf-c5982da1bd68';
  UPDATE public.profiles SET spouse_id = '09b74721-af05-489b-9fa8-51aeca18c043' WHERE id = '98e013bb-c845-4a01-9f29-e30418085f80';
  UPDATE public.profiles SET spouse_id = '98e013bb-c845-4a01-9f29-e30418085f80' WHERE id = '09b74721-af05-489b-9fa8-51aeca18c043';
  UPDATE public.profiles SET spouse_id = 'cb63660a-b0f6-421b-9b5b-06fdaf28de9c' WHERE id = '1d1cdf88-22c8-4687-883f-b1dd4b8fd4b0';
  UPDATE public.profiles SET spouse_id = '1d1cdf88-22c8-4687-883f-b1dd4b8fd4b0' WHERE id = 'cb63660a-b0f6-421b-9b5b-06fdaf28de9c';
  UPDATE public.profiles SET spouse_id = '11d54fe2-8e08-4557-b6aa-9d8fe99ce3e9' WHERE id = 'b97783df-67db-4a60-ad67-dcb6b4ddf9fa';
  UPDATE public.profiles SET spouse_id = 'b97783df-67db-4a60-ad67-dcb6b4ddf9fa' WHERE id = '11d54fe2-8e08-4557-b6aa-9d8fe99ce3e9';
  UPDATE public.profiles SET spouse_id = 'ed4c0016-fa08-4317-ac7b-d4851c1fb11a' WHERE id = 'd2486560-7e90-4ec9-947b-aa53900f970a';
  UPDATE public.profiles SET spouse_id = 'd2486560-7e90-4ec9-947b-aa53900f970a' WHERE id = 'ed4c0016-fa08-4317-ac7b-d4851c1fb11a';
  UPDATE public.profiles SET spouse_id = 'dacf9dd1-d154-47a3-af1b-9f5663eb172e' WHERE id = '01cffd07-e218-42d6-89f9-c12af443e8fe';
  UPDATE public.profiles SET spouse_id = '01cffd07-e218-42d6-89f9-c12af443e8fe' WHERE id = 'dacf9dd1-d154-47a3-af1b-9f5663eb172e';
  UPDATE public.profiles SET spouse_id = 'ff747f86-e7fa-414a-996b-2962be8a6743' WHERE id = '28bab668-c8b2-4246-b2ca-d4a3329e88b2';
  UPDATE public.profiles SET spouse_id = '28bab668-c8b2-4246-b2ca-d4a3329e88b2' WHERE id = 'ff747f86-e7fa-414a-996b-2962be8a6743';
  UPDATE public.profiles SET spouse_id = 'b9c1eb03-54db-4bf2-88a6-226be1640d57' WHERE id = '61bb229d-5043-4586-a1cb-b5e7809b9a42';
  UPDATE public.profiles SET spouse_id = '61bb229d-5043-4586-a1cb-b5e7809b9a42' WHERE id = 'b9c1eb03-54db-4bf2-88a6-226be1640d57';
  UPDATE public.profiles SET spouse_id = '43f76c8d-5a51-4323-90b4-20542b056dd7' WHERE id = '22f124a9-befb-447e-8e8c-e16d14c14f40';
  UPDATE public.profiles SET spouse_id = '22f124a9-befb-447e-8e8c-e16d14c14f40' WHERE id = '43f76c8d-5a51-4323-90b4-20542b056dd7';
  UPDATE public.profiles SET spouse_id = 'cf1d34ee-2080-4088-b5d8-d7731199901a' WHERE id = '770b9d65-c331-466a-854f-4134401e8154';
  UPDATE public.profiles SET spouse_id = '770b9d65-c331-466a-854f-4134401e8154' WHERE id = 'cf1d34ee-2080-4088-b5d8-d7731199901a';
  UPDATE public.profiles SET spouse_id = '233b4286-6217-4db6-a7b9-735f7d08f9e3' WHERE id = '300309cf-bc6b-4b04-8680-25c794dcf29b';
  UPDATE public.profiles SET spouse_id = '300309cf-bc6b-4b04-8680-25c794dcf29b' WHERE id = '233b4286-6217-4db6-a7b9-735f7d08f9e3';
  UPDATE public.profiles SET spouse_id = '52416985-e4a7-4a49-b4b0-433878205c4d' WHERE id = '70f111a7-ed80-4cb9-8df9-a57b334042a5';
  UPDATE public.profiles SET spouse_id = '70f111a7-ed80-4cb9-8df9-a57b334042a5' WHERE id = '52416985-e4a7-4a49-b4b0-433878205c4d';
  UPDATE public.profiles SET spouse_id = '93a88ed5-e784-4d6b-a69c-d7debb496bf3' WHERE id = 'cc31648e-f28f-422a-a4e4-d4f6d4a8a081';
  UPDATE public.profiles SET spouse_id = 'cc31648e-f28f-422a-a4e4-d4f6d4a8a081' WHERE id = '93a88ed5-e784-4d6b-a69c-d7debb496bf3';
  UPDATE public.profiles SET spouse_id = '2a75f8bc-d048-437f-85f3-f2c0f94dee00' WHERE id = 'dc23aa70-fbb4-4b81-9d74-3e5543cca2cb';
  UPDATE public.profiles SET spouse_id = 'dc23aa70-fbb4-4b81-9d74-3e5543cca2cb' WHERE id = '2a75f8bc-d048-437f-85f3-f2c0f94dee00';
  UPDATE public.profiles SET spouse_id = '20eb0250-1390-4a45-8abd-3f3ba349d2c3' WHERE id = '60d5d00e-1ad7-43df-8cd4-a78be04e6f66';
  UPDATE public.profiles SET spouse_id = '60d5d00e-1ad7-43df-8cd4-a78be04e6f66' WHERE id = '20eb0250-1390-4a45-8abd-3f3ba349d2c3';
  UPDATE public.profiles SET spouse_id = '9ae11fee-96fb-4c81-a6cd-57af2541291f' WHERE id = '5ffeca61-7cd6-4cf1-adc6-d48959409cb0';
  UPDATE public.profiles SET spouse_id = '5ffeca61-7cd6-4cf1-adc6-d48959409cb0' WHERE id = '9ae11fee-96fb-4c81-a6cd-57af2541291f';
  UPDATE public.profiles SET spouse_id = 'a8403eae-74c6-4fef-a79f-2847d04efcec' WHERE id = '1eacbe73-b7b9-4b19-b4f8-4396f357f975';
  UPDATE public.profiles SET spouse_id = '1eacbe73-b7b9-4b19-b4f8-4396f357f975' WHERE id = 'a8403eae-74c6-4fef-a79f-2847d04efcec';
  UPDATE public.profiles SET spouse_id = '37a7eca7-d590-4f26-8fda-d63a6377914e' WHERE id = 'b02b4f4f-5b40-4085-a3c9-82db4c266582';
  UPDATE public.profiles SET spouse_id = 'b02b4f4f-5b40-4085-a3c9-82db4c266582' WHERE id = '37a7eca7-d590-4f26-8fda-d63a6377914e';
  UPDATE public.profiles SET spouse_id = 'ba920b1c-2c4f-46c3-ab83-4eef8c657c4a' WHERE id = 'a3f3e01d-de9f-4355-afd9-163ef2baa6ab';
  UPDATE public.profiles SET spouse_id = 'a3f3e01d-de9f-4355-afd9-163ef2baa6ab' WHERE id = 'ba920b1c-2c4f-46c3-ab83-4eef8c657c4a';
  UPDATE public.profiles SET spouse_id = '8b01e7d2-fdb5-4873-beec-0f255c9c1be3' WHERE id = '667b7671-f41e-411c-9c09-650bdf3c3fbf';
  UPDATE public.profiles SET spouse_id = '667b7671-f41e-411c-9c09-650bdf3c3fbf' WHERE id = '8b01e7d2-fdb5-4873-beec-0f255c9c1be3';
  UPDATE public.profiles SET spouse_id = '18cb4392-3c16-46ff-bbac-96af09d8c07c' WHERE id = '39ba647e-b4c9-4d9d-a376-c7b4b5b05ee1';
  UPDATE public.profiles SET spouse_id = '39ba647e-b4c9-4d9d-a376-c7b4b5b05ee1' WHERE id = '18cb4392-3c16-46ff-bbac-96af09d8c07c';
  UPDATE public.profiles SET spouse_id = '5a9dab15-3181-461b-8979-220324e65540' WHERE id = '3769e1a2-b80f-4c23-9328-7d7e2d733e55';
  UPDATE public.profiles SET spouse_id = '3769e1a2-b80f-4c23-9328-7d7e2d733e55' WHERE id = '5a9dab15-3181-461b-8979-220324e65540';
  UPDATE public.profiles SET spouse_id = '0dc1bb25-5c61-4473-a337-2e2d2f66e3a9' WHERE id = '255b5be3-2f4d-45b8-ae42-f41dc52596f5';
  UPDATE public.profiles SET spouse_id = '255b5be3-2f4d-45b8-ae42-f41dc52596f5' WHERE id = '0dc1bb25-5c61-4473-a337-2e2d2f66e3a9';
  UPDATE public.profiles SET spouse_id = 'fbd6a317-24a5-41f9-8da1-f3aa22a33cbf' WHERE id = '5a1d7c3c-cf7f-4c14-ad35-6377e89fbc6c';
  UPDATE public.profiles SET spouse_id = '5a1d7c3c-cf7f-4c14-ad35-6377e89fbc6c' WHERE id = 'fbd6a317-24a5-41f9-8da1-f3aa22a33cbf';
  UPDATE public.profiles SET spouse_id = 'cdcb7800-a3c8-44c9-b782-d0cc98431d61' WHERE id = '3bb28abb-1e36-4b4c-86be-39ede123499b';
  UPDATE public.profiles SET spouse_id = '3bb28abb-1e36-4b4c-86be-39ede123499b' WHERE id = 'cdcb7800-a3c8-44c9-b782-d0cc98431d61';
  UPDATE public.profiles SET spouse_id = '134164ad-c0fb-4c9b-ba42-a512c1aad399' WHERE id = '04691149-7822-419e-af0c-0abc4ca89778';
  UPDATE public.profiles SET spouse_id = '04691149-7822-419e-af0c-0abc4ca89778' WHERE id = '134164ad-c0fb-4c9b-ba42-a512c1aad399';
  UPDATE public.profiles SET spouse_id = 'abfa588a-96e0-468a-85f2-c63a08d5cc96' WHERE id = '1f3eb3b0-f1c2-4c9f-a202-5d52180e8bc5';
  UPDATE public.profiles SET spouse_id = '1f3eb3b0-f1c2-4c9f-a202-5d52180e8bc5' WHERE id = 'abfa588a-96e0-468a-85f2-c63a08d5cc96';
  UPDATE public.profiles SET spouse_id = 'a1e470e1-3742-444f-8834-8f5891892096' WHERE id = 'e9754ebb-7614-4040-9d7f-5b741d07b633';
  UPDATE public.profiles SET spouse_id = 'e9754ebb-7614-4040-9d7f-5b741d07b633' WHERE id = 'a1e470e1-3742-444f-8834-8f5891892096';
  UPDATE public.profiles SET spouse_id = '94734ad2-5b56-4a13-99a1-e8ea21226daa' WHERE id = '060c9b8a-9173-4c73-afb1-348868616c14';
  UPDATE public.profiles SET spouse_id = '060c9b8a-9173-4c73-afb1-348868616c14' WHERE id = '94734ad2-5b56-4a13-99a1-e8ea21226daa';
  UPDATE public.profiles SET spouse_id = '81a0a170-8930-48f2-b505-8cd13b9883c2' WHERE id = 'c0dff264-dc84-45d6-9a4e-da18d047dd73';
  UPDATE public.profiles SET spouse_id = 'c0dff264-dc84-45d6-9a4e-da18d047dd73' WHERE id = '81a0a170-8930-48f2-b505-8cd13b9883c2';
  UPDATE public.profiles SET spouse_id = '3d98a907-ca71-444c-a6e6-c91e31d9ff5c' WHERE id = '2677d29f-1562-41cd-9165-d007e2ebd21c';
  UPDATE public.profiles SET spouse_id = '2677d29f-1562-41cd-9165-d007e2ebd21c' WHERE id = '3d98a907-ca71-444c-a6e6-c91e31d9ff5c';
  UPDATE public.profiles SET spouse_id = 'e69c3258-eecc-422d-aad5-72c658281486' WHERE id = 'b348d9cf-050a-4d0c-a8e2-e1120dc44ce9';
  UPDATE public.profiles SET spouse_id = 'b348d9cf-050a-4d0c-a8e2-e1120dc44ce9' WHERE id = 'e69c3258-eecc-422d-aad5-72c658281486';
  UPDATE public.profiles SET spouse_id = '2c668ccd-0f93-41b2-8743-66b74b4b533b' WHERE id = '6f91d776-8634-4ece-94ae-f3994a84d1a5';
  UPDATE public.profiles SET spouse_id = '6f91d776-8634-4ece-94ae-f3994a84d1a5' WHERE id = '2c668ccd-0f93-41b2-8743-66b74b4b533b';
  UPDATE public.profiles SET spouse_id = '757b9efb-8eda-4fd7-8405-7576e2aa32dd' WHERE id = '461cb7b4-aa06-4eb9-bef5-480815827ebe';
  UPDATE public.profiles SET spouse_id = '461cb7b4-aa06-4eb9-bef5-480815827ebe' WHERE id = '757b9efb-8eda-4fd7-8405-7576e2aa32dd';
  UPDATE public.profiles SET spouse_id = '12bd3171-e22d-4d74-b50d-91c8a20dc721' WHERE id = 'a0a8c1f3-b85b-4651-909e-4676c741b2b9';
  UPDATE public.profiles SET spouse_id = 'a0a8c1f3-b85b-4651-909e-4676c741b2b9' WHERE id = '12bd3171-e22d-4d74-b50d-91c8a20dc721';
  UPDATE public.profiles SET spouse_id = '0b1b930d-73f2-4de5-a858-75faa09fd567' WHERE id = '4fa95ea1-a476-4748-b497-89ae3e5585f8';
  UPDATE public.profiles SET spouse_id = '4fa95ea1-a476-4748-b497-89ae3e5585f8' WHERE id = '0b1b930d-73f2-4de5-a858-75faa09fd567';
  UPDATE public.profiles SET spouse_id = '5d5d13b8-48b6-4458-a9d0-bb5aae9c215e' WHERE id = '2ff78bac-b9be-4f2b-82e3-b072780d15b8';
  UPDATE public.profiles SET spouse_id = '2ff78bac-b9be-4f2b-82e3-b072780d15b8' WHERE id = '5d5d13b8-48b6-4458-a9d0-bb5aae9c215e';
  UPDATE public.profiles SET spouse_id = '563ec794-3f1b-431a-9d37-f3d88b351158' WHERE id = 'fd3b4ca9-f0f3-4e55-a710-718bbbc4ff96';
  UPDATE public.profiles SET spouse_id = 'fd3b4ca9-f0f3-4e55-a710-718bbbc4ff96' WHERE id = '563ec794-3f1b-431a-9d37-f3d88b351158';
  UPDATE public.profiles SET spouse_id = 'bed91864-53a2-4c6e-b35d-ba593e895143' WHERE id = '8c7eeb03-e45d-4b66-8d61-f45d482b344b';
  UPDATE public.profiles SET spouse_id = '8c7eeb03-e45d-4b66-8d61-f45d482b344b' WHERE id = 'bed91864-53a2-4c6e-b35d-ba593e895143';
  UPDATE public.profiles SET spouse_id = '7c4dce9c-31a4-47ad-898d-402428f5afc3' WHERE id = 'e4b579fe-e0da-4041-a958-a78e79c805dd';
  UPDATE public.profiles SET spouse_id = 'e4b579fe-e0da-4041-a958-a78e79c805dd' WHERE id = '7c4dce9c-31a4-47ad-898d-402428f5afc3';
  UPDATE public.profiles SET spouse_id = 'f8fc3a94-f3fd-4467-a992-52262a94b14a' WHERE id = 'c3dee27d-46b7-4b6f-b312-7e0a1f5e3ca8';
  UPDATE public.profiles SET spouse_id = 'c3dee27d-46b7-4b6f-b312-7e0a1f5e3ca8' WHERE id = 'f8fc3a94-f3fd-4467-a992-52262a94b14a';
  UPDATE public.profiles SET spouse_id = 'b9181151-41c7-441a-90a6-949a703ae525' WHERE id = 'a6ca3f63-53e2-407b-a9fa-ae1f9c695380';
  UPDATE public.profiles SET spouse_id = 'a6ca3f63-53e2-407b-a9fa-ae1f9c695380' WHERE id = 'b9181151-41c7-441a-90a6-949a703ae525';
  UPDATE public.profiles SET spouse_id = '947b92b9-c68d-4f75-a8cd-5785f3e1b00c' WHERE id = '8a9a91d2-1bf6-40a1-8a45-e858192d0fb2';
  UPDATE public.profiles SET spouse_id = '8a9a91d2-1bf6-40a1-8a45-e858192d0fb2' WHERE id = '947b92b9-c68d-4f75-a8cd-5785f3e1b00c';
  UPDATE public.profiles SET spouse_id = 'e7f688c6-a018-4870-9f61-ec7be9da2b24' WHERE id = '7cc5d3fd-5602-41b8-a8b0-2a601502657c';
  UPDATE public.profiles SET spouse_id = '7cc5d3fd-5602-41b8-a8b0-2a601502657c' WHERE id = 'e7f688c6-a018-4870-9f61-ec7be9da2b24';
  UPDATE public.profiles SET spouse_id = '520c80c9-aa39-4e3b-b2dc-25f244134337' WHERE id = '1d980dc9-edef-4d20-8f4e-06b5ca740b25';
  UPDATE public.profiles SET spouse_id = '1d980dc9-edef-4d20-8f4e-06b5ca740b25' WHERE id = '520c80c9-aa39-4e3b-b2dc-25f244134337';
  UPDATE public.profiles SET spouse_id = '06d3daf5-c876-4098-b629-a15511ab4f91' WHERE id = 'cc48aec5-2f4c-4cdb-8e61-4680e3df8c83';
  UPDATE public.profiles SET spouse_id = 'cc48aec5-2f4c-4cdb-8e61-4680e3df8c83' WHERE id = '06d3daf5-c876-4098-b629-a15511ab4f91';
  UPDATE public.profiles SET spouse_id = 'e95ff5f1-2d83-4d91-b128-9b90e3545799' WHERE id = '949959ee-1dd0-409e-b9f8-32ed32900042';
  UPDATE public.profiles SET spouse_id = '949959ee-1dd0-409e-b9f8-32ed32900042' WHERE id = 'e95ff5f1-2d83-4d91-b128-9b90e3545799';
  UPDATE public.profiles SET spouse_id = '9aa0ae66-d55f-4866-a489-2adfeb6986f0' WHERE id = '75140740-0ff3-4301-80e2-d690e8c3631a';
  UPDATE public.profiles SET spouse_id = '75140740-0ff3-4301-80e2-d690e8c3631a' WHERE id = '9aa0ae66-d55f-4866-a489-2adfeb6986f0';
  UPDATE public.profiles SET spouse_id = '3bf01b20-b2d7-4a79-ac09-dfe57cb53f85' WHERE id = '6d436adf-b847-406e-bc81-08edec7082d5';
  UPDATE public.profiles SET spouse_id = '6d436adf-b847-406e-bc81-08edec7082d5' WHERE id = '3bf01b20-b2d7-4a79-ac09-dfe57cb53f85';
  UPDATE public.profiles SET spouse_id = 'e71efd7c-f1fb-4657-b177-222ffbbe45f3' WHERE id = 'bac00a53-6c8b-4e62-a103-377d2b317a9b';
  UPDATE public.profiles SET spouse_id = 'bac00a53-6c8b-4e62-a103-377d2b317a9b' WHERE id = 'e71efd7c-f1fb-4657-b177-222ffbbe45f3';
  UPDATE public.profiles SET spouse_id = 'ab486074-4430-4145-a18e-a057cc12ea24' WHERE id = 'b0169324-5c7e-490f-a060-50ffffb76fcc';
  UPDATE public.profiles SET spouse_id = 'b0169324-5c7e-490f-a060-50ffffb76fcc' WHERE id = 'ab486074-4430-4145-a18e-a057cc12ea24';
  UPDATE public.profiles SET spouse_id = 'c6cd2239-d26e-49f0-9f83-f983b0bce48b' WHERE id = '01eb5520-da87-40b5-81eb-e38425e82968';
  UPDATE public.profiles SET spouse_id = '01eb5520-da87-40b5-81eb-e38425e82968' WHERE id = 'c6cd2239-d26e-49f0-9f83-f983b0bce48b';
  UPDATE public.profiles SET spouse_id = 'f759ea07-6f82-4d13-8e86-4aa62bd8743c' WHERE id = 'b5da54bb-bbb8-4761-a7a7-56e2d3067853';
  UPDATE public.profiles SET spouse_id = 'b5da54bb-bbb8-4761-a7a7-56e2d3067853' WHERE id = 'f759ea07-6f82-4d13-8e86-4aa62bd8743c';
  UPDATE public.profiles SET spouse_id = 'e12a6c53-a805-4a5c-a371-56565afdd0ea' WHERE id = '2a2b6b04-2392-4488-9907-fcb1ca1ef972';
  UPDATE public.profiles SET spouse_id = '2a2b6b04-2392-4488-9907-fcb1ca1ef972' WHERE id = 'e12a6c53-a805-4a5c-a371-56565afdd0ea';
  UPDATE public.profiles SET spouse_id = 'ac525d55-2834-4af2-8998-525a077c5131' WHERE id = 'a1e245a9-a9e8-40fa-b5e7-c77f8254f413';
  UPDATE public.profiles SET spouse_id = 'a1e245a9-a9e8-40fa-b5e7-c77f8254f413' WHERE id = 'ac525d55-2834-4af2-8998-525a077c5131';
  UPDATE public.profiles SET spouse_id = '0a10e106-c70e-4577-83b4-4fd3692e19bc' WHERE id = '6eb8f32f-32c9-42fd-9bc8-c1eb531f8f64';
  UPDATE public.profiles SET spouse_id = '6eb8f32f-32c9-42fd-9bc8-c1eb531f8f64' WHERE id = '0a10e106-c70e-4577-83b4-4fd3692e19bc';
  UPDATE public.profiles SET spouse_id = '3941c095-38e1-48ce-a448-493641f2b4dc' WHERE id = '60f23c80-fef9-4368-87c8-4fad26594ad8';
  UPDATE public.profiles SET spouse_id = '60f23c80-fef9-4368-87c8-4fad26594ad8' WHERE id = '3941c095-38e1-48ce-a448-493641f2b4dc';
  UPDATE public.profiles SET spouse_id = '9480e978-7d5f-4bc1-ba15-22616f3c2a62' WHERE id = 'e9b7b08d-8b13-4757-b553-b7e7fbee5209';
  UPDATE public.profiles SET spouse_id = 'e9b7b08d-8b13-4757-b553-b7e7fbee5209' WHERE id = '9480e978-7d5f-4bc1-ba15-22616f3c2a62';
  UPDATE public.profiles SET spouse_id = '92f70a03-0c90-4011-b42f-2d96b9072737' WHERE id = '3be62807-f4e5-4bf4-8d97-2d1311753175';
  UPDATE public.profiles SET spouse_id = '3be62807-f4e5-4bf4-8d97-2d1311753175' WHERE id = '92f70a03-0c90-4011-b42f-2d96b9072737';
  UPDATE public.profiles SET spouse_id = '3ad0382a-7f9b-4371-8bda-1c55d3a90e0e' WHERE id = 'e4dc0ee6-6287-431d-acf5-0c62d50cb4cd';
  UPDATE public.profiles SET spouse_id = 'e4dc0ee6-6287-431d-acf5-0c62d50cb4cd' WHERE id = '3ad0382a-7f9b-4371-8bda-1c55d3a90e0e';
  UPDATE public.profiles SET spouse_id = '306da3f7-8b19-4248-8cdf-2c2df9002d8b' WHERE id = '577a8a70-5414-44ed-b9e2-2992cdb0e083';
  UPDATE public.profiles SET spouse_id = '577a8a70-5414-44ed-b9e2-2992cdb0e083' WHERE id = '306da3f7-8b19-4248-8cdf-2c2df9002d8b';
  UPDATE public.profiles SET spouse_id = '153aeb2c-be7c-4ef1-bd7c-a3b3da2370f1' WHERE id = '4b33e034-5341-4e8a-a7cc-e86aa07de102';
  UPDATE public.profiles SET spouse_id = '4b33e034-5341-4e8a-a7cc-e86aa07de102' WHERE id = '153aeb2c-be7c-4ef1-bd7c-a3b3da2370f1';
  UPDATE public.profiles SET spouse_id = '62c5805d-ffe9-421f-b0ac-2df896b149d9' WHERE id = '64fed90e-bed3-477b-b296-e3284bd747c3';
  UPDATE public.profiles SET spouse_id = '64fed90e-bed3-477b-b296-e3284bd747c3' WHERE id = '62c5805d-ffe9-421f-b0ac-2df896b149d9';
  UPDATE public.profiles SET spouse_id = 'eeb05682-ff4e-47c3-801e-72417c44fa17' WHERE id = '39817ad5-f1e9-41d2-8a36-327b874917cb';
  UPDATE public.profiles SET spouse_id = '39817ad5-f1e9-41d2-8a36-327b874917cb' WHERE id = 'eeb05682-ff4e-47c3-801e-72417c44fa17';
  UPDATE public.profiles SET spouse_id = '3bd2fa63-835c-425d-b59c-4f5e7347dc5d' WHERE id = 'df359988-6e42-4170-adbc-0770f27492d8';
  UPDATE public.profiles SET spouse_id = 'df359988-6e42-4170-adbc-0770f27492d8' WHERE id = '3bd2fa63-835c-425d-b59c-4f5e7347dc5d';
  UPDATE public.profiles SET spouse_id = '1d932706-4669-4b65-8216-2e27ad245971' WHERE id = 'a6bd54a5-7ba6-459e-87c1-6b59e27efec6';
  UPDATE public.profiles SET spouse_id = 'a6bd54a5-7ba6-459e-87c1-6b59e27efec6' WHERE id = '1d932706-4669-4b65-8216-2e27ad245971';
  UPDATE public.profiles SET spouse_id = '11cfdb38-c2d1-43fc-b83d-5bfaf42fbbbb' WHERE id = '27dcb3c1-c18e-4218-80b4-05d0a1b8a5ab';
  UPDATE public.profiles SET spouse_id = '27dcb3c1-c18e-4218-80b4-05d0a1b8a5ab' WHERE id = '11cfdb38-c2d1-43fc-b83d-5bfaf42fbbbb';
  UPDATE public.profiles SET spouse_id = '16333488-0d3b-4795-8597-9dcb7d9dc128' WHERE id = 'bedd45d3-8d32-4efd-8147-7534488b749a';
  UPDATE public.profiles SET spouse_id = 'bedd45d3-8d32-4efd-8147-7534488b749a' WHERE id = '16333488-0d3b-4795-8597-9dcb7d9dc128';
  UPDATE public.profiles SET spouse_id = '56633d3f-4763-4a50-a729-697468846aaf' WHERE id = 'c98f9811-3687-423e-aff0-82190ae57698';
  UPDATE public.profiles SET spouse_id = 'c98f9811-3687-423e-aff0-82190ae57698' WHERE id = '56633d3f-4763-4a50-a729-697468846aaf';
  UPDATE public.profiles SET spouse_id = 'e055729a-4b76-4528-b260-4f2b1a0eeeff' WHERE id = '4696bddf-98ff-4307-97ea-82fcb9ff317f';
  UPDATE public.profiles SET spouse_id = '4696bddf-98ff-4307-97ea-82fcb9ff317f' WHERE id = 'e055729a-4b76-4528-b260-4f2b1a0eeeff';
  UPDATE public.profiles SET spouse_id = 'ed73084d-85c8-420d-b6ae-a404985a3138' WHERE id = '81659905-131f-4a84-aafb-1ab3d9f0693d';
  UPDATE public.profiles SET spouse_id = '81659905-131f-4a84-aafb-1ab3d9f0693d' WHERE id = 'ed73084d-85c8-420d-b6ae-a404985a3138';
  UPDATE public.profiles SET spouse_id = '75d62d1e-646c-4f27-b61f-1736ff071923' WHERE id = 'de2648cb-4bac-436d-b4d5-a97741b3e50f';
  UPDATE public.profiles SET spouse_id = 'de2648cb-4bac-436d-b4d5-a97741b3e50f' WHERE id = '75d62d1e-646c-4f27-b61f-1736ff071923';
  UPDATE public.profiles SET spouse_id = '7f3b532f-5421-4b9f-8ba0-2e717ddc1f93' WHERE id = '7205e063-55e5-41b9-906b-8cc83e2f9b0d';
  UPDATE public.profiles SET spouse_id = '7205e063-55e5-41b9-906b-8cc83e2f9b0d' WHERE id = '7f3b532f-5421-4b9f-8ba0-2e717ddc1f93';
  UPDATE public.profiles SET spouse_id = '52b16034-cbcf-4896-a7b2-7336375ffe30' WHERE id = 'a6dfb526-08b9-452d-bc99-7384ffb0e521';
  UPDATE public.profiles SET spouse_id = 'a6dfb526-08b9-452d-bc99-7384ffb0e521' WHERE id = '52b16034-cbcf-4896-a7b2-7336375ffe30';
  UPDATE public.profiles SET spouse_id = '10ee34d4-888d-4409-88df-699a366c8cef' WHERE id = 'f7d3c8ab-4309-4b4f-a235-da8204f07b86';
  UPDATE public.profiles SET spouse_id = 'f7d3c8ab-4309-4b4f-a235-da8204f07b86' WHERE id = '10ee34d4-888d-4409-88df-699a366c8cef';
  UPDATE public.profiles SET spouse_id = '374dc646-b0ad-4830-b353-6b12f5ff2561' WHERE id = '0961cec1-bf5a-4cf8-aba3-c89efd4421bf';
  UPDATE public.profiles SET spouse_id = '0961cec1-bf5a-4cf8-aba3-c89efd4421bf' WHERE id = '374dc646-b0ad-4830-b353-6b12f5ff2561';
  UPDATE public.profiles SET spouse_id = 'a2a83320-2e09-4258-a3d5-8aaacbb043e0' WHERE id = '09ff0348-354e-43c2-b372-181bac3bddfb';
  UPDATE public.profiles SET spouse_id = '09ff0348-354e-43c2-b372-181bac3bddfb' WHERE id = 'a2a83320-2e09-4258-a3d5-8aaacbb043e0';
  UPDATE public.profiles SET spouse_id = '75208da3-b8ba-486e-8665-e765a183883b' WHERE id = '747b38d7-b84b-4039-9033-6fee34f9bddf';
  UPDATE public.profiles SET spouse_id = '747b38d7-b84b-4039-9033-6fee34f9bddf' WHERE id = '75208da3-b8ba-486e-8665-e765a183883b';
  UPDATE public.profiles SET spouse_id = 'd9f00b9c-8e29-42c2-8874-1801b2f0290e' WHERE id = 'a9702713-6d0a-48dd-b1da-cb915ad1ce71';
  UPDATE public.profiles SET spouse_id = 'a9702713-6d0a-48dd-b1da-cb915ad1ce71' WHERE id = 'd9f00b9c-8e29-42c2-8874-1801b2f0290e';
  UPDATE public.profiles SET spouse_id = '0257e477-a7b6-4121-a5a8-27919652d373' WHERE id = '6936238c-4151-4795-92e8-1b238739f7ed';
  UPDATE public.profiles SET spouse_id = '6936238c-4151-4795-92e8-1b238739f7ed' WHERE id = '0257e477-a7b6-4121-a5a8-27919652d373';
  UPDATE public.profiles SET spouse_id = '107ca685-65b8-4780-bc0f-c943e09aa8ef' WHERE id = '7fb7dc20-c84e-4590-9f05-10156435ee5f';
  UPDATE public.profiles SET spouse_id = '7fb7dc20-c84e-4590-9f05-10156435ee5f' WHERE id = '107ca685-65b8-4780-bc0f-c943e09aa8ef';
  UPDATE public.profiles SET spouse_id = 'f1eedb72-e58a-4905-8b59-d6db370a2b32' WHERE id = '4f6caee5-fe21-4c66-b050-28a3766c802c';
  UPDATE public.profiles SET spouse_id = '4f6caee5-fe21-4c66-b050-28a3766c802c' WHERE id = 'f1eedb72-e58a-4905-8b59-d6db370a2b32';
  UPDATE public.profiles SET spouse_id = 'c6ca5e65-7c90-4d00-b1d9-d9c03744a72c' WHERE id = 'c3fc759d-6814-46ad-b336-01c59a63da94';
  UPDATE public.profiles SET spouse_id = 'c3fc759d-6814-46ad-b336-01c59a63da94' WHERE id = 'c6ca5e65-7c90-4d00-b1d9-d9c03744a72c';
  UPDATE public.profiles SET spouse_id = '32f624ea-0788-480e-b963-0d5fa2bd24d6' WHERE id = '722a8040-c020-4878-a2aa-0424f57d868d';
  UPDATE public.profiles SET spouse_id = '722a8040-c020-4878-a2aa-0424f57d868d' WHERE id = '32f624ea-0788-480e-b963-0d5fa2bd24d6';
  UPDATE public.profiles SET spouse_id = '1bd07e79-5900-4d35-960c-f7b6f6b7c5a6' WHERE id = '32b950d9-6474-4e1e-a513-555280617278';
  UPDATE public.profiles SET spouse_id = '32b950d9-6474-4e1e-a513-555280617278' WHERE id = '1bd07e79-5900-4d35-960c-f7b6f6b7c5a6';
  UPDATE public.profiles SET spouse_id = 'c986ba93-3f40-44ba-82b6-7147178a2c67' WHERE id = '15b6d388-0772-477d-91b1-bc3504a0bb21';
  UPDATE public.profiles SET spouse_id = '15b6d388-0772-477d-91b1-bc3504a0bb21' WHERE id = 'c986ba93-3f40-44ba-82b6-7147178a2c67';
  UPDATE public.profiles SET spouse_id = 'fe58ac90-83fc-4708-bc8e-d7a7f2080fe9' WHERE id = '01de7ea5-c4fe-4330-a5db-e90ee9b75999';
  UPDATE public.profiles SET spouse_id = '01de7ea5-c4fe-4330-a5db-e90ee9b75999' WHERE id = 'fe58ac90-83fc-4708-bc8e-d7a7f2080fe9';
  UPDATE public.profiles SET spouse_id = '4c496562-332f-4350-8713-36deb6c0ab95' WHERE id = '111fc211-6520-4e68-ad30-d99663fb7f12';
  UPDATE public.profiles SET spouse_id = '111fc211-6520-4e68-ad30-d99663fb7f12' WHERE id = '4c496562-332f-4350-8713-36deb6c0ab95';
  UPDATE public.profiles SET spouse_id = '1355f355-3402-4c7b-9fa8-aa7a1e426c2d' WHERE id = 'a794e044-0c16-479d-a039-b544402e1422';
  UPDATE public.profiles SET spouse_id = 'a794e044-0c16-479d-a039-b544402e1422' WHERE id = '1355f355-3402-4c7b-9fa8-aa7a1e426c2d';
  UPDATE public.profiles SET spouse_id = '4f8be18d-1754-481e-ab8f-870005082348' WHERE id = '6a6a3f14-83fa-4a44-b0cb-f33de4ba029c';
  UPDATE public.profiles SET spouse_id = '6a6a3f14-83fa-4a44-b0cb-f33de4ba029c' WHERE id = '4f8be18d-1754-481e-ab8f-870005082348';
  UPDATE public.profiles SET spouse_id = '4d4704b4-9513-403d-8499-17c560f45254' WHERE id = '18e11abb-1bd3-4901-aacf-177af5aa8960';
  UPDATE public.profiles SET spouse_id = '18e11abb-1bd3-4901-aacf-177af5aa8960' WHERE id = '4d4704b4-9513-403d-8499-17c560f45254';
  UPDATE public.profiles SET spouse_id = 'ff3f31ab-7908-484b-811d-6c9300452d95' WHERE id = 'f80cfe6c-f07f-4461-852c-b8a3ed25d767';
  UPDATE public.profiles SET spouse_id = 'f80cfe6c-f07f-4461-852c-b8a3ed25d767' WHERE id = 'ff3f31ab-7908-484b-811d-6c9300452d95';
  UPDATE public.profiles SET spouse_id = '4ddbc50f-0c2b-4d34-90a5-6b1229b900cc' WHERE id = '84006fda-8503-4753-9bf5-3df051516634';
  UPDATE public.profiles SET spouse_id = '84006fda-8503-4753-9bf5-3df051516634' WHERE id = '4ddbc50f-0c2b-4d34-90a5-6b1229b900cc';
  UPDATE public.profiles SET spouse_id = '18b71168-2c8d-4a0b-9858-f547f3b67c5e' WHERE id = '4dc5a04a-3281-4cee-968a-bc61d83f1210';
  UPDATE public.profiles SET spouse_id = '4dc5a04a-3281-4cee-968a-bc61d83f1210' WHERE id = '18b71168-2c8d-4a0b-9858-f547f3b67c5e';
  UPDATE public.profiles SET spouse_id = '58f5593b-6ccd-4576-b9ba-3a327901c487' WHERE id = 'aa0cb027-08d8-4433-92fe-6bd9e4a7eec6';
  UPDATE public.profiles SET spouse_id = 'aa0cb027-08d8-4433-92fe-6bd9e4a7eec6' WHERE id = '58f5593b-6ccd-4576-b9ba-3a327901c487';
  UPDATE public.profiles SET spouse_id = 'ed35496c-3a32-410c-8757-cd3abebc4a67' WHERE id = '4a5f5788-797a-45f1-b6d7-e3f6e77745eb';
  UPDATE public.profiles SET spouse_id = '4a5f5788-797a-45f1-b6d7-e3f6e77745eb' WHERE id = 'ed35496c-3a32-410c-8757-cd3abebc4a67';
  UPDATE public.profiles SET spouse_id = 'cef669da-d59e-4963-af3c-a18cb59a0a9c' WHERE id = '93ea2784-ac7a-4374-8e8c-7b3337858f2b';
  UPDATE public.profiles SET spouse_id = '93ea2784-ac7a-4374-8e8c-7b3337858f2b' WHERE id = 'cef669da-d59e-4963-af3c-a18cb59a0a9c';
  UPDATE public.profiles SET spouse_id = 'c474b9e3-67e9-4639-a1b3-2a210b64148e' WHERE id = '9d85386a-2977-44f0-abf2-ca36fb815f2d';
  UPDATE public.profiles SET spouse_id = '9d85386a-2977-44f0-abf2-ca36fb815f2d' WHERE id = 'c474b9e3-67e9-4639-a1b3-2a210b64148e';
  UPDATE public.profiles SET spouse_id = '903d0419-b1bd-46a5-9537-a5a8b99b3c1d' WHERE id = 'f0968a66-f3e9-400c-bc80-32affb37034b';
  UPDATE public.profiles SET spouse_id = 'f0968a66-f3e9-400c-bc80-32affb37034b' WHERE id = '903d0419-b1bd-46a5-9537-a5a8b99b3c1d';
  UPDATE public.profiles SET spouse_id = '52a865e0-cd3c-45cf-9db7-6312f51cbe3e' WHERE id = 'f85afe51-62f0-4587-871e-a09c1030b1fe';
  UPDATE public.profiles SET spouse_id = 'f85afe51-62f0-4587-871e-a09c1030b1fe' WHERE id = '52a865e0-cd3c-45cf-9db7-6312f51cbe3e';
  UPDATE public.profiles SET spouse_id = '55f6d5f6-2e1e-472d-b08a-477a87ca34a6' WHERE id = '83893c76-725f-448b-b55c-791bba040776';
  UPDATE public.profiles SET spouse_id = '83893c76-725f-448b-b55c-791bba040776' WHERE id = '55f6d5f6-2e1e-472d-b08a-477a87ca34a6';
  UPDATE public.profiles SET spouse_id = '145c5222-1c13-48a9-8eef-0a206fe1f549' WHERE id = 'f07fb6d8-6385-492f-a864-9c10519a2c7f';
  UPDATE public.profiles SET spouse_id = 'f07fb6d8-6385-492f-a864-9c10519a2c7f' WHERE id = '145c5222-1c13-48a9-8eef-0a206fe1f549';
  UPDATE public.profiles SET spouse_id = '5e193f39-6b9f-414e-bcde-98599d93adf5' WHERE id = '3c2c1c31-bad2-428d-b1c1-1e98fee4bfd5';
  UPDATE public.profiles SET spouse_id = '3c2c1c31-bad2-428d-b1c1-1e98fee4bfd5' WHERE id = '5e193f39-6b9f-414e-bcde-98599d93adf5';
  UPDATE public.profiles SET spouse_id = '0e444243-f06a-497e-ae34-29e52db8d1ab' WHERE id = '2de6beb6-fef1-4f67-b588-946d9ad6889b';
  UPDATE public.profiles SET spouse_id = '2de6beb6-fef1-4f67-b588-946d9ad6889b' WHERE id = '0e444243-f06a-497e-ae34-29e52db8d1ab';
  UPDATE public.profiles SET spouse_id = 'e0da7c6c-7b50-4845-a29a-e50c020311e1' WHERE id = '0210b6d7-2bee-4b12-b998-facc98d5e391';
  UPDATE public.profiles SET spouse_id = '0210b6d7-2bee-4b12-b998-facc98d5e391' WHERE id = 'e0da7c6c-7b50-4845-a29a-e50c020311e1';
  UPDATE public.profiles SET spouse_id = '4f35c61f-1da4-4882-b94f-f54369d8eab5' WHERE id = '5299325a-efc6-4992-9c13-cd875e2e0810';
  UPDATE public.profiles SET spouse_id = '5299325a-efc6-4992-9c13-cd875e2e0810' WHERE id = '4f35c61f-1da4-4882-b94f-f54369d8eab5';
  UPDATE public.profiles SET spouse_id = '467666c6-93ce-4458-821c-a54ef6a7dd3b' WHERE id = '2705d104-941d-41ed-aa42-ca742dcb51db';
  UPDATE public.profiles SET spouse_id = '2705d104-941d-41ed-aa42-ca742dcb51db' WHERE id = '467666c6-93ce-4458-821c-a54ef6a7dd3b';
  UPDATE public.profiles SET spouse_id = 'd7f09103-d5db-4df4-b30c-9f41a5a1f33d' WHERE id = 'a863cacd-926d-4dbf-b533-d22e45d80139';
  UPDATE public.profiles SET spouse_id = 'a863cacd-926d-4dbf-b533-d22e45d80139' WHERE id = 'd7f09103-d5db-4df4-b30c-9f41a5a1f33d';
  UPDATE public.profiles SET spouse_id = 'bb48c596-0afe-4438-ac36-eccc37ce7f1e' WHERE id = '3be39136-25f7-4c76-b912-68867a128786';
  UPDATE public.profiles SET spouse_id = '3be39136-25f7-4c76-b912-68867a128786' WHERE id = 'bb48c596-0afe-4438-ac36-eccc37ce7f1e';
  UPDATE public.profiles SET spouse_id = 'f8f7d7a8-d9d0-4666-a254-858eb78f1bc3' WHERE id = '7840225c-8d31-4ca8-aeae-a627fcae7c4e';
  UPDATE public.profiles SET spouse_id = '7840225c-8d31-4ca8-aeae-a627fcae7c4e' WHERE id = 'f8f7d7a8-d9d0-4666-a254-858eb78f1bc3';
  UPDATE public.profiles SET spouse_id = '78a85e6b-6af6-463b-9775-20f19af29e6e' WHERE id = '7a3513b1-9ad3-4f99-a56e-f361f8738812';
  UPDATE public.profiles SET spouse_id = '7a3513b1-9ad3-4f99-a56e-f361f8738812' WHERE id = '78a85e6b-6af6-463b-9775-20f19af29e6e';
  UPDATE public.profiles SET spouse_id = 'eedb5897-a1b1-4656-9066-c6d82289bf03' WHERE id = 'be3216a8-a15e-41f7-94fb-cf03402e4328';
  UPDATE public.profiles SET spouse_id = 'be3216a8-a15e-41f7-94fb-cf03402e4328' WHERE id = 'eedb5897-a1b1-4656-9066-c6d82289bf03';
  UPDATE public.profiles SET spouse_id = '963e2e20-b96f-411f-b77a-58400ece2293' WHERE id = '0db29e6a-c54a-44e6-93b1-9bf2f4052433';
  UPDATE public.profiles SET spouse_id = '0db29e6a-c54a-44e6-93b1-9bf2f4052433' WHERE id = '963e2e20-b96f-411f-b77a-58400ece2293';
  UPDATE public.profiles SET spouse_id = '426ad53a-a1ef-4472-ab9b-a42a06879e51' WHERE id = 'c29c03e9-40f4-4a49-95d9-c70f011d4002';
  UPDATE public.profiles SET spouse_id = 'c29c03e9-40f4-4a49-95d9-c70f011d4002' WHERE id = '426ad53a-a1ef-4472-ab9b-a42a06879e51';
  UPDATE public.profiles SET spouse_id = 'ab518771-bb8d-4399-b516-2d912164dfe8' WHERE id = '02c0f4ec-7d50-4314-af0a-5ef9758dcd11';
  UPDATE public.profiles SET spouse_id = '02c0f4ec-7d50-4314-af0a-5ef9758dcd11' WHERE id = 'ab518771-bb8d-4399-b516-2d912164dfe8';
  UPDATE public.profiles SET spouse_id = '908f6a9f-f179-4492-9778-a1d617623be6' WHERE id = 'f85efaba-9cf9-44a9-bae8-fdaf808ebe77';
  UPDATE public.profiles SET spouse_id = 'f85efaba-9cf9-44a9-bae8-fdaf808ebe77' WHERE id = '908f6a9f-f179-4492-9778-a1d617623be6';
  UPDATE public.profiles SET spouse_id = '58b4b501-3778-40a5-82be-6cc8c86dd3af' WHERE id = '96dc0c0f-88b8-4e7d-a2ab-1e08712c8b06';
  UPDATE public.profiles SET spouse_id = '96dc0c0f-88b8-4e7d-a2ab-1e08712c8b06' WHERE id = '58b4b501-3778-40a5-82be-6cc8c86dd3af';
  UPDATE public.profiles SET spouse_id = 'cf3c4250-2e8b-4779-adf8-d1bc6cd281f0' WHERE id = '7effff7e-ff89-4ea1-957d-f09afb0bafe2';
  UPDATE public.profiles SET spouse_id = '7effff7e-ff89-4ea1-957d-f09afb0bafe2' WHERE id = 'cf3c4250-2e8b-4779-adf8-d1bc6cd281f0';
  UPDATE public.profiles SET spouse_id = '14ad3d68-7bdf-4ae0-9586-0041f218d732' WHERE id = 'f1d794c5-eeaf-438f-a083-61e37db7f481';
  UPDATE public.profiles SET spouse_id = 'f1d794c5-eeaf-438f-a083-61e37db7f481' WHERE id = '14ad3d68-7bdf-4ae0-9586-0041f218d732';
  UPDATE public.profiles SET spouse_id = 'd1c42487-08d1-4cf9-b697-77cf9246cf61' WHERE id = '1656669f-a404-4b39-94b4-02fde1f89672';
  UPDATE public.profiles SET spouse_id = '1656669f-a404-4b39-94b4-02fde1f89672' WHERE id = 'd1c42487-08d1-4cf9-b697-77cf9246cf61';
  UPDATE public.profiles SET spouse_id = 'f3beee46-fb10-49c0-a584-df0fab331614' WHERE id = '1ed8b73d-1a8a-46e2-b0aa-6ba8360db32f';
  UPDATE public.profiles SET spouse_id = '1ed8b73d-1a8a-46e2-b0aa-6ba8360db32f' WHERE id = 'f3beee46-fb10-49c0-a584-df0fab331614';
  UPDATE public.profiles SET spouse_id = 'e4fb9fdc-8ef5-40d5-99c5-a79638f569fc' WHERE id = '10f27076-8ad1-4b6c-96b6-0bcfce118d21';
  UPDATE public.profiles SET spouse_id = '10f27076-8ad1-4b6c-96b6-0bcfce118d21' WHERE id = 'e4fb9fdc-8ef5-40d5-99c5-a79638f569fc';
  UPDATE public.profiles SET spouse_id = 'a8f224cf-d8b8-4c91-aea0-2080a88ccde4' WHERE id = '23868771-e51d-46a5-a2bc-d2680ecd2194';
  UPDATE public.profiles SET spouse_id = '23868771-e51d-46a5-a2bc-d2680ecd2194' WHERE id = 'a8f224cf-d8b8-4c91-aea0-2080a88ccde4';
  UPDATE public.profiles SET spouse_id = 'bfe75fc9-f016-44e7-90f5-2aa7a745383b' WHERE id = '563b566b-c35d-46ec-9583-72b47d07281d';
  UPDATE public.profiles SET spouse_id = '563b566b-c35d-46ec-9583-72b47d07281d' WHERE id = 'bfe75fc9-f016-44e7-90f5-2aa7a745383b';
  UPDATE public.profiles SET spouse_id = '775b69aa-09b8-40fb-90a5-b8147eefe466' WHERE id = 'e245e00f-8c14-490e-88ef-ba6a0a10b43f';
  UPDATE public.profiles SET spouse_id = 'e245e00f-8c14-490e-88ef-ba6a0a10b43f' WHERE id = '775b69aa-09b8-40fb-90a5-b8147eefe466';
  UPDATE public.profiles SET spouse_id = '1e692cbb-dde9-4f45-823c-6686487116f5' WHERE id = 'f6bcf7f9-945d-4272-bdc2-75021465bc1c';
  UPDATE public.profiles SET spouse_id = 'f6bcf7f9-945d-4272-bdc2-75021465bc1c' WHERE id = '1e692cbb-dde9-4f45-823c-6686487116f5';
  UPDATE public.profiles SET spouse_id = '6a392324-bef0-4715-ab94-85a334eb2d91' WHERE id = 'f04dda79-d9e1-475d-928c-a5dce6bd5834';
  UPDATE public.profiles SET spouse_id = 'f04dda79-d9e1-475d-928c-a5dce6bd5834' WHERE id = '6a392324-bef0-4715-ab94-85a334eb2d91';
  UPDATE public.profiles SET spouse_id = 'd7096cec-4242-458a-9999-6ec2bfc84eb2' WHERE id = '6fa2d7da-daeb-4cea-9b02-fea2168bfb01';
  UPDATE public.profiles SET spouse_id = '6fa2d7da-daeb-4cea-9b02-fea2168bfb01' WHERE id = 'd7096cec-4242-458a-9999-6ec2bfc84eb2';
  UPDATE public.profiles SET spouse_id = 'cb31b953-06da-43eb-8b0e-af0b9390a0ae' WHERE id = '7d4c46f0-4ed3-4bf6-ae29-98c1df090fca';
  UPDATE public.profiles SET spouse_id = '7d4c46f0-4ed3-4bf6-ae29-98c1df090fca' WHERE id = 'cb31b953-06da-43eb-8b0e-af0b9390a0ae';
  UPDATE public.profiles SET spouse_id = '07193709-1bc4-41ec-bddc-02c409210275' WHERE id = 'b45ce3b0-9910-4544-b199-0a91fddd9ce9';
  UPDATE public.profiles SET spouse_id = 'b45ce3b0-9910-4544-b199-0a91fddd9ce9' WHERE id = '07193709-1bc4-41ec-bddc-02c409210275';
  UPDATE public.profiles SET spouse_id = '015ef6dc-288f-4266-ae6c-7eb878294df3' WHERE id = '4778ed70-4974-4e5a-ab7b-f4d50c257bd5';
  UPDATE public.profiles SET spouse_id = '4778ed70-4974-4e5a-ab7b-f4d50c257bd5' WHERE id = '015ef6dc-288f-4266-ae6c-7eb878294df3';
  UPDATE public.profiles SET spouse_id = '0a60cc91-b996-4028-8175-a8c8858a67cd' WHERE id = 'e4cb38f5-0fc2-4af1-9431-23e61e51bf0b';
  UPDATE public.profiles SET spouse_id = 'e4cb38f5-0fc2-4af1-9431-23e61e51bf0b' WHERE id = '0a60cc91-b996-4028-8175-a8c8858a67cd';
  UPDATE public.profiles SET spouse_id = '94be688c-539d-4a7d-b1fc-b829d40c3692' WHERE id = 'a4a5df28-ad0a-4eb7-9373-299ec6573932';
  UPDATE public.profiles SET spouse_id = 'a4a5df28-ad0a-4eb7-9373-299ec6573932' WHERE id = '94be688c-539d-4a7d-b1fc-b829d40c3692';
  UPDATE public.profiles SET spouse_id = 'c1134a6f-178d-40fa-affd-6d94d8fae52f' WHERE id = 'ce7f1091-e6a6-40f5-9aa6-6a1dd38d34c5';
  UPDATE public.profiles SET spouse_id = 'ce7f1091-e6a6-40f5-9aa6-6a1dd38d34c5' WHERE id = 'c1134a6f-178d-40fa-affd-6d94d8fae52f';
  UPDATE public.profiles SET spouse_id = 'ad1328a6-078f-4e85-835b-6a422cf12fdb' WHERE id = '05374aa2-ab3c-4909-9393-e0dd371f36f4';
  UPDATE public.profiles SET spouse_id = '05374aa2-ab3c-4909-9393-e0dd371f36f4' WHERE id = 'ad1328a6-078f-4e85-835b-6a422cf12fdb';
  UPDATE public.profiles SET father_id = '18199521-b88c-45ba-8973-194040fe970b', mother_id = '6b604757-d4ef-40d7-beb0-514888126d1e' WHERE id = '581bef00-4815-40fa-b731-7152debcbc7c';
  UPDATE public.profiles SET father_id = '95da0514-9444-4f29-a788-9d782b842895', mother_id = 'eaffce78-f113-4ead-aa0d-5ae9a8c5a110' WHERE id = '133bfc28-1807-4762-9986-176a0ead795c';
  UPDATE public.profiles SET father_id = '76385bbe-a540-4638-8013-609b49a6a2fe', mother_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '777363ae-fa07-4e54-b1dc-3a994e33839b';
  UPDATE public.profiles SET father_id = NULL, mother_id = '842cb647-a695-438e-bde3-21c1d435ed6b' WHERE id = '19ee4823-f87d-4aa2-b33b-513cbf18384c';
  UPDATE public.profiles SET father_id = NULL, mother_id = '842cb647-a695-438e-bde3-21c1d435ed6b' WHERE id = '7357b7aa-ec4c-4b46-ba88-83fe74926a5b';
  UPDATE public.profiles SET father_id = '075eabfb-81bd-4211-a4dd-a20b3e7fed47', mother_id = '451700ce-7eff-49d7-a787-f99a9eda2f8e' WHERE id = '885c1205-df30-4b76-a404-4f78abeda3d4';
  UPDATE public.profiles SET father_id = '075eabfb-81bd-4211-a4dd-a20b3e7fed47', mother_id = '451700ce-7eff-49d7-a787-f99a9eda2f8e' WHERE id = '91aac336-92ac-4490-9c85-14d3830fdf9b';
  UPDATE public.profiles SET father_id = '6ed4afbd-1081-4c81-be12-f03628822bba', mother_id = '1dc0ac57-4bbb-46b5-abae-938828807b02' WHERE id = '30999b0d-f37c-45f2-99ba-67f30e20a4bb';
  UPDATE public.profiles SET father_id = '6ed4afbd-1081-4c81-be12-f03628822bba', mother_id = '1dc0ac57-4bbb-46b5-abae-938828807b02' WHERE id = '6c852113-aeb7-44a8-b6df-e73b57f27071';
  UPDATE public.profiles SET father_id = '9cb51b1b-c865-4d6e-a6c9-29730d247a65', mother_id = '8bcec8d5-0fdf-402d-a963-61de788fc967' WHERE id = 'bb6baa23-618f-484f-ae33-349e641e8d19';
  UPDATE public.profiles SET father_id = '9cb51b1b-c865-4d6e-a6c9-29730d247a65', mother_id = '8bcec8d5-0fdf-402d-a963-61de788fc967' WHERE id = 'd256d873-e62b-48a5-b174-58f2cfefd55b';
  UPDATE public.profiles SET father_id = 'efa67ef3-8431-4adf-817b-3485bdf5526e', mother_id = '86c3cf40-e6be-4004-a67b-30a8e1bc6801' WHERE id = '930c2e88-4c8c-46bc-8e28-da953c85e383';
  UPDATE public.profiles SET father_id = 'efa67ef3-8431-4adf-817b-3485bdf5526e', mother_id = '86c3cf40-e6be-4004-a67b-30a8e1bc6801' WHERE id = '072a6edb-b5df-4906-80d0-b9dac1e96fe2';
  UPDATE public.profiles SET father_id = 'd601c038-8bef-439d-8abd-8e441694e063', mother_id = '54b85487-74c4-47fc-9a54-4a7ad7440ce2' WHERE id = '9107e676-25c7-447b-a76a-225065d0f7e3';
  UPDATE public.profiles SET father_id = 'd601c038-8bef-439d-8abd-8e441694e063', mother_id = '54b85487-74c4-47fc-9a54-4a7ad7440ce2' WHERE id = 'f51523ee-bb76-4f72-8888-6b2188619b51';
  UPDATE public.profiles SET father_id = 'd601c038-8bef-439d-8abd-8e441694e063', mother_id = '54b85487-74c4-47fc-9a54-4a7ad7440ce2' WHERE id = '0a426482-c3d2-410c-97bc-d99ba99739dc';
  UPDATE public.profiles SET father_id = 'd1952ca6-0fc8-4d25-bb5c-27e539f5e1eb', mother_id = '70215bab-9e3d-4a7c-94e4-762e1a164792' WHERE id = '8d3c3b62-5639-4c6d-9645-1568a467d2b2';
  UPDATE public.profiles SET father_id = 'd1952ca6-0fc8-4d25-bb5c-27e539f5e1eb', mother_id = '70215bab-9e3d-4a7c-94e4-762e1a164792' WHERE id = '180da680-795d-4398-94f2-51382ef42017';
  UPDATE public.profiles SET father_id = 'd1952ca6-0fc8-4d25-bb5c-27e539f5e1eb', mother_id = '70215bab-9e3d-4a7c-94e4-762e1a164792' WHERE id = '65ae8c33-5a09-4085-85fd-a55a5c03a3c6';
  UPDATE public.profiles SET father_id = 'e3186275-49bc-4908-8bb0-1a703d6e04f4', mother_id = '7e7eccaf-13ba-4a6e-8314-25a385bd99e1' WHERE id = 'e1e0f36e-1be0-457a-974e-c655061d1b21';
  UPDATE public.profiles SET father_id = 'e3186275-49bc-4908-8bb0-1a703d6e04f4', mother_id = '7e7eccaf-13ba-4a6e-8314-25a385bd99e1' WHERE id = 'b376638a-df6f-42b7-bf6d-11e1567d00d4';
  UPDATE public.profiles SET father_id = '18a9e871-da19-4167-ae79-0a0f4d7ee177', mother_id = '8497d209-25dd-4c37-848a-71a5ce583a4e' WHERE id = 'fa032bf6-7835-4f28-9033-62a4bfd4e0f9';
  UPDATE public.profiles SET father_id = '18a9e871-da19-4167-ae79-0a0f4d7ee177', mother_id = '8497d209-25dd-4c37-848a-71a5ce583a4e' WHERE id = 'dbf1815b-7a91-4bf3-8df0-2101132816d0';
  UPDATE public.profiles SET father_id = '2be9bae1-598f-4ef9-8bae-29c5b7f8ec75', mother_id = '91a31c18-cc8e-4cb8-ace6-1dba6277426c' WHERE id = '90f386fd-e904-41a7-bcf9-66dc29d656cb';
  UPDATE public.profiles SET father_id = '2be9bae1-598f-4ef9-8bae-29c5b7f8ec75', mother_id = '91a31c18-cc8e-4cb8-ace6-1dba6277426c' WHERE id = '48e17972-1250-4cb9-b914-b784fbfd7d18';
  UPDATE public.profiles SET father_id = '432d4817-9d00-43de-b3cb-980b6f076573', mother_id = '550512f2-af6c-4275-b162-28eaabd2f610' WHERE id = '83c13cf4-fced-45c7-9049-119cb42d37de';
  UPDATE public.profiles SET father_id = 'baa8946b-a7c8-4644-9ac0-60d4ee5b1fd8', mother_id = '92bcf7d0-2e22-43f6-a552-223cd710b0f4' WHERE id = 'ab07bca1-c5de-48db-879b-24c22123f0e8';
  UPDATE public.profiles SET father_id = 'a01be850-e0a9-43bc-a1fe-71a8fc25584a', mother_id = '2f962c77-17f1-4a34-ab50-4a916dd3ea67' WHERE id = '2e5727d8-17e5-48e4-aa72-2730570ca9c7';
  UPDATE public.profiles SET father_id = 'f384022d-8284-4319-af6e-9fbe52e69d6f', mother_id = '859de62b-bf20-4d15-be6d-04ff434704ca' WHERE id = '7973d621-acd9-4a74-a822-1786b5228c88';
  UPDATE public.profiles SET father_id = '4f545f60-8a6c-46b3-98e7-5e9a9241b39c', mother_id = 'a0eef8b7-9ebe-4f37-bfd7-da7af7b5af42' WHERE id = 'd8343644-12d9-401d-bbfb-61fcea213ed4';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'b3cc8109-5fd1-48cb-b536-cdbd634ea728' WHERE id = '193d59e6-b5e3-4f04-9008-76cbcda9645f';
  UPDATE public.profiles SET father_id = '53105f33-5e45-45e6-960a-4992d916d7f7', mother_id = '1d636a29-8d27-493a-9973-e35e74476c54' WHERE id = '8e012c82-8158-4b0b-a0dd-4d14de6d4a3a';
  UPDATE public.profiles SET father_id = '53105f33-5e45-45e6-960a-4992d916d7f7', mother_id = '1d636a29-8d27-493a-9973-e35e74476c54' WHERE id = '9eb079bb-b5b6-4e51-8514-b056f3f5b4dd';
  UPDATE public.profiles SET father_id = '49069bca-a1ca-4346-b1eb-aa00419a5c81', mother_id = 'cd5dabff-935b-499d-991c-d5b06494981f' WHERE id = '5b83aa0c-916f-4e7e-b10a-6982209769d9';
  UPDATE public.profiles SET father_id = 'aa3d2a3c-7f0c-467b-bf85-2952cca85639', mother_id = 'e86f8f13-6779-4961-907a-1c8c6fa870b1' WHERE id = 'e363ccc4-8a99-4919-ae43-879ce4ccd49e';
  UPDATE public.profiles SET father_id = 'e1439e40-56c7-4d8f-9e0e-2de14aa23470', mother_id = '4b26e83c-029a-44d9-ba6d-ddfd24a22371' WHERE id = '6965a4f8-1a2f-4169-bba2-68db6d4b3cd4';
  UPDATE public.profiles SET father_id = 'e1439e40-56c7-4d8f-9e0e-2de14aa23470', mother_id = '4b26e83c-029a-44d9-ba6d-ddfd24a22371' WHERE id = '24e24b6a-73ca-4b95-9e4c-2b93d3cbb95b';
  UPDATE public.profiles SET father_id = '3a24ed42-84e7-4591-90a4-8a1d5f3e94a5', mother_id = '2642fe06-67a6-4311-8fdf-e99729e30ab0' WHERE id = '8f079d27-b2b2-4e41-abee-5d291bddcc86';
  UPDATE public.profiles SET father_id = 'd387f54a-2404-4d75-8abf-ec8e15e2b192', mother_id = '97ccb0b0-481c-49ee-9c2b-2f7cc8dff8d7' WHERE id = 'a87f0c0e-3451-4e7c-8944-6fa2b3a3ac47';
  UPDATE public.profiles SET father_id = '19e646e3-8ee2-4759-bce9-271eb6210b0f', mother_id = 'cc099159-251d-4faf-bcaf-98498a7f6e53' WHERE id = '7da20361-8881-4494-b296-eeb7dc4b43fb';
  UPDATE public.profiles SET father_id = '19e646e3-8ee2-4759-bce9-271eb6210b0f', mother_id = 'cc099159-251d-4faf-bcaf-98498a7f6e53' WHERE id = 'aab2ea78-c623-49ba-a2eb-18feec255606';
  UPDATE public.profiles SET father_id = '5bf8572e-cab5-43f6-9f15-9df1cee486e0', mother_id = 'b039b08d-0e01-4bdc-b987-3ab6f901e3a1' WHERE id = '80588dd5-54c3-4f20-862d-a46e811b9eee';
  UPDATE public.profiles SET father_id = '5aeda46e-fc73-49f3-9df8-a981e1f36d5f', mother_id = 'f11fa2bd-91cf-4be9-8abf-c5982da1bd68' WHERE id = '83a538e0-dbc7-4ccd-ae80-0c68496cd7de';
  UPDATE public.profiles SET father_id = '5aeda46e-fc73-49f3-9df8-a981e1f36d5f', mother_id = 'f11fa2bd-91cf-4be9-8abf-c5982da1bd68' WHERE id = '4332ba7f-05a0-4a12-b963-9044e6a0fbf7';
  UPDATE public.profiles SET father_id = '1d1cdf88-22c8-4687-883f-b1dd4b8fd4b0', mother_id = 'cb63660a-b0f6-421b-9b5b-06fdaf28de9c' WHERE id = '4bf188b3-00b1-4e9b-adc7-25a4b71f2f34';
  UPDATE public.profiles SET father_id = '1d1cdf88-22c8-4687-883f-b1dd4b8fd4b0', mother_id = 'cb63660a-b0f6-421b-9b5b-06fdaf28de9c' WHERE id = '814458ef-8078-412b-97c7-343887eb4063';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'fa45817b-3c0a-4b86-95ec-321028d8a7ce' WHERE id = '58a5cdee-8bd2-409f-ab45-b567841e54f8';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'fa45817b-3c0a-4b86-95ec-321028d8a7ce' WHERE id = '789c375b-e6a5-411c-9f37-6b6b187f2e29';
  UPDATE public.profiles SET father_id = 'b97783df-67db-4a60-ad67-dcb6b4ddf9fa', mother_id = '11d54fe2-8e08-4557-b6aa-9d8fe99ce3e9' WHERE id = '1ca82797-5aac-4631-8573-fda8becdc21c';
  UPDATE public.profiles SET father_id = '01cffd07-e218-42d6-89f9-c12af443e8fe', mother_id = 'dacf9dd1-d154-47a3-af1b-9f5663eb172e' WHERE id = 'ea6ee148-3d17-4e6f-a678-5ab5a616f020';
  UPDATE public.profiles SET father_id = '28bab668-c8b2-4246-b2ca-d4a3329e88b2', mother_id = 'ff747f86-e7fa-414a-996b-2962be8a6743' WHERE id = '9138a49b-cb8c-4b52-86c1-e1abb8c5e08f';
  UPDATE public.profiles SET father_id = '28bab668-c8b2-4246-b2ca-d4a3329e88b2', mother_id = 'ff747f86-e7fa-414a-996b-2962be8a6743' WHERE id = '7303622e-0996-437a-bcd2-bd90701cd504';
  UPDATE public.profiles SET father_id = '61bb229d-5043-4586-a1cb-b5e7809b9a42', mother_id = 'b9c1eb03-54db-4bf2-88a6-226be1640d57' WHERE id = '5f9cac0f-a150-4031-8916-303254cfc6d4';
  UPDATE public.profiles SET father_id = '770b9d65-c331-466a-854f-4134401e8154', mother_id = 'cf1d34ee-2080-4088-b5d8-d7731199901a' WHERE id = 'cc10d9de-3840-4c7c-b09b-d582d71fbdf4';
  UPDATE public.profiles SET father_id = '770b9d65-c331-466a-854f-4134401e8154', mother_id = 'cf1d34ee-2080-4088-b5d8-d7731199901a' WHERE id = '05283e93-f2cf-4c81-93b3-c64b6a304a33';
  UPDATE public.profiles SET father_id = 'cc31648e-f28f-422a-a4e4-d4f6d4a8a081', mother_id = '93a88ed5-e784-4d6b-a69c-d7debb496bf3' WHERE id = '933d612d-44d4-4314-b93b-4c704564f331';
  UPDATE public.profiles SET father_id = 'dc23aa70-fbb4-4b81-9d74-3e5543cca2cb', mother_id = '2a75f8bc-d048-437f-85f3-f2c0f94dee00' WHERE id = '3691fc35-2237-4afd-8520-851c5c1bbc1f';
  UPDATE public.profiles SET father_id = '5ffeca61-7cd6-4cf1-adc6-d48959409cb0', mother_id = '9ae11fee-96fb-4c81-a6cd-57af2541291f' WHERE id = '03a773d6-637f-41a4-adb3-3bf7fa3ab362';
  UPDATE public.profiles SET father_id = '5ffeca61-7cd6-4cf1-adc6-d48959409cb0', mother_id = '9ae11fee-96fb-4c81-a6cd-57af2541291f' WHERE id = 'b8b4f899-40ce-4dde-908d-96e407622fae';
  UPDATE public.profiles SET father_id = 'b02b4f4f-5b40-4085-a3c9-82db4c266582', mother_id = '37a7eca7-d590-4f26-8fda-d63a6377914e' WHERE id = '82682c32-09ec-4d57-b696-b7ced5cfc50f';
  UPDATE public.profiles SET father_id = 'b02b4f4f-5b40-4085-a3c9-82db4c266582', mother_id = '37a7eca7-d590-4f26-8fda-d63a6377914e' WHERE id = '5318dcf2-79e5-4ce1-abd5-bc4df72634cd';
  UPDATE public.profiles SET father_id = 'a3f3e01d-de9f-4355-afd9-163ef2baa6ab', mother_id = 'ba920b1c-2c4f-46c3-ab83-4eef8c657c4a' WHERE id = '95330e5e-f741-4ea7-a125-9f51deb9365e';
  UPDATE public.profiles SET father_id = '3769e1a2-b80f-4c23-9328-7d7e2d733e55', mother_id = '5a9dab15-3181-461b-8979-220324e65540' WHERE id = '7bf2a8a1-1d38-413b-a2b5-77663f2a3255';
  UPDATE public.profiles SET father_id = '3bb28abb-1e36-4b4c-86be-39ede123499b', mother_id = 'cdcb7800-a3c8-44c9-b782-d0cc98431d61' WHERE id = '7b72a571-653f-41a2-a491-191dcc7b9841';
  UPDATE public.profiles SET father_id = '3bb28abb-1e36-4b4c-86be-39ede123499b', mother_id = 'cdcb7800-a3c8-44c9-b782-d0cc98431d61' WHERE id = 'a483ef3f-4ffb-4a60-8c7d-b1e5034c47e3';
  UPDATE public.profiles SET father_id = '04691149-7822-419e-af0c-0abc4ca89778', mother_id = '134164ad-c0fb-4c9b-ba42-a512c1aad399' WHERE id = '67f26cae-b7bc-4b15-84e3-c8f5e20d51af';
  UPDATE public.profiles SET father_id = '1f3eb3b0-f1c2-4c9f-a202-5d52180e8bc5', mother_id = 'abfa588a-96e0-468a-85f2-c63a08d5cc96' WHERE id = 'd1c45d05-e092-47cf-8894-ac568acf70ac';
  UPDATE public.profiles SET father_id = 'e9754ebb-7614-4040-9d7f-5b741d07b633', mother_id = 'a1e470e1-3742-444f-8834-8f5891892096' WHERE id = 'bfbbefbe-e661-4882-9f41-c6b6c6e5564e';
  UPDATE public.profiles SET father_id = 'e9754ebb-7614-4040-9d7f-5b741d07b633', mother_id = 'a1e470e1-3742-444f-8834-8f5891892096' WHERE id = 'a59946d3-9c25-40fd-b87b-dd2f98990461';
  UPDATE public.profiles SET father_id = 'c0dff264-dc84-45d6-9a4e-da18d047dd73', mother_id = '81a0a170-8930-48f2-b505-8cd13b9883c2' WHERE id = '568fdb5d-b1c2-4756-88d9-c335ef1c9a13';
  UPDATE public.profiles SET father_id = 'c0dff264-dc84-45d6-9a4e-da18d047dd73', mother_id = '81a0a170-8930-48f2-b505-8cd13b9883c2' WHERE id = '9a4e1669-97cf-47c7-8335-8a3b9737244d';
  UPDATE public.profiles SET father_id = '6f91d776-8634-4ece-94ae-f3994a84d1a5', mother_id = '2c668ccd-0f93-41b2-8743-66b74b4b533b' WHERE id = '8c0ccb5c-4000-4b4f-aad3-69e04bdd7c13';
  UPDATE public.profiles SET father_id = '6f91d776-8634-4ece-94ae-f3994a84d1a5', mother_id = '2c668ccd-0f93-41b2-8743-66b74b4b533b' WHERE id = '388126b0-bd32-4968-be8b-3e0de8ba6d47';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'b4d865c4-14ff-4d3e-b41f-9a2865d9d1a6' WHERE id = '968867ff-0c83-4604-9a4a-23d81d82c8ea';
  UPDATE public.profiles SET father_id = 'c3dee27d-46b7-4b6f-b312-7e0a1f5e3ca8', mother_id = 'f8fc3a94-f3fd-4467-a992-52262a94b14a' WHERE id = '8122c13c-b1a1-4749-bf2c-6016c6a0d81e';
  UPDATE public.profiles SET father_id = 'a6ca3f63-53e2-407b-a9fa-ae1f9c695380', mother_id = 'b9181151-41c7-441a-90a6-949a703ae525' WHERE id = 'da9f0ce9-0bc4-48c0-892e-400bd72edfdf';
  UPDATE public.profiles SET father_id = '8a9a91d2-1bf6-40a1-8a45-e858192d0fb2', mother_id = '947b92b9-c68d-4f75-a8cd-5785f3e1b00c' WHERE id = '5f7f3124-4088-41e2-ad70-4057634c6b52';
  UPDATE public.profiles SET father_id = '8a9a91d2-1bf6-40a1-8a45-e858192d0fb2', mother_id = '947b92b9-c68d-4f75-a8cd-5785f3e1b00c' WHERE id = '8c3d244b-6ea8-46df-8291-f3898d806424';
  UPDATE public.profiles SET father_id = '7cc5d3fd-5602-41b8-a8b0-2a601502657c', mother_id = 'e7f688c6-a018-4870-9f61-ec7be9da2b24' WHERE id = '6032d844-5ec8-42af-a542-9681d754b965';
  UPDATE public.profiles SET father_id = '949959ee-1dd0-409e-b9f8-32ed32900042', mother_id = 'e95ff5f1-2d83-4d91-b128-9b90e3545799' WHERE id = '952e38d0-ef7a-4c11-85f4-b7cbe0b2bfda';
  UPDATE public.profiles SET father_id = 'bac00a53-6c8b-4e62-a103-377d2b317a9b', mother_id = 'e71efd7c-f1fb-4657-b177-222ffbbe45f3' WHERE id = '0d081af7-f83d-4d99-9633-e388c59f5a6c';
  UPDATE public.profiles SET father_id = '60f23c80-fef9-4368-87c8-4fad26594ad8', mother_id = '3941c095-38e1-48ce-a448-493641f2b4dc' WHERE id = 'df4ca1be-3d48-4d9e-b860-106303126eab';
  UPDATE public.profiles SET father_id = '60f23c80-fef9-4368-87c8-4fad26594ad8', mother_id = '3941c095-38e1-48ce-a448-493641f2b4dc' WHERE id = '844cf6a5-101d-4f55-b65a-c57ba6c44973';
  UPDATE public.profiles SET father_id = '60f23c80-fef9-4368-87c8-4fad26594ad8', mother_id = '3941c095-38e1-48ce-a448-493641f2b4dc' WHERE id = 'ac734394-c100-4219-81d8-4fcf7102a2ac';
  UPDATE public.profiles SET father_id = 'e4dc0ee6-6287-431d-acf5-0c62d50cb4cd', mother_id = '3ad0382a-7f9b-4371-8bda-1c55d3a90e0e' WHERE id = '33cb1e8d-98f3-4c10-b053-d8be68f7c31c';
  UPDATE public.profiles SET father_id = 'e4dc0ee6-6287-431d-acf5-0c62d50cb4cd', mother_id = '3ad0382a-7f9b-4371-8bda-1c55d3a90e0e' WHERE id = '798cf288-c38b-4544-8423-f92af5397a93';
  UPDATE public.profiles SET father_id = 'e4dc0ee6-6287-431d-acf5-0c62d50cb4cd', mother_id = '3ad0382a-7f9b-4371-8bda-1c55d3a90e0e' WHERE id = '2f46f6d9-3bb2-4a89-bf67-675dfb61673e';
  UPDATE public.profiles SET father_id = '64fed90e-bed3-477b-b296-e3284bd747c3', mother_id = '62c5805d-ffe9-421f-b0ac-2df896b149d9' WHERE id = 'fa1bd922-ad4f-4696-b684-57bc7e8be418';
  UPDATE public.profiles SET father_id = '39817ad5-f1e9-41d2-8a36-327b874917cb', mother_id = 'eeb05682-ff4e-47c3-801e-72417c44fa17' WHERE id = 'fa28fa92-7095-4a97-84c6-5759e4029598';
  UPDATE public.profiles SET father_id = '39817ad5-f1e9-41d2-8a36-327b874917cb', mother_id = 'eeb05682-ff4e-47c3-801e-72417c44fa17' WHERE id = '5af65d2f-06f8-43f1-9fa7-445d7b276af3';
  UPDATE public.profiles SET father_id = '81659905-131f-4a84-aafb-1ab3d9f0693d', mother_id = 'ed73084d-85c8-420d-b6ae-a404985a3138' WHERE id = 'ef6ce8ca-85f3-4942-a155-050ca4116b3b';
  UPDATE public.profiles SET father_id = 'a6dfb526-08b9-452d-bc99-7384ffb0e521', mother_id = '52b16034-cbcf-4896-a7b2-7336375ffe30' WHERE id = 'a31ce4ca-beed-465b-993c-f76976c3673f';
  UPDATE public.profiles SET father_id = 'a6dfb526-08b9-452d-bc99-7384ffb0e521', mother_id = '52b16034-cbcf-4896-a7b2-7336375ffe30' WHERE id = 'f0d995e6-5117-472f-bace-a139b34b0d89';
  UPDATE public.profiles SET father_id = '0961cec1-bf5a-4cf8-aba3-c89efd4421bf', mother_id = '374dc646-b0ad-4830-b353-6b12f5ff2561' WHERE id = 'aa5acfc5-035e-44ae-9dc2-45b1d7b8df50';
  UPDATE public.profiles SET father_id = '0961cec1-bf5a-4cf8-aba3-c89efd4421bf', mother_id = '374dc646-b0ad-4830-b353-6b12f5ff2561' WHERE id = '01d9b464-7053-4f22-8815-874c13796ed8';
  UPDATE public.profiles SET father_id = '6936238c-4151-4795-92e8-1b238739f7ed', mother_id = '0257e477-a7b6-4121-a5a8-27919652d373' WHERE id = 'fd84b5f8-115e-4bc8-8ae7-9cd5b84d10a7';
  UPDATE public.profiles SET father_id = '4f6caee5-fe21-4c66-b050-28a3766c802c', mother_id = 'f1eedb72-e58a-4905-8b59-d6db370a2b32' WHERE id = 'f338f154-5c97-4529-8b12-9b90478740bd';
  UPDATE public.profiles SET father_id = '722a8040-c020-4878-a2aa-0424f57d868d', mother_id = '32f624ea-0788-480e-b963-0d5fa2bd24d6' WHERE id = 'bf98590e-ccc0-4929-835c-ba1e9846d679';
  UPDATE public.profiles SET father_id = '32b950d9-6474-4e1e-a513-555280617278', mother_id = '1bd07e79-5900-4d35-960c-f7b6f6b7c5a6' WHERE id = '4b4383f1-0c5e-48e3-82ef-1ac67dae9231';
  UPDATE public.profiles SET father_id = NULL, mother_id = '251b4abd-0ebb-49f5-8773-1cba771cb36d' WHERE id = 'b008f08b-016d-4067-8e31-aa26ad8196b5';
  UPDATE public.profiles SET father_id = NULL, mother_id = '251b4abd-0ebb-49f5-8773-1cba771cb36d' WHERE id = '2ab6692a-78b5-4c50-b2ca-fd04799988c2';
  UPDATE public.profiles SET father_id = '15b6d388-0772-477d-91b1-bc3504a0bb21', mother_id = 'c986ba93-3f40-44ba-82b6-7147178a2c67' WHERE id = 'f81d2bdc-4497-460f-a60b-b759afdec6a9';
  UPDATE public.profiles SET father_id = '15b6d388-0772-477d-91b1-bc3504a0bb21', mother_id = 'c986ba93-3f40-44ba-82b6-7147178a2c67' WHERE id = 'cb9ba05f-c74c-4bd2-8270-3b2ada1297a7';
  UPDATE public.profiles SET father_id = '15b6d388-0772-477d-91b1-bc3504a0bb21', mother_id = 'c986ba93-3f40-44ba-82b6-7147178a2c67' WHERE id = 'b8b2e930-80b1-42cd-a0dd-530afb3de1a7';
  UPDATE public.profiles SET father_id = '01de7ea5-c4fe-4330-a5db-e90ee9b75999', mother_id = 'fe58ac90-83fc-4708-bc8e-d7a7f2080fe9' WHERE id = '3bac8349-bdeb-4f5c-8837-846f9fee43f1';
  UPDATE public.profiles SET father_id = '01de7ea5-c4fe-4330-a5db-e90ee9b75999', mother_id = 'fe58ac90-83fc-4708-bc8e-d7a7f2080fe9' WHERE id = '9ac2d7c2-17bf-464d-9333-89e0735c493e';
  UPDATE public.profiles SET father_id = '111fc211-6520-4e68-ad30-d99663fb7f12', mother_id = '4c496562-332f-4350-8713-36deb6c0ab95' WHERE id = '20a8f04e-66ec-4fbd-ade3-80b59ac244dd';
  UPDATE public.profiles SET father_id = '6a6a3f14-83fa-4a44-b0cb-f33de4ba029c', mother_id = '4f8be18d-1754-481e-ab8f-870005082348' WHERE id = 'de2e7b1c-98c1-440b-995d-eeb21e4b3a53';
  UPDATE public.profiles SET father_id = '84006fda-8503-4753-9bf5-3df051516634', mother_id = '4ddbc50f-0c2b-4d34-90a5-6b1229b900cc' WHERE id = 'f9c4ebef-9a80-4e30-96d6-c8ce1ff81ca7';
  UPDATE public.profiles SET father_id = '84006fda-8503-4753-9bf5-3df051516634', mother_id = '4ddbc50f-0c2b-4d34-90a5-6b1229b900cc' WHERE id = '28f4a5d3-fcfe-49af-b514-22b5f8177e32';
  UPDATE public.profiles SET father_id = '84006fda-8503-4753-9bf5-3df051516634', mother_id = '4ddbc50f-0c2b-4d34-90a5-6b1229b900cc' WHERE id = '76c416c9-b8e8-4644-9b80-04458484213b';
  UPDATE public.profiles SET father_id = '4dc5a04a-3281-4cee-968a-bc61d83f1210', mother_id = '18b71168-2c8d-4a0b-9858-f547f3b67c5e' WHERE id = '8c884b5a-603f-4c43-82dd-38eaba21bbdd';
  UPDATE public.profiles SET father_id = 'aa0cb027-08d8-4433-92fe-6bd9e4a7eec6', mother_id = '58f5593b-6ccd-4576-b9ba-3a327901c487' WHERE id = '4ea36c0f-71e4-49e7-ab1d-7c8d9b91ad13';
  UPDATE public.profiles SET father_id = 'aa0cb027-08d8-4433-92fe-6bd9e4a7eec6', mother_id = '58f5593b-6ccd-4576-b9ba-3a327901c487' WHERE id = '9bdc7d0d-388d-40a8-b3ee-d0408cf5c19e';
  UPDATE public.profiles SET father_id = 'f85afe51-62f0-4587-871e-a09c1030b1fe', mother_id = '52a865e0-cd3c-45cf-9db7-6312f51cbe3e' WHERE id = 'bedc2468-4c37-4434-9ead-95e68a42f126';
  UPDATE public.profiles SET father_id = NULL, mother_id = '7a05ad9b-21d4-46b3-88a4-9df066afb94d' WHERE id = '3b8b46fb-8aff-4205-bae5-e356e7a2fb1a';
  UPDATE public.profiles SET father_id = NULL, mother_id = '7a05ad9b-21d4-46b3-88a4-9df066afb94d' WHERE id = '69f5a2e2-b8be-47f3-8273-fc387c929a34';
  UPDATE public.profiles SET father_id = '3c2c1c31-bad2-428d-b1c1-1e98fee4bfd5', mother_id = '5e193f39-6b9f-414e-bcde-98599d93adf5' WHERE id = 'a41f4c5c-d0ac-46de-9a87-47d0df1fda09';
  UPDATE public.profiles SET father_id = '0210b6d7-2bee-4b12-b998-facc98d5e391', mother_id = 'e0da7c6c-7b50-4845-a29a-e50c020311e1' WHERE id = '046b9437-4d75-498f-9091-6ba825d8d942';
  UPDATE public.profiles SET father_id = '2705d104-941d-41ed-aa42-ca742dcb51db', mother_id = '467666c6-93ce-4458-821c-a54ef6a7dd3b' WHERE id = 'ca9c295c-146c-4547-af57-40d91de534b5';
  UPDATE public.profiles SET father_id = '2705d104-941d-41ed-aa42-ca742dcb51db', mother_id = '467666c6-93ce-4458-821c-a54ef6a7dd3b' WHERE id = '3f7f941f-8fce-46a7-a365-cc992467c40d';
  UPDATE public.profiles SET father_id = 'a863cacd-926d-4dbf-b533-d22e45d80139', mother_id = 'd7f09103-d5db-4df4-b30c-9f41a5a1f33d' WHERE id = '9b88b8e5-e42a-4535-9dfe-21bb83b52c9b';
  UPDATE public.profiles SET father_id = '7a3513b1-9ad3-4f99-a56e-f361f8738812', mother_id = '78a85e6b-6af6-463b-9775-20f19af29e6e' WHERE id = '5699e7ef-6769-444f-89db-bc8800071738';
  UPDATE public.profiles SET father_id = 'be3216a8-a15e-41f7-94fb-cf03402e4328', mother_id = 'eedb5897-a1b1-4656-9066-c6d82289bf03' WHERE id = '544b01f8-a1f6-4425-9913-aa39035ce596';
  UPDATE public.profiles SET father_id = 'be3216a8-a15e-41f7-94fb-cf03402e4328', mother_id = 'eedb5897-a1b1-4656-9066-c6d82289bf03' WHERE id = '190d674e-6c67-4d3b-9555-8603d2db2873';
  UPDATE public.profiles SET father_id = 'c29c03e9-40f4-4a49-95d9-c70f011d4002', mother_id = '426ad53a-a1ef-4472-ab9b-a42a06879e51' WHERE id = '588c1bf6-986f-49b7-a199-c3ba39487d8a';
  UPDATE public.profiles SET father_id = '02c0f4ec-7d50-4314-af0a-5ef9758dcd11', mother_id = 'ab518771-bb8d-4399-b516-2d912164dfe8' WHERE id = 'c68989a1-e2d8-4ce7-bc6d-15a68d4c8292';
  UPDATE public.profiles SET father_id = 'e1a3052a-79d6-4bb5-bf7a-a19b88ba18f3', mother_id = NULL WHERE id = '88001175-a896-46ee-8372-d22b2e255f83';
  UPDATE public.profiles SET father_id = 'e1a3052a-79d6-4bb5-bf7a-a19b88ba18f3', mother_id = NULL WHERE id = 'cae2d2e9-173a-48fa-9a49-52bde41244bc';
  UPDATE public.profiles SET father_id = 'f85efaba-9cf9-44a9-bae8-fdaf808ebe77', mother_id = '908f6a9f-f179-4492-9778-a1d617623be6' WHERE id = '1066a960-6088-4925-b731-4ea27bc7a3da';
  UPDATE public.profiles SET father_id = '96dc0c0f-88b8-4e7d-a2ab-1e08712c8b06', mother_id = '58b4b501-3778-40a5-82be-6cc8c86dd3af' WHERE id = '794837e7-a382-4ee3-8e96-f9759370af81';
  UPDATE public.profiles SET father_id = '7effff7e-ff89-4ea1-957d-f09afb0bafe2', mother_id = 'cf3c4250-2e8b-4779-adf8-d1bc6cd281f0' WHERE id = '3bac46fe-d2f8-4b11-bc0e-87496bfbbe50';
  UPDATE public.profiles SET father_id = '7effff7e-ff89-4ea1-957d-f09afb0bafe2', mother_id = 'cf3c4250-2e8b-4779-adf8-d1bc6cd281f0' WHERE id = 'fac15d86-4066-41c3-8908-cff49ad3e522';
  UPDATE public.profiles SET father_id = 'f1d794c5-eeaf-438f-a083-61e37db7f481', mother_id = '14ad3d68-7bdf-4ae0-9586-0041f218d732' WHERE id = '13b0029d-6203-4918-a0ea-d5e0b8129ab8';
  UPDATE public.profiles SET father_id = '1656669f-a404-4b39-94b4-02fde1f89672', mother_id = 'd1c42487-08d1-4cf9-b697-77cf9246cf61' WHERE id = '01eed741-7f47-4b43-9d50-3e9d2345bb93';
  UPDATE public.profiles SET father_id = '1656669f-a404-4b39-94b4-02fde1f89672', mother_id = 'd1c42487-08d1-4cf9-b697-77cf9246cf61' WHERE id = '38f49a15-36d2-451e-8d60-4ff8ab93d731';
  UPDATE public.profiles SET father_id = '1ed8b73d-1a8a-46e2-b0aa-6ba8360db32f', mother_id = 'f3beee46-fb10-49c0-a584-df0fab331614' WHERE id = 'd0fd103a-198e-4ef8-9d2c-6fdc70f0b448';
  UPDATE public.profiles SET father_id = '10f27076-8ad1-4b6c-96b6-0bcfce118d21', mother_id = 'e4fb9fdc-8ef5-40d5-99c5-a79638f569fc' WHERE id = '6ed21ce0-d15a-46d6-938e-e46bc0192bf6';
  UPDATE public.profiles SET father_id = '23868771-e51d-46a5-a2bc-d2680ecd2194', mother_id = 'a8f224cf-d8b8-4c91-aea0-2080a88ccde4' WHERE id = '0ad14a21-1b97-4ccb-a41f-887c0ac7cf7a';
  UPDATE public.profiles SET father_id = '23868771-e51d-46a5-a2bc-d2680ecd2194', mother_id = 'a8f224cf-d8b8-4c91-aea0-2080a88ccde4' WHERE id = 'a040ae8f-ab01-4c18-9411-b3b3c00d676c';
  UPDATE public.profiles SET father_id = '563b566b-c35d-46ec-9583-72b47d07281d', mother_id = 'bfe75fc9-f016-44e7-90f5-2aa7a745383b' WHERE id = '091f9dc9-92bd-4685-853c-5d80c7e86921';
  UPDATE public.profiles SET father_id = '563b566b-c35d-46ec-9583-72b47d07281d', mother_id = 'bfe75fc9-f016-44e7-90f5-2aa7a745383b' WHERE id = '55d77b7f-629b-4cd2-9b0b-2ad824f983b4';
  UPDATE public.profiles SET father_id = 'f04dda79-d9e1-475d-928c-a5dce6bd5834', mother_id = '6a392324-bef0-4715-ab94-85a334eb2d91' WHERE id = '34d024c4-6173-4469-9e95-07d489c9f665';
  UPDATE public.profiles SET father_id = 'f04dda79-d9e1-475d-928c-a5dce6bd5834', mother_id = '6a392324-bef0-4715-ab94-85a334eb2d91' WHERE id = 'ac1a10a0-153d-4eb3-a105-14803f82c0df';
  UPDATE public.profiles SET father_id = 'f04dda79-d9e1-475d-928c-a5dce6bd5834', mother_id = '6a392324-bef0-4715-ab94-85a334eb2d91' WHERE id = 'ebb403e9-ec1f-44b6-875a-9fe7e03d4c84';
  UPDATE public.profiles SET father_id = 'f04dda79-d9e1-475d-928c-a5dce6bd5834', mother_id = '6a392324-bef0-4715-ab94-85a334eb2d91' WHERE id = '6a0889e7-71ce-4414-87aa-678557370e0f';
  UPDATE public.profiles SET father_id = '6fa2d7da-daeb-4cea-9b02-fea2168bfb01', mother_id = 'd7096cec-4242-458a-9999-6ec2bfc84eb2' WHERE id = 'a5bdf968-9e12-4d84-8bc7-1d40b25f8a79';
  UPDATE public.profiles SET father_id = 'a4a5df28-ad0a-4eb7-9373-299ec6573932', mother_id = '94be688c-539d-4a7d-b1fc-b829d40c3692' WHERE id = '835cd260-fd18-4184-ae80-6bf27b21a158';

  -- ==========================================================================
  -- 7. ATUALIZAR DISCIPULADO (discipler_id)
  -- ==========================================================================

  UPDATE public.profiles SET discipler_id = 'd9431731-50c0-44f2-947d-dc88a309b3d6' WHERE id = '69eecf4a-7ba6-4c53-be51-ed9d202715e8';
  UPDATE public.profiles SET discipler_id = 'd10f39b4-92c7-4967-9a82-69ad771457a1' WHERE id = 'ed56e011-a066-49c8-8233-e3b5f50140af';
  UPDATE public.profiles SET discipler_id = '9c9ad423-9cd4-46c8-acd4-05e1053d9896' WHERE id = 'a52a6748-767f-4c5d-b6c4-3cd96572cd59';
  UPDATE public.profiles SET discipler_id = 'd10f39b4-92c7-4967-9a82-69ad771457a1' WHERE id = '57d74b4b-3280-497a-87fc-9929e70eddcd';
  UPDATE public.profiles SET discipler_id = '9c9ad423-9cd4-46c8-acd4-05e1053d9896' WHERE id = 'b48c1d94-9e72-445b-b469-4a2c00a74e99';
  UPDATE public.profiles SET discipler_id = 'd10f39b4-92c7-4967-9a82-69ad771457a1' WHERE id = '266c8e68-4192-47a8-9f1e-10708d388e54';
  UPDATE public.profiles SET discipler_id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d' WHERE id = '2092d89f-7c41-4cde-9666-72db932250e5';
  UPDATE public.profiles SET discipler_id = '76385bbe-a540-4638-8013-609b49a6a2fe' WHERE id = '6717d16b-3add-4977-a824-a9c6bc2f9c13';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = 'f1acb2a6-60ed-43ca-927b-7737c7a799b5';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '842cb647-a695-438e-bde3-21c1d435ed6b';
  UPDATE public.profiles SET discipler_id = '76385bbe-a540-4638-8013-609b49a6a2fe' WHERE id = '0f0f28df-102c-4071-894e-389e41360cb1';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = 'a23f3eb2-c9e5-495b-84c3-ecc4670bcb26';
  UPDATE public.profiles SET discipler_id = '76385bbe-a540-4638-8013-609b49a6a2fe' WHERE id = 'c163c8a6-d96f-4980-8242-fe3e94f85fb7';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '93ce9392-ac77-4f5b-a4a0-bc3fa8ee0644';
  UPDATE public.profiles SET discipler_id = '76385bbe-a540-4638-8013-609b49a6a2fe' WHERE id = '075eabfb-81bd-4211-a4dd-a20b3e7fed47';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '451700ce-7eff-49d7-a787-f99a9eda2f8e';
  UPDATE public.profiles SET discipler_id = '76385bbe-a540-4638-8013-609b49a6a2fe' WHERE id = '6ed4afbd-1081-4c81-be12-f03628822bba';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '1dc0ac57-4bbb-46b5-abae-938828807b02';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '1989e812-e291-4e83-89b3-b848aef84570';
  UPDATE public.profiles SET discipler_id = 'd9431731-50c0-44f2-947d-dc88a309b3d6' WHERE id = 'dc8f98f8-306b-47ce-b650-645fed3c2f65';
  UPDATE public.profiles SET discipler_id = '6717d16b-3add-4977-a824-a9c6bc2f9c13' WHERE id = '30039d06-4756-40f8-8d7d-2a91466fc5b9';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '1b10c655-7452-4b91-820e-4b4a47fe12f6';
  UPDATE public.profiles SET discipler_id = '6717d16b-3add-4977-a824-a9c6bc2f9c13' WHERE id = '2020229d-7979-4cbb-8fab-f021f18b825e';
  UPDATE public.profiles SET discipler_id = 'a573ee8c-e8c2-4501-b484-dfef25e04a6c' WHERE id = 'a3c9a07c-017c-4c35-a164-9fca6da79b4c';
  UPDATE public.profiles SET discipler_id = '299d81b7-08b1-4fa6-b026-f45a65c684e0' WHERE id = '70d7271f-0612-4434-9bab-d8c5ad38bb86';
  UPDATE public.profiles SET discipler_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = '094adf18-1186-4802-a0c2-01852547ca63';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = '8103138f-6084-4eb2-b852-be3d55cd19ba';
  UPDATE public.profiles SET discipler_id = '02bf68cb-e556-4b65-a89e-7b236d235693' WHERE id = '13f92f18-e27a-409d-a2a6-461e2da8ef4b';
  UPDATE public.profiles SET discipler_id = '2020229d-7979-4cbb-8fab-f021f18b825e' WHERE id = '7581ff85-77d8-4f7e-8f48-2ef15f39fa7c';
  UPDATE public.profiles SET discipler_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = '38644b54-ac21-4bfd-8444-85619f985a83';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = 'ee51a38f-1fa5-4a3a-bf56-403db185980b';
  UPDATE public.profiles SET discipler_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = '2bf1deac-98cb-43ab-878e-aa8d559cca75';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = '584fa9fb-c171-46f5-8196-1a056d89527b';
  UPDATE public.profiles SET discipler_id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d' WHERE id = '31ca95d0-c658-4dc9-8116-8048726048f3';
  UPDATE public.profiles SET discipler_id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde' WHERE id = '88505968-39c9-4785-aa66-1eed08165c32';
  UPDATE public.profiles SET discipler_id = '31ca95d0-c658-4dc9-8116-8048726048f3' WHERE id = 'dbb46454-9eff-4e9e-85e0-46b10d664ade';
  UPDATE public.profiles SET discipler_id = '88505968-39c9-4785-aa66-1eed08165c32' WHERE id = '8f2c7cd0-dc24-4fcd-8da5-7c8f18af2f26';
  UPDATE public.profiles SET discipler_id = '1a6883bd-6cd3-4b77-b3d0-2d316b80a676' WHERE id = '62cdd14f-499e-4fd7-bfc8-60c7d79eca68';
  UPDATE public.profiles SET discipler_id = 'bc3cb641-22c2-4740-97c5-de8bfb35aebc' WHERE id = '02bf68cb-e556-4b65-a89e-7b236d235693';
  UPDATE public.profiles SET discipler_id = '76385bbe-a540-4638-8013-609b49a6a2fe' WHERE id = 'eb49b757-df17-400b-ae00-8e0cd3397de1';
  UPDATE public.profiles SET discipler_id = 'd490eba5-fbb2-4281-9777-d8226e71aa9f' WHERE id = '77da84a6-4557-4582-a4ca-5d11246e5e99';
  UPDATE public.profiles SET discipler_id = '62cdd14f-499e-4fd7-bfc8-60c7d79eca68' WHERE id = '9bd2e2fa-4e02-4ece-aaa4-3fcf13265ebf';
  UPDATE public.profiles SET discipler_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = '1ed2f9fb-b2d6-4bbb-8d52-56e641fb9048';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = 'b2dff33d-b4b7-41d5-94e5-d2a8f8516d93';
  UPDATE public.profiles SET discipler_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = 'a573ee8c-e8c2-4501-b484-dfef25e04a6c';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = '299d81b7-08b1-4fa6-b026-f45a65c684e0';
  UPDATE public.profiles SET discipler_id = '9bd2e2fa-4e02-4ece-aaa4-3fcf13265ebf' WHERE id = '9c9f8af5-87de-4405-b5cb-32d8b6d5b2ab';
  UPDATE public.profiles SET discipler_id = '62cdd14f-499e-4fd7-bfc8-60c7d79eca68' WHERE id = '9cb51b1b-c865-4d6e-a6c9-29730d247a65';
  UPDATE public.profiles SET discipler_id = '02bf68cb-e556-4b65-a89e-7b236d235693' WHERE id = '8bcec8d5-0fdf-402d-a963-61de788fc967';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = '8b5b308b-d51a-49de-b525-694ddb924372';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = 'f10adea6-2436-468e-b214-937f20a4e094';
  UPDATE public.profiles SET discipler_id = '9bd2e2fa-4e02-4ece-aaa4-3fcf13265ebf' WHERE id = '1681cb6a-b484-4030-bfb1-b33aea39ca9d';
  UPDATE public.profiles SET discipler_id = '86e61bad-d320-4bfc-9941-f61b6fae964c' WHERE id = '9029c57c-8190-40e6-bf07-a46caa76baa2';
  UPDATE public.profiles SET discipler_id = '78a85e6b-6af6-463b-9775-20f19af29e6e' WHERE id = '86e61bad-d320-4bfc-9941-f61b6fae964c';
  UPDATE public.profiles SET discipler_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = 'efa67ef3-8431-4adf-817b-3485bdf5526e';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = '86c3cf40-e6be-4004-a67b-30a8e1bc6801';
  UPDATE public.profiles SET discipler_id = '62cdd14f-499e-4fd7-bfc8-60c7d79eca68' WHERE id = '3b4775c4-d7d4-43c2-8153-52345ac65971';
  UPDATE public.profiles SET discipler_id = '9029c57c-8190-40e6-bf07-a46caa76baa2' WHERE id = 'df674479-c6c1-4105-afe0-1b5f1660954e';
  UPDATE public.profiles SET discipler_id = '299d81b7-08b1-4fa6-b026-f45a65c684e0' WHERE id = '529addb2-b920-40b8-ab0d-e2a56ac50201';
  UPDATE public.profiles SET discipler_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = '135eb50a-71cd-4534-8edc-4d70e441f992';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = '9471ce5d-592b-43a5-b642-eca9376ade77';
  UPDATE public.profiles SET discipler_id = 'eb49b757-df17-400b-ae00-8e0cd3397de1' WHERE id = 'd601c038-8bef-439d-8abd-8e441694e063';
  UPDATE public.profiles SET discipler_id = '77da84a6-4557-4582-a4ca-5d11246e5e99' WHERE id = '54b85487-74c4-47fc-9a54-4a7ad7440ce2';
  UPDATE public.profiles SET discipler_id = 'd10f39b4-92c7-4967-9a82-69ad771457a1' WHERE id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d';
  UPDATE public.profiles SET discipler_id = '9c9ad423-9cd4-46c8-acd4-05e1053d9896' WHERE id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde';
  UPDATE public.profiles SET discipler_id = 'd10f39b4-92c7-4967-9a82-69ad771457a1' WHERE id = '1a6883bd-6cd3-4b77-b3d0-2d316b80a676';
  UPDATE public.profiles SET discipler_id = '9c9ad423-9cd4-46c8-acd4-05e1053d9896' WHERE id = 'bc3cb641-22c2-4740-97c5-de8bfb35aebc';
  UPDATE public.profiles SET discipler_id = '1a6883bd-6cd3-4b77-b3d0-2d316b80a676' WHERE id = 'aa3d2a3c-7f0c-467b-bf85-2952cca85639';
  UPDATE public.profiles SET discipler_id = 'bc3cb641-22c2-4740-97c5-de8bfb35aebc' WHERE id = 'e86f8f13-6779-4961-907a-1c8c6fa870b1';
  UPDATE public.profiles SET discipler_id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d' WHERE id = '7e630638-b948-429e-b5e0-1f0ff0dcaa30';
  UPDATE public.profiles SET discipler_id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde' WHERE id = '3550ae89-e7cc-426d-bbb5-3bc74cf2775e';
  UPDATE public.profiles SET discipler_id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d' WHERE id = '83133cf2-3975-4311-8806-3cba0bffeaab';
  UPDATE public.profiles SET discipler_id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde' WHERE id = '8e8fc92d-956e-4c2b-a9fd-1eafcc4f99a3';
  UPDATE public.profiles SET discipler_id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde' WHERE id = 'c1baf135-aeef-45ed-9373-bd9cad49d2e4';
  UPDATE public.profiles SET discipler_id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde' WHERE id = '7db85295-7a6a-4fef-ac5d-530737b9de8b';
  UPDATE public.profiles SET discipler_id = '5b92e638-151a-4e3d-8e80-c8712d01ae8d' WHERE id = '0ababef1-5f5d-436e-8abd-4c06321a96fb';
  UPDATE public.profiles SET discipler_id = '9dedb40f-0760-4b7d-8819-aac8f5c47fde' WHERE id = 'e329ffd2-65d6-4202-9969-432a4fe276af';
  UPDATE public.profiles SET discipler_id = '060c9b8a-9173-4c73-afb1-348868616c14' WHERE id = '3bb28abb-1e36-4b4c-86be-39ede123499b';
  UPDATE public.profiles SET discipler_id = '94734ad2-5b56-4a13-99a1-e8ea21226daa' WHERE id = 'cdcb7800-a3c8-44c9-b782-d0cc98431d61';
  UPDATE public.profiles SET discipler_id = '94734ad2-5b56-4a13-99a1-e8ea21226daa' WHERE id = '134164ad-c0fb-4c9b-ba42-a512c1aad399';
  UPDATE public.profiles SET discipler_id = '94734ad2-5b56-4a13-99a1-e8ea21226daa' WHERE id = '36710d40-c124-4852-85d8-c8100d14adaf';
  UPDATE public.profiles SET discipler_id = '060c9b8a-9173-4c73-afb1-348868616c14' WHERE id = '1f3eb3b0-f1c2-4c9f-a202-5d52180e8bc5';
  UPDATE public.profiles SET discipler_id = '060c9b8a-9173-4c73-afb1-348868616c14' WHERE id = 'e9754ebb-7614-4040-9d7f-5b741d07b633';
  UPDATE public.profiles SET discipler_id = '94734ad2-5b56-4a13-99a1-e8ea21226daa' WHERE id = 'a1e470e1-3742-444f-8834-8f5891892096';
  UPDATE public.profiles SET discipler_id = '060c9b8a-9173-4c73-afb1-348868616c14' WHERE id = 'e527af2d-6f17-459c-aefe-e24cbeb824fe';
  UPDATE public.profiles SET discipler_id = '060c9b8a-9173-4c73-afb1-348868616c14' WHERE id = 'c0dff264-dc84-45d6-9a4e-da18d047dd73';
  UPDATE public.profiles SET discipler_id = '94734ad2-5b56-4a13-99a1-e8ea21226daa' WHERE id = '81a0a170-8930-48f2-b505-8cd13b9883c2';
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
     'pdf', 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', 'O Propósito Eterno', 'Catequese', now() - INTERVAL '28 days'),

    (m_res_id3, 'Artigo: A Centralidade de Cristo e o Fim da Religiosidade', 
     'Texto meditativo abordando a distinção entre a salvação como meio e a conformidade a Cristo como o objetivo final.', 
     'markdown', 'https://raw.githubusercontent.com/markdown-it/markdown-it/master/README.md', 'O Propósito Eterno', 'Artigo Teológico', now() - INTERVAL '25 days'),

    (m_res_id4, 'Juntas e Ligamentos: Discipulado Vida na Vida', 
     'Como a edificação orgânica acontece através de relacionamentos transparentes de prestação de contas, confissão e ensino mútuo.', 
     'video', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'Juntas e Ligamentos', 'Vida Comum', now() - INTERVAL '20 days'),

    (m_res_id5, 'Caderno de Estudo 02: Relacionamentos de Aliança e Cuidado Mútuo', 
     'Guia prático para reuniões de companheirismo entre discípulos e discipuladores.', 
     'pdf', 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', 'Juntas e Ligamentos', 'Catequese', now() - INTERVAL '18 days'),

    (m_res_id6, 'O Sacerdócio Universal de Todos os Santos', 
     'Princípios do Novo Testamento que desmistificam a divisão clero/leigo. Todos os discípulos são sacerdotes e ministros em serviço.', 
     'video', 'https://www.youtube.com/watch?v=ScMzIvxBSi4', 'Sacerdócio Universal', 'Eclesiologia Orgânica', now() - INTERVAL '15 days'),

    (m_res_id7, 'Artigo: A Igreja no Bairro e a Dinâmica nas Ruas', 
     'Evangelismo natural pelo testemunho pessoal e amor comunitário expresso na vida cotidiana de Belo Horizonte.', 
     'markdown', 'https://raw.githubusercontent.com/markdown-it/markdown-it/master/README.md', 'Sacerdócio Universal', 'Prática Comunitária', now() - INTERVAL '12 days'),

    (m_res_id8, 'Módulo 03: Prática do Evangelho do Reino nas Casas', 
     'Roteiro de compartilhamento do pão, oração e instrução bíblica mútua para os encontros domiciliares.', 
     'pdf', 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', 'Sacerdócio Universal', 'Catequese', now() - INTERVAL '10 days'),

    (m_res_id9, 'Vídeo Institucional: Princípios do Reino e Descentralização', 
     'Palestra introdutória sobre autonomia dos grupos caseiros e serviço diaconal aos necessitados.', 
     'video', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'Vida do Reino', 'Prática Comunitária', now() - INTERVAL '8 days'),

    (m_res_id10, 'Caderno Geral: O Evangelho Segundo Jesus', 
     'Compilação de ensinos práticos dos quatro evangelhos com foco no arrependimento, fé e seguimento radical de Cristo.', 
     'pdf', 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', 'Vida do Reino', 'Fundamentos', now() - INTERVAL '5 days');

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
      'mandatory_phone', '',
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
      'email', 'ggoesbraga@gmail.com', 'phone', '',
      'gender', 'Masculino', 'cityState', 'Belo Horizonte / MG', 'city_state', 'Belo Horizonte / MG',
      'birthDate', '2008-04-02'
    ),
    jsonb_build_object(
      'Nome Completo', 'Gabriel Góes Braga',
      'E-mail', 'ggoesbraga@gmail.com',
      'Telefone / WhatsApp', '',
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
      'mandatory_phone', '',
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
      'email', 'ggoesbraga@gmail.com', 'phone', '',
      'gender', 'Masculino', 'cityState', 'Belo Horizonte / MG', 'city_state', 'Belo Horizonte / MG',
      'birthDate', '2008-04-02'
    ),
    jsonb_build_object(
      'Nome Completo', 'Gabriel Góes Braga',
      'Sexo / Gênero', 'Masculino',
      'E-mail', 'ggoesbraga@gmail.com',
      'Telefone / WhatsApp', '',
      'Data de Nascimento / Idade', '2008-04-02'
    )
  ) ON CONFLICT DO NOTHING;

END $$;
