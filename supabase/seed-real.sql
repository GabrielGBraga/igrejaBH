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
  gabriel_id   uuid := '49530a11-3be0-4dc6-b12d-6e76c1c6d3e1';
  fernando_id  uuid := '41538203-0a7e-426e-9f6e-176315fa44a5';
  clara_id     uuid := 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb';
  flavio_id    uuid := 'ac4683a2-4a53-46f2-be91-8a06195a7a67';
  marleide_id  uuid := '2ee8740d-b1fe-4614-baf7-da870e0ac155';

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

  INSERT INTO public.sectors (id, name, created_at) VALUES ('42bca509-5742-4127-93ab-219d7f3d47e9', 'São Gabriel/Pampulha', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('75c19430-01bd-481d-952e-c2ae5566c1df', 'Venda Nova/Neves', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('4723496b-6e4b-42c7-806a-86bda7a85bb9', 'Santa Luzia', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('742a0e92-cb70-4edb-ba38-8f8c32889caa', 'Oeste', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('94a7b075-2946-467b-859f-8f2fea298bd0', 'Betim/Contagem', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('945c169c-3a75-434d-9d16-aff16ac012fb', 'Fora da Localidade', now());

  -- ==========================================================================
  -- 3. CRIAÇÃO DOS GRUPOS CASEIROS (35 Grupos Reais das Planilhas)
  -- ==========================================================================

  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b366e6bf-7874-49f6-b9e1-8db54a692033', '42bca509-5742-4127-93ab-219d7f3d47e9', 'Solimões - BH - Bairro Solimões', 2, '19:30:00', -19.8392, -43.9185, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '63938120-2da3-4289-b043-54453759b8d4', '42bca509-5742-4127-93ab-219d7f3d47e9', 'Heliópolis - BH - Bairro Heliópolis', 3, '19:30:00', -19.8425, -43.9482, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', '42bca509-5742-4127-93ab-219d7f3d47e9', 'São Gabriel - BH - Região São Gabriel / Pampulha', 4, '19:30:00', -19.858, -43.916, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', '42bca509-5742-4127-93ab-219d7f3d47e9', 'Santa Amélia - BH - Rua Pioneiros da Paz, Santa Amélia / Rua Hildebrando de Oliveira 65, Copacabana', 5, '19:30:00', -19.8361, -43.9724, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', '42bca509-5742-4127-93ab-219d7f3d47e9', 'Jardim Vitória - BH - Bairro Vitória / Jardim Vitória', 6, '19:30:00', -19.8456, -43.8891, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', '75c19430-01bd-481d-952e-c2ae5566c1df', 'Santa Branca - BH - Rua Norte, 42, Santa Branca - BH', 2, '19:30:00', -19.8268, -43.9685, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', '75c19430-01bd-481d-952e-c2ae5566c1df', 'Santa Branca - BH - Rua São José do Jacuri, 135, B. Santa Branca', 3, '19:30:00', -19.8245, -43.966, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', '75c19430-01bd-481d-952e-c2ae5566c1df', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 (Casa do Marinho) - Maria Helena', 4, '19:30:00', -19.7985, -44.0092, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', '75c19430-01bd-481d-952e-c2ae5566c1df', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 - Maria Helena', 5, '19:30:00', -19.7992, -44.0105, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', '75c19430-01bd-481d-952e-c2ae5566c1df', 'Leblon - BH - Rua Olga Pimenta Guimarães, 204 - Leblon', 6, '19:30:00', -19.8115, -43.988, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'ad393be8-666a-4ad4-a48a-711217306577', '75c19430-01bd-481d-952e-c2ae5566c1df', 'Sevilha B - Ribeirão das Neves - Rua São João Del Rei, 270, Sevilha B', 2, '19:30:00', -19.7695, -44.0812, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', '75c19430-01bd-481d-952e-c2ae5566c1df', 'Areias - Ribeirão das Neves - Rodízio (Areias / Morro Alto)', 3, '19:30:00', -19.782, -43.985, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'adc03c88-e531-4494-8a68-ceef7762e4f7', '4723496b-6e4b-42c7-806a-86bda7a85bb9', 'Santa Matilde - Santa Luzia - Rua Geraldo Ferreira Rabelo, 169, Santa Matilde', 4, '19:30:00', -19.7668, -43.8582, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', '4723496b-6e4b-42c7-806a-86bda7a85bb9', 'Lagoa Santa - Lagoa Santa', 5, '19:30:00', -19.6328, -43.8906, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', '4723496b-6e4b-42c7-806a-86bda7a85bb9', 'São Benedito - Santa Luzia - Bairro São Benedito', 6, '19:30:00', -19.7825, -43.9145, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', '4723496b-6e4b-42c7-806a-86bda7a85bb9', 'Fazendinha do Baú - Santa Luzia - Rua Presidente Roosevelt, 1107 - Fazendinha do Baú - Santa Luzia', 2, '19:30:00', -19.7755, -43.872, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '84bad7cb-be75-434f-b9d5-1a303aac4464', '4723496b-6e4b-42c7-806a-86bda7a85bb9', 'Córrego das Calçadas - Santa Luzia - Av. Engenheiro Felipe Gabrich, nº 734, Córrego das Calçadas, Santa Luzia', 3, '19:30:00', -19.759, -43.851, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3c098744-82ba-45e8-8090-a1f387bfaa97', '4723496b-6e4b-42c7-806a-86bda7a85bb9', 'Cristina B - Santa Luzia - Rua Mila Bernardina da Rocha, 85, Cristina B, Santa Luzia/MG', 4, '19:30:00', -19.7762, -43.9248, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '002a3ca8-197b-486f-b24e-d146480c6e72', '742a0e92-cb70-4edb-ba38-8f8c32889caa', 'Novo Tirol - BH - Rua Macadâmia, 168, Novo Tirol - BH', 5, '19:30:00', -19.9985, -44.0315, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '08015614-b513-4bd1-86a3-c268609a6a3f', '742a0e92-cb70-4edb-ba38-8f8c32889caa', 'Milionários - BH - Rua dos Atleticanos - Milionários', 6, '19:30:00', -19.981, -43.9965, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', '742a0e92-cb70-4edb-ba38-8f8c32889caa', 'Tropical / Quintas do Jacuba - Contagem - Estrada Chico Mendes, 900 - Quintas do Jacuba - Contagem', 2, '19:30:00', -19.9265, -44.115, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '454c813e-f396-4ba8-97eb-c8af1c44da78', '742a0e92-cb70-4edb-ba38-8f8c32889caa', 'Novo Progresso - Contagem - Rua Paraopeba, 184, Novo Progresso', 3, '19:30:00', -19.898, -44.039, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', '742a0e92-cb70-4edb-ba38-8f8c32889caa', 'Bela Vista / Barreiro - Ibirité - Rua Melo de Souza Maia, 101, Bela Vista', 4, '19:30:00', -20.008, -44.052, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', '742a0e92-cb70-4edb-ba38-8f8c32889caa', 'Salgado Filho - BH - Rua Ibiraci, 250 - Bairro Salgado Filho - BH', 5, '19:30:00', -19.9412, -43.9825, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', '742a0e92-cb70-4edb-ba38-8f8c32889caa', 'Nova Suíça - BH - Rua Lindolfo de Azevedo, 608, Nova Suíça - BH', 6, '19:30:00', -19.9445, -43.9734, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', '94a7b075-2946-467b-859f-8f2fea298bd0', 'São José - Esmeraldas - Rua Américo França Abreu, 257, São José, Esmeraldas', 2, '19:30:00', -19.7615, -44.314, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', '94a7b075-2946-467b-859f-8f2fea298bd0', 'Jardim Riacho das Pedras - Contagem - Rua Urânio, 114, Jardim Riacho das Pedras - Contagem', 3, '19:30:00', -19.9565, -44.041, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '7a245029-b248-4fae-b8a1-555e3596985a', '94a7b075-2946-467b-859f-8f2fea298bd0', 'Marimbá - Betim - Sítio da Igreja (Marimbá / Juatuba)', 4, '19:30:00', -19.932, -44.275, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', '94a7b075-2946-467b-859f-8f2fea298bd0', 'Resplendor - Igarapé - Rua Bahia, 131, Resplendor - Igarapé', 5, '19:30:00', -20.068, -44.298, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '81eedfc8-0117-42b2-a349-d03eba6bee08', '94a7b075-2946-467b-859f-8f2fea298bd0', 'Jardim Alterosa / Santo Antônio - Betim - Rua Limoeiro, 337, Santo Antônio - Betim', 6, '19:30:00', -19.961, -44.172, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', '94a7b075-2946-467b-859f-8f2fea298bd0', 'Três Barras - Contagem - Rua Gentil Diniz, 441 - Três Barras - Contagem', 2, '19:30:00', -19.9145, -44.0885, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', '94a7b075-2946-467b-859f-8f2fea298bd0', 'Eldorado - Contagem - Rua José Barra do Nascimento, 1971, Eldorado - Contagem', 3, '19:30:00', -19.938, -44.0395, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'c122f72e-3a70-45fa-b29d-a8d730705b70', '94a7b075-2946-467b-859f-8f2fea298bd0', 'Ponte Alta - Betim - Condomínio Ouro Verde, Bairro Ponte Alta - Betim', 4, '19:30:00', -19.896, -44.203, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'fa04c60a-6a06-4d31-bbcc-533829613f1f', '945c169c-3a75-434d-9d16-aff16ac012fb', 'Interlagos - Sete Lagoas - Rua Antônio Domingos da Silva Filho, 307, B. Interlagos - Sete Lagoas', 5, '19:30:00', -19.4752, -44.2368, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', '945c169c-3a75-434d-9d16-aff16ac012fb', 'Santa Bárbara - Santa Bárbara / Barão de Cocais', 6, '19:30:00', -19.9595, -43.415, now()
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
    '19ec4776-52dc-43c8-8c08-e272cc157732', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    '2ee8740d-b1fe-4614-baf7-da870e0ac155', 'Marleide', NULL, NULL, NULL, NULL, NULL, 'F',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    '71f8eedc-9d7b-48d1-991e-ae98013a5fbe', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    'aed6ce90-d29e-463f-80d7-d7eb28741fa8', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    'b7b9a6a9-483c-4652-9ce5-5ee31e7e949a', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, 'M',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    '1bc2068a-b1c1-4775-9a46-2437674461dc', 'Soely', NULL, NULL, NULL, NULL, NULL, 'F',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    'bc3cc745-dcd0-4c79-b8a1-bde6e336b28f', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    'd46c69da-3468-4e73-8d78-c1a6a8a50924', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    '2d0e7358-423b-4c27-b1bc-e4c6bc17b647', 'Euller', NULL, NULL, NULL, NULL, NULL, 'M',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    'cfefe8cc-f85e-4427-ad60-149ae73e1dad', 'Wellington', NULL, NULL, NULL, NULL, NULL, 'M',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    '8fb69cc8-44c0-46ac-be75-4568d2a0e3a6', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    '23bd5f9b-0dec-4888-bf3b-c6d78a74a8dc', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    'fe51e018-12b5-4ca2-9164-ade04b45ea55', 'Joana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    'aaf5e5aa-b3b3-4f56-8884-0ca9b6ff98d2', 'Agatha', NULL, NULL, NULL, NULL, NULL, 'F',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    'a1b8ab96-5166-440a-aad5-652216e56289', 'Mariângela', NULL, NULL, NULL, NULL, NULL, 'F',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    '89f154dd-bfee-4516-81f7-6ef9ab81cd76', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    'b366e6bf-7874-49f6-b9e1-8db54a692033', true, false, false, false, false,
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
    '5862029e-8e82-439b-a8e8-a45b3f954987', 'André', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'c9451d88-3d0b-4366-9dee-49bf4b1a665c', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '87ccf9ea-c9af-475b-8d80-2fe92f9b5c8c', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'b79deef6-8e02-4da3-8996-4a68d349a5f6', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '21382e4a-8fd4-4ec9-9df2-bf9adaba9dac', 'Elis', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '41538203-0a7e-426e-9f6e-176315fa44a5', 'Fernando Gomes Braga', 'fgb80@yahoo.com', NULL, NULL, '1980-07-18'::date, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, true, false, false, true,
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
    'e58d0305-1872-4e1a-8d0f-d9804c26d8cb', 'Clara Góes Braga', 'claradiscipula@gmail.com', NULL, NULL, '1983-06-16'::date, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'ba4715d3-dafd-4c10-bec8-205b39e154a5', 'Artur', NULL, NULL, NULL, '2019-09-09'::date, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '49530a11-3be0-4dc6-b12d-6e76c1c6d3e1', 'Gabriel Góes Braga', 'ggoesbraga@gmail.com', NULL, NULL, '2008-04-02'::date, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, true, true,
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
    'b42b968a-b5f3-4b49-a9c1-39fcf5b5e928', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '915cf368-3a76-477f-8f7e-3c56b2602b24', 'Marina', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '2fb3c448-d198-4c58-b50f-532032d13e8e', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'f373cd2a-85ad-4a7b-b54f-4e886c89075a', 'Deia', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '1996717f-e08a-44e3-9b6f-7c44aaf8fe9a', 'Marivaldo', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '679737de-e2ed-4c93-b0f9-61172109ec1a', 'Luciene', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '1dce335d-9640-4178-8675-8a35bcef33f3', 'Ramon', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'c53698e8-a13d-48a6-9f01-218732f58b3a', 'Margareth', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '284c583e-eeb5-4896-94c9-4ecfe43ba1bf', 'Renan', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '1d94db5d-33e8-47c8-b74b-89c3baf318af', 'Arlete', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '831e59c6-147c-4042-a81c-bc3f19f6ea36', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '9996439c-760a-4ee1-9278-26091fb1988f', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '58cf7bf8-953b-4a7b-b2a9-8f0fc0975084', 'Cecília', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'bce95976-eed0-4b1b-8c6b-8efe0f6f1d18', 'Hugo', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '4156a63d-cfd6-443f-8f75-94a85a73bc40', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '1a803e04-1fc7-460e-b5bc-1b8d294dec66', 'Sarah', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'e2a08832-e454-4de2-8b0d-10b59362e49b', 'Matheus', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'f002bd09-01c5-4132-9ffa-2410534196d5', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'a3beba85-241c-4119-b3ae-ea6a0e43fc4b', 'Marlon', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'b80e234e-5b89-4200-84b6-0a5f0f1b6a25', 'Maura', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '60028e2c-f736-4a3c-8f3b-d3d4b0f5032c', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '5407bf48-52d2-4fef-a85f-086f39640c4c', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '21bf9e0b-a641-4a24-8abe-be94e19aa01c', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'fde66a1a-78b6-4327-918e-187d1c6f1965', 'Zoraide', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '9666306e-4569-4937-8092-516692bb7123', 'Miriã', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '1c403fa0-9423-424c-8a0c-16b5938db8cb', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    'a6285c83-e760-4a9c-9c0d-364f54ebbdf0', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '47a23238-4217-468e-ab65-fabf7a365838', 'Wanderlaine', NULL, NULL, NULL, NULL, NULL, 'F',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '71681ca5-6fab-4479-b44f-eddf46a4372b', 'Ismael', NULL, NULL, NULL, NULL, NULL, 'M',
    '63938120-2da3-4289-b043-54453759b8d4', true, false, false, false, false,
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
    '48410ac0-1787-4c7e-a6e7-4e6806642850', 'Emerson', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '4effb9f2-0cff-4fa4-ac68-49a93c2628fa', 'Neide', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'a72d4939-2969-45b4-9e45-a4247325519b', 'Walace', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'fb825f48-ceee-4081-85e4-6dd94bca5a50', 'Sabrina', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '0f68b9d6-4519-49c0-80fb-ccd8f8054f42', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'f17f1d00-d885-4ef9-b56b-b3dee6f7d281', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '4db2d7d9-a30f-44c6-8615-a3f64bee5c01', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'ce3ad9d1-0ae8-4940-9b51-2519e39e712c', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '91ca2fe2-9032-4d9c-a4c6-7969b4197f0f', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'eb53ac6a-789b-412b-aba3-e86e8a4566db', 'Cristina', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '7ac247cc-b99a-43b4-b54b-8fadf2432dee', 'Tales', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'ac1fdb69-a924-4214-9205-52be933cdd77', 'Edna', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '03628cd7-f794-4b9b-9d3e-b0c6f8b0ea1e', 'Thiago', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '163bc3f2-162a-4add-8746-5442599c1855', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'a1d267e0-60bc-4f79-b56c-de041d22f9b6', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '1e7d0844-9b45-4144-8f6a-47e5eded8daa', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '46feee7e-f65c-4367-989d-d27a9a28c60f', 'Carlos Eduardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '46a2f154-615b-4f58-974e-332e17d3f528', 'Joelma', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '740e35a6-aa00-4aa8-a166-f3fcb1106267', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'd852000c-53c1-4b7a-bd16-6d81c145d5da', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'a05697b6-6904-45a7-88c3-b6b7098d96b1', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'fcf6ad83-5564-407a-a912-1d58481f6369', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '7d4694d8-84c5-4a1f-9ab4-f8e148296d02', 'Grace', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '531b1665-fd27-4591-af6d-f355deffc0c8', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '07ddb69d-a9f8-4284-8ab6-54d2409fda68', 'Lutero', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '58ad8446-19dd-4099-bb89-5c27a099aacc', 'Dominique', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '557bc446-6c90-4815-b650-e1e3c9299eeb', 'Kaleu', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '41984054-409f-4f5b-a416-2a457b27867a', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '1782517b-7a4a-41d6-ac9d-ace9095fd531', 'Marilda', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'fa88c3be-f2b6-4547-8af5-01c2104cdc53', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '27065ca5-f568-4eac-b77a-7a8de42baa75', 'Enzo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '220cf2c5-d1f4-417b-8045-d62cbe1f1658', 'Daniele', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '9f207e7a-ec9f-45ac-a292-3cd93919221d', 'Luciene', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'dbc8c225-9ea2-4c3d-a5e4-e4c55a92dc56', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'ea84cd9e-0fb3-41d2-ab96-c9543ff1c59e', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '9272fd6c-c4e0-4df3-9064-266ead281479', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '7fe3ee6e-1682-4af1-995b-d80d6b14033d', 'Antonela', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '1f80df5a-433f-4200-9325-d03c79743fbe', 'Luiz Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '836aa21c-9e3a-4b07-80d8-5850c77d5550', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '4ac72fae-635c-40cf-af54-657b5d2fdf42', 'Amélia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'd8896391-af7e-4956-9c68-2eb4fc530398', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '364de290-003a-4eb6-b113-af145a2c2734', 'Tamara', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '8c776d66-666f-4f16-94b1-772ec6dbd3a5', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '1ba39a4d-451d-450f-8338-69cfb187defd', 'Ciça', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '2105f44b-d2b2-4cb6-9c20-ea411fae11ed', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '70af37f8-013e-4740-a3b0-71dd1bf3adb7', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    '56e83202-89ad-409d-a988-1257989ea096', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    'e30756e5-e290-4b4a-b615-3fc795b75a7e', true, false, false, false, false,
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
    'deb039b9-2c43-4b85-a74a-a3d4886969a8', 'Eduardo Lopes', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'da9efe8a-2833-40d3-a43d-0143dc822d90', 'Érica Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'baf63c47-7914-4719-962d-5827d78c9ffb', 'Laura Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '2fba4517-8374-46e1-b278-154ea6e2c80e', 'Eduardo Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '29b270b9-3d7c-46ac-95a4-2755825d5420', 'Luís Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'fa76f2d1-ddf1-4f9b-930b-78716a3f9eec', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '7e006f19-2157-49d2-9281-fbd612b85730', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '5376f2b1-22d0-46e0-b6e9-49afde19830b', 'Henrique Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '053498e9-b39c-465e-800f-fdcd995b0e67', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '3cce93d3-8d87-4935-867c-cd4ca496d75c', 'Lucas Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '1f11629a-6d93-402d-ac55-5ee99afea65a', 'Raíssa', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'd9b833e7-3a2a-42e4-9a31-1ff994e370e1', 'Lian', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'fdf67716-b692-4b04-a2d3-e1f9dde50c59', 'Pietro', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '8976bfcd-ce49-4c0c-b03f-d8f8d6d2aeb8', 'Danilo', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '9394181d-3464-408d-a3bd-bb935dbe3b32', 'Melry', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'a23ae893-9aa5-444f-8987-68b2ebbcfea4', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '7b30110e-468e-4a89-b0ee-3815befe8175', 'Sofia', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'c5a32184-3d3e-455b-a177-c1ccf55f0511', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'ae582e8f-fece-45ed-b752-3460084f0213', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'a6c53dcc-9b74-406f-9c63-f9fc6bcbdd7e', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '1f2e263e-b3f0-4637-95c4-3f45605586c0', 'Josinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '702dfacb-7739-4b6a-bce8-84b1d0a14f0f', 'Thiago Bombeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'e7b36a58-1821-4656-877b-41b87727603c', 'Paula Emanuela', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'f76e0594-c149-4e63-85bb-2505f5102b9f', 'Ana Luiza', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '1bcf9e15-fc9c-4529-b161-134b1f046d96', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'a37ca909-88b0-44c4-a92b-f713f5a7eb8d', 'Thiago Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'adca2ec6-fd09-486d-bd25-8a5b4bcaf02d', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '25c6bce5-0268-4b7b-8a5a-56a672f2afd4', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'ed6b30b7-982b-48d5-927a-85456a41f266', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '7bfbc39c-a734-4e15-9d6a-edecf30c4cfa', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '08c3f7e2-c9df-40fa-babb-ba557cc5010c', 'Miriã', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    'c705022b-217a-4129-84c9-b33d0106b857', 'Nikole', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '88ac04a8-75b0-4a5a-bf6e-28b4ab0823cc', 'Brenda', NULL, NULL, NULL, NULL, NULL, 'F',
    '167bcb15-3046-4f0a-b314-5190dba9b7fb', true, false, false, false, false,
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
    '51d8feb7-3c2f-48ec-b34d-4bcf12c0b903', 'Ademir', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'bd7c7442-5fd8-4c00-bcd3-aecb129ab6c5', 'Janaína', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '195ade05-f31c-49de-86e7-d4e72ba9b22b', 'Emanuela', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '7eb96c86-8d3e-45cc-a7e0-0f7e2a1d4587', 'João Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '125e543a-302f-433b-be68-a09e63c507a9', 'Julião', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'e722fd77-ec0b-4545-bde5-444e71101dfd', 'Darlene', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '8517e549-b579-4402-86f5-0b0855d62962', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '5942c5aa-c6dd-4bd2-b322-2d940cc7d8f8', 'João Francisco', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '64951ab2-fe06-4f13-a5be-1b9b2ef76bc8', 'Ana Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '2d0dc693-7089-4ace-9484-a67442012d7d', 'Elias', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'd7328036-ca54-4e76-94de-ab6165728b8c', 'Fabiana', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '83369a64-fb56-4ff0-aeb6-b32e51b698f4', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '73cacc71-b7a9-45ad-b96e-10af3f76b74a', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '2139cc2a-b8fb-432b-b0d4-da50222acc48', 'Luiz Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '642fc83d-6711-47e5-a177-6601936cbba1', 'Jéssica', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'cfdfe0d1-e7e7-4577-96bb-d04716b3a83e', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '4bf8d08a-b3a2-4d83-a090-ab4ac1ed4a37', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'e73511dd-3cec-44b3-88c0-410891369f89', 'Thainara', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '879960b8-e1f7-469d-b510-2f639c3d621c', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'ed10e654-ace7-49ad-a1a5-493443dfa681', 'Laila', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'd1dd4653-aaff-4594-a731-182d7ff6c649', 'Evenly', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '13082a23-3b93-4882-856d-ab30546460c5', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'b1712dc7-e900-4e7f-bb66-85bad1005217', 'Antony', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '0e76ecad-d38d-4548-a10b-886846d4dcc9', 'Carla', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '1fb0e72c-a649-48c4-9af3-ba066d0dd5cc', 'Laiana', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'b6e85457-3db7-420d-b634-f49edb36c41e', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '9234cd5a-2938-4603-b541-5e70dde94705', 'Riquelmer', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '7f4b8423-0e21-4501-8188-e14600bd3181', 'Caíque', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '3755f773-f92d-4067-be14-3c2adc728396', 'Silas', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '0685cdb6-a989-4fb5-8251-73f498ff0a54', 'Juraci', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    'fdca5f0c-a67a-4b94-b760-548843bc9730', 'Luizão', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '272c6631-a509-4fd6-ad4b-c8cdeb57120e', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '529d7a2d-cb61-4dd8-9b1c-fa30265d39c8', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '57bc60fc-0514-46b5-a06b-1fbbf12a9a69', 'Juscelino', NULL, NULL, NULL, NULL, NULL, 'M',
    '3347a7eb-d4de-494e-8be4-7b34a99aa203', true, false, false, false, false,
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
    '1a1cb155-63dc-48aa-be97-629e7f164085', 'Helder', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'dc2fe539-c283-4a93-9c35-88809f4dbddc', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'eed70877-f3df-4777-920a-03e929f504f9', 'Jonata', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'f43aae06-e095-4d2e-bb57-442e4f068c93', 'Francérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '4be2bee7-f6ab-4ff3-aa01-d8b4139e6b1e', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '9394686a-d894-4de0-b9c5-d38dc0214d01', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '31e6b766-d663-4b16-b4a7-89a6398035ba', 'Kennedy', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'b5e2d682-430c-49f1-87b7-4260c4275e09', 'Bárbara', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'a95674e5-9d61-4d33-82bb-7fc71199dce9', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '3c207200-5452-4ff5-a9af-5fdd935c3302', 'Pricila', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '52db34c2-0a5a-4959-b6a0-3d02bee1a6cd', 'Luciano', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '7b31ef9f-ffe4-4394-af3f-da7738c4ebce', 'Lilian', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'bf313a7a-6252-4122-ab1e-81aabcee0ce4', 'Tiago', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '50df36b1-4fb0-4911-9e6d-fabe4b2049b0', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'cc3c8b72-8e6c-4354-986d-679b4b1b313b', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '047e97f9-2410-49aa-b71f-a03d60b2018c', 'Taiane', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '2ec480e4-4dcd-4ecf-9a9c-b4286b1a7bc0', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'c6128e49-11a6-45f4-b389-2abfa88f7138', 'Rhuan', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    'cb668bf9-3380-45b9-828c-d945727b81c7', 'Gabriele', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '5e5aca21-5ef2-4790-af92-44702aebbe9e', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '9bfa46bf-a0f2-4a95-958e-57993c71b1b2', 'Polyana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '28375ace-3ea1-46ae-851c-08cd7999bbce', 'Maria Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '61843e28-4eda-4f68-a8d7-5d7fec4fe132', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '6655cf95-914d-4cf9-87d0-f5f2f42d7f74', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '87713316-d310-4d50-9e70-030562fd3a3c', 'David', NULL, NULL, NULL, NULL, NULL, 'M',
    'b0bbefe0-256e-4cd3-98fe-254236c2b742', true, false, false, false, false,
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
    '6b86a8db-1d0f-4912-ae80-29200ade426b', 'Juarez', NULL, NULL, NULL, NULL, NULL, 'M',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '40a0515b-0a57-49e7-af3e-8ecee4111ccb', 'Divina', NULL, NULL, NULL, NULL, NULL, 'F',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '1a356435-f1e5-4182-92c9-9fd264cb6eff', 'Argeu', NULL, NULL, NULL, NULL, NULL, 'M',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '039fbf33-f317-48e5-8e0d-936db31d9160', 'Lora', NULL, NULL, NULL, NULL, NULL, 'F',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '0867a620-f94b-4f40-bd61-953032e28ec0', 'Sérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '6d2cc23c-fba4-47e9-83ac-a621040cecc5', 'Karina', NULL, NULL, NULL, NULL, NULL, 'F',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    'ab9589c3-52f2-43c8-9ad1-128ed4a9ed1a', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '69ba3739-912c-47a0-97b7-6e8832b54c64', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    'b97370f4-d9ed-427d-845f-617403ba0b14', 'Lúcia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '80a47259-6c6b-462a-8165-c6a5b0f68c19', 'Mundica', NULL, NULL, NULL, NULL, NULL, 'F',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '33765832-7f7c-4222-9e37-a9d9934cc6af', 'Janir', NULL, NULL, NULL, NULL, NULL, 'F',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '1b2fc3d7-126f-45ba-83b1-afa799634795', 'Cristiano', NULL, NULL, NULL, NULL, NULL, 'M',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    '2e9695b2-f370-49f3-90be-6c37215f10b6', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    'bc417f2e-81fa-473c-94d1-76d564d4305f', 'Caio', NULL, NULL, NULL, NULL, NULL, 'M',
    '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a', true, false, false, false, false,
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
    'f57ad015-e7c3-438a-9f12-db36c09a4335', 'Marinho', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '612d29d8-f49d-4e39-a109-673bf53aa47f', 'Quênia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '2d377053-64a4-4942-a5ba-ee101a660cab', 'Karina', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '4753c931-e112-4ed5-95b2-b13bed2c133f', 'Jonas', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'bb54e705-da5d-49f6-9810-4a1b6e45fd4a', 'Wellington', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'f7eea24c-008a-41dd-9932-6503c9b9f7b3', 'Raquel', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'd5d8862e-afc0-4627-9e09-c506965e4587', 'W. Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'b51a6cfe-82cc-46e0-b163-256680d98407', 'Carlinho', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '14897482-dd97-4401-82d1-ba8e0b9ed06d', 'Graziela', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'a3933113-4ab7-4ef5-8666-f8857be95db2', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'd92eb4ed-858b-4c09-ae09-3306f30f63fd', 'Alexandre', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '0dd7e454-0797-491c-8fe3-3475b659065c', 'Érica', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '33c3cb37-6fa2-4063-98a7-13ce081e1191', 'Benjamim', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'cda61385-c64a-463a-9ce6-31eef0d3ab34', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '6de44343-a9d4-4c3a-b5a7-398ed6e5fcaf', 'Eliete', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '7a7e6309-2a08-473c-a612-31593f2433ec', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'eadeb240-9e4f-4954-9fa7-db464ab72b88', 'Marcela', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'a31da5a4-deec-4d5c-b792-d528bcf4f10c', 'Zezinho', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'b2264eb8-2acc-45fc-8683-6f5eb5e6543d', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '8957807a-e715-4d48-a8a6-3b33305425d3', 'Cida Santos', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '5c140d14-54e9-4f14-b3ba-676d0d9a4fb3', 'Cida Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '14259a65-cac5-4ef0-8e66-f1fac5cc8770', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '20423899-a1be-41fe-a81e-3617d1f534ba', 'Cleuza', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '0734a02b-fdce-4db2-9e29-7fcb1107cfe5', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'de6b3e84-f486-45b2-ae7b-f53c7490e504', 'Roger', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '40fffba6-b4fd-4fe7-b10b-95ccccf3776b', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'bed3384b-b1cc-4c02-a002-6214c87b050b', 'Mary', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'bff87838-abd9-46f4-8aef-5ee7530edfc4', 'Filho 1', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '8f8a7f9b-19d0-4dd5-a941-dfc2930171d6', 'Filho 2', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '5c7a5a29-8d7d-45e2-bb81-fb235b4fbeb3', 'Marly', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '625835a3-2962-45c1-9971-7d369cf17589', 'Marcone', NULL, NULL, NULL, NULL, NULL, 'M',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    '80b7b173-3745-430a-bd84-80bec9ada5f8', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, 'F',
    'ccdbd19e-c15b-47af-9415-57a1481c56aa', true, false, false, false, false,
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
    'e42cecff-79c7-4c65-a4ba-44a08c50571a', 'Vera', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '089eb37a-3539-4603-9f28-1fdfc68d8787', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '256ca232-7272-42e4-b27c-845df33afa7f', 'Didier', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    'e1bb5bee-f50b-4fd2-b81b-9358977cfd20', 'Winter', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '6f3a51d6-af0d-456a-8227-4b82351bc7ed', 'Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    'a5fa06f0-a3b8-488c-a24a-21266eaf2b40', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '0a9096c0-86cb-4372-bd1b-ea8f5dee3d57', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '69f162e6-04dd-4c01-ae32-480a7303db7c', 'Maria José', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '71f43006-bb6e-440d-bb1a-2209585f1431', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    'd9d1717b-bab3-47ee-89fc-c35482d78999', 'Selma', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    'a53e98f4-7a95-49b1-b3cd-093d1ac25158', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '14f38a23-d661-4599-bae7-47744094db90', 'Antônia', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    'fdb99e68-ab63-4585-a38b-5945165a8bc6', 'Marcone Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '6dc72ec1-1e88-44ee-96b1-569b6a06e931', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    'a7583aa9-6991-4796-a3f9-38b34c58ce6d', 'Karine', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    'e3828cef-f195-4cfe-88a4-0f2d32c9582e', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '99be6504-c702-4136-9ba6-827b93a4a67f', 'Isabela', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '3d420810-dc4d-42b5-9e03-eecfbf114225', 'Cecília', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '68614af5-bb97-4eb4-a806-83b6b4c45379', 'Matheus', NULL, NULL, NULL, NULL, NULL, 'M',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '775e0a4b-70a0-494f-b29b-3aad35c558c5', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    'c3af21fa-bbb9-4f62-b2e7-ae151a7c12dc', 'Hadassa', NULL, NULL, NULL, NULL, NULL, 'F',
    'cd47bc1a-e589-4890-b53d-e0f3f732d155', true, false, false, false, false,
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
    '2d34ce73-838d-4d99-90fa-e1893a87cdb1', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'a2ec4427-e18b-4cdf-ac52-13b2e029ed11', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'd2089a49-259e-4892-9a84-fbcb7e915f9e', 'Sidney', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '474c1aae-45b4-4128-a1f7-8c0b9bf2a3ce', 'Suzan', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '027d3967-256f-4a56-bc84-67b3941215ca', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'dad33f58-b3c0-472f-bee9-256bd3e0b8c8', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'd9b07b7c-fa36-4595-b92d-bf7a2c1fdbe5', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'bdec47df-9b01-4517-837d-bb645f9381df', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '6d08ebb9-54c6-46cb-bed2-90e56d34ed6c', 'Hélia', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'de0db994-0506-4e43-b721-141f1d8bdb48', 'Renato', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '360c341a-3bf4-4314-b55b-f74d3b59e1f3', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '7042236a-9f19-429c-85cc-04c5dad769aa', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'e1f7ca2c-69af-4210-8c96-00d9598a3a38', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '81fae17d-bcd1-4b84-8055-e7b4244b35fe', 'Ediléia', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'd4e6646b-e624-4737-8404-250150e042a5', 'Daiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'de5694c4-4a09-44ef-9ac0-e220770589ca', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '6f8f6c75-5033-4a55-888e-0c871d6cf1b7', 'Esther', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'b16e6ebe-42d3-4e27-9ff1-254bba818ee0', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'edc19318-a69b-4db3-a2e2-7c9b2932d654', 'Sandra', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '5a761c43-04bf-4f31-b434-3524c3e40646', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '349649ef-5829-4587-bec8-a86d509f8eb5', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '27a13096-6901-4c8a-8713-a932561f2f9c', 'Moisés', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '4670f7e4-93ef-46e2-8409-72370677d54f', 'Ramani', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '5655e0b9-1480-4450-a22e-a8f643342549', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '88bb1d75-c78d-4e78-9350-2e83c1da8c53', 'Débora', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'ed077042-73aa-4f27-949d-2918308a0c1a', 'Juliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    'b6aec84c-dacf-4ce5-a460-a21a10b033f1', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491', true, false, false, false, false,
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
    '1761642d-1189-4fe0-b79c-eafc71831e79', 'Dimas', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '0d371dcc-40d7-4e2f-9de5-8922139c8b92', 'Nívia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'b489044b-3370-4f91-a4f9-265d7eafa149', 'Artur', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '0df8e0aa-c692-4ab3-b2a9-7411b514db6f', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'dd6a067d-0080-4f7e-bddc-cff252ae6682', 'Douglas', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'c0b8d474-507e-4b27-bac5-ccacaa05fa73', 'Cristina', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'fe7c93c0-4bb0-4616-a91a-e1f59e567478', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '5e65ad20-51be-47a7-b97a-7ceda57183cf', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '744ca85f-dba9-4219-acb5-fcfaf1f5978c', 'Cláudio', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '70c49972-7aad-4029-9b20-74076b37f028', 'Cinara', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '1a473189-1e8f-47d0-bd72-efa4dfb348ae', 'Saulo', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'a51c8e32-cd17-466d-999f-117f5a13981c', 'Duardin', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '0481c99b-14b4-4920-95f7-311da08dbbe7', 'Angélica', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'cb3f38b6-cafd-4da8-9a56-f573222314e7', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '2efdd372-519a-4e43-89e8-c8b9dd437676', 'Lara', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '13c6339c-9465-4a0f-8ca0-0f4f0831b509', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '19b30595-09ac-4f93-894a-1ceedef35175', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '94b81417-d088-4b6a-aa12-bf0835c4a2bd', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '34ecb3c7-74a7-4088-bbcc-144214f72813', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '7c665554-8203-4489-b04d-658f17cb5774', 'Graça', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'f2cf8c29-115a-46c7-a7fc-b0d6fb33ce12', 'Jane', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '2428174b-ec35-466c-be24-f6d8a1d71c47', 'Kézia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'da8bea45-51f1-48d1-99b2-942db494f2bb', 'José', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '4752f70f-7d70-4ca7-857f-409f227f754f', 'Geralda', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'a9c70e8d-257e-4989-82a0-df202554187e', 'Marta', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '0bb0ae28-fd0a-4839-a1a3-3ad944a662b7', 'Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'd3c6d8cd-fc9b-472d-b021-45faf880b98d', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'aba43f40-f39a-491f-a092-6d2f5ea99604', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '00f4778b-c13f-443b-8f3b-d0b094875c04', 'Wesley', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'd64395ae-9107-4a15-b6be-c339264d6f3e', 'Elen', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '2b8f1fde-b81c-414e-97fb-8987efb65e84', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '31f4f517-90cb-4b29-a722-d0c624827352', 'Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '9438c0a2-be20-4658-b485-3c2b33bb472d', 'Cleiton', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    '1273ca07-f66e-4498-b69d-6314956f1dcc', 'Milca', NULL, NULL, NULL, NULL, NULL, 'F',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'feb3706a-0dbc-421c-b907-015f0fa3d935', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    'ad393be8-666a-4ad4-a48a-711217306577', true, false, false, false, false,
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
    'd18c42bf-13f3-4db1-9a2c-4cb3a1824765', 'Jaime', NULL, NULL, NULL, NULL, NULL, 'M',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'fd7421dc-e24d-4ab1-8e2e-523534d30e36', 'Jacira', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '1fdd27df-deda-4dbe-a73b-b436db8249b4', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '11787974-d37b-4e3d-bb0d-272434b9a441', 'Dona Adélia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '2805af4b-4afd-4694-846c-4f7a8dbc5f86', 'Wagner', NULL, NULL, NULL, NULL, NULL, 'M',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'd0efb40a-1e42-4d2c-a201-750031eeaf16', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '1c8a03df-e828-4c54-986e-b10c83e2a75c', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '0e12c45b-851a-4d82-939a-0bb025f3f997', 'Rebeca', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '9e876476-7081-472d-9529-4d613ca1c3b0', 'Ronaldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'd50e316f-3e08-4531-975f-c2f4f1e8057f', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'f82f2d40-3ef2-44b7-bc9c-f1ea0d745553', 'Glória', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'a353767c-9979-4023-a653-40cc2202ca2c', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '9af18973-f83c-4eca-9643-9fe7564ff0d2', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '26d99b5a-3d64-41f8-8c18-fb8a79ae96e5', 'Aurora', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '26ed3d69-7653-46e6-b02e-3e41f66ed7f3', 'Maria Tereza', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '5a2883f5-144e-4b79-a8a5-4badd593a645', 'Welvis', NULL, NULL, NULL, NULL, NULL, 'M',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'b3346ac1-df4f-4038-acf3-a5a3e5b13347', 'Adriele', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '9863a27e-45f0-4c72-b394-f5cf0eb5923d', 'Bela Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'a91e3152-bbe1-49d5-a5b9-a2366a173a01', 'Izaque', NULL, NULL, NULL, NULL, NULL, 'M',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    '02bbe8c4-7103-412d-aed1-7e4913774813', 'Jamile', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'f9024f25-b8ea-4c57-affc-b989b63148b6', 'Kailaine', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'ff893283-01a1-41cd-85b5-e3263b188a6a', 'Angélica', NULL, NULL, NULL, NULL, NULL, 'F',
    'e6b4096f-e087-41cc-8c5e-d083980b13c4', true, false, false, false, false,
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
    'aad4af3c-f8dd-46cd-92cd-6ae4620a28e3', 'Davi Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '81c36f7d-917e-4ad6-82bc-da56fb728c92', 'Liliane Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '48892566-8964-4615-9341-499c82450f4f', 'Diogo Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    'c91c6726-1948-48ec-84f6-6f79c9964e68', 'Thiago Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    'e2c8d6e5-c6fb-4744-bb9a-e0182140abb8', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '9ab5e99a-a169-4984-b54e-2027ba37cc36', 'Gabriel Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '0c82ea83-5f16-4a45-b1e7-b99e1d941b4f', 'Giovana', NULL, NULL, NULL, NULL, NULL, 'F',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    'd4d929b4-01d1-48dd-b6eb-61a534e89409', 'Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '2542a549-e6ab-4458-aee3-e2d9e393034c', 'Krismary', NULL, NULL, NULL, NULL, NULL, 'F',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '17d89c23-f27f-46d4-8f96-208196d8b6fc', 'Wellinton', NULL, NULL, NULL, NULL, NULL, 'M',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    'c4409645-87a8-41cf-b2d0-46bb3deb6049', 'Miliane', NULL, NULL, NULL, NULL, NULL, 'F',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '5ebf0736-bcbb-4cf5-80ce-48398e10b0f2', 'Gellissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    'efa9933a-800d-421f-a3f5-f0a859bd19b4', 'Kal', NULL, NULL, NULL, NULL, NULL, 'M',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '72015b0c-ec6e-4d54-a88d-ae44c62711ac', 'Tininha', NULL, NULL, NULL, NULL, NULL, 'F',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    'fafe39c3-d6cb-4127-a9c0-c019903dab51', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    '579fbf3d-fa72-485b-886f-b5ba864269f7', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    'adc03c88-e531-4494-8a68-ceef7762e4f7', true, false, false, false, false,
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
    'c525665c-41c9-428f-b2bf-19f75c3273e3', 'Lincon', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '4da0d483-7562-4aa3-8ce1-bae3cf26d0ea', 'Tati', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'ca687d0a-6c68-44a5-b47c-04a861dcbea6', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '5a5c0fdd-a581-41b9-b347-00e02d8febc2', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '9e1c75ea-6a67-4d38-9238-6d38ef75fb06', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'cf1346c9-c3bb-4a47-a31c-8c1f77324d4a', 'Adilon', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'd1c722d8-77f0-42a3-884e-1137f1d91cc0', 'Lena', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '30820239-cfa7-40a1-b100-5f8f37acd1b2', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '61cefda3-feab-46ab-bb34-095634d5a25e', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '0ca60d3b-1d10-433a-80ef-5c6b44c5f856', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'f9c5dcae-bcd0-409a-bec0-107b57f022ea', 'Milena', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'a9fa1bb6-eff3-42fc-b88b-d92b771b9180', 'Isabel', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'afc0ea06-9e6e-416b-9323-9a512af12fd1', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '9cf018e2-8a26-4a6c-9c19-2a7218850108', 'Daniela', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'c12e1672-b8c1-490b-87f4-dcbca7fb0a82', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '715a65a9-9f5e-4183-9221-2801902de422', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '6c3875b3-c265-427f-ac39-2dc4152f4bd0', 'Bernardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '82f620bb-0d1c-4e61-8093-92d7ffed8d6e', 'Neto', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '2f4f85aa-dec6-40a3-8468-0907a169020c', 'Thaís', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'c7817d63-618c-41ce-8c0d-ed83045b1242', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '2a24006f-118f-4013-a767-6c8f87c5f161', 'Luiz Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '417e8bea-be9f-40b2-a359-ba75007a0ac4', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '2bf2e6ff-2041-4e56-9a02-89a1f6940655', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '4bc2b2ab-8fa9-4d0a-aebf-62242e45e599', 'Benício', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    '9a8f086a-2a27-43e3-ae74-d985189cf57b', 'Augusto', NULL, NULL, NULL, NULL, NULL, 'M',
    'fad1fef2-d71e-4783-b11e-8f26cb3faff6', true, false, false, false, false,
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
    'ac596a22-212d-4e17-82de-97f07cf80528', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '2506aea3-8c4b-41a0-8237-e11cf9dd0130', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '808a6473-f076-43be-9408-6f62697e824a', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '6426769b-3361-4e5c-92ca-71faa0b1933f', 'Soninha', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '63433d51-1305-46ac-9be8-c4a6f0e3b2a0', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    'ebccc2ac-a542-43a8-8074-06124a38cbc3', 'Daniele', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '1a1aa17e-1e40-43ba-be3c-d1233180b37f', 'Lívia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '0778b9a9-43e4-48ec-993a-1ca6a6e03769', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    'b78776f3-9b0b-4ebd-9df0-59e079ae2a3d', 'Geovana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    'c3e9e50a-771d-4b61-960e-1e3497d7e738', 'Emanuele', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '26b23ba2-14e0-48d8-9f75-1aa39e56fe84', 'Paulo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '9e594c78-e783-459c-9697-2bd526a6d353', 'Alcione', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '3ad8df8f-16cf-4275-a4fb-c7145d22389c', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    'a45dcb8c-f43a-4303-918b-ec0ef4db3b55', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '1e29f38f-19c0-4cb0-ac2b-5baa037ac5c7', 'Abadia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '4668a055-2570-455a-8aa4-3b92f24be712', 'Dona Vânia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '493d0e03-fd47-48d0-a921-7d1a07835444', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '3f34f2a2-21ca-40e6-92c0-c8b63b7af9b0', 'Bryan', NULL, NULL, NULL, NULL, NULL, 'M',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '185d1daf-adfe-4222-be33-64f8865fc357', 'Evandro', NULL, NULL, NULL, NULL, NULL, 'M',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '213af085-8b16-4e13-8377-737f0c8a020d', 'Jucilene', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '5a72b179-d31d-4ef4-869d-298cd11def45', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '725bfde5-fdce-4c16-94fb-229932618416', 'Gilson', NULL, NULL, NULL, NULL, NULL, 'M',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '3c742c4d-ed01-4a67-9096-b2610d24e075', 'Liliane', NULL, NULL, NULL, NULL, NULL, 'F',
    'b6cab6d6-a3a7-4739-a93e-ed674aed58df', true, false, false, false, false,
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
    '23657810-988d-4cc3-9e1b-1751ebbbdcd4', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    '4fb6d3c1-820f-4cfb-b31b-d880223d3d1a', 'Auxiliadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    '9bd7da3e-ff4f-41d9-96e8-6b2e90f7216d', 'Jonatham', NULL, NULL, NULL, NULL, NULL, 'M',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    'c7ba2bfb-43e0-46b9-b665-3a0d6874de74', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    '30b3bb90-624e-43ac-a2bb-2e02a95c9d4b', 'Jésius', NULL, NULL, NULL, NULL, NULL, 'M',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    'ec488ee3-4fd9-4f38-8ea9-f528c97dd46b', 'Elisângela', NULL, NULL, NULL, NULL, NULL, 'F',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    '57c8cae9-25b3-4cb1-8dd3-8eb5d6142966', 'Cláudio', NULL, NULL, NULL, NULL, NULL, 'M',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    'a3b432cb-5e5c-4672-b812-ecffebc204ee', 'Ivanete', NULL, NULL, NULL, NULL, NULL, 'F',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    '23776236-9aa7-45fc-b95e-d4fb7fe6da23', 'Brener', NULL, NULL, NULL, NULL, NULL, 'M',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    '936ceae4-c5c9-406e-8841-84379376662a', 'Deivison', NULL, NULL, NULL, NULL, NULL, 'M',
    '09661dad-55e9-4d67-b9fd-6c1a983fa100', true, false, false, false, false,
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
    'db93cb34-835d-4fe6-8e35-53621fd147e7', 'Roberto', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '5ce3d7af-196e-4675-aa48-19c96f622d99', 'Leidiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '98e97be0-27ba-4847-9d97-accbde0d3424', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    'cb58a6cb-ca14-40e6-bb47-4f8cdcc58fc2', 'Rayssa', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '0c01eee7-9da0-4da9-a6f7-a673f4a3db6f', 'Ryan', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '08b473e2-eaf9-44ef-84eb-6f02b72e4a25', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    'df3db365-38ea-4aca-abeb-c4c4a2207333', 'Dora', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    'f5a74c50-0724-420b-b8df-adab5251d9bc', 'Ana Flávia', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '7d775daf-ccf6-4977-977a-fe015751b1d3', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    'b21328c6-5e07-41c1-a852-50a44cc78f53', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '9ce2ff98-f302-4130-93d2-45942b07913c', 'Leydimere', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '696c2849-64f8-4899-9bbb-30195ee65c8f', 'Bernardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '6b506bab-3ceb-48d4-9ca0-8efad398eae6', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '69b48c21-3834-4c15-aa7c-585de935dac7', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    'f603b12a-a7c3-4e06-ae3c-9925ad08fcea', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '9bc1eb46-0ea5-40bd-ae7d-de083ce66d20', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '838deeec-42e3-4c82-9aca-30c7c8b660df', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '9ec0d723-674b-4224-bd42-d046f79d6910', 'Álvaro', NULL, NULL, NULL, NULL, NULL, 'M',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '01a42d7a-9374-475c-83c2-b2c5c75af0a6', 'Gabriela', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    '78eabb9c-bc6e-467a-93ed-9d879a2490d5', 'Olívia', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    'd9f25bad-c607-4680-9b55-c914e62d5f3f', 'Maria Aparecida', NULL, NULL, NULL, NULL, NULL, 'F',
    '84bad7cb-be75-434f-b9d5-1a303aac4464', true, false, false, false, false,
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
    'fb4ae27f-7799-4940-956e-6e5c337fe981', 'João Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    'ee2ca227-aafa-40f8-9f43-a2fa3090b2bb', 'Thaís', NULL, NULL, NULL, NULL, NULL, 'F',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    'ba74aff3-651b-4b89-b9c3-0fc09904744d', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    '816c41bb-a6cf-400e-a5c6-0e282dba200a', 'Lara', NULL, NULL, NULL, NULL, NULL, 'F',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    'c94e4491-9993-425e-90ad-6bcdf906ae32', 'Zinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    '8277576d-b0ea-4107-9bdb-6917cce5ea7a', 'Warley Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    '1104fa95-1ceb-43c9-a48b-ee77c5794c0e', 'Dona Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    '1f54b7ab-e0c3-427b-b925-58e81d0b821a', 'Júlio', NULL, NULL, NULL, NULL, NULL, 'M',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    '5f633223-b89e-46ec-bd19-e1ef8f9b286b', 'Andréia', NULL, NULL, NULL, NULL, NULL, 'F',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    'b979a29c-5f5e-4b42-ab28-228966f55bde', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    '5bd5ed21-ce40-4633-adbf-f98469b1d98a', 'Diogo', NULL, NULL, NULL, NULL, NULL, 'M',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    '81eed824-2776-4c5f-b12e-17febc2d8435', 'Maurício', NULL, NULL, NULL, NULL, NULL, 'M',
    '3c098744-82ba-45e8-8090-a1f387bfaa97', true, false, false, false, false,
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
    '8843c203-2474-4a86-abb2-f795dd099fe3', 'Júlio', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '7428d4ba-dda0-4c0f-8908-12ce3b72318b', 'Valéria', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'c443a0a4-4d8b-4a07-846f-9eed64fedee1', 'Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '3eb49b3d-9266-40c2-910b-5d494115ccb8', 'Anderson', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '3f6d0078-c3ae-4c3e-9ce4-1c8e77aafb09', 'Kênia', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '24e9cef5-d879-4caf-893a-ccbc3f957f8e', 'João Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '1a3dfbbd-d501-45fb-a402-5db1c736a727', 'Arthur', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '90cdc2d3-2770-44fc-81a7-cd0701bb68a4', 'André', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'a3a1c2d2-6b49-44c2-92d6-e47dad320e98', 'Andréa', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '9d517464-5296-4fa3-8602-16f528f291be', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'a8c9400a-bd69-4622-a2a3-03256f1b59ee', 'Marco André', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '98088ecf-01ce-48fd-860a-9adf4dc29213', 'Genderson', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '59bb6092-e518-423d-9540-4d154ce46b02', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'c9682429-807a-4396-85e8-9a89a921e164', 'Sérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'b8d07260-54af-48d0-b333-127674addbaf', 'Kênia', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '153c23b6-1876-4cb5-bd1f-b515e45add99', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'ea91e543-6615-4b64-852a-62cb15e43368', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '72f5e5cf-692c-4044-8b0c-9fb979ffd8cd', 'Juliano', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'afd46cc5-f631-4bb4-aa0c-ae57bf4a636c', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '05ff2ee7-58c2-4c27-b9fd-1fca15e846a8', 'Bernadino', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'fd88bbc8-210d-40f9-97c9-ec359641e5fc', 'Jorgina', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'a8bbce5d-6d63-4f65-af39-879a0ab3a334', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '6d1a49fa-af42-45cb-9414-2ad4afe3f1de', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '6717f9f2-8152-4d1b-a3ec-66c6220d7b5e', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'd4c96517-da30-487f-be35-36f4bf27c72f', 'Valéria', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '16d7a185-a0d2-491f-93e3-c9334713a3a7', 'Mariza', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '1976e0e6-9420-4e46-a6f1-ef6a15a26610', 'Jorge', NULL, NULL, NULL, NULL, NULL, 'M',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '6ee994ae-4df5-46e2-b29c-ad7af8d99760', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '824ea17a-0de5-4c26-b7b9-762dc249a6ec', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    'b32abc78-8e98-4805-a989-ca68fa0ff6d4', 'Cristiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '002a3ca8-197b-486f-b24e-d146480c6e72', true, false, false, false, false,
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
    '8b571057-7c94-4269-81a7-a6fb34dd1373', 'Rafael S. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '77ffe695-e38b-4cab-a160-59fed1eb0e70', 'Isabelle C. M. Moraes', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '36eadb01-e784-4323-bfea-a0c338661606', 'Beatriz M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    'ba8976aa-e017-4088-bd2e-1e243a27f5d6', 'Filipe M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    'f65f52ba-68a3-4389-aa17-66e3de488a69', 'André M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '1b79371e-80e6-4dc9-80b3-46ce809a72fb', 'Ari', NULL, NULL, NULL, NULL, NULL, 'M',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '77914e9f-026d-4eba-9a5b-2b83b978d90f', 'Jucieda', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    'f33d8194-8fc3-47ea-831d-bc8d805808e9', 'Natally Silvina', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '2888b159-eac2-4102-b88f-24d50d554435', 'Wesley Anselmo', NULL, NULL, NULL, NULL, NULL, 'M',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '4d6438a0-6cb6-4699-8c19-4e8caf732cc5', 'Evelyn Ellen Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '7df14af7-4fb5-427b-b293-97546ed3ca31', 'Anna Júlia Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    'db52670c-7c47-4a21-884f-edc4690f7d25', 'Anna Laura Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '7113071f-c095-4a54-b1a4-449d4686b4a1', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '1d9f23a3-43a1-4fd4-b1a4-357a79842155', 'Lucas Eduardo Luz', NULL, NULL, NULL, NULL, NULL, 'M',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '409646e0-bbab-49d8-86d9-94df0c8ad46a', 'Allina Rodrigues Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '3841be2a-af59-4e6f-ba10-35b90a91b39e', 'Carolina Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '65168bb1-4eae-4179-8e1a-99900496ee0e', 'Maria Fernanda Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    '99a660a9-c04c-4ee6-8b03-45d55309b4a9', 'Leonardo Luz', NULL, NULL, NULL, NULL, NULL, 'M',
    '08015614-b513-4bd1-86a3-c268609a6a3f', true, false, false, false, false,
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
    'cb44faa7-fada-4754-9a48-b4c2c911cf94', 'Cláudio Luís dos Santos', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '273d760d-2569-4f6c-9372-c7833dd656df', 'Vânia Lúcia de Paula Santos', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'a5ecfe2d-3dfe-4cb0-9951-b7459048c720', 'Nicolas Matheus P. Santos', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '7c8a73a8-ee9e-4100-a523-730a700be20f', 'Davi Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'dc89b869-08ce-46d5-a8c8-0330a73060ba', 'Roseli Gonçalves', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'c6506f77-06ef-4f06-bfc3-5a4bef774238', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'dde681b0-f281-47b8-8114-d7273e3e45c5', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'c6773fb8-621a-45c9-83d7-1c112aab0051', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '085fd5cd-72d7-4435-aa37-050a5733b4f3', 'Lúcio', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '03f38c79-742f-4e08-8b12-51ddda20cc5a', 'Tatiana', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '10795158-8d9d-4903-9166-6eded32a2637', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '7dfe1f40-15d7-41d7-b38d-b40edb925636', 'Eliza', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '7ac9f5be-d838-46d1-9cd2-790674800465', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '15cabd86-de1e-4944-8c19-384bc67c087b', 'Neila', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '33c9a9f6-4073-43c0-8815-9cd7acbc500d', 'Enzo', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'd32944f6-f859-4093-8f1a-7c4f7d2fd9cf', 'Melissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'cdf3160e-2e83-4d35-93f8-ba9f0fc6cda4', 'Hemerson', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '6fe9081b-f611-40d2-ae14-50bb53d225fb', 'Joelma', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '2e18975a-33e6-4f7a-9da8-6e434ff02529', 'Sueli', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '030b85eb-0f54-4201-86d4-774a46c53576', 'Izadora', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '32c7e4a0-3129-4f72-88b0-8590a7c808de', 'Isabel', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '1d752fd1-fdf7-49fd-b00b-55408cb833b2', 'Aparecida (Cida)', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '37eaf045-f0f3-42d8-9537-9008dbd12344', 'Alviclênia', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'afbc6e30-2084-4a9c-a128-1fb2332ae6c6', 'Rosa', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '074d5c14-3d7b-4b17-b7d5-cf27d8386e04', 'Ferreira', NULL, NULL, NULL, NULL, NULL, 'M',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    '03d23d2b-2c50-4e6a-9cad-dd19b028c468', 'Gisleia', NULL, NULL, NULL, NULL, NULL, 'F',
    'c2852ff1-bc44-463f-9dce-1774ebc16a8b', true, false, false, false, false,
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
    'a4e32b83-b201-4c50-b72f-ae4738145c21', 'Willian', NULL, NULL, NULL, NULL, NULL, 'M',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    'e782760e-8183-48a0-9ca3-642a58f98c87', 'Dulce', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    'b0cb4d2d-f134-48cb-96c8-cf2a98e596d2', 'Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '634ebf19-5d6f-4553-a482-0d9b795cdb5b', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    'd845a0d0-cbaa-4432-91cb-40a13c5232cc', 'Eduardo Coutinho', NULL, NULL, NULL, NULL, NULL, 'M',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    'c0281d29-ea62-47dc-b713-3fa61a914d50', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '47397373-f6de-47b3-b15e-8e4f0c97a7d4', 'Roberto', NULL, NULL, NULL, NULL, NULL, 'M',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '30ec8b53-fa37-4d68-8f78-82ba961ed646', 'Neusa', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '350cc14a-12c3-4177-87ac-8457eddace69', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '31f72d9e-634c-40a8-b1c5-999a1818d562', 'Meirielle', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    'fffc854c-bdee-4781-b480-dc32c37a2cfe', 'Eunice', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    'e0b2db19-abb0-4e67-bb18-38d43526e2e6', 'Lucimar', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    'efab151e-d8bc-430b-9c55-7a239a38ce3b', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '4637e51e-d868-48a0-9c49-e3e45b5c161a', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '083f9f38-7032-4278-9596-67c4202b1dff', 'Dalva', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '489d006a-d113-40c4-9fd5-b4806cf13a3e', 'Lúcia Helena', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '8e69290f-c4fb-4e91-b1e6-1d3b6a899987', 'Sirlene', NULL, NULL, NULL, NULL, NULL, 'F',
    '454c813e-f396-4ba8-97eb-c8af1c44da78', true, false, false, false, false,
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
    '6a7a69f2-740b-45a7-8399-3db32c96ac8a', 'José Alfredo', NULL, NULL, NULL, NULL, NULL, 'M',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    '84fcc302-3b37-43c3-b3ff-d6e5978183c6', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    'f2b9159e-8d29-491b-a5aa-25446a426482', 'Isaque', NULL, NULL, NULL, NULL, NULL, 'M',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    'd4888e55-62e1-4003-964c-263847bbeb25', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    'cc02327c-e58f-4f11-8bca-b7f936147b76', 'Ila', NULL, NULL, NULL, NULL, NULL, 'F',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    '36d0e251-c2cb-4f7e-8c79-d2ae45df7599', 'Gabriela', NULL, NULL, NULL, NULL, NULL, 'F',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    'a3b09779-e382-4e9b-b769-559a8959b3d6', 'Neide', NULL, NULL, NULL, NULL, NULL, 'F',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    '9b9e02ec-cced-4643-a830-d1c7d9057a64', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, 'F',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    '5fc9f0b4-bb35-473e-a445-f0d7eacf0185', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    'e10dec81-fb8d-42e2-8cc8-b488a9fa03e6', 'Deise', NULL, NULL, NULL, NULL, NULL, 'F',
    'dbb6bb31-295c-4584-b95f-699a1ca55cef', true, false, false, false, false,
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
    '49061166-5ee7-46aa-ad69-c830e8040bb9', 'Thiago Van Petten', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    'b33b9b1e-4817-4d06-8c51-b6a55293b79c', 'Nara', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '3740abe5-1fba-4a4b-a766-ead9e7b96e34', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '413d642a-2bef-4c76-8fc3-49d13b80a213', 'Augusto', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '4aa7949b-706d-4d0e-b2cb-3024503bb61c', 'Ismar', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    'ae42aed7-1e27-4999-9dd9-af3c31b28b7e', 'João Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '90131381-befd-4e28-a84c-df5e8cd3b2c9', 'Sara', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '095beade-90c3-4edc-82cb-dabf241e868e', 'Denise', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '49121378-c117-4140-9383-a70886756298', 'Madalena (Madá)', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '3831c6cd-b6db-42dd-acb1-f212b9116e8b', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '2a7e7b18-c2cb-4c75-a552-630d7b420abf', 'Tiago (Tiaguinho)', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '89e98fd2-ef60-4e14-a189-4296faf874f6', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    'f4ae810a-a538-4628-84ee-b081625f4e1c', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    'fec8cecd-1a12-47a6-9f39-5d8dd95d2066', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '318b2c39-07c1-4beb-bf9a-2464253c4c60', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    'b8a334d2-b79d-4079-8b72-596a2e9d7adb', 'Elisa', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    'd2611ef7-f80d-493c-9d81-d2d7d2cddd06', 'Mauro', NULL, NULL, NULL, NULL, NULL, 'M',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '9a472a03-3019-433a-a844-aab960d371a1', 'Marlene', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '9d973a73-9e76-4566-b46d-1efdc444f4e1', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '3322eaa1-2a5b-4419-b356-bbf9d9439789', true, false, false, false, false,
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
    '99969e7f-7eba-4b22-b80f-61ca77a97b1f', 'Jardir', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '9f7ef2d9-ab1d-44e0-b277-a1f4659cd464', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    'e918e722-10da-48b4-92bb-b243e560420a', 'Warlei', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '58ebe276-7a77-4b63-9dfb-0dfe71c1f3bf', 'Alba', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    'b6f75b58-ff57-47d5-9d53-7ee7617b57e7', 'Afrânio', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '77948d79-6a1e-4a9b-8ca1-7d1683c1e8ae', 'Helen', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '2defd892-a663-4a86-a58d-58b35c3fd551', 'Helena', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '118b6386-22c9-4aaf-beb4-52e1a95f7876', 'Kátia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '6756ac72-ae10-4d4c-8096-22df321bcd3c', 'Cassinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '282214d6-90e4-4d18-be4d-694e129e27f5', 'Clemência', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '6116ce1f-0907-4dfb-910e-6d6c1070844f', 'Bárbara', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '25137c7e-590c-4100-a9f0-a9e640aaf33d', 'Perpétua', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    'f7289dd0-da5f-4507-a29e-5ddd3cdc7590', 'Ágatha', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '7f4730cf-d90f-4115-a217-771ca5088818', 'Maria Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '921aac28-91ea-4a56-8078-3501d3d944ee', 'Claudinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    'b2bda8fe-9444-4780-bfcd-556c19d39d96', 'Saulo', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '80a73aff-0b63-47db-8f3e-748be9b6b3fa', 'Kioko', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '43fbc97b-b00b-4d14-94f5-7c2a37cfc060', 'Denise', NULL, NULL, NULL, NULL, NULL, 'F',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    'bdbcfac3-a4bc-4275-9cab-127a2326e653', 'Wellington Ferreira (Shibas)', NULL, NULL, NULL, NULL, NULL, 'M',
    '8a371e51-c2a3-4e06-bd53-4636c93a86ed', true, false, false, false, false,
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
    '2560ef21-cd4b-4bc0-9b6f-424d8ce63f32', 'Luiz Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '6cd9c6dd-091b-4458-be1b-649c9cfbf5dc', 'Charles Pascoal', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'a6e41747-32b3-4124-b6a8-08063bcf1362', 'Lorena de Freitas', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '86e27d3e-8314-406f-9cc3-4cd0f579c56b', 'Ana Raquel', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'd7dbbb9b-2ab7-4ca6-8b25-ecac282ef660', 'Davi Ribeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'b667ba62-263f-44d5-9cd2-1afbaf7bce8d', 'Jehanne', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '1cf73a9a-eb7d-4edf-a305-d4319ba65cb8', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'd42c9db9-abf2-40de-b820-ae8e02186c07', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '1342fab1-4218-44d8-b935-0c0b824e0f34', 'Tiago Ribeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'b8d744bf-242e-4c11-a7de-29a8e19236e4', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'e805b9ca-eaca-42a0-9a18-153be8c8d218', 'Lídia', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '17e8b845-f21e-4fb8-bce3-48b7e85d7297', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'ac4683a2-4a53-46f2-be91-8a06195a7a67', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'f57e52f9-0018-446a-9862-45fc2ee9adfc', 'Darlene', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '1bf910d5-e364-4f12-ad40-8133f208cc28', 'Davi de Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '986f57e1-6461-4afb-bef6-b5adbe9e3def', 'Jonatas', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '68b3e7f5-2706-4dda-8732-f863519dc42e', 'Marisa', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '96457c4e-0c26-4fd4-b9cc-3b85c2930dcb', 'Raphael', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '94f28d5c-67be-450e-b946-37149156fb40', 'Sophia', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'a3572e00-8fb9-496f-8d39-e2e39c35f314', 'Emerson Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '90ed5647-d80f-4994-a497-488663a76f6a', 'Caroline Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '544f14c2-d5cc-47dd-baa5-40ac7bdbafe7', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'b1bde40a-1169-4e84-a44c-c52ee6f42545', 'Tiago Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '8a319402-8ada-4a10-bbec-49bb860534af', 'Samuel Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '7a7829a1-d58d-4ce2-ba69-a62774218d81', 'Isabela Heleno', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    '7f75673e-fb65-42f9-bd94-05b5e467dbce', 'Ilia Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'a657daa7-e94d-48c3-a424-dbc8b4eaeca3', 'Glaydson José', NULL, NULL, NULL, NULL, NULL, 'M',
    '586db6a6-33c5-48bc-9e4a-17b464a4f428', true, false, false, false, false,
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
    'e12eba1f-e0b9-4e48-87a0-e4b6722f4f3b', 'Alexandre', NULL, NULL, NULL, NULL, NULL, 'M',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '412281ef-14cc-4bf5-8c8c-3a99801ac0c5', 'Érica', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '2b6c397c-0adf-4598-872b-60e2030bd0db', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    'a6ef5c5f-36be-45f4-a7b4-ac7e8f9f83ef', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '3e56fc68-c292-4638-9aae-7b9caad492ab', 'Heloísa', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    'd36ce245-1130-49a0-ac1e-e165e9edce0c', 'Tames', NULL, NULL, NULL, NULL, NULL, 'M',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    'e90f4120-ed2f-4388-9983-c669dc5ed409', 'Michelle', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '7e17132c-bb7d-4092-8bc2-4287069bda10', 'Helisa', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '9a8bd12f-e8ea-42b3-8114-6268cf77f9a9', 'Adelmo', NULL, NULL, NULL, NULL, NULL, 'M',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    'f55a0aab-53b9-448f-a57d-84f2eb9068f4', 'Júnia', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '9ab5963a-7c9f-44c9-bcd8-c1c743201b4e', 'Neuza', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '6dfbf707-82e9-4a95-829f-9daef9d5fc4c', 'Rosa', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    'bd688ad9-23df-474b-aac0-fc8e23ceae9e', 'Juan', NULL, NULL, NULL, NULL, NULL, 'M',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    'f7d55a4f-8e34-4cf0-81ce-b69e9c196e14', 'Ximena', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    'b0b888f8-eba9-4080-801d-00a42be835d2', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    'c332d75d-d325-4b23-bd70-be271f577f2a', 'Victória', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '218bb895-e627-4cd2-9838-597c68681e15', 'Antonella', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '66b84a63-a1c2-443a-b29c-5cc2767b6a3d', 'Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '0c57ff88-fdca-4ccb-a579-01eb98babac7', 'Silvana', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '7e992b77-d6b0-40bf-8b1b-6ce2e8957482', 'Emanuelle', NULL, NULL, NULL, NULL, NULL, 'F',
    'd2a8d8cf-217d-44c6-b171-a971ecb6f405', true, false, false, false, false,
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
    '2593d98a-bf0c-4ee9-bce6-396691bef474', 'Jairo', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '40f58745-8172-49b5-ad40-9adcdc0864d6', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '8a1c8af4-e054-45db-a8ca-14870409ee0d', 'Camila', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    'd696909f-cfcf-4bc3-ac80-af4828387550', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '8ae246e6-0b5d-4075-997c-7e6b6c9ca984', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '07505fcb-bbab-4c23-a738-4127501f402e', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '35df79d8-19ec-40b5-9985-4def6cfcf4ba', 'Emanuele', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '41520468-e8fc-4f30-8432-5bef0e656ba3', 'Geovana', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '95050668-c07e-43f4-9927-5aa3ee62d4b9', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    'e14d477f-7d43-4b78-8c59-309bb9e43c8e', 'Warley', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '4842d3df-262e-4f5f-a9e4-e94e264f8942', 'Deise', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    'c1881747-9f15-4bb3-90df-5b7540da365f', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    'ac0b9f71-629b-4624-a2fe-5b4ea4c87e87', 'Jetro', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '9b7e123e-8a4b-4cbf-b1ea-91018cc09710', 'Olício', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '59da7ad8-e573-43a6-b2b6-0cc612f75412', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '6ff366f4-e6d3-4212-bd49-f25a5228a488', 'Noah', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '31a63e84-70b9-4dcb-9d8d-745170332492', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '82923ff5-0618-43e3-b9f9-1543f681b4a6', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '05b2ac6e-5494-439a-93db-10e6eab77f8f', 'Jéssica', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '487fc304-5040-4e9f-810f-296ca99cbc2c', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    'd387d30a-45a6-425d-8be0-67726f688e9d', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '4a0fc86b-2ba3-4e0c-85ac-2a7db6466f1e', 'Emilly', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '12f716b7-67e9-4fbd-ba59-71acb7c2439f', 'José Maurício', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '8b16ce25-716a-4a75-8a20-92cbe5db7d86', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '9c244df9-0d28-4358-b9b3-7441579bacd6', 'Mizael', NULL, NULL, NULL, NULL, NULL, 'M',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '0d05ab02-1d57-49f8-b7a1-7ca7476a1e6c', 'Helen', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    '8fb44784-4976-4642-8845-bb0a17cb9fed', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    'd7fc8e71-5031-47c4-af71-adfd38623653', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '7a245029-b248-4fae-b8a1-555e3596985a', true, false, false, false, false,
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
    'd17bef0c-89e9-466d-9df4-6a18677aa0a3', 'William', NULL, NULL, NULL, NULL, NULL, 'M',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '8e6174b6-6d89-457e-b2d8-3f5988b0e829', 'Simara', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '9266f1dc-f06f-48b1-b47b-9fe4f5020955', 'Wenderson', NULL, NULL, NULL, NULL, NULL, 'M',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    'b9fcb867-cf5b-406a-a004-032d7aaaaca7', 'Renata', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '8e9dfb48-c747-4bc8-a72d-c696d7fa00c9', 'Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '2b3352f4-d8db-4322-a1b3-b16625e164b9', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '636c7fb2-7f99-43d0-80a6-f29da2a21526', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '46f49bc1-8ea4-478a-a6b7-25aa8ea8d637', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '83957f34-947c-417b-855a-9e9c98dee6b7', 'Bianca', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    'ae1fcbd9-3d73-4498-bac9-774b38e3d901', 'Gláucia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    'ba1c755d-4d4f-4032-b825-2a7647ad9c2e', 'Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    'd27fcaa9-e95b-4293-82e7-2fcf807a0d9a', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '7f847425-4ad3-46d5-bd70-faedda8adccd', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    'ba4a9672-3e50-461d-856e-af3b4d5dacd8', true, false, false, false, false,
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
    '7f6a897d-f307-4429-afdf-f50c86822fa1', 'Cléber', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '698c6074-257b-43b4-a379-45585b53de97', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '3c7ffa1c-ef8a-4d1e-8a45-713f6b3901e7', 'Camilla', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '619e54b6-6171-44f2-a081-1bdb77914858', 'Caio Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'cf1e668b-d5c6-4bfe-a4c8-c63cecdf3f3c', 'Marina', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'ee643bef-3d93-486f-be03-1ec6e30b9fa7', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'e898433b-71b2-495a-b778-88cffac37816', 'Simone', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '8fac9fa3-a045-4ac7-bcea-25800d44f69c', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '013ca4c2-23ec-4927-8870-33ff6a9e86f1', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '884cd615-51a4-466a-b34a-353ce7f54aaf', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'fb0d32fb-4fd4-483d-8c81-a5b0a800ecc2', 'Vanusa', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '3f756cdb-0c88-474c-961e-16d00943f790', 'Abner', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '5e780f3e-0a2b-4e61-8dc3-0b45f686d554', 'Fabiana', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'cabf2f97-704d-41ec-be3a-3d61ce65b308', 'Levi', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'a23d8852-44ab-45d8-8fc6-653e6675f14b', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'bd9d240d-1228-4c58-aec9-d9ce6d6dcd05', 'Nely', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'f55d4296-84d0-4b55-bb12-ab6c54da1119', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '69d31065-79d0-4ba4-8ff4-0e3e64ffc6d3', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '6ab35f69-d80e-4531-b8f7-4d2833f92c1b', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'bef040a4-97fc-41cc-8400-86caab8bc675', 'Lourdes', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '03283ddf-1330-468f-bb6d-8a9b5f9b6ede', 'Denim', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'be24d372-c67b-4814-84b5-dea54dca0c36', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '2d24c057-0315-4b10-8ad6-a4aae7b37821', 'Ismael', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '7a97bef5-e295-4445-bb5f-73b5cb909c8b', 'Isac', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '88e17c40-137a-445c-b6a0-73c95fc9738b', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'b889b208-60da-434b-b2b8-594d0e3cbf88', 'José Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '2304dc39-52dc-42ac-adce-166d89194071', 'Fagner', NULL, NULL, NULL, NULL, NULL, 'M',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '9e12aea8-fd5e-4e60-9ac8-951d2c4b33d7', 'Lauren', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '0d41964c-c6ce-4089-84a8-fcdfefe3dcb6', 'Rosângela', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    'e4eb4e0a-d5ac-433f-96c6-be9cd6a798f4', 'Suzi', NULL, NULL, NULL, NULL, NULL, 'F',
    '81eedfc8-0117-42b2-a349-d03eba6bee08', true, false, false, false, false,
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
    '92e26edd-467f-41f2-8fa7-438886aee0c4', 'Marilson', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'bb5c9636-55d4-4df0-92e4-3b8d60cfc829', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '37187d46-cba3-4c95-8bab-0f5f04a5fa01', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '16fc3cae-b943-4e46-8bec-d7f01baa4f31', 'Gilson', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '53fe2ad5-6b9a-4c61-88de-f5f3038679b2', 'Nislândia', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '1546262a-e85c-4567-8734-3d17756fabc1', 'Izabela', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'e5e842bf-4cfe-4219-977f-6e169ef6198f', 'Ana Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'af0b46b7-aa56-4935-90c4-fcc8f60f08a0', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'ffe90127-a721-4c5d-a767-0601449ab591', 'Wanderluz', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '927e05a8-c64b-497d-9cff-922bcb8adf92', 'Janete', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'bd5f67af-dd66-4767-9c80-3a2ba4c875ed', 'Eduarda', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '62d4667e-4a08-4256-989b-7a47c0c38aa5', 'Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '0b41474e-5a7c-41f9-8cac-2c94dbcb5b02', 'Dilvano', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'bfaf2255-9cea-451d-ba83-65873c2525f1', 'Edilene', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '0327b2c7-2b8c-4079-9203-4c9275ba120b', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '6504260b-9f34-4c87-b35f-331b555967cb', 'Josué', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '908d2ecc-65f7-4160-b782-30f6e0fe8559', 'Lorena', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'f35c8560-6530-4238-bc60-6f861fb8de96', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'a37f60bf-47c8-4aa0-9681-9502f1d9cf70', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'd4445397-62d1-4780-bceb-9cfdd30b99bf', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '6e63bfd5-5879-49a9-94cc-89ef65e53633', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'd3f1c692-16cd-4336-b357-4ee1191c26f7', 'Suely', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'fd388df9-b123-4c2d-b18a-7f2d869bcee9', 'Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '0b3d3917-9a4c-4f06-b6e5-2bf0442ed694', 'Talita', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'e8ff1aa2-e0fe-4dcf-9f30-e72a8b9c9dca', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '2b313e6c-35af-4309-9170-a485fabb45e8', 'Luciano', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '9b2e2647-6f18-4546-97e4-5c47ffb6805f', 'Joana', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '45576048-b424-4d53-9d88-e4308ac55741', 'Raíssa', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'f49e9970-5721-40e1-b48c-f3025cad65c3', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'c5ecb4b2-ef2d-465d-82c7-e860bc32c5e5', 'Abner', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '42812fa4-c163-44d6-a74c-dbc554a44e3b', 'Ranma', NULL, NULL, NULL, NULL, NULL, 'F',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '274d21ff-f182-4c57-8f95-8d06a31ac710', 'Jonata', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    '76c1c6be-fdff-4979-b3aa-f50caf0fe7a0', 'Isac', NULL, NULL, NULL, NULL, NULL, 'M',
    'a6ca0670-ea44-44a4-a415-1577eaafd0c1', true, false, false, false, false,
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
    'b9c372cd-0253-4162-8336-9a11ad7258cd', 'Artur Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'ed6abaed-ed59-42db-bb8e-64d26b8ea1c1', 'Thaís Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '2d41c797-1179-438b-ac94-8cc7f8a866ff', 'Isabela Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '272e1873-2ee9-404a-9d01-e1b572f4281e', 'Júlia Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'bbfaa8e8-781a-4b42-9fac-a37cd6c46542', 'Sofia Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'ceecba38-dbf1-4e71-9527-b75bca08248d', 'Douglas Macaúba', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'c735630e-4256-4ec4-a557-d74b25ff1564', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'f5499f30-0123-42b6-b744-f16c50722a76', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '311b2c8d-bd25-4bca-a569-257bcdf6583c', 'Thiago', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '8bb8d56e-6b43-4997-a4ac-053b78ca0a9b', 'Carine', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '62c7b3ef-9732-481c-aae3-37ec063ccb99', 'Melina', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '6557adf5-8e87-474e-8883-bf1fa0ae18f2', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'bbb8a195-549d-46d6-96cf-84a45ec4f5ae', 'Diego', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '7c47fad3-84c7-49b7-b56b-ea9e470ca582', 'Gisele', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '4c0c9695-0939-44f0-965f-cb25fd8bb7a0', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '7a083438-77fe-43ba-ae15-31811724e9b2', 'Graziele', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'fe6b60ae-114e-449e-933b-f057b41374b9', 'Imaculada', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'f433d75b-88a9-4602-91cc-8f6bb0f5ad72', 'Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'b521d801-f99a-4835-8b3e-a3625884da65', 'Vinícios', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'a37df668-d01b-41f9-a54d-d326f2a17d3f', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '6d950b31-7a4b-4803-8b3f-83dc82d48581', 'Ana Eloísa', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'b028ead5-8ecf-421e-ab7e-8675231fd1da', 'Maria Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '1309f57e-a4bd-440b-a7af-c982600700f2', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    'c36f9d58-e6ae-447a-b8ad-be60805d9fa7', 'Martim', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '1c2406c3-adf3-4d5b-956d-ff488006f0d4', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '2c1c06cc-2873-4657-b6ce-9bd49b285f3e', 'Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '6be3fa3c-b822-41ba-9d3e-ca0d6d6f924b', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '2ea8ebfc-4d46-430b-a4f5-58b4721d4d2f', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '894f2bf3-1164-4fcf-a510-1c163dc2b4d7', 'Isaque', NULL, NULL, NULL, NULL, NULL, 'M',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '0850a030-4329-4d72-8cb3-dc09df86c40d', 'Zélia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '11a8553c-65ac-478f-af3e-a99f61dfe645', 'Keila', NULL, NULL, NULL, NULL, NULL, 'F',
    'ff816d34-d01d-4b8f-abfb-ebba5de5f9be', true, false, false, false, false,
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
    '6bf0a643-6a4e-4599-8f3e-6784437768d0', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '3b257027-3160-4e0f-bc58-0b6aa5813ff9', 'Leila', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'd8b020f1-187a-4c54-8040-f0f6d1feaa46', 'Ivan', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '6891fe8e-3abb-471c-a02e-be10435a3301', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '462f996d-dbf5-471a-8cbb-db5e2144aa26', 'Eliel', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '2cf0d866-0648-4ceb-9004-ba32cdc093b3', 'Fabíola', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '6662b5c5-0b15-4a96-be3e-f94fc1393c59', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'e00093b5-0e0a-4562-8c58-990a77c29110', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '54cb5c5a-153a-4dc4-bb2b-64d3a979b158', 'Ramon', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '58e950e1-6ad8-40e7-89aa-8773d96bf0df', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '8132f25c-541d-415e-b0d8-08ac92337875', 'Ravi', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '9a9caf5f-4d30-4599-bc87-74c8cd7a7aec', 'Melissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'aac7b23c-9a35-41f4-815c-7a92d531f782', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '2f3a54eb-ecd1-481a-91a2-fa8523e226e5', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'ed18aea1-e564-4922-a92d-27ef56a5219e', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '84b3aca0-ef20-4436-aa64-082c92b5c60d', 'Antônio', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '2546a5f2-6c35-4de2-b940-8b959f4df61c', 'Jaqueline', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'cef591e9-7189-4929-aa28-e3509b2f1d5e', 'Verônica', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'fbb335cf-5808-4292-8c12-9657eefac316', 'Nileide', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'e788d9fe-04b1-4dd0-9ab0-09b3a2360ef1', 'Fábio', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '7418d54e-e2af-49dd-8c1f-413289b4671f', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '25f16537-4989-48ee-afb2-936ff389fbf1', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '83f17c9d-9955-4a25-8f48-ef5326a4fb2b', 'Suzana', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '537ef7da-9bfb-47c2-85c5-3dec6e748d1a', 'Lorena', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'abfd8fea-dbdd-4b3f-b6dd-bfa31b1fe93f', 'Asaph', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '7ec438d7-bd9f-4c18-ae9c-e785ca10a5bd', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'a5dbd7da-0387-44dd-9ec6-4a4e3dec3924', 'Tainara', NULL, NULL, NULL, NULL, NULL, 'F',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    '65e727a5-9e8a-4c8b-8e20-73f8d36a550b', 'Théo', NULL, NULL, NULL, NULL, NULL, 'M',
    'c122f72e-3a70-45fa-b29d-a8d730705b70', true, false, false, false, false,
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
    'fcba7dea-23cb-4da3-9d0b-e065b51b20f3', 'Cláudio Lopes', NULL, NULL, NULL, NULL, NULL, 'M',
    'fa04c60a-6a06-4d31-bbcc-533829613f1f', true, false, false, false, false,
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
    'cea68f7b-66ad-4c71-aa2f-c8a55a802249', 'Zulmira Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    'fa04c60a-6a06-4d31-bbcc-533829613f1f', true, false, false, false, false,
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
    '1cd47f96-3a56-4685-aad6-62edc8de8804', 'Cristina Barbosa', NULL, NULL, NULL, NULL, NULL, 'F',
    'fa04c60a-6a06-4d31-bbcc-533829613f1f', true, false, false, false, false,
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
    '30e75c10-5e13-4085-b84a-7410d4d90492', 'Ismênia Ferreira Rezende', NULL, NULL, NULL, NULL, NULL, 'F',
    'fa04c60a-6a06-4d31-bbcc-533829613f1f', true, false, false, false, false,
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
    '6aa9b43e-c138-4bc7-a76c-44bab723a3a5', 'Maria das Graças', NULL, NULL, NULL, NULL, NULL, 'F',
    'fa04c60a-6a06-4d31-bbcc-533829613f1f', true, false, false, false, false,
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
    'ce29b36b-bac6-49ba-bf63-72cebaa163cb', 'Samuel Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, 'M',
    'fa04c60a-6a06-4d31-bbcc-533829613f1f', true, false, false, false, false,
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
    'e1ed96e0-bd55-4bf2-82aa-23315c3f83aa', 'Kamila Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, 'F',
    'fa04c60a-6a06-4d31-bbcc-533829613f1f', true, false, false, false, false,
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
    'cda888cd-6996-4f6e-a1f0-a7d4eed04285', 'José Antônio', NULL, NULL, NULL, NULL, NULL, 'M',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    '88f729e3-7586-49e8-a7f5-ff8ac7bca5cb', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    '4e89d3dc-6c15-433c-9003-ec23404704c1', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    'd3062ce1-81b4-4795-a533-de12931f2320', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    '5dfd82d2-24d2-4362-b946-fea8a3120029', 'Uyara', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    '908e6a0e-6c72-4e5a-9813-cca396740cb2', 'Uyrlan', NULL, NULL, NULL, NULL, NULL, 'M',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    'b6692a55-d3ea-415e-a366-55754965a0af', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    '1023b947-a174-47d3-94c9-83da43276d79', 'Suzana', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    '2876eca3-511f-4ce1-bf54-e33cb81e8393', 'Welington', NULL, NULL, NULL, NULL, NULL, 'M',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    '020fab36-7f91-4da1-b9c7-cc0a6c86131d', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    'f95020cc-f8b9-4bb9-83f0-134e39a731a6', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    'c992d89f-9a6e-4592-8a11-4d432ec4b3ed', 'Ariane', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    'c037ee51-bdc5-4495-9ba2-f735467eda2f', 'Hebert', NULL, NULL, NULL, NULL, NULL, 'M',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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
    '94bd167e-c692-43bb-9083-413b723a3c46', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    'db96195d-e3ce-4095-b8a1-bafe0c5a21a5', true, false, false, false, false,
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

  UPDATE public.home_groups SET leader_1_id = '19ec4776-52dc-43c8-8c08-e272cc157732', leader_2_id = NULL WHERE id = 'b366e6bf-7874-49f6-b9e1-8db54a692033';
  UPDATE public.home_groups SET leader_1_id = '41538203-0a7e-426e-9f6e-176315fa44a5', leader_2_id = 'a6285c83-e760-4a9c-9c0d-364f54ebbdf0' WHERE id = '63938120-2da3-4289-b043-54453759b8d4';
  UPDATE public.home_groups SET leader_1_id = '46feee7e-f65c-4367-989d-d27a9a28c60f', leader_2_id = 'a1d267e0-60bc-4f79-b56c-de041d22f9b6' WHERE id = 'e30756e5-e290-4b4a-b615-3fc795b75a7e';
  UPDATE public.home_groups SET leader_1_id = 'deb039b9-2c43-4b85-a74a-a3d4886969a8', leader_2_id = NULL WHERE id = '167bcb15-3046-4f0a-b314-5190dba9b7fb';
  UPDATE public.home_groups SET leader_1_id = '51d8feb7-3c2f-48ec-b34d-4bcf12c0b903', leader_2_id = NULL WHERE id = '3347a7eb-d4de-494e-8be4-7b34a99aa203';
  UPDATE public.home_groups SET leader_1_id = '1a1cb155-63dc-48aa-be97-629e7f164085', leader_2_id = NULL WHERE id = 'b0bbefe0-256e-4cd3-98fe-254236c2b742';
  UPDATE public.home_groups SET leader_1_id = '6b86a8db-1d0f-4912-ae80-29200ade426b', leader_2_id = NULL WHERE id = '8cb6ba0d-7db2-40b2-b12e-54abb1fdda5a';
  UPDATE public.home_groups SET leader_1_id = 'f57ad015-e7c3-438a-9f12-db36c09a4335', leader_2_id = NULL WHERE id = 'ccdbd19e-c15b-47af-9415-57a1481c56aa';
  UPDATE public.home_groups SET leader_1_id = '089eb37a-3539-4603-9f28-1fdfc68d8787', leader_2_id = NULL WHERE id = 'cd47bc1a-e589-4890-b53d-e0f3f732d155';
  UPDATE public.home_groups SET leader_1_id = '2d34ce73-838d-4d99-90fa-e1893a87cdb1', leader_2_id = NULL WHERE id = '5ab6502a-ab7d-4da8-a2da-db3fe5c6e491';
  UPDATE public.home_groups SET leader_1_id = 'dd6a067d-0080-4f7e-bddc-cff252ae6682', leader_2_id = '1761642d-1189-4fe0-b79c-eafc71831e79' WHERE id = 'ad393be8-666a-4ad4-a48a-711217306577';
  UPDATE public.home_groups SET leader_1_id = 'd18c42bf-13f3-4db1-9a2c-4cb3a1824765', leader_2_id = '2805af4b-4afd-4694-846c-4f7a8dbc5f86' WHERE id = 'e6b4096f-e087-41cc-8c5e-d083980b13c4';
  UPDATE public.home_groups SET leader_1_id = 'aad4af3c-f8dd-46cd-92cd-6ae4620a28e3', leader_2_id = NULL WHERE id = 'adc03c88-e531-4494-8a68-ceef7762e4f7';
  UPDATE public.home_groups SET leader_1_id = '82f620bb-0d1c-4e61-8093-92d7ffed8d6e', leader_2_id = NULL WHERE id = 'fad1fef2-d71e-4783-b11e-8f26cb3faff6';
  UPDATE public.home_groups SET leader_1_id = 'ac596a22-212d-4e17-82de-97f07cf80528', leader_2_id = NULL WHERE id = 'b6cab6d6-a3a7-4739-a93e-ed674aed58df';
  UPDATE public.home_groups SET leader_1_id = '23657810-988d-4cc3-9e1b-1751ebbbdcd4', leader_2_id = '30b3bb90-624e-43ac-a2bb-2e02a95c9d4b' WHERE id = '09661dad-55e9-4d67-b9fd-6c1a983fa100';
  UPDATE public.home_groups SET leader_1_id = 'db93cb34-835d-4fe6-8e35-53621fd147e7', leader_2_id = '9ec0d723-674b-4224-bd42-d046f79d6910' WHERE id = '84bad7cb-be75-434f-b9d5-1a303aac4464';
  UPDATE public.home_groups SET leader_1_id = '81eed824-2776-4c5f-b12e-17febc2d8435', leader_2_id = '5bd5ed21-ce40-4633-adbf-f98469b1d98a' WHERE id = '3c098744-82ba-45e8-8090-a1f387bfaa97';
  UPDATE public.home_groups SET leader_1_id = '8843c203-2474-4a86-abb2-f795dd099fe3', leader_2_id = NULL WHERE id = '002a3ca8-197b-486f-b24e-d146480c6e72';
  UPDATE public.home_groups SET leader_1_id = '8b571057-7c94-4269-81a7-a6fb34dd1373', leader_2_id = NULL WHERE id = '08015614-b513-4bd1-86a3-c268609a6a3f';
  UPDATE public.home_groups SET leader_1_id = '7c8a73a8-ee9e-4100-a523-730a700be20f', leader_2_id = '085fd5cd-72d7-4435-aa37-050a5733b4f3' WHERE id = 'c2852ff1-bc44-463f-9dce-1774ebc16a8b';
  UPDATE public.home_groups SET leader_1_id = 'a4e32b83-b201-4c50-b72f-ae4738145c21', leader_2_id = NULL WHERE id = '454c813e-f396-4ba8-97eb-c8af1c44da78';
  UPDATE public.home_groups SET leader_1_id = '6a7a69f2-740b-45a7-8399-3db32c96ac8a', leader_2_id = NULL WHERE id = 'dbb6bb31-295c-4584-b95f-699a1ca55cef';
  UPDATE public.home_groups SET leader_1_id = 'ae42aed7-1e27-4999-9dd9-af3c31b28b7e', leader_2_id = '49061166-5ee7-46aa-ad69-c830e8040bb9' WHERE id = '3322eaa1-2a5b-4419-b356-bbf9d9439789';
  UPDATE public.home_groups SET leader_1_id = '99969e7f-7eba-4b22-b80f-61ca77a97b1f', leader_2_id = NULL WHERE id = '8a371e51-c2a3-4e06-bd53-4636c93a86ed';
  UPDATE public.home_groups SET leader_1_id = 'a3572e00-8fb9-496f-8d39-e2e39c35f314', leader_2_id = NULL WHERE id = '586db6a6-33c5-48bc-9e4a-17b464a4f428';
  UPDATE public.home_groups SET leader_1_id = 'bd688ad9-23df-474b-aac0-fc8e23ceae9e', leader_2_id = 'e12eba1f-e0b9-4e48-87a0-e4b6722f4f3b' WHERE id = 'd2a8d8cf-217d-44c6-b171-a971ecb6f405';
  UPDATE public.home_groups SET leader_1_id = '2593d98a-bf0c-4ee9-bce6-396691bef474', leader_2_id = NULL WHERE id = '7a245029-b248-4fae-b8a1-555e3596985a';
  UPDATE public.home_groups SET leader_1_id = 'd17bef0c-89e9-466d-9df4-6a18677aa0a3', leader_2_id = NULL WHERE id = 'ba4a9672-3e50-461d-856e-af3b4d5dacd8';
  UPDATE public.home_groups SET leader_1_id = '7f6a897d-f307-4429-afdf-f50c86822fa1', leader_2_id = '619e54b6-6171-44f2-a081-1bdb77914858' WHERE id = '81eedfc8-0117-42b2-a349-d03eba6bee08';
  UPDATE public.home_groups SET leader_1_id = '92e26edd-467f-41f2-8fa7-438886aee0c4', leader_2_id = NULL WHERE id = 'a6ca0670-ea44-44a4-a415-1577eaafd0c1';
  UPDATE public.home_groups SET leader_1_id = 'b9c372cd-0253-4162-8336-9a11ad7258cd', leader_2_id = NULL WHERE id = 'ff816d34-d01d-4b8f-abfb-ebba5de5f9be';
  UPDATE public.home_groups SET leader_1_id = '6bf0a643-6a4e-4599-8f3e-6784437768d0', leader_2_id = NULL WHERE id = 'c122f72e-3a70-45fa-b29d-a8d730705b70';
  UPDATE public.home_groups SET leader_1_id = 'fcba7dea-23cb-4da3-9d0b-e065b51b20f3', leader_2_id = NULL WHERE id = 'fa04c60a-6a06-4d31-bbcc-533829613f1f';
  UPDATE public.home_groups SET leader_1_id = 'cda888cd-6996-4f6e-a1f0-a7d4eed04285', leader_2_id = NULL WHERE id = 'db96195d-e3ce-4095-b8a1-bafe0c5a21a5';

  -- ==========================================================================
  -- 6. ATUALIZAR CASAMENTOS (spouse_id) E FILIAÇÃO (father_id, mother_id)
  -- ==========================================================================

  UPDATE public.profiles SET spouse_id = '2ee8740d-b1fe-4614-baf7-da870e0ac155' WHERE id = '19ec4776-52dc-43c8-8c08-e272cc157732';
  UPDATE public.profiles SET spouse_id = '19ec4776-52dc-43c8-8c08-e272cc157732' WHERE id = '2ee8740d-b1fe-4614-baf7-da870e0ac155';
  UPDATE public.profiles SET spouse_id = '1bc2068a-b1c1-4775-9a46-2437674461dc' WHERE id = 'b7b9a6a9-483c-4652-9ce5-5ee31e7e949a';
  UPDATE public.profiles SET spouse_id = 'b7b9a6a9-483c-4652-9ce5-5ee31e7e949a' WHERE id = '1bc2068a-b1c1-4775-9a46-2437674461dc';
  UPDATE public.profiles SET spouse_id = 'd46c69da-3468-4e73-8d78-c1a6a8a50924' WHERE id = 'bc3cc745-dcd0-4c79-b8a1-bde6e336b28f';
  UPDATE public.profiles SET spouse_id = 'bc3cc745-dcd0-4c79-b8a1-bde6e336b28f' WHERE id = 'd46c69da-3468-4e73-8d78-c1a6a8a50924';
  UPDATE public.profiles SET spouse_id = '8fb69cc8-44c0-46ac-be75-4568d2a0e3a6' WHERE id = 'cfefe8cc-f85e-4427-ad60-149ae73e1dad';
  UPDATE public.profiles SET spouse_id = 'cfefe8cc-f85e-4427-ad60-149ae73e1dad' WHERE id = '8fb69cc8-44c0-46ac-be75-4568d2a0e3a6';
  UPDATE public.profiles SET spouse_id = 'fe51e018-12b5-4ca2-9164-ade04b45ea55' WHERE id = '23bd5f9b-0dec-4888-bf3b-c6d78a74a8dc';
  UPDATE public.profiles SET spouse_id = '23bd5f9b-0dec-4888-bf3b-c6d78a74a8dc' WHERE id = 'fe51e018-12b5-4ca2-9164-ade04b45ea55';
  UPDATE public.profiles SET spouse_id = 'c9451d88-3d0b-4366-9dee-49bf4b1a665c' WHERE id = '5862029e-8e82-439b-a8e8-a45b3f954987';
  UPDATE public.profiles SET spouse_id = '5862029e-8e82-439b-a8e8-a45b3f954987' WHERE id = 'c9451d88-3d0b-4366-9dee-49bf4b1a665c';
  UPDATE public.profiles SET spouse_id = 'b79deef6-8e02-4da3-8996-4a68d349a5f6' WHERE id = '87ccf9ea-c9af-475b-8d80-2fe92f9b5c8c';
  UPDATE public.profiles SET spouse_id = '87ccf9ea-c9af-475b-8d80-2fe92f9b5c8c' WHERE id = 'b79deef6-8e02-4da3-8996-4a68d349a5f6';
  UPDATE public.profiles SET spouse_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = '41538203-0a7e-426e-9f6e-176315fa44a5';
  UPDATE public.profiles SET spouse_id = '41538203-0a7e-426e-9f6e-176315fa44a5' WHERE id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb';
  UPDATE public.profiles SET spouse_id = '679737de-e2ed-4c93-b0f9-61172109ec1a' WHERE id = '1996717f-e08a-44e3-9b6f-7c44aaf8fe9a';
  UPDATE public.profiles SET spouse_id = '1996717f-e08a-44e3-9b6f-7c44aaf8fe9a' WHERE id = '679737de-e2ed-4c93-b0f9-61172109ec1a';
  UPDATE public.profiles SET spouse_id = 'c53698e8-a13d-48a6-9f01-218732f58b3a' WHERE id = '1dce335d-9640-4178-8675-8a35bcef33f3';
  UPDATE public.profiles SET spouse_id = '1dce335d-9640-4178-8675-8a35bcef33f3' WHERE id = 'c53698e8-a13d-48a6-9f01-218732f58b3a';
  UPDATE public.profiles SET spouse_id = '1d94db5d-33e8-47c8-b74b-89c3baf318af' WHERE id = '284c583e-eeb5-4896-94c9-4ecfe43ba1bf';
  UPDATE public.profiles SET spouse_id = '284c583e-eeb5-4896-94c9-4ecfe43ba1bf' WHERE id = '1d94db5d-33e8-47c8-b74b-89c3baf318af';
  UPDATE public.profiles SET spouse_id = '9996439c-760a-4ee1-9278-26091fb1988f' WHERE id = '831e59c6-147c-4042-a81c-bc3f19f6ea36';
  UPDATE public.profiles SET spouse_id = '831e59c6-147c-4042-a81c-bc3f19f6ea36' WHERE id = '9996439c-760a-4ee1-9278-26091fb1988f';
  UPDATE public.profiles SET spouse_id = '1a803e04-1fc7-460e-b5bc-1b8d294dec66' WHERE id = '4156a63d-cfd6-443f-8f75-94a85a73bc40';
  UPDATE public.profiles SET spouse_id = '4156a63d-cfd6-443f-8f75-94a85a73bc40' WHERE id = '1a803e04-1fc7-460e-b5bc-1b8d294dec66';
  UPDATE public.profiles SET spouse_id = '47a23238-4217-468e-ab65-fabf7a365838' WHERE id = 'a6285c83-e760-4a9c-9c0d-364f54ebbdf0';
  UPDATE public.profiles SET spouse_id = 'a6285c83-e760-4a9c-9c0d-364f54ebbdf0' WHERE id = '47a23238-4217-468e-ab65-fabf7a365838';
  UPDATE public.profiles SET spouse_id = '4effb9f2-0cff-4fa4-ac68-49a93c2628fa' WHERE id = '48410ac0-1787-4c7e-a6e7-4e6806642850';
  UPDATE public.profiles SET spouse_id = '48410ac0-1787-4c7e-a6e7-4e6806642850' WHERE id = '4effb9f2-0cff-4fa4-ac68-49a93c2628fa';
  UPDATE public.profiles SET spouse_id = 'fb825f48-ceee-4081-85e4-6dd94bca5a50' WHERE id = 'a72d4939-2969-45b4-9e45-a4247325519b';
  UPDATE public.profiles SET spouse_id = 'a72d4939-2969-45b4-9e45-a4247325519b' WHERE id = 'fb825f48-ceee-4081-85e4-6dd94bca5a50';
  UPDATE public.profiles SET spouse_id = 'ce3ad9d1-0ae8-4940-9b51-2519e39e712c' WHERE id = '4db2d7d9-a30f-44c6-8615-a3f64bee5c01';
  UPDATE public.profiles SET spouse_id = '4db2d7d9-a30f-44c6-8615-a3f64bee5c01' WHERE id = 'ce3ad9d1-0ae8-4940-9b51-2519e39e712c';
  UPDATE public.profiles SET spouse_id = 'eb53ac6a-789b-412b-aba3-e86e8a4566db' WHERE id = '91ca2fe2-9032-4d9c-a4c6-7969b4197f0f';
  UPDATE public.profiles SET spouse_id = '91ca2fe2-9032-4d9c-a4c6-7969b4197f0f' WHERE id = 'eb53ac6a-789b-412b-aba3-e86e8a4566db';
  UPDATE public.profiles SET spouse_id = 'ac1fdb69-a924-4214-9205-52be933cdd77' WHERE id = '7ac247cc-b99a-43b4-b54b-8fadf2432dee';
  UPDATE public.profiles SET spouse_id = '7ac247cc-b99a-43b4-b54b-8fadf2432dee' WHERE id = 'ac1fdb69-a924-4214-9205-52be933cdd77';
  UPDATE public.profiles SET spouse_id = '1e7d0844-9b45-4144-8f6a-47e5eded8daa' WHERE id = 'a1d267e0-60bc-4f79-b56c-de041d22f9b6';
  UPDATE public.profiles SET spouse_id = 'a1d267e0-60bc-4f79-b56c-de041d22f9b6' WHERE id = '1e7d0844-9b45-4144-8f6a-47e5eded8daa';
  UPDATE public.profiles SET spouse_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = '46feee7e-f65c-4367-989d-d27a9a28c60f';
  UPDATE public.profiles SET spouse_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = '46a2f154-615b-4f58-974e-332e17d3f528';
  UPDATE public.profiles SET spouse_id = '7d4694d8-84c5-4a1f-9ab4-f8e148296d02' WHERE id = 'fcf6ad83-5564-407a-a912-1d58481f6369';
  UPDATE public.profiles SET spouse_id = 'fcf6ad83-5564-407a-a912-1d58481f6369' WHERE id = '7d4694d8-84c5-4a1f-9ab4-f8e148296d02';
  UPDATE public.profiles SET spouse_id = '58ad8446-19dd-4099-bb89-5c27a099aacc' WHERE id = '07ddb69d-a9f8-4284-8ab6-54d2409fda68';
  UPDATE public.profiles SET spouse_id = '07ddb69d-a9f8-4284-8ab6-54d2409fda68' WHERE id = '58ad8446-19dd-4099-bb89-5c27a099aacc';
  UPDATE public.profiles SET spouse_id = 'fa88c3be-f2b6-4547-8af5-01c2104cdc53' WHERE id = '27065ca5-f568-4eac-b77a-7a8de42baa75';
  UPDATE public.profiles SET spouse_id = '27065ca5-f568-4eac-b77a-7a8de42baa75' WHERE id = 'fa88c3be-f2b6-4547-8af5-01c2104cdc53';
  UPDATE public.profiles SET spouse_id = 'ea84cd9e-0fb3-41d2-ab96-c9543ff1c59e' WHERE id = 'dbc8c225-9ea2-4c3d-a5e4-e4c55a92dc56';
  UPDATE public.profiles SET spouse_id = 'dbc8c225-9ea2-4c3d-a5e4-e4c55a92dc56' WHERE id = 'ea84cd9e-0fb3-41d2-ab96-c9543ff1c59e';
  UPDATE public.profiles SET spouse_id = '364de290-003a-4eb6-b113-af145a2c2734' WHERE id = 'd8896391-af7e-4956-9c68-2eb4fc530398';
  UPDATE public.profiles SET spouse_id = 'd8896391-af7e-4956-9c68-2eb4fc530398' WHERE id = '364de290-003a-4eb6-b113-af145a2c2734';
  UPDATE public.profiles SET spouse_id = '1ba39a4d-451d-450f-8338-69cfb187defd' WHERE id = '8c776d66-666f-4f16-94b1-772ec6dbd3a5';
  UPDATE public.profiles SET spouse_id = '8c776d66-666f-4f16-94b1-772ec6dbd3a5' WHERE id = '1ba39a4d-451d-450f-8338-69cfb187defd';
  UPDATE public.profiles SET spouse_id = 'da9efe8a-2833-40d3-a43d-0143dc822d90' WHERE id = 'deb039b9-2c43-4b85-a74a-a3d4886969a8';
  UPDATE public.profiles SET spouse_id = 'deb039b9-2c43-4b85-a74a-a3d4886969a8' WHERE id = 'da9efe8a-2833-40d3-a43d-0143dc822d90';
  UPDATE public.profiles SET spouse_id = '7e006f19-2157-49d2-9281-fbd612b85730' WHERE id = 'fa76f2d1-ddf1-4f9b-930b-78716a3f9eec';
  UPDATE public.profiles SET spouse_id = 'fa76f2d1-ddf1-4f9b-930b-78716a3f9eec' WHERE id = '7e006f19-2157-49d2-9281-fbd612b85730';
  UPDATE public.profiles SET spouse_id = '1f11629a-6d93-402d-ac55-5ee99afea65a' WHERE id = '3cce93d3-8d87-4935-867c-cd4ca496d75c';
  UPDATE public.profiles SET spouse_id = '3cce93d3-8d87-4935-867c-cd4ca496d75c' WHERE id = '1f11629a-6d93-402d-ac55-5ee99afea65a';
  UPDATE public.profiles SET spouse_id = '9394181d-3464-408d-a3bd-bb935dbe3b32' WHERE id = '8976bfcd-ce49-4c0c-b03f-d8f8d6d2aeb8';
  UPDATE public.profiles SET spouse_id = '8976bfcd-ce49-4c0c-b03f-d8f8d6d2aeb8' WHERE id = '9394181d-3464-408d-a3bd-bb935dbe3b32';
  UPDATE public.profiles SET spouse_id = 'ae582e8f-fece-45ed-b752-3460084f0213' WHERE id = 'c5a32184-3d3e-455b-a177-c1ccf55f0511';
  UPDATE public.profiles SET spouse_id = 'c5a32184-3d3e-455b-a177-c1ccf55f0511' WHERE id = 'ae582e8f-fece-45ed-b752-3460084f0213';
  UPDATE public.profiles SET spouse_id = 'e7b36a58-1821-4656-877b-41b87727603c' WHERE id = '702dfacb-7739-4b6a-bce8-84b1d0a14f0f';
  UPDATE public.profiles SET spouse_id = '702dfacb-7739-4b6a-bce8-84b1d0a14f0f' WHERE id = 'e7b36a58-1821-4656-877b-41b87727603c';
  UPDATE public.profiles SET spouse_id = 'adca2ec6-fd09-486d-bd25-8a5b4bcaf02d' WHERE id = '25c6bce5-0268-4b7b-8a5a-56a672f2afd4';
  UPDATE public.profiles SET spouse_id = '25c6bce5-0268-4b7b-8a5a-56a672f2afd4' WHERE id = 'adca2ec6-fd09-486d-bd25-8a5b4bcaf02d';
  UPDATE public.profiles SET spouse_id = '08c3f7e2-c9df-40fa-babb-ba557cc5010c' WHERE id = '7bfbc39c-a734-4e15-9d6a-edecf30c4cfa';
  UPDATE public.profiles SET spouse_id = '7bfbc39c-a734-4e15-9d6a-edecf30c4cfa' WHERE id = '08c3f7e2-c9df-40fa-babb-ba557cc5010c';
  UPDATE public.profiles SET spouse_id = 'bd7c7442-5fd8-4c00-bcd3-aecb129ab6c5' WHERE id = '51d8feb7-3c2f-48ec-b34d-4bcf12c0b903';
  UPDATE public.profiles SET spouse_id = '51d8feb7-3c2f-48ec-b34d-4bcf12c0b903' WHERE id = 'bd7c7442-5fd8-4c00-bcd3-aecb129ab6c5';
  UPDATE public.profiles SET spouse_id = 'e722fd77-ec0b-4545-bde5-444e71101dfd' WHERE id = '125e543a-302f-433b-be68-a09e63c507a9';
  UPDATE public.profiles SET spouse_id = '125e543a-302f-433b-be68-a09e63c507a9' WHERE id = 'e722fd77-ec0b-4545-bde5-444e71101dfd';
  UPDATE public.profiles SET spouse_id = 'd7328036-ca54-4e76-94de-ab6165728b8c' WHERE id = '2d0dc693-7089-4ace-9484-a67442012d7d';
  UPDATE public.profiles SET spouse_id = '2d0dc693-7089-4ace-9484-a67442012d7d' WHERE id = 'd7328036-ca54-4e76-94de-ab6165728b8c';
  UPDATE public.profiles SET spouse_id = '642fc83d-6711-47e5-a177-6601936cbba1' WHERE id = '2139cc2a-b8fb-432b-b0d4-da50222acc48';
  UPDATE public.profiles SET spouse_id = '2139cc2a-b8fb-432b-b0d4-da50222acc48' WHERE id = '642fc83d-6711-47e5-a177-6601936cbba1';
  UPDATE public.profiles SET spouse_id = 'ed10e654-ace7-49ad-a1a5-493443dfa681' WHERE id = '879960b8-e1f7-469d-b510-2f639c3d621c';
  UPDATE public.profiles SET spouse_id = '879960b8-e1f7-469d-b510-2f639c3d621c' WHERE id = 'ed10e654-ace7-49ad-a1a5-493443dfa681';
  UPDATE public.profiles SET spouse_id = 'dc2fe539-c283-4a93-9c35-88809f4dbddc' WHERE id = '1a1cb155-63dc-48aa-be97-629e7f164085';
  UPDATE public.profiles SET spouse_id = '1a1cb155-63dc-48aa-be97-629e7f164085' WHERE id = 'dc2fe539-c283-4a93-9c35-88809f4dbddc';
  UPDATE public.profiles SET spouse_id = '4be2bee7-f6ab-4ff3-aa01-d8b4139e6b1e' WHERE id = 'f43aae06-e095-4d2e-bb57-442e4f068c93';
  UPDATE public.profiles SET spouse_id = 'f43aae06-e095-4d2e-bb57-442e4f068c93' WHERE id = '4be2bee7-f6ab-4ff3-aa01-d8b4139e6b1e';
  UPDATE public.profiles SET spouse_id = 'b5e2d682-430c-49f1-87b7-4260c4275e09' WHERE id = '31e6b766-d663-4b16-b4a7-89a6398035ba';
  UPDATE public.profiles SET spouse_id = '31e6b766-d663-4b16-b4a7-89a6398035ba' WHERE id = 'b5e2d682-430c-49f1-87b7-4260c4275e09';
  UPDATE public.profiles SET spouse_id = '7b31ef9f-ffe4-4394-af3f-da7738c4ebce' WHERE id = '52db34c2-0a5a-4959-b6a0-3d02bee1a6cd';
  UPDATE public.profiles SET spouse_id = '52db34c2-0a5a-4959-b6a0-3d02bee1a6cd' WHERE id = '7b31ef9f-ffe4-4394-af3f-da7738c4ebce';
  UPDATE public.profiles SET spouse_id = '047e97f9-2410-49aa-b71f-a03d60b2018c' WHERE id = '2ec480e4-4dcd-4ecf-9a9c-b4286b1a7bc0';
  UPDATE public.profiles SET spouse_id = '2ec480e4-4dcd-4ecf-9a9c-b4286b1a7bc0' WHERE id = '047e97f9-2410-49aa-b71f-a03d60b2018c';
  UPDATE public.profiles SET spouse_id = '40a0515b-0a57-49e7-af3e-8ecee4111ccb' WHERE id = '6b86a8db-1d0f-4912-ae80-29200ade426b';
  UPDATE public.profiles SET spouse_id = '6b86a8db-1d0f-4912-ae80-29200ade426b' WHERE id = '40a0515b-0a57-49e7-af3e-8ecee4111ccb';
  UPDATE public.profiles SET spouse_id = '039fbf33-f317-48e5-8e0d-936db31d9160' WHERE id = '1a356435-f1e5-4182-92c9-9fd264cb6eff';
  UPDATE public.profiles SET spouse_id = '1a356435-f1e5-4182-92c9-9fd264cb6eff' WHERE id = '039fbf33-f317-48e5-8e0d-936db31d9160';
  UPDATE public.profiles SET spouse_id = '6d2cc23c-fba4-47e9-83ac-a621040cecc5' WHERE id = '0867a620-f94b-4f40-bd61-953032e28ec0';
  UPDATE public.profiles SET spouse_id = '0867a620-f94b-4f40-bd61-953032e28ec0' WHERE id = '6d2cc23c-fba4-47e9-83ac-a621040cecc5';
  UPDATE public.profiles SET spouse_id = '33765832-7f7c-4222-9e37-a9d9934cc6af' WHERE id = '1b2fc3d7-126f-45ba-83b1-afa799634795';
  UPDATE public.profiles SET spouse_id = '1b2fc3d7-126f-45ba-83b1-afa799634795' WHERE id = '33765832-7f7c-4222-9e37-a9d9934cc6af';
  UPDATE public.profiles SET spouse_id = '2e9695b2-f370-49f3-90be-6c37215f10b6' WHERE id = 'bc417f2e-81fa-473c-94d1-76d564d4305f';
  UPDATE public.profiles SET spouse_id = 'bc417f2e-81fa-473c-94d1-76d564d4305f' WHERE id = '2e9695b2-f370-49f3-90be-6c37215f10b6';
  UPDATE public.profiles SET spouse_id = '612d29d8-f49d-4e39-a109-673bf53aa47f' WHERE id = 'f57ad015-e7c3-438a-9f12-db36c09a4335';
  UPDATE public.profiles SET spouse_id = 'f57ad015-e7c3-438a-9f12-db36c09a4335' WHERE id = '612d29d8-f49d-4e39-a109-673bf53aa47f';
  UPDATE public.profiles SET spouse_id = 'f7eea24c-008a-41dd-9932-6503c9b9f7b3' WHERE id = 'bb54e705-da5d-49f6-9810-4a1b6e45fd4a';
  UPDATE public.profiles SET spouse_id = 'bb54e705-da5d-49f6-9810-4a1b6e45fd4a' WHERE id = 'f7eea24c-008a-41dd-9932-6503c9b9f7b3';
  UPDATE public.profiles SET spouse_id = '14897482-dd97-4401-82d1-ba8e0b9ed06d' WHERE id = 'b51a6cfe-82cc-46e0-b163-256680d98407';
  UPDATE public.profiles SET spouse_id = 'b51a6cfe-82cc-46e0-b163-256680d98407' WHERE id = '14897482-dd97-4401-82d1-ba8e0b9ed06d';
  UPDATE public.profiles SET spouse_id = '0dd7e454-0797-491c-8fe3-3475b659065c' WHERE id = 'd92eb4ed-858b-4c09-ae09-3306f30f63fd';
  UPDATE public.profiles SET spouse_id = 'd92eb4ed-858b-4c09-ae09-3306f30f63fd' WHERE id = '0dd7e454-0797-491c-8fe3-3475b659065c';
  UPDATE public.profiles SET spouse_id = '6de44343-a9d4-4c3a-b5a7-398ed6e5fcaf' WHERE id = 'cda61385-c64a-463a-9ce6-31eef0d3ab34';
  UPDATE public.profiles SET spouse_id = 'cda61385-c64a-463a-9ce6-31eef0d3ab34' WHERE id = '6de44343-a9d4-4c3a-b5a7-398ed6e5fcaf';
  UPDATE public.profiles SET spouse_id = 'b2264eb8-2acc-45fc-8683-6f5eb5e6543d' WHERE id = 'a31da5a4-deec-4d5c-b792-d528bcf4f10c';
  UPDATE public.profiles SET spouse_id = 'a31da5a4-deec-4d5c-b792-d528bcf4f10c' WHERE id = 'b2264eb8-2acc-45fc-8683-6f5eb5e6543d';
  UPDATE public.profiles SET spouse_id = '5c140d14-54e9-4f14-b3ba-676d0d9a4fb3' WHERE id = '14259a65-cac5-4ef0-8e66-f1fac5cc8770';
  UPDATE public.profiles SET spouse_id = '14259a65-cac5-4ef0-8e66-f1fac5cc8770' WHERE id = '5c140d14-54e9-4f14-b3ba-676d0d9a4fb3';
  UPDATE public.profiles SET spouse_id = 'bed3384b-b1cc-4c02-a002-6214c87b050b' WHERE id = '40fffba6-b4fd-4fe7-b10b-95ccccf3776b';
  UPDATE public.profiles SET spouse_id = '40fffba6-b4fd-4fe7-b10b-95ccccf3776b' WHERE id = 'bed3384b-b1cc-4c02-a002-6214c87b050b';
  UPDATE public.profiles SET spouse_id = '80b7b173-3745-430a-bd84-80bec9ada5f8' WHERE id = '625835a3-2962-45c1-9971-7d369cf17589';
  UPDATE public.profiles SET spouse_id = '625835a3-2962-45c1-9971-7d369cf17589' WHERE id = '80b7b173-3745-430a-bd84-80bec9ada5f8';
  UPDATE public.profiles SET spouse_id = 'e42cecff-79c7-4c65-a4ba-44a08c50571a' WHERE id = '089eb37a-3539-4603-9f28-1fdfc68d8787';
  UPDATE public.profiles SET spouse_id = '089eb37a-3539-4603-9f28-1fdfc68d8787' WHERE id = 'e42cecff-79c7-4c65-a4ba-44a08c50571a';
  UPDATE public.profiles SET spouse_id = '6f3a51d6-af0d-456a-8227-4b82351bc7ed' WHERE id = 'e1bb5bee-f50b-4fd2-b81b-9358977cfd20';
  UPDATE public.profiles SET spouse_id = 'e1bb5bee-f50b-4fd2-b81b-9358977cfd20' WHERE id = '6f3a51d6-af0d-456a-8227-4b82351bc7ed';
  UPDATE public.profiles SET spouse_id = '69f162e6-04dd-4c01-ae32-480a7303db7c' WHERE id = '0a9096c0-86cb-4372-bd1b-ea8f5dee3d57';
  UPDATE public.profiles SET spouse_id = '0a9096c0-86cb-4372-bd1b-ea8f5dee3d57' WHERE id = '69f162e6-04dd-4c01-ae32-480a7303db7c';
  UPDATE public.profiles SET spouse_id = 'd9d1717b-bab3-47ee-89fc-c35482d78999' WHERE id = '71f43006-bb6e-440d-bb1a-2209585f1431';
  UPDATE public.profiles SET spouse_id = '71f43006-bb6e-440d-bb1a-2209585f1431' WHERE id = 'd9d1717b-bab3-47ee-89fc-c35482d78999';
  UPDATE public.profiles SET spouse_id = 'a7583aa9-6991-4796-a3f9-38b34c58ce6d' WHERE id = '6dc72ec1-1e88-44ee-96b1-569b6a06e931';
  UPDATE public.profiles SET spouse_id = '6dc72ec1-1e88-44ee-96b1-569b6a06e931' WHERE id = 'a7583aa9-6991-4796-a3f9-38b34c58ce6d';
  UPDATE public.profiles SET spouse_id = '775e0a4b-70a0-494f-b29b-3aad35c558c5' WHERE id = '68614af5-bb97-4eb4-a806-83b6b4c45379';
  UPDATE public.profiles SET spouse_id = '68614af5-bb97-4eb4-a806-83b6b4c45379' WHERE id = '775e0a4b-70a0-494f-b29b-3aad35c558c5';
  UPDATE public.profiles SET spouse_id = 'a2ec4427-e18b-4cdf-ac52-13b2e029ed11' WHERE id = '2d34ce73-838d-4d99-90fa-e1893a87cdb1';
  UPDATE public.profiles SET spouse_id = '2d34ce73-838d-4d99-90fa-e1893a87cdb1' WHERE id = 'a2ec4427-e18b-4cdf-ac52-13b2e029ed11';
  UPDATE public.profiles SET spouse_id = '474c1aae-45b4-4128-a1f7-8c0b9bf2a3ce' WHERE id = 'd2089a49-259e-4892-9a84-fbcb7e915f9e';
  UPDATE public.profiles SET spouse_id = 'd2089a49-259e-4892-9a84-fbcb7e915f9e' WHERE id = '474c1aae-45b4-4128-a1f7-8c0b9bf2a3ce';
  UPDATE public.profiles SET spouse_id = '6d08ebb9-54c6-46cb-bed2-90e56d34ed6c' WHERE id = 'bdec47df-9b01-4517-837d-bb645f9381df';
  UPDATE public.profiles SET spouse_id = 'bdec47df-9b01-4517-837d-bb645f9381df' WHERE id = '6d08ebb9-54c6-46cb-bed2-90e56d34ed6c';
  UPDATE public.profiles SET spouse_id = '360c341a-3bf4-4314-b55b-f74d3b59e1f3' WHERE id = 'de0db994-0506-4e43-b721-141f1d8bdb48';
  UPDATE public.profiles SET spouse_id = 'de0db994-0506-4e43-b721-141f1d8bdb48' WHERE id = '360c341a-3bf4-4314-b55b-f74d3b59e1f3';
  UPDATE public.profiles SET spouse_id = 'edc19318-a69b-4db3-a2e2-7c9b2932d654' WHERE id = 'b16e6ebe-42d3-4e27-9ff1-254bba818ee0';
  UPDATE public.profiles SET spouse_id = 'b16e6ebe-42d3-4e27-9ff1-254bba818ee0' WHERE id = 'edc19318-a69b-4db3-a2e2-7c9b2932d654';
  UPDATE public.profiles SET spouse_id = '88bb1d75-c78d-4e78-9350-2e83c1da8c53' WHERE id = '5655e0b9-1480-4450-a22e-a8f643342549';
  UPDATE public.profiles SET spouse_id = '5655e0b9-1480-4450-a22e-a8f643342549' WHERE id = '88bb1d75-c78d-4e78-9350-2e83c1da8c53';
  UPDATE public.profiles SET spouse_id = '0d371dcc-40d7-4e2f-9de5-8922139c8b92' WHERE id = '1761642d-1189-4fe0-b79c-eafc71831e79';
  UPDATE public.profiles SET spouse_id = '1761642d-1189-4fe0-b79c-eafc71831e79' WHERE id = '0d371dcc-40d7-4e2f-9de5-8922139c8b92';
  UPDATE public.profiles SET spouse_id = 'c0b8d474-507e-4b27-bac5-ccacaa05fa73' WHERE id = 'dd6a067d-0080-4f7e-bddc-cff252ae6682';
  UPDATE public.profiles SET spouse_id = 'dd6a067d-0080-4f7e-bddc-cff252ae6682' WHERE id = 'c0b8d474-507e-4b27-bac5-ccacaa05fa73';
  UPDATE public.profiles SET spouse_id = '70c49972-7aad-4029-9b20-74076b37f028' WHERE id = '744ca85f-dba9-4219-acb5-fcfaf1f5978c';
  UPDATE public.profiles SET spouse_id = '744ca85f-dba9-4219-acb5-fcfaf1f5978c' WHERE id = '70c49972-7aad-4029-9b20-74076b37f028';
  UPDATE public.profiles SET spouse_id = '0481c99b-14b4-4920-95f7-311da08dbbe7' WHERE id = 'a51c8e32-cd17-466d-999f-117f5a13981c';
  UPDATE public.profiles SET spouse_id = 'a51c8e32-cd17-466d-999f-117f5a13981c' WHERE id = '0481c99b-14b4-4920-95f7-311da08dbbe7';
  UPDATE public.profiles SET spouse_id = '19b30595-09ac-4f93-894a-1ceedef35175' WHERE id = '13c6339c-9465-4a0f-8ca0-0f4f0831b509';
  UPDATE public.profiles SET spouse_id = '13c6339c-9465-4a0f-8ca0-0f4f0831b509' WHERE id = '19b30595-09ac-4f93-894a-1ceedef35175';
  UPDATE public.profiles SET spouse_id = '4752f70f-7d70-4ca7-857f-409f227f754f' WHERE id = 'da8bea45-51f1-48d1-99b2-942db494f2bb';
  UPDATE public.profiles SET spouse_id = 'da8bea45-51f1-48d1-99b2-942db494f2bb' WHERE id = '4752f70f-7d70-4ca7-857f-409f227f754f';
  UPDATE public.profiles SET spouse_id = 'd3c6d8cd-fc9b-472d-b021-45faf880b98d' WHERE id = 'aba43f40-f39a-491f-a092-6d2f5ea99604';
  UPDATE public.profiles SET spouse_id = 'aba43f40-f39a-491f-a092-6d2f5ea99604' WHERE id = 'd3c6d8cd-fc9b-472d-b021-45faf880b98d';
  UPDATE public.profiles SET spouse_id = 'd64395ae-9107-4a15-b6be-c339264d6f3e' WHERE id = '00f4778b-c13f-443b-8f3b-d0b094875c04';
  UPDATE public.profiles SET spouse_id = '00f4778b-c13f-443b-8f3b-d0b094875c04' WHERE id = 'd64395ae-9107-4a15-b6be-c339264d6f3e';
  UPDATE public.profiles SET spouse_id = '1273ca07-f66e-4498-b69d-6314956f1dcc' WHERE id = '9438c0a2-be20-4658-b485-3c2b33bb472d';
  UPDATE public.profiles SET spouse_id = '9438c0a2-be20-4658-b485-3c2b33bb472d' WHERE id = '1273ca07-f66e-4498-b69d-6314956f1dcc';
  UPDATE public.profiles SET spouse_id = 'fd7421dc-e24d-4ab1-8e2e-523534d30e36' WHERE id = 'd18c42bf-13f3-4db1-9a2c-4cb3a1824765';
  UPDATE public.profiles SET spouse_id = 'd18c42bf-13f3-4db1-9a2c-4cb3a1824765' WHERE id = 'fd7421dc-e24d-4ab1-8e2e-523534d30e36';
  UPDATE public.profiles SET spouse_id = 'd0efb40a-1e42-4d2c-a201-750031eeaf16' WHERE id = '2805af4b-4afd-4694-846c-4f7a8dbc5f86';
  UPDATE public.profiles SET spouse_id = '2805af4b-4afd-4694-846c-4f7a8dbc5f86' WHERE id = 'd0efb40a-1e42-4d2c-a201-750031eeaf16';
  UPDATE public.profiles SET spouse_id = 'f82f2d40-3ef2-44b7-bc9c-f1ea0d745553' WHERE id = 'd50e316f-3e08-4531-975f-c2f4f1e8057f';
  UPDATE public.profiles SET spouse_id = 'd50e316f-3e08-4531-975f-c2f4f1e8057f' WHERE id = 'f82f2d40-3ef2-44b7-bc9c-f1ea0d745553';
  UPDATE public.profiles SET spouse_id = '9af18973-f83c-4eca-9643-9fe7564ff0d2' WHERE id = 'a353767c-9979-4023-a653-40cc2202ca2c';
  UPDATE public.profiles SET spouse_id = 'a353767c-9979-4023-a653-40cc2202ca2c' WHERE id = '9af18973-f83c-4eca-9643-9fe7564ff0d2';
  UPDATE public.profiles SET spouse_id = 'b3346ac1-df4f-4038-acf3-a5a3e5b13347' WHERE id = '5a2883f5-144e-4b79-a8a5-4badd593a645';
  UPDATE public.profiles SET spouse_id = '5a2883f5-144e-4b79-a8a5-4badd593a645' WHERE id = 'b3346ac1-df4f-4038-acf3-a5a3e5b13347';
  UPDATE public.profiles SET spouse_id = '02bbe8c4-7103-412d-aed1-7e4913774813' WHERE id = 'a91e3152-bbe1-49d5-a5b9-a2366a173a01';
  UPDATE public.profiles SET spouse_id = 'a91e3152-bbe1-49d5-a5b9-a2366a173a01' WHERE id = '02bbe8c4-7103-412d-aed1-7e4913774813';
  UPDATE public.profiles SET spouse_id = '81c36f7d-917e-4ad6-82bc-da56fb728c92' WHERE id = 'aad4af3c-f8dd-46cd-92cd-6ae4620a28e3';
  UPDATE public.profiles SET spouse_id = 'aad4af3c-f8dd-46cd-92cd-6ae4620a28e3' WHERE id = '81c36f7d-917e-4ad6-82bc-da56fb728c92';
  UPDATE public.profiles SET spouse_id = 'e2c8d6e5-c6fb-4744-bb9a-e0182140abb8' WHERE id = '9ab5e99a-a169-4984-b54e-2027ba37cc36';
  UPDATE public.profiles SET spouse_id = '9ab5e99a-a169-4984-b54e-2027ba37cc36' WHERE id = 'e2c8d6e5-c6fb-4744-bb9a-e0182140abb8';
  UPDATE public.profiles SET spouse_id = 'c4409645-87a8-41cf-b2d0-46bb3deb6049' WHERE id = '17d89c23-f27f-46d4-8f96-208196d8b6fc';
  UPDATE public.profiles SET spouse_id = '17d89c23-f27f-46d4-8f96-208196d8b6fc' WHERE id = 'c4409645-87a8-41cf-b2d0-46bb3deb6049';
  UPDATE public.profiles SET spouse_id = '72015b0c-ec6e-4d54-a88d-ae44c62711ac' WHERE id = 'efa9933a-800d-421f-a3f5-f0a859bd19b4';
  UPDATE public.profiles SET spouse_id = 'efa9933a-800d-421f-a3f5-f0a859bd19b4' WHERE id = '72015b0c-ec6e-4d54-a88d-ae44c62711ac';
  UPDATE public.profiles SET spouse_id = '4da0d483-7562-4aa3-8ce1-bae3cf26d0ea' WHERE id = 'c525665c-41c9-428f-b2bf-19f75c3273e3';
  UPDATE public.profiles SET spouse_id = 'c525665c-41c9-428f-b2bf-19f75c3273e3' WHERE id = '4da0d483-7562-4aa3-8ce1-bae3cf26d0ea';
  UPDATE public.profiles SET spouse_id = 'd1c722d8-77f0-42a3-884e-1137f1d91cc0' WHERE id = 'cf1346c9-c3bb-4a47-a31c-8c1f77324d4a';
  UPDATE public.profiles SET spouse_id = 'cf1346c9-c3bb-4a47-a31c-8c1f77324d4a' WHERE id = 'd1c722d8-77f0-42a3-884e-1137f1d91cc0';
  UPDATE public.profiles SET spouse_id = 'f9c5dcae-bcd0-409a-bec0-107b57f022ea' WHERE id = '0ca60d3b-1d10-433a-80ef-5c6b44c5f856';
  UPDATE public.profiles SET spouse_id = '0ca60d3b-1d10-433a-80ef-5c6b44c5f856' WHERE id = 'f9c5dcae-bcd0-409a-bec0-107b57f022ea';
  UPDATE public.profiles SET spouse_id = '9cf018e2-8a26-4a6c-9c19-2a7218850108' WHERE id = 'afc0ea06-9e6e-416b-9323-9a512af12fd1';
  UPDATE public.profiles SET spouse_id = 'afc0ea06-9e6e-416b-9323-9a512af12fd1' WHERE id = '9cf018e2-8a26-4a6c-9c19-2a7218850108';
  UPDATE public.profiles SET spouse_id = '2f4f85aa-dec6-40a3-8468-0907a169020c' WHERE id = '82f620bb-0d1c-4e61-8093-92d7ffed8d6e';
  UPDATE public.profiles SET spouse_id = '82f620bb-0d1c-4e61-8093-92d7ffed8d6e' WHERE id = '2f4f85aa-dec6-40a3-8468-0907a169020c';
  UPDATE public.profiles SET spouse_id = '2bf2e6ff-2041-4e56-9a02-89a1f6940655' WHERE id = '417e8bea-be9f-40b2-a359-ba75007a0ac4';
  UPDATE public.profiles SET spouse_id = '417e8bea-be9f-40b2-a359-ba75007a0ac4' WHERE id = '2bf2e6ff-2041-4e56-9a02-89a1f6940655';
  UPDATE public.profiles SET spouse_id = '2506aea3-8c4b-41a0-8237-e11cf9dd0130' WHERE id = 'ac596a22-212d-4e17-82de-97f07cf80528';
  UPDATE public.profiles SET spouse_id = 'ac596a22-212d-4e17-82de-97f07cf80528' WHERE id = '2506aea3-8c4b-41a0-8237-e11cf9dd0130';
  UPDATE public.profiles SET spouse_id = '6426769b-3361-4e5c-92ca-71faa0b1933f' WHERE id = '808a6473-f076-43be-9408-6f62697e824a';
  UPDATE public.profiles SET spouse_id = '808a6473-f076-43be-9408-6f62697e824a' WHERE id = '6426769b-3361-4e5c-92ca-71faa0b1933f';
  UPDATE public.profiles SET spouse_id = 'ebccc2ac-a542-43a8-8074-06124a38cbc3' WHERE id = '63433d51-1305-46ac-9be8-c4a6f0e3b2a0';
  UPDATE public.profiles SET spouse_id = '63433d51-1305-46ac-9be8-c4a6f0e3b2a0' WHERE id = 'ebccc2ac-a542-43a8-8074-06124a38cbc3';
  UPDATE public.profiles SET spouse_id = '9e594c78-e783-459c-9697-2bd526a6d353' WHERE id = '26b23ba2-14e0-48d8-9f75-1aa39e56fe84';
  UPDATE public.profiles SET spouse_id = '26b23ba2-14e0-48d8-9f75-1aa39e56fe84' WHERE id = '9e594c78-e783-459c-9697-2bd526a6d353';
  UPDATE public.profiles SET spouse_id = '213af085-8b16-4e13-8377-737f0c8a020d' WHERE id = '185d1daf-adfe-4222-be33-64f8865fc357';
  UPDATE public.profiles SET spouse_id = '185d1daf-adfe-4222-be33-64f8865fc357' WHERE id = '213af085-8b16-4e13-8377-737f0c8a020d';
  UPDATE public.profiles SET spouse_id = '3c742c4d-ed01-4a67-9096-b2610d24e075' WHERE id = '725bfde5-fdce-4c16-94fb-229932618416';
  UPDATE public.profiles SET spouse_id = '725bfde5-fdce-4c16-94fb-229932618416' WHERE id = '3c742c4d-ed01-4a67-9096-b2610d24e075';
  UPDATE public.profiles SET spouse_id = '4fb6d3c1-820f-4cfb-b31b-d880223d3d1a' WHERE id = '23657810-988d-4cc3-9e1b-1751ebbbdcd4';
  UPDATE public.profiles SET spouse_id = '23657810-988d-4cc3-9e1b-1751ebbbdcd4' WHERE id = '4fb6d3c1-820f-4cfb-b31b-d880223d3d1a';
  UPDATE public.profiles SET spouse_id = 'ec488ee3-4fd9-4f38-8ea9-f528c97dd46b' WHERE id = '30b3bb90-624e-43ac-a2bb-2e02a95c9d4b';
  UPDATE public.profiles SET spouse_id = '30b3bb90-624e-43ac-a2bb-2e02a95c9d4b' WHERE id = 'ec488ee3-4fd9-4f38-8ea9-f528c97dd46b';
  UPDATE public.profiles SET spouse_id = 'a3b432cb-5e5c-4672-b812-ecffebc204ee' WHERE id = '57c8cae9-25b3-4cb1-8dd3-8eb5d6142966';
  UPDATE public.profiles SET spouse_id = '57c8cae9-25b3-4cb1-8dd3-8eb5d6142966' WHERE id = 'a3b432cb-5e5c-4672-b812-ecffebc204ee';
  UPDATE public.profiles SET spouse_id = '5ce3d7af-196e-4675-aa48-19c96f622d99' WHERE id = 'db93cb34-835d-4fe6-8e35-53621fd147e7';
  UPDATE public.profiles SET spouse_id = 'db93cb34-835d-4fe6-8e35-53621fd147e7' WHERE id = '5ce3d7af-196e-4675-aa48-19c96f622d99';
  UPDATE public.profiles SET spouse_id = 'df3db365-38ea-4aca-abeb-c4c4a2207333' WHERE id = '08b473e2-eaf9-44ef-84eb-6f02b72e4a25';
  UPDATE public.profiles SET spouse_id = '08b473e2-eaf9-44ef-84eb-6f02b72e4a25' WHERE id = 'df3db365-38ea-4aca-abeb-c4c4a2207333';
  UPDATE public.profiles SET spouse_id = '9ce2ff98-f302-4130-93d2-45942b07913c' WHERE id = 'b21328c6-5e07-41c1-a852-50a44cc78f53';
  UPDATE public.profiles SET spouse_id = 'b21328c6-5e07-41c1-a852-50a44cc78f53' WHERE id = '9ce2ff98-f302-4130-93d2-45942b07913c';
  UPDATE public.profiles SET spouse_id = 'f603b12a-a7c3-4e06-ae3c-9925ad08fcea' WHERE id = '69b48c21-3834-4c15-aa7c-585de935dac7';
  UPDATE public.profiles SET spouse_id = '69b48c21-3834-4c15-aa7c-585de935dac7' WHERE id = 'f603b12a-a7c3-4e06-ae3c-9925ad08fcea';
  UPDATE public.profiles SET spouse_id = '01a42d7a-9374-475c-83c2-b2c5c75af0a6' WHERE id = '9ec0d723-674b-4224-bd42-d046f79d6910';
  UPDATE public.profiles SET spouse_id = '9ec0d723-674b-4224-bd42-d046f79d6910' WHERE id = '01a42d7a-9374-475c-83c2-b2c5c75af0a6';
  UPDATE public.profiles SET spouse_id = 'ee2ca227-aafa-40f8-9f43-a2fa3090b2bb' WHERE id = 'fb4ae27f-7799-4940-956e-6e5c337fe981';
  UPDATE public.profiles SET spouse_id = 'fb4ae27f-7799-4940-956e-6e5c337fe981' WHERE id = 'ee2ca227-aafa-40f8-9f43-a2fa3090b2bb';
  UPDATE public.profiles SET spouse_id = 'c94e4491-9993-425e-90ad-6bcdf906ae32' WHERE id = '8277576d-b0ea-4107-9bdb-6917cce5ea7a';
  UPDATE public.profiles SET spouse_id = '8277576d-b0ea-4107-9bdb-6917cce5ea7a' WHERE id = 'c94e4491-9993-425e-90ad-6bcdf906ae32';
  UPDATE public.profiles SET spouse_id = '5f633223-b89e-46ec-bd19-e1ef8f9b286b' WHERE id = '1f54b7ab-e0c3-427b-b925-58e81d0b821a';
  UPDATE public.profiles SET spouse_id = '1f54b7ab-e0c3-427b-b925-58e81d0b821a' WHERE id = '5f633223-b89e-46ec-bd19-e1ef8f9b286b';
  UPDATE public.profiles SET spouse_id = '7428d4ba-dda0-4c0f-8908-12ce3b72318b' WHERE id = '8843c203-2474-4a86-abb2-f795dd099fe3';
  UPDATE public.profiles SET spouse_id = '8843c203-2474-4a86-abb2-f795dd099fe3' WHERE id = '7428d4ba-dda0-4c0f-8908-12ce3b72318b';
  UPDATE public.profiles SET spouse_id = '3f6d0078-c3ae-4c3e-9ce4-1c8e77aafb09' WHERE id = '3eb49b3d-9266-40c2-910b-5d494115ccb8';
  UPDATE public.profiles SET spouse_id = '3eb49b3d-9266-40c2-910b-5d494115ccb8' WHERE id = '3f6d0078-c3ae-4c3e-9ce4-1c8e77aafb09';
  UPDATE public.profiles SET spouse_id = 'a3a1c2d2-6b49-44c2-92d6-e47dad320e98' WHERE id = '90cdc2d3-2770-44fc-81a7-cd0701bb68a4';
  UPDATE public.profiles SET spouse_id = '90cdc2d3-2770-44fc-81a7-cd0701bb68a4' WHERE id = 'a3a1c2d2-6b49-44c2-92d6-e47dad320e98';
  UPDATE public.profiles SET spouse_id = '59bb6092-e518-423d-9540-4d154ce46b02' WHERE id = '98088ecf-01ce-48fd-860a-9adf4dc29213';
  UPDATE public.profiles SET spouse_id = '98088ecf-01ce-48fd-860a-9adf4dc29213' WHERE id = '59bb6092-e518-423d-9540-4d154ce46b02';
  UPDATE public.profiles SET spouse_id = 'b8d07260-54af-48d0-b333-127674addbaf' WHERE id = 'c9682429-807a-4396-85e8-9a89a921e164';
  UPDATE public.profiles SET spouse_id = 'c9682429-807a-4396-85e8-9a89a921e164' WHERE id = 'b8d07260-54af-48d0-b333-127674addbaf';
  UPDATE public.profiles SET spouse_id = 'afd46cc5-f631-4bb4-aa0c-ae57bf4a636c' WHERE id = '72f5e5cf-692c-4044-8b0c-9fb979ffd8cd';
  UPDATE public.profiles SET spouse_id = '72f5e5cf-692c-4044-8b0c-9fb979ffd8cd' WHERE id = 'afd46cc5-f631-4bb4-aa0c-ae57bf4a636c';
  UPDATE public.profiles SET spouse_id = 'fd88bbc8-210d-40f9-97c9-ec359641e5fc' WHERE id = '05ff2ee7-58c2-4c27-b9fd-1fca15e846a8';
  UPDATE public.profiles SET spouse_id = '05ff2ee7-58c2-4c27-b9fd-1fca15e846a8' WHERE id = 'fd88bbc8-210d-40f9-97c9-ec359641e5fc';
  UPDATE public.profiles SET spouse_id = '6d1a49fa-af42-45cb-9414-2ad4afe3f1de' WHERE id = 'a8bbce5d-6d63-4f65-af39-879a0ab3a334';
  UPDATE public.profiles SET spouse_id = 'a8bbce5d-6d63-4f65-af39-879a0ab3a334' WHERE id = '6d1a49fa-af42-45cb-9414-2ad4afe3f1de';
  UPDATE public.profiles SET spouse_id = '6ee994ae-4df5-46e2-b29c-ad7af8d99760' WHERE id = '1976e0e6-9420-4e46-a6f1-ef6a15a26610';
  UPDATE public.profiles SET spouse_id = '1976e0e6-9420-4e46-a6f1-ef6a15a26610' WHERE id = '6ee994ae-4df5-46e2-b29c-ad7af8d99760';
  UPDATE public.profiles SET spouse_id = '77ffe695-e38b-4cab-a160-59fed1eb0e70' WHERE id = '8b571057-7c94-4269-81a7-a6fb34dd1373';
  UPDATE public.profiles SET spouse_id = '8b571057-7c94-4269-81a7-a6fb34dd1373' WHERE id = '77ffe695-e38b-4cab-a160-59fed1eb0e70';
  UPDATE public.profiles SET spouse_id = '77914e9f-026d-4eba-9a5b-2b83b978d90f' WHERE id = '1b79371e-80e6-4dc9-80b3-46ce809a72fb';
  UPDATE public.profiles SET spouse_id = '1b79371e-80e6-4dc9-80b3-46ce809a72fb' WHERE id = '77914e9f-026d-4eba-9a5b-2b83b978d90f';
  UPDATE public.profiles SET spouse_id = '4d6438a0-6cb6-4699-8c19-4e8caf732cc5' WHERE id = '2888b159-eac2-4102-b88f-24d50d554435';
  UPDATE public.profiles SET spouse_id = '2888b159-eac2-4102-b88f-24d50d554435' WHERE id = '4d6438a0-6cb6-4699-8c19-4e8caf732cc5';
  UPDATE public.profiles SET spouse_id = '409646e0-bbab-49d8-86d9-94df0c8ad46a' WHERE id = '1d9f23a3-43a1-4fd4-b1a4-357a79842155';
  UPDATE public.profiles SET spouse_id = '1d9f23a3-43a1-4fd4-b1a4-357a79842155' WHERE id = '409646e0-bbab-49d8-86d9-94df0c8ad46a';
  UPDATE public.profiles SET spouse_id = '273d760d-2569-4f6c-9372-c7833dd656df' WHERE id = 'cb44faa7-fada-4754-9a48-b4c2c911cf94';
  UPDATE public.profiles SET spouse_id = 'cb44faa7-fada-4754-9a48-b4c2c911cf94' WHERE id = '273d760d-2569-4f6c-9372-c7833dd656df';
  UPDATE public.profiles SET spouse_id = 'dc89b869-08ce-46d5-a8c8-0330a73060ba' WHERE id = '7c8a73a8-ee9e-4100-a523-730a700be20f';
  UPDATE public.profiles SET spouse_id = '7c8a73a8-ee9e-4100-a523-730a700be20f' WHERE id = 'dc89b869-08ce-46d5-a8c8-0330a73060ba';
  UPDATE public.profiles SET spouse_id = '03f38c79-742f-4e08-8b12-51ddda20cc5a' WHERE id = '085fd5cd-72d7-4435-aa37-050a5733b4f3';
  UPDATE public.profiles SET spouse_id = '085fd5cd-72d7-4435-aa37-050a5733b4f3' WHERE id = '03f38c79-742f-4e08-8b12-51ddda20cc5a';
  UPDATE public.profiles SET spouse_id = '15cabd86-de1e-4944-8c19-384bc67c087b' WHERE id = '7ac9f5be-d838-46d1-9cd2-790674800465';
  UPDATE public.profiles SET spouse_id = '7ac9f5be-d838-46d1-9cd2-790674800465' WHERE id = '15cabd86-de1e-4944-8c19-384bc67c087b';
  UPDATE public.profiles SET spouse_id = '6fe9081b-f611-40d2-ae14-50bb53d225fb' WHERE id = 'cdf3160e-2e83-4d35-93f8-ba9f0fc6cda4';
  UPDATE public.profiles SET spouse_id = 'cdf3160e-2e83-4d35-93f8-ba9f0fc6cda4' WHERE id = '6fe9081b-f611-40d2-ae14-50bb53d225fb';
  UPDATE public.profiles SET spouse_id = '03d23d2b-2c50-4e6a-9cad-dd19b028c468' WHERE id = '074d5c14-3d7b-4b17-b7d5-cf27d8386e04';
  UPDATE public.profiles SET spouse_id = '074d5c14-3d7b-4b17-b7d5-cf27d8386e04' WHERE id = '03d23d2b-2c50-4e6a-9cad-dd19b028c468';
  UPDATE public.profiles SET spouse_id = 'e782760e-8183-48a0-9ca3-642a58f98c87' WHERE id = 'a4e32b83-b201-4c50-b72f-ae4738145c21';
  UPDATE public.profiles SET spouse_id = 'a4e32b83-b201-4c50-b72f-ae4738145c21' WHERE id = 'e782760e-8183-48a0-9ca3-642a58f98c87';
  UPDATE public.profiles SET spouse_id = '634ebf19-5d6f-4553-a482-0d9b795cdb5b' WHERE id = 'b0cb4d2d-f134-48cb-96c8-cf2a98e596d2';
  UPDATE public.profiles SET spouse_id = 'b0cb4d2d-f134-48cb-96c8-cf2a98e596d2' WHERE id = '634ebf19-5d6f-4553-a482-0d9b795cdb5b';
  UPDATE public.profiles SET spouse_id = 'c0281d29-ea62-47dc-b713-3fa61a914d50' WHERE id = 'd845a0d0-cbaa-4432-91cb-40a13c5232cc';
  UPDATE public.profiles SET spouse_id = 'd845a0d0-cbaa-4432-91cb-40a13c5232cc' WHERE id = 'c0281d29-ea62-47dc-b713-3fa61a914d50';
  UPDATE public.profiles SET spouse_id = '30ec8b53-fa37-4d68-8f78-82ba961ed646' WHERE id = '47397373-f6de-47b3-b15e-8e4f0c97a7d4';
  UPDATE public.profiles SET spouse_id = '47397373-f6de-47b3-b15e-8e4f0c97a7d4' WHERE id = '30ec8b53-fa37-4d68-8f78-82ba961ed646';
  UPDATE public.profiles SET spouse_id = '84fcc302-3b37-43c3-b3ff-d6e5978183c6' WHERE id = '6a7a69f2-740b-45a7-8399-3db32c96ac8a';
  UPDATE public.profiles SET spouse_id = '6a7a69f2-740b-45a7-8399-3db32c96ac8a' WHERE id = '84fcc302-3b37-43c3-b3ff-d6e5978183c6';
  UPDATE public.profiles SET spouse_id = 'cc02327c-e58f-4f11-8bca-b7f936147b76' WHERE id = 'd4888e55-62e1-4003-964c-263847bbeb25';
  UPDATE public.profiles SET spouse_id = 'd4888e55-62e1-4003-964c-263847bbeb25' WHERE id = 'cc02327c-e58f-4f11-8bca-b7f936147b76';
  UPDATE public.profiles SET spouse_id = 'e10dec81-fb8d-42e2-8cc8-b488a9fa03e6' WHERE id = '5fc9f0b4-bb35-473e-a445-f0d7eacf0185';
  UPDATE public.profiles SET spouse_id = '5fc9f0b4-bb35-473e-a445-f0d7eacf0185' WHERE id = 'e10dec81-fb8d-42e2-8cc8-b488a9fa03e6';
  UPDATE public.profiles SET spouse_id = 'b33b9b1e-4817-4d06-8c51-b6a55293b79c' WHERE id = '49061166-5ee7-46aa-ad69-c830e8040bb9';
  UPDATE public.profiles SET spouse_id = '49061166-5ee7-46aa-ad69-c830e8040bb9' WHERE id = 'b33b9b1e-4817-4d06-8c51-b6a55293b79c';
  UPDATE public.profiles SET spouse_id = '90131381-befd-4e28-a84c-df5e8cd3b2c9' WHERE id = 'ae42aed7-1e27-4999-9dd9-af3c31b28b7e';
  UPDATE public.profiles SET spouse_id = 'ae42aed7-1e27-4999-9dd9-af3c31b28b7e' WHERE id = '90131381-befd-4e28-a84c-df5e8cd3b2c9';
  UPDATE public.profiles SET spouse_id = 'fec8cecd-1a12-47a6-9f39-5d8dd95d2066' WHERE id = 'f4ae810a-a538-4628-84ee-b081625f4e1c';
  UPDATE public.profiles SET spouse_id = 'f4ae810a-a538-4628-84ee-b081625f4e1c' WHERE id = 'fec8cecd-1a12-47a6-9f39-5d8dd95d2066';
  UPDATE public.profiles SET spouse_id = '9a472a03-3019-433a-a844-aab960d371a1' WHERE id = 'd2611ef7-f80d-493c-9d81-d2d7d2cddd06';
  UPDATE public.profiles SET spouse_id = 'd2611ef7-f80d-493c-9d81-d2d7d2cddd06' WHERE id = '9a472a03-3019-433a-a844-aab960d371a1';
  UPDATE public.profiles SET spouse_id = '9f7ef2d9-ab1d-44e0-b277-a1f4659cd464' WHERE id = '99969e7f-7eba-4b22-b80f-61ca77a97b1f';
  UPDATE public.profiles SET spouse_id = '99969e7f-7eba-4b22-b80f-61ca77a97b1f' WHERE id = '9f7ef2d9-ab1d-44e0-b277-a1f4659cd464';
  UPDATE public.profiles SET spouse_id = '58ebe276-7a77-4b63-9dfb-0dfe71c1f3bf' WHERE id = 'e918e722-10da-48b4-92bb-b243e560420a';
  UPDATE public.profiles SET spouse_id = 'e918e722-10da-48b4-92bb-b243e560420a' WHERE id = '58ebe276-7a77-4b63-9dfb-0dfe71c1f3bf';
  UPDATE public.profiles SET spouse_id = '77948d79-6a1e-4a9b-8ca1-7d1683c1e8ae' WHERE id = 'b6f75b58-ff57-47d5-9d53-7ee7617b57e7';
  UPDATE public.profiles SET spouse_id = 'b6f75b58-ff57-47d5-9d53-7ee7617b57e7' WHERE id = '77948d79-6a1e-4a9b-8ca1-7d1683c1e8ae';
  UPDATE public.profiles SET spouse_id = '80a73aff-0b63-47db-8f3e-748be9b6b3fa' WHERE id = 'b2bda8fe-9444-4780-bfcd-556c19d39d96';
  UPDATE public.profiles SET spouse_id = 'b2bda8fe-9444-4780-bfcd-556c19d39d96' WHERE id = '80a73aff-0b63-47db-8f3e-748be9b6b3fa';
  UPDATE public.profiles SET spouse_id = 'a6e41747-32b3-4124-b6a8-08063bcf1362' WHERE id = '6cd9c6dd-091b-4458-be1b-649c9cfbf5dc';
  UPDATE public.profiles SET spouse_id = '6cd9c6dd-091b-4458-be1b-649c9cfbf5dc' WHERE id = 'a6e41747-32b3-4124-b6a8-08063bcf1362';
  UPDATE public.profiles SET spouse_id = 'b667ba62-263f-44d5-9cd2-1afbaf7bce8d' WHERE id = 'd7dbbb9b-2ab7-4ca6-8b25-ecac282ef660';
  UPDATE public.profiles SET spouse_id = 'd7dbbb9b-2ab7-4ca6-8b25-ecac282ef660' WHERE id = 'b667ba62-263f-44d5-9cd2-1afbaf7bce8d';
  UPDATE public.profiles SET spouse_id = 'e805b9ca-eaca-42a0-9a18-153be8c8d218' WHERE id = 'b8d744bf-242e-4c11-a7de-29a8e19236e4';
  UPDATE public.profiles SET spouse_id = 'b8d744bf-242e-4c11-a7de-29a8e19236e4' WHERE id = 'e805b9ca-eaca-42a0-9a18-153be8c8d218';
  UPDATE public.profiles SET spouse_id = 'f57e52f9-0018-446a-9862-45fc2ee9adfc' WHERE id = 'ac4683a2-4a53-46f2-be91-8a06195a7a67';
  UPDATE public.profiles SET spouse_id = 'ac4683a2-4a53-46f2-be91-8a06195a7a67' WHERE id = 'f57e52f9-0018-446a-9862-45fc2ee9adfc';
  UPDATE public.profiles SET spouse_id = '90ed5647-d80f-4994-a497-488663a76f6a' WHERE id = 'a3572e00-8fb9-496f-8d39-e2e39c35f314';
  UPDATE public.profiles SET spouse_id = 'a3572e00-8fb9-496f-8d39-e2e39c35f314' WHERE id = '90ed5647-d80f-4994-a497-488663a76f6a';
  UPDATE public.profiles SET spouse_id = '412281ef-14cc-4bf5-8c8c-3a99801ac0c5' WHERE id = 'e12eba1f-e0b9-4e48-87a0-e4b6722f4f3b';
  UPDATE public.profiles SET spouse_id = 'e12eba1f-e0b9-4e48-87a0-e4b6722f4f3b' WHERE id = '412281ef-14cc-4bf5-8c8c-3a99801ac0c5';
  UPDATE public.profiles SET spouse_id = 'e90f4120-ed2f-4388-9983-c669dc5ed409' WHERE id = 'd36ce245-1130-49a0-ac1e-e165e9edce0c';
  UPDATE public.profiles SET spouse_id = 'd36ce245-1130-49a0-ac1e-e165e9edce0c' WHERE id = 'e90f4120-ed2f-4388-9983-c669dc5ed409';
  UPDATE public.profiles SET spouse_id = 'f55a0aab-53b9-448f-a57d-84f2eb9068f4' WHERE id = '9a8bd12f-e8ea-42b3-8114-6268cf77f9a9';
  UPDATE public.profiles SET spouse_id = '9a8bd12f-e8ea-42b3-8114-6268cf77f9a9' WHERE id = 'f55a0aab-53b9-448f-a57d-84f2eb9068f4';
  UPDATE public.profiles SET spouse_id = 'f7d55a4f-8e34-4cf0-81ce-b69e9c196e14' WHERE id = 'bd688ad9-23df-474b-aac0-fc8e23ceae9e';
  UPDATE public.profiles SET spouse_id = 'bd688ad9-23df-474b-aac0-fc8e23ceae9e' WHERE id = 'f7d55a4f-8e34-4cf0-81ce-b69e9c196e14';
  UPDATE public.profiles SET spouse_id = '0c57ff88-fdca-4ccb-a579-01eb98babac7' WHERE id = '66b84a63-a1c2-443a-b29c-5cc2767b6a3d';
  UPDATE public.profiles SET spouse_id = '66b84a63-a1c2-443a-b29c-5cc2767b6a3d' WHERE id = '0c57ff88-fdca-4ccb-a579-01eb98babac7';
  UPDATE public.profiles SET spouse_id = '40f58745-8172-49b5-ad40-9adcdc0864d6' WHERE id = '2593d98a-bf0c-4ee9-bce6-396691bef474';
  UPDATE public.profiles SET spouse_id = '2593d98a-bf0c-4ee9-bce6-396691bef474' WHERE id = '40f58745-8172-49b5-ad40-9adcdc0864d6';
  UPDATE public.profiles SET spouse_id = '07505fcb-bbab-4c23-a738-4127501f402e' WHERE id = '8ae246e6-0b5d-4075-997c-7e6b6c9ca984';
  UPDATE public.profiles SET spouse_id = '8ae246e6-0b5d-4075-997c-7e6b6c9ca984' WHERE id = '07505fcb-bbab-4c23-a738-4127501f402e';
  UPDATE public.profiles SET spouse_id = '4842d3df-262e-4f5f-a9e4-e94e264f8942' WHERE id = 'e14d477f-7d43-4b78-8c59-309bb9e43c8e';
  UPDATE public.profiles SET spouse_id = 'e14d477f-7d43-4b78-8c59-309bb9e43c8e' WHERE id = '4842d3df-262e-4f5f-a9e4-e94e264f8942';
  UPDATE public.profiles SET spouse_id = '59da7ad8-e573-43a6-b2b6-0cc612f75412' WHERE id = '9b7e123e-8a4b-4cbf-b1ea-91018cc09710';
  UPDATE public.profiles SET spouse_id = '9b7e123e-8a4b-4cbf-b1ea-91018cc09710' WHERE id = '59da7ad8-e573-43a6-b2b6-0cc612f75412';
  UPDATE public.profiles SET spouse_id = '05b2ac6e-5494-439a-93db-10e6eab77f8f' WHERE id = '82923ff5-0618-43e3-b9f9-1543f681b4a6';
  UPDATE public.profiles SET spouse_id = '82923ff5-0618-43e3-b9f9-1543f681b4a6' WHERE id = '05b2ac6e-5494-439a-93db-10e6eab77f8f';
  UPDATE public.profiles SET spouse_id = 'd387d30a-45a6-425d-8be0-67726f688e9d' WHERE id = '487fc304-5040-4e9f-810f-296ca99cbc2c';
  UPDATE public.profiles SET spouse_id = '487fc304-5040-4e9f-810f-296ca99cbc2c' WHERE id = 'd387d30a-45a6-425d-8be0-67726f688e9d';
  UPDATE public.profiles SET spouse_id = '8e6174b6-6d89-457e-b2d8-3f5988b0e829' WHERE id = 'd17bef0c-89e9-466d-9df4-6a18677aa0a3';
  UPDATE public.profiles SET spouse_id = 'd17bef0c-89e9-466d-9df4-6a18677aa0a3' WHERE id = '8e6174b6-6d89-457e-b2d8-3f5988b0e829';
  UPDATE public.profiles SET spouse_id = 'b9fcb867-cf5b-406a-a004-032d7aaaaca7' WHERE id = '9266f1dc-f06f-48b1-b47b-9fe4f5020955';
  UPDATE public.profiles SET spouse_id = '9266f1dc-f06f-48b1-b47b-9fe4f5020955' WHERE id = 'b9fcb867-cf5b-406a-a004-032d7aaaaca7';
  UPDATE public.profiles SET spouse_id = '636c7fb2-7f99-43d0-80a6-f29da2a21526' WHERE id = '2b3352f4-d8db-4322-a1b3-b16625e164b9';
  UPDATE public.profiles SET spouse_id = '2b3352f4-d8db-4322-a1b3-b16625e164b9' WHERE id = '636c7fb2-7f99-43d0-80a6-f29da2a21526';
  UPDATE public.profiles SET spouse_id = '698c6074-257b-43b4-a379-45585b53de97' WHERE id = '7f6a897d-f307-4429-afdf-f50c86822fa1';
  UPDATE public.profiles SET spouse_id = '7f6a897d-f307-4429-afdf-f50c86822fa1' WHERE id = '698c6074-257b-43b4-a379-45585b53de97';
  UPDATE public.profiles SET spouse_id = 'cf1e668b-d5c6-4bfe-a4c8-c63cecdf3f3c' WHERE id = '619e54b6-6171-44f2-a081-1bdb77914858';
  UPDATE public.profiles SET spouse_id = '619e54b6-6171-44f2-a081-1bdb77914858' WHERE id = 'cf1e668b-d5c6-4bfe-a4c8-c63cecdf3f3c';
  UPDATE public.profiles SET spouse_id = 'e898433b-71b2-495a-b778-88cffac37816' WHERE id = 'ee643bef-3d93-486f-be03-1ec6e30b9fa7';
  UPDATE public.profiles SET spouse_id = 'ee643bef-3d93-486f-be03-1ec6e30b9fa7' WHERE id = 'e898433b-71b2-495a-b778-88cffac37816';
  UPDATE public.profiles SET spouse_id = 'fb0d32fb-4fd4-483d-8c81-a5b0a800ecc2' WHERE id = '884cd615-51a4-466a-b34a-353ce7f54aaf';
  UPDATE public.profiles SET spouse_id = '884cd615-51a4-466a-b34a-353ce7f54aaf' WHERE id = 'fb0d32fb-4fd4-483d-8c81-a5b0a800ecc2';
  UPDATE public.profiles SET spouse_id = '5e780f3e-0a2b-4e61-8dc3-0b45f686d554' WHERE id = '3f756cdb-0c88-474c-961e-16d00943f790';
  UPDATE public.profiles SET spouse_id = '3f756cdb-0c88-474c-961e-16d00943f790' WHERE id = '5e780f3e-0a2b-4e61-8dc3-0b45f686d554';
  UPDATE public.profiles SET spouse_id = 'bef040a4-97fc-41cc-8400-86caab8bc675' WHERE id = '6ab35f69-d80e-4531-b8f7-4d2833f92c1b';
  UPDATE public.profiles SET spouse_id = '6ab35f69-d80e-4531-b8f7-4d2833f92c1b' WHERE id = 'bef040a4-97fc-41cc-8400-86caab8bc675';
  UPDATE public.profiles SET spouse_id = 'be24d372-c67b-4814-84b5-dea54dca0c36' WHERE id = '03283ddf-1330-468f-bb6d-8a9b5f9b6ede';
  UPDATE public.profiles SET spouse_id = '03283ddf-1330-468f-bb6d-8a9b5f9b6ede' WHERE id = 'be24d372-c67b-4814-84b5-dea54dca0c36';
  UPDATE public.profiles SET spouse_id = 'bb5c9636-55d4-4df0-92e4-3b8d60cfc829' WHERE id = '92e26edd-467f-41f2-8fa7-438886aee0c4';
  UPDATE public.profiles SET spouse_id = '92e26edd-467f-41f2-8fa7-438886aee0c4' WHERE id = 'bb5c9636-55d4-4df0-92e4-3b8d60cfc829';
  UPDATE public.profiles SET spouse_id = '53fe2ad5-6b9a-4c61-88de-f5f3038679b2' WHERE id = '16fc3cae-b943-4e46-8bec-d7f01baa4f31';
  UPDATE public.profiles SET spouse_id = '16fc3cae-b943-4e46-8bec-d7f01baa4f31' WHERE id = '53fe2ad5-6b9a-4c61-88de-f5f3038679b2';
  UPDATE public.profiles SET spouse_id = '927e05a8-c64b-497d-9cff-922bcb8adf92' WHERE id = 'ffe90127-a721-4c5d-a767-0601449ab591';
  UPDATE public.profiles SET spouse_id = 'ffe90127-a721-4c5d-a767-0601449ab591' WHERE id = '927e05a8-c64b-497d-9cff-922bcb8adf92';
  UPDATE public.profiles SET spouse_id = 'bfaf2255-9cea-451d-ba83-65873c2525f1' WHERE id = '0b41474e-5a7c-41f9-8cac-2c94dbcb5b02';
  UPDATE public.profiles SET spouse_id = '0b41474e-5a7c-41f9-8cac-2c94dbcb5b02' WHERE id = 'bfaf2255-9cea-451d-ba83-65873c2525f1';
  UPDATE public.profiles SET spouse_id = '908d2ecc-65f7-4160-b782-30f6e0fe8559' WHERE id = '6504260b-9f34-4c87-b35f-331b555967cb';
  UPDATE public.profiles SET spouse_id = '6504260b-9f34-4c87-b35f-331b555967cb' WHERE id = '908d2ecc-65f7-4160-b782-30f6e0fe8559';
  UPDATE public.profiles SET spouse_id = '6e63bfd5-5879-49a9-94cc-89ef65e53633' WHERE id = 'd4445397-62d1-4780-bceb-9cfdd30b99bf';
  UPDATE public.profiles SET spouse_id = 'd4445397-62d1-4780-bceb-9cfdd30b99bf' WHERE id = '6e63bfd5-5879-49a9-94cc-89ef65e53633';
  UPDATE public.profiles SET spouse_id = '0b3d3917-9a4c-4f06-b6e5-2bf0442ed694' WHERE id = 'fd388df9-b123-4c2d-b18a-7f2d869bcee9';
  UPDATE public.profiles SET spouse_id = 'fd388df9-b123-4c2d-b18a-7f2d869bcee9' WHERE id = '0b3d3917-9a4c-4f06-b6e5-2bf0442ed694';
  UPDATE public.profiles SET spouse_id = '9b2e2647-6f18-4546-97e4-5c47ffb6805f' WHERE id = '2b313e6c-35af-4309-9170-a485fabb45e8';
  UPDATE public.profiles SET spouse_id = '2b313e6c-35af-4309-9170-a485fabb45e8' WHERE id = '9b2e2647-6f18-4546-97e4-5c47ffb6805f';
  UPDATE public.profiles SET spouse_id = 'ed6abaed-ed59-42db-bb8e-64d26b8ea1c1' WHERE id = 'b9c372cd-0253-4162-8336-9a11ad7258cd';
  UPDATE public.profiles SET spouse_id = 'b9c372cd-0253-4162-8336-9a11ad7258cd' WHERE id = 'ed6abaed-ed59-42db-bb8e-64d26b8ea1c1';
  UPDATE public.profiles SET spouse_id = 'c735630e-4256-4ec4-a557-d74b25ff1564' WHERE id = 'ceecba38-dbf1-4e71-9527-b75bca08248d';
  UPDATE public.profiles SET spouse_id = 'ceecba38-dbf1-4e71-9527-b75bca08248d' WHERE id = 'c735630e-4256-4ec4-a557-d74b25ff1564';
  UPDATE public.profiles SET spouse_id = '8bb8d56e-6b43-4997-a4ac-053b78ca0a9b' WHERE id = '311b2c8d-bd25-4bca-a569-257bcdf6583c';
  UPDATE public.profiles SET spouse_id = '311b2c8d-bd25-4bca-a569-257bcdf6583c' WHERE id = '8bb8d56e-6b43-4997-a4ac-053b78ca0a9b';
  UPDATE public.profiles SET spouse_id = '7c47fad3-84c7-49b7-b56b-ea9e470ca582' WHERE id = 'bbb8a195-549d-46d6-96cf-84a45ec4f5ae';
  UPDATE public.profiles SET spouse_id = 'bbb8a195-549d-46d6-96cf-84a45ec4f5ae' WHERE id = '7c47fad3-84c7-49b7-b56b-ea9e470ca582';
  UPDATE public.profiles SET spouse_id = 'a37df668-d01b-41f9-a54d-d326f2a17d3f' WHERE id = 'b521d801-f99a-4835-8b3e-a3625884da65';
  UPDATE public.profiles SET spouse_id = 'b521d801-f99a-4835-8b3e-a3625884da65' WHERE id = 'a37df668-d01b-41f9-a54d-d326f2a17d3f';
  UPDATE public.profiles SET spouse_id = '1c2406c3-adf3-4d5b-956d-ff488006f0d4' WHERE id = 'c36f9d58-e6ae-447a-b8ad-be60805d9fa7';
  UPDATE public.profiles SET spouse_id = 'c36f9d58-e6ae-447a-b8ad-be60805d9fa7' WHERE id = '1c2406c3-adf3-4d5b-956d-ff488006f0d4';
  UPDATE public.profiles SET spouse_id = '3b257027-3160-4e0f-bc58-0b6aa5813ff9' WHERE id = '6bf0a643-6a4e-4599-8f3e-6784437768d0';
  UPDATE public.profiles SET spouse_id = '6bf0a643-6a4e-4599-8f3e-6784437768d0' WHERE id = '3b257027-3160-4e0f-bc58-0b6aa5813ff9';
  UPDATE public.profiles SET spouse_id = '2cf0d866-0648-4ceb-9004-ba32cdc093b3' WHERE id = '462f996d-dbf5-471a-8cbb-db5e2144aa26';
  UPDATE public.profiles SET spouse_id = '462f996d-dbf5-471a-8cbb-db5e2144aa26' WHERE id = '2cf0d866-0648-4ceb-9004-ba32cdc093b3';
  UPDATE public.profiles SET spouse_id = '58e950e1-6ad8-40e7-89aa-8773d96bf0df' WHERE id = '54cb5c5a-153a-4dc4-bb2b-64d3a979b158';
  UPDATE public.profiles SET spouse_id = '54cb5c5a-153a-4dc4-bb2b-64d3a979b158' WHERE id = '58e950e1-6ad8-40e7-89aa-8773d96bf0df';
  UPDATE public.profiles SET spouse_id = '2f3a54eb-ecd1-481a-91a2-fa8523e226e5' WHERE id = 'aac7b23c-9a35-41f4-815c-7a92d531f782';
  UPDATE public.profiles SET spouse_id = 'aac7b23c-9a35-41f4-815c-7a92d531f782' WHERE id = '2f3a54eb-ecd1-481a-91a2-fa8523e226e5';
  UPDATE public.profiles SET spouse_id = '2546a5f2-6c35-4de2-b940-8b959f4df61c' WHERE id = '84b3aca0-ef20-4436-aa64-082c92b5c60d';
  UPDATE public.profiles SET spouse_id = '84b3aca0-ef20-4436-aa64-082c92b5c60d' WHERE id = '2546a5f2-6c35-4de2-b940-8b959f4df61c';
  UPDATE public.profiles SET spouse_id = '7418d54e-e2af-49dd-8c1f-413289b4671f' WHERE id = 'e788d9fe-04b1-4dd0-9ab0-09b3a2360ef1';
  UPDATE public.profiles SET spouse_id = 'e788d9fe-04b1-4dd0-9ab0-09b3a2360ef1' WHERE id = '7418d54e-e2af-49dd-8c1f-413289b4671f';
  UPDATE public.profiles SET spouse_id = 'a5dbd7da-0387-44dd-9ec6-4a4e3dec3924' WHERE id = '7ec438d7-bd9f-4c18-ae9c-e785ca10a5bd';
  UPDATE public.profiles SET spouse_id = '7ec438d7-bd9f-4c18-ae9c-e785ca10a5bd' WHERE id = 'a5dbd7da-0387-44dd-9ec6-4a4e3dec3924';
  UPDATE public.profiles SET spouse_id = 'cea68f7b-66ad-4c71-aa2f-c8a55a802249' WHERE id = 'fcba7dea-23cb-4da3-9d0b-e065b51b20f3';
  UPDATE public.profiles SET spouse_id = 'fcba7dea-23cb-4da3-9d0b-e065b51b20f3' WHERE id = 'cea68f7b-66ad-4c71-aa2f-c8a55a802249';
  UPDATE public.profiles SET spouse_id = 'e1ed96e0-bd55-4bf2-82aa-23315c3f83aa' WHERE id = 'ce29b36b-bac6-49ba-bf63-72cebaa163cb';
  UPDATE public.profiles SET spouse_id = 'ce29b36b-bac6-49ba-bf63-72cebaa163cb' WHERE id = 'e1ed96e0-bd55-4bf2-82aa-23315c3f83aa';
  UPDATE public.profiles SET spouse_id = '88f729e3-7586-49e8-a7f5-ff8ac7bca5cb' WHERE id = 'cda888cd-6996-4f6e-a1f0-a7d4eed04285';
  UPDATE public.profiles SET spouse_id = 'cda888cd-6996-4f6e-a1f0-a7d4eed04285' WHERE id = '88f729e3-7586-49e8-a7f5-ff8ac7bca5cb';
  UPDATE public.profiles SET spouse_id = 'd3062ce1-81b4-4795-a533-de12931f2320' WHERE id = '4e89d3dc-6c15-433c-9003-ec23404704c1';
  UPDATE public.profiles SET spouse_id = '4e89d3dc-6c15-433c-9003-ec23404704c1' WHERE id = 'd3062ce1-81b4-4795-a533-de12931f2320';
  UPDATE public.profiles SET spouse_id = 'b6692a55-d3ea-415e-a366-55754965a0af' WHERE id = '908e6a0e-6c72-4e5a-9813-cca396740cb2';
  UPDATE public.profiles SET spouse_id = '908e6a0e-6c72-4e5a-9813-cca396740cb2' WHERE id = 'b6692a55-d3ea-415e-a366-55754965a0af';
  UPDATE public.profiles SET spouse_id = '020fab36-7f91-4da1-b9c7-cc0a6c86131d' WHERE id = '2876eca3-511f-4ce1-bf54-e33cb81e8393';
  UPDATE public.profiles SET spouse_id = '2876eca3-511f-4ce1-bf54-e33cb81e8393' WHERE id = '020fab36-7f91-4da1-b9c7-cc0a6c86131d';
  UPDATE public.profiles SET spouse_id = '94bd167e-c692-43bb-9083-413b723a3c46' WHERE id = 'c037ee51-bdc5-4495-9ba2-f735467eda2f';
  UPDATE public.profiles SET spouse_id = 'c037ee51-bdc5-4495-9ba2-f735467eda2f' WHERE id = '94bd167e-c692-43bb-9083-413b723a3c46';
  UPDATE public.profiles SET father_id = '23bd5f9b-0dec-4888-bf3b-c6d78a74a8dc', mother_id = 'fe51e018-12b5-4ca2-9164-ade04b45ea55' WHERE id = 'aaf5e5aa-b3b3-4f56-8884-0ca9b6ff98d2';
  UPDATE public.profiles SET father_id = '87ccf9ea-c9af-475b-8d80-2fe92f9b5c8c', mother_id = 'b79deef6-8e02-4da3-8996-4a68d349a5f6' WHERE id = '21382e4a-8fd4-4ec9-9df2-bf9adaba9dac';
  UPDATE public.profiles SET father_id = '41538203-0a7e-426e-9f6e-176315fa44a5', mother_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = 'ba4715d3-dafd-4c10-bec8-205b39e154a5';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'b42b968a-b5f3-4b49-a9c1-39fcf5b5e928' WHERE id = '915cf368-3a76-477f-8f7e-3c56b2602b24';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'b42b968a-b5f3-4b49-a9c1-39fcf5b5e928' WHERE id = '2fb3c448-d198-4c58-b50f-532032d13e8e';
  UPDATE public.profiles SET father_id = '831e59c6-147c-4042-a81c-bc3f19f6ea36', mother_id = '9996439c-760a-4ee1-9278-26091fb1988f' WHERE id = '58cf7bf8-953b-4a7b-b2a9-8f0fc0975084';
  UPDATE public.profiles SET father_id = '831e59c6-147c-4042-a81c-bc3f19f6ea36', mother_id = '9996439c-760a-4ee1-9278-26091fb1988f' WHERE id = 'bce95976-eed0-4b1b-8c6b-8efe0f6f1d18';
  UPDATE public.profiles SET father_id = '4156a63d-cfd6-443f-8f75-94a85a73bc40', mother_id = '1a803e04-1fc7-460e-b5bc-1b8d294dec66' WHERE id = 'e2a08832-e454-4de2-8b0d-10b59362e49b';
  UPDATE public.profiles SET father_id = '4156a63d-cfd6-443f-8f75-94a85a73bc40', mother_id = '1a803e04-1fc7-460e-b5bc-1b8d294dec66' WHERE id = 'f002bd09-01c5-4132-9ffa-2410534196d5';
  UPDATE public.profiles SET father_id = '07ddb69d-a9f8-4284-8ab6-54d2409fda68', mother_id = '58ad8446-19dd-4099-bb89-5c27a099aacc' WHERE id = '557bc446-6c90-4815-b650-e1e3c9299eeb';
  UPDATE public.profiles SET father_id = '07ddb69d-a9f8-4284-8ab6-54d2409fda68', mother_id = '58ad8446-19dd-4099-bb89-5c27a099aacc' WHERE id = '41984054-409f-4f5b-a416-2a457b27867a';
  UPDATE public.profiles SET father_id = 'dbc8c225-9ea2-4c3d-a5e4-e4c55a92dc56', mother_id = 'ea84cd9e-0fb3-41d2-ab96-c9543ff1c59e' WHERE id = '9272fd6c-c4e0-4df3-9064-266ead281479';
  UPDATE public.profiles SET father_id = 'dbc8c225-9ea2-4c3d-a5e4-e4c55a92dc56', mother_id = 'ea84cd9e-0fb3-41d2-ab96-c9543ff1c59e' WHERE id = '7fe3ee6e-1682-4af1-995b-d80d6b14033d';
  UPDATE public.profiles SET father_id = '8c776d66-666f-4f16-94b1-772ec6dbd3a5', mother_id = '1ba39a4d-451d-450f-8338-69cfb187defd' WHERE id = '2105f44b-d2b2-4cb6-9c20-ea411fae11ed';
  UPDATE public.profiles SET father_id = '8c776d66-666f-4f16-94b1-772ec6dbd3a5', mother_id = '1ba39a4d-451d-450f-8338-69cfb187defd' WHERE id = '70af37f8-013e-4740-a3b0-71dd1bf3adb7';
  UPDATE public.profiles SET father_id = '8c776d66-666f-4f16-94b1-772ec6dbd3a5', mother_id = '1ba39a4d-451d-450f-8338-69cfb187defd' WHERE id = '56e83202-89ad-409d-a988-1257989ea096';
  UPDATE public.profiles SET father_id = 'deb039b9-2c43-4b85-a74a-a3d4886969a8', mother_id = 'da9efe8a-2833-40d3-a43d-0143dc822d90' WHERE id = 'baf63c47-7914-4719-962d-5827d78c9ffb';
  UPDATE public.profiles SET father_id = 'deb039b9-2c43-4b85-a74a-a3d4886969a8', mother_id = 'da9efe8a-2833-40d3-a43d-0143dc822d90' WHERE id = '2fba4517-8374-46e1-b278-154ea6e2c80e';
  UPDATE public.profiles SET father_id = 'deb039b9-2c43-4b85-a74a-a3d4886969a8', mother_id = 'da9efe8a-2833-40d3-a43d-0143dc822d90' WHERE id = '29b270b9-3d7c-46ac-95a4-2755825d5420';
  UPDATE public.profiles SET father_id = 'fa76f2d1-ddf1-4f9b-930b-78716a3f9eec', mother_id = '7e006f19-2157-49d2-9281-fbd612b85730' WHERE id = '5376f2b1-22d0-46e0-b6e9-49afde19830b';
  UPDATE public.profiles SET father_id = 'fa76f2d1-ddf1-4f9b-930b-78716a3f9eec', mother_id = '7e006f19-2157-49d2-9281-fbd612b85730' WHERE id = '053498e9-b39c-465e-800f-fdcd995b0e67';
  UPDATE public.profiles SET father_id = '3cce93d3-8d87-4935-867c-cd4ca496d75c', mother_id = '1f11629a-6d93-402d-ac55-5ee99afea65a' WHERE id = 'd9b833e7-3a2a-42e4-9a31-1ff994e370e1';
  UPDATE public.profiles SET father_id = '3cce93d3-8d87-4935-867c-cd4ca496d75c', mother_id = '1f11629a-6d93-402d-ac55-5ee99afea65a' WHERE id = 'fdf67716-b692-4b04-a2d3-e1f9dde50c59';
  UPDATE public.profiles SET father_id = '8976bfcd-ce49-4c0c-b03f-d8f8d6d2aeb8', mother_id = '9394181d-3464-408d-a3bd-bb935dbe3b32' WHERE id = 'a23ae893-9aa5-444f-8987-68b2ebbcfea4';
  UPDATE public.profiles SET father_id = '8976bfcd-ce49-4c0c-b03f-d8f8d6d2aeb8', mother_id = '9394181d-3464-408d-a3bd-bb935dbe3b32' WHERE id = '7b30110e-468e-4a89-b0ee-3815befe8175';
  UPDATE public.profiles SET father_id = 'c5a32184-3d3e-455b-a177-c1ccf55f0511', mother_id = 'ae582e8f-fece-45ed-b752-3460084f0213' WHERE id = 'a6c53dcc-9b74-406f-9c63-f9fc6bcbdd7e';
  UPDATE public.profiles SET father_id = '702dfacb-7739-4b6a-bce8-84b1d0a14f0f', mother_id = 'e7b36a58-1821-4656-877b-41b87727603c' WHERE id = 'a37ca909-88b0-44c4-a92b-f713f5a7eb8d';
  UPDATE public.profiles SET father_id = '25c6bce5-0268-4b7b-8a5a-56a672f2afd4', mother_id = 'adca2ec6-fd09-486d-bd25-8a5b4bcaf02d' WHERE id = 'ed6b30b7-982b-48d5-927a-85456a41f266';
  UPDATE public.profiles SET father_id = '125e543a-302f-433b-be68-a09e63c507a9', mother_id = 'e722fd77-ec0b-4545-bde5-444e71101dfd' WHERE id = '8517e549-b579-4402-86f5-0b0855d62962';
  UPDATE public.profiles SET father_id = '2139cc2a-b8fb-432b-b0d4-da50222acc48', mother_id = '642fc83d-6711-47e5-a177-6601936cbba1' WHERE id = 'cfdfe0d1-e7e7-4577-96bb-d04716b3a83e';
  UPDATE public.profiles SET father_id = NULL, mother_id = '272c6631-a509-4fd6-ad4b-c8cdeb57120e' WHERE id = '529d7a2d-cb61-4dd8-9b1c-fa30265d39c8';
  UPDATE public.profiles SET father_id = '0867a620-f94b-4f40-bd61-953032e28ec0', mother_id = '6d2cc23c-fba4-47e9-83ac-a621040cecc5' WHERE id = 'ab9589c3-52f2-43c8-9ad1-128ed4a9ed1a';
  UPDATE public.profiles SET father_id = '0867a620-f94b-4f40-bd61-953032e28ec0', mother_id = '6d2cc23c-fba4-47e9-83ac-a621040cecc5' WHERE id = '69ba3739-912c-47a0-97b7-6e8832b54c64';
  UPDATE public.profiles SET father_id = 'b51a6cfe-82cc-46e0-b163-256680d98407', mother_id = '14897482-dd97-4401-82d1-ba8e0b9ed06d' WHERE id = 'a3933113-4ab7-4ef5-8666-f8857be95db2';
  UPDATE public.profiles SET father_id = 'd92eb4ed-858b-4c09-ae09-3306f30f63fd', mother_id = '0dd7e454-0797-491c-8fe3-3475b659065c' WHERE id = '33c3cb37-6fa2-4063-98a7-13ce081e1191';
  UPDATE public.profiles SET father_id = '40fffba6-b4fd-4fe7-b10b-95ccccf3776b', mother_id = 'bed3384b-b1cc-4c02-a002-6214c87b050b' WHERE id = 'bff87838-abd9-46f4-8aef-5ee7530edfc4';
  UPDATE public.profiles SET father_id = '40fffba6-b4fd-4fe7-b10b-95ccccf3776b', mother_id = 'bed3384b-b1cc-4c02-a002-6214c87b050b' WHERE id = '8f8a7f9b-19d0-4dd5-a941-dfc2930171d6';
  UPDATE public.profiles SET father_id = 'e1bb5bee-f50b-4fd2-b81b-9358977cfd20', mother_id = '6f3a51d6-af0d-456a-8227-4b82351bc7ed' WHERE id = 'a5fa06f0-a3b8-488c-a24a-21266eaf2b40';
  UPDATE public.profiles SET father_id = '71f43006-bb6e-440d-bb1a-2209585f1431', mother_id = 'd9d1717b-bab3-47ee-89fc-c35482d78999' WHERE id = 'a53e98f4-7a95-49b1-b3cd-093d1ac25158';
  UPDATE public.profiles SET father_id = '6dc72ec1-1e88-44ee-96b1-569b6a06e931', mother_id = 'a7583aa9-6991-4796-a3f9-38b34c58ce6d' WHERE id = '99be6504-c702-4136-9ba6-827b93a4a67f';
  UPDATE public.profiles SET father_id = '6dc72ec1-1e88-44ee-96b1-569b6a06e931', mother_id = 'a7583aa9-6991-4796-a3f9-38b34c58ce6d' WHERE id = '3d420810-dc4d-42b5-9e03-eecfbf114225';
  UPDATE public.profiles SET father_id = '68614af5-bb97-4eb4-a806-83b6b4c45379', mother_id = '775e0a4b-70a0-494f-b29b-3aad35c558c5' WHERE id = 'c3af21fa-bbb9-4f62-b2e7-ae151a7c12dc';
  UPDATE public.profiles SET father_id = 'd2089a49-259e-4892-9a84-fbcb7e915f9e', mother_id = '474c1aae-45b4-4128-a1f7-8c0b9bf2a3ce' WHERE id = 'dad33f58-b3c0-472f-bee9-256bd3e0b8c8';
  UPDATE public.profiles SET father_id = 'd2089a49-259e-4892-9a84-fbcb7e915f9e', mother_id = '474c1aae-45b4-4128-a1f7-8c0b9bf2a3ce' WHERE id = 'd9b07b7c-fa36-4595-b92d-bf7a2c1fdbe5';
  UPDATE public.profiles SET father_id = 'de0db994-0506-4e43-b721-141f1d8bdb48', mother_id = '360c341a-3bf4-4314-b55b-f74d3b59e1f3' WHERE id = '7042236a-9f19-429c-85cc-04c5dad769aa';
  UPDATE public.profiles SET father_id = 'de0db994-0506-4e43-b721-141f1d8bdb48', mother_id = '360c341a-3bf4-4314-b55b-f74d3b59e1f3' WHERE id = 'e1f7ca2c-69af-4210-8c96-00d9598a3a38';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'd4e6646b-e624-4737-8404-250150e042a5' WHERE id = 'de5694c4-4a09-44ef-9ac0-e220770589ca';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'd4e6646b-e624-4737-8404-250150e042a5' WHERE id = '6f8f6c75-5033-4a55-888e-0c871d6cf1b7';
  UPDATE public.profiles SET father_id = 'b16e6ebe-42d3-4e27-9ff1-254bba818ee0', mother_id = 'edc19318-a69b-4db3-a2e2-7c9b2932d654' WHERE id = '5a761c43-04bf-4f31-b434-3524c3e40646';
  UPDATE public.profiles SET father_id = '1761642d-1189-4fe0-b79c-eafc71831e79', mother_id = '0d371dcc-40d7-4e2f-9de5-8922139c8b92' WHERE id = '0df8e0aa-c692-4ab3-b2a9-7411b514db6f';
  UPDATE public.profiles SET father_id = 'dd6a067d-0080-4f7e-bddc-cff252ae6682', mother_id = 'c0b8d474-507e-4b27-bac5-ccacaa05fa73' WHERE id = 'fe7c93c0-4bb0-4616-a91a-e1f59e567478';
  UPDATE public.profiles SET father_id = 'dd6a067d-0080-4f7e-bddc-cff252ae6682', mother_id = 'c0b8d474-507e-4b27-bac5-ccacaa05fa73' WHERE id = '5e65ad20-51be-47a7-b97a-7ceda57183cf';
  UPDATE public.profiles SET father_id = '744ca85f-dba9-4219-acb5-fcfaf1f5978c', mother_id = '70c49972-7aad-4029-9b20-74076b37f028' WHERE id = '1a473189-1e8f-47d0-bd72-efa4dfb348ae';
  UPDATE public.profiles SET father_id = '13c6339c-9465-4a0f-8ca0-0f4f0831b509', mother_id = '19b30595-09ac-4f93-894a-1ceedef35175' WHERE id = '94b81417-d088-4b6a-aa12-bf0835c4a2bd';
  UPDATE public.profiles SET father_id = '13c6339c-9465-4a0f-8ca0-0f4f0831b509', mother_id = '19b30595-09ac-4f93-894a-1ceedef35175' WHERE id = '34ecb3c7-74a7-4088-bbcc-144214f72813';
  UPDATE public.profiles SET father_id = '00f4778b-c13f-443b-8f3b-d0b094875c04', mother_id = 'd64395ae-9107-4a15-b6be-c339264d6f3e' WHERE id = '31f4f517-90cb-4b29-a722-d0c624827352';
  UPDATE public.profiles SET father_id = '9438c0a2-be20-4658-b485-3c2b33bb472d', mother_id = '1273ca07-f66e-4498-b69d-6314956f1dcc' WHERE id = 'feb3706a-0dbc-421c-b907-015f0fa3d935';
  UPDATE public.profiles SET father_id = '2805af4b-4afd-4694-846c-4f7a8dbc5f86', mother_id = 'd0efb40a-1e42-4d2c-a201-750031eeaf16' WHERE id = '1c8a03df-e828-4c54-986e-b10c83e2a75c';
  UPDATE public.profiles SET father_id = '2805af4b-4afd-4694-846c-4f7a8dbc5f86', mother_id = 'd0efb40a-1e42-4d2c-a201-750031eeaf16' WHERE id = '0e12c45b-851a-4d82-939a-0bb025f3f997';
  UPDATE public.profiles SET father_id = 'a353767c-9979-4023-a653-40cc2202ca2c', mother_id = '9af18973-f83c-4eca-9643-9fe7564ff0d2' WHERE id = '26d99b5a-3d64-41f8-8c18-fb8a79ae96e5';
  UPDATE public.profiles SET father_id = 'a353767c-9979-4023-a653-40cc2202ca2c', mother_id = '9af18973-f83c-4eca-9643-9fe7564ff0d2' WHERE id = '26ed3d69-7653-46e6-b02e-3e41f66ed7f3';
  UPDATE public.profiles SET father_id = '5a2883f5-144e-4b79-a8a5-4badd593a645', mother_id = 'b3346ac1-df4f-4038-acf3-a5a3e5b13347' WHERE id = '9863a27e-45f0-4c72-b394-f5cf0eb5923d';
  UPDATE public.profiles SET father_id = '9ab5e99a-a169-4984-b54e-2027ba37cc36', mother_id = 'e2c8d6e5-c6fb-4744-bb9a-e0182140abb8' WHERE id = '0c82ea83-5f16-4a45-b1e7-b99e1d941b4f';
  UPDATE public.profiles SET father_id = 'c525665c-41c9-428f-b2bf-19f75c3273e3', mother_id = '4da0d483-7562-4aa3-8ce1-bae3cf26d0ea' WHERE id = '5a5c0fdd-a581-41b9-b347-00e02d8febc2';
  UPDATE public.profiles SET father_id = 'c525665c-41c9-428f-b2bf-19f75c3273e3', mother_id = '4da0d483-7562-4aa3-8ce1-bae3cf26d0ea' WHERE id = '9e1c75ea-6a67-4d38-9238-6d38ef75fb06';
  UPDATE public.profiles SET father_id = 'cf1346c9-c3bb-4a47-a31c-8c1f77324d4a', mother_id = 'd1c722d8-77f0-42a3-884e-1137f1d91cc0' WHERE id = '61cefda3-feab-46ab-bb34-095634d5a25e';
  UPDATE public.profiles SET father_id = '0ca60d3b-1d10-433a-80ef-5c6b44c5f856', mother_id = 'f9c5dcae-bcd0-409a-bec0-107b57f022ea' WHERE id = 'a9fa1bb6-eff3-42fc-b88b-d92b771b9180';
  UPDATE public.profiles SET father_id = 'afc0ea06-9e6e-416b-9323-9a512af12fd1', mother_id = '9cf018e2-8a26-4a6c-9c19-2a7218850108' WHERE id = '715a65a9-9f5e-4183-9221-2801902de422';
  UPDATE public.profiles SET father_id = 'afc0ea06-9e6e-416b-9323-9a512af12fd1', mother_id = '9cf018e2-8a26-4a6c-9c19-2a7218850108' WHERE id = '6c3875b3-c265-427f-ac39-2dc4152f4bd0';
  UPDATE public.profiles SET father_id = '417e8bea-be9f-40b2-a359-ba75007a0ac4', mother_id = '2bf2e6ff-2041-4e56-9a02-89a1f6940655' WHERE id = '4bc2b2ab-8fa9-4d0a-aebf-62242e45e599';
  UPDATE public.profiles SET father_id = '417e8bea-be9f-40b2-a359-ba75007a0ac4', mother_id = '2bf2e6ff-2041-4e56-9a02-89a1f6940655' WHERE id = '9a8f086a-2a27-43e3-ae74-d985189cf57b';
  UPDATE public.profiles SET father_id = '63433d51-1305-46ac-9be8-c4a6f0e3b2a0', mother_id = 'ebccc2ac-a542-43a8-8074-06124a38cbc3' WHERE id = '1a1aa17e-1e40-43ba-be3c-d1233180b37f';
  UPDATE public.profiles SET father_id = '63433d51-1305-46ac-9be8-c4a6f0e3b2a0', mother_id = 'ebccc2ac-a542-43a8-8074-06124a38cbc3' WHERE id = 'c3e9e50a-771d-4b61-960e-1e3497d7e738';
  UPDATE public.profiles SET father_id = NULL, mother_id = '493d0e03-fd47-48d0-a921-7d1a07835444' WHERE id = '3f34f2a2-21ca-40e6-92c0-c8b63b7af9b0';
  UPDATE public.profiles SET father_id = '08b473e2-eaf9-44ef-84eb-6f02b72e4a25', mother_id = 'df3db365-38ea-4aca-abeb-c4c4a2207333' WHERE id = '7d775daf-ccf6-4977-977a-fe015751b1d3';
  UPDATE public.profiles SET father_id = 'b21328c6-5e07-41c1-a852-50a44cc78f53', mother_id = '9ce2ff98-f302-4130-93d2-45942b07913c' WHERE id = '6b506bab-3ceb-48d4-9ca0-8efad398eae6';
  UPDATE public.profiles SET father_id = '69b48c21-3834-4c15-aa7c-585de935dac7', mother_id = 'f603b12a-a7c3-4e06-ae3c-9925ad08fcea' WHERE id = '9bc1eb46-0ea5-40bd-ae7d-de083ce66d20';
  UPDATE public.profiles SET father_id = '69b48c21-3834-4c15-aa7c-585de935dac7', mother_id = 'f603b12a-a7c3-4e06-ae3c-9925ad08fcea' WHERE id = '838deeec-42e3-4c82-9aca-30c7c8b660df';
  UPDATE public.profiles SET father_id = '9ec0d723-674b-4224-bd42-d046f79d6910', mother_id = '01a42d7a-9374-475c-83c2-b2c5c75af0a6' WHERE id = '78eabb9c-bc6e-467a-93ed-9d879a2490d5';
  UPDATE public.profiles SET father_id = '1f54b7ab-e0c3-427b-b925-58e81d0b821a', mother_id = '5f633223-b89e-46ec-bd19-e1ef8f9b286b' WHERE id = 'b979a29c-5f5e-4b42-ab28-228966f55bde';
  UPDATE public.profiles SET father_id = '90cdc2d3-2770-44fc-81a7-cd0701bb68a4', mother_id = 'a3a1c2d2-6b49-44c2-92d6-e47dad320e98' WHERE id = 'a8c9400a-bd69-4622-a2a3-03256f1b59ee';
  UPDATE public.profiles SET father_id = '8b571057-7c94-4269-81a7-a6fb34dd1373', mother_id = '77ffe695-e38b-4cab-a160-59fed1eb0e70' WHERE id = '36eadb01-e784-4323-bfea-a0c338661606';
  UPDATE public.profiles SET father_id = '8b571057-7c94-4269-81a7-a6fb34dd1373', mother_id = '77ffe695-e38b-4cab-a160-59fed1eb0e70' WHERE id = 'ba8976aa-e017-4088-bd2e-1e243a27f5d6';
  UPDATE public.profiles SET father_id = '8b571057-7c94-4269-81a7-a6fb34dd1373', mother_id = '77ffe695-e38b-4cab-a160-59fed1eb0e70' WHERE id = 'f65f52ba-68a3-4389-aa17-66e3de488a69';
  UPDATE public.profiles SET father_id = '1d9f23a3-43a1-4fd4-b1a4-357a79842155', mother_id = '409646e0-bbab-49d8-86d9-94df0c8ad46a' WHERE id = '3841be2a-af59-4e6f-ba10-35b90a91b39e';
  UPDATE public.profiles SET father_id = '1d9f23a3-43a1-4fd4-b1a4-357a79842155', mother_id = '409646e0-bbab-49d8-86d9-94df0c8ad46a' WHERE id = '65168bb1-4eae-4179-8e1a-99900496ee0e';
  UPDATE public.profiles SET father_id = '1d9f23a3-43a1-4fd4-b1a4-357a79842155', mother_id = '409646e0-bbab-49d8-86d9-94df0c8ad46a' WHERE id = '99a660a9-c04c-4ee6-8b03-45d55309b4a9';
  UPDATE public.profiles SET father_id = '085fd5cd-72d7-4435-aa37-050a5733b4f3', mother_id = '03f38c79-742f-4e08-8b12-51ddda20cc5a' WHERE id = '7dfe1f40-15d7-41d7-b38d-b40edb925636';
  UPDATE public.profiles SET father_id = '7ac9f5be-d838-46d1-9cd2-790674800465', mother_id = '15cabd86-de1e-4944-8c19-384bc67c087b' WHERE id = '33c9a9f6-4073-43c0-8815-9cd7acbc500d';
  UPDATE public.profiles SET father_id = '7ac9f5be-d838-46d1-9cd2-790674800465', mother_id = '15cabd86-de1e-4944-8c19-384bc67c087b' WHERE id = 'd32944f6-f859-4093-8f1a-7c4f7d2fd9cf';
  UPDATE public.profiles SET father_id = '6a7a69f2-740b-45a7-8399-3db32c96ac8a', mother_id = '84fcc302-3b37-43c3-b3ff-d6e5978183c6' WHERE id = 'f2b9159e-8d29-491b-a5aa-25446a426482';
  UPDATE public.profiles SET father_id = '49061166-5ee7-46aa-ad69-c830e8040bb9', mother_id = 'b33b9b1e-4817-4d06-8c51-b6a55293b79c' WHERE id = '3740abe5-1fba-4a4b-a766-ead9e7b96e34';
  UPDATE public.profiles SET father_id = '49061166-5ee7-46aa-ad69-c830e8040bb9', mother_id = 'b33b9b1e-4817-4d06-8c51-b6a55293b79c' WHERE id = '413d642a-2bef-4c76-8fc3-49d13b80a213';
  UPDATE public.profiles SET father_id = 'f4ae810a-a538-4628-84ee-b081625f4e1c', mother_id = 'fec8cecd-1a12-47a6-9f39-5d8dd95d2066' WHERE id = '318b2c39-07c1-4beb-bf9a-2464253c4c60';
  UPDATE public.profiles SET father_id = 'f4ae810a-a538-4628-84ee-b081625f4e1c', mother_id = 'fec8cecd-1a12-47a6-9f39-5d8dd95d2066' WHERE id = 'b8a334d2-b79d-4079-8b72-596a2e9d7adb';
  UPDATE public.profiles SET father_id = 'b6f75b58-ff57-47d5-9d53-7ee7617b57e7', mother_id = '77948d79-6a1e-4a9b-8ca1-7d1683c1e8ae' WHERE id = '2defd892-a663-4a86-a58d-58b35c3fd551';
  UPDATE public.profiles SET father_id = '6cd9c6dd-091b-4458-be1b-649c9cfbf5dc', mother_id = 'a6e41747-32b3-4124-b6a8-08063bcf1362' WHERE id = '86e27d3e-8314-406f-9cc3-4cd0f579c56b';
  UPDATE public.profiles SET father_id = 'b8d744bf-242e-4c11-a7de-29a8e19236e4', mother_id = 'e805b9ca-eaca-42a0-9a18-153be8c8d218' WHERE id = '17e8b845-f21e-4fb8-bce3-48b7e85d7297';
  UPDATE public.profiles SET father_id = 'ac4683a2-4a53-46f2-be91-8a06195a7a67', mother_id = 'f57e52f9-0018-446a-9862-45fc2ee9adfc' WHERE id = '986f57e1-6461-4afb-bef6-b5adbe9e3def';
  UPDATE public.profiles SET father_id = NULL, mother_id = '68b3e7f5-2706-4dda-8732-f863519dc42e' WHERE id = '96457c4e-0c26-4fd4-b9cc-3b85c2930dcb';
  UPDATE public.profiles SET father_id = NULL, mother_id = '68b3e7f5-2706-4dda-8732-f863519dc42e' WHERE id = '94f28d5c-67be-450e-b946-37149156fb40';
  UPDATE public.profiles SET father_id = 'a3572e00-8fb9-496f-8d39-e2e39c35f314', mother_id = '90ed5647-d80f-4994-a497-488663a76f6a' WHERE id = '8a319402-8ada-4a10-bbec-49bb860534af';
  UPDATE public.profiles SET father_id = 'a3572e00-8fb9-496f-8d39-e2e39c35f314', mother_id = '90ed5647-d80f-4994-a497-488663a76f6a' WHERE id = '7a7829a1-d58d-4ce2-ba69-a62774218d81';
  UPDATE public.profiles SET father_id = 'a3572e00-8fb9-496f-8d39-e2e39c35f314', mother_id = '90ed5647-d80f-4994-a497-488663a76f6a' WHERE id = 'a657daa7-e94d-48c3-a424-dbc8b4eaeca3';
  UPDATE public.profiles SET father_id = 'e12eba1f-e0b9-4e48-87a0-e4b6722f4f3b', mother_id = '412281ef-14cc-4bf5-8c8c-3a99801ac0c5' WHERE id = 'a6ef5c5f-36be-45f4-a7b4-ac7e8f9f83ef';
  UPDATE public.profiles SET father_id = 'e12eba1f-e0b9-4e48-87a0-e4b6722f4f3b', mother_id = '412281ef-14cc-4bf5-8c8c-3a99801ac0c5' WHERE id = '3e56fc68-c292-4638-9aae-7b9caad492ab';
  UPDATE public.profiles SET father_id = 'd36ce245-1130-49a0-ac1e-e165e9edce0c', mother_id = 'e90f4120-ed2f-4388-9983-c669dc5ed409' WHERE id = '7e17132c-bb7d-4092-8bc2-4287069bda10';
  UPDATE public.profiles SET father_id = 'bd688ad9-23df-474b-aac0-fc8e23ceae9e', mother_id = 'f7d55a4f-8e34-4cf0-81ce-b69e9c196e14' WHERE id = '218bb895-e627-4cd2-9838-597c68681e15';
  UPDATE public.profiles SET father_id = '8ae246e6-0b5d-4075-997c-7e6b6c9ca984', mother_id = '07505fcb-bbab-4c23-a738-4127501f402e' WHERE id = '35df79d8-19ec-40b5-9985-4def6cfcf4ba';
  UPDATE public.profiles SET father_id = '8ae246e6-0b5d-4075-997c-7e6b6c9ca984', mother_id = '07505fcb-bbab-4c23-a738-4127501f402e' WHERE id = '41520468-e8fc-4f30-8432-5bef0e656ba3';
  UPDATE public.profiles SET father_id = '8ae246e6-0b5d-4075-997c-7e6b6c9ca984', mother_id = '07505fcb-bbab-4c23-a738-4127501f402e' WHERE id = '95050668-c07e-43f4-9927-5aa3ee62d4b9';
  UPDATE public.profiles SET father_id = 'e14d477f-7d43-4b78-8c59-309bb9e43c8e', mother_id = '4842d3df-262e-4f5f-a9e4-e94e264f8942' WHERE id = 'ac0b9f71-629b-4624-a2fe-5b4ea4c87e87';
  UPDATE public.profiles SET father_id = '9b7e123e-8a4b-4cbf-b1ea-91018cc09710', mother_id = '59da7ad8-e573-43a6-b2b6-0cc612f75412' WHERE id = '6ff366f4-e6d3-4212-bd49-f25a5228a488';
  UPDATE public.profiles SET father_id = '9b7e123e-8a4b-4cbf-b1ea-91018cc09710', mother_id = '59da7ad8-e573-43a6-b2b6-0cc612f75412' WHERE id = '31a63e84-70b9-4dcb-9d8d-745170332492';
  UPDATE public.profiles SET father_id = '2b3352f4-d8db-4322-a1b3-b16625e164b9', mother_id = '636c7fb2-7f99-43d0-80a6-f29da2a21526' WHERE id = '83957f34-947c-417b-855a-9e9c98dee6b7';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'ba1c755d-4d4f-4032-b825-2a7647ad9c2e' WHERE id = 'd27fcaa9-e95b-4293-82e7-2fcf807a0d9a';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'ba1c755d-4d4f-4032-b825-2a7647ad9c2e' WHERE id = '7f847425-4ad3-46d5-bd70-faedda8adccd';
  UPDATE public.profiles SET father_id = 'ee643bef-3d93-486f-be03-1ec6e30b9fa7', mother_id = 'e898433b-71b2-495a-b778-88cffac37816' WHERE id = '013ca4c2-23ec-4927-8870-33ff6a9e86f1';
  UPDATE public.profiles SET father_id = '3f756cdb-0c88-474c-961e-16d00943f790', mother_id = '5e780f3e-0a2b-4e61-8dc3-0b45f686d554' WHERE id = 'cabf2f97-704d-41ec-be3a-3d61ce65b308';
  UPDATE public.profiles SET father_id = '03283ddf-1330-468f-bb6d-8a9b5f9b6ede', mother_id = 'be24d372-c67b-4814-84b5-dea54dca0c36' WHERE id = '7a97bef5-e295-4445-bb5f-73b5cb909c8b';
  UPDATE public.profiles SET father_id = '03283ddf-1330-468f-bb6d-8a9b5f9b6ede', mother_id = 'be24d372-c67b-4814-84b5-dea54dca0c36' WHERE id = '88e17c40-137a-445c-b6a0-73c95fc9738b';
  UPDATE public.profiles SET father_id = '92e26edd-467f-41f2-8fa7-438886aee0c4', mother_id = 'bb5c9636-55d4-4df0-92e4-3b8d60cfc829' WHERE id = '37187d46-cba3-4c95-8bab-0f5f04a5fa01';
  UPDATE public.profiles SET father_id = '0b41474e-5a7c-41f9-8cac-2c94dbcb5b02', mother_id = 'bfaf2255-9cea-451d-ba83-65873c2525f1' WHERE id = '0327b2c7-2b8c-4079-9203-4c9275ba120b';
  UPDATE public.profiles SET father_id = '6504260b-9f34-4c87-b35f-331b555967cb', mother_id = '908d2ecc-65f7-4160-b782-30f6e0fe8559' WHERE id = 'f35c8560-6530-4238-bc60-6f861fb8de96';
  UPDATE public.profiles SET father_id = '6504260b-9f34-4c87-b35f-331b555967cb', mother_id = '908d2ecc-65f7-4160-b782-30f6e0fe8559' WHERE id = 'a37f60bf-47c8-4aa0-9681-9502f1d9cf70';
  UPDATE public.profiles SET father_id = 'fd388df9-b123-4c2d-b18a-7f2d869bcee9', mother_id = '0b3d3917-9a4c-4f06-b6e5-2bf0442ed694' WHERE id = 'e8ff1aa2-e0fe-4dcf-9f30-e72a8b9c9dca';
  UPDATE public.profiles SET father_id = '2b313e6c-35af-4309-9170-a485fabb45e8', mother_id = '9b2e2647-6f18-4546-97e4-5c47ffb6805f' WHERE id = '45576048-b424-4d53-9d88-e4308ac55741';
  UPDATE public.profiles SET father_id = 'c5ecb4b2-ef2d-465d-82c7-e860bc32c5e5', mother_id = NULL WHERE id = '42812fa4-c163-44d6-a74c-dbc554a44e3b';
  UPDATE public.profiles SET father_id = 'c5ecb4b2-ef2d-465d-82c7-e860bc32c5e5', mother_id = NULL WHERE id = '274d21ff-f182-4c57-8f95-8d06a31ac710';
  UPDATE public.profiles SET father_id = 'b9c372cd-0253-4162-8336-9a11ad7258cd', mother_id = 'ed6abaed-ed59-42db-bb8e-64d26b8ea1c1' WHERE id = 'bbfaa8e8-781a-4b42-9fac-a37cd6c46542';
  UPDATE public.profiles SET father_id = 'ceecba38-dbf1-4e71-9527-b75bca08248d', mother_id = 'c735630e-4256-4ec4-a557-d74b25ff1564' WHERE id = 'f5499f30-0123-42b6-b744-f16c50722a76';
  UPDATE public.profiles SET father_id = '311b2c8d-bd25-4bca-a569-257bcdf6583c', mother_id = '8bb8d56e-6b43-4997-a4ac-053b78ca0a9b' WHERE id = '62c7b3ef-9732-481c-aae3-37ec063ccb99';
  UPDATE public.profiles SET father_id = '311b2c8d-bd25-4bca-a569-257bcdf6583c', mother_id = '8bb8d56e-6b43-4997-a4ac-053b78ca0a9b' WHERE id = '6557adf5-8e87-474e-8883-bf1fa0ae18f2';
  UPDATE public.profiles SET father_id = 'bbb8a195-549d-46d6-96cf-84a45ec4f5ae', mother_id = '7c47fad3-84c7-49b7-b56b-ea9e470ca582' WHERE id = '4c0c9695-0939-44f0-965f-cb25fd8bb7a0';
  UPDATE public.profiles SET father_id = 'b521d801-f99a-4835-8b3e-a3625884da65', mother_id = 'a37df668-d01b-41f9-a54d-d326f2a17d3f' WHERE id = 'b028ead5-8ecf-421e-ab7e-8675231fd1da';
  UPDATE public.profiles SET father_id = 'b521d801-f99a-4835-8b3e-a3625884da65', mother_id = 'a37df668-d01b-41f9-a54d-d326f2a17d3f' WHERE id = '1309f57e-a4bd-440b-a7af-c982600700f2';
  UPDATE public.profiles SET father_id = 'c36f9d58-e6ae-447a-b8ad-be60805d9fa7', mother_id = '1c2406c3-adf3-4d5b-956d-ff488006f0d4' WHERE id = '2ea8ebfc-4d46-430b-a4f5-58b4721d4d2f';
  UPDATE public.profiles SET father_id = '6bf0a643-6a4e-4599-8f3e-6784437768d0', mother_id = '3b257027-3160-4e0f-bc58-0b6aa5813ff9' WHERE id = '6891fe8e-3abb-471c-a02e-be10435a3301';
  UPDATE public.profiles SET father_id = '462f996d-dbf5-471a-8cbb-db5e2144aa26', mother_id = '2cf0d866-0648-4ceb-9004-ba32cdc093b3' WHERE id = '6662b5c5-0b15-4a96-be3e-f94fc1393c59';
  UPDATE public.profiles SET father_id = '462f996d-dbf5-471a-8cbb-db5e2144aa26', mother_id = '2cf0d866-0648-4ceb-9004-ba32cdc093b3' WHERE id = 'e00093b5-0e0a-4562-8c58-990a77c29110';
  UPDATE public.profiles SET father_id = '54cb5c5a-153a-4dc4-bb2b-64d3a979b158', mother_id = '58e950e1-6ad8-40e7-89aa-8773d96bf0df' WHERE id = '8132f25c-541d-415e-b0d8-08ac92337875';
  UPDATE public.profiles SET father_id = '54cb5c5a-153a-4dc4-bb2b-64d3a979b158', mother_id = '58e950e1-6ad8-40e7-89aa-8773d96bf0df' WHERE id = '9a9caf5f-4d30-4599-bc87-74c8cd7a7aec';
  UPDATE public.profiles SET father_id = 'e788d9fe-04b1-4dd0-9ab0-09b3a2360ef1', mother_id = '7418d54e-e2af-49dd-8c1f-413289b4671f' WHERE id = '25f16537-4989-48ee-afb2-936ff389fbf1';
  UPDATE public.profiles SET father_id = 'e788d9fe-04b1-4dd0-9ab0-09b3a2360ef1', mother_id = '7418d54e-e2af-49dd-8c1f-413289b4671f' WHERE id = '83f17c9d-9955-4a25-8f48-ef5326a4fb2b';
  UPDATE public.profiles SET father_id = 'e788d9fe-04b1-4dd0-9ab0-09b3a2360ef1', mother_id = '7418d54e-e2af-49dd-8c1f-413289b4671f' WHERE id = '537ef7da-9bfb-47c2-85c5-3dec6e748d1a';
  UPDATE public.profiles SET father_id = 'e788d9fe-04b1-4dd0-9ab0-09b3a2360ef1', mother_id = '7418d54e-e2af-49dd-8c1f-413289b4671f' WHERE id = 'abfd8fea-dbdd-4b3f-b6dd-bfa31b1fe93f';
  UPDATE public.profiles SET father_id = '7ec438d7-bd9f-4c18-ae9c-e785ca10a5bd', mother_id = 'a5dbd7da-0387-44dd-9ec6-4a4e3dec3924' WHERE id = '65e727a5-9e8a-4c8b-8e20-73f8d36a550b';
  UPDATE public.profiles SET father_id = '908e6a0e-6c72-4e5a-9813-cca396740cb2', mother_id = 'b6692a55-d3ea-415e-a366-55754965a0af' WHERE id = '1023b947-a174-47d3-94c9-83da43276d79';

  -- ==========================================================================
  -- 7. ATUALIZAR DISCIPULADO (discipler_id)
  -- ==========================================================================

  UPDATE public.profiles SET discipler_id = '5407bf48-52d2-4fef-a85f-086f39640c4c' WHERE id = '71f8eedc-9d7b-48d1-991e-ae98013a5fbe';
  UPDATE public.profiles SET discipler_id = '19ec4776-52dc-43c8-8c08-e272cc157732' WHERE id = 'b7b9a6a9-483c-4652-9ce5-5ee31e7e949a';
  UPDATE public.profiles SET discipler_id = '2ee8740d-b1fe-4614-baf7-da870e0ac155' WHERE id = '1bc2068a-b1c1-4775-9a46-2437674461dc';
  UPDATE public.profiles SET discipler_id = '19ec4776-52dc-43c8-8c08-e272cc157732' WHERE id = 'bc3cc745-dcd0-4c79-b8a1-bde6e336b28f';
  UPDATE public.profiles SET discipler_id = '2ee8740d-b1fe-4614-baf7-da870e0ac155' WHERE id = 'd46c69da-3468-4e73-8d78-c1a6a8a50924';
  UPDATE public.profiles SET discipler_id = '19ec4776-52dc-43c8-8c08-e272cc157732' WHERE id = '2d0e7358-423b-4c27-b1bc-e4c6bc17b647';
  UPDATE public.profiles SET discipler_id = 'f57ad015-e7c3-438a-9f12-db36c09a4335' WHERE id = 'cfefe8cc-f85e-4427-ad60-149ae73e1dad';
  UPDATE public.profiles SET discipler_id = '41538203-0a7e-426e-9f6e-176315fa44a5' WHERE id = '5862029e-8e82-439b-a8e8-a45b3f954987';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = 'c9451d88-3d0b-4366-9dee-49bf4b1a665c';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = 'b42b968a-b5f3-4b49-a9c1-39fcf5b5e928';
  UPDATE public.profiles SET discipler_id = '41538203-0a7e-426e-9f6e-176315fa44a5' WHERE id = '1dce335d-9640-4178-8675-8a35bcef33f3';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = 'c53698e8-a13d-48a6-9f01-218732f58b3a';
  UPDATE public.profiles SET discipler_id = '41538203-0a7e-426e-9f6e-176315fa44a5' WHERE id = '284c583e-eeb5-4896-94c9-4ecfe43ba1bf';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = '1d94db5d-33e8-47c8-b74b-89c3baf318af';
  UPDATE public.profiles SET discipler_id = '41538203-0a7e-426e-9f6e-176315fa44a5' WHERE id = '831e59c6-147c-4042-a81c-bc3f19f6ea36';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = '9996439c-760a-4ee1-9278-26091fb1988f';
  UPDATE public.profiles SET discipler_id = '41538203-0a7e-426e-9f6e-176315fa44a5' WHERE id = '4156a63d-cfd6-443f-8f75-94a85a73bc40';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = '1a803e04-1fc7-460e-b5bc-1b8d294dec66';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = 'b80e234e-5b89-4200-84b6-0a5f0f1b6a25';
  UPDATE public.profiles SET discipler_id = '5407bf48-52d2-4fef-a85f-086f39640c4c' WHERE id = '60028e2c-f736-4a3c-8f3b-d3d4b0f5032c';
  UPDATE public.profiles SET discipler_id = '5862029e-8e82-439b-a8e8-a45b3f954987' WHERE id = '21bf9e0b-a641-4a24-8abe-be94e19aa01c';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = 'fde66a1a-78b6-4327-918e-187d1c6f1965';
  UPDATE public.profiles SET discipler_id = '5862029e-8e82-439b-a8e8-a45b3f954987' WHERE id = 'a6285c83-e760-4a9c-9c0d-364f54ebbdf0';
  UPDATE public.profiles SET discipler_id = 'fcf6ad83-5564-407a-a912-1d58481f6369' WHERE id = '48410ac0-1787-4c7e-a6e7-4e6806642850';
  UPDATE public.profiles SET discipler_id = '7d4694d8-84c5-4a1f-9ab4-f8e148296d02' WHERE id = '4effb9f2-0cff-4fa4-ac68-49a93c2628fa';
  UPDATE public.profiles SET discipler_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = 'a72d4939-2969-45b4-9e45-a4247325519b';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = 'fb825f48-ceee-4081-85e4-6dd94bca5a50';
  UPDATE public.profiles SET discipler_id = '1e7d0844-9b45-4144-8f6a-47e5eded8daa' WHERE id = '0f68b9d6-4519-49c0-80fb-ccd8f8054f42';
  UPDATE public.profiles SET discipler_id = 'a6285c83-e760-4a9c-9c0d-364f54ebbdf0' WHERE id = 'f17f1d00-d885-4ef9-b56b-b3dee6f7d281';
  UPDATE public.profiles SET discipler_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = '4db2d7d9-a30f-44c6-8615-a3f64bee5c01';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = 'ce3ad9d1-0ae8-4940-9b51-2519e39e712c';
  UPDATE public.profiles SET discipler_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = '91ca2fe2-9032-4d9c-a4c6-7969b4197f0f';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = 'eb53ac6a-789b-412b-aba3-e86e8a4566db';
  UPDATE public.profiles SET discipler_id = 'f57ad015-e7c3-438a-9f12-db36c09a4335' WHERE id = '7ac247cc-b99a-43b4-b54b-8fadf2432dee';
  UPDATE public.profiles SET discipler_id = '612d29d8-f49d-4e39-a109-673bf53aa47f' WHERE id = 'ac1fdb69-a924-4214-9205-52be933cdd77';
  UPDATE public.profiles SET discipler_id = '7ac247cc-b99a-43b4-b54b-8fadf2432dee' WHERE id = '03628cd7-f794-4b9b-9d3e-b0c6f8b0ea1e';
  UPDATE public.profiles SET discipler_id = 'ac1fdb69-a924-4214-9205-52be933cdd77' WHERE id = '163bc3f2-162a-4add-8746-5442599c1855';
  UPDATE public.profiles SET discipler_id = 'bb54e705-da5d-49f6-9810-4a1b6e45fd4a' WHERE id = 'a1d267e0-60bc-4f79-b56c-de041d22f9b6';
  UPDATE public.profiles SET discipler_id = 'f7eea24c-008a-41dd-9932-6503c9b9f7b3' WHERE id = '1e7d0844-9b45-4144-8f6a-47e5eded8daa';
  UPDATE public.profiles SET discipler_id = '41538203-0a7e-426e-9f6e-176315fa44a5' WHERE id = '46feee7e-f65c-4367-989d-d27a9a28c60f';
  UPDATE public.profiles SET discipler_id = 'e58d0305-1872-4e1a-8d0f-d9804c26d8cb' WHERE id = '46a2f154-615b-4f58-974e-332e17d3f528';
  UPDATE public.profiles SET discipler_id = 'a1d267e0-60bc-4f79-b56c-de041d22f9b6' WHERE id = '740e35a6-aa00-4aa8-a166-f3fcb1106267';
  UPDATE public.profiles SET discipler_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = 'd852000c-53c1-4b7a-bd16-6d81c145d5da';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = 'a05697b6-6904-45a7-88c3-b6b7098d96b1';
  UPDATE public.profiles SET discipler_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = 'fcf6ad83-5564-407a-a912-1d58481f6369';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = '7d4694d8-84c5-4a1f-9ab4-f8e148296d02';
  UPDATE public.profiles SET discipler_id = '740e35a6-aa00-4aa8-a166-f3fcb1106267' WHERE id = '531b1665-fd27-4591-af6d-f355deffc0c8';
  UPDATE public.profiles SET discipler_id = 'a1d267e0-60bc-4f79-b56c-de041d22f9b6' WHERE id = '07ddb69d-a9f8-4284-8ab6-54d2409fda68';
  UPDATE public.profiles SET discipler_id = '1e7d0844-9b45-4144-8f6a-47e5eded8daa' WHERE id = '58ad8446-19dd-4099-bb89-5c27a099aacc';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = '1782517b-7a4a-41d6-ac9d-ace9095fd531';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = 'fa88c3be-f2b6-4547-8af5-01c2104cdc53';
  UPDATE public.profiles SET discipler_id = '740e35a6-aa00-4aa8-a166-f3fcb1106267' WHERE id = '27065ca5-f568-4eac-b77a-7a8de42baa75';
  UPDATE public.profiles SET discipler_id = '9f207e7a-ec9f-45ac-a292-3cd93919221d' WHERE id = '220cf2c5-d1f4-417b-8045-d62cbe1f1658';
  UPDATE public.profiles SET discipler_id = 'bfaf2255-9cea-451d-ba83-65873c2525f1' WHERE id = '9f207e7a-ec9f-45ac-a292-3cd93919221d';
  UPDATE public.profiles SET discipler_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = 'dbc8c225-9ea2-4c3d-a5e4-e4c55a92dc56';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = 'ea84cd9e-0fb3-41d2-ab96-c9543ff1c59e';
  UPDATE public.profiles SET discipler_id = 'a1d267e0-60bc-4f79-b56c-de041d22f9b6' WHERE id = '1f80df5a-433f-4200-9325-d03c79743fbe';
  UPDATE public.profiles SET discipler_id = '220cf2c5-d1f4-417b-8045-d62cbe1f1658' WHERE id = '836aa21c-9e3a-4b07-80d8-5850c77d5550';
  UPDATE public.profiles SET discipler_id = '7d4694d8-84c5-4a1f-9ab4-f8e148296d02' WHERE id = '4ac72fae-635c-40cf-af54-657b5d2fdf42';
  UPDATE public.profiles SET discipler_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = 'd8896391-af7e-4956-9c68-2eb4fc530398';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = '364de290-003a-4eb6-b113-af145a2c2734';
  UPDATE public.profiles SET discipler_id = '46feee7e-f65c-4367-989d-d27a9a28c60f' WHERE id = '8c776d66-666f-4f16-94b1-772ec6dbd3a5';
  UPDATE public.profiles SET discipler_id = '46a2f154-615b-4f58-974e-332e17d3f528' WHERE id = '1ba39a4d-451d-450f-8338-69cfb187defd';
  UPDATE public.profiles SET discipler_id = '19ec4776-52dc-43c8-8c08-e272cc157732' WHERE id = 'f57ad015-e7c3-438a-9f12-db36c09a4335';
  UPDATE public.profiles SET discipler_id = '2ee8740d-b1fe-4614-baf7-da870e0ac155' WHERE id = '612d29d8-f49d-4e39-a109-673bf53aa47f';
  UPDATE public.profiles SET discipler_id = '19ec4776-52dc-43c8-8c08-e272cc157732' WHERE id = 'bb54e705-da5d-49f6-9810-4a1b6e45fd4a';
  UPDATE public.profiles SET discipler_id = '2ee8740d-b1fe-4614-baf7-da870e0ac155' WHERE id = 'f7eea24c-008a-41dd-9932-6503c9b9f7b3';
  UPDATE public.profiles SET discipler_id = 'bb54e705-da5d-49f6-9810-4a1b6e45fd4a' WHERE id = 'd92eb4ed-858b-4c09-ae09-3306f30f63fd';
  UPDATE public.profiles SET discipler_id = 'f7eea24c-008a-41dd-9932-6503c9b9f7b3' WHERE id = '0dd7e454-0797-491c-8fe3-3475b659065c';
  UPDATE public.profiles SET discipler_id = 'f57ad015-e7c3-438a-9f12-db36c09a4335' WHERE id = 'cda61385-c64a-463a-9ce6-31eef0d3ab34';
  UPDATE public.profiles SET discipler_id = '612d29d8-f49d-4e39-a109-673bf53aa47f' WHERE id = '6de44343-a9d4-4c3a-b5a7-398ed6e5fcaf';
  UPDATE public.profiles SET discipler_id = 'f57ad015-e7c3-438a-9f12-db36c09a4335' WHERE id = 'a31da5a4-deec-4d5c-b792-d528bcf4f10c';
  UPDATE public.profiles SET discipler_id = '612d29d8-f49d-4e39-a109-673bf53aa47f' WHERE id = 'b2264eb8-2acc-45fc-8683-6f5eb5e6543d';
  UPDATE public.profiles SET discipler_id = '612d29d8-f49d-4e39-a109-673bf53aa47f' WHERE id = '8957807a-e715-4d48-a8a6-3b33305425d3';
  UPDATE public.profiles SET discipler_id = '612d29d8-f49d-4e39-a109-673bf53aa47f' WHERE id = '5c140d14-54e9-4f14-b3ba-676d0d9a4fb3';
  UPDATE public.profiles SET discipler_id = 'f57ad015-e7c3-438a-9f12-db36c09a4335' WHERE id = '625835a3-2962-45c1-9971-7d369cf17589';
  UPDATE public.profiles SET discipler_id = '612d29d8-f49d-4e39-a109-673bf53aa47f' WHERE id = '80b7b173-3745-430a-bd84-80bec9ada5f8';
  UPDATE public.profiles SET discipler_id = '82f620bb-0d1c-4e61-8093-92d7ffed8d6e' WHERE id = 'c525665c-41c9-428f-b2bf-19f75c3273e3';
  UPDATE public.profiles SET discipler_id = '2f4f85aa-dec6-40a3-8468-0907a169020c' WHERE id = '4da0d483-7562-4aa3-8ce1-bae3cf26d0ea';
  UPDATE public.profiles SET discipler_id = '2f4f85aa-dec6-40a3-8468-0907a169020c' WHERE id = 'd1c722d8-77f0-42a3-884e-1137f1d91cc0';
  UPDATE public.profiles SET discipler_id = '2f4f85aa-dec6-40a3-8468-0907a169020c' WHERE id = '30820239-cfa7-40a1-b100-5f8f37acd1b2';
  UPDATE public.profiles SET discipler_id = '82f620bb-0d1c-4e61-8093-92d7ffed8d6e' WHERE id = '0ca60d3b-1d10-433a-80ef-5c6b44c5f856';
  UPDATE public.profiles SET discipler_id = '82f620bb-0d1c-4e61-8093-92d7ffed8d6e' WHERE id = 'afc0ea06-9e6e-416b-9323-9a512af12fd1';
  UPDATE public.profiles SET discipler_id = '2f4f85aa-dec6-40a3-8468-0907a169020c' WHERE id = '9cf018e2-8a26-4a6c-9c19-2a7218850108';
  UPDATE public.profiles SET discipler_id = '82f620bb-0d1c-4e61-8093-92d7ffed8d6e' WHERE id = '2a24006f-118f-4013-a767-6c8f87c5f161';
  UPDATE public.profiles SET discipler_id = '82f620bb-0d1c-4e61-8093-92d7ffed8d6e' WHERE id = '417e8bea-be9f-40b2-a359-ba75007a0ac4';
  UPDATE public.profiles SET discipler_id = '2f4f85aa-dec6-40a3-8468-0907a169020c' WHERE id = '2bf2e6ff-2041-4e56-9a02-89a1f6940655';
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
