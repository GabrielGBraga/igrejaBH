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
  gabriel_id   uuid := 'fbdd1115-6292-42f7-9ae9-cece6cb7f33b';
  fernando_id  uuid := 'e1a9bb33-babc-4664-99f4-dbab5f8b0391';
  clara_id     uuid := '1b4d6e6b-98e2-4c75-9e38-6d912e898977';
  flavio_id    uuid := '5dc19046-ecda-4bf2-99fe-bcf490851948';
  marleide_id  uuid := 'e7c4ea7a-cb2e-4a03-b594-c9c76b2589dc';

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

  INSERT INTO public.sectors (id, name, created_at) VALUES ('fede5d52-e067-41d4-bc9f-0ff1443d1173', 'São Gabriel/Pampulha', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('5f8f7d94-ae6b-4f2f-89f8-0c6e38b7407c', 'Venda Nova/Neves', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('38e023ec-d6f0-48f8-bfe6-d7a4dcc44d6a', 'Santa Luzia', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('4673ad74-417d-4d07-92ad-6a8b5c7363b7', 'Oeste', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'Betim/Contagem', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('fc8dbd0b-41ac-48a7-b8f8-8d6c420de6ed', 'Fora da Localidade', now());

  -- ==========================================================================
  -- 3. CRIAÇÃO DOS GRUPOS CASEIROS (35 Grupos Reais das Planilhas)
  -- ==========================================================================

  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', 'fede5d52-e067-41d4-bc9f-0ff1443d1173', 'Solimões - BH - Bairro Solimões', 2, '19:30:00', -19.8392, -43.9185, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', 'fede5d52-e067-41d4-bc9f-0ff1443d1173', 'Heliópolis - BH - Bairro Heliópolis', 3, '19:30:00', -19.8425, -43.9482, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', 'fede5d52-e067-41d4-bc9f-0ff1443d1173', 'São Gabriel - BH - Região São Gabriel / Pampulha', 4, '19:30:00', -19.858, -43.916, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', 'fede5d52-e067-41d4-bc9f-0ff1443d1173', 'Santa Amélia - BH - Rua Pioneiros da Paz, Santa Amélia / Rua Hildebrando de Oliveira 65, Copacabana', 5, '19:30:00', -19.8361, -43.9724, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '5800d281-3e26-4074-b0da-966b1c4caec6', 'fede5d52-e067-41d4-bc9f-0ff1443d1173', 'Jardim Vitória - BH - Bairro Vitória / Jardim Vitória', 6, '19:30:00', -19.8456, -43.8891, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', '5f8f7d94-ae6b-4f2f-89f8-0c6e38b7407c', 'Santa Branca - BH - Rua Norte, 42, Santa Branca - BH', 2, '19:30:00', -19.8268, -43.9685, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', '5f8f7d94-ae6b-4f2f-89f8-0c6e38b7407c', 'Santa Branca - BH - Rua São José do Jacuri, 135, B. Santa Branca', 3, '19:30:00', -19.8245, -43.966, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '60df6500-4a69-480f-830d-79a024c5595f', '5f8f7d94-ae6b-4f2f-89f8-0c6e38b7407c', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 (Casa do Marinho) - Maria Helena', 4, '19:30:00', -19.7985, -44.0092, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', '5f8f7d94-ae6b-4f2f-89f8-0c6e38b7407c', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 - Maria Helena', 5, '19:30:00', -19.7992, -44.0105, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '62451771-26e2-4664-a887-ad433850de09', '5f8f7d94-ae6b-4f2f-89f8-0c6e38b7407c', 'Leblon - BH - Rua Olga Pimenta Guimarães, 204 - Leblon', 6, '19:30:00', -19.8115, -43.988, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '741ef189-124f-4e6b-82e6-50a4f97858ed', '5f8f7d94-ae6b-4f2f-89f8-0c6e38b7407c', 'Sevilha B - Ribeirão das Neves - Rua São João Del Rei, 270, Sevilha B', 2, '19:30:00', -19.7695, -44.0812, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', '5f8f7d94-ae6b-4f2f-89f8-0c6e38b7407c', 'Areias - Ribeirão das Neves - Rodízio (Areias / Morro Alto)', 3, '19:30:00', -19.782, -43.985, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', '38e023ec-d6f0-48f8-bfe6-d7a4dcc44d6a', 'Santa Matilde - Santa Luzia - Rua Geraldo Ferreira Rabelo, 169, Santa Matilde', 4, '19:30:00', -19.7668, -43.8582, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'dd962002-7930-47e8-8969-7b6202750e62', '38e023ec-d6f0-48f8-bfe6-d7a4dcc44d6a', 'Lagoa Santa - Lagoa Santa', 5, '19:30:00', -19.6328, -43.8906, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '1f94c716-9570-432c-b3d9-3308e39e0558', '38e023ec-d6f0-48f8-bfe6-d7a4dcc44d6a', 'São Benedito - Santa Luzia - Bairro São Benedito', 6, '19:30:00', -19.7825, -43.9145, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', '38e023ec-d6f0-48f8-bfe6-d7a4dcc44d6a', 'Fazendinha do Baú - Santa Luzia - Rua Presidente Roosevelt, 1107 - Fazendinha do Baú - Santa Luzia', 2, '19:30:00', -19.7755, -43.872, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '31154092-877c-4416-b90d-64a75a6b3ab5', '38e023ec-d6f0-48f8-bfe6-d7a4dcc44d6a', 'Córrego das Calçadas - Santa Luzia - Av. Engenheiro Felipe Gabrich, nº 734, Córrego das Calçadas, Santa Luzia', 3, '19:30:00', -19.759, -43.851, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '1f7ec431-0044-45c6-92c2-6006677f401f', '38e023ec-d6f0-48f8-bfe6-d7a4dcc44d6a', 'Cristina B - Santa Luzia - Rua Mila Bernardina da Rocha, 85, Cristina B, Santa Luzia/MG', 4, '19:30:00', -19.7762, -43.9248, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', '4673ad74-417d-4d07-92ad-6a8b5c7363b7', 'Novo Tirol - BH - Rua Macadâmia, 168, Novo Tirol - BH', 5, '19:30:00', -19.9985, -44.0315, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3382db18-dc2c-47f2-8079-0ae2a677964e', '4673ad74-417d-4d07-92ad-6a8b5c7363b7', 'Milionários - BH - Rua dos Atleticanos - Milionários', 6, '19:30:00', -19.981, -43.9965, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', '4673ad74-417d-4d07-92ad-6a8b5c7363b7', 'Tropical / Quintas do Jacuba - Contagem - Estrada Chico Mendes, 900 - Quintas do Jacuba - Contagem', 2, '19:30:00', -19.9265, -44.115, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', '4673ad74-417d-4d07-92ad-6a8b5c7363b7', 'Novo Progresso - Contagem - Rua Paraopeba, 184, Novo Progresso', 3, '19:30:00', -19.898, -44.039, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', '4673ad74-417d-4d07-92ad-6a8b5c7363b7', 'Bela Vista / Barreiro - Ibirité - Rua Melo de Souza Maia, 101, Bela Vista', 4, '19:30:00', -20.008, -44.052, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b232050e-af19-4672-8202-0c2c743d1902', '4673ad74-417d-4d07-92ad-6a8b5c7363b7', 'Salgado Filho - BH - Rua Ibiraci, 250 - Bairro Salgado Filho - BH', 5, '19:30:00', -19.9412, -43.9825, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', '4673ad74-417d-4d07-92ad-6a8b5c7363b7', 'Nova Suíça - BH - Rua Lindolfo de Azevedo, 608, Nova Suíça - BH', 6, '19:30:00', -19.9445, -43.9734, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'a08f343a-cdbb-4101-9658-57252f88a03c', '2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'São José - Esmeraldas - Rua Américo França Abreu, 257, São José, Esmeraldas', 2, '19:30:00', -19.7615, -44.314, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', '2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'Jardim Riacho das Pedras - Contagem - Rua Urânio, 114, Jardim Riacho das Pedras - Contagem', 3, '19:30:00', -19.9565, -44.041, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', '2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'Marimbá - Betim - Sítio da Igreja (Marimbá / Juatuba)', 4, '19:30:00', -19.932, -44.275, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', '2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'Resplendor - Igarapé - Rua Bahia, 131, Resplendor - Igarapé', 5, '19:30:00', -20.068, -44.298, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', '2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'Jardim Alterosa / Santo Antônio - Betim - Rua Limoeiro, 337, Santo Antônio - Betim', 6, '19:30:00', -19.961, -44.172, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', '2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'Três Barras - Contagem - Rua Gentil Diniz, 441 - Três Barras - Contagem', 2, '19:30:00', -19.9145, -44.0885, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '76789e7d-25f4-4544-ae57-051adc1d01ec', '2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'Eldorado - Contagem - Rua José Barra do Nascimento, 1971, Eldorado - Contagem', 3, '19:30:00', -19.938, -44.0395, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', '2aa083a0-3af0-4b52-9862-ff10727fdfdf', 'Ponte Alta - Betim - Condomínio Ouro Verde, Bairro Ponte Alta - Betim', 4, '19:30:00', -19.896, -44.203, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906', 'fc8dbd0b-41ac-48a7-b8f8-8d6c420de6ed', 'Interlagos - Sete Lagoas - Rua Antônio Domingos da Silva Filho, 307, B. Interlagos - Sete Lagoas', 5, '19:30:00', -19.4752, -44.2368, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '9756c191-c9db-4df7-9649-d6de63d8b006', 'fc8dbd0b-41ac-48a7-b8f8-8d6c420de6ed', 'Santa Bárbara - Santa Bárbara / Barão de Cocais', 6, '19:30:00', -19.9595, -43.415, now()
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
    'a973e365-e1c3-40d2-9a29-f030018314c8', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    'e7c4ea7a-cb2e-4a03-b594-c9c76b2589dc', 'Marleide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    'd56c853d-f037-4bbe-ab44-9b50f00a6225', 'Mateus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '4ce74efe-350c-497d-bbf4-9bdbac5606f9', 'Mariana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '75cfde95-1a4c-4b95-84db-2396c917a8b6', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '1b041dc5-7f90-458e-b15a-ada2e4ec9384', 'Soely', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '258ad5b9-065b-4b86-9ba3-1ccdbb79f2ca', 'Cleber', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '2b51e206-d402-415e-9bf5-381bdf291e57', 'Ana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '6a1fedc1-001c-4b86-97a3-656ddc26411d', 'Euller', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '4a2c6619-1eb0-4825-ab34-8c44df13383c', 'Wellington', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '8bc69d90-48f7-40de-ae9a-cb6a20c15748', 'Luciana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    'ad29df2f-ce38-4a48-8400-2229ec7440f4', 'Edmilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '3d782737-2883-47a1-b101-22391372edb0', 'Joana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '714362ed-cc6d-4036-8b59-421502056358', 'Agatha', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    '654ad3a2-6f2a-489f-9de9-6637c5d3edcf', 'Mariângela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    'cc706eb6-3859-423f-85d3-1ed07f5d5e1d', 'Breno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '10deaee4-7135-4dd4-b0af-fd5d28d837c7', true, false, false, false, false,
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
    'aded8621-99c7-4de3-a0ad-85e41ab6f5c5', 'André', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '6d70bbc2-c227-456a-8b4d-1bf1b7eb0244', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'c13dc906-6c0a-4d1c-ae3a-56ba784a4663', 'Daniel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '4dfe0c9c-5849-4e7e-8b4c-77a7c22007d4', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '007fdd97-e54d-41ec-b76f-cc4ee2e9e17e', 'Elis', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'e1a9bb33-babc-4664-99f4-dbab5f8b0391', 'Fernando Gomes Braga', 'fgb80@yahoo.com', NULL, NULL, '1980-07-18'::date, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, true, false, false, true,
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
    '1b4d6e6b-98e2-4c75-9e38-6d912e898977', 'Clara Góes Braga', 'claradiscipula@gmail.com', NULL, NULL, '1983-06-16'::date, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '14e651da-8606-4d92-91f3-91644e32cb24', 'Artur', NULL, NULL, NULL, '2019-09-09'::date, NULL, false, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'fbdd1115-6292-42f7-9ae9-cece6cb7f33b', 'Gabriel Góes Braga', 'ggoesbraga@gmail.com', NULL, NULL, '2008-04-02'::date, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, true, true,
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
    '59e96adb-0fd4-4ec2-81bd-1051006bb503', 'Maria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'e4f850e5-389d-4fa1-963c-ea78b411ab85', 'Marina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'c764b165-b3fa-4433-9bb8-c4e1d1347867', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'eb4913d5-86e6-4583-8aa9-96451d6bc64c', 'Deia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '2844dd9c-d919-49d5-a2cb-7479e0561205', 'Marivaldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '668c945e-ba87-41bf-a4a8-25746a11c7da', 'Luciene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '824ec089-985d-49db-ba37-1f6afcb9393b', 'Ramon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'f513abc3-34d0-473f-98d4-f5af4b3f6be3', 'Margareth', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'dd3c88c9-0d44-47ab-bd2f-4896a5cef601', 'Renan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '86b309b9-7fd4-409c-8258-3fb84886be8c', 'Arlete', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '484e5d46-3941-4f2f-ae29-9c6426033847', 'Ricardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'e004fbe1-0a09-42f7-baa2-801c605953f2', 'Priscila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '54514519-b0c7-4586-b1ea-430d1a879a0f', 'Cecília', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'a6c2cacd-413a-4b2b-bac1-64920c0bfd10', 'Hugo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '5d6624e4-515a-41d5-9d89-2191b63b9527', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '96f5541d-d799-4a00-8c02-4b408e8209a2', 'Sarah', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '72b03c28-bd64-43a0-be61-14be82dc09ce', 'Matheus', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '8d89109e-465a-4c40-a1e1-13384353fe20', 'Pedro', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '1bb5f39a-5af2-4ecc-a192-f8d0c5b48e5c', 'Marlon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'fa83ef7d-2e73-4bf7-99e1-8f6915f2bac2', 'Maura', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'c8914d91-c7c5-4f92-add3-f25940a0a9c5', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '8ca1902f-789b-4163-b4c6-30a1bd9aed8b', 'Samuel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'bc44a1b9-2edb-433d-b835-217bb7076adb', 'Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '983e3b2c-05bc-47a2-b246-2a6ef1be4b6e', 'Zoraide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '3cecb0de-de46-4249-9f44-c18128a58073', 'Miriã', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '8316a814-9602-4844-ba8a-7052c10a0a99', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    'fcc50877-28bd-4da1-ae88-0179e1e04a35', 'Samuel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
    'Casado(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'a449a4d6-73c6-4a75-a8b2-57598fe6b109', 'Wanderlaine', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
    'Casado(a)', 'Jaraguá', 'Belo Horizonte', 'MG',
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
    '33a9981a-a658-4057-8d52-05685b4e12d9', 'Ismael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'fdb8bcc3-fbf6-4544-a833-8daf949afa67', true, false, false, false, false,
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
    '19f38b67-a685-46df-93d5-7ee9eb6c94e1', 'Emerson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'b183c471-89c8-4b01-b8cc-dfadaadf68d0', 'Neide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '5be03c33-0bf4-45dd-89a2-24de9572845e', 'Walace', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '857df53a-b0b5-4292-90d3-db5d9ae5c950', 'Sabrina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'fb87c251-b3df-4246-8ee6-2a0e996ed9b6', 'Carol', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '0efb0be6-ae9b-49e8-854e-d6daf8bb3fb7', 'Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '616e448f-5ef4-4ac4-b179-46ebdeb52f24', 'Fernando', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '08bc0098-901c-440f-a612-90f666bcdcf8', 'Adriana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'a8aa0ee1-7642-42c7-b0f5-6f4e4c445ba4', 'Marcelo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '902853f5-3dfd-4a69-8482-45289bdd5243', 'Cristina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'fd674526-58b2-4b05-8261-9c7e29dca92f', 'Tales', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '53be1066-9209-42ae-8ad0-f1db95a1a2f0', 'Edna', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '4297299b-54a6-48dd-8389-2d058af352d7', 'Thiago', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '04bb9a8b-cd49-42a5-a7a1-4258f3608614', 'Ana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '155ede15-081f-45d5-aa2a-4d07a8475e00', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'd068d7a0-021f-4117-95dc-7fce4880abd5', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '47b12c72-96ac-44a1-ac2c-a3965a144111', 'Carlos Eduardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '1031fb1d-55ce-4d3c-bf44-73eef15727e6', 'Joelma', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'd1f42bed-270d-4e9d-8291-b200eeb9d033', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '9bfeb3a2-b069-495c-b7b3-f58471f4d864', 'Rafael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'e8380783-25ea-490a-86b0-44c56735eac4', 'Ana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '3ca73420-7208-487d-b688-cd299ab072a1', 'Bruno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '53d11f8b-36b2-4e7b-82df-f34027298ce1', 'Grace', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'd725d78a-aead-4054-921c-1c7349e7fb6d', 'João', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '82f3301a-efcf-43cb-8025-d411c91ae73e', 'Lutero', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'aea774da-ae23-4237-8fca-3adfc0a743e2', 'Dominique', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '337eb07d-9525-4ef0-a9d4-fd8891628b4f', 'Kaleu', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '13290749-1adb-484a-8f32-3e50b3bbe5a3', 'Vivian', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '9d3e3d9c-0087-45db-b5f0-27e1149c48b2', 'Marilda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'b885c4f1-d874-4165-80f8-79ebf0c101bd', 'Vanessa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '5d0b407b-f754-4ca0-ac16-b089f6232264', 'Enzo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '26321912-b208-436a-a337-0ce9bdd0d2d8', 'Daniele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '11a67fda-3694-47f1-b2f3-0c2da85280b7', 'Luciene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'e2246a62-a822-4fe7-9b48-76a18e840230', 'Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'e8ae9e3d-8463-4a4d-8283-b2df0337ec24', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '99da2259-e583-4067-a948-b72318da9bc8', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '7b8e2210-c873-4f98-95fe-b3ee0324016f', 'Antonela', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'a1f11d2c-e62c-4da9-86bf-f05bdc46e7f8', 'Luiz Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '60e5c06d-ed91-4f09-ad9f-73910e033e02', 'Juliana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '398d9631-cdee-4014-91dc-71e7708d9265', 'Amélia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'e0f4fba9-a4e0-47f9-8292-000de315f586', 'Felipe', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '927bdbf2-398d-433f-8c99-60263bc9863e', 'Tamara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'd1b17fce-5466-45a9-a929-19c6e037d8ed', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '900b2622-411b-4268-9c11-3d3e9b433c4b', 'Ciça', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    'ae1bc088-a888-4eff-a416-f7d8cfe6dadd', 'Mariana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '7c2d6858-b82b-4822-8f8c-65331f484c23', 'Henrique', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '86ea625d-bcf0-4cdd-a0e0-f64c20bf3c85', 'Vivian', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e4dbb62d-5795-4498-861e-7d40e920ffb2', true, false, false, false, false,
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
    '226d4f00-0a5d-4e07-921d-141d6e6a8e61', 'Eduardo Lopes', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '1412fe9f-582f-4f29-abd7-98726b189f5a', 'Érica Lopes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '7aab270e-981b-41d8-8164-87dd15089a1c', 'Laura Lopes', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '71c8cd62-e468-466a-a33c-28309ed9349b', 'Eduardo Filho', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'f3ca22c0-f632-40a5-8e8a-e5d3a51df676', 'Luís Filipe', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '648f3ba8-df06-4d5d-8ea7-c2a637adb855', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'efd6fe7d-3fd6-448a-adf0-e21ad3e79a1a', 'Juliana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'aee813e9-5b05-49cc-bc11-e117253cd4da', 'Henrique Filho', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'e3bc733d-65b6-47ee-b86b-a8f299d20fc0', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '7c12dfe6-42e7-4863-a930-47c330a2502b', 'Lucas Oliveira', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '91f90e54-3d7e-498c-b65a-ccbc80065313', 'Raíssa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'cc2259b7-01a3-468e-bc6c-8fb2b5f2a622', 'Lian', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '1d96bb97-6ff4-4991-941d-5e7149552f53', 'Pietro', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'f75a3f92-f18e-469f-8929-a142fd5b0ddf', 'Danilo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '25665c02-7b99-4da1-85e2-ff878508f32f', 'Melry', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'aefb870c-834e-4d55-a546-1cbbb9626909', 'Henrique', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '36589f61-d033-477d-8f6a-c96c5d3efeb6', 'Sofia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'f1a9dbb9-5c1f-4232-8455-fbcefafcbc49', 'Mateus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'ec23f305-c606-4eee-b888-23e74ec8f1d3', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '5f355a04-f53d-49d4-9fdd-c96e4503c3dd', 'Davi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '07f5b08e-8ac7-4daa-ae47-3c62bfa22790', 'Josinha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'cc179474-541d-40ee-ab8d-41cf98af10fe', 'Thiago Bombeiro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'a6dc1e28-435a-4fec-849d-d5e00f04cae2', 'Paula Emanuela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '2a11f54a-c317-4975-a5cf-b8ba08724455', 'Ana Luiza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '6c5fe4a3-be3e-4302-aed6-ec9fb1529a25', 'Aline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '4155c44e-831a-48c0-b9f4-c08518e2621b', 'Thiago Filho', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '7922b84f-697a-4a08-b8fd-3ccb61b621a2', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
    'Casado(a)', 'Céu Azul', 'Belo Horizonte', 'MG',
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
    'c49b9a37-08a1-4500-b80f-3123a4edd61d', 'Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
    'Casado(a)', 'Céu Azul', 'Belo Horizonte', 'MG',
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
    '9199fa20-17bd-4c0b-b0b9-f6ea0e2b127a', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '761ce82c-aa54-4268-ac75-9c45afada9fc', 'Bruno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '9fb2c561-db57-41d1-8ee1-1d945b9d687e', 'Miriã', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'ce76a35d-09c5-4e79-af22-e89abe908632', 'Nikole', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    '71928f96-f685-4a89-895d-30a60360bb72', 'Brenda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'e7970dea-2618-4c6f-94d8-3e3bfdd84368', true, false, false, false, false,
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
    'f88e308a-638c-4333-a652-fabe6d3c57a4', 'Ademir', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '31232db3-802e-4c7a-b8bb-f5736126ad41', 'Janaína', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'b5a535a2-a94b-4d2a-a042-7069740912cc', 'Emanuela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '0283e86a-0aad-435c-b5b8-e8229cb922c2', 'João Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'cc5b7e4c-6ea0-4de7-afc3-1c1dfb401806', 'Julião', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '2494a7e4-3952-4861-a839-b92e79639bb1', 'Darlene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '05bc176f-06a8-4ae0-9277-b48cc120ae06', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'b1bc9193-2a93-4974-b80f-1e5ff52842ce', 'João Francisco', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'a35cef4f-100e-44c3-87de-c662b32939ce', 'Ana Beatriz', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '3f47be24-abd2-41a4-b7da-07c8ffa17f8e', 'Elias', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'd69860c2-6582-41ab-94ab-31d1dd0778bd', 'Fabiana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'fd196d6f-3f00-4490-bd6f-4f7226ed0456', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'd3421b35-f408-4e7d-ae0d-83b775519837', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '739d43d2-70c5-484e-8283-d889b225b936', 'Luiz Filipe', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '142d86af-5058-4094-a5d6-643409402e23', 'Jéssica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '12676f28-81b0-4e74-b696-993c094ec873', 'Ester', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'f874833a-bf09-4e2a-9680-ee2056a666f9', 'Gabriel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'b9272b34-c38f-4dec-b5c2-8fa8281b5202', 'Thainara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '108f03eb-ded4-4d35-a0d0-e4816b5af632', 'Lucas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '2011e37c-0837-4b2c-957c-297040fbb2d9', 'Laila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'fd98ae92-11c8-4810-958e-48c774ace408', 'Evenly', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '50b24231-4b50-447e-ac8d-af5503ba92f0', 'Luís', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'b679a8da-e35d-413b-8ffe-ede4cc4c3f31', 'Antony', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '77688352-99ef-4033-982e-31c149ce8ef8', 'Carla', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'f007c862-4ae0-411a-b2b4-71c7c9e01d9a', 'Laiana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '8ee9303e-bac1-4490-9c8d-3206c021957d', 'Luciana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '1200024d-3b6d-49b1-bb0f-392ae1c7df9d', 'Riquelmer', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '864155c3-4adc-4206-a46a-238b91990fff', 'Caíque', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '410a23d5-a39b-4415-b26e-fbaa89bdb3b4', 'Silas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '509382f7-91cc-4aa0-8b4c-f04c6540e2ef', 'Juraci', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '437f0ec4-0a29-4101-9f10-b578627212eb', 'Luizão', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    'e3d551b9-1ed3-45c7-83f0-5f7e205d544e', 'Amanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '8956fdb9-2759-458e-ad19-07eaabc2e40e', 'Valentina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '4d23da6b-e265-4759-9aa8-f7c3b1fe723b', 'Juscelino', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5800d281-3e26-4074-b0da-966b1c4caec6', true, false, false, false, false,
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
    '79195b39-bd2b-47b1-802b-5ce1f89e385b', 'Helder', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'ce77e3e6-47a3-4ad7-adec-9a3fe5c98cae', 'Vivian', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'f3dfe894-bc26-473f-a45d-4d9d500b5258', 'Jonata', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '111591a0-bb98-47ab-9a5e-c56ef61d11d9', 'Francérgio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '09594764-f583-486e-b90b-c65d21031630', 'Juliana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'b3b0cc4e-ed28-481f-8d8b-2a950d4876f6', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'ee428f95-4f04-47aa-83e4-6479387049a2', 'Kennedy', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '58e4d72e-5f5d-4226-8ed8-3954df70234c', 'Bárbara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'd22e677e-7a2a-4e3b-9062-b1b27290bac2', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '5d48f97b-dc6a-4d72-9775-2ae3948a6e97', 'Pricila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'dd9b61fd-a9cf-440e-9253-ce700421edea', 'Luciano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '1b7f0b11-cf70-494b-b8ea-7fae857c8e71', 'Lilian', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'fae1994e-950c-4190-969b-80fa02ecb0fb', 'Tiago', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '5a8d8eca-82cb-45af-9850-89bc538f36c0', 'Miguel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '51e8b11e-fc4f-412d-b517-693b21fe97a7', 'Breno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'e7677369-caf4-42b2-95bb-11e8a37fb48c', 'Taiane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '1932e93f-70d8-4e94-8a88-052aba3bb257', 'Henrique', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'a37c69f3-6985-4440-a28b-31ddec6bba33', 'Rhuan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'c3994ab6-7291-4d25-8253-24cfb89f8569', 'Gabriele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '644931a2-b3a9-44a5-904e-86ae823e6206', 'Vanessa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'c0a639de-4f2b-40f0-9b70-c6a042e9cbe1', 'Polyana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'e9e3c277-1b42-42e9-83cb-199f0cfcfc10', 'Maria Clara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '49389052-0f2c-4575-8574-83f448e7c60c', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '94028bc3-42dc-45b6-a0c8-50190da2a0ab', 'Júlia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    '045a4afa-630a-4d5b-9951-bdbb3bef8b9f', 'David', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b', true, false, false, false, false,
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
    'ed3ce8d1-3736-4d8f-a990-5ffd0f08de33', 'Juarez', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    'a82b3df8-2e6c-4f8f-9a40-10ee11a462d9', 'Divina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    '49967758-5c98-42cd-9bb5-9f2e1b871281', 'Argeu', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    '684bcfec-178b-46f2-8594-8185dfa0823b', 'Lora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    '3a3067ba-b6fe-470c-a44b-0028f2840baa', 'Sérgio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    'b017cdce-7fef-40e1-90ca-656fa92108fc', 'Karina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    '2dc1f353-333f-49b5-a753-c68541ef5d1f', 'Emanuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    'a65d741d-9bf8-4944-9cd6-c767c7845df5', 'Daniel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    '05844df6-0756-4fcc-a66b-fdad12292b5a', 'Lúcia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    'c0a41b88-540e-4856-8f67-de167fbbee0f', 'Mundica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
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
    'af1d3dd9-52ee-4846-a93a-018e873974d6', 'Janir', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
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
    '240beee7-bd39-4260-88eb-a4ad650f4e46', 'Cristiano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
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
    '334357c7-ac87-4ff2-b689-3ac8230c3653', 'Vanessa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
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
    '3a0b50ed-ddb3-4863-bc84-2ede399304da', 'Caio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '8584ae0d-c452-4e42-b16f-c04c2f541b15', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
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
    '2608ba42-d23a-44dc-9526-fcd983bf71d4', 'Marinho', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '9a7f7903-ecac-4dcb-b742-cbed967b32e7', 'Quênia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '2b6feecd-4a2b-4640-9d23-b9cf908cf08a', 'Karina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '8d6f756c-aca9-45a8-8a34-96b6b6dcda8f', 'Jonas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'afeb57ba-f488-48f9-a6b3-7f86fa7ebdd4', 'Wellington', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'a896926e-5e19-4357-8fd4-5250b019a8be', 'Raquel', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '28143dc1-fca8-4b9b-baf2-f8ab024c56f6', 'W. Júnior', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'dedb7842-857c-4db0-987e-63e82f28f5e0', 'Carlinho', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'd2343609-d932-4aae-8765-cf1dbcda9934', 'Graziela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'efc20ecc-6f5f-4a04-954f-0d78fb2561b2', 'João', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'a4a6c2ea-0e93-4212-9b9e-6ab0b558585b', 'Alexandre', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '2f63077b-4802-4958-8713-3752be15f903', 'Érica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '751821eb-3e86-4a94-96e4-37cdb9fe959d', 'Benjamim', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '8f452f97-ef47-4eb3-8668-f262fcc80ad5', 'Marcelo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '04a5cb31-a7e0-4dfb-93da-0eca0986945d', 'Eliete', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '4acdd21c-1c53-429f-9e40-e5955976be89', 'Amanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '8363918b-a0a5-461f-88ab-a059b0617115', 'Marcela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'dcebfc03-6e61-47ba-a3de-da8136972ab8', 'Zezinho', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '7ef4d644-acf9-4338-9ea7-11e3ebc528f6', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'd33ee00b-8cf9-4811-8750-c37d95657d22', 'Cida Santos', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'ac9d6881-551e-4abc-a986-1eabeb1758c8', 'Cida Lopes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '9b978c76-0bf3-4b11-8de0-8a157a1f7ab8', 'Mateus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
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
    '4af2040c-0214-4ccd-9403-1a586ba3ba38', 'Cleuza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'b50cf975-764c-4825-940a-7925b39373cb', 'Alice', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '04321bac-4650-4bc8-b53c-fcc6c0cce6a7', 'Roger', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '0e3034af-bc94-4a2c-99bd-bb65a322881d', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'c6778a0b-c19b-44c3-aeda-634a715b64d1', 'Mary', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '360c84c9-a3e2-43ea-8445-331e799038ed', 'Filho 1', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '77d2c33a-2aea-49a2-967b-d668597a4c69', 'Filho 2', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'f22a09e7-206d-4b15-9d12-761fc096ad08', 'Marly', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'c0f4a9b7-9e79-4374-8a74-7abb0562d4a6', 'Marcone', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    'd9f57c30-8b9b-429f-a337-78d9403784f4', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '60df6500-4a69-480f-830d-79a024c5595f', true, false, false, false, false,
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
    '966025e8-dd0a-4c08-8848-97c0b5c17ae2', 'Vera', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '34296481-6906-4e4d-ac90-85a14d11c4fe', 'Luís', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'a3af907e-54fd-4949-935e-743a9fa3d25e', 'Didier', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'e4f802fa-d427-4c44-8cdb-9e02168b9f81', 'Winter', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'ccdb1acf-f78a-4a09-89f1-73d3e451f4d0', 'Fernanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '4b4ccbac-d7e3-421e-9a71-a5e8eadd66ec', 'Breno', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '4185d295-a4a6-4835-a44c-e9bf08df2168', 'Geraldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '032c0ffb-af55-4fea-82f1-d4a4fca9100f', 'Maria José', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '31c93768-8752-451b-a256-020d6a1a1852', 'Leonardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '0c2480de-42b0-4e3f-b64c-eef93e0e180a', 'Selma', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '5d2c361b-81d8-42dc-b8d1-6e037864faa4', 'Rafaela', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'c63bdcc3-4588-430f-8ff6-dcddcdffb8fb', 'Antônia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '53203785-616d-4a31-9593-6e481c89d67a', 'Marcone Júnior', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'cbc61792-e9a2-44e1-a42d-224091a741be', 'Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'b78d9a4e-bfc9-49c5-baa1-ae4343c0be6a', 'Karine', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '2dcff0c2-8fb6-4b10-a818-31df48a6dfa9', 'Isadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '2a8f6153-331c-4802-a97c-70cdafd33edd', 'Isabela', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'a3567819-fa33-47f0-a524-4a341fc92543', 'Cecília', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '2745f373-03cc-4f80-8746-445e9d2165e0', 'Matheus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'ee3b39fb-0c8f-4d4c-9ae8-2d190770de0c', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    'a18bcbeb-4dc1-4e8a-ae94-009ca8c5d592', 'Hadassa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '96fbbcde-b4db-4722-9dc7-62c679bfe3ba', true, false, false, false, false,
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
    '990f1ea3-5b50-4fb9-a1fb-468be7f7d401', 'Cleber', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '49840429-448b-4c1b-b771-f35fa64908e4', 'Cida', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '5fa25dca-a17d-499f-862e-762e9a98ab47', 'Sidney', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '3228f88a-57ae-4e20-8fd3-f9f4c4484c1e', 'Suzan', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'ee262263-390e-45f3-8ffc-4d28304c92d3', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'c1cd96e8-5c7b-48ef-b2c3-c0f877863959', 'Ana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'ccd59088-0191-49f8-a45b-f0fe47f1039f', 'Lucas', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '349e8422-7439-4fad-9b96-d85693463cde', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '07fb0524-4445-4c32-8fe7-2756277c0ded', 'Hélia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'ab91841f-86d6-4743-8970-a5a4261a99a8', 'Renato', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'b24d02cb-a015-4eec-b033-6cf5cf966efc', 'Eliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'ffccf940-9cb9-48fd-9d2c-3ff705c19424', 'Lavínia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'ef469136-4e11-447f-bf4a-bfa642b87cdd', 'Valentina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '192eeec5-465b-48cc-9f42-5f1f8dbdb092', 'Ediléia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'ad25452d-4b9f-42d4-8d48-aac7ca567823', 'Daiane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'f6fa9609-1ac7-4dbf-b5ef-218a11da7148', 'Felipe', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'e4febcdc-6ad2-4d86-907f-777fe3e54fe7', 'Esther', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '9ec1fbfd-c5e2-4ed5-8d89-55d795090662', 'João', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '54abd5f9-7f2f-4e98-8e52-b75e8d25cc28', 'Sandra', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '72053eac-faae-43a6-a0a5-46d040c9896a', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '63ab4c35-ce1a-499b-a11a-0514806acbb8', 'Edmilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '567d6799-96d9-4614-add0-dc95fbc4ce76', 'Moisés', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '31416e72-03a7-4a58-b4dc-a9d65437b03d', 'Ramani', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'ac032b66-3119-478c-b1f8-102db8f94ecf', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '1c7d29ae-4f1e-47f4-82ec-d04fb86ea0c4', 'Débora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '8442a6af-b44f-4db5-9af5-0d89d232b7e9', 'Juliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    'ca2676d5-281e-451c-8b49-917af531e292', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '62451771-26e2-4664-a887-ad433850de09', true, false, false, false, false,
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
    '92c403a6-e91c-48e0-96b5-0004b18e39c8', 'Dimas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    'f08fe565-b8ed-4fa1-bd4a-6d98b521f983', 'Nívia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '8b74ad5f-e0ce-4e1b-bf77-7db4a9438f73', 'Artur', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '49ff983e-d7c6-449b-8f1d-c321b1725d3c', 'Heitor', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '636f0f98-e7d5-4fb8-a324-edc9aba51787', 'Douglas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '53158ea5-612e-417d-94e0-4743b0ce4655', 'Cristina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '93fe0a62-ed96-4bbb-ac4f-1dcc0491f124', 'Gabriel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '05264f17-5964-4a00-a5c5-b4156b5e8f18', 'Felipe', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '224e9a4c-047c-46d3-9030-993039dbadaa', 'Cláudio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '8f1722be-a5e0-4342-ac4f-72c081575e13', 'Cinara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '53a4f65a-a8a0-4c63-b5cc-d753164f580a', 'Saulo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '91bdc470-6cbf-4e68-845d-a191886ad3d3', 'Duardin', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    'ec502851-ffc2-4242-af79-539977507905', 'Angélica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '3239ea04-f731-42a8-ad57-e745f44c56ea', 'Lavínia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '82c657f9-f526-4027-8b2f-e1480d689cb7', 'Lara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '1111540b-5192-42e6-a6c0-9a24c0a6bcd0', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '6955274a-bafd-4d77-9e7f-abe74c2def68', 'Aline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '36df4762-3c20-46b5-8228-c027fc4e6554', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    'ac8b28ae-4e55-475f-8635-6bdaebaa0e96', 'Ana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    'aedfbc3b-89c5-400b-a14c-8f486b93af31', 'Graça', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '16b6a3d8-34c7-496b-be77-e90d6fa0e47d', 'Jane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '857b2234-3912-44b4-bda6-f9f9831b62be', 'Kézia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '509992ac-ac5f-45e9-b228-5da31ef15e03', 'José', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '8769e06a-d6b1-4560-ae86-0c0b16129822', 'Geralda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    'da2e96df-4bda-41a3-8e48-b97def41f0a9', 'Marta', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '03d413f2-4502-4ca2-8beb-562de4558464', 'Clara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '8871d876-ddf8-461a-bddb-af4a14962967', 'Adriana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
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
    'd1203429-b964-4c92-8c80-9ab3c1711499', 'Davi', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
    'Casado(a)', NULL, 'Belo Horizonte', 'MG',
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
    '7f86ec93-2f8e-4881-a66a-be6f3251eb0c', 'Wesley', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '2efdfc69-ccfa-4b05-ab5e-aab60ce947c0', 'Elen', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    'cee0448b-1563-416b-b3e8-57d5335e5674', 'Júlia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '22d2b7a6-61ed-450b-a02b-555e35051935', 'Laura', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '2e7a357c-38f8-455f-9aaf-32d46c46eb63', 'Cleiton', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    'f1670eef-34d9-4ea3-90a1-838e7c7808f0', 'Milca', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    '8a880a85-0849-4961-b4ba-b4862c40f963', 'Mateus', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '741ef189-124f-4e6b-82e6-50a4f97858ed', true, false, false, false, false,
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
    'f5dcdabe-3257-44f2-89e5-efc5baa9b8c5', 'Jaime', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '48fdf0df-594e-4128-8512-fc213677a517', 'Jacira', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '04eb2d28-05ce-4765-90d6-872ea298b76f', 'Rafael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '75636c7c-2015-432b-a7eb-5b195aa126fc', 'Dona Adélia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '628b867e-dc09-453d-b90f-851c5168a3b6', 'Wagner', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    'f8781f2b-f8b8-4ae7-b206-1c037207a141', 'Mariana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    'f8c7e97e-efb6-4b45-aac7-2dee6ecbe597', 'Beatriz', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '3f436c4d-bea3-4d26-9122-f993e8966f7a', 'Rebeca', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    'a8ff0ce8-7e84-448c-afbc-c447b7fff2a8', 'Ronaldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    'd3e572d2-d65e-4cfb-a3b9-7be0f363909b', 'Geraldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '89bd2092-73f1-48ee-a2f0-6b18bee4441f', 'Glória', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    'fe54992d-fdff-489c-a738-66330c6c567c', 'Marcos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '66ef2df8-d34a-4242-ad63-e15e1d970fb8', 'Rafaela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '86096b47-9e2b-4dbb-a85d-ec8e06b19f07', 'Aurora', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '1f7ab833-d232-4e73-8c6b-8853ddb32c28', 'Maria Tereza', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '68cd5ce4-6b4d-4fcc-929a-658cd7034385', 'Welvis', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '8e588129-af0f-441e-be1a-2df53f2fb47b', 'Adriele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '4d99852d-e6ce-4ee0-8f2f-1240f2d19649', 'Bela Maria', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '7673c3fd-f08b-4cda-a84e-029f1cbd0a34', 'Izaque', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '4063456d-0b92-4443-8258-23e3fc53112f', 'Jamile', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '7871d796-e05a-4b43-94d9-8f29487ea5d1', 'Kailaine', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '4e2b2d65-59c8-4031-beae-0068f7292ff0', 'Angélica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4', true, false, false, false, false,
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
    '12aafabd-bd35-4109-9d10-29e5f8126646', 'Davi Cunha', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '8784e30b-219f-44c3-8dd1-9f6d991f4937', 'Liliane Cunha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    'a9077c92-6f2e-413b-bb49-6ef1391fefbe', 'Diogo Cunha', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '0bc9d299-9a6e-4fed-a3f5-1ff6494b5834', 'Thiago Cunha', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '4d0a36b7-61a5-4cb9-af84-41075b0892af', 'Luana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
    'Casado(a)', 'Imperial', 'Belo Horizonte', 'MG',
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
    '258bf4e4-59d6-4990-90f9-774eacdc0915', 'Gabriel Leonardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
    'Casado(a)', 'Imperial', 'Belo Horizonte', 'MG',
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
    '3592cee7-0ad7-4efa-8bd6-ac5fb0c263c9', 'Giovana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '50959c57-d6b6-4c2f-9d92-48bdbc7d2da2', 'Fátima', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '3952850c-6500-4699-bb13-f92017549541', 'Krismary', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    'ccc6b7b4-0bca-493d-86f4-14e95115785c', 'Wellinton', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '585b6b37-cdc4-4291-af68-41f734050072', 'Miliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    'f063d061-ca83-45a9-b726-92cbdbd76d2e', 'Gellissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    'f6be4ad4-59a9-4e00-9df6-e66c30280c27', 'Kal', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '734d213a-2614-4db5-864f-9f0bec35600e', 'Tininha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    'e3fb6a2d-5c18-4f05-9147-2c09c7cc07c4', 'Davi', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '1a771a08-d77c-4642-a467-cfc28986ee96', 'Mateus', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'd1c0a07b-445a-496a-937f-5e38fb9f42c8', true, false, false, false, false,
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
    '405a1194-8de6-4574-94be-59c7f11f4e4d', 'Lincon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    'a9422e33-5760-4c77-a371-ef03ae46aeb3', 'Tati', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '964e6c7e-b6b1-48a2-a0f4-b8490ac61bd9', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '9d5f9b5a-4324-4e64-9ebc-a3c348005b43', 'Samuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '0fe5c509-3f0d-45be-8011-2360f3fa73d5', 'Benjamin', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '7b041cfe-2812-4a70-86af-ec0e8eb7ecbb', 'Adilon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '74a6b813-9e9d-4821-aa25-e6c0617af855', 'Lena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '3e7a77c7-420e-4aca-9531-0f1362627ac1', 'Luíza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '7fbf32b2-8d71-421c-bc10-a7b35d82f9e9', 'Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '575b9cc2-74af-4dcb-9dd7-dd04321921fd', 'Gabriel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '34b393d4-49dd-4d8e-b2a9-fd9e33cca567', 'Milena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    'd0608af7-3ce2-41ef-8fb3-1aada02ca96b', 'Isabel', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    'afc77f80-8261-4e97-93fb-0e986839f8be', 'Davi', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '17c4dfad-a19c-48a3-8b5c-7857717d4805', 'Daniela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '5821f373-fac7-4586-9c02-ee70f925d38a', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    'd075c19f-d349-4f03-b5ea-841834dc7743', 'Leonardo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '2451872b-a223-44bb-93f5-0815964a8854', 'Bernardo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '5be0e19c-aed0-494a-bffe-47cc4ab70103', 'Neto', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    'be26f95d-e753-457d-b7e3-4c070946115a', 'Thaís', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    'aa87d896-09a3-460e-a1c1-70adc7c0de85', 'Mariana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    'c3b373ad-2dcf-47ac-a8b1-691bb72a6ffe', 'Luiz Fernando', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '0cf84e5b-cb6a-4e31-a4df-bda79ced0ffa', 'Lucas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '4e7f4b53-2a99-4d40-ad41-c872cdf55389', 'Amanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '09bf4dbd-9df6-4b23-85f8-7844f458b75a', 'Benício', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    'ba1519db-bc29-46a2-b3bf-c0dd3d657c2d', 'Augusto', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'dd962002-7930-47e8-8969-7b6202750e62', true, false, false, false, false,
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
    '8d666902-6f90-48e3-b1c4-42d67caa4955', 'Fernando', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'fc3ee5d0-7e0d-4ae1-bdfa-d9d111412eeb', 'Sônia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '35534c26-cef7-48a3-baae-0946a252d735', 'Miguel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'c2f1e02d-0ca6-400b-966a-10bc625da747', 'Soninha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '2bfad71d-8f66-4e57-91d0-293f970f819c', 'Gustavo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'f1dcc02a-491c-499c-8618-1b8b299b9fe8', 'Daniele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '1349685b-8d14-4b6b-8c02-9422718f8bf3', 'Lívia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '8dcfac08-3e6f-40d6-88f1-79ae5373d030', 'Lavínia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '40921dbc-13d8-456a-8fa6-a4e0136e58dd', 'Geovana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '26cd32fd-e99c-42db-b040-73f21aadc9fc', 'Emanuele', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'a2ca4445-5e27-47c7-a148-637414771941', 'Paulo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'f1d0afdf-58bc-4281-b626-642112543f28', 'Alcione', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '8de823b0-5304-4e90-8d19-f7b67f1236f0', 'Carol', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '2f5cec64-b9ad-488c-9bfc-5db097d2f306', 'Alice', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'e96303af-2375-4dc3-85f8-9cb1b2b97484', 'Abadia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'a508cef1-673a-4592-9213-29834b3ac4df', 'Dona Vânia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '87c15b96-d823-4d7b-989e-18dbe768a026', 'Aline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '68640f55-328e-48e4-84d6-69b27841c2ce', 'Bryan', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'd119de4f-cc6b-497f-b93c-3da08d088dab', 'Evandro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'b032182c-cd31-4084-bb12-5b46723cbe7d', 'Jucilene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '2715d16d-ad81-40df-9169-ee6ebb8c9f3a', 'Ester', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    'bbf008a8-3409-4b01-88c6-e7e0c9770a8c', 'Gilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '70e12c83-5d7a-405f-988a-9ae97939a2c6', 'Liliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f94c716-9570-432c-b3d9-3308e39e0558', true, false, false, false, false,
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
    '00295091-c15a-434a-bbd8-16d1e0390e11', 'Ricardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    '9f42c79f-80f3-434b-86cf-ed7390a0b6dc', 'Auxiliadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    '6ea48363-d67f-42af-bd52-ab9f129c8686', 'Jonatham', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    '2ec4357b-aad9-4f64-b443-9d531291bdd5', 'Samuel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    '31da6e86-d480-4748-8d1f-880399e5cee5', 'Jésius', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    '4a81a97e-b4b8-437f-9265-b9923f35c1a8', 'Elisângela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    '8c926ada-f173-4d58-8cba-4917dce4f3be', 'Cláudio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    'c1ac2e76-07a4-43d9-8d80-2bb3229a8b5a', 'Ivanete', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    'f0f0bee1-0a25-4edc-b60f-91c1370741a7', 'Brener', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    '0d5781e4-27a9-42a7-b8ec-bd71807ade7a', 'Deivison', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '41d254d7-0f14-4b93-85f1-79930d9a4c56', true, false, false, false, false,
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
    '3861d28d-3a5f-4d9d-8b8a-afef49d483f1', 'Roberto', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'b4ab24b6-ee1c-477f-ad35-705d76af3813', 'Leidiane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '82596efe-6eb3-4c21-beb5-a9736c42d0d4', 'Rafaela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '9014daec-3dcb-4722-b536-18e92292e4c3', 'Rayssa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '9bd4a911-3e92-4f17-a99c-916b02796192', 'Ryan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'e861f0ce-b36c-4a9e-93d7-3d56bf620f9e', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'a55d4fc7-d8de-473c-b366-3ee72f47d0f5', 'Dora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '041952bc-4e40-4098-8a9d-a1c72eeb0737', 'Ana Flávia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'e45c6322-8848-4c40-8394-c337740e8cff', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '7f10aa27-9ce7-4695-a7a0-6ba31370c669', 'Marcos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '5beeb6a8-fbcc-4f9b-aa8a-ad66404b4b11', 'Leydimere', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'b8435eaf-5a3d-4476-83fb-4f705be106fd', 'Bernardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'a9dd3d88-19f5-4bfc-9e9d-de8d1e094fd4', 'Heitor', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '1772deb0-a1b9-466f-acc2-8d1b1f7f9403', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'f22c9ccb-60cb-439c-a971-d99fd7d1e063', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '35815f97-8750-4e9f-9579-5860e1df47b8', 'Emanuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'cfef4ef8-2f46-4a77-8877-ed285891ef79', 'Lucas', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'fab1cdcf-9067-46a0-b675-fba7180871f6', 'Álvaro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'f91666a8-284c-4739-ba98-aef196d741d5', 'Gabriela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    'f4df620d-8a3a-477d-a2a7-92237f18ce4b', 'Olívia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '8198933f-e3fd-4734-b2b4-54057fb4c3e6', 'Maria Aparecida', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '31154092-877c-4416-b90d-64a75a6b3ab5', true, false, false, false, false,
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
    '0a13b01c-8208-4cda-b4a6-63568f8cd7ee', 'João Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    '925e2f60-3558-4234-ad8c-62a12c2afc3d', 'Thaís', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    'f8d3101d-50a7-48c0-9960-713493aefd08', 'Cida', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    '07f6a814-f731-4b00-8b48-3462af59f9ec', 'Lara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    'c63ebda7-e10a-4761-92c4-4a740718fbd9', 'Zinha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
    'Casado(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
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
    '9fecb530-43e2-4a7a-ae5f-0e9bd4d778e2', 'Warley Gabriel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
    'Casado(a)', 'Conj. Cristina', 'Belo Horizonte', 'MG',
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
    '6e2b094d-9a9d-4bfc-86b1-8cb2df890cc4', 'Dona Maria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    '82ab30f9-8d40-4faf-899c-596eb229dc02', 'Júlio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    'f2d496e6-e298-4dcf-9330-266f3de54ecc', 'Andréia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    '8080747a-29ae-4fd4-8cba-9057f60d5275', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    '49bec215-8df6-4fde-b031-51c7f7f4d574', 'Diogo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    '1ee25687-14fb-4824-bef4-85e652fe5e2a', 'Maurício', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1f7ec431-0044-45c6-92c2-6006677f401f', true, false, false, false, false,
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
    '1e82391f-bc35-4f33-a7b9-464cefcf9679', 'Júlio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'b19ee2d0-50e6-4050-ab98-de66bd0700e7', 'Valéria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '6c511e77-8871-4f10-b4ed-d156b1e48bfb', 'Filipe', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'c67e1524-c69d-406a-b04b-861f333279c8', 'Anderson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '08fe0f2d-9f4b-4743-8b93-f41a3b1b6729', 'Kênia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '95626365-622b-4647-83a8-e54bad8617be', 'João Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '2c460c54-cc38-47ed-8526-42660e9d2062', 'Arthur', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '7d762968-aa49-4470-9b03-1e1ecc4ba5bc', 'André', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'd2bdf3b1-073b-4348-833c-9bd383271107', 'Andréa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'e322df3d-db32-41f9-be1b-5fcabe44fbc6', 'Isadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'face4ee7-5760-4346-9994-0e114e6599d2', 'Marco André', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '8e8c74f6-30ea-47e5-b0bf-d7cb3ebf388c', 'Genderson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'a012b0e3-a129-4102-b1b9-6ea412287d6f', 'Letícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '8b6254cd-feec-44e3-b2ec-2718351cbf6b', 'Sérgio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'bb2354b6-b65a-498f-b323-e0870fbc06f2', 'Kênia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '8d24179a-f7c9-4fd1-b1cd-093c0d3250ee', 'Priscila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'e7526a5d-b3d0-4722-ae5d-4cc8cd4aa720', 'Bruno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '61b5edca-66bd-4201-9655-52c1235bb292', 'Juliano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'ace85718-6156-4e85-98b3-88bdc070e884', 'Letícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'd5bc892c-6bda-40b4-9e0a-8780809d5c1a', 'Bernadino', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'fa595664-7f5a-4986-bd7a-83fb09c87653', 'Jorgina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'c988f65b-1580-479b-a32a-3bdfb46b8c1e', 'Ricardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '6413580a-96de-43e2-8de5-4e3cb27f3405', 'Beatriz', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '053f6040-0fa5-49cb-8683-62045ff5594a', 'Nicole', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '180231f4-0b84-4bf2-b8b8-939f9235dc76', 'Valéria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    'b4cb177e-4c9b-47ed-a736-ea29e0d59277', 'Mariza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '757c9e11-799e-45c0-8108-78f625aea053', 'Jorge', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '60339e5b-6921-4659-a487-c359d353f403', 'Ana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '452cc76e-beae-4134-be2d-56b6030aa30f', 'Amanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '6d41d8e2-5303-4b83-8e59-3cb61e71aa31', 'Cristiane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '661e6f3d-d13c-4a0c-bd81-d62d2b206c52', true, false, false, false, false,
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
    '93527aa0-3388-48fb-a303-aa4e2f161292', 'Rafael S. de Moraes', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    'fdaed233-614b-4752-8982-a5a4afb8ac00', 'Isabelle C. M. Moraes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '854886f4-88d9-4062-9488-a13c3a6a67c6', 'Beatriz M. de Moraes', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '54e470f0-e5c8-47aa-b64d-806a0506cb53', 'Filipe M. de Moraes', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '2ff41274-e6b7-4013-a365-46030117bd41', 'André M. de Moraes', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '17ea13af-458c-484f-a709-5147e2b66cd4', 'Ari', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '4581e138-9690-44b1-9087-4afe2b31fd30', 'Jucieda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '7238dada-4086-4f7e-94a3-320909d17c51', 'Natally Silvina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '115a393d-7a65-4838-8509-97b5fb4662c0', 'Wesley Anselmo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '8d48c577-335b-49d4-94a7-148771d9aa45', 'Evelyn Ellen Dias Anselmo', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '71a22ceb-3d87-4f7b-91b6-003e4d9942ca', 'Anna Júlia Dias Anselmo', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    'f69f539c-0816-4421-8bfa-2522bfd940a1', 'Anna Laura Dias Anselmo', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '28e7d87b-f4d1-4992-9424-36c13eeabbea', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '9d0f3c3a-2302-42db-963f-84976f8c1a5c', 'Lucas Eduardo Luz', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '6739e621-4dba-45f7-b3d1-cf18e62c764d', 'Allina Rodrigues Luz', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    'eb9d17eb-160f-4b08-a1e4-1f3c6a5662b0', 'Carolina Luz', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '3cc23eb6-90ac-43e6-81c3-91b745953f0a', 'Maria Fernanda Luz', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    'd77bd9a1-5898-46ee-9c96-9d668ba0f940', 'Leonardo Luz', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '3382db18-dc2c-47f2-8079-0ae2a677964e', true, false, false, false, false,
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
    '37f633d6-595e-4e6c-8db1-1b20d58f28af', 'Cláudio Luís dos Santos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '92f27fc2-3fa4-4cb3-962a-8c7f788fc6ee', 'Vânia Lúcia de Paula Santos', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    'fa05999b-6f36-4dae-84f5-20627d3cf781', 'Nicolas Matheus P. Santos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '328888ff-ef8d-4ca8-9fa5-07beeeb0b910', 'Davi Carlos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    'cbde07f3-06e9-4f8f-ac17-bac632ff2d95', 'Roseli Gonçalves', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '55773dd2-397a-462f-9628-4f948fe51f3d', 'Júlia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '260e2e4c-97cf-4215-bf5a-5af9ed9acd7a', 'Rafael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '34377d8e-1c51-4cf0-b102-9cac18093e87', 'Daniel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '29e3342d-8e00-421e-b9d5-facdfdad5411', 'Lúcio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    'aa29b0e9-e50e-4873-8d87-c0b065ba99a1', 'Tatiana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '5224c4a7-a615-4e7d-bebd-0510585a7d91', 'Isadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '3ef2d0ef-a68e-49a1-93fd-de7ae888abed', 'Eliza', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '041e8a9f-6f91-49c3-ad81-4e461f5ce44e', 'Marcelo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    'b5d9201a-afa0-46c0-869c-798223c7cc52', 'Neila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '2c051969-7326-418a-8cce-14e4e0d31576', 'Enzo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    'c95090f4-7b4d-4b5f-a5e5-10f54a641d8d', 'Melissa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '2b6a403e-ea40-4c27-a8bb-33437e17b52e', 'Hemerson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    'd15ed94c-8602-4d06-9af9-c992b3e1050a', 'Joelma', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '7109142e-8e86-4feb-89ce-9714d8ccbd29', 'Sueli', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '11b14b0f-a249-4afb-a146-a2f5db1ab877', 'Izadora', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '94a760da-6727-403f-bccb-3eb1bea1fc93', 'Isabel', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    'ff8abcd1-43f2-4554-a3fa-e2251a47d1e3', 'Aparecida (Cida)', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '748c933a-4755-47de-bbf1-cb5a121ad3ac', 'Alviclênia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '981af8ff-6a65-4b12-80e2-e9b3cbbbcd3b', 'Rosa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '55ec953a-64da-4d84-9ea6-58885bcb4a64', 'Ferreira', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '04e57724-30a1-4d59-80fe-2e72c97d14f0', 'Gisleia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0', true, false, false, false, false,
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
    '8bb73338-12f6-4285-a10f-31afe4d5578c', 'Willian', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    'a49b79d1-9550-43c8-b5fc-463320674af2', 'Dulce', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '868e6443-25cb-41db-82dd-f55391bdf866', 'Oliveira', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '28e96d3f-8fd7-4fb5-8ca4-0130d48bc3ee', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '658f21d4-5e28-4e3d-a072-04b4207f8704', 'Eduardo Coutinho', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '634d30ef-6fa9-41b4-bb5d-5024d8eb1aec', 'Mariana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    'a51a10f5-0d81-476f-9223-01f58a307b4f', 'Roberto', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    'e9e44a59-1ce6-4a48-a05f-d13038fef5b1', 'Neusa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '4b7f0545-5c53-431e-a2ce-d5ca7302c77f', 'Aline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    'b0e36db6-1898-4ab1-8f33-7aa3dbdebffd', 'Meirielle', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '457165f2-7f6b-42fe-aa6f-7d15ef1852fb', 'Eunice', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '3329469f-bf0b-4138-8fc4-81893080eda3', 'Lucimar', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '444088d0-e2b0-429c-be8e-92bc9e8e16fb', 'Miguel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    'b5d36b78-1e30-4402-b54b-46a04c7bdcd4', 'Maria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    '3b701b0e-ed56-46c8-a730-16fd6674ad90', 'Dalva', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    'e22530cb-846e-4ac1-9795-7c98d62a9d04', 'Lúcia Helena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    'c3ce72e1-7bfe-47c9-9093-6e91d17779a3', 'Sirlene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1b6641bf-c61d-4d4e-bba6-8a22dc64038d', true, false, false, false, false,
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
    'bef7cb3d-e566-462f-830a-b49cfd17b7a1', 'José Alfredo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    'dea3031b-19c2-4f23-ab04-5dedf95d858a', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    'e8dc22f3-2977-47a3-b86c-4b35574c8ed5', 'Isaque', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    '4b7f402a-6379-4d07-bd58-72dea782b187', 'Cleber', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    '2fc397b3-2a85-4b24-ab1e-a93ac1f11ec5', 'Ila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    '10d292de-7111-43bb-9a8b-ccb0afb0eeda', 'Gabriela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    'ce826e12-8bbc-4abd-9f0a-a406db7016c1', 'Neide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    '23f008cf-608c-4870-96ee-dcf3ddd9f099', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    '9437e5f0-3b3b-471d-b016-596834328824', 'Leandro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    'ab86b706-a042-4ca2-8807-c421a88a1d35', 'Deise', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4c2e891c-a3d3-4f53-8379-901a3d9352ee', true, false, false, false, false,
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
    '91645f9d-70b9-4c30-bb26-6dfc8feb98fa', 'Thiago Van Petten', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '42fd96d3-c60d-4897-8690-30a59cdb46fe', 'Nara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'b98b319b-8a43-497e-bfe1-1f79d6bd9eee', 'João', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '3e2cb516-5fa5-4a18-a380-4610b13888a8', 'Augusto', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'b9417779-f563-4669-869d-8e2eb7e45cb0', 'Ismar', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'fdf1b7fc-14d9-402e-b359-91208c2cb5c6', 'João Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'd9a61816-3b72-45fc-9b2f-6f02fa320f6d', 'Sara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '65e24621-8046-43f3-ac9f-a8f5c7266a3a', 'Denise', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '61bdfe5a-6554-4596-9b1d-56ea28d14b44', 'Madalena (Madá)', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'd89f48d7-1bb5-4a64-865f-00a937f276ee', 'Leonardo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'd346581a-3ee0-4da8-8971-4c9940b6c122', 'Tiago (Tiaguinho)', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '978ce1fe-b8cd-47cf-9c61-5c31d1c6ab0d', 'Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '0e404566-ca63-4f64-a186-6cda2b76029e', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'e149b5c1-3f8b-4a20-93eb-e3575c8f328c', 'Natália', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '432cbdd9-f741-479c-a513-d94137150362', 'Alice', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '848ce622-b8bd-409c-baf4-a398b0da96b7', 'Elisa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'eaa86918-e788-4226-b513-a8be7154cf72', 'Mauro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'f682eafc-6708-497d-b994-071933ea5760', 'Marlene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    'ab2c18f0-7362-40bc-9757-bfbc8a86b5b8', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'b232050e-af19-4672-8202-0c2c743d1902', true, false, false, false, false,
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
    '3cd8bf96-86ee-415c-9a22-1e52e6073f1b', 'Jardir', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '94e383a6-2e45-404d-b1b9-5b9bc9e0247f', 'Cida', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '51eb0ed6-4efe-481f-9d4f-a0d783372f68', 'Warlei', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    'b5edbf1f-ac89-4fde-bf31-67fc9a4c1fe1', 'Alba', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '58cc9b8c-577a-4f5d-9b70-27d394c12b5a', 'Afrânio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '0017e641-e8a1-41d7-ae5f-d70dd43ca968', 'Helen', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '8168fda4-8bfc-41bc-804b-168f7ff0c67a', 'Helena', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    'c9cd591f-a9ac-445b-baf8-41fc9e305eff', 'Kátia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '50ed57e5-c957-4fdc-9a16-9399b13ebedf', 'Cassinha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    'ddaa5ba0-4763-430f-a84f-d61d7a9babd6', 'Clemência', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    'fd641a03-b7cf-4106-84f0-ccc70459d8e1', 'Bárbara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '16c65708-8191-4419-8759-5c37b8ddee38', 'Perpétua', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '5d8b41e0-8be7-46d4-9817-ade8532b69c1', 'Ágatha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '902f6149-a059-404b-9c40-bb6806216d36', 'Maria Luíza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '4ee4f066-2e53-4b28-922a-e01928c69135', 'Claudinha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '0015145e-5457-46f8-9111-2abd0ad8e339', 'Saulo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    'cb6d4b25-6eb7-4d22-97db-46ba47f53602', 'Kioko', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    'aabe8c2a-1e33-4330-9ee1-9eccf746f3ac', 'Denise', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '68159ccf-57b7-4756-8b1d-7a76dd0b4346', 'Wellington Ferreira (Shibas)', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '476fd88d-05db-4f7b-bdbb-1353c8a78f47', true, false, false, false, false,
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
    '8a4ed24b-13a1-4fcc-b278-18f547e73fd5', 'Luiz Henrique', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '312fa654-647a-4b1c-9ef7-78c1703790d5', 'Charles Pascoal', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '68730bca-3b01-4f20-b762-2fb3ffec054a', 'Lorena de Freitas', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'ad3bac89-6ab6-4c6e-bf5d-025731eecb10', 'Ana Raquel', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'eb21e876-0f49-4bb4-a4db-801dc6e42b0d', 'Davi Ribeiro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'ee496571-41c1-4393-b619-08a6c25bb725', 'Jehanne', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'b595331b-b8cb-4dc2-809d-e05aa5e0a2b8', 'Gabriel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '7e2a61d3-2712-417f-86dd-bc10d2abd0f0', 'Samuel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '41218eff-9149-4c58-ae61-c8158bb26485', 'Tiago Ribeiro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '4960506d-d84d-4ee9-aec9-8c008ef1c2b6', 'Edmilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'c447f2f8-ca89-47a3-a88b-9fd9c24edcfe', 'Lídia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '87635b1b-10ca-4b86-a829-78bcc374b178', 'Letícia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '5dc19046-ecda-4bf2-99fe-bcf490851948', 'Flávio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '2130022d-2652-4ba1-b5c6-a21c71cff5db', 'Darlene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '573e2417-6434-4f03-bebe-6b9b0e1f6cd5', 'Davi de Oliveira', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'd99e258b-168f-49b7-830f-539c125226fc', 'Jonatas', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '3f33f8d4-e1e7-4730-b8bc-2490d8bf419a', 'Marisa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '12f03b89-fe95-4c76-846a-ce0f04104024', 'Raphael', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '372a1d97-58d7-4397-adbc-6af556a87cae', 'Sophia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'eae6ff2d-83c3-45d0-81ca-3149e1e70e53', 'Emerson Heleno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'b5850315-518d-40f3-af24-30aba539621b', 'Caroline Fátima', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '011c3a97-0048-4908-b658-3112fa9c2652', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'b3ebaf91-af1a-406b-8633-ea5498f1cfb1', 'Tiago Heleno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'b41a97f7-f4d2-4d52-bff9-b892b3e384d3', 'Samuel Heleno', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '3fcd870a-3c52-484d-a80f-c54719bf957d', 'Isabela Heleno', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '5235c9d0-9f2e-407e-9e9f-21446e6a11b6', 'Ilia Fátima', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    '80a33004-f4cb-4f87-b560-bbec77b881a9', 'Glaydson José', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'a08f343a-cdbb-4101-9658-57252f88a03c', true, false, false, false, false,
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
    'b251487b-ad05-45d4-8fee-7430d15bb307', 'Alexandre', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '391d8530-09e1-4def-bbfd-2fc72881e8f7', 'Érica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'f1c0d5cd-6f94-47ef-bf5c-afe54e65a864', 'Pedro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '8bff6d22-d7cf-4b9d-83ea-d881d0fb3d78', 'Valentina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'a803aed2-3a87-4ceb-8267-371e3cbc5742', 'Heloísa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'f8bcba15-ce59-4477-a78b-39fc86521461', 'Tames', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'db3404ac-8788-4a6b-9751-e681bef1508b', 'Michelle', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '7b68a6e6-429f-4064-b07d-bf285ccfd659', 'Helisa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'ae63ecf0-2119-4c74-a29e-cfa1b2b08edc', 'Adelmo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '99c73b33-41e9-4a2e-9940-85a2e78884ae', 'Júnia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '79de54fc-6c6d-49d6-b37d-0a3dd9f1db8e', 'Neuza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '685d62fc-3a24-4002-8c34-d7b682dd50c7', 'Rosa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '01c8b898-6a7d-49d5-ac69-fd49d9c84cff', 'Juan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '2873ea53-833c-416e-a70e-c73f5fe9bab5', 'Ximena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '50b20bc8-b910-4ecf-a98a-23aeb688dd07', 'Valentina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'dfe365e9-2d5d-4f14-8e1c-d230b2dffee1', 'Victória', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'be8f2ccb-711c-465b-9e16-f04134ed5131', 'Antonella', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '5b5c96a5-74ae-4ab4-8983-8061c9bf75b2', 'Júnior', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'eab04353-d3ac-4747-bab9-f32cdb8474e8', 'Silvana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    'b0c09296-83e5-411a-83b8-c5c757652c7f', 'Emanuelle', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '4f8199ea-63af-491a-b6f1-b9a6d7356789', true, false, false, false, false,
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
    '7e2c1782-40db-432a-afe3-648e65b406dc', 'Jairo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'dbd4bc9e-38bb-42aa-80f2-2473630bf757', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '46f5df4d-e010-4629-ac35-082377d49a68', 'Camila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'ae8cafbf-9327-447b-b926-5c3e80637d20', 'Lucas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'c13e83de-4188-48cf-808e-ba7bead2901a', 'Leandro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'e3695a3e-d982-464d-8156-b81135549ffc', 'Eliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'e73cd1cc-cdfb-4020-8f48-43c9c408456e', 'Emanuele', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'a493ad68-2635-421c-9a8a-8dba31568b9f', 'Geovana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '77a271f7-cf11-4abb-8b72-5cd7292ffcaf', 'Davi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '1c48d1a6-1d1d-4273-a4e1-e0b97cfe3c5c', 'Warley', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'a5103498-0694-478d-8b8a-b98e7e71557a', 'Deise', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'd7d5d029-c8ec-449d-a767-51c6de6e13c9', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '221c9a87-b4f8-4933-b1b4-e03b3b1c0b81', 'Jetro', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '9add99e1-7d93-45cb-83e5-0c103d603e63', 'Olício', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '29665ad5-87a1-40d5-8adc-2ac09c768461', 'Luana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'd604e548-2245-4d2d-8f13-8ed5bca9ca83', 'Noah', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '74271be5-e8db-4e36-b7cf-bb33e6c25991', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '83066baa-842f-4af1-b6f7-ee2aa3d9b2a7', 'Daniel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '37286d4d-11f3-4f9f-9b3a-302bcec416e1', 'Jéssica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '8d99031b-4589-455d-bb33-6ac6ffca661e', 'Marcos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '70fca288-ae64-4695-8be6-46ab3069fe8d', 'Maria', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '9a2f8393-7f4a-4a6d-961f-06f035541125', 'Emilly', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '2555f684-a039-4952-bb9e-dd071cc9ef80', 'José Maurício', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '9eed5b8f-8633-436e-9ccc-10bf94e4c159', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'a4302efa-6e76-4b2e-a70c-14208744e16c', 'Mizael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '29dc3e69-50ed-4df2-a5dd-535e36df3159', 'Helen', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'd0db7f75-d6bf-4b0d-9818-29a3e92a6d9a', 'Luana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    '07af828e-2da4-4191-831f-2aa85bc48c8a', 'Júlia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '312b5a0a-0531-4c3f-b0f5-d9374b936374', true, false, false, false, false,
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
    'c392beb4-fdf3-4bc9-a08c-f759283197eb', 'William', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '8aa2c083-7ee2-4bc8-af16-f52e34bc7856', 'Simara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    'ac644edb-2312-443b-b719-be15fdf463fe', 'Wenderson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '2a0b5153-9d3c-489f-80cb-d1fbad468c64', 'Renata', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    'b7a79bd0-0db8-4c7a-a052-c00cdabe9bb8', 'Fátima', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '2be4dce8-29d6-495e-9c2d-2f056e9af477', 'Fernando', NULL, NULL, NULL, NULL, NULL, true, 'M',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '4b3871c0-43a8-4e1b-a60d-3a7dbbe5fbba', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '743c8736-0bf0-4be8-bca4-c168d3384bb3', 'Natália', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '1756d57e-4f77-442d-b4f1-bafaf109ea0d', 'Bianca', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '6315e802-aee3-49d4-90db-9fb8add51fc9', 'Gláucia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '675056a1-7f67-468e-bdc1-56000c042ad3', 'Fernanda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '95534aeb-bed1-453e-92ed-07dbba118ea2', 'Bruno', NULL, NULL, NULL, NULL, NULL, false, 'M',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    'bf45baff-97d5-4648-9999-d3a34360bb9f', 'Luíza', NULL, NULL, NULL, NULL, NULL, false, 'F',
    'a9f09fed-c299-4eb7-a1d2-92a518c98e7b', true, false, false, false, false,
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
    '6a4f4dc5-4836-46a6-b553-a57faee1faba', 'Cléber', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '9787a3e1-3e4f-4b7b-9399-1e24fbf69863', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '23feea2d-832e-4fa5-8904-b47fea03f9f7', 'Camilla', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'a0b1113e-10d9-4462-8920-ba29b47999ba', 'Caio Vitor', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'fc28c40b-7bfd-4561-8583-b7d84c0587da', 'Marina', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'c8ebac1e-9962-4d63-8fcd-74b653fd202c', 'Marcelo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'efc94b49-b067-4780-ae04-1b6fe2b73a61', 'Simone', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'bafc5f79-df7c-407a-a760-69565fcc8143', 'Beatriz', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '77f43703-ced7-4581-b2ea-0aebff732ff3', 'Maria', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'c5d068d8-e4da-4b0b-b067-5237b2ea454d', 'Bruno', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'a1c64fa1-1df6-4a0c-9da4-4cc14353aeb1', 'Vanusa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'bfdb4d61-01f6-49e1-ad62-3b21da705859', 'Abner', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '7afd0614-d8fc-4f6f-9b60-b65dba2fd3be', 'Fabiana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'df1c5b58-87bb-494a-9f75-a9337411d3a4', 'Levi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '9e66283f-289a-4c97-afc4-6ea0e9b857a3', 'Sônia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '65abd327-e3fe-40fa-9c6e-da4ed497713b', 'Nely', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '9668476d-7806-42c6-9780-2d02e3fd0fdb', 'Rafaela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '714ea99a-dca3-4cf9-a140-2be10b28cffc', 'Luís', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'd65e5659-c51e-4437-a022-67bfa5932749', 'João', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'acba2af7-57ea-4be8-915b-652d2a49da78', 'Lourdes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '4ed9b368-cec4-4138-88e0-54e64c0ef68d', 'Denim', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'b7b34209-937c-4bd1-9a1e-471b564c869e', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '70f6abb4-1669-444b-8ece-f238c20b9f40', 'Ismael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '7dd11c76-5582-477a-abc4-e6a79fb549be', 'Isac', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '82fa05f5-0881-423a-b895-860044fc56a0', 'Daniel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '8b0b4bad-a45b-47a9-a038-5183c8d8ad91', 'José Geraldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'd67bb2ab-36cf-4fea-832c-05d1ec72f910', 'Fagner', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '4a38637b-f841-4b0e-9c20-9fa958588a48', 'Lauren', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    'b05eba22-69e8-42a6-ab62-4de61a783a88', 'Rosângela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '3ef3c52d-33ee-4761-b9b9-69116adcf85d', 'Suzi', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381', true, false, false, false, false,
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
    '8970cb37-167a-4f5a-bfaf-80f45ab453f8', 'Marilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'a84d3ab2-733f-4bc1-bca5-9d08a58a0e4e', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '8fbb94d1-3507-4f79-b298-2e63d53f0a53', 'Benjamin', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '4735de7b-691e-44be-8cc0-37ff915049e7', 'Gilson', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '8bef510e-f17f-4fa0-851c-c07a5a1082d5', 'Nislândia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'd3cdf99a-0d86-44d3-8df0-eecd472133b6', 'Izabela', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '3b21a16e-54d6-411d-939e-450d4a4d9d69', 'Ana Luíza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '4579dc1a-5321-44c9-87d9-05a11b6f775f', 'Rafael', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '6eee9caa-c1fc-465b-b719-45a86beba2e2', 'Wanderluz', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'fca3a6b5-2d65-477d-81d8-543230949261', 'Janete', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '7093987a-29b5-497c-b81c-1e0ebb1706e9', 'Eduarda', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '67dcf960-a21c-4cb6-9098-bad9bf8841ca', 'Carlos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'ec84ddec-16d0-49be-a4d0-250b4b5e0433', 'Dilvano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'e7434ed7-3f56-4953-a23e-034fc2e0a869', 'Edilene', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '1b8a0ed7-b818-4b1b-af8c-0d37d3a245d8', 'Ana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'ba12c36e-7aa5-437f-8148-6c2dc1a9beca', 'Josué', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'a4b595ec-b537-47c2-97b3-881f300cc8c9', 'Lorena', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '0515d36b-74cc-4484-a526-20b223b3a69f', 'Miguel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '77de958c-717a-4d3d-a463-646ab8db1734', 'Emanuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'd6a6588f-673f-4e6f-bd78-3d33cc8b3766', 'Guilherme', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'cc1b3197-6312-44c1-9a6a-ee502b2f740d', 'Priscila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '0b5be951-fe41-4016-ac3d-d38d12df1fb4', 'Suely', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '77929dd0-bccb-4701-9aa0-a0babeafab1a', 'Filipe', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '93328aad-b7e3-4447-999e-e7e8506b5725', 'Talita', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '7a5a4905-d5cf-416f-a274-9b35748332b5', 'Benjamin', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '185ccd35-bb37-499c-a8d0-180d8b2b1d89', 'Luciano', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'f501f4ef-04cb-4e4c-9fdf-03f3716384e7', 'Joana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '41d5ff61-4e29-4ec8-b007-066add539036', 'Raíssa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'f7ee9961-667b-41c8-8e78-07a6ff4e994c', 'Luciana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '678ebfdb-33c5-42f3-9166-ff4909c4c230', 'Abner', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '04711b8d-42fb-4a56-a952-f5e0b54a34a1', 'Ranma', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '387b0044-7d08-4ee1-8a99-b07b17161a2d', 'Jonata', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    'b4ccab99-a18f-4294-8ba5-8904be9f554c', 'Isac', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b', true, false, false, false, false,
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
    '5235e5d4-5633-4304-89b1-619e8a593fb4', 'Artur Cunha', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'df34ee47-9c3e-46d0-bb72-209c52153ed6', 'Thaís Cunha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '02508945-3bb5-4825-a1d8-150bf28f9896', 'Isabela Cunha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '0f3e4a36-26c5-454e-a582-c046a95c8f72', 'Júlia Cunha', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '0494e0ba-2d26-4d34-9087-61af0c76ce72', 'Sofia Cunha', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '67c0aceb-5b50-480e-8b32-35d4ed61f7a8', 'Douglas Macaúba', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '0fdae6b3-4fc9-4e0a-9fc9-698eb0b35b10', 'Carol', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '30ebdf02-6644-437e-b9f0-75a9f613b043', 'Gabriel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '9e6bab41-7b4b-46fa-b634-c24a5bb6b69f', 'Thiago', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'cefac67c-0b39-4c2e-af20-2fe0a6fecbd4', 'Carine', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '7c433288-8826-4672-a3bd-8adbe7d1781f', 'Melina', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '4e746430-0b72-4e24-b781-e634c54e4fb3', 'Maria', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '2d698fb0-4152-4ff6-a6e5-5bde71d7607b', 'Diego', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '1bc8bd81-6d1c-4fab-81b2-8b2fafb9e8ff', 'Gisele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '02b652d8-a3df-4685-bbc0-8f66030c7435', 'Samuel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'ebb81cb3-5ed1-42d6-9a65-988d83f89802', 'Graziele', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '2c852362-1656-4b9e-af59-272b2cc412fd', 'Imaculada', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '274f7471-362f-4269-ae3f-b8903434dfba', 'Carlos', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'ed709a28-a9eb-4b72-9101-1b337f389c9a', 'Vinícios', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'e27ee72b-fddf-42aa-b3d8-17424a74d8c2', 'Sônia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '603ea64b-08c6-41c2-8b9f-629815602a73', 'Ana Eloísa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'b1e25fe8-ee14-4bfe-ac27-e05f8670a9ca', 'Maria Júlia', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'dce0f2b2-0aec-4de5-a906-9bc162044ae1', 'Heitor', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '582693f0-538b-411c-bc0f-6b1d13ee18b5', 'Martim', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'cd5152cf-676f-470b-82c3-a7ba999573ab', 'Adriana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'ed35d11c-a71b-4b63-8f1d-2a4a7cad180f', 'Laura', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '4f33aea4-39ce-4e24-970b-45976b0fed49', 'Ester', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '5b9b56e0-70f7-4f89-a236-e3d855c06dea', 'Gabriel', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    'a1f82b81-e7ee-4dcb-981c-3fefa77de9e1', 'Isaque', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '07b8c447-b82e-427c-a241-8e32a731081f', 'Zélia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '46777d57-be20-459f-bc35-b939b8b451b4', 'Keila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '76789e7d-25f4-4544-ae57-051adc1d01ec', true, false, false, false, false,
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
    '2dbbd7cb-2b1b-437f-84aa-57b1e353a362', 'Lucas', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'f18f93a5-61f7-4013-b29b-53748476e6ed', 'Leila', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'dd8ba744-9ae6-465e-9282-c3095fc81612', 'Ivan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '8a1a74c6-9481-4382-97f8-76ba59b9ec1a', 'Ester', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '2d65db4f-e820-43d0-a8c3-a6fdc2d89385', 'Eliel', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'b3c4a3b1-c80f-4015-b913-e65ce743c113', 'Fabíola', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '35c81e66-ff07-4811-9f37-3eddb60ebb51', 'Davi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'ccf50420-ffaf-4e22-9258-a3610d343bca', 'Ana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '2d249150-6edb-4cfc-bca2-b51df7bfcd57', 'Ramon', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '2cdca0e5-bab9-43c0-9907-d49769e3dba1', 'Natália', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'e29c7835-e16a-492c-ab8a-a28ad0ad1f38', 'Ravi', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '2ab0fd30-19b5-4c33-95e2-964e21df5ba2', 'Melissa', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '2c796d5a-b155-4e34-9f8c-bbbc03f5884d', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'c8b6eebf-771b-448d-8061-dd6810f7c96c', 'Cláudia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '2c82285e-aa13-4d2a-b7b4-178a931a9f4c', 'Nicole', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'd2a909d2-3d9a-40a5-b7f6-7b26590fcc19', 'Antônio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'a665d852-2736-4b11-8f6b-222aca8ecc9b', 'Jaqueline', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '13007c05-4865-4a7e-a23b-2cdf8c1de3ae', 'Verônica', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '9dc083ee-0354-46a7-b94b-e204720540d6', 'Nileide', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'a969cab0-39d3-4778-b81d-f9c2f62ae70e', 'Fábio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '2034e3f5-b826-44b9-a253-d2c8c26d541c', 'Larissa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'c026d039-2d1f-4351-853e-ec80a7b4c4ad', 'Nicole', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'fe3729c9-8fbc-478d-b7ed-07ca598a9e7c', 'Suzana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '54d0e3e0-6eb1-4562-95e0-7d5f1cf72f6d', 'Lorena', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'aa311714-a38d-43f6-b812-568ef8ce0473', 'Asaph', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '805a3a37-87e0-4afd-b533-77b6da543549', 'Leandro', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '584d026b-a444-4e34-bfa8-8586e1c4f577', 'Tainara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    '89cb1e9a-43c9-4279-93e3-caf293a62ac6', 'Théo', NULL, NULL, NULL, NULL, NULL, false, 'M',
    '1c4a5f55-ff93-4bdc-98ca-3486a391cb81', true, false, false, false, false,
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
    'ce252217-9f28-4922-b77e-f194441cb866', 'Cláudio Lopes', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906', true, false, false, false, false,
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
    'cfc7e8b5-6e96-456f-8225-a2c8e572adc8', 'Zulmira Lopes', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906', true, false, false, false, false,
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
    'bd546efa-b813-413e-98f0-cd6039ce368b', 'Cristina Barbosa', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906', true, false, false, false, false,
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
    '02693ea5-be7d-481f-b3f7-a90826d0e537', 'Ismênia Ferreira Rezende', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906', true, false, false, false, false,
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
    'c322c56f-fe72-4fba-8b58-ff4699722b16', 'Maria das Graças', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906', true, false, false, false, false,
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
    'c3efdf1e-0d95-4740-9cb4-4cff274eeec6', 'Samuel Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906', true, false, false, false, false,
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
    '27f2770a-f2ba-42ca-883c-d8160547126a', 'Kamila Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906', true, false, false, false, false,
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
    'a4af9da4-e3ed-475d-9635-dab4a6f1e52b', 'José Antônio', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '4a41689b-42c1-4529-a56a-3e46848599b3', 'Eliane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    'eb99f6ce-f33f-45dc-8ab6-7f31d942c661', 'Geraldo', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '41d9f15c-5199-4cb6-ae94-448bc6e5ca01', 'Adriana', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '131a6f72-7a0f-45b3-b9dd-fb2dc2feda1d', 'Uyara', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '6b8071c2-25aa-442a-89f8-4c32c9816ef0', 'Uyrlan', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '41cdaf01-c322-4ff9-a6b8-df2318f39586', 'Luíza', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    'fb039ca1-1927-4da7-8dc0-5bf6203f6aa2', 'Suzana', NULL, NULL, NULL, NULL, NULL, false, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    'c811077c-affb-4a52-aa28-d5398c994876', 'Welington', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '76284aba-a0f5-4c45-9257-8879ca9c73a1', 'Patrícia', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    'ad96755d-45ac-4615-a3a6-df490a396fa1', 'Nicole', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '82f64a7a-f0d4-459a-81bc-4e3c40d6cbf3', 'Ariane', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '38387835-2ad9-40c2-97aa-10d85c8c54ef', 'Hebert', NULL, NULL, NULL, NULL, NULL, true, 'M',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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
    '7887c9ad-746e-4a73-addf-b61240e3f4c7', 'Natália', NULL, NULL, NULL, NULL, NULL, true, 'F',
    '9756c191-c9db-4df7-9649-d6de63d8b006', true, false, false, false, false,
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

  UPDATE public.home_groups SET leader_1_id = 'a973e365-e1c3-40d2-9a29-f030018314c8', leader_2_id = NULL WHERE id = '10deaee4-7135-4dd4-b0af-fd5d28d837c7';
  UPDATE public.home_groups SET leader_1_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391', leader_2_id = 'fcc50877-28bd-4da1-ae88-0179e1e04a35' WHERE id = 'fdb8bcc3-fbf6-4544-a833-8daf949afa67';
  UPDATE public.home_groups SET leader_1_id = '47b12c72-96ac-44a1-ac2c-a3965a144111', leader_2_id = '155ede15-081f-45d5-aa2a-4d07a8475e00' WHERE id = 'e4dbb62d-5795-4498-861e-7d40e920ffb2';
  UPDATE public.home_groups SET leader_1_id = '226d4f00-0a5d-4e07-921d-141d6e6a8e61', leader_2_id = NULL WHERE id = 'e7970dea-2618-4c6f-94d8-3e3bfdd84368';
  UPDATE public.home_groups SET leader_1_id = 'f88e308a-638c-4333-a652-fabe6d3c57a4', leader_2_id = NULL WHERE id = '5800d281-3e26-4074-b0da-966b1c4caec6';
  UPDATE public.home_groups SET leader_1_id = '79195b39-bd2b-47b1-802b-5ce1f89e385b', leader_2_id = NULL WHERE id = 'a5e2c192-4f6a-4a29-95bb-50c4ad560d2b';
  UPDATE public.home_groups SET leader_1_id = 'ed3ce8d1-3736-4d8f-a990-5ffd0f08de33', leader_2_id = NULL WHERE id = '8584ae0d-c452-4e42-b16f-c04c2f541b15';
  UPDATE public.home_groups SET leader_1_id = '2608ba42-d23a-44dc-9526-fcd983bf71d4', leader_2_id = NULL WHERE id = '60df6500-4a69-480f-830d-79a024c5595f';
  UPDATE public.home_groups SET leader_1_id = '34296481-6906-4e4d-ac90-85a14d11c4fe', leader_2_id = NULL WHERE id = '96fbbcde-b4db-4722-9dc7-62c679bfe3ba';
  UPDATE public.home_groups SET leader_1_id = '990f1ea3-5b50-4fb9-a1fb-468be7f7d401', leader_2_id = NULL WHERE id = '62451771-26e2-4664-a887-ad433850de09';
  UPDATE public.home_groups SET leader_1_id = '636f0f98-e7d5-4fb8-a324-edc9aba51787', leader_2_id = '92c403a6-e91c-48e0-96b5-0004b18e39c8' WHERE id = '741ef189-124f-4e6b-82e6-50a4f97858ed';
  UPDATE public.home_groups SET leader_1_id = 'f5dcdabe-3257-44f2-89e5-efc5baa9b8c5', leader_2_id = '628b867e-dc09-453d-b90f-851c5168a3b6' WHERE id = '2a3e5611-5f22-4ab9-85c5-c94a8fac81b4';
  UPDATE public.home_groups SET leader_1_id = '12aafabd-bd35-4109-9d10-29e5f8126646', leader_2_id = NULL WHERE id = 'd1c0a07b-445a-496a-937f-5e38fb9f42c8';
  UPDATE public.home_groups SET leader_1_id = '5be0e19c-aed0-494a-bffe-47cc4ab70103', leader_2_id = NULL WHERE id = 'dd962002-7930-47e8-8969-7b6202750e62';
  UPDATE public.home_groups SET leader_1_id = '8d666902-6f90-48e3-b1c4-42d67caa4955', leader_2_id = NULL WHERE id = '1f94c716-9570-432c-b3d9-3308e39e0558';
  UPDATE public.home_groups SET leader_1_id = '00295091-c15a-434a-bbd8-16d1e0390e11', leader_2_id = '31da6e86-d480-4748-8d1f-880399e5cee5' WHERE id = '41d254d7-0f14-4b93-85f1-79930d9a4c56';
  UPDATE public.home_groups SET leader_1_id = '3861d28d-3a5f-4d9d-8b8a-afef49d483f1', leader_2_id = 'fab1cdcf-9067-46a0-b675-fba7180871f6' WHERE id = '31154092-877c-4416-b90d-64a75a6b3ab5';
  UPDATE public.home_groups SET leader_1_id = '1ee25687-14fb-4824-bef4-85e652fe5e2a', leader_2_id = '49bec215-8df6-4fde-b031-51c7f7f4d574' WHERE id = '1f7ec431-0044-45c6-92c2-6006677f401f';
  UPDATE public.home_groups SET leader_1_id = '1e82391f-bc35-4f33-a7b9-464cefcf9679', leader_2_id = NULL WHERE id = '661e6f3d-d13c-4a0c-bd81-d62d2b206c52';
  UPDATE public.home_groups SET leader_1_id = '93527aa0-3388-48fb-a303-aa4e2f161292', leader_2_id = NULL WHERE id = '3382db18-dc2c-47f2-8079-0ae2a677964e';
  UPDATE public.home_groups SET leader_1_id = '328888ff-ef8d-4ca8-9fa5-07beeeb0b910', leader_2_id = '29e3342d-8e00-421e-b9d5-facdfdad5411' WHERE id = 'a29ae2cd-af0c-4b2c-b02d-ea5baf36fad0';
  UPDATE public.home_groups SET leader_1_id = '8bb73338-12f6-4285-a10f-31afe4d5578c', leader_2_id = NULL WHERE id = '1b6641bf-c61d-4d4e-bba6-8a22dc64038d';
  UPDATE public.home_groups SET leader_1_id = 'bef7cb3d-e566-462f-830a-b49cfd17b7a1', leader_2_id = NULL WHERE id = '4c2e891c-a3d3-4f53-8379-901a3d9352ee';
  UPDATE public.home_groups SET leader_1_id = 'fdf1b7fc-14d9-402e-b359-91208c2cb5c6', leader_2_id = '91645f9d-70b9-4c30-bb26-6dfc8feb98fa' WHERE id = 'b232050e-af19-4672-8202-0c2c743d1902';
  UPDATE public.home_groups SET leader_1_id = '3cd8bf96-86ee-415c-9a22-1e52e6073f1b', leader_2_id = NULL WHERE id = '476fd88d-05db-4f7b-bdbb-1353c8a78f47';
  UPDATE public.home_groups SET leader_1_id = 'eae6ff2d-83c3-45d0-81ca-3149e1e70e53', leader_2_id = NULL WHERE id = 'a08f343a-cdbb-4101-9658-57252f88a03c';
  UPDATE public.home_groups SET leader_1_id = '01c8b898-6a7d-49d5-ac69-fd49d9c84cff', leader_2_id = 'b251487b-ad05-45d4-8fee-7430d15bb307' WHERE id = '4f8199ea-63af-491a-b6f1-b9a6d7356789';
  UPDATE public.home_groups SET leader_1_id = '7e2c1782-40db-432a-afe3-648e65b406dc', leader_2_id = NULL WHERE id = '312b5a0a-0531-4c3f-b0f5-d9374b936374';
  UPDATE public.home_groups SET leader_1_id = 'c392beb4-fdf3-4bc9-a08c-f759283197eb', leader_2_id = NULL WHERE id = 'a9f09fed-c299-4eb7-a1d2-92a518c98e7b';
  UPDATE public.home_groups SET leader_1_id = '6a4f4dc5-4836-46a6-b553-a57faee1faba', leader_2_id = 'a0b1113e-10d9-4462-8920-ba29b47999ba' WHERE id = '6de7cae1-f93a-4c0c-ae3a-2f7d1999c381';
  UPDATE public.home_groups SET leader_1_id = '8970cb37-167a-4f5a-bfaf-80f45ab453f8', leader_2_id = NULL WHERE id = '7aa6864c-1aa0-4bc3-86ad-e09a1f34d88b';
  UPDATE public.home_groups SET leader_1_id = '5235e5d4-5633-4304-89b1-619e8a593fb4', leader_2_id = NULL WHERE id = '76789e7d-25f4-4544-ae57-051adc1d01ec';
  UPDATE public.home_groups SET leader_1_id = '2dbbd7cb-2b1b-437f-84aa-57b1e353a362', leader_2_id = NULL WHERE id = '1c4a5f55-ff93-4bdc-98ca-3486a391cb81';
  UPDATE public.home_groups SET leader_1_id = 'ce252217-9f28-4922-b77e-f194441cb866', leader_2_id = NULL WHERE id = '5f9e3d7c-1c1d-47e3-bb9e-3c38b9313906';
  UPDATE public.home_groups SET leader_1_id = 'a4af9da4-e3ed-475d-9635-dab4a6f1e52b', leader_2_id = NULL WHERE id = '9756c191-c9db-4df7-9649-d6de63d8b006';

  -- ==========================================================================
  -- 6. ATUALIZAR CASAMENTOS (spouse_id) E FILIAÇÃO (father_id, mother_id)
  -- ==========================================================================

  UPDATE public.profiles SET spouse_id = 'e7c4ea7a-cb2e-4a03-b594-c9c76b2589dc' WHERE id = 'a973e365-e1c3-40d2-9a29-f030018314c8';
  UPDATE public.profiles SET spouse_id = 'a973e365-e1c3-40d2-9a29-f030018314c8' WHERE id = 'e7c4ea7a-cb2e-4a03-b594-c9c76b2589dc';
  UPDATE public.profiles SET spouse_id = '1b041dc5-7f90-458e-b15a-ada2e4ec9384' WHERE id = '75cfde95-1a4c-4b95-84db-2396c917a8b6';
  UPDATE public.profiles SET spouse_id = '75cfde95-1a4c-4b95-84db-2396c917a8b6' WHERE id = '1b041dc5-7f90-458e-b15a-ada2e4ec9384';
  UPDATE public.profiles SET spouse_id = '2b51e206-d402-415e-9bf5-381bdf291e57' WHERE id = '258ad5b9-065b-4b86-9ba3-1ccdbb79f2ca';
  UPDATE public.profiles SET spouse_id = '258ad5b9-065b-4b86-9ba3-1ccdbb79f2ca' WHERE id = '2b51e206-d402-415e-9bf5-381bdf291e57';
  UPDATE public.profiles SET spouse_id = '8bc69d90-48f7-40de-ae9a-cb6a20c15748' WHERE id = '4a2c6619-1eb0-4825-ab34-8c44df13383c';
  UPDATE public.profiles SET spouse_id = '4a2c6619-1eb0-4825-ab34-8c44df13383c' WHERE id = '8bc69d90-48f7-40de-ae9a-cb6a20c15748';
  UPDATE public.profiles SET spouse_id = '3d782737-2883-47a1-b101-22391372edb0' WHERE id = 'ad29df2f-ce38-4a48-8400-2229ec7440f4';
  UPDATE public.profiles SET spouse_id = 'ad29df2f-ce38-4a48-8400-2229ec7440f4' WHERE id = '3d782737-2883-47a1-b101-22391372edb0';
  UPDATE public.profiles SET spouse_id = '6d70bbc2-c227-456a-8b4d-1bf1b7eb0244' WHERE id = 'aded8621-99c7-4de3-a0ad-85e41ab6f5c5';
  UPDATE public.profiles SET spouse_id = 'aded8621-99c7-4de3-a0ad-85e41ab6f5c5' WHERE id = '6d70bbc2-c227-456a-8b4d-1bf1b7eb0244';
  UPDATE public.profiles SET spouse_id = '4dfe0c9c-5849-4e7e-8b4c-77a7c22007d4' WHERE id = 'c13dc906-6c0a-4d1c-ae3a-56ba784a4663';
  UPDATE public.profiles SET spouse_id = 'c13dc906-6c0a-4d1c-ae3a-56ba784a4663' WHERE id = '4dfe0c9c-5849-4e7e-8b4c-77a7c22007d4';
  UPDATE public.profiles SET spouse_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391';
  UPDATE public.profiles SET spouse_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391' WHERE id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977';
  UPDATE public.profiles SET spouse_id = '668c945e-ba87-41bf-a4a8-25746a11c7da' WHERE id = '2844dd9c-d919-49d5-a2cb-7479e0561205';
  UPDATE public.profiles SET spouse_id = '2844dd9c-d919-49d5-a2cb-7479e0561205' WHERE id = '668c945e-ba87-41bf-a4a8-25746a11c7da';
  UPDATE public.profiles SET spouse_id = 'f513abc3-34d0-473f-98d4-f5af4b3f6be3' WHERE id = '824ec089-985d-49db-ba37-1f6afcb9393b';
  UPDATE public.profiles SET spouse_id = '824ec089-985d-49db-ba37-1f6afcb9393b' WHERE id = 'f513abc3-34d0-473f-98d4-f5af4b3f6be3';
  UPDATE public.profiles SET spouse_id = '86b309b9-7fd4-409c-8258-3fb84886be8c' WHERE id = 'dd3c88c9-0d44-47ab-bd2f-4896a5cef601';
  UPDATE public.profiles SET spouse_id = 'dd3c88c9-0d44-47ab-bd2f-4896a5cef601' WHERE id = '86b309b9-7fd4-409c-8258-3fb84886be8c';
  UPDATE public.profiles SET spouse_id = 'e004fbe1-0a09-42f7-baa2-801c605953f2' WHERE id = '484e5d46-3941-4f2f-ae29-9c6426033847';
  UPDATE public.profiles SET spouse_id = '484e5d46-3941-4f2f-ae29-9c6426033847' WHERE id = 'e004fbe1-0a09-42f7-baa2-801c605953f2';
  UPDATE public.profiles SET spouse_id = '96f5541d-d799-4a00-8c02-4b408e8209a2' WHERE id = '5d6624e4-515a-41d5-9d89-2191b63b9527';
  UPDATE public.profiles SET spouse_id = '5d6624e4-515a-41d5-9d89-2191b63b9527' WHERE id = '96f5541d-d799-4a00-8c02-4b408e8209a2';
  UPDATE public.profiles SET spouse_id = 'a449a4d6-73c6-4a75-a8b2-57598fe6b109' WHERE id = 'fcc50877-28bd-4da1-ae88-0179e1e04a35';
  UPDATE public.profiles SET spouse_id = 'fcc50877-28bd-4da1-ae88-0179e1e04a35' WHERE id = 'a449a4d6-73c6-4a75-a8b2-57598fe6b109';
  UPDATE public.profiles SET spouse_id = 'b183c471-89c8-4b01-b8cc-dfadaadf68d0' WHERE id = '19f38b67-a685-46df-93d5-7ee9eb6c94e1';
  UPDATE public.profiles SET spouse_id = '19f38b67-a685-46df-93d5-7ee9eb6c94e1' WHERE id = 'b183c471-89c8-4b01-b8cc-dfadaadf68d0';
  UPDATE public.profiles SET spouse_id = '857df53a-b0b5-4292-90d3-db5d9ae5c950' WHERE id = '5be03c33-0bf4-45dd-89a2-24de9572845e';
  UPDATE public.profiles SET spouse_id = '5be03c33-0bf4-45dd-89a2-24de9572845e' WHERE id = '857df53a-b0b5-4292-90d3-db5d9ae5c950';
  UPDATE public.profiles SET spouse_id = '08bc0098-901c-440f-a612-90f666bcdcf8' WHERE id = '616e448f-5ef4-4ac4-b179-46ebdeb52f24';
  UPDATE public.profiles SET spouse_id = '616e448f-5ef4-4ac4-b179-46ebdeb52f24' WHERE id = '08bc0098-901c-440f-a612-90f666bcdcf8';
  UPDATE public.profiles SET spouse_id = '902853f5-3dfd-4a69-8482-45289bdd5243' WHERE id = 'a8aa0ee1-7642-42c7-b0f5-6f4e4c445ba4';
  UPDATE public.profiles SET spouse_id = 'a8aa0ee1-7642-42c7-b0f5-6f4e4c445ba4' WHERE id = '902853f5-3dfd-4a69-8482-45289bdd5243';
  UPDATE public.profiles SET spouse_id = '53be1066-9209-42ae-8ad0-f1db95a1a2f0' WHERE id = 'fd674526-58b2-4b05-8261-9c7e29dca92f';
  UPDATE public.profiles SET spouse_id = 'fd674526-58b2-4b05-8261-9c7e29dca92f' WHERE id = '53be1066-9209-42ae-8ad0-f1db95a1a2f0';
  UPDATE public.profiles SET spouse_id = 'd068d7a0-021f-4117-95dc-7fce4880abd5' WHERE id = '155ede15-081f-45d5-aa2a-4d07a8475e00';
  UPDATE public.profiles SET spouse_id = '155ede15-081f-45d5-aa2a-4d07a8475e00' WHERE id = 'd068d7a0-021f-4117-95dc-7fce4880abd5';
  UPDATE public.profiles SET spouse_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = '47b12c72-96ac-44a1-ac2c-a3965a144111';
  UPDATE public.profiles SET spouse_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6';
  UPDATE public.profiles SET spouse_id = '53d11f8b-36b2-4e7b-82df-f34027298ce1' WHERE id = '3ca73420-7208-487d-b688-cd299ab072a1';
  UPDATE public.profiles SET spouse_id = '3ca73420-7208-487d-b688-cd299ab072a1' WHERE id = '53d11f8b-36b2-4e7b-82df-f34027298ce1';
  UPDATE public.profiles SET spouse_id = 'aea774da-ae23-4237-8fca-3adfc0a743e2' WHERE id = '82f3301a-efcf-43cb-8025-d411c91ae73e';
  UPDATE public.profiles SET spouse_id = '82f3301a-efcf-43cb-8025-d411c91ae73e' WHERE id = 'aea774da-ae23-4237-8fca-3adfc0a743e2';
  UPDATE public.profiles SET spouse_id = 'b885c4f1-d874-4165-80f8-79ebf0c101bd' WHERE id = '5d0b407b-f754-4ca0-ac16-b089f6232264';
  UPDATE public.profiles SET spouse_id = '5d0b407b-f754-4ca0-ac16-b089f6232264' WHERE id = 'b885c4f1-d874-4165-80f8-79ebf0c101bd';
  UPDATE public.profiles SET spouse_id = 'e8ae9e3d-8463-4a4d-8283-b2df0337ec24' WHERE id = 'e2246a62-a822-4fe7-9b48-76a18e840230';
  UPDATE public.profiles SET spouse_id = 'e2246a62-a822-4fe7-9b48-76a18e840230' WHERE id = 'e8ae9e3d-8463-4a4d-8283-b2df0337ec24';
  UPDATE public.profiles SET spouse_id = '927bdbf2-398d-433f-8c99-60263bc9863e' WHERE id = 'e0f4fba9-a4e0-47f9-8292-000de315f586';
  UPDATE public.profiles SET spouse_id = 'e0f4fba9-a4e0-47f9-8292-000de315f586' WHERE id = '927bdbf2-398d-433f-8c99-60263bc9863e';
  UPDATE public.profiles SET spouse_id = '900b2622-411b-4268-9c11-3d3e9b433c4b' WHERE id = 'd1b17fce-5466-45a9-a929-19c6e037d8ed';
  UPDATE public.profiles SET spouse_id = 'd1b17fce-5466-45a9-a929-19c6e037d8ed' WHERE id = '900b2622-411b-4268-9c11-3d3e9b433c4b';
  UPDATE public.profiles SET spouse_id = '1412fe9f-582f-4f29-abd7-98726b189f5a' WHERE id = '226d4f00-0a5d-4e07-921d-141d6e6a8e61';
  UPDATE public.profiles SET spouse_id = '226d4f00-0a5d-4e07-921d-141d6e6a8e61' WHERE id = '1412fe9f-582f-4f29-abd7-98726b189f5a';
  UPDATE public.profiles SET spouse_id = 'efd6fe7d-3fd6-448a-adf0-e21ad3e79a1a' WHERE id = '648f3ba8-df06-4d5d-8ea7-c2a637adb855';
  UPDATE public.profiles SET spouse_id = '648f3ba8-df06-4d5d-8ea7-c2a637adb855' WHERE id = 'efd6fe7d-3fd6-448a-adf0-e21ad3e79a1a';
  UPDATE public.profiles SET spouse_id = '91f90e54-3d7e-498c-b65a-ccbc80065313' WHERE id = '7c12dfe6-42e7-4863-a930-47c330a2502b';
  UPDATE public.profiles SET spouse_id = '7c12dfe6-42e7-4863-a930-47c330a2502b' WHERE id = '91f90e54-3d7e-498c-b65a-ccbc80065313';
  UPDATE public.profiles SET spouse_id = '25665c02-7b99-4da1-85e2-ff878508f32f' WHERE id = 'f75a3f92-f18e-469f-8929-a142fd5b0ddf';
  UPDATE public.profiles SET spouse_id = 'f75a3f92-f18e-469f-8929-a142fd5b0ddf' WHERE id = '25665c02-7b99-4da1-85e2-ff878508f32f';
  UPDATE public.profiles SET spouse_id = 'ec23f305-c606-4eee-b888-23e74ec8f1d3' WHERE id = 'f1a9dbb9-5c1f-4232-8455-fbcefafcbc49';
  UPDATE public.profiles SET spouse_id = 'f1a9dbb9-5c1f-4232-8455-fbcefafcbc49' WHERE id = 'ec23f305-c606-4eee-b888-23e74ec8f1d3';
  UPDATE public.profiles SET spouse_id = 'a6dc1e28-435a-4fec-849d-d5e00f04cae2' WHERE id = 'cc179474-541d-40ee-ab8d-41cf98af10fe';
  UPDATE public.profiles SET spouse_id = 'cc179474-541d-40ee-ab8d-41cf98af10fe' WHERE id = 'a6dc1e28-435a-4fec-849d-d5e00f04cae2';
  UPDATE public.profiles SET spouse_id = '7922b84f-697a-4a08-b8fd-3ccb61b621a2' WHERE id = 'c49b9a37-08a1-4500-b80f-3123a4edd61d';
  UPDATE public.profiles SET spouse_id = 'c49b9a37-08a1-4500-b80f-3123a4edd61d' WHERE id = '7922b84f-697a-4a08-b8fd-3ccb61b621a2';
  UPDATE public.profiles SET spouse_id = '9fb2c561-db57-41d1-8ee1-1d945b9d687e' WHERE id = '761ce82c-aa54-4268-ac75-9c45afada9fc';
  UPDATE public.profiles SET spouse_id = '761ce82c-aa54-4268-ac75-9c45afada9fc' WHERE id = '9fb2c561-db57-41d1-8ee1-1d945b9d687e';
  UPDATE public.profiles SET spouse_id = '31232db3-802e-4c7a-b8bb-f5736126ad41' WHERE id = 'f88e308a-638c-4333-a652-fabe6d3c57a4';
  UPDATE public.profiles SET spouse_id = 'f88e308a-638c-4333-a652-fabe6d3c57a4' WHERE id = '31232db3-802e-4c7a-b8bb-f5736126ad41';
  UPDATE public.profiles SET spouse_id = '2494a7e4-3952-4861-a839-b92e79639bb1' WHERE id = 'cc5b7e4c-6ea0-4de7-afc3-1c1dfb401806';
  UPDATE public.profiles SET spouse_id = 'cc5b7e4c-6ea0-4de7-afc3-1c1dfb401806' WHERE id = '2494a7e4-3952-4861-a839-b92e79639bb1';
  UPDATE public.profiles SET spouse_id = 'd69860c2-6582-41ab-94ab-31d1dd0778bd' WHERE id = '3f47be24-abd2-41a4-b7da-07c8ffa17f8e';
  UPDATE public.profiles SET spouse_id = '3f47be24-abd2-41a4-b7da-07c8ffa17f8e' WHERE id = 'd69860c2-6582-41ab-94ab-31d1dd0778bd';
  UPDATE public.profiles SET spouse_id = '142d86af-5058-4094-a5d6-643409402e23' WHERE id = '739d43d2-70c5-484e-8283-d889b225b936';
  UPDATE public.profiles SET spouse_id = '739d43d2-70c5-484e-8283-d889b225b936' WHERE id = '142d86af-5058-4094-a5d6-643409402e23';
  UPDATE public.profiles SET spouse_id = '2011e37c-0837-4b2c-957c-297040fbb2d9' WHERE id = '108f03eb-ded4-4d35-a0d0-e4816b5af632';
  UPDATE public.profiles SET spouse_id = '108f03eb-ded4-4d35-a0d0-e4816b5af632' WHERE id = '2011e37c-0837-4b2c-957c-297040fbb2d9';
  UPDATE public.profiles SET spouse_id = 'ce77e3e6-47a3-4ad7-adec-9a3fe5c98cae' WHERE id = '79195b39-bd2b-47b1-802b-5ce1f89e385b';
  UPDATE public.profiles SET spouse_id = '79195b39-bd2b-47b1-802b-5ce1f89e385b' WHERE id = 'ce77e3e6-47a3-4ad7-adec-9a3fe5c98cae';
  UPDATE public.profiles SET spouse_id = '09594764-f583-486e-b90b-c65d21031630' WHERE id = '111591a0-bb98-47ab-9a5e-c56ef61d11d9';
  UPDATE public.profiles SET spouse_id = '111591a0-bb98-47ab-9a5e-c56ef61d11d9' WHERE id = '09594764-f583-486e-b90b-c65d21031630';
  UPDATE public.profiles SET spouse_id = '58e4d72e-5f5d-4226-8ed8-3954df70234c' WHERE id = 'ee428f95-4f04-47aa-83e4-6479387049a2';
  UPDATE public.profiles SET spouse_id = 'ee428f95-4f04-47aa-83e4-6479387049a2' WHERE id = '58e4d72e-5f5d-4226-8ed8-3954df70234c';
  UPDATE public.profiles SET spouse_id = '1b7f0b11-cf70-494b-b8ea-7fae857c8e71' WHERE id = 'dd9b61fd-a9cf-440e-9253-ce700421edea';
  UPDATE public.profiles SET spouse_id = 'dd9b61fd-a9cf-440e-9253-ce700421edea' WHERE id = '1b7f0b11-cf70-494b-b8ea-7fae857c8e71';
  UPDATE public.profiles SET spouse_id = 'e7677369-caf4-42b2-95bb-11e8a37fb48c' WHERE id = '1932e93f-70d8-4e94-8a88-052aba3bb257';
  UPDATE public.profiles SET spouse_id = '1932e93f-70d8-4e94-8a88-052aba3bb257' WHERE id = 'e7677369-caf4-42b2-95bb-11e8a37fb48c';
  UPDATE public.profiles SET spouse_id = 'a82b3df8-2e6c-4f8f-9a40-10ee11a462d9' WHERE id = 'ed3ce8d1-3736-4d8f-a990-5ffd0f08de33';
  UPDATE public.profiles SET spouse_id = 'ed3ce8d1-3736-4d8f-a990-5ffd0f08de33' WHERE id = 'a82b3df8-2e6c-4f8f-9a40-10ee11a462d9';
  UPDATE public.profiles SET spouse_id = '684bcfec-178b-46f2-8594-8185dfa0823b' WHERE id = '49967758-5c98-42cd-9bb5-9f2e1b871281';
  UPDATE public.profiles SET spouse_id = '49967758-5c98-42cd-9bb5-9f2e1b871281' WHERE id = '684bcfec-178b-46f2-8594-8185dfa0823b';
  UPDATE public.profiles SET spouse_id = 'b017cdce-7fef-40e1-90ca-656fa92108fc' WHERE id = '3a3067ba-b6fe-470c-a44b-0028f2840baa';
  UPDATE public.profiles SET spouse_id = '3a3067ba-b6fe-470c-a44b-0028f2840baa' WHERE id = 'b017cdce-7fef-40e1-90ca-656fa92108fc';
  UPDATE public.profiles SET spouse_id = 'af1d3dd9-52ee-4846-a93a-018e873974d6' WHERE id = '240beee7-bd39-4260-88eb-a4ad650f4e46';
  UPDATE public.profiles SET spouse_id = '240beee7-bd39-4260-88eb-a4ad650f4e46' WHERE id = 'af1d3dd9-52ee-4846-a93a-018e873974d6';
  UPDATE public.profiles SET spouse_id = '334357c7-ac87-4ff2-b689-3ac8230c3653' WHERE id = '3a0b50ed-ddb3-4863-bc84-2ede399304da';
  UPDATE public.profiles SET spouse_id = '3a0b50ed-ddb3-4863-bc84-2ede399304da' WHERE id = '334357c7-ac87-4ff2-b689-3ac8230c3653';
  UPDATE public.profiles SET spouse_id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7' WHERE id = '2608ba42-d23a-44dc-9526-fcd983bf71d4';
  UPDATE public.profiles SET spouse_id = '2608ba42-d23a-44dc-9526-fcd983bf71d4' WHERE id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7';
  UPDATE public.profiles SET spouse_id = 'a896926e-5e19-4357-8fd4-5250b019a8be' WHERE id = 'afeb57ba-f488-48f9-a6b3-7f86fa7ebdd4';
  UPDATE public.profiles SET spouse_id = 'afeb57ba-f488-48f9-a6b3-7f86fa7ebdd4' WHERE id = 'a896926e-5e19-4357-8fd4-5250b019a8be';
  UPDATE public.profiles SET spouse_id = 'd2343609-d932-4aae-8765-cf1dbcda9934' WHERE id = 'dedb7842-857c-4db0-987e-63e82f28f5e0';
  UPDATE public.profiles SET spouse_id = 'dedb7842-857c-4db0-987e-63e82f28f5e0' WHERE id = 'd2343609-d932-4aae-8765-cf1dbcda9934';
  UPDATE public.profiles SET spouse_id = '2f63077b-4802-4958-8713-3752be15f903' WHERE id = 'a4a6c2ea-0e93-4212-9b9e-6ab0b558585b';
  UPDATE public.profiles SET spouse_id = 'a4a6c2ea-0e93-4212-9b9e-6ab0b558585b' WHERE id = '2f63077b-4802-4958-8713-3752be15f903';
  UPDATE public.profiles SET spouse_id = '04a5cb31-a7e0-4dfb-93da-0eca0986945d' WHERE id = '8f452f97-ef47-4eb3-8668-f262fcc80ad5';
  UPDATE public.profiles SET spouse_id = '8f452f97-ef47-4eb3-8668-f262fcc80ad5' WHERE id = '04a5cb31-a7e0-4dfb-93da-0eca0986945d';
  UPDATE public.profiles SET spouse_id = '7ef4d644-acf9-4338-9ea7-11e3ebc528f6' WHERE id = 'dcebfc03-6e61-47ba-a3de-da8136972ab8';
  UPDATE public.profiles SET spouse_id = 'dcebfc03-6e61-47ba-a3de-da8136972ab8' WHERE id = '7ef4d644-acf9-4338-9ea7-11e3ebc528f6';
  UPDATE public.profiles SET spouse_id = 'ac9d6881-551e-4abc-a986-1eabeb1758c8' WHERE id = '9b978c76-0bf3-4b11-8de0-8a157a1f7ab8';
  UPDATE public.profiles SET spouse_id = '9b978c76-0bf3-4b11-8de0-8a157a1f7ab8' WHERE id = 'ac9d6881-551e-4abc-a986-1eabeb1758c8';
  UPDATE public.profiles SET spouse_id = 'c6778a0b-c19b-44c3-aeda-634a715b64d1' WHERE id = '0e3034af-bc94-4a2c-99bd-bb65a322881d';
  UPDATE public.profiles SET spouse_id = '0e3034af-bc94-4a2c-99bd-bb65a322881d' WHERE id = 'c6778a0b-c19b-44c3-aeda-634a715b64d1';
  UPDATE public.profiles SET spouse_id = 'd9f57c30-8b9b-429f-a337-78d9403784f4' WHERE id = 'c0f4a9b7-9e79-4374-8a74-7abb0562d4a6';
  UPDATE public.profiles SET spouse_id = 'c0f4a9b7-9e79-4374-8a74-7abb0562d4a6' WHERE id = 'd9f57c30-8b9b-429f-a337-78d9403784f4';
  UPDATE public.profiles SET spouse_id = '966025e8-dd0a-4c08-8848-97c0b5c17ae2' WHERE id = '34296481-6906-4e4d-ac90-85a14d11c4fe';
  UPDATE public.profiles SET spouse_id = '34296481-6906-4e4d-ac90-85a14d11c4fe' WHERE id = '966025e8-dd0a-4c08-8848-97c0b5c17ae2';
  UPDATE public.profiles SET spouse_id = 'ccdb1acf-f78a-4a09-89f1-73d3e451f4d0' WHERE id = 'e4f802fa-d427-4c44-8cdb-9e02168b9f81';
  UPDATE public.profiles SET spouse_id = 'e4f802fa-d427-4c44-8cdb-9e02168b9f81' WHERE id = 'ccdb1acf-f78a-4a09-89f1-73d3e451f4d0';
  UPDATE public.profiles SET spouse_id = '032c0ffb-af55-4fea-82f1-d4a4fca9100f' WHERE id = '4185d295-a4a6-4835-a44c-e9bf08df2168';
  UPDATE public.profiles SET spouse_id = '4185d295-a4a6-4835-a44c-e9bf08df2168' WHERE id = '032c0ffb-af55-4fea-82f1-d4a4fca9100f';
  UPDATE public.profiles SET spouse_id = '0c2480de-42b0-4e3f-b64c-eef93e0e180a' WHERE id = '31c93768-8752-451b-a256-020d6a1a1852';
  UPDATE public.profiles SET spouse_id = '31c93768-8752-451b-a256-020d6a1a1852' WHERE id = '0c2480de-42b0-4e3f-b64c-eef93e0e180a';
  UPDATE public.profiles SET spouse_id = 'b78d9a4e-bfc9-49c5-baa1-ae4343c0be6a' WHERE id = 'cbc61792-e9a2-44e1-a42d-224091a741be';
  UPDATE public.profiles SET spouse_id = 'cbc61792-e9a2-44e1-a42d-224091a741be' WHERE id = 'b78d9a4e-bfc9-49c5-baa1-ae4343c0be6a';
  UPDATE public.profiles SET spouse_id = 'ee3b39fb-0c8f-4d4c-9ae8-2d190770de0c' WHERE id = '2745f373-03cc-4f80-8746-445e9d2165e0';
  UPDATE public.profiles SET spouse_id = '2745f373-03cc-4f80-8746-445e9d2165e0' WHERE id = 'ee3b39fb-0c8f-4d4c-9ae8-2d190770de0c';
  UPDATE public.profiles SET spouse_id = '49840429-448b-4c1b-b771-f35fa64908e4' WHERE id = '990f1ea3-5b50-4fb9-a1fb-468be7f7d401';
  UPDATE public.profiles SET spouse_id = '990f1ea3-5b50-4fb9-a1fb-468be7f7d401' WHERE id = '49840429-448b-4c1b-b771-f35fa64908e4';
  UPDATE public.profiles SET spouse_id = '3228f88a-57ae-4e20-8fd3-f9f4c4484c1e' WHERE id = '5fa25dca-a17d-499f-862e-762e9a98ab47';
  UPDATE public.profiles SET spouse_id = '5fa25dca-a17d-499f-862e-762e9a98ab47' WHERE id = '3228f88a-57ae-4e20-8fd3-f9f4c4484c1e';
  UPDATE public.profiles SET spouse_id = '07fb0524-4445-4c32-8fe7-2756277c0ded' WHERE id = '349e8422-7439-4fad-9b96-d85693463cde';
  UPDATE public.profiles SET spouse_id = '349e8422-7439-4fad-9b96-d85693463cde' WHERE id = '07fb0524-4445-4c32-8fe7-2756277c0ded';
  UPDATE public.profiles SET spouse_id = 'b24d02cb-a015-4eec-b033-6cf5cf966efc' WHERE id = 'ab91841f-86d6-4743-8970-a5a4261a99a8';
  UPDATE public.profiles SET spouse_id = 'ab91841f-86d6-4743-8970-a5a4261a99a8' WHERE id = 'b24d02cb-a015-4eec-b033-6cf5cf966efc';
  UPDATE public.profiles SET spouse_id = '54abd5f9-7f2f-4e98-8e52-b75e8d25cc28' WHERE id = '9ec1fbfd-c5e2-4ed5-8d89-55d795090662';
  UPDATE public.profiles SET spouse_id = '9ec1fbfd-c5e2-4ed5-8d89-55d795090662' WHERE id = '54abd5f9-7f2f-4e98-8e52-b75e8d25cc28';
  UPDATE public.profiles SET spouse_id = '1c7d29ae-4f1e-47f4-82ec-d04fb86ea0c4' WHERE id = 'ac032b66-3119-478c-b1f8-102db8f94ecf';
  UPDATE public.profiles SET spouse_id = 'ac032b66-3119-478c-b1f8-102db8f94ecf' WHERE id = '1c7d29ae-4f1e-47f4-82ec-d04fb86ea0c4';
  UPDATE public.profiles SET spouse_id = 'f08fe565-b8ed-4fa1-bd4a-6d98b521f983' WHERE id = '92c403a6-e91c-48e0-96b5-0004b18e39c8';
  UPDATE public.profiles SET spouse_id = '92c403a6-e91c-48e0-96b5-0004b18e39c8' WHERE id = 'f08fe565-b8ed-4fa1-bd4a-6d98b521f983';
  UPDATE public.profiles SET spouse_id = '53158ea5-612e-417d-94e0-4743b0ce4655' WHERE id = '636f0f98-e7d5-4fb8-a324-edc9aba51787';
  UPDATE public.profiles SET spouse_id = '636f0f98-e7d5-4fb8-a324-edc9aba51787' WHERE id = '53158ea5-612e-417d-94e0-4743b0ce4655';
  UPDATE public.profiles SET spouse_id = '8f1722be-a5e0-4342-ac4f-72c081575e13' WHERE id = '224e9a4c-047c-46d3-9030-993039dbadaa';
  UPDATE public.profiles SET spouse_id = '224e9a4c-047c-46d3-9030-993039dbadaa' WHERE id = '8f1722be-a5e0-4342-ac4f-72c081575e13';
  UPDATE public.profiles SET spouse_id = 'ec502851-ffc2-4242-af79-539977507905' WHERE id = '91bdc470-6cbf-4e68-845d-a191886ad3d3';
  UPDATE public.profiles SET spouse_id = '91bdc470-6cbf-4e68-845d-a191886ad3d3' WHERE id = 'ec502851-ffc2-4242-af79-539977507905';
  UPDATE public.profiles SET spouse_id = '6955274a-bafd-4d77-9e7f-abe74c2def68' WHERE id = '1111540b-5192-42e6-a6c0-9a24c0a6bcd0';
  UPDATE public.profiles SET spouse_id = '1111540b-5192-42e6-a6c0-9a24c0a6bcd0' WHERE id = '6955274a-bafd-4d77-9e7f-abe74c2def68';
  UPDATE public.profiles SET spouse_id = '8769e06a-d6b1-4560-ae86-0c0b16129822' WHERE id = '509992ac-ac5f-45e9-b228-5da31ef15e03';
  UPDATE public.profiles SET spouse_id = '509992ac-ac5f-45e9-b228-5da31ef15e03' WHERE id = '8769e06a-d6b1-4560-ae86-0c0b16129822';
  UPDATE public.profiles SET spouse_id = '8871d876-ddf8-461a-bddb-af4a14962967' WHERE id = 'd1203429-b964-4c92-8c80-9ab3c1711499';
  UPDATE public.profiles SET spouse_id = 'd1203429-b964-4c92-8c80-9ab3c1711499' WHERE id = '8871d876-ddf8-461a-bddb-af4a14962967';
  UPDATE public.profiles SET spouse_id = '2efdfc69-ccfa-4b05-ab5e-aab60ce947c0' WHERE id = '7f86ec93-2f8e-4881-a66a-be6f3251eb0c';
  UPDATE public.profiles SET spouse_id = '7f86ec93-2f8e-4881-a66a-be6f3251eb0c' WHERE id = '2efdfc69-ccfa-4b05-ab5e-aab60ce947c0';
  UPDATE public.profiles SET spouse_id = 'f1670eef-34d9-4ea3-90a1-838e7c7808f0' WHERE id = '2e7a357c-38f8-455f-9aaf-32d46c46eb63';
  UPDATE public.profiles SET spouse_id = '2e7a357c-38f8-455f-9aaf-32d46c46eb63' WHERE id = 'f1670eef-34d9-4ea3-90a1-838e7c7808f0';
  UPDATE public.profiles SET spouse_id = '48fdf0df-594e-4128-8512-fc213677a517' WHERE id = 'f5dcdabe-3257-44f2-89e5-efc5baa9b8c5';
  UPDATE public.profiles SET spouse_id = 'f5dcdabe-3257-44f2-89e5-efc5baa9b8c5' WHERE id = '48fdf0df-594e-4128-8512-fc213677a517';
  UPDATE public.profiles SET spouse_id = 'f8781f2b-f8b8-4ae7-b206-1c037207a141' WHERE id = '628b867e-dc09-453d-b90f-851c5168a3b6';
  UPDATE public.profiles SET spouse_id = '628b867e-dc09-453d-b90f-851c5168a3b6' WHERE id = 'f8781f2b-f8b8-4ae7-b206-1c037207a141';
  UPDATE public.profiles SET spouse_id = '89bd2092-73f1-48ee-a2f0-6b18bee4441f' WHERE id = 'd3e572d2-d65e-4cfb-a3b9-7be0f363909b';
  UPDATE public.profiles SET spouse_id = 'd3e572d2-d65e-4cfb-a3b9-7be0f363909b' WHERE id = '89bd2092-73f1-48ee-a2f0-6b18bee4441f';
  UPDATE public.profiles SET spouse_id = '66ef2df8-d34a-4242-ad63-e15e1d970fb8' WHERE id = 'fe54992d-fdff-489c-a738-66330c6c567c';
  UPDATE public.profiles SET spouse_id = 'fe54992d-fdff-489c-a738-66330c6c567c' WHERE id = '66ef2df8-d34a-4242-ad63-e15e1d970fb8';
  UPDATE public.profiles SET spouse_id = '8e588129-af0f-441e-be1a-2df53f2fb47b' WHERE id = '68cd5ce4-6b4d-4fcc-929a-658cd7034385';
  UPDATE public.profiles SET spouse_id = '68cd5ce4-6b4d-4fcc-929a-658cd7034385' WHERE id = '8e588129-af0f-441e-be1a-2df53f2fb47b';
  UPDATE public.profiles SET spouse_id = '4063456d-0b92-4443-8258-23e3fc53112f' WHERE id = '7673c3fd-f08b-4cda-a84e-029f1cbd0a34';
  UPDATE public.profiles SET spouse_id = '7673c3fd-f08b-4cda-a84e-029f1cbd0a34' WHERE id = '4063456d-0b92-4443-8258-23e3fc53112f';
  UPDATE public.profiles SET spouse_id = '8784e30b-219f-44c3-8dd1-9f6d991f4937' WHERE id = '12aafabd-bd35-4109-9d10-29e5f8126646';
  UPDATE public.profiles SET spouse_id = '12aafabd-bd35-4109-9d10-29e5f8126646' WHERE id = '8784e30b-219f-44c3-8dd1-9f6d991f4937';
  UPDATE public.profiles SET spouse_id = '4d0a36b7-61a5-4cb9-af84-41075b0892af' WHERE id = '258bf4e4-59d6-4990-90f9-774eacdc0915';
  UPDATE public.profiles SET spouse_id = '258bf4e4-59d6-4990-90f9-774eacdc0915' WHERE id = '4d0a36b7-61a5-4cb9-af84-41075b0892af';
  UPDATE public.profiles SET spouse_id = '585b6b37-cdc4-4291-af68-41f734050072' WHERE id = 'ccc6b7b4-0bca-493d-86f4-14e95115785c';
  UPDATE public.profiles SET spouse_id = 'ccc6b7b4-0bca-493d-86f4-14e95115785c' WHERE id = '585b6b37-cdc4-4291-af68-41f734050072';
  UPDATE public.profiles SET spouse_id = '734d213a-2614-4db5-864f-9f0bec35600e' WHERE id = 'f6be4ad4-59a9-4e00-9df6-e66c30280c27';
  UPDATE public.profiles SET spouse_id = 'f6be4ad4-59a9-4e00-9df6-e66c30280c27' WHERE id = '734d213a-2614-4db5-864f-9f0bec35600e';
  UPDATE public.profiles SET spouse_id = 'a9422e33-5760-4c77-a371-ef03ae46aeb3' WHERE id = '405a1194-8de6-4574-94be-59c7f11f4e4d';
  UPDATE public.profiles SET spouse_id = '405a1194-8de6-4574-94be-59c7f11f4e4d' WHERE id = 'a9422e33-5760-4c77-a371-ef03ae46aeb3';
  UPDATE public.profiles SET spouse_id = '74a6b813-9e9d-4821-aa25-e6c0617af855' WHERE id = '7b041cfe-2812-4a70-86af-ec0e8eb7ecbb';
  UPDATE public.profiles SET spouse_id = '7b041cfe-2812-4a70-86af-ec0e8eb7ecbb' WHERE id = '74a6b813-9e9d-4821-aa25-e6c0617af855';
  UPDATE public.profiles SET spouse_id = '34b393d4-49dd-4d8e-b2a9-fd9e33cca567' WHERE id = '575b9cc2-74af-4dcb-9dd7-dd04321921fd';
  UPDATE public.profiles SET spouse_id = '575b9cc2-74af-4dcb-9dd7-dd04321921fd' WHERE id = '34b393d4-49dd-4d8e-b2a9-fd9e33cca567';
  UPDATE public.profiles SET spouse_id = '17c4dfad-a19c-48a3-8b5c-7857717d4805' WHERE id = 'afc77f80-8261-4e97-93fb-0e986839f8be';
  UPDATE public.profiles SET spouse_id = 'afc77f80-8261-4e97-93fb-0e986839f8be' WHERE id = '17c4dfad-a19c-48a3-8b5c-7857717d4805';
  UPDATE public.profiles SET spouse_id = 'be26f95d-e753-457d-b7e3-4c070946115a' WHERE id = '5be0e19c-aed0-494a-bffe-47cc4ab70103';
  UPDATE public.profiles SET spouse_id = '5be0e19c-aed0-494a-bffe-47cc4ab70103' WHERE id = 'be26f95d-e753-457d-b7e3-4c070946115a';
  UPDATE public.profiles SET spouse_id = '4e7f4b53-2a99-4d40-ad41-c872cdf55389' WHERE id = '0cf84e5b-cb6a-4e31-a4df-bda79ced0ffa';
  UPDATE public.profiles SET spouse_id = '0cf84e5b-cb6a-4e31-a4df-bda79ced0ffa' WHERE id = '4e7f4b53-2a99-4d40-ad41-c872cdf55389';
  UPDATE public.profiles SET spouse_id = 'fc3ee5d0-7e0d-4ae1-bdfa-d9d111412eeb' WHERE id = '8d666902-6f90-48e3-b1c4-42d67caa4955';
  UPDATE public.profiles SET spouse_id = '8d666902-6f90-48e3-b1c4-42d67caa4955' WHERE id = 'fc3ee5d0-7e0d-4ae1-bdfa-d9d111412eeb';
  UPDATE public.profiles SET spouse_id = 'c2f1e02d-0ca6-400b-966a-10bc625da747' WHERE id = '35534c26-cef7-48a3-baae-0946a252d735';
  UPDATE public.profiles SET spouse_id = '35534c26-cef7-48a3-baae-0946a252d735' WHERE id = 'c2f1e02d-0ca6-400b-966a-10bc625da747';
  UPDATE public.profiles SET spouse_id = 'f1dcc02a-491c-499c-8618-1b8b299b9fe8' WHERE id = '2bfad71d-8f66-4e57-91d0-293f970f819c';
  UPDATE public.profiles SET spouse_id = '2bfad71d-8f66-4e57-91d0-293f970f819c' WHERE id = 'f1dcc02a-491c-499c-8618-1b8b299b9fe8';
  UPDATE public.profiles SET spouse_id = 'f1d0afdf-58bc-4281-b626-642112543f28' WHERE id = 'a2ca4445-5e27-47c7-a148-637414771941';
  UPDATE public.profiles SET spouse_id = 'a2ca4445-5e27-47c7-a148-637414771941' WHERE id = 'f1d0afdf-58bc-4281-b626-642112543f28';
  UPDATE public.profiles SET spouse_id = 'b032182c-cd31-4084-bb12-5b46723cbe7d' WHERE id = 'd119de4f-cc6b-497f-b93c-3da08d088dab';
  UPDATE public.profiles SET spouse_id = 'd119de4f-cc6b-497f-b93c-3da08d088dab' WHERE id = 'b032182c-cd31-4084-bb12-5b46723cbe7d';
  UPDATE public.profiles SET spouse_id = '70e12c83-5d7a-405f-988a-9ae97939a2c6' WHERE id = 'bbf008a8-3409-4b01-88c6-e7e0c9770a8c';
  UPDATE public.profiles SET spouse_id = 'bbf008a8-3409-4b01-88c6-e7e0c9770a8c' WHERE id = '70e12c83-5d7a-405f-988a-9ae97939a2c6';
  UPDATE public.profiles SET spouse_id = '9f42c79f-80f3-434b-86cf-ed7390a0b6dc' WHERE id = '00295091-c15a-434a-bbd8-16d1e0390e11';
  UPDATE public.profiles SET spouse_id = '00295091-c15a-434a-bbd8-16d1e0390e11' WHERE id = '9f42c79f-80f3-434b-86cf-ed7390a0b6dc';
  UPDATE public.profiles SET spouse_id = '4a81a97e-b4b8-437f-9265-b9923f35c1a8' WHERE id = '31da6e86-d480-4748-8d1f-880399e5cee5';
  UPDATE public.profiles SET spouse_id = '31da6e86-d480-4748-8d1f-880399e5cee5' WHERE id = '4a81a97e-b4b8-437f-9265-b9923f35c1a8';
  UPDATE public.profiles SET spouse_id = 'c1ac2e76-07a4-43d9-8d80-2bb3229a8b5a' WHERE id = '8c926ada-f173-4d58-8cba-4917dce4f3be';
  UPDATE public.profiles SET spouse_id = '8c926ada-f173-4d58-8cba-4917dce4f3be' WHERE id = 'c1ac2e76-07a4-43d9-8d80-2bb3229a8b5a';
  UPDATE public.profiles SET spouse_id = 'b4ab24b6-ee1c-477f-ad35-705d76af3813' WHERE id = '3861d28d-3a5f-4d9d-8b8a-afef49d483f1';
  UPDATE public.profiles SET spouse_id = '3861d28d-3a5f-4d9d-8b8a-afef49d483f1' WHERE id = 'b4ab24b6-ee1c-477f-ad35-705d76af3813';
  UPDATE public.profiles SET spouse_id = 'a55d4fc7-d8de-473c-b366-3ee72f47d0f5' WHERE id = 'e861f0ce-b36c-4a9e-93d7-3d56bf620f9e';
  UPDATE public.profiles SET spouse_id = 'e861f0ce-b36c-4a9e-93d7-3d56bf620f9e' WHERE id = 'a55d4fc7-d8de-473c-b366-3ee72f47d0f5';
  UPDATE public.profiles SET spouse_id = '5beeb6a8-fbcc-4f9b-aa8a-ad66404b4b11' WHERE id = '7f10aa27-9ce7-4695-a7a0-6ba31370c669';
  UPDATE public.profiles SET spouse_id = '7f10aa27-9ce7-4695-a7a0-6ba31370c669' WHERE id = '5beeb6a8-fbcc-4f9b-aa8a-ad66404b4b11';
  UPDATE public.profiles SET spouse_id = 'f22c9ccb-60cb-439c-a971-d99fd7d1e063' WHERE id = '1772deb0-a1b9-466f-acc2-8d1b1f7f9403';
  UPDATE public.profiles SET spouse_id = '1772deb0-a1b9-466f-acc2-8d1b1f7f9403' WHERE id = 'f22c9ccb-60cb-439c-a971-d99fd7d1e063';
  UPDATE public.profiles SET spouse_id = 'f91666a8-284c-4739-ba98-aef196d741d5' WHERE id = 'fab1cdcf-9067-46a0-b675-fba7180871f6';
  UPDATE public.profiles SET spouse_id = 'fab1cdcf-9067-46a0-b675-fba7180871f6' WHERE id = 'f91666a8-284c-4739-ba98-aef196d741d5';
  UPDATE public.profiles SET spouse_id = '925e2f60-3558-4234-ad8c-62a12c2afc3d' WHERE id = '0a13b01c-8208-4cda-b4a6-63568f8cd7ee';
  UPDATE public.profiles SET spouse_id = '0a13b01c-8208-4cda-b4a6-63568f8cd7ee' WHERE id = '925e2f60-3558-4234-ad8c-62a12c2afc3d';
  UPDATE public.profiles SET spouse_id = 'c63ebda7-e10a-4761-92c4-4a740718fbd9' WHERE id = '9fecb530-43e2-4a7a-ae5f-0e9bd4d778e2';
  UPDATE public.profiles SET spouse_id = '9fecb530-43e2-4a7a-ae5f-0e9bd4d778e2' WHERE id = 'c63ebda7-e10a-4761-92c4-4a740718fbd9';
  UPDATE public.profiles SET spouse_id = 'f2d496e6-e298-4dcf-9330-266f3de54ecc' WHERE id = '82ab30f9-8d40-4faf-899c-596eb229dc02';
  UPDATE public.profiles SET spouse_id = '82ab30f9-8d40-4faf-899c-596eb229dc02' WHERE id = 'f2d496e6-e298-4dcf-9330-266f3de54ecc';
  UPDATE public.profiles SET spouse_id = 'b19ee2d0-50e6-4050-ab98-de66bd0700e7' WHERE id = '1e82391f-bc35-4f33-a7b9-464cefcf9679';
  UPDATE public.profiles SET spouse_id = '1e82391f-bc35-4f33-a7b9-464cefcf9679' WHERE id = 'b19ee2d0-50e6-4050-ab98-de66bd0700e7';
  UPDATE public.profiles SET spouse_id = '08fe0f2d-9f4b-4743-8b93-f41a3b1b6729' WHERE id = 'c67e1524-c69d-406a-b04b-861f333279c8';
  UPDATE public.profiles SET spouse_id = 'c67e1524-c69d-406a-b04b-861f333279c8' WHERE id = '08fe0f2d-9f4b-4743-8b93-f41a3b1b6729';
  UPDATE public.profiles SET spouse_id = 'd2bdf3b1-073b-4348-833c-9bd383271107' WHERE id = '7d762968-aa49-4470-9b03-1e1ecc4ba5bc';
  UPDATE public.profiles SET spouse_id = '7d762968-aa49-4470-9b03-1e1ecc4ba5bc' WHERE id = 'd2bdf3b1-073b-4348-833c-9bd383271107';
  UPDATE public.profiles SET spouse_id = 'a012b0e3-a129-4102-b1b9-6ea412287d6f' WHERE id = '8e8c74f6-30ea-47e5-b0bf-d7cb3ebf388c';
  UPDATE public.profiles SET spouse_id = '8e8c74f6-30ea-47e5-b0bf-d7cb3ebf388c' WHERE id = 'a012b0e3-a129-4102-b1b9-6ea412287d6f';
  UPDATE public.profiles SET spouse_id = 'bb2354b6-b65a-498f-b323-e0870fbc06f2' WHERE id = '8b6254cd-feec-44e3-b2ec-2718351cbf6b';
  UPDATE public.profiles SET spouse_id = '8b6254cd-feec-44e3-b2ec-2718351cbf6b' WHERE id = 'bb2354b6-b65a-498f-b323-e0870fbc06f2';
  UPDATE public.profiles SET spouse_id = 'ace85718-6156-4e85-98b3-88bdc070e884' WHERE id = '61b5edca-66bd-4201-9655-52c1235bb292';
  UPDATE public.profiles SET spouse_id = '61b5edca-66bd-4201-9655-52c1235bb292' WHERE id = 'ace85718-6156-4e85-98b3-88bdc070e884';
  UPDATE public.profiles SET spouse_id = 'fa595664-7f5a-4986-bd7a-83fb09c87653' WHERE id = 'd5bc892c-6bda-40b4-9e0a-8780809d5c1a';
  UPDATE public.profiles SET spouse_id = 'd5bc892c-6bda-40b4-9e0a-8780809d5c1a' WHERE id = 'fa595664-7f5a-4986-bd7a-83fb09c87653';
  UPDATE public.profiles SET spouse_id = '6413580a-96de-43e2-8de5-4e3cb27f3405' WHERE id = 'c988f65b-1580-479b-a32a-3bdfb46b8c1e';
  UPDATE public.profiles SET spouse_id = 'c988f65b-1580-479b-a32a-3bdfb46b8c1e' WHERE id = '6413580a-96de-43e2-8de5-4e3cb27f3405';
  UPDATE public.profiles SET spouse_id = '60339e5b-6921-4659-a487-c359d353f403' WHERE id = '757c9e11-799e-45c0-8108-78f625aea053';
  UPDATE public.profiles SET spouse_id = '757c9e11-799e-45c0-8108-78f625aea053' WHERE id = '60339e5b-6921-4659-a487-c359d353f403';
  UPDATE public.profiles SET spouse_id = 'fdaed233-614b-4752-8982-a5a4afb8ac00' WHERE id = '93527aa0-3388-48fb-a303-aa4e2f161292';
  UPDATE public.profiles SET spouse_id = '93527aa0-3388-48fb-a303-aa4e2f161292' WHERE id = 'fdaed233-614b-4752-8982-a5a4afb8ac00';
  UPDATE public.profiles SET spouse_id = '4581e138-9690-44b1-9087-4afe2b31fd30' WHERE id = '17ea13af-458c-484f-a709-5147e2b66cd4';
  UPDATE public.profiles SET spouse_id = '17ea13af-458c-484f-a709-5147e2b66cd4' WHERE id = '4581e138-9690-44b1-9087-4afe2b31fd30';
  UPDATE public.profiles SET spouse_id = '8d48c577-335b-49d4-94a7-148771d9aa45' WHERE id = '115a393d-7a65-4838-8509-97b5fb4662c0';
  UPDATE public.profiles SET spouse_id = '115a393d-7a65-4838-8509-97b5fb4662c0' WHERE id = '8d48c577-335b-49d4-94a7-148771d9aa45';
  UPDATE public.profiles SET spouse_id = '6739e621-4dba-45f7-b3d1-cf18e62c764d' WHERE id = '9d0f3c3a-2302-42db-963f-84976f8c1a5c';
  UPDATE public.profiles SET spouse_id = '9d0f3c3a-2302-42db-963f-84976f8c1a5c' WHERE id = '6739e621-4dba-45f7-b3d1-cf18e62c764d';
  UPDATE public.profiles SET spouse_id = '92f27fc2-3fa4-4cb3-962a-8c7f788fc6ee' WHERE id = '37f633d6-595e-4e6c-8db1-1b20d58f28af';
  UPDATE public.profiles SET spouse_id = '37f633d6-595e-4e6c-8db1-1b20d58f28af' WHERE id = '92f27fc2-3fa4-4cb3-962a-8c7f788fc6ee';
  UPDATE public.profiles SET spouse_id = 'cbde07f3-06e9-4f8f-ac17-bac632ff2d95' WHERE id = '328888ff-ef8d-4ca8-9fa5-07beeeb0b910';
  UPDATE public.profiles SET spouse_id = '328888ff-ef8d-4ca8-9fa5-07beeeb0b910' WHERE id = 'cbde07f3-06e9-4f8f-ac17-bac632ff2d95';
  UPDATE public.profiles SET spouse_id = 'aa29b0e9-e50e-4873-8d87-c0b065ba99a1' WHERE id = '29e3342d-8e00-421e-b9d5-facdfdad5411';
  UPDATE public.profiles SET spouse_id = '29e3342d-8e00-421e-b9d5-facdfdad5411' WHERE id = 'aa29b0e9-e50e-4873-8d87-c0b065ba99a1';
  UPDATE public.profiles SET spouse_id = 'b5d9201a-afa0-46c0-869c-798223c7cc52' WHERE id = '041e8a9f-6f91-49c3-ad81-4e461f5ce44e';
  UPDATE public.profiles SET spouse_id = '041e8a9f-6f91-49c3-ad81-4e461f5ce44e' WHERE id = 'b5d9201a-afa0-46c0-869c-798223c7cc52';
  UPDATE public.profiles SET spouse_id = 'd15ed94c-8602-4d06-9af9-c992b3e1050a' WHERE id = '2b6a403e-ea40-4c27-a8bb-33437e17b52e';
  UPDATE public.profiles SET spouse_id = '2b6a403e-ea40-4c27-a8bb-33437e17b52e' WHERE id = 'd15ed94c-8602-4d06-9af9-c992b3e1050a';
  UPDATE public.profiles SET spouse_id = '04e57724-30a1-4d59-80fe-2e72c97d14f0' WHERE id = '55ec953a-64da-4d84-9ea6-58885bcb4a64';
  UPDATE public.profiles SET spouse_id = '55ec953a-64da-4d84-9ea6-58885bcb4a64' WHERE id = '04e57724-30a1-4d59-80fe-2e72c97d14f0';
  UPDATE public.profiles SET spouse_id = 'a49b79d1-9550-43c8-b5fc-463320674af2' WHERE id = '8bb73338-12f6-4285-a10f-31afe4d5578c';
  UPDATE public.profiles SET spouse_id = '8bb73338-12f6-4285-a10f-31afe4d5578c' WHERE id = 'a49b79d1-9550-43c8-b5fc-463320674af2';
  UPDATE public.profiles SET spouse_id = '28e96d3f-8fd7-4fb5-8ca4-0130d48bc3ee' WHERE id = '868e6443-25cb-41db-82dd-f55391bdf866';
  UPDATE public.profiles SET spouse_id = '868e6443-25cb-41db-82dd-f55391bdf866' WHERE id = '28e96d3f-8fd7-4fb5-8ca4-0130d48bc3ee';
  UPDATE public.profiles SET spouse_id = '634d30ef-6fa9-41b4-bb5d-5024d8eb1aec' WHERE id = '658f21d4-5e28-4e3d-a072-04b4207f8704';
  UPDATE public.profiles SET spouse_id = '658f21d4-5e28-4e3d-a072-04b4207f8704' WHERE id = '634d30ef-6fa9-41b4-bb5d-5024d8eb1aec';
  UPDATE public.profiles SET spouse_id = 'e9e44a59-1ce6-4a48-a05f-d13038fef5b1' WHERE id = 'a51a10f5-0d81-476f-9223-01f58a307b4f';
  UPDATE public.profiles SET spouse_id = 'a51a10f5-0d81-476f-9223-01f58a307b4f' WHERE id = 'e9e44a59-1ce6-4a48-a05f-d13038fef5b1';
  UPDATE public.profiles SET spouse_id = 'dea3031b-19c2-4f23-ab04-5dedf95d858a' WHERE id = 'bef7cb3d-e566-462f-830a-b49cfd17b7a1';
  UPDATE public.profiles SET spouse_id = 'bef7cb3d-e566-462f-830a-b49cfd17b7a1' WHERE id = 'dea3031b-19c2-4f23-ab04-5dedf95d858a';
  UPDATE public.profiles SET spouse_id = '2fc397b3-2a85-4b24-ab1e-a93ac1f11ec5' WHERE id = '4b7f402a-6379-4d07-bd58-72dea782b187';
  UPDATE public.profiles SET spouse_id = '4b7f402a-6379-4d07-bd58-72dea782b187' WHERE id = '2fc397b3-2a85-4b24-ab1e-a93ac1f11ec5';
  UPDATE public.profiles SET spouse_id = 'ab86b706-a042-4ca2-8807-c421a88a1d35' WHERE id = '9437e5f0-3b3b-471d-b016-596834328824';
  UPDATE public.profiles SET spouse_id = '9437e5f0-3b3b-471d-b016-596834328824' WHERE id = 'ab86b706-a042-4ca2-8807-c421a88a1d35';
  UPDATE public.profiles SET spouse_id = '42fd96d3-c60d-4897-8690-30a59cdb46fe' WHERE id = '91645f9d-70b9-4c30-bb26-6dfc8feb98fa';
  UPDATE public.profiles SET spouse_id = '91645f9d-70b9-4c30-bb26-6dfc8feb98fa' WHERE id = '42fd96d3-c60d-4897-8690-30a59cdb46fe';
  UPDATE public.profiles SET spouse_id = 'd9a61816-3b72-45fc-9b2f-6f02fa320f6d' WHERE id = 'fdf1b7fc-14d9-402e-b359-91208c2cb5c6';
  UPDATE public.profiles SET spouse_id = 'fdf1b7fc-14d9-402e-b359-91208c2cb5c6' WHERE id = 'd9a61816-3b72-45fc-9b2f-6f02fa320f6d';
  UPDATE public.profiles SET spouse_id = 'e149b5c1-3f8b-4a20-93eb-e3575c8f328c' WHERE id = '0e404566-ca63-4f64-a186-6cda2b76029e';
  UPDATE public.profiles SET spouse_id = '0e404566-ca63-4f64-a186-6cda2b76029e' WHERE id = 'e149b5c1-3f8b-4a20-93eb-e3575c8f328c';
  UPDATE public.profiles SET spouse_id = 'f682eafc-6708-497d-b994-071933ea5760' WHERE id = 'eaa86918-e788-4226-b513-a8be7154cf72';
  UPDATE public.profiles SET spouse_id = 'eaa86918-e788-4226-b513-a8be7154cf72' WHERE id = 'f682eafc-6708-497d-b994-071933ea5760';
  UPDATE public.profiles SET spouse_id = '94e383a6-2e45-404d-b1b9-5b9bc9e0247f' WHERE id = '3cd8bf96-86ee-415c-9a22-1e52e6073f1b';
  UPDATE public.profiles SET spouse_id = '3cd8bf96-86ee-415c-9a22-1e52e6073f1b' WHERE id = '94e383a6-2e45-404d-b1b9-5b9bc9e0247f';
  UPDATE public.profiles SET spouse_id = 'b5edbf1f-ac89-4fde-bf31-67fc9a4c1fe1' WHERE id = '51eb0ed6-4efe-481f-9d4f-a0d783372f68';
  UPDATE public.profiles SET spouse_id = '51eb0ed6-4efe-481f-9d4f-a0d783372f68' WHERE id = 'b5edbf1f-ac89-4fde-bf31-67fc9a4c1fe1';
  UPDATE public.profiles SET spouse_id = '0017e641-e8a1-41d7-ae5f-d70dd43ca968' WHERE id = '58cc9b8c-577a-4f5d-9b70-27d394c12b5a';
  UPDATE public.profiles SET spouse_id = '58cc9b8c-577a-4f5d-9b70-27d394c12b5a' WHERE id = '0017e641-e8a1-41d7-ae5f-d70dd43ca968';
  UPDATE public.profiles SET spouse_id = 'cb6d4b25-6eb7-4d22-97db-46ba47f53602' WHERE id = '0015145e-5457-46f8-9111-2abd0ad8e339';
  UPDATE public.profiles SET spouse_id = '0015145e-5457-46f8-9111-2abd0ad8e339' WHERE id = 'cb6d4b25-6eb7-4d22-97db-46ba47f53602';
  UPDATE public.profiles SET spouse_id = '68730bca-3b01-4f20-b762-2fb3ffec054a' WHERE id = '312fa654-647a-4b1c-9ef7-78c1703790d5';
  UPDATE public.profiles SET spouse_id = '312fa654-647a-4b1c-9ef7-78c1703790d5' WHERE id = '68730bca-3b01-4f20-b762-2fb3ffec054a';
  UPDATE public.profiles SET spouse_id = 'ee496571-41c1-4393-b619-08a6c25bb725' WHERE id = 'eb21e876-0f49-4bb4-a4db-801dc6e42b0d';
  UPDATE public.profiles SET spouse_id = 'eb21e876-0f49-4bb4-a4db-801dc6e42b0d' WHERE id = 'ee496571-41c1-4393-b619-08a6c25bb725';
  UPDATE public.profiles SET spouse_id = 'c447f2f8-ca89-47a3-a88b-9fd9c24edcfe' WHERE id = '4960506d-d84d-4ee9-aec9-8c008ef1c2b6';
  UPDATE public.profiles SET spouse_id = '4960506d-d84d-4ee9-aec9-8c008ef1c2b6' WHERE id = 'c447f2f8-ca89-47a3-a88b-9fd9c24edcfe';
  UPDATE public.profiles SET spouse_id = '2130022d-2652-4ba1-b5c6-a21c71cff5db' WHERE id = '5dc19046-ecda-4bf2-99fe-bcf490851948';
  UPDATE public.profiles SET spouse_id = '5dc19046-ecda-4bf2-99fe-bcf490851948' WHERE id = '2130022d-2652-4ba1-b5c6-a21c71cff5db';
  UPDATE public.profiles SET spouse_id = 'b5850315-518d-40f3-af24-30aba539621b' WHERE id = 'eae6ff2d-83c3-45d0-81ca-3149e1e70e53';
  UPDATE public.profiles SET spouse_id = 'eae6ff2d-83c3-45d0-81ca-3149e1e70e53' WHERE id = 'b5850315-518d-40f3-af24-30aba539621b';
  UPDATE public.profiles SET spouse_id = '391d8530-09e1-4def-bbfd-2fc72881e8f7' WHERE id = 'b251487b-ad05-45d4-8fee-7430d15bb307';
  UPDATE public.profiles SET spouse_id = 'b251487b-ad05-45d4-8fee-7430d15bb307' WHERE id = '391d8530-09e1-4def-bbfd-2fc72881e8f7';
  UPDATE public.profiles SET spouse_id = 'db3404ac-8788-4a6b-9751-e681bef1508b' WHERE id = 'f8bcba15-ce59-4477-a78b-39fc86521461';
  UPDATE public.profiles SET spouse_id = 'f8bcba15-ce59-4477-a78b-39fc86521461' WHERE id = 'db3404ac-8788-4a6b-9751-e681bef1508b';
  UPDATE public.profiles SET spouse_id = '99c73b33-41e9-4a2e-9940-85a2e78884ae' WHERE id = 'ae63ecf0-2119-4c74-a29e-cfa1b2b08edc';
  UPDATE public.profiles SET spouse_id = 'ae63ecf0-2119-4c74-a29e-cfa1b2b08edc' WHERE id = '99c73b33-41e9-4a2e-9940-85a2e78884ae';
  UPDATE public.profiles SET spouse_id = '2873ea53-833c-416e-a70e-c73f5fe9bab5' WHERE id = '01c8b898-6a7d-49d5-ac69-fd49d9c84cff';
  UPDATE public.profiles SET spouse_id = '01c8b898-6a7d-49d5-ac69-fd49d9c84cff' WHERE id = '2873ea53-833c-416e-a70e-c73f5fe9bab5';
  UPDATE public.profiles SET spouse_id = 'eab04353-d3ac-4747-bab9-f32cdb8474e8' WHERE id = '5b5c96a5-74ae-4ab4-8983-8061c9bf75b2';
  UPDATE public.profiles SET spouse_id = '5b5c96a5-74ae-4ab4-8983-8061c9bf75b2' WHERE id = 'eab04353-d3ac-4747-bab9-f32cdb8474e8';
  UPDATE public.profiles SET spouse_id = 'dbd4bc9e-38bb-42aa-80f2-2473630bf757' WHERE id = '7e2c1782-40db-432a-afe3-648e65b406dc';
  UPDATE public.profiles SET spouse_id = '7e2c1782-40db-432a-afe3-648e65b406dc' WHERE id = 'dbd4bc9e-38bb-42aa-80f2-2473630bf757';
  UPDATE public.profiles SET spouse_id = 'e3695a3e-d982-464d-8156-b81135549ffc' WHERE id = 'c13e83de-4188-48cf-808e-ba7bead2901a';
  UPDATE public.profiles SET spouse_id = 'c13e83de-4188-48cf-808e-ba7bead2901a' WHERE id = 'e3695a3e-d982-464d-8156-b81135549ffc';
  UPDATE public.profiles SET spouse_id = 'a5103498-0694-478d-8b8a-b98e7e71557a' WHERE id = '1c48d1a6-1d1d-4273-a4e1-e0b97cfe3c5c';
  UPDATE public.profiles SET spouse_id = '1c48d1a6-1d1d-4273-a4e1-e0b97cfe3c5c' WHERE id = 'a5103498-0694-478d-8b8a-b98e7e71557a';
  UPDATE public.profiles SET spouse_id = '29665ad5-87a1-40d5-8adc-2ac09c768461' WHERE id = '9add99e1-7d93-45cb-83e5-0c103d603e63';
  UPDATE public.profiles SET spouse_id = '9add99e1-7d93-45cb-83e5-0c103d603e63' WHERE id = '29665ad5-87a1-40d5-8adc-2ac09c768461';
  UPDATE public.profiles SET spouse_id = '37286d4d-11f3-4f9f-9b3a-302bcec416e1' WHERE id = '83066baa-842f-4af1-b6f7-ee2aa3d9b2a7';
  UPDATE public.profiles SET spouse_id = '83066baa-842f-4af1-b6f7-ee2aa3d9b2a7' WHERE id = '37286d4d-11f3-4f9f-9b3a-302bcec416e1';
  UPDATE public.profiles SET spouse_id = '70fca288-ae64-4695-8be6-46ab3069fe8d' WHERE id = '8d99031b-4589-455d-bb33-6ac6ffca661e';
  UPDATE public.profiles SET spouse_id = '8d99031b-4589-455d-bb33-6ac6ffca661e' WHERE id = '70fca288-ae64-4695-8be6-46ab3069fe8d';
  UPDATE public.profiles SET spouse_id = '8aa2c083-7ee2-4bc8-af16-f52e34bc7856' WHERE id = 'c392beb4-fdf3-4bc9-a08c-f759283197eb';
  UPDATE public.profiles SET spouse_id = 'c392beb4-fdf3-4bc9-a08c-f759283197eb' WHERE id = '8aa2c083-7ee2-4bc8-af16-f52e34bc7856';
  UPDATE public.profiles SET spouse_id = '2a0b5153-9d3c-489f-80cb-d1fbad468c64' WHERE id = 'ac644edb-2312-443b-b719-be15fdf463fe';
  UPDATE public.profiles SET spouse_id = 'ac644edb-2312-443b-b719-be15fdf463fe' WHERE id = '2a0b5153-9d3c-489f-80cb-d1fbad468c64';
  UPDATE public.profiles SET spouse_id = '4b3871c0-43a8-4e1b-a60d-3a7dbbe5fbba' WHERE id = '2be4dce8-29d6-495e-9c2d-2f056e9af477';
  UPDATE public.profiles SET spouse_id = '2be4dce8-29d6-495e-9c2d-2f056e9af477' WHERE id = '4b3871c0-43a8-4e1b-a60d-3a7dbbe5fbba';
  UPDATE public.profiles SET spouse_id = '9787a3e1-3e4f-4b7b-9399-1e24fbf69863' WHERE id = '6a4f4dc5-4836-46a6-b553-a57faee1faba';
  UPDATE public.profiles SET spouse_id = '6a4f4dc5-4836-46a6-b553-a57faee1faba' WHERE id = '9787a3e1-3e4f-4b7b-9399-1e24fbf69863';
  UPDATE public.profiles SET spouse_id = 'fc28c40b-7bfd-4561-8583-b7d84c0587da' WHERE id = 'a0b1113e-10d9-4462-8920-ba29b47999ba';
  UPDATE public.profiles SET spouse_id = 'a0b1113e-10d9-4462-8920-ba29b47999ba' WHERE id = 'fc28c40b-7bfd-4561-8583-b7d84c0587da';
  UPDATE public.profiles SET spouse_id = 'efc94b49-b067-4780-ae04-1b6fe2b73a61' WHERE id = 'c8ebac1e-9962-4d63-8fcd-74b653fd202c';
  UPDATE public.profiles SET spouse_id = 'c8ebac1e-9962-4d63-8fcd-74b653fd202c' WHERE id = 'efc94b49-b067-4780-ae04-1b6fe2b73a61';
  UPDATE public.profiles SET spouse_id = 'a1c64fa1-1df6-4a0c-9da4-4cc14353aeb1' WHERE id = 'c5d068d8-e4da-4b0b-b067-5237b2ea454d';
  UPDATE public.profiles SET spouse_id = 'c5d068d8-e4da-4b0b-b067-5237b2ea454d' WHERE id = 'a1c64fa1-1df6-4a0c-9da4-4cc14353aeb1';
  UPDATE public.profiles SET spouse_id = '7afd0614-d8fc-4f6f-9b60-b65dba2fd3be' WHERE id = 'bfdb4d61-01f6-49e1-ad62-3b21da705859';
  UPDATE public.profiles SET spouse_id = 'bfdb4d61-01f6-49e1-ad62-3b21da705859' WHERE id = '7afd0614-d8fc-4f6f-9b60-b65dba2fd3be';
  UPDATE public.profiles SET spouse_id = 'acba2af7-57ea-4be8-915b-652d2a49da78' WHERE id = 'd65e5659-c51e-4437-a022-67bfa5932749';
  UPDATE public.profiles SET spouse_id = 'd65e5659-c51e-4437-a022-67bfa5932749' WHERE id = 'acba2af7-57ea-4be8-915b-652d2a49da78';
  UPDATE public.profiles SET spouse_id = 'b7b34209-937c-4bd1-9a1e-471b564c869e' WHERE id = '4ed9b368-cec4-4138-88e0-54e64c0ef68d';
  UPDATE public.profiles SET spouse_id = '4ed9b368-cec4-4138-88e0-54e64c0ef68d' WHERE id = 'b7b34209-937c-4bd1-9a1e-471b564c869e';
  UPDATE public.profiles SET spouse_id = 'a84d3ab2-733f-4bc1-bca5-9d08a58a0e4e' WHERE id = '8970cb37-167a-4f5a-bfaf-80f45ab453f8';
  UPDATE public.profiles SET spouse_id = '8970cb37-167a-4f5a-bfaf-80f45ab453f8' WHERE id = 'a84d3ab2-733f-4bc1-bca5-9d08a58a0e4e';
  UPDATE public.profiles SET spouse_id = '8bef510e-f17f-4fa0-851c-c07a5a1082d5' WHERE id = '4735de7b-691e-44be-8cc0-37ff915049e7';
  UPDATE public.profiles SET spouse_id = '4735de7b-691e-44be-8cc0-37ff915049e7' WHERE id = '8bef510e-f17f-4fa0-851c-c07a5a1082d5';
  UPDATE public.profiles SET spouse_id = 'fca3a6b5-2d65-477d-81d8-543230949261' WHERE id = '6eee9caa-c1fc-465b-b719-45a86beba2e2';
  UPDATE public.profiles SET spouse_id = '6eee9caa-c1fc-465b-b719-45a86beba2e2' WHERE id = 'fca3a6b5-2d65-477d-81d8-543230949261';
  UPDATE public.profiles SET spouse_id = 'e7434ed7-3f56-4953-a23e-034fc2e0a869' WHERE id = 'ec84ddec-16d0-49be-a4d0-250b4b5e0433';
  UPDATE public.profiles SET spouse_id = 'ec84ddec-16d0-49be-a4d0-250b4b5e0433' WHERE id = 'e7434ed7-3f56-4953-a23e-034fc2e0a869';
  UPDATE public.profiles SET spouse_id = 'a4b595ec-b537-47c2-97b3-881f300cc8c9' WHERE id = 'ba12c36e-7aa5-437f-8148-6c2dc1a9beca';
  UPDATE public.profiles SET spouse_id = 'ba12c36e-7aa5-437f-8148-6c2dc1a9beca' WHERE id = 'a4b595ec-b537-47c2-97b3-881f300cc8c9';
  UPDATE public.profiles SET spouse_id = 'cc1b3197-6312-44c1-9a6a-ee502b2f740d' WHERE id = 'd6a6588f-673f-4e6f-bd78-3d33cc8b3766';
  UPDATE public.profiles SET spouse_id = 'd6a6588f-673f-4e6f-bd78-3d33cc8b3766' WHERE id = 'cc1b3197-6312-44c1-9a6a-ee502b2f740d';
  UPDATE public.profiles SET spouse_id = '93328aad-b7e3-4447-999e-e7e8506b5725' WHERE id = '77929dd0-bccb-4701-9aa0-a0babeafab1a';
  UPDATE public.profiles SET spouse_id = '77929dd0-bccb-4701-9aa0-a0babeafab1a' WHERE id = '93328aad-b7e3-4447-999e-e7e8506b5725';
  UPDATE public.profiles SET spouse_id = 'f501f4ef-04cb-4e4c-9fdf-03f3716384e7' WHERE id = '185ccd35-bb37-499c-a8d0-180d8b2b1d89';
  UPDATE public.profiles SET spouse_id = '185ccd35-bb37-499c-a8d0-180d8b2b1d89' WHERE id = 'f501f4ef-04cb-4e4c-9fdf-03f3716384e7';
  UPDATE public.profiles SET spouse_id = 'df34ee47-9c3e-46d0-bb72-209c52153ed6' WHERE id = '5235e5d4-5633-4304-89b1-619e8a593fb4';
  UPDATE public.profiles SET spouse_id = '5235e5d4-5633-4304-89b1-619e8a593fb4' WHERE id = 'df34ee47-9c3e-46d0-bb72-209c52153ed6';
  UPDATE public.profiles SET spouse_id = '0fdae6b3-4fc9-4e0a-9fc9-698eb0b35b10' WHERE id = '67c0aceb-5b50-480e-8b32-35d4ed61f7a8';
  UPDATE public.profiles SET spouse_id = '67c0aceb-5b50-480e-8b32-35d4ed61f7a8' WHERE id = '0fdae6b3-4fc9-4e0a-9fc9-698eb0b35b10';
  UPDATE public.profiles SET spouse_id = 'cefac67c-0b39-4c2e-af20-2fe0a6fecbd4' WHERE id = '9e6bab41-7b4b-46fa-b634-c24a5bb6b69f';
  UPDATE public.profiles SET spouse_id = '9e6bab41-7b4b-46fa-b634-c24a5bb6b69f' WHERE id = 'cefac67c-0b39-4c2e-af20-2fe0a6fecbd4';
  UPDATE public.profiles SET spouse_id = '1bc8bd81-6d1c-4fab-81b2-8b2fafb9e8ff' WHERE id = '2d698fb0-4152-4ff6-a6e5-5bde71d7607b';
  UPDATE public.profiles SET spouse_id = '2d698fb0-4152-4ff6-a6e5-5bde71d7607b' WHERE id = '1bc8bd81-6d1c-4fab-81b2-8b2fafb9e8ff';
  UPDATE public.profiles SET spouse_id = 'e27ee72b-fddf-42aa-b3d8-17424a74d8c2' WHERE id = 'ed709a28-a9eb-4b72-9101-1b337f389c9a';
  UPDATE public.profiles SET spouse_id = 'ed709a28-a9eb-4b72-9101-1b337f389c9a' WHERE id = 'e27ee72b-fddf-42aa-b3d8-17424a74d8c2';
  UPDATE public.profiles SET spouse_id = 'cd5152cf-676f-470b-82c3-a7ba999573ab' WHERE id = '582693f0-538b-411c-bc0f-6b1d13ee18b5';
  UPDATE public.profiles SET spouse_id = '582693f0-538b-411c-bc0f-6b1d13ee18b5' WHERE id = 'cd5152cf-676f-470b-82c3-a7ba999573ab';
  UPDATE public.profiles SET spouse_id = 'f18f93a5-61f7-4013-b29b-53748476e6ed' WHERE id = '2dbbd7cb-2b1b-437f-84aa-57b1e353a362';
  UPDATE public.profiles SET spouse_id = '2dbbd7cb-2b1b-437f-84aa-57b1e353a362' WHERE id = 'f18f93a5-61f7-4013-b29b-53748476e6ed';
  UPDATE public.profiles SET spouse_id = 'b3c4a3b1-c80f-4015-b913-e65ce743c113' WHERE id = '2d65db4f-e820-43d0-a8c3-a6fdc2d89385';
  UPDATE public.profiles SET spouse_id = '2d65db4f-e820-43d0-a8c3-a6fdc2d89385' WHERE id = 'b3c4a3b1-c80f-4015-b913-e65ce743c113';
  UPDATE public.profiles SET spouse_id = '2cdca0e5-bab9-43c0-9907-d49769e3dba1' WHERE id = '2d249150-6edb-4cfc-bca2-b51df7bfcd57';
  UPDATE public.profiles SET spouse_id = '2d249150-6edb-4cfc-bca2-b51df7bfcd57' WHERE id = '2cdca0e5-bab9-43c0-9907-d49769e3dba1';
  UPDATE public.profiles SET spouse_id = 'c8b6eebf-771b-448d-8061-dd6810f7c96c' WHERE id = '2c796d5a-b155-4e34-9f8c-bbbc03f5884d';
  UPDATE public.profiles SET spouse_id = '2c796d5a-b155-4e34-9f8c-bbbc03f5884d' WHERE id = 'c8b6eebf-771b-448d-8061-dd6810f7c96c';
  UPDATE public.profiles SET spouse_id = 'a665d852-2736-4b11-8f6b-222aca8ecc9b' WHERE id = 'd2a909d2-3d9a-40a5-b7f6-7b26590fcc19';
  UPDATE public.profiles SET spouse_id = 'd2a909d2-3d9a-40a5-b7f6-7b26590fcc19' WHERE id = 'a665d852-2736-4b11-8f6b-222aca8ecc9b';
  UPDATE public.profiles SET spouse_id = '2034e3f5-b826-44b9-a253-d2c8c26d541c' WHERE id = 'a969cab0-39d3-4778-b81d-f9c2f62ae70e';
  UPDATE public.profiles SET spouse_id = 'a969cab0-39d3-4778-b81d-f9c2f62ae70e' WHERE id = '2034e3f5-b826-44b9-a253-d2c8c26d541c';
  UPDATE public.profiles SET spouse_id = '584d026b-a444-4e34-bfa8-8586e1c4f577' WHERE id = '805a3a37-87e0-4afd-b533-77b6da543549';
  UPDATE public.profiles SET spouse_id = '805a3a37-87e0-4afd-b533-77b6da543549' WHERE id = '584d026b-a444-4e34-bfa8-8586e1c4f577';
  UPDATE public.profiles SET spouse_id = 'cfc7e8b5-6e96-456f-8225-a2c8e572adc8' WHERE id = 'ce252217-9f28-4922-b77e-f194441cb866';
  UPDATE public.profiles SET spouse_id = 'ce252217-9f28-4922-b77e-f194441cb866' WHERE id = 'cfc7e8b5-6e96-456f-8225-a2c8e572adc8';
  UPDATE public.profiles SET spouse_id = '27f2770a-f2ba-42ca-883c-d8160547126a' WHERE id = 'c3efdf1e-0d95-4740-9cb4-4cff274eeec6';
  UPDATE public.profiles SET spouse_id = 'c3efdf1e-0d95-4740-9cb4-4cff274eeec6' WHERE id = '27f2770a-f2ba-42ca-883c-d8160547126a';
  UPDATE public.profiles SET spouse_id = '4a41689b-42c1-4529-a56a-3e46848599b3' WHERE id = 'a4af9da4-e3ed-475d-9635-dab4a6f1e52b';
  UPDATE public.profiles SET spouse_id = 'a4af9da4-e3ed-475d-9635-dab4a6f1e52b' WHERE id = '4a41689b-42c1-4529-a56a-3e46848599b3';
  UPDATE public.profiles SET spouse_id = '41d9f15c-5199-4cb6-ae94-448bc6e5ca01' WHERE id = 'eb99f6ce-f33f-45dc-8ab6-7f31d942c661';
  UPDATE public.profiles SET spouse_id = 'eb99f6ce-f33f-45dc-8ab6-7f31d942c661' WHERE id = '41d9f15c-5199-4cb6-ae94-448bc6e5ca01';
  UPDATE public.profiles SET spouse_id = '41cdaf01-c322-4ff9-a6b8-df2318f39586' WHERE id = '6b8071c2-25aa-442a-89f8-4c32c9816ef0';
  UPDATE public.profiles SET spouse_id = '6b8071c2-25aa-442a-89f8-4c32c9816ef0' WHERE id = '41cdaf01-c322-4ff9-a6b8-df2318f39586';
  UPDATE public.profiles SET spouse_id = '76284aba-a0f5-4c45-9257-8879ca9c73a1' WHERE id = 'c811077c-affb-4a52-aa28-d5398c994876';
  UPDATE public.profiles SET spouse_id = 'c811077c-affb-4a52-aa28-d5398c994876' WHERE id = '76284aba-a0f5-4c45-9257-8879ca9c73a1';
  UPDATE public.profiles SET spouse_id = '7887c9ad-746e-4a73-addf-b61240e3f4c7' WHERE id = '38387835-2ad9-40c2-97aa-10d85c8c54ef';
  UPDATE public.profiles SET spouse_id = '38387835-2ad9-40c2-97aa-10d85c8c54ef' WHERE id = '7887c9ad-746e-4a73-addf-b61240e3f4c7';
  UPDATE public.profiles SET father_id = 'ad29df2f-ce38-4a48-8400-2229ec7440f4', mother_id = '3d782737-2883-47a1-b101-22391372edb0' WHERE id = '714362ed-cc6d-4036-8b59-421502056358';
  UPDATE public.profiles SET father_id = 'c13dc906-6c0a-4d1c-ae3a-56ba784a4663', mother_id = '4dfe0c9c-5849-4e7e-8b4c-77a7c22007d4' WHERE id = '007fdd97-e54d-41ec-b76f-cc4ee2e9e17e';
  UPDATE public.profiles SET father_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391', mother_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = '14e651da-8606-4d92-91f3-91644e32cb24';
  UPDATE public.profiles SET father_id = NULL, mother_id = '59e96adb-0fd4-4ec2-81bd-1051006bb503' WHERE id = 'e4f850e5-389d-4fa1-963c-ea78b411ab85';
  UPDATE public.profiles SET father_id = NULL, mother_id = '59e96adb-0fd4-4ec2-81bd-1051006bb503' WHERE id = 'c764b165-b3fa-4433-9bb8-c4e1d1347867';
  UPDATE public.profiles SET father_id = '484e5d46-3941-4f2f-ae29-9c6426033847', mother_id = 'e004fbe1-0a09-42f7-baa2-801c605953f2' WHERE id = '54514519-b0c7-4586-b1ea-430d1a879a0f';
  UPDATE public.profiles SET father_id = '484e5d46-3941-4f2f-ae29-9c6426033847', mother_id = 'e004fbe1-0a09-42f7-baa2-801c605953f2' WHERE id = 'a6c2cacd-413a-4b2b-bac1-64920c0bfd10';
  UPDATE public.profiles SET father_id = '5d6624e4-515a-41d5-9d89-2191b63b9527', mother_id = '96f5541d-d799-4a00-8c02-4b408e8209a2' WHERE id = '72b03c28-bd64-43a0-be61-14be82dc09ce';
  UPDATE public.profiles SET father_id = '5d6624e4-515a-41d5-9d89-2191b63b9527', mother_id = '96f5541d-d799-4a00-8c02-4b408e8209a2' WHERE id = '8d89109e-465a-4c40-a1e1-13384353fe20';
  UPDATE public.profiles SET father_id = '82f3301a-efcf-43cb-8025-d411c91ae73e', mother_id = 'aea774da-ae23-4237-8fca-3adfc0a743e2' WHERE id = '337eb07d-9525-4ef0-a9d4-fd8891628b4f';
  UPDATE public.profiles SET father_id = '82f3301a-efcf-43cb-8025-d411c91ae73e', mother_id = 'aea774da-ae23-4237-8fca-3adfc0a743e2' WHERE id = '13290749-1adb-484a-8f32-3e50b3bbe5a3';
  UPDATE public.profiles SET father_id = 'e2246a62-a822-4fe7-9b48-76a18e840230', mother_id = 'e8ae9e3d-8463-4a4d-8283-b2df0337ec24' WHERE id = '99da2259-e583-4067-a948-b72318da9bc8';
  UPDATE public.profiles SET father_id = 'e2246a62-a822-4fe7-9b48-76a18e840230', mother_id = 'e8ae9e3d-8463-4a4d-8283-b2df0337ec24' WHERE id = '7b8e2210-c873-4f98-95fe-b3ee0324016f';
  UPDATE public.profiles SET father_id = 'd1b17fce-5466-45a9-a929-19c6e037d8ed', mother_id = '900b2622-411b-4268-9c11-3d3e9b433c4b' WHERE id = 'ae1bc088-a888-4eff-a416-f7d8cfe6dadd';
  UPDATE public.profiles SET father_id = 'd1b17fce-5466-45a9-a929-19c6e037d8ed', mother_id = '900b2622-411b-4268-9c11-3d3e9b433c4b' WHERE id = '7c2d6858-b82b-4822-8f8c-65331f484c23';
  UPDATE public.profiles SET father_id = 'd1b17fce-5466-45a9-a929-19c6e037d8ed', mother_id = '900b2622-411b-4268-9c11-3d3e9b433c4b' WHERE id = '86ea625d-bcf0-4cdd-a0e0-f64c20bf3c85';
  UPDATE public.profiles SET father_id = '226d4f00-0a5d-4e07-921d-141d6e6a8e61', mother_id = '1412fe9f-582f-4f29-abd7-98726b189f5a' WHERE id = '7aab270e-981b-41d8-8164-87dd15089a1c';
  UPDATE public.profiles SET father_id = '226d4f00-0a5d-4e07-921d-141d6e6a8e61', mother_id = '1412fe9f-582f-4f29-abd7-98726b189f5a' WHERE id = '71c8cd62-e468-466a-a33c-28309ed9349b';
  UPDATE public.profiles SET father_id = '226d4f00-0a5d-4e07-921d-141d6e6a8e61', mother_id = '1412fe9f-582f-4f29-abd7-98726b189f5a' WHERE id = 'f3ca22c0-f632-40a5-8e8a-e5d3a51df676';
  UPDATE public.profiles SET father_id = '648f3ba8-df06-4d5d-8ea7-c2a637adb855', mother_id = 'efd6fe7d-3fd6-448a-adf0-e21ad3e79a1a' WHERE id = 'aee813e9-5b05-49cc-bc11-e117253cd4da';
  UPDATE public.profiles SET father_id = '648f3ba8-df06-4d5d-8ea7-c2a637adb855', mother_id = 'efd6fe7d-3fd6-448a-adf0-e21ad3e79a1a' WHERE id = 'e3bc733d-65b6-47ee-b86b-a8f299d20fc0';
  UPDATE public.profiles SET father_id = '7c12dfe6-42e7-4863-a930-47c330a2502b', mother_id = '91f90e54-3d7e-498c-b65a-ccbc80065313' WHERE id = 'cc2259b7-01a3-468e-bc6c-8fb2b5f2a622';
  UPDATE public.profiles SET father_id = '7c12dfe6-42e7-4863-a930-47c330a2502b', mother_id = '91f90e54-3d7e-498c-b65a-ccbc80065313' WHERE id = '1d96bb97-6ff4-4991-941d-5e7149552f53';
  UPDATE public.profiles SET father_id = 'f75a3f92-f18e-469f-8929-a142fd5b0ddf', mother_id = '25665c02-7b99-4da1-85e2-ff878508f32f' WHERE id = 'aefb870c-834e-4d55-a546-1cbbb9626909';
  UPDATE public.profiles SET father_id = 'f75a3f92-f18e-469f-8929-a142fd5b0ddf', mother_id = '25665c02-7b99-4da1-85e2-ff878508f32f' WHERE id = '36589f61-d033-477d-8f6a-c96c5d3efeb6';
  UPDATE public.profiles SET father_id = 'f1a9dbb9-5c1f-4232-8455-fbcefafcbc49', mother_id = 'ec23f305-c606-4eee-b888-23e74ec8f1d3' WHERE id = '5f355a04-f53d-49d4-9fdd-c96e4503c3dd';
  UPDATE public.profiles SET father_id = 'cc179474-541d-40ee-ab8d-41cf98af10fe', mother_id = 'a6dc1e28-435a-4fec-849d-d5e00f04cae2' WHERE id = '4155c44e-831a-48c0-b9f4-c08518e2621b';
  UPDATE public.profiles SET father_id = 'c49b9a37-08a1-4500-b80f-3123a4edd61d', mother_id = '7922b84f-697a-4a08-b8fd-3ccb61b621a2' WHERE id = '9199fa20-17bd-4c0b-b0b9-f6ea0e2b127a';
  UPDATE public.profiles SET father_id = 'cc5b7e4c-6ea0-4de7-afc3-1c1dfb401806', mother_id = '2494a7e4-3952-4861-a839-b92e79639bb1' WHERE id = '05bc176f-06a8-4ae0-9277-b48cc120ae06';
  UPDATE public.profiles SET father_id = '739d43d2-70c5-484e-8283-d889b225b936', mother_id = '142d86af-5058-4094-a5d6-643409402e23' WHERE id = '12676f28-81b0-4e74-b696-993c094ec873';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'e3d551b9-1ed3-45c7-83f0-5f7e205d544e' WHERE id = '8956fdb9-2759-458e-ad19-07eaabc2e40e';
  UPDATE public.profiles SET father_id = '3a3067ba-b6fe-470c-a44b-0028f2840baa', mother_id = 'b017cdce-7fef-40e1-90ca-656fa92108fc' WHERE id = '2dc1f353-333f-49b5-a753-c68541ef5d1f';
  UPDATE public.profiles SET father_id = '3a3067ba-b6fe-470c-a44b-0028f2840baa', mother_id = 'b017cdce-7fef-40e1-90ca-656fa92108fc' WHERE id = 'a65d741d-9bf8-4944-9cd6-c767c7845df5';
  UPDATE public.profiles SET father_id = 'dedb7842-857c-4db0-987e-63e82f28f5e0', mother_id = 'd2343609-d932-4aae-8765-cf1dbcda9934' WHERE id = 'efc20ecc-6f5f-4a04-954f-0d78fb2561b2';
  UPDATE public.profiles SET father_id = 'a4a6c2ea-0e93-4212-9b9e-6ab0b558585b', mother_id = '2f63077b-4802-4958-8713-3752be15f903' WHERE id = '751821eb-3e86-4a94-96e4-37cdb9fe959d';
  UPDATE public.profiles SET father_id = '0e3034af-bc94-4a2c-99bd-bb65a322881d', mother_id = 'c6778a0b-c19b-44c3-aeda-634a715b64d1' WHERE id = '360c84c9-a3e2-43ea-8445-331e799038ed';
  UPDATE public.profiles SET father_id = '0e3034af-bc94-4a2c-99bd-bb65a322881d', mother_id = 'c6778a0b-c19b-44c3-aeda-634a715b64d1' WHERE id = '77d2c33a-2aea-49a2-967b-d668597a4c69';
  UPDATE public.profiles SET father_id = 'e4f802fa-d427-4c44-8cdb-9e02168b9f81', mother_id = 'ccdb1acf-f78a-4a09-89f1-73d3e451f4d0' WHERE id = '4b4ccbac-d7e3-421e-9a71-a5e8eadd66ec';
  UPDATE public.profiles SET father_id = '31c93768-8752-451b-a256-020d6a1a1852', mother_id = '0c2480de-42b0-4e3f-b64c-eef93e0e180a' WHERE id = '5d2c361b-81d8-42dc-b8d1-6e037864faa4';
  UPDATE public.profiles SET father_id = 'cbc61792-e9a2-44e1-a42d-224091a741be', mother_id = 'b78d9a4e-bfc9-49c5-baa1-ae4343c0be6a' WHERE id = '2a8f6153-331c-4802-a97c-70cdafd33edd';
  UPDATE public.profiles SET father_id = 'cbc61792-e9a2-44e1-a42d-224091a741be', mother_id = 'b78d9a4e-bfc9-49c5-baa1-ae4343c0be6a' WHERE id = 'a3567819-fa33-47f0-a524-4a341fc92543';
  UPDATE public.profiles SET father_id = '2745f373-03cc-4f80-8746-445e9d2165e0', mother_id = 'ee3b39fb-0c8f-4d4c-9ae8-2d190770de0c' WHERE id = 'a18bcbeb-4dc1-4e8a-ae94-009ca8c5d592';
  UPDATE public.profiles SET father_id = '5fa25dca-a17d-499f-862e-762e9a98ab47', mother_id = '3228f88a-57ae-4e20-8fd3-f9f4c4484c1e' WHERE id = 'c1cd96e8-5c7b-48ef-b2c3-c0f877863959';
  UPDATE public.profiles SET father_id = '5fa25dca-a17d-499f-862e-762e9a98ab47', mother_id = '3228f88a-57ae-4e20-8fd3-f9f4c4484c1e' WHERE id = 'ccd59088-0191-49f8-a45b-f0fe47f1039f';
  UPDATE public.profiles SET father_id = 'ab91841f-86d6-4743-8970-a5a4261a99a8', mother_id = 'b24d02cb-a015-4eec-b033-6cf5cf966efc' WHERE id = 'ffccf940-9cb9-48fd-9d2c-3ff705c19424';
  UPDATE public.profiles SET father_id = 'ab91841f-86d6-4743-8970-a5a4261a99a8', mother_id = 'b24d02cb-a015-4eec-b033-6cf5cf966efc' WHERE id = 'ef469136-4e11-447f-bf4a-bfa642b87cdd';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'ad25452d-4b9f-42d4-8d48-aac7ca567823' WHERE id = 'f6fa9609-1ac7-4dbf-b5ef-218a11da7148';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'ad25452d-4b9f-42d4-8d48-aac7ca567823' WHERE id = 'e4febcdc-6ad2-4d86-907f-777fe3e54fe7';
  UPDATE public.profiles SET father_id = '9ec1fbfd-c5e2-4ed5-8d89-55d795090662', mother_id = '54abd5f9-7f2f-4e98-8e52-b75e8d25cc28' WHERE id = '72053eac-faae-43a6-a0a5-46d040c9896a';
  UPDATE public.profiles SET father_id = '92c403a6-e91c-48e0-96b5-0004b18e39c8', mother_id = 'f08fe565-b8ed-4fa1-bd4a-6d98b521f983' WHERE id = '49ff983e-d7c6-449b-8f1d-c321b1725d3c';
  UPDATE public.profiles SET father_id = '636f0f98-e7d5-4fb8-a324-edc9aba51787', mother_id = '53158ea5-612e-417d-94e0-4743b0ce4655' WHERE id = '93fe0a62-ed96-4bbb-ac4f-1dcc0491f124';
  UPDATE public.profiles SET father_id = '636f0f98-e7d5-4fb8-a324-edc9aba51787', mother_id = '53158ea5-612e-417d-94e0-4743b0ce4655' WHERE id = '05264f17-5964-4a00-a5c5-b4156b5e8f18';
  UPDATE public.profiles SET father_id = '224e9a4c-047c-46d3-9030-993039dbadaa', mother_id = '8f1722be-a5e0-4342-ac4f-72c081575e13' WHERE id = '53a4f65a-a8a0-4c63-b5cc-d753164f580a';
  UPDATE public.profiles SET father_id = '1111540b-5192-42e6-a6c0-9a24c0a6bcd0', mother_id = '6955274a-bafd-4d77-9e7f-abe74c2def68' WHERE id = '36df4762-3c20-46b5-8228-c027fc4e6554';
  UPDATE public.profiles SET father_id = '1111540b-5192-42e6-a6c0-9a24c0a6bcd0', mother_id = '6955274a-bafd-4d77-9e7f-abe74c2def68' WHERE id = 'ac8b28ae-4e55-475f-8635-6bdaebaa0e96';
  UPDATE public.profiles SET father_id = '7f86ec93-2f8e-4881-a66a-be6f3251eb0c', mother_id = '2efdfc69-ccfa-4b05-ab5e-aab60ce947c0' WHERE id = '22d2b7a6-61ed-450b-a02b-555e35051935';
  UPDATE public.profiles SET father_id = '2e7a357c-38f8-455f-9aaf-32d46c46eb63', mother_id = 'f1670eef-34d9-4ea3-90a1-838e7c7808f0' WHERE id = '8a880a85-0849-4961-b4ba-b4862c40f963';
  UPDATE public.profiles SET father_id = '628b867e-dc09-453d-b90f-851c5168a3b6', mother_id = 'f8781f2b-f8b8-4ae7-b206-1c037207a141' WHERE id = 'f8c7e97e-efb6-4b45-aac7-2dee6ecbe597';
  UPDATE public.profiles SET father_id = '628b867e-dc09-453d-b90f-851c5168a3b6', mother_id = 'f8781f2b-f8b8-4ae7-b206-1c037207a141' WHERE id = '3f436c4d-bea3-4d26-9122-f993e8966f7a';
  UPDATE public.profiles SET father_id = 'fe54992d-fdff-489c-a738-66330c6c567c', mother_id = '66ef2df8-d34a-4242-ad63-e15e1d970fb8' WHERE id = '86096b47-9e2b-4dbb-a85d-ec8e06b19f07';
  UPDATE public.profiles SET father_id = 'fe54992d-fdff-489c-a738-66330c6c567c', mother_id = '66ef2df8-d34a-4242-ad63-e15e1d970fb8' WHERE id = '1f7ab833-d232-4e73-8c6b-8853ddb32c28';
  UPDATE public.profiles SET father_id = '68cd5ce4-6b4d-4fcc-929a-658cd7034385', mother_id = '8e588129-af0f-441e-be1a-2df53f2fb47b' WHERE id = '4d99852d-e6ce-4ee0-8f2f-1240f2d19649';
  UPDATE public.profiles SET father_id = '258bf4e4-59d6-4990-90f9-774eacdc0915', mother_id = '4d0a36b7-61a5-4cb9-af84-41075b0892af' WHERE id = '3592cee7-0ad7-4efa-8bd6-ac5fb0c263c9';
  UPDATE public.profiles SET father_id = '405a1194-8de6-4574-94be-59c7f11f4e4d', mother_id = 'a9422e33-5760-4c77-a371-ef03ae46aeb3' WHERE id = '9d5f9b5a-4324-4e64-9ebc-a3c348005b43';
  UPDATE public.profiles SET father_id = '405a1194-8de6-4574-94be-59c7f11f4e4d', mother_id = 'a9422e33-5760-4c77-a371-ef03ae46aeb3' WHERE id = '0fe5c509-3f0d-45be-8011-2360f3fa73d5';
  UPDATE public.profiles SET father_id = '7b041cfe-2812-4a70-86af-ec0e8eb7ecbb', mother_id = '74a6b813-9e9d-4821-aa25-e6c0617af855' WHERE id = '7fbf32b2-8d71-421c-bc10-a7b35d82f9e9';
  UPDATE public.profiles SET father_id = '575b9cc2-74af-4dcb-9dd7-dd04321921fd', mother_id = '34b393d4-49dd-4d8e-b2a9-fd9e33cca567' WHERE id = 'd0608af7-3ce2-41ef-8fb3-1aada02ca96b';
  UPDATE public.profiles SET father_id = 'afc77f80-8261-4e97-93fb-0e986839f8be', mother_id = '17c4dfad-a19c-48a3-8b5c-7857717d4805' WHERE id = 'd075c19f-d349-4f03-b5ea-841834dc7743';
  UPDATE public.profiles SET father_id = 'afc77f80-8261-4e97-93fb-0e986839f8be', mother_id = '17c4dfad-a19c-48a3-8b5c-7857717d4805' WHERE id = '2451872b-a223-44bb-93f5-0815964a8854';
  UPDATE public.profiles SET father_id = '0cf84e5b-cb6a-4e31-a4df-bda79ced0ffa', mother_id = '4e7f4b53-2a99-4d40-ad41-c872cdf55389' WHERE id = '09bf4dbd-9df6-4b23-85f8-7844f458b75a';
  UPDATE public.profiles SET father_id = '0cf84e5b-cb6a-4e31-a4df-bda79ced0ffa', mother_id = '4e7f4b53-2a99-4d40-ad41-c872cdf55389' WHERE id = 'ba1519db-bc29-46a2-b3bf-c0dd3d657c2d';
  UPDATE public.profiles SET father_id = '2bfad71d-8f66-4e57-91d0-293f970f819c', mother_id = 'f1dcc02a-491c-499c-8618-1b8b299b9fe8' WHERE id = '1349685b-8d14-4b6b-8c02-9422718f8bf3';
  UPDATE public.profiles SET father_id = '2bfad71d-8f66-4e57-91d0-293f970f819c', mother_id = 'f1dcc02a-491c-499c-8618-1b8b299b9fe8' WHERE id = '26cd32fd-e99c-42db-b040-73f21aadc9fc';
  UPDATE public.profiles SET father_id = NULL, mother_id = '87c15b96-d823-4d7b-989e-18dbe768a026' WHERE id = '68640f55-328e-48e4-84d6-69b27841c2ce';
  UPDATE public.profiles SET father_id = 'e861f0ce-b36c-4a9e-93d7-3d56bf620f9e', mother_id = 'a55d4fc7-d8de-473c-b366-3ee72f47d0f5' WHERE id = 'e45c6322-8848-4c40-8394-c337740e8cff';
  UPDATE public.profiles SET father_id = '7f10aa27-9ce7-4695-a7a0-6ba31370c669', mother_id = '5beeb6a8-fbcc-4f9b-aa8a-ad66404b4b11' WHERE id = 'a9dd3d88-19f5-4bfc-9e9d-de8d1e094fd4';
  UPDATE public.profiles SET father_id = '1772deb0-a1b9-466f-acc2-8d1b1f7f9403', mother_id = 'f22c9ccb-60cb-439c-a971-d99fd7d1e063' WHERE id = '35815f97-8750-4e9f-9579-5860e1df47b8';
  UPDATE public.profiles SET father_id = '1772deb0-a1b9-466f-acc2-8d1b1f7f9403', mother_id = 'f22c9ccb-60cb-439c-a971-d99fd7d1e063' WHERE id = 'cfef4ef8-2f46-4a77-8877-ed285891ef79';
  UPDATE public.profiles SET father_id = 'fab1cdcf-9067-46a0-b675-fba7180871f6', mother_id = 'f91666a8-284c-4739-ba98-aef196d741d5' WHERE id = 'f4df620d-8a3a-477d-a2a7-92237f18ce4b';
  UPDATE public.profiles SET father_id = '82ab30f9-8d40-4faf-899c-596eb229dc02', mother_id = 'f2d496e6-e298-4dcf-9330-266f3de54ecc' WHERE id = '8080747a-29ae-4fd4-8cba-9057f60d5275';
  UPDATE public.profiles SET father_id = '7d762968-aa49-4470-9b03-1e1ecc4ba5bc', mother_id = 'd2bdf3b1-073b-4348-833c-9bd383271107' WHERE id = 'face4ee7-5760-4346-9994-0e114e6599d2';
  UPDATE public.profiles SET father_id = '93527aa0-3388-48fb-a303-aa4e2f161292', mother_id = 'fdaed233-614b-4752-8982-a5a4afb8ac00' WHERE id = '854886f4-88d9-4062-9488-a13c3a6a67c6';
  UPDATE public.profiles SET father_id = '93527aa0-3388-48fb-a303-aa4e2f161292', mother_id = 'fdaed233-614b-4752-8982-a5a4afb8ac00' WHERE id = '54e470f0-e5c8-47aa-b64d-806a0506cb53';
  UPDATE public.profiles SET father_id = '93527aa0-3388-48fb-a303-aa4e2f161292', mother_id = 'fdaed233-614b-4752-8982-a5a4afb8ac00' WHERE id = '2ff41274-e6b7-4013-a365-46030117bd41';
  UPDATE public.profiles SET father_id = '9d0f3c3a-2302-42db-963f-84976f8c1a5c', mother_id = '6739e621-4dba-45f7-b3d1-cf18e62c764d' WHERE id = 'eb9d17eb-160f-4b08-a1e4-1f3c6a5662b0';
  UPDATE public.profiles SET father_id = '9d0f3c3a-2302-42db-963f-84976f8c1a5c', mother_id = '6739e621-4dba-45f7-b3d1-cf18e62c764d' WHERE id = '3cc23eb6-90ac-43e6-81c3-91b745953f0a';
  UPDATE public.profiles SET father_id = '9d0f3c3a-2302-42db-963f-84976f8c1a5c', mother_id = '6739e621-4dba-45f7-b3d1-cf18e62c764d' WHERE id = 'd77bd9a1-5898-46ee-9c96-9d668ba0f940';
  UPDATE public.profiles SET father_id = '29e3342d-8e00-421e-b9d5-facdfdad5411', mother_id = 'aa29b0e9-e50e-4873-8d87-c0b065ba99a1' WHERE id = '3ef2d0ef-a68e-49a1-93fd-de7ae888abed';
  UPDATE public.profiles SET father_id = '041e8a9f-6f91-49c3-ad81-4e461f5ce44e', mother_id = 'b5d9201a-afa0-46c0-869c-798223c7cc52' WHERE id = '2c051969-7326-418a-8cce-14e4e0d31576';
  UPDATE public.profiles SET father_id = '041e8a9f-6f91-49c3-ad81-4e461f5ce44e', mother_id = 'b5d9201a-afa0-46c0-869c-798223c7cc52' WHERE id = 'c95090f4-7b4d-4b5f-a5e5-10f54a641d8d';
  UPDATE public.profiles SET father_id = 'bef7cb3d-e566-462f-830a-b49cfd17b7a1', mother_id = 'dea3031b-19c2-4f23-ab04-5dedf95d858a' WHERE id = 'e8dc22f3-2977-47a3-b86c-4b35574c8ed5';
  UPDATE public.profiles SET father_id = '91645f9d-70b9-4c30-bb26-6dfc8feb98fa', mother_id = '42fd96d3-c60d-4897-8690-30a59cdb46fe' WHERE id = 'b98b319b-8a43-497e-bfe1-1f79d6bd9eee';
  UPDATE public.profiles SET father_id = '91645f9d-70b9-4c30-bb26-6dfc8feb98fa', mother_id = '42fd96d3-c60d-4897-8690-30a59cdb46fe' WHERE id = '3e2cb516-5fa5-4a18-a380-4610b13888a8';
  UPDATE public.profiles SET father_id = '0e404566-ca63-4f64-a186-6cda2b76029e', mother_id = 'e149b5c1-3f8b-4a20-93eb-e3575c8f328c' WHERE id = '432cbdd9-f741-479c-a513-d94137150362';
  UPDATE public.profiles SET father_id = '0e404566-ca63-4f64-a186-6cda2b76029e', mother_id = 'e149b5c1-3f8b-4a20-93eb-e3575c8f328c' WHERE id = '848ce622-b8bd-409c-baf4-a398b0da96b7';
  UPDATE public.profiles SET father_id = '58cc9b8c-577a-4f5d-9b70-27d394c12b5a', mother_id = '0017e641-e8a1-41d7-ae5f-d70dd43ca968' WHERE id = '8168fda4-8bfc-41bc-804b-168f7ff0c67a';
  UPDATE public.profiles SET father_id = '312fa654-647a-4b1c-9ef7-78c1703790d5', mother_id = '68730bca-3b01-4f20-b762-2fb3ffec054a' WHERE id = 'ad3bac89-6ab6-4c6e-bf5d-025731eecb10';
  UPDATE public.profiles SET father_id = '4960506d-d84d-4ee9-aec9-8c008ef1c2b6', mother_id = 'c447f2f8-ca89-47a3-a88b-9fd9c24edcfe' WHERE id = '87635b1b-10ca-4b86-a829-78bcc374b178';
  UPDATE public.profiles SET father_id = '5dc19046-ecda-4bf2-99fe-bcf490851948', mother_id = '2130022d-2652-4ba1-b5c6-a21c71cff5db' WHERE id = 'd99e258b-168f-49b7-830f-539c125226fc';
  UPDATE public.profiles SET father_id = NULL, mother_id = '3f33f8d4-e1e7-4730-b8bc-2490d8bf419a' WHERE id = '12f03b89-fe95-4c76-846a-ce0f04104024';
  UPDATE public.profiles SET father_id = NULL, mother_id = '3f33f8d4-e1e7-4730-b8bc-2490d8bf419a' WHERE id = '372a1d97-58d7-4397-adbc-6af556a87cae';
  UPDATE public.profiles SET father_id = 'eae6ff2d-83c3-45d0-81ca-3149e1e70e53', mother_id = 'b5850315-518d-40f3-af24-30aba539621b' WHERE id = 'b41a97f7-f4d2-4d52-bff9-b892b3e384d3';
  UPDATE public.profiles SET father_id = 'eae6ff2d-83c3-45d0-81ca-3149e1e70e53', mother_id = 'b5850315-518d-40f3-af24-30aba539621b' WHERE id = '3fcd870a-3c52-484d-a80f-c54719bf957d';
  UPDATE public.profiles SET father_id = 'eae6ff2d-83c3-45d0-81ca-3149e1e70e53', mother_id = 'b5850315-518d-40f3-af24-30aba539621b' WHERE id = '80a33004-f4cb-4f87-b560-bbec77b881a9';
  UPDATE public.profiles SET father_id = 'b251487b-ad05-45d4-8fee-7430d15bb307', mother_id = '391d8530-09e1-4def-bbfd-2fc72881e8f7' WHERE id = '8bff6d22-d7cf-4b9d-83ea-d881d0fb3d78';
  UPDATE public.profiles SET father_id = 'b251487b-ad05-45d4-8fee-7430d15bb307', mother_id = '391d8530-09e1-4def-bbfd-2fc72881e8f7' WHERE id = 'a803aed2-3a87-4ceb-8267-371e3cbc5742';
  UPDATE public.profiles SET father_id = 'f8bcba15-ce59-4477-a78b-39fc86521461', mother_id = 'db3404ac-8788-4a6b-9751-e681bef1508b' WHERE id = '7b68a6e6-429f-4064-b07d-bf285ccfd659';
  UPDATE public.profiles SET father_id = '01c8b898-6a7d-49d5-ac69-fd49d9c84cff', mother_id = '2873ea53-833c-416e-a70e-c73f5fe9bab5' WHERE id = 'be8f2ccb-711c-465b-9e16-f04134ed5131';
  UPDATE public.profiles SET father_id = 'c13e83de-4188-48cf-808e-ba7bead2901a', mother_id = 'e3695a3e-d982-464d-8156-b81135549ffc' WHERE id = 'e73cd1cc-cdfb-4020-8f48-43c9c408456e';
  UPDATE public.profiles SET father_id = 'c13e83de-4188-48cf-808e-ba7bead2901a', mother_id = 'e3695a3e-d982-464d-8156-b81135549ffc' WHERE id = 'a493ad68-2635-421c-9a8a-8dba31568b9f';
  UPDATE public.profiles SET father_id = 'c13e83de-4188-48cf-808e-ba7bead2901a', mother_id = 'e3695a3e-d982-464d-8156-b81135549ffc' WHERE id = '77a271f7-cf11-4abb-8b72-5cd7292ffcaf';
  UPDATE public.profiles SET father_id = '1c48d1a6-1d1d-4273-a4e1-e0b97cfe3c5c', mother_id = 'a5103498-0694-478d-8b8a-b98e7e71557a' WHERE id = '221c9a87-b4f8-4933-b1b4-e03b3b1c0b81';
  UPDATE public.profiles SET father_id = '9add99e1-7d93-45cb-83e5-0c103d603e63', mother_id = '29665ad5-87a1-40d5-8adc-2ac09c768461' WHERE id = 'd604e548-2245-4d2d-8f13-8ed5bca9ca83';
  UPDATE public.profiles SET father_id = '9add99e1-7d93-45cb-83e5-0c103d603e63', mother_id = '29665ad5-87a1-40d5-8adc-2ac09c768461' WHERE id = '74271be5-e8db-4e36-b7cf-bb33e6c25991';
  UPDATE public.profiles SET father_id = '2be4dce8-29d6-495e-9c2d-2f056e9af477', mother_id = '4b3871c0-43a8-4e1b-a60d-3a7dbbe5fbba' WHERE id = '1756d57e-4f77-442d-b4f1-bafaf109ea0d';
  UPDATE public.profiles SET father_id = NULL, mother_id = '675056a1-7f67-468e-bdc1-56000c042ad3' WHERE id = '95534aeb-bed1-453e-92ed-07dbba118ea2';
  UPDATE public.profiles SET father_id = NULL, mother_id = '675056a1-7f67-468e-bdc1-56000c042ad3' WHERE id = 'bf45baff-97d5-4648-9999-d3a34360bb9f';
  UPDATE public.profiles SET father_id = 'c8ebac1e-9962-4d63-8fcd-74b653fd202c', mother_id = 'efc94b49-b067-4780-ae04-1b6fe2b73a61' WHERE id = '77f43703-ced7-4581-b2ea-0aebff732ff3';
  UPDATE public.profiles SET father_id = 'bfdb4d61-01f6-49e1-ad62-3b21da705859', mother_id = '7afd0614-d8fc-4f6f-9b60-b65dba2fd3be' WHERE id = 'df1c5b58-87bb-494a-9f75-a9337411d3a4';
  UPDATE public.profiles SET father_id = '4ed9b368-cec4-4138-88e0-54e64c0ef68d', mother_id = 'b7b34209-937c-4bd1-9a1e-471b564c869e' WHERE id = '7dd11c76-5582-477a-abc4-e6a79fb549be';
  UPDATE public.profiles SET father_id = '4ed9b368-cec4-4138-88e0-54e64c0ef68d', mother_id = 'b7b34209-937c-4bd1-9a1e-471b564c869e' WHERE id = '82fa05f5-0881-423a-b895-860044fc56a0';
  UPDATE public.profiles SET father_id = '8970cb37-167a-4f5a-bfaf-80f45ab453f8', mother_id = 'a84d3ab2-733f-4bc1-bca5-9d08a58a0e4e' WHERE id = '8fbb94d1-3507-4f79-b298-2e63d53f0a53';
  UPDATE public.profiles SET father_id = 'ec84ddec-16d0-49be-a4d0-250b4b5e0433', mother_id = 'e7434ed7-3f56-4953-a23e-034fc2e0a869' WHERE id = '1b8a0ed7-b818-4b1b-af8c-0d37d3a245d8';
  UPDATE public.profiles SET father_id = 'ba12c36e-7aa5-437f-8148-6c2dc1a9beca', mother_id = 'a4b595ec-b537-47c2-97b3-881f300cc8c9' WHERE id = '0515d36b-74cc-4484-a526-20b223b3a69f';
  UPDATE public.profiles SET father_id = 'ba12c36e-7aa5-437f-8148-6c2dc1a9beca', mother_id = 'a4b595ec-b537-47c2-97b3-881f300cc8c9' WHERE id = '77de958c-717a-4d3d-a463-646ab8db1734';
  UPDATE public.profiles SET father_id = '77929dd0-bccb-4701-9aa0-a0babeafab1a', mother_id = '93328aad-b7e3-4447-999e-e7e8506b5725' WHERE id = '7a5a4905-d5cf-416f-a274-9b35748332b5';
  UPDATE public.profiles SET father_id = '185ccd35-bb37-499c-a8d0-180d8b2b1d89', mother_id = 'f501f4ef-04cb-4e4c-9fdf-03f3716384e7' WHERE id = '41d5ff61-4e29-4ec8-b007-066add539036';
  UPDATE public.profiles SET father_id = '678ebfdb-33c5-42f3-9166-ff4909c4c230', mother_id = NULL WHERE id = '04711b8d-42fb-4a56-a952-f5e0b54a34a1';
  UPDATE public.profiles SET father_id = '678ebfdb-33c5-42f3-9166-ff4909c4c230', mother_id = NULL WHERE id = '387b0044-7d08-4ee1-8a99-b07b17161a2d';
  UPDATE public.profiles SET father_id = '5235e5d4-5633-4304-89b1-619e8a593fb4', mother_id = 'df34ee47-9c3e-46d0-bb72-209c52153ed6' WHERE id = '0494e0ba-2d26-4d34-9087-61af0c76ce72';
  UPDATE public.profiles SET father_id = '67c0aceb-5b50-480e-8b32-35d4ed61f7a8', mother_id = '0fdae6b3-4fc9-4e0a-9fc9-698eb0b35b10' WHERE id = '30ebdf02-6644-437e-b9f0-75a9f613b043';
  UPDATE public.profiles SET father_id = '9e6bab41-7b4b-46fa-b634-c24a5bb6b69f', mother_id = 'cefac67c-0b39-4c2e-af20-2fe0a6fecbd4' WHERE id = '7c433288-8826-4672-a3bd-8adbe7d1781f';
  UPDATE public.profiles SET father_id = '9e6bab41-7b4b-46fa-b634-c24a5bb6b69f', mother_id = 'cefac67c-0b39-4c2e-af20-2fe0a6fecbd4' WHERE id = '4e746430-0b72-4e24-b781-e634c54e4fb3';
  UPDATE public.profiles SET father_id = '2d698fb0-4152-4ff6-a6e5-5bde71d7607b', mother_id = '1bc8bd81-6d1c-4fab-81b2-8b2fafb9e8ff' WHERE id = '02b652d8-a3df-4685-bbc0-8f66030c7435';
  UPDATE public.profiles SET father_id = 'ed709a28-a9eb-4b72-9101-1b337f389c9a', mother_id = 'e27ee72b-fddf-42aa-b3d8-17424a74d8c2' WHERE id = 'b1e25fe8-ee14-4bfe-ac27-e05f8670a9ca';
  UPDATE public.profiles SET father_id = 'ed709a28-a9eb-4b72-9101-1b337f389c9a', mother_id = 'e27ee72b-fddf-42aa-b3d8-17424a74d8c2' WHERE id = 'dce0f2b2-0aec-4de5-a906-9bc162044ae1';
  UPDATE public.profiles SET father_id = '582693f0-538b-411c-bc0f-6b1d13ee18b5', mother_id = 'cd5152cf-676f-470b-82c3-a7ba999573ab' WHERE id = '5b9b56e0-70f7-4f89-a236-e3d855c06dea';
  UPDATE public.profiles SET father_id = '2dbbd7cb-2b1b-437f-84aa-57b1e353a362', mother_id = 'f18f93a5-61f7-4013-b29b-53748476e6ed' WHERE id = '8a1a74c6-9481-4382-97f8-76ba59b9ec1a';
  UPDATE public.profiles SET father_id = '2d65db4f-e820-43d0-a8c3-a6fdc2d89385', mother_id = 'b3c4a3b1-c80f-4015-b913-e65ce743c113' WHERE id = '35c81e66-ff07-4811-9f37-3eddb60ebb51';
  UPDATE public.profiles SET father_id = '2d65db4f-e820-43d0-a8c3-a6fdc2d89385', mother_id = 'b3c4a3b1-c80f-4015-b913-e65ce743c113' WHERE id = 'ccf50420-ffaf-4e22-9258-a3610d343bca';
  UPDATE public.profiles SET father_id = '2d249150-6edb-4cfc-bca2-b51df7bfcd57', mother_id = '2cdca0e5-bab9-43c0-9907-d49769e3dba1' WHERE id = 'e29c7835-e16a-492c-ab8a-a28ad0ad1f38';
  UPDATE public.profiles SET father_id = '2d249150-6edb-4cfc-bca2-b51df7bfcd57', mother_id = '2cdca0e5-bab9-43c0-9907-d49769e3dba1' WHERE id = '2ab0fd30-19b5-4c33-95e2-964e21df5ba2';
  UPDATE public.profiles SET father_id = 'a969cab0-39d3-4778-b81d-f9c2f62ae70e', mother_id = '2034e3f5-b826-44b9-a253-d2c8c26d541c' WHERE id = 'c026d039-2d1f-4351-853e-ec80a7b4c4ad';
  UPDATE public.profiles SET father_id = 'a969cab0-39d3-4778-b81d-f9c2f62ae70e', mother_id = '2034e3f5-b826-44b9-a253-d2c8c26d541c' WHERE id = 'fe3729c9-8fbc-478d-b7ed-07ca598a9e7c';
  UPDATE public.profiles SET father_id = 'a969cab0-39d3-4778-b81d-f9c2f62ae70e', mother_id = '2034e3f5-b826-44b9-a253-d2c8c26d541c' WHERE id = '54d0e3e0-6eb1-4562-95e0-7d5f1cf72f6d';
  UPDATE public.profiles SET father_id = 'a969cab0-39d3-4778-b81d-f9c2f62ae70e', mother_id = '2034e3f5-b826-44b9-a253-d2c8c26d541c' WHERE id = 'aa311714-a38d-43f6-b812-568ef8ce0473';
  UPDATE public.profiles SET father_id = '805a3a37-87e0-4afd-b533-77b6da543549', mother_id = '584d026b-a444-4e34-bfa8-8586e1c4f577' WHERE id = '89cb1e9a-43c9-4279-93e3-caf293a62ac6';
  UPDATE public.profiles SET father_id = '6b8071c2-25aa-442a-89f8-4c32c9816ef0', mother_id = '41cdaf01-c322-4ff9-a6b8-df2318f39586' WHERE id = 'fb039ca1-1927-4da7-8dc0-5bf6203f6aa2';

  -- ==========================================================================
  -- 7. ATUALIZAR DISCIPULADO (discipler_id)
  -- ==========================================================================

  UPDATE public.profiles SET discipler_id = '8ca1902f-789b-4163-b4c6-30a1bd9aed8b' WHERE id = 'd56c853d-f037-4bbe-ab44-9b50f00a6225';
  UPDATE public.profiles SET discipler_id = 'a973e365-e1c3-40d2-9a29-f030018314c8' WHERE id = '75cfde95-1a4c-4b95-84db-2396c917a8b6';
  UPDATE public.profiles SET discipler_id = 'e7c4ea7a-cb2e-4a03-b594-c9c76b2589dc' WHERE id = '1b041dc5-7f90-458e-b15a-ada2e4ec9384';
  UPDATE public.profiles SET discipler_id = 'a973e365-e1c3-40d2-9a29-f030018314c8' WHERE id = '258ad5b9-065b-4b86-9ba3-1ccdbb79f2ca';
  UPDATE public.profiles SET discipler_id = 'e7c4ea7a-cb2e-4a03-b594-c9c76b2589dc' WHERE id = '2b51e206-d402-415e-9bf5-381bdf291e57';
  UPDATE public.profiles SET discipler_id = 'a973e365-e1c3-40d2-9a29-f030018314c8' WHERE id = '6a1fedc1-001c-4b86-97a3-656ddc26411d';
  UPDATE public.profiles SET discipler_id = '2608ba42-d23a-44dc-9526-fcd983bf71d4' WHERE id = '4a2c6619-1eb0-4825-ab34-8c44df13383c';
  UPDATE public.profiles SET discipler_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391' WHERE id = 'aded8621-99c7-4de3-a0ad-85e41ab6f5c5';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = '6d70bbc2-c227-456a-8b4d-1bf1b7eb0244';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = '59e96adb-0fd4-4ec2-81bd-1051006bb503';
  UPDATE public.profiles SET discipler_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391' WHERE id = '824ec089-985d-49db-ba37-1f6afcb9393b';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = 'f513abc3-34d0-473f-98d4-f5af4b3f6be3';
  UPDATE public.profiles SET discipler_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391' WHERE id = 'dd3c88c9-0d44-47ab-bd2f-4896a5cef601';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = '86b309b9-7fd4-409c-8258-3fb84886be8c';
  UPDATE public.profiles SET discipler_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391' WHERE id = '484e5d46-3941-4f2f-ae29-9c6426033847';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = 'e004fbe1-0a09-42f7-baa2-801c605953f2';
  UPDATE public.profiles SET discipler_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391' WHERE id = '5d6624e4-515a-41d5-9d89-2191b63b9527';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = '96f5541d-d799-4a00-8c02-4b408e8209a2';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = 'fa83ef7d-2e73-4bf7-99e1-8f6915f2bac2';
  UPDATE public.profiles SET discipler_id = '8ca1902f-789b-4163-b4c6-30a1bd9aed8b' WHERE id = 'c8914d91-c7c5-4f92-add3-f25940a0a9c5';
  UPDATE public.profiles SET discipler_id = 'aded8621-99c7-4de3-a0ad-85e41ab6f5c5' WHERE id = 'bc44a1b9-2edb-433d-b835-217bb7076adb';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = '983e3b2c-05bc-47a2-b246-2a6ef1be4b6e';
  UPDATE public.profiles SET discipler_id = 'aded8621-99c7-4de3-a0ad-85e41ab6f5c5' WHERE id = 'fcc50877-28bd-4da1-ae88-0179e1e04a35';
  UPDATE public.profiles SET discipler_id = '3ca73420-7208-487d-b688-cd299ab072a1' WHERE id = '19f38b67-a685-46df-93d5-7ee9eb6c94e1';
  UPDATE public.profiles SET discipler_id = '53d11f8b-36b2-4e7b-82df-f34027298ce1' WHERE id = 'b183c471-89c8-4b01-b8cc-dfadaadf68d0';
  UPDATE public.profiles SET discipler_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = '5be03c33-0bf4-45dd-89a2-24de9572845e';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = '857df53a-b0b5-4292-90d3-db5d9ae5c950';
  UPDATE public.profiles SET discipler_id = 'd068d7a0-021f-4117-95dc-7fce4880abd5' WHERE id = 'fb87c251-b3df-4246-8ee6-2a0e996ed9b6';
  UPDATE public.profiles SET discipler_id = 'fcc50877-28bd-4da1-ae88-0179e1e04a35' WHERE id = '0efb0be6-ae9b-49e8-854e-d6daf8bb3fb7';
  UPDATE public.profiles SET discipler_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = '616e448f-5ef4-4ac4-b179-46ebdeb52f24';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = '08bc0098-901c-440f-a612-90f666bcdcf8';
  UPDATE public.profiles SET discipler_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = 'a8aa0ee1-7642-42c7-b0f5-6f4e4c445ba4';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = '902853f5-3dfd-4a69-8482-45289bdd5243';
  UPDATE public.profiles SET discipler_id = '2608ba42-d23a-44dc-9526-fcd983bf71d4' WHERE id = 'fd674526-58b2-4b05-8261-9c7e29dca92f';
  UPDATE public.profiles SET discipler_id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7' WHERE id = '53be1066-9209-42ae-8ad0-f1db95a1a2f0';
  UPDATE public.profiles SET discipler_id = 'fd674526-58b2-4b05-8261-9c7e29dca92f' WHERE id = '4297299b-54a6-48dd-8389-2d058af352d7';
  UPDATE public.profiles SET discipler_id = '53be1066-9209-42ae-8ad0-f1db95a1a2f0' WHERE id = '04bb9a8b-cd49-42a5-a7a1-4258f3608614';
  UPDATE public.profiles SET discipler_id = 'afeb57ba-f488-48f9-a6b3-7f86fa7ebdd4' WHERE id = '155ede15-081f-45d5-aa2a-4d07a8475e00';
  UPDATE public.profiles SET discipler_id = 'a896926e-5e19-4357-8fd4-5250b019a8be' WHERE id = 'd068d7a0-021f-4117-95dc-7fce4880abd5';
  UPDATE public.profiles SET discipler_id = 'e1a9bb33-babc-4664-99f4-dbab5f8b0391' WHERE id = '47b12c72-96ac-44a1-ac2c-a3965a144111';
  UPDATE public.profiles SET discipler_id = '1b4d6e6b-98e2-4c75-9e38-6d912e898977' WHERE id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6';
  UPDATE public.profiles SET discipler_id = '155ede15-081f-45d5-aa2a-4d07a8475e00' WHERE id = 'd1f42bed-270d-4e9d-8291-b200eeb9d033';
  UPDATE public.profiles SET discipler_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = '9bfeb3a2-b069-495c-b7b3-f58471f4d864';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = 'e8380783-25ea-490a-86b0-44c56735eac4';
  UPDATE public.profiles SET discipler_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = '3ca73420-7208-487d-b688-cd299ab072a1';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = '53d11f8b-36b2-4e7b-82df-f34027298ce1';
  UPDATE public.profiles SET discipler_id = 'd1f42bed-270d-4e9d-8291-b200eeb9d033' WHERE id = 'd725d78a-aead-4054-921c-1c7349e7fb6d';
  UPDATE public.profiles SET discipler_id = '155ede15-081f-45d5-aa2a-4d07a8475e00' WHERE id = '82f3301a-efcf-43cb-8025-d411c91ae73e';
  UPDATE public.profiles SET discipler_id = 'd068d7a0-021f-4117-95dc-7fce4880abd5' WHERE id = 'aea774da-ae23-4237-8fca-3adfc0a743e2';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = '9d3e3d9c-0087-45db-b5f0-27e1149c48b2';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = 'b885c4f1-d874-4165-80f8-79ebf0c101bd';
  UPDATE public.profiles SET discipler_id = 'd1f42bed-270d-4e9d-8291-b200eeb9d033' WHERE id = '5d0b407b-f754-4ca0-ac16-b089f6232264';
  UPDATE public.profiles SET discipler_id = '11a67fda-3694-47f1-b2f3-0c2da85280b7' WHERE id = '26321912-b208-436a-a337-0ce9bdd0d2d8';
  UPDATE public.profiles SET discipler_id = 'e7434ed7-3f56-4953-a23e-034fc2e0a869' WHERE id = '11a67fda-3694-47f1-b2f3-0c2da85280b7';
  UPDATE public.profiles SET discipler_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = 'e2246a62-a822-4fe7-9b48-76a18e840230';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = 'e8ae9e3d-8463-4a4d-8283-b2df0337ec24';
  UPDATE public.profiles SET discipler_id = '155ede15-081f-45d5-aa2a-4d07a8475e00' WHERE id = 'a1f11d2c-e62c-4da9-86bf-f05bdc46e7f8';
  UPDATE public.profiles SET discipler_id = '26321912-b208-436a-a337-0ce9bdd0d2d8' WHERE id = '60e5c06d-ed91-4f09-ad9f-73910e033e02';
  UPDATE public.profiles SET discipler_id = '53d11f8b-36b2-4e7b-82df-f34027298ce1' WHERE id = '398d9631-cdee-4014-91dc-71e7708d9265';
  UPDATE public.profiles SET discipler_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = 'e0f4fba9-a4e0-47f9-8292-000de315f586';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = '927bdbf2-398d-433f-8c99-60263bc9863e';
  UPDATE public.profiles SET discipler_id = '47b12c72-96ac-44a1-ac2c-a3965a144111' WHERE id = 'd1b17fce-5466-45a9-a929-19c6e037d8ed';
  UPDATE public.profiles SET discipler_id = '1031fb1d-55ce-4d3c-bf44-73eef15727e6' WHERE id = '900b2622-411b-4268-9c11-3d3e9b433c4b';
  UPDATE public.profiles SET discipler_id = 'a973e365-e1c3-40d2-9a29-f030018314c8' WHERE id = '2608ba42-d23a-44dc-9526-fcd983bf71d4';
  UPDATE public.profiles SET discipler_id = 'e7c4ea7a-cb2e-4a03-b594-c9c76b2589dc' WHERE id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7';
  UPDATE public.profiles SET discipler_id = 'a973e365-e1c3-40d2-9a29-f030018314c8' WHERE id = 'afeb57ba-f488-48f9-a6b3-7f86fa7ebdd4';
  UPDATE public.profiles SET discipler_id = 'e7c4ea7a-cb2e-4a03-b594-c9c76b2589dc' WHERE id = 'a896926e-5e19-4357-8fd4-5250b019a8be';
  UPDATE public.profiles SET discipler_id = 'afeb57ba-f488-48f9-a6b3-7f86fa7ebdd4' WHERE id = 'a4a6c2ea-0e93-4212-9b9e-6ab0b558585b';
  UPDATE public.profiles SET discipler_id = 'a896926e-5e19-4357-8fd4-5250b019a8be' WHERE id = '2f63077b-4802-4958-8713-3752be15f903';
  UPDATE public.profiles SET discipler_id = '2608ba42-d23a-44dc-9526-fcd983bf71d4' WHERE id = '8f452f97-ef47-4eb3-8668-f262fcc80ad5';
  UPDATE public.profiles SET discipler_id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7' WHERE id = '04a5cb31-a7e0-4dfb-93da-0eca0986945d';
  UPDATE public.profiles SET discipler_id = '2608ba42-d23a-44dc-9526-fcd983bf71d4' WHERE id = 'dcebfc03-6e61-47ba-a3de-da8136972ab8';
  UPDATE public.profiles SET discipler_id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7' WHERE id = '7ef4d644-acf9-4338-9ea7-11e3ebc528f6';
  UPDATE public.profiles SET discipler_id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7' WHERE id = 'd33ee00b-8cf9-4811-8750-c37d95657d22';
  UPDATE public.profiles SET discipler_id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7' WHERE id = 'ac9d6881-551e-4abc-a986-1eabeb1758c8';
  UPDATE public.profiles SET discipler_id = '2608ba42-d23a-44dc-9526-fcd983bf71d4' WHERE id = 'c0f4a9b7-9e79-4374-8a74-7abb0562d4a6';
  UPDATE public.profiles SET discipler_id = '9a7f7903-ecac-4dcb-b742-cbed967b32e7' WHERE id = 'd9f57c30-8b9b-429f-a337-78d9403784f4';
  UPDATE public.profiles SET discipler_id = '5be0e19c-aed0-494a-bffe-47cc4ab70103' WHERE id = '405a1194-8de6-4574-94be-59c7f11f4e4d';
  UPDATE public.profiles SET discipler_id = 'be26f95d-e753-457d-b7e3-4c070946115a' WHERE id = 'a9422e33-5760-4c77-a371-ef03ae46aeb3';
  UPDATE public.profiles SET discipler_id = 'be26f95d-e753-457d-b7e3-4c070946115a' WHERE id = '74a6b813-9e9d-4821-aa25-e6c0617af855';
  UPDATE public.profiles SET discipler_id = 'be26f95d-e753-457d-b7e3-4c070946115a' WHERE id = '3e7a77c7-420e-4aca-9531-0f1362627ac1';
  UPDATE public.profiles SET discipler_id = '5be0e19c-aed0-494a-bffe-47cc4ab70103' WHERE id = '575b9cc2-74af-4dcb-9dd7-dd04321921fd';
  UPDATE public.profiles SET discipler_id = '5be0e19c-aed0-494a-bffe-47cc4ab70103' WHERE id = 'afc77f80-8261-4e97-93fb-0e986839f8be';
  UPDATE public.profiles SET discipler_id = 'be26f95d-e753-457d-b7e3-4c070946115a' WHERE id = '17c4dfad-a19c-48a3-8b5c-7857717d4805';
  UPDATE public.profiles SET discipler_id = '5be0e19c-aed0-494a-bffe-47cc4ab70103' WHERE id = 'c3b373ad-2dcf-47ac-a8b1-691bb72a6ffe';
  UPDATE public.profiles SET discipler_id = '5be0e19c-aed0-494a-bffe-47cc4ab70103' WHERE id = '0cf84e5b-cb6a-4e31-a4df-bda79ced0ffa';
  UPDATE public.profiles SET discipler_id = 'be26f95d-e753-457d-b7e3-4c070946115a' WHERE id = '4e7f4b53-2a99-4d40-ad41-c872cdf55389';
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
