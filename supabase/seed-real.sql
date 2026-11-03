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
  gabriel_id   uuid := '43dd9046-8575-4e3c-8e42-bcbaab61dc6d';
  fernando_id  uuid := 'cefd05cc-83a1-4c99-bb65-288ef974baa1';
  clara_id     uuid := '0173059d-1312-42d5-834f-d5025499ee10';
  flavio_id    uuid := '14f3b34a-e342-4671-9361-cf94df252307';
  marleide_id  uuid := 'e81475a5-a09d-4269-bae2-4b5f9009b7e8';

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

  INSERT INTO public.sectors (id, name, created_at) VALUES ('90f8f6d4-0ace-42c2-bd06-44637bc2d9b4', 'São Gabriel/Pampulha', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('86d95c36-0a6d-4e06-8575-caa66269c2c7', 'Venda Nova/Neves', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('6cee9dbd-eec7-422b-b178-65c4b6286aaf', 'Santa Luzia', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('9a5bba56-d9c2-4826-a232-399d70e2136c', 'Oeste', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('9c29966f-48ba-48fb-bea2-ada14a3649ad', 'Betim/Contagem', now());
  INSERT INTO public.sectors (id, name, created_at) VALUES ('0059dafa-e63c-46ff-b1fc-7868e8714b16', 'Fora da Localidade', now());

  -- ==========================================================================
  -- 3. CRIAÇÃO DOS GRUPOS CASEIROS (35 Grupos Reais das Planilhas)
  -- ==========================================================================

  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', '90f8f6d4-0ace-42c2-bd06-44637bc2d9b4', 'Solimões - BH - Bairro Solimões', 2, '19:30:00', -19.8392, -43.9185, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', '90f8f6d4-0ace-42c2-bd06-44637bc2d9b4', 'Heliópolis - BH - Bairro Heliópolis', 3, '19:30:00', -19.8425, -43.9482, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', '90f8f6d4-0ace-42c2-bd06-44637bc2d9b4', 'São Gabriel - BH - Região São Gabriel / Pampulha', 4, '19:30:00', -19.858, -43.916, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', '90f8f6d4-0ace-42c2-bd06-44637bc2d9b4', 'Santa Amélia - BH - Rua Pioneiros da Paz, Santa Amélia / Rua Hildebrando de Oliveira 65, Copacabana', 5, '19:30:00', -19.8361, -43.9724, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', '90f8f6d4-0ace-42c2-bd06-44637bc2d9b4', 'Jardim Vitória - BH - Bairro Vitória / Jardim Vitória', 6, '19:30:00', -19.8456, -43.8891, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '88a5824a-d469-42d4-9eca-4e36f795deba', '86d95c36-0a6d-4e06-8575-caa66269c2c7', 'Santa Branca - BH - Rua Norte, 42, Santa Branca - BH', 2, '19:30:00', -19.8268, -43.9685, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', '86d95c36-0a6d-4e06-8575-caa66269c2c7', 'Santa Branca - BH - Rua São José do Jacuri, 135, B. Santa Branca', 3, '19:30:00', -19.8245, -43.966, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', '86d95c36-0a6d-4e06-8575-caa66269c2c7', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 (Casa do Marinho) - Maria Helena', 4, '19:30:00', -19.7985, -44.0092, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', '86d95c36-0a6d-4e06-8575-caa66269c2c7', 'Maria Helena - Ribeirão das Neves - Rua Lagoinhas, 64 - Maria Helena', 5, '19:30:00', -19.7992, -44.0105, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '8dc501c9-06de-441d-bf78-cb2269559fb2', '86d95c36-0a6d-4e06-8575-caa66269c2c7', 'Leblon - BH - Rua Olga Pimenta Guimarães, 204 - Leblon', 6, '19:30:00', -19.8115, -43.988, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', '86d95c36-0a6d-4e06-8575-caa66269c2c7', 'Sevilha B - Ribeirão das Neves - Rua São João Del Rei, 270, Sevilha B', 2, '19:30:00', -19.7695, -44.0812, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '57fcb51d-1716-40e9-ada8-93b422f3e066', '86d95c36-0a6d-4e06-8575-caa66269c2c7', 'Areias - Ribeirão das Neves - Rodízio (Areias / Morro Alto)', 3, '19:30:00', -19.782, -43.985, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', '6cee9dbd-eec7-422b-b178-65c4b6286aaf', 'Santa Matilde - Santa Luzia - Rua Geraldo Ferreira Rabelo, 169, Santa Matilde', 4, '19:30:00', -19.7668, -43.8582, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', '6cee9dbd-eec7-422b-b178-65c4b6286aaf', 'Lagoa Santa - Lagoa Santa', 5, '19:30:00', -19.6328, -43.8906, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', '6cee9dbd-eec7-422b-b178-65c4b6286aaf', 'São Benedito - Santa Luzia - Bairro São Benedito', 6, '19:30:00', -19.7825, -43.9145, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '5714b151-16c5-4509-a7f7-1431768130c9', '6cee9dbd-eec7-422b-b178-65c4b6286aaf', 'Fazendinha do Baú - Santa Luzia - Rua Presidente Roosevelt, 1107 - Fazendinha do Baú - Santa Luzia', 2, '19:30:00', -19.7755, -43.872, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', '6cee9dbd-eec7-422b-b178-65c4b6286aaf', 'Córrego das Calçadas - Santa Luzia - Av. Engenheiro Felipe Gabrich, nº 734, Córrego das Calçadas, Santa Luzia', 3, '19:30:00', -19.759, -43.851, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', '6cee9dbd-eec7-422b-b178-65c4b6286aaf', 'Cristina B - Santa Luzia - Rua Mila Bernardina da Rocha, 85, Cristina B, Santa Luzia/MG', 4, '19:30:00', -19.7762, -43.9248, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', '9a5bba56-d9c2-4826-a232-399d70e2136c', 'Novo Tirol - BH - Rua Macadâmia, 168, Novo Tirol - BH', 5, '19:30:00', -19.9985, -44.0315, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '730f6bed-ef15-44b8-b8f8-d808c9739131', '9a5bba56-d9c2-4826-a232-399d70e2136c', 'Milionários - BH - Rua dos Atleticanos - Milionários', 6, '19:30:00', -19.981, -43.9965, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', '9a5bba56-d9c2-4826-a232-399d70e2136c', 'Tropical / Quintas do Jacuba - Contagem - Estrada Chico Mendes, 900 - Quintas do Jacuba - Contagem', 2, '19:30:00', -19.9265, -44.115, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'f10b3c41-de40-4526-8aa0-76e00a268b08', '9a5bba56-d9c2-4826-a232-399d70e2136c', 'Novo Progresso - Contagem - Rua Paraopeba, 184, Novo Progresso', 3, '19:30:00', -19.898, -44.039, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '61b13068-059b-4fbe-a47b-246096c8a75a', '9a5bba56-d9c2-4826-a232-399d70e2136c', 'Bela Vista / Barreiro - Ibirité - Rua Melo de Souza Maia, 101, Bela Vista', 4, '19:30:00', -20.008, -44.052, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', '9a5bba56-d9c2-4826-a232-399d70e2136c', 'Salgado Filho - BH - Rua Ibiraci, 250 - Bairro Salgado Filho - BH', 5, '19:30:00', -19.9412, -43.9825, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', '9a5bba56-d9c2-4826-a232-399d70e2136c', 'Nova Suíça - BH - Rua Lindolfo de Azevedo, 608, Nova Suíça - BH', 6, '19:30:00', -19.9445, -43.9734, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', '9c29966f-48ba-48fb-bea2-ada14a3649ad', 'São José - Esmeraldas - Rua Américo França Abreu, 257, São José, Esmeraldas', 2, '19:30:00', -19.7615, -44.314, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'd5225343-ca7c-4212-8423-ee298e2e4255', '9c29966f-48ba-48fb-bea2-ada14a3649ad', 'Jardim Riacho das Pedras - Contagem - Rua Urânio, 114, Jardim Riacho das Pedras - Contagem', 3, '19:30:00', -19.9565, -44.041, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '6874331a-31dd-404f-b983-1e669a58ded7', '9c29966f-48ba-48fb-bea2-ada14a3649ad', 'Marimbá - Betim - Sítio da Igreja (Marimbá / Juatuba)', 4, '19:30:00', -19.932, -44.275, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '4b46a123-8af6-4ede-841b-e89e82f87390', '9c29966f-48ba-48fb-bea2-ada14a3649ad', 'Resplendor - Igarapé - Rua Bahia, 131, Resplendor - Igarapé', 5, '19:30:00', -20.068, -44.298, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', '9c29966f-48ba-48fb-bea2-ada14a3649ad', 'Jardim Alterosa / Santo Antônio - Betim - Rua Limoeiro, 337, Santo Antônio - Betim', 6, '19:30:00', -19.961, -44.172, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', '9c29966f-48ba-48fb-bea2-ada14a3649ad', 'Três Barras - Contagem - Rua Gentil Diniz, 441 - Três Barras - Contagem', 2, '19:30:00', -19.9145, -44.0885, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', '9c29966f-48ba-48fb-bea2-ada14a3649ad', 'Eldorado - Contagem - Rua José Barra do Nascimento, 1971, Eldorado - Contagem', 3, '19:30:00', -19.938, -44.0395, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', '9c29966f-48ba-48fb-bea2-ada14a3649ad', 'Ponte Alta - Betim - Condomínio Ouro Verde, Bairro Ponte Alta - Betim', 4, '19:30:00', -19.896, -44.203, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa', '0059dafa-e63c-46ff-b1fc-7868e8714b16', 'Interlagos - Sete Lagoas - Rua Antônio Domingos da Silva Filho, 307, B. Interlagos - Sete Lagoas', 5, '19:30:00', -19.4752, -44.2368, now()
  );
  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', '0059dafa-e63c-46ff-b1fc-7868e8714b16', 'Santa Bárbara - Santa Bárbara / Barão de Cocais', 6, '19:30:00', -19.9595, -43.415, now()
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
    '219a120e-ff58-405f-83ba-933279e08896', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    'e81475a5-a09d-4269-bae2-4b5f9009b7e8', 'Marleide', NULL, NULL, NULL, NULL, NULL, 'F',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '72d015f6-7aa4-493d-a2de-960214f037db', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    'c64c20ca-aedf-466a-985d-b0ef0b5c2f41', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '044a0d94-2dc6-40e1-bf37-1812bcae79aa', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, 'M',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '2c1a15d7-517a-4b42-b5ac-54230fe4769e', 'Soely', NULL, NULL, NULL, NULL, NULL, 'F',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '9396e709-343e-4ed7-888f-a74fa83910ef', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '28e97996-fd77-4f65-80f7-c1aeaf0e4e28', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    'b6387dbd-5fa7-48de-a288-0fb583737dcf', 'Euller', NULL, NULL, NULL, NULL, NULL, 'M',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '2ba3cd78-bb32-497c-bb99-6e4711657460', 'Wellington', NULL, NULL, NULL, NULL, NULL, 'M',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '843dcf1e-fddb-48a1-8985-182fed900093', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '6b7b1503-8f48-409c-a0d9-d6ccf021d6c2', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '425e5c0e-79da-41a5-b2c6-f930bd6eb23e', 'Joana', NULL, NULL, NULL, NULL, NULL, 'F',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    'dfa0577d-a152-4496-83d6-b93063bdd23f', 'Agatha', NULL, NULL, NULL, NULL, NULL, 'F',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    'ba0db112-6332-471c-bee4-289e4d712df4', 'Mariângela', NULL, NULL, NULL, NULL, NULL, 'F',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    '34325e1b-d409-4618-973b-dbfffe77cc64', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8', true, false, false, false, false,
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
    'c217d85b-3422-4198-86f8-2ca90b6ca039', 'André', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '3215a739-9748-4ded-bf1b-60e7a15dcf3a', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'eaf52b9c-d7d1-48dd-ad19-a287a6807df0', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'd5b0c069-8cae-4bd3-9fb3-2b862e55f9b3', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'a3046d6c-5b69-4f1f-9522-ceee6211bbdf', 'Elis', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'cefd05cc-83a1-4c99-bb65-288ef974baa1', 'Fernando Gomes Braga', 'fgb80@yahoo.com', '103.821.540-52', '(31) 99123-4567', '1966-04-12'::date, '1984-06-20'::date, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, true, false, false, true,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    'Administrador', 'Ensino Superior', 'Empresário', 'mais de 5 salários mínimos', 'Própria',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80', 'Flávio', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '0173059d-1312-42d5-834f-d5025499ee10', 'Clara Góes Braga', 'claradiscipula@gmail.com', '167.370.473-66', '(31) 99123-4568', '1968-09-15'::date, '1986-11-10'::date, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
    'Casado(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    'Professora de Ensino Básico', 'Ensino Superior', 'CLT', 'mais de 5 salários mínimos', 'Própria',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&auto=format&fit=crop&q=80', 'Marleide', now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    'b4687743-9b48-4fae-834e-5fe7fb19f05a', 'Artur', NULL, NULL, NULL, '2019-09-09'::date, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '43dd9046-8575-4e3c-8e42-bcbaab61dc6d', 'Gabriel Góes Braga', 'ggoesbraga@gmail.com', '132.507.246-02', '(31) 99888-7777', '1995-07-08'::date, '2012-06-15'::date, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, true, true,
    'Solteiro(a)', 'Heliópolis', 'Belo Horizonte', 'MG',
    'Desenvolvedor de Software', 'Ensino Superior', 'CLT', 'mais de 5 salários mínimos', 'Própria',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&auto=format&fit=crop&q=80', NULL, now()
  );
  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '6000aaf3-1674-4418-aa81-29543143fe6a', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '99c5c33b-a17d-4e1d-b362-dc5baa9ace9d', 'Marina', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '8387b20b-ecd4-437c-9531-945b87659d85', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'a3c430fa-4a73-44fe-85c8-bed1daf8066a', 'Deia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'cc8ca953-c753-4781-b6ac-d9585c236831', 'Marivaldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '89dfdb4e-b84c-49f0-91b3-b26f4811a90a', 'Luciene', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '45658447-a13b-4a51-9ec3-0a9e584043bf', 'Ramon', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'cde1c6ad-2f8b-4543-859a-defd8b5d50e9', 'Margareth', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '8ca46ee3-feb4-48de-b7ff-07717d68e3fe', 'Renan', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '6baed437-e3fe-4de6-b86f-049c801dce3c', 'Arlete', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'ec051e64-ffce-4f37-bfb7-c2f6e29bfdd1', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '4477f189-e461-4d08-b3c9-caf05f98c772', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'efced203-7f62-463b-9437-a59270be23c4', 'Cecília', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'e2adff93-2ee7-4f85-b203-ce9bc02c38ae', 'Hugo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'afd19ec0-75da-4df1-8b60-d9402e912d46', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '337bdc08-6b2c-41f1-ac84-937e2c960b8e', 'Sarah', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '9c60abd9-6ccc-41f6-94ed-2f012e15230d', 'Matheus', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'ec8f440c-4d7f-4a24-8d21-2ece7b846522', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '083facd6-0634-40cf-8c3e-d1804b22bb1e', 'Marlon', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'de7548ca-68cd-4c33-b95d-70f29fc9b991', 'Maura', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '98a95ad8-74e8-49f0-a2d4-d4eb6df0e7b5', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'dc7b515b-9d74-4d35-be95-4935bd244275', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'd8ca5b4e-0b42-40eb-aab8-e71a4f99f026', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '649b0f27-ede0-445c-9afa-c39525fe13b1', 'Zoraide', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '79e8805d-7149-4634-aba0-f0ede108d56a', 'Miriã', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '26b3d995-d7fb-4c74-8f38-9bbd2d5e6308', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '7e4e09e8-1878-4ea2-9355-30e55ddab65b', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'dc0ba837-ab0f-4d73-ad6f-484cab57b496', 'Wanderlaine', NULL, NULL, NULL, NULL, NULL, 'F',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    'dc8c81f1-c052-40f8-8213-94e16eb64fda', 'Ismael', NULL, NULL, NULL, NULL, NULL, 'M',
    'b5ea8c19-2d35-48a2-b2bf-824e59968519', true, false, false, false, false,
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
    '31dd4142-d016-460e-a53a-a074387887ba', 'Emerson', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'e050cb39-15bb-4fac-bc7c-0ddb41541a66', 'Neide', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '0f37069a-c847-441d-8700-503df3a5eb80', 'Walace', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'f91068e8-62ed-46ec-bb69-2bf6287f9300', 'Sabrina', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '50c1ab08-4157-453f-802e-661a290d5997', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '3e424427-4092-4d0b-8629-dbca904a6a4c', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'ee5e2ce1-8e47-4830-ab8d-f653905488e7', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'b3f5b24c-5db8-49b4-ac05-aa9a6a738d74', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '576a3f90-bbd1-4fda-9f3a-92ad190cbf86', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '11f14cf7-7af8-46d4-8a33-f7f4143ee2a6', 'Cristina', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'a1946d29-22e6-41d0-9da8-bebc95854689', 'Tales', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'd2f9b13f-b958-42e3-827c-b76c25be11c4', 'Edna', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '76355d35-0af6-42ea-9bd4-e07342c58922', 'Thiago', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'e2c87c25-7ce7-4300-bd4f-6603391e49c1', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '7c3a7310-e6ce-4794-a8d6-99fab6ec20ed', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '5d89236b-d7c7-491b-b8e6-cb2ceb8ec689', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7', 'Carlos Eduardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '7ee41141-243b-4aea-986a-6492efe1b957', 'Joelma', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'd63ea523-0aca-4bd1-a435-670780e75811', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '574acf7b-47ec-4bea-8723-c4840814f094', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'c5da543a-8a8d-4c3b-881c-f0bb7ad86226', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'a721678f-add7-4f85-bcff-c64d77a072b6', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '45b5215a-e43e-40ee-bd5e-e31cace3b45a', 'Grace', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '264b7595-02db-4384-9d8d-b48e0a58d243', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'a984e0dc-5082-401c-a77f-44b4146e15a2', 'Lutero', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'cb35fefc-3ec0-4a04-a645-abd3ca790a41', 'Dominique', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '4ff489d0-abf3-40ca-93f1-e5b0a988ef24', 'Kaleu', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '443f6bdf-da31-47a2-820d-5ce986245a81', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '029184ea-f254-46c5-8fd3-c485453c419d', 'Marilda', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'e633481b-f0a6-40c8-a1f1-07a884356d21', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'b3e96f4c-be3b-49c3-abe5-7e21fa7762fb', 'Enzo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'efa92820-2094-4a14-bfd1-6ac951ee17f9', 'Daniele', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '66f5d3bf-5edb-465b-a05c-930ba66d2bf1', 'Luciene', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '4c4a5960-daaf-489c-827c-d7cd17df72e9', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'ecb2345b-6190-4a59-aadc-3c1e04805a20', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'bb8359a2-93d1-4834-9712-461705043c60', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'be5c59ab-d165-4922-93f7-69a86d0af96c', 'Antonela', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '37960c1e-3656-4dd3-8af1-0e9a583c64cf', 'Luiz Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '9c4a1f92-21f9-49a0-9179-8e49b42a8622', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '4c2012bc-398c-412b-a406-1f8fb4bca41d', 'Amélia', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '75f53908-d6f5-42cc-b6e4-4a2d18b013e7', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '9b2410e1-37f9-4576-bc72-db72777f4f72', 'Tamara', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '22994182-ebda-4aa6-b715-9c3296957181', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '10e831c3-be52-4828-8e7c-788b72ab0bbb', 'Ciça', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '98304d55-8743-4783-abfd-4bfdd23942d3', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '50f9a13e-3ef8-4d19-8768-81a5f2b1cfbd', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    '91519024-7c98-44b2-bdf6-3c1a96e22400', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    '5e1312d6-51b1-422f-9db2-fd75f9dd03a6', true, false, false, false, false,
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
    'bcd9ffb6-aa46-4c19-9a88-41989cfe0598', 'Eduardo Lopes', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '45f23409-8e1b-440a-91de-a42e11c4f9ce', 'Érica Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'b84a0a95-4254-49b4-a504-9b6b0a3ddf4a', 'Laura Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '4ed1da52-07ed-4021-9a42-fac4cbec7649', 'Eduardo Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '2a35a5a3-3a1d-4356-b787-9ccbaefc3792', 'Luís Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '6a75a407-4dad-4333-8469-1d96d00926d3', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '67b3c127-3dda-43af-a332-c2d16ce03e11', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '4f31f085-2678-4be7-b7b6-d48c14983a9a', 'Henrique Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '25080b17-2896-455c-86ea-8bf7f076ad20', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'c87b8712-cf05-48b5-b820-dc172460fe5d', 'Lucas Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'f9efb3e4-a627-4c5b-bc28-125132334751', 'Raíssa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '2c465bea-a93b-466d-a333-084519bbdc89', 'Lian', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'dde3887e-f3ff-4594-b725-6396232601be', 'Pietro', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '3774929f-208a-47a5-b41c-41b5c4a255fd', 'Danilo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '959c3df3-ecac-4b76-bc20-c3e105828c6f', 'Melry', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '252e78f2-8381-4fa3-aa09-58363bacea4c', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '48858676-9ba0-46f0-8994-962755381b22', 'Sofia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '748e38bd-6b77-47c7-9ed7-2a2e0c6a46dc', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'a7d7345b-6d89-40b8-8a34-0b1d61003ee9', 'Ana Luísa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '62fde44b-201b-46c3-b412-d24ae1e8fb2c', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '4d32e791-6040-4896-976b-1dd0ee3931e9', 'Josinha', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'bf6d306e-8652-41fa-aca5-ed1674fdc41a', 'Thiago Bombeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'ee7ffe41-3b01-4d16-9567-75262b0e7990', 'Paula Emanuela', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'd7e9ea67-2031-417c-aab4-3fea4ca64847', 'Ana Luiza', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '3b7b5ca5-4f27-493e-b40b-fd874d008ac8', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '607be0a5-8135-46df-aee8-eb178a17de80', 'Thiago Filho', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '52fb29b0-20b5-444f-bf5f-ee5147f7493c', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '5c74e216-d02f-44d2-afbd-280317b14dfe', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'c2285b61-56a3-41d6-9a6f-40aa68fc0d77', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '10b4ab73-c235-4186-8bb2-46ba811b6da7', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'e7535c45-7b6e-4e8b-ab0b-4780a6ccc870', 'Miriã', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '4b690def-c815-4a47-a85e-fcda3c8397fa', 'Nikole', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    '5e2baf12-36d3-4520-a7d7-da5949d48b29', 'Brenda', NULL, NULL, NULL, NULL, NULL, 'F',
    'e939abea-3ef0-4514-b26c-1ee7cf1c438c', true, false, false, false, false,
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
    'f9ca51cb-1d30-43a0-8192-37b27725defb', 'Ademir', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '53b9206b-4c8e-4542-a793-4af98b167ba5', 'Janaína', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '79e0a69d-e53c-4bb1-88b1-a6ed150c4b22', 'Emanuela', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '0c72b48f-782c-43de-b098-c3581711d11d', 'João Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '510e50aa-1eac-4369-9fc1-0acea761a7dd', 'Julião', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '3124f4de-c749-4c7c-bbbb-9b933d3b76d4', 'Darlene', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '289ec264-77d5-4705-b91c-95c2186a32d4', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '0dccaa73-17ae-4107-9d51-40e210f367b1', 'João Francisco', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'af330838-9a58-4815-8251-332fba6caa7c', 'Ana Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '14812dc2-691f-405b-ad00-535168d6e7ec', 'Elias', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'f85b3167-d444-4bea-a5d0-e23e1da8e0a9', 'Fabiana', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'b57cc7aa-ea5f-4d65-89c1-631f44206316', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'f78112dd-ebdc-49a8-8d09-bbdda9007810', 'Maria Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '9d1a9f2b-5088-4ffe-b971-c35dd5945c4f', 'Luiz Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '0c134eb5-6e9a-4a73-b493-e1da8b1cb629', 'Jéssica', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'd071713c-e7b0-4c3f-a1d0-afae372fbed6', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '95d57830-a43e-49e2-aff7-66c35cc70500', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'c08367ef-9ff5-4e2d-becd-0c7810bd190a', 'Thainara', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '6e28c646-978d-4e2f-abb5-6bf42f2e712e', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '0371190b-b3b3-4f59-85a6-84172bb89374', 'Laila', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '35c0d617-94e1-42cc-b0bf-dc1160dd5125', 'Evenly', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '8ce5c730-42d1-4594-bd90-84b05d707ff8', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'c8b8067a-5bcd-4b9a-86e1-3d60a2961a9a', 'Antony', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'cfaaaea4-b5f6-4b05-8c97-c25e6f3d29b4', 'Carla', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '1d42c1f8-251b-4d8a-9cb9-92430029b602', 'Laiana', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '76c6b6d6-fe2b-4cf3-89d9-a060750ded12', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'c1a5f95f-40c8-4dc0-bb97-a4a24d5623a9', 'Riquelmer', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '4a6b9d27-31a7-4e8c-b6b0-e59c497f066f', 'Caíque', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '2b2d370a-94d0-4f07-bca2-309c6cef6408', 'Silas', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'e3f2fba8-769e-4113-a2b2-7835626072d0', 'Juraci', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'b1dbe108-d9fb-4811-b5b8-0c7a35c8b15d', 'Luizão', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '1a86a28f-9c21-4d77-ba05-a83faff42a9c', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '83714d72-e22e-463e-b936-088265db3f30', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    'e78f61f0-2548-428d-876e-bc0ec1893e70', 'Juscelino', NULL, NULL, NULL, NULL, NULL, 'M',
    'c38d4e1a-15fc-41df-9091-9cf5c3604cde', true, false, false, false, false,
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
    '9d212800-0ba6-40d8-8715-bf2e250999f9', 'Helder', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'c042552c-7c37-4300-b155-2537254f67d4', 'Vivian', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '86ff6441-a5d5-42b0-898c-671b54089541', 'Jonata', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '0bf4b5bb-11e1-49ef-88d0-35af77e4b305', 'Francérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'bf38cf2c-549a-4302-bd12-acd8269da97a', 'Juliana', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'bfcab115-e5f1-4941-baab-13b8d6bb1481', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '532ef45e-1e86-4242-a724-49dfdd6b2e1a', 'Kennedy', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'f85ee4f7-a4de-4c09-ac6a-ca254c7da320', 'Bárbara', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'b346bb10-894f-4516-8fb4-2c3808b55463', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '87251811-2bfb-4e66-bd9c-f5bfb1505ba0', 'Pricila', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '2ee9bb29-09ec-4196-b408-737f7978ab86', 'Luciano', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '538e20b8-bdeb-458c-a1e2-1f4b79fcf06d', 'Lilian', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'a762a44e-5277-453e-9405-d447cc887766', 'Tiago', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '1a219dbf-076d-4658-b329-1c3c43d9c463', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '570dfdd3-d0a9-4079-8ff0-fbed34bdbd28', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '08a80ea0-da91-4e92-bf1b-dc4ef2348e9d', 'Taiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '8b813c87-6a0a-4434-9ff3-a2ef5f60bd0c', 'Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '5345e812-3c4c-48fc-82a5-f688254bd9f3', 'Rhuan', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'ed8f6a76-fa3c-4943-8151-6e5b00bbd691', 'Gabriele', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '55b58adc-d91f-4f1b-b6cf-2d30a527ddd4', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'aaf3eccc-c8fc-4a1b-b03a-d227702b18de', 'Polyana', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'b698a1d3-497f-4b7a-8d7c-d056827035e9', 'Maria Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    'bd3ebd00-4d5c-47cc-b216-c2db6353d3c0', 'Ana Paula', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '54149402-e62c-48c7-8967-5de843e8f5ee', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '8d60ceec-be85-4039-b76c-470252326a4b', 'David', NULL, NULL, NULL, NULL, NULL, 'M',
    '88a5824a-d469-42d4-9eca-4e36f795deba', true, false, false, false, false,
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
    '2ce6c9f2-9ce9-4ab0-8495-ae6e43ed1e8f', 'Juarez', NULL, NULL, NULL, NULL, NULL, 'M',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '30ea4413-d4f4-4086-8969-dca1df9637d4', 'Divina', NULL, NULL, NULL, NULL, NULL, 'F',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '1b14354d-62df-4363-a9c4-0cca112a026b', 'Argeu', NULL, NULL, NULL, NULL, NULL, 'M',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    'bc4d8561-453f-403f-9dc1-c146708c4a8e', 'Lora', NULL, NULL, NULL, NULL, NULL, 'F',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '4ba9b8f3-7122-486d-a43d-b34922b7a04a', 'Sérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '3c8388af-9675-4a38-86eb-c422bab96cbe', 'Karina', NULL, NULL, NULL, NULL, NULL, 'F',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '0597b054-8be5-467a-987f-c56308a28236', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    'fe375bb9-83e4-426c-b1cb-a287b289c278', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    'e00fe9fa-a93c-4a08-98fc-2dd60432ffe1', 'Lúcia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    'c26a1a2c-81bb-4583-bb69-21bf7cc2a798', 'Mundica', NULL, NULL, NULL, NULL, NULL, 'F',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '6368f6bc-9be9-4f1b-9d49-77a2fa9b0edc', 'Janir', NULL, NULL, NULL, NULL, NULL, 'F',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '44695239-d982-4146-8cd2-f4cdedfe326b', 'Cristiano', NULL, NULL, NULL, NULL, NULL, 'M',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '5daef673-ca71-477d-a3f8-5f9a1fa22947', 'Vanessa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '1163426c-e620-48a9-86fb-5500f8d19506', 'Caio', NULL, NULL, NULL, NULL, NULL, 'M',
    'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5', true, false, false, false, false,
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
    '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3', 'Marinho', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '76de4596-1505-4ec0-99cf-f7360d6d79a8', 'Quênia', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'aaa93966-f020-47ca-89b9-af29bb8743f7', 'Karina', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '61977362-6b73-4356-936d-5406cf8efdb6', 'Jonas', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'caadae9c-21e3-4152-9989-1e5a6017743c', 'Wellington', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '76f9712f-c596-4ae1-b2fc-48933a7ee2db', 'Raquel', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '300d5de4-f927-4192-995a-c3c39cd76ccf', 'W. Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'ef14a065-d5fb-4e13-9779-bc9b5c267a52', 'Carlinho', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '74cbfa30-1257-42d5-91bc-9e595de6d067', 'Graziela', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '8c9a1b32-958d-4b44-a79a-f4671bbb3f6b', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '07366db0-2e6c-49f4-86f9-b349088bb253', 'Alexandre', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'c8998cef-df63-4419-adb3-206f5d89d54d', 'Érica', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'f3266092-c488-42ee-b586-af5fa006619d', 'Benjamim', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'b12c63df-b43b-4b7a-88a3-2807e1386001', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '3833e775-9e8c-48db-a798-d50650bef65d', 'Eliete', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'c7c0fa6c-e9a2-44c2-b66b-80d63406144a', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '7a90875f-f164-433a-ac7c-9643d53b536d', 'Marcela', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '7c2b1a5d-bcba-4922-af98-183f9472b70c', 'Zezinho', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '93f65414-b584-49e3-a8b5-3503ce23ec79', 'Ana Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '62adea3d-445c-4f03-9b68-bbdb001bff71', 'Cida Santos', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'a0ce886c-0937-412d-aeb6-c8be08a15b50', 'Cida Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'f72b6443-c2de-42d2-b3c9-b0212f0a67dd', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '7903d97c-c8c2-444c-b268-83a7b87b6720', 'Cleuza', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'd31b0df4-f0a6-4512-a4b4-de4ec99d9832', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '6f397c40-827b-4af1-85f2-a1324d2ca9a9', 'Roger', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'b748780e-0227-4eea-93f3-9e5ffd582187', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'fbd774c1-a520-4eca-bcb1-906a3be33b90', 'Mary', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '43144135-0f3e-411f-9554-da3123fc7534', 'Filho 1', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '13170641-402a-40b2-8f6c-095ed40aed90', 'Filho 2', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    'e3ba59f8-4e8f-4f20-a0aa-cc1121a622b5', 'Marly', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '139288c5-11cc-4712-9239-4e5775f33243', 'Marcone', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '91e1fb4f-feb0-43f0-a71e-30b942d66319', 'Rosemeire', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10f3ae3-fc50-4966-ad78-101e43dc7bc6', true, false, false, false, false,
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
    '93e6ef9b-2a12-4779-9372-0a91e6cd3809', 'Vera', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'ad24591c-02e7-4a8e-9d21-bb38c8449793', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '158c0190-ed31-43e7-8f6b-a7996992dfc5', 'Didier', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'a8ad3f52-edf2-40f1-ae61-5aab86a7abd5', 'Winter', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '1e0d092f-ad3a-4be3-8c43-1b8be389d6ce', 'Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '04c8aacb-40f8-4b49-ae6a-98ccde19b13a', 'Breno', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'c270668d-456a-4669-b183-c3cb65434c79', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'b29b07bb-fc08-4a83-80d1-ce1b9666b976', 'Maria José', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'e0e5ac4b-b5ac-4d20-a0fa-74bbe8dcce67', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'dd92baa3-d81f-4ecb-ac90-26bf6dd93cb9', 'Selma', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '8e1b18db-d67c-48fb-86aa-8ba5d79da082', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '7b69140f-4d47-4ecc-ae3e-dab348d29ad3', 'Antônia', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '8f82b7d5-7f72-45e0-ae48-f0860db890a4', 'Marcone Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'e454e77c-01af-4a81-acd8-1c5ee3bc2fb1', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '3aeb8cf2-c7db-4e05-99d9-08b9f8ec85c9', 'Karine', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '7af9a5a1-b1a5-4a47-b72e-b37d06280082', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'ab460d8b-c7eb-4d29-b6a7-a360fe392be4', 'Isabela', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '79808740-e212-4bab-9682-efe38718b6c3', 'Cecília', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '71134040-e519-4cb6-a859-4f5266f229f5', 'Matheus', NULL, NULL, NULL, NULL, NULL, 'M',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '37aed401-1fca-43b4-8396-6a3209429260', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    '78addeb9-d21a-4ef2-a2ff-58e4949fe849', 'Hadassa', NULL, NULL, NULL, NULL, NULL, 'F',
    'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71', true, false, false, false, false,
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
    'e24a1b13-3acf-4c22-9726-7a263ebb9902', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '6714c279-8029-4e46-a287-efee9888fdee', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '27cda7e9-8f51-4a8b-8eef-303c3d126c0d', 'Sidney', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '8b11fd5b-f5f8-4492-bac2-7e38baab49fd', 'Suzan', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '8a6ffc48-b5db-455e-b0b3-eca2b2d30c04', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'dc2a8a5a-062d-4044-b2f0-0fa1b71ccbaa', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '7113daaa-fed1-41ab-9bb4-48c1e3f9f720', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'a8345812-7114-4e6f-be56-ffabc3601680', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '476e6248-4b9a-462f-9f59-e65288d34c1d', 'Hélia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '33ba0ab1-dc22-4a72-8765-81abb06454d3', 'Renato', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'b1be76b7-b9d3-436e-bf42-82ac78196baf', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '80e3383a-c5e7-4788-814b-2fdb5b2e746b', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '6fa9f817-254d-4f3b-a6bd-5be09c845b6c', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '0deb384e-6d9b-45dc-88b6-32be610ccfab', 'Ediléia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'f1215a6d-6ca1-4b40-8fc4-b19e5a45297f', 'Daiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '68567951-93b4-4b2b-a082-09273db7af17', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '2591c830-ac34-4746-a450-af6c19594119', 'Esther', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '005b1789-b9a4-4922-8c70-0629ce4c7fff', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '9aa58a8b-b179-49b4-a3b4-3d6aa0f4b079', 'Sandra', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '809dc61a-caeb-4af4-889b-2e5dc84be5cb', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '436fcbb6-cecd-4996-880d-37ae5b8e9153', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'c97fbb4c-1583-496a-86c3-02e30a4d6c5f', 'Moisés', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'e635b02e-3c3d-4e1d-955a-61a1f5a16ada', 'Ramani', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '4aab6a0a-73a0-4c77-81ec-24b15494637a', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'bf4ed3e3-57e7-46a4-8597-24d812a263c4', 'Débora', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'bb941f2a-9f73-4bc6-8ef6-744fb7a57242', 'Juliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    '5953fb6f-9bf0-459c-a7b3-0eeb8d1aacec', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8dc501c9-06de-441d-bf78-cb2269559fb2', true, false, false, false, false,
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
    'f48ae622-64c2-4b0d-af76-ad4a8208d098', 'Dimas', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'd513b617-28cb-4050-83b2-ff801f763f63', 'Nívia', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '3987930f-6e2c-4230-b07b-d60cab2d7ea9', 'Artur', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '83bacc2a-ffe5-42dd-82da-03c771eb48f7', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'af590c9f-12d7-457d-8b43-39fbbaf2e5db', 'Douglas', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'fe50fdcc-c384-4029-8b57-d45b48b99c80', 'Cristina', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '8784f447-db9b-4ac0-9ef9-ff7d2be34189', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '321aec57-1ac2-4674-b885-76a0e45bdeb9', 'Felipe', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'c4e92cc2-ca10-4c97-aeea-df69d15b4651', 'Cláudio', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'a33cd689-65d9-4b4c-b3e9-5e2e31b7107b', 'Cinara', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '980b2f51-dabb-4c82-9d7a-16a238ffae49', 'Saulo', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'ae96fac5-7df5-4161-abcc-87065e91c504', 'Duardin', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '095c9ea3-8ab0-4dee-90d9-b6035d060b2c', 'Angélica', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '4436f25c-69bd-4490-9d62-2130cebad702', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '8e17ccfe-2356-467c-8210-d4bad9c610e4', 'Lara', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '8a4e3479-1da9-4e4b-9773-393fd3626764', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'd379fedb-0c55-4916-8888-e2ad5f8532ea', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'a7cf9642-7b29-4abb-854b-b5a04d35d05a', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '82f8bdb5-bbbf-4a32-9aa9-cf0e8e7ee203', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '5cb6445d-7f25-4060-be28-2f0aafeb7e41', 'Graça', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'e037fc50-2d7a-4631-9729-295a0f76be63', 'Jane', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '595bbe53-3ac7-4964-b5ff-fa36c534e4a2', 'Kézia', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '31e3288c-aff8-4f77-b1b7-c3e429f6e446', 'José', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '8f2a3de7-729c-463d-8196-9801767d7bb9', 'Geralda', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'efde5023-cbc3-41c0-bf69-e2716deb5057', 'Marta', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'dbb7ad9f-f230-448e-8063-1700a41d2e30', 'Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '0b168797-56ef-4826-9b98-8ae3aa27f5ee', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '06cd38c9-6c2f-462c-8c4e-f77722d85429', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '59a3a433-74ca-4a11-a2eb-8dc9e4e157a3', 'Wesley', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '2bbebb46-5b7d-464e-93f4-6f784fa55b7b', 'Elen', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '43477912-017d-4be2-9b20-abd05d16bfba', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '0b10f7b0-84ac-4277-8ac1-50f291f5ebfd', 'Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '5bf8019f-94f6-4d14-958c-543bdf48198c', 'Cleiton', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    '20924b51-51d0-4464-8a3b-60fb353d5d0a', 'Milca', NULL, NULL, NULL, NULL, NULL, 'F',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'aa9d73cf-8c7d-4502-8124-6b31b53dcac5', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    '7f07285a-f15d-441a-af8f-b9a1f3f87081', true, false, false, false, false,
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
    'ab5c3b50-070e-42c4-ba65-a73f2b3768db', 'Jaime', NULL, NULL, NULL, NULL, NULL, 'M',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '577ea67c-06f1-45ba-9e36-9d114b2e565a', 'Jacira', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '961035c3-86e0-48cb-9cc6-bb240b551880', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'f84a3a6e-7af9-45f2-97dc-5f3c642c9070', 'Dona Adélia', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '7d5a8f77-6d3e-4e9d-b5da-ca58a7af12a1', 'Wagner', NULL, NULL, NULL, NULL, NULL, 'M',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'c945aaf0-f082-4152-a6ab-c753986e89c7', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'e5cf66d9-4f17-4526-af19-9139ffe2d544', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '58f22e43-3007-4007-9661-b267ab9d6832', 'Rebeca', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '67ae989a-a76b-4c53-94b5-decff88f0c6f', 'Ronaldo', NULL, NULL, NULL, NULL, NULL, 'M',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '3099f6f9-a7a3-4b5c-8b32-c37429ec1504', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'bd10408c-bcb6-4e4c-a418-72a3e68ecd58', 'Glória', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '2c2a4c9f-4ae6-4ece-9287-cf1301b28615', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'ad0f2b65-1246-4288-9e78-653d2c377626', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '4b94b8bd-fa38-4b0c-899d-a73a79783e69', 'Aurora', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '29d1145e-6f97-46c3-bad0-1238285893ff', 'Maria Tereza', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '66c1eee5-2c5d-4405-b680-ab83f0429724', 'Welvis', NULL, NULL, NULL, NULL, NULL, 'M',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'af85f349-a7af-4d46-9daf-ae1f2eabc375', 'Adriele', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '7aaab403-4f86-48ae-b62c-3148c09564dd', 'Bela Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '1bc80eba-2bd9-45ac-9729-923f9d750e36', 'Izaque', NULL, NULL, NULL, NULL, NULL, 'M',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'f9358d2f-e6cc-4c57-bf33-3da48bb30b39', 'Jamile', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'c5435b41-6bd0-41d2-88bf-2c2593c13c41', 'Kailaine', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    '1c527af3-f1f1-464a-9af8-5df6f78de0a6', 'Angélica', NULL, NULL, NULL, NULL, NULL, 'F',
    '57fcb51d-1716-40e9-ada8-93b422f3e066', true, false, false, false, false,
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
    'd4dfc0ac-2e23-4805-9b63-02ba2d4bc4d7', 'Davi Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '9b1c7842-0ef3-4441-b672-ddc8c3349528', 'Liliane Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '8206dc30-98d8-46c7-9ad3-77c681e4d727', 'Diogo Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    'facbfe83-00dc-45c0-9928-049088590490', 'Thiago Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '7873ec8d-e43a-4513-9a9c-013b09107834', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '12d805ce-183c-4f2e-92bb-1830ef7778d8', 'Gabriel Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '72443398-2053-454d-8167-eff7271c45bf', 'Giovana', NULL, NULL, NULL, NULL, NULL, 'F',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '0763293b-0749-4490-9d90-f10c978f8390', 'Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '882b96d3-9831-4794-a7be-1c5a12bfb84d', 'Krismary', NULL, NULL, NULL, NULL, NULL, 'F',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    'c41d69f8-43f9-43be-9d34-0c4a79e357fd', 'Wellinton', NULL, NULL, NULL, NULL, NULL, 'M',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '8bc2b23b-2991-4d8d-8029-76eb0d6222fd', 'Miliane', NULL, NULL, NULL, NULL, NULL, 'F',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    'c9b36e6d-8a72-441b-b513-a0f5888ed93d', 'Gellissa', NULL, NULL, NULL, NULL, NULL, 'F',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '737e26d8-52c0-4a18-98d6-b4821650b691', 'Kal', NULL, NULL, NULL, NULL, NULL, 'M',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '3edf5bc9-db9b-4039-bcc5-430eaea8fd9c', 'Tininha', NULL, NULL, NULL, NULL, NULL, 'F',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '02ce258c-c8dc-48b1-b387-aa71651312dd', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    'cc5d6e42-0378-46e7-ae45-48bad4bc3541', 'Mateus', NULL, NULL, NULL, NULL, NULL, 'M',
    'b229c98c-6d81-4fa1-bb7b-ba53f274fd94', true, false, false, false, false,
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
    '8e4e872f-e93b-498d-a6b9-551d06fa082a', 'Lincon', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'a7585340-04b8-463e-98e0-950ea4d52906', 'Tati', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'd1b5742d-46de-43f7-878c-c58497e57bca', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '21592ff8-3e6d-4556-bdbc-2e6fc1391d2f', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '1a276854-f5f2-4b25-8487-411a7b5e977f', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '4068d892-8d90-4a1a-b8d9-9b1809c0af61', 'Adilon', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '675e4992-d9b1-4da1-b147-f02eceed7e30', 'Lena', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '68dc2482-0259-4b33-b20b-a2a338963033', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '943ae2d9-b81d-4040-b674-b284a621bf7a', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'd0952ba5-945a-4479-94f1-9926b1a2fac9', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'c9f1a974-b158-4e3f-9760-5b687cab0919', 'Milena', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'd099d36f-4485-433f-8da9-6e71bef1306d', 'Isabel', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '8ff1f030-ad11-4cd3-9d2f-a8c178a48104', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'e0625d12-06b9-4fe4-b461-524a33fbef24', 'Daniela', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'fc695951-064c-4d8b-a7e8-a113a8509741', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '1faa0611-feea-4982-9b33-3fba8b345c72', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '6680bc00-b442-4aad-aef0-120bf0235f8f', 'Bernardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '56f6889f-ba1d-4ff5-b31d-933bd4b10105', 'Neto', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'a444b048-3e7a-4186-b33c-c0ee40fc96c3', 'Thaís', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'b1f3f922-3d33-45c8-8abc-b7d82ca776aa', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '731f56d8-18f7-46da-b9f6-bc690b2ab426', 'Luiz Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '742a5e06-ce24-4721-9aec-a7a26e96cdcc', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'e6d99983-4f42-4516-80f3-4acb7e274016', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'a8ebca91-d777-4fc3-8c71-1bb0fb531d55', 'Benício', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    '88bbbd9f-15ae-4a4e-9bf9-17b42a1c90c6', 'Augusto', NULL, NULL, NULL, NULL, NULL, 'M',
    '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2', true, false, false, false, false,
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
    'd5009d58-dd2a-41dd-889e-ffcd27ae4034', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '83570457-a654-428c-bb45-2b0d991cc017', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '12afa679-3de9-40c3-8d57-99416899151c', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    'ff9e9dec-8dc7-42b3-a3b2-f95a0660288d', 'Soninha', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '22857b4e-a9ab-4e91-bf23-008de0da1fcb', 'Gustavo', NULL, NULL, NULL, NULL, NULL, 'M',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '7e3e92b1-efa0-46c8-9f23-79bd76a59ff8', 'Daniele', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '5e12b668-9279-4dbe-baaf-9dad3d67ef7b', 'Lívia', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    'd989828e-07bc-47c6-bdb5-6bdd5e59b573', 'Lavínia', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '1d4c3538-9e8f-4f27-a4e6-1ad9a09908fc', 'Geovana', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '7ea0145b-2a1f-40b4-9e8c-c7b642a1d351', 'Emanuele', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '8a7d81b0-4e85-43d0-b62e-4cc2eb6f68ce', 'Paulo', NULL, NULL, NULL, NULL, NULL, 'M',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    'a0bbf386-f10b-4010-9fbf-ccabc5ac0623', 'Alcione', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '0be4fb20-e0f8-49a3-972e-62d5a89ffb49', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '1bb56b44-1aab-48cb-b6b0-b55078344e1d', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    'd7ddc8c0-a05a-4773-9b95-edfee929607b', 'Abadia', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '2c8e0548-8974-49b2-a9ad-8e60e49b6968', 'Dona Vânia', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    'deca0afd-0996-4618-aa72-1c287d8e9f6e', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    'dd531eda-d871-42d5-a193-4b796656f509', 'Bryan', NULL, NULL, NULL, NULL, NULL, 'M',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    'a99713c1-3ed8-45d0-921e-65cc2b6c4eb4', 'Evandro', NULL, NULL, NULL, NULL, NULL, 'M',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '806ee593-66c1-49fa-a1f1-52e74cdcc6a8', 'Jucilene', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    'c841911e-fafb-4d45-ab57-8c8cf3f9e9c0', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '3e46f68d-5d33-4373-9832-b979cab7e285', 'Gilson', NULL, NULL, NULL, NULL, NULL, 'M',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '9de8161a-5d57-4c0c-a11e-aebe2bc2c2ea', 'Liliane', NULL, NULL, NULL, NULL, NULL, 'F',
    'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08', true, false, false, false, false,
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
    '1d6f2814-903c-4f37-9212-728078805f44', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    '766ebb63-6afb-4bdd-a61a-596863b91c8b', 'Auxiliadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    '16d18c6b-5fb9-472d-b038-d9a451917e13', 'Jonatham', NULL, NULL, NULL, NULL, NULL, 'M',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    '7c92defd-1c98-4c54-bc49-2a280f49c4f2', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    '768e2171-752d-4fb3-be67-dc7e40ab9ae0', 'Jésius', NULL, NULL, NULL, NULL, NULL, 'M',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    '83823064-630a-40f0-bb8b-21149eb99747', 'Elisângela', NULL, NULL, NULL, NULL, NULL, 'F',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    'e26d46fc-586a-464c-8a60-63b8a237780c', 'Cláudio', NULL, NULL, NULL, NULL, NULL, 'M',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    'edb28b68-420a-44ee-aecc-b48a5f6f7c79', 'Ivanete', NULL, NULL, NULL, NULL, NULL, 'F',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    '467122ce-6b3c-4b71-bcf5-c71bc24fe3ab', 'Brener', NULL, NULL, NULL, NULL, NULL, 'M',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    'ddf34c33-44d4-4e9e-b467-57a9c043c357', 'Deivison', NULL, NULL, NULL, NULL, NULL, 'M',
    '5714b151-16c5-4509-a7f7-1431768130c9', true, false, false, false, false,
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
    'a2cbca82-b7f2-4634-af7c-851ae58b9265', 'Roberto', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'c58269ca-fca9-4254-b0ea-c8791fe2c99e', 'Leidiane', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '2871869a-bcf4-4099-b722-2c00018aacc2', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'b092fc37-71b2-4d93-a963-1c1e8cbd3877', 'Rayssa', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '0a223d17-33ab-49ce-b4bd-53d9b2859f85', 'Ryan', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '12e061aa-fb55-4165-86c8-c06c7d5381c1', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '04188ea7-29c7-4dfc-a7f2-a745a110b1cb', 'Dora', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'daff38d7-e7fa-4952-99f6-880a29a8d86d', 'Ana Flávia', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'd1142389-f970-44a9-92e8-7fbbf9299568', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '561b3acf-c189-42df-a043-a71b23a66db6', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '0d9e6cb8-2762-43e7-9484-e95f0c805c00', 'Leydimere', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'c106153c-abdb-40fd-a17b-60b1f3dd3feb', 'Bernardo', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'f59d7efb-a78e-43c5-b8dd-a5e8f950e1c8', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '8f88e49a-ec0f-4dc3-b3f7-7df78812a179', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '7af0aea9-b5db-45c6-895e-9be45d23d912', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '5a43a07e-b919-46de-8323-ba86fedf4761', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '74e44a10-188f-4bf3-b472-d6e7df3a8624', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'ccd0ea9f-27ee-4b51-baf9-91dde838fc74', 'Álvaro', NULL, NULL, NULL, NULL, NULL, 'M',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '5a68b362-ec39-4f09-bad6-f3979df4f26f', 'Gabriela', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'dbce97e9-87ec-4ad0-bf1b-3c9658e12a64', 'Olívia', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    '0659fdc4-5463-4f9a-ae37-4e7a76e035d7', 'Maria Aparecida', NULL, NULL, NULL, NULL, NULL, 'F',
    '3a0ecbfe-05a7-4595-b824-2f0299d71d2d', true, false, false, false, false,
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
    'e3b5dbc1-ba42-47a8-b5fd-ca26aceece4a', 'João Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    '7f54c921-8de5-457e-8b6e-955c8f4c7b06', 'Thaís', NULL, NULL, NULL, NULL, NULL, 'F',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    'eeda4a92-a6ac-4faf-a085-b4e0cabb4378', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    '0407243d-a136-4966-b9ae-3c98d6bf47f9', 'Lara', NULL, NULL, NULL, NULL, NULL, 'F',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    '785563b6-74d5-4c88-bea8-956732262d2f', 'Zinha', NULL, NULL, NULL, NULL, NULL, 'F',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    '440de73e-1357-420f-a788-5abc2e1a8962', 'Warley Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    '4c654481-6ee6-43de-b266-88dac5231490', 'Dona Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    'c6c48ae8-5e93-48f0-9c6c-78cff50af3fc', 'Júlio', NULL, NULL, NULL, NULL, NULL, 'M',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    '073d41aa-5378-4485-951b-416f1d95ca00', 'Andréia', NULL, NULL, NULL, NULL, NULL, 'F',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    'd6cd92cb-2f00-4a55-9d57-3728c97bd891', 'Paulo Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    'efdd1777-2471-4c0e-b45b-b225c581dc7b', 'Diogo', NULL, NULL, NULL, NULL, NULL, 'M',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    '0078dfb7-a8a2-4b4a-9289-d966af4a0a37', 'Maurício', NULL, NULL, NULL, NULL, NULL, 'M',
    'b3bdadc6-5400-4e3f-8ac2-73351974f4c3', true, false, false, false, false,
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
    '3b8b379e-487b-42b4-9c3e-4db8f476bcf6', 'Júlio', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'ae81097f-1774-4183-9372-99830fa09204', 'Valéria', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'eed2e6a0-1661-43c8-8733-c1516f396b5c', 'Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'b45df520-0f02-452d-bf5b-1748c8b34029', 'Anderson', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'ab815076-e42a-4a1c-83e9-f8eddee086b2', 'Kênia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '64979a47-540c-4eb2-9210-22395e014492', 'João Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '34b7c9b1-258c-4d39-bac5-18fa862627f9', 'Arthur', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '662f5324-14e5-45c5-9fa4-64347433563e', 'André', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '430f3eaf-1cc6-4153-b8ee-ae9a663c9850', 'Andréa', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'c619d65c-1a0c-42e5-9f45-0ffba8f57781', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'a4608825-a37c-4ae3-acc4-8858dc619445', 'Marco André', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'a5c52b21-66a6-4555-9ef2-70223ef1d1e9', 'Genderson', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'f572d8ab-1f32-4b4b-85f4-27bdaa9776f7', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '1338e785-b944-4a37-a88e-0ed03c28dec7', 'Sérgio', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '3b4832e5-05c3-47b3-850f-43f06473160e', 'Kênia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '22034f60-7eaf-4249-8177-04602767067a', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '7821ceea-8915-4dd1-9736-09f35d26825f', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '410ddbc6-ffe3-4e9b-b708-f956d5375fc6', 'Juliano', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'f0f4de22-c116-4874-94ca-6db167b69d9f', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '0a1e1143-c924-44df-941a-c9a474409e39', 'Bernadino', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'c9e1f999-1e73-4084-bc36-03864ca1e0ce', 'Jorgina', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'b3549442-1c49-4e45-b52e-ad3267f7dce7', 'Ricardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'cd534814-f2bd-4073-9b98-32d5178bdecf', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '6a9f6e04-fbf3-401a-be92-1803967b8523', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '2819104e-f1fd-4b97-a38e-30b6f655aec6', 'Valéria', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '854e26fb-074a-46db-955a-d4afba99ae03', 'Mariza', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '3a26e266-ea78-4a86-8175-c8962302d4af', 'Jorge', NULL, NULL, NULL, NULL, NULL, 'M',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    'e972d21a-bc51-46e7-99f3-7cc44f1f1c4e', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '8c2f65b0-b5fa-445c-8717-32f206c40152', 'Amanda', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '0fb670e4-8051-4db7-bdcc-622df74b0297', 'Cristiane', NULL, NULL, NULL, NULL, NULL, 'F',
    'e33d7058-96e5-48d5-a7f8-a1301f1f1821', true, false, false, false, false,
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
    '1b61df57-60e3-43d1-b202-94778723bc75', 'Rafael S. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    'fdcf0ae3-7f3a-47b3-8d1a-fc06da14c839', 'Isabelle C. M. Moraes', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '17e5683d-f9cf-4140-b2fc-68de891bd73b', 'Beatriz M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '3a448701-8441-4d90-8e67-108fc015529a', 'Filipe M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '022b9115-20a1-4caf-b681-c3a12ef2c7c7', 'André M. de Moraes', NULL, NULL, NULL, NULL, NULL, 'M',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '10ab12fa-8fc7-4294-a322-335969c49acb', 'Ari', NULL, NULL, NULL, NULL, NULL, 'M',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '919218ab-64be-4915-a4f3-7d9e4eaeff39', 'Jucieda', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '695a4e0b-69fc-4dda-97e1-249a739609d6', 'Natally Silvina', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    'd16b2349-9b5c-48e7-8dd1-9067484ec681', 'Wesley Anselmo', NULL, NULL, NULL, NULL, NULL, 'M',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '4202b35a-8f03-4c20-bd0a-90700dd51a94', 'Evelyn Ellen Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '9e89354b-ceed-4c99-8623-78e6af1ab5fe', 'Anna Júlia Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '4eae2b25-f188-4290-b87a-a2263ae54f93', 'Anna Laura Dias Anselmo', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '33ce58f1-d486-4b04-9bb7-adf07efdef07', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '9a490b28-fc1e-48ff-a3bd-4992e140d86e', 'Lucas Eduardo Luz', NULL, NULL, NULL, NULL, NULL, 'M',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    'f4d10dc6-ebc9-4b00-807b-f4cc2892c2f7', 'Allina Rodrigues Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '866d8229-8c00-41f9-ba7b-4fd00815a269', 'Carolina Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    'd784b85e-07ff-4d6f-854c-a6df449b89db', 'Maria Fernanda Luz', NULL, NULL, NULL, NULL, NULL, 'F',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    'adb66eff-e72a-49ff-a3dc-ed77e2402db8', 'Leonardo Luz', NULL, NULL, NULL, NULL, NULL, 'M',
    '730f6bed-ef15-44b8-b8f8-d808c9739131', true, false, false, false, false,
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
    '66a1c186-e3f7-4abe-9e2f-1eaa595e9957', 'Cláudio Luís dos Santos', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '4e01c8ec-ff7e-4a71-8534-09ea34b79cf5', 'Vânia Lúcia de Paula Santos', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    'c03cfe23-1c8c-4b94-8a9c-19335f16f5a1', 'Nicolas Matheus P. Santos', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '83009bc4-07d9-4e12-8023-d142333013fc', 'Davi Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    'c6dfddb2-7f21-46d5-8c61-5c17837bcee9', 'Roseli Gonçalves', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    'ccda19d4-1760-4696-a917-583141e40df6', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '664202df-2467-4fe1-978b-536c80475818', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '4853d8a3-0b30-412f-8b3b-d2f5d30ce86b', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '79c3061a-ab1c-4323-95c0-0ddd57363136', 'Lúcio', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '7f0ba630-de60-48a2-9790-eb49c3cbb491', 'Tatiana', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    'ab5200c8-b931-4041-b420-bb038fced51a', 'Isadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    'ca99344f-fa39-4e49-8631-281be52d104f', 'Eliza', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '015ab95a-a385-4946-a881-ca4b90535a56', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '3d388ff0-fdc3-41c0-82be-1e049ecf3243', 'Neila', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    'c1058965-4808-47b6-a086-aab424f8535d', 'Enzo', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '03f19c42-e695-463b-a655-77d9e589ab66', 'Melissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '0f71fdaf-2abd-49a3-97b4-17ec0ef1f0cc', 'Hemerson', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '2d5db83a-d8ff-4022-9d7d-417727f96f5a', 'Joelma', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '18dbaaf6-9342-4bbf-8a46-b9fb682a7a5b', 'Sueli', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '1aa03740-910e-4a52-96b4-939ee22f165d', 'Izadora', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '73438311-dc01-4e35-86f8-eb139b2cb5b9', 'Isabel', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '758f09a3-5ec3-4d02-84c4-2b77035b1d7f', 'Aparecida (Cida)', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    'f5b3350a-b929-4df2-bb0a-293f62df9cab', 'Alviclênia', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '6189187b-2694-4611-8888-e617a064449e', 'Rosa', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '76d842bf-b99d-42ee-8ac0-20c3953c1494', 'Ferreira', NULL, NULL, NULL, NULL, NULL, 'M',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    '4c05247c-b11f-4983-9092-ad0a68510888', 'Gisleia', NULL, NULL, NULL, NULL, NULL, 'F',
    '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa', true, false, false, false, false,
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
    'b526bab6-c753-4970-93f7-e3481115816e', 'Willian', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '6249eeec-4306-434c-8063-fd04a9169f02', 'Dulce', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '001a6eea-64de-4793-a39d-d10ece61b525', 'Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '8f790441-e0b2-4a4c-a720-1c81eee1f95f', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '8f17a7cd-8753-4251-a652-480990b1dc1a', 'Eduardo Coutinho', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    'd82bcff9-d5ab-49c0-86e8-f4ced747056b', 'Mariana', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    'a6599d0b-cce5-4c5d-9d73-e7d89d995247', 'Roberto', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '54d57870-a9bb-45f6-ac5c-aea9d2066260', 'Neusa', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '993fe92d-30f9-4786-a93f-d6e960510de9', 'Aline', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '53877903-e965-40a7-b535-ce14def8bf5f', 'Meirielle', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    'de6a4289-176a-422f-9e89-d792f21d98f6', 'Eunice', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '52903a62-f7b3-4fdd-9ff7-a088f51ab7b1', 'Lucimar', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '12d2bd91-fe1a-4b44-8df6-6984e092eb26', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '7d0f7882-e372-4e39-a8d4-14074477067c', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    'e43bc70f-3ae6-4d98-8b51-95f6d0af52ba', 'Dalva', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '73b9a991-6265-4a59-a7ba-6a16da6b9545', 'Lúcia Helena', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    '89d98e80-a280-45ae-bb55-c3a9d812ba05', 'Sirlene', NULL, NULL, NULL, NULL, NULL, 'F',
    'f10b3c41-de40-4526-8aa0-76e00a268b08', true, false, false, false, false,
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
    'b3e686c7-d8b2-44ba-85e6-0d6799516e05', 'José Alfredo', NULL, NULL, NULL, NULL, NULL, 'M',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    '50b820e6-22d8-4e42-a464-2f08961ff281', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    'ad3c0fd5-eafa-4460-89a7-97d6df89f4ce', 'Isaque', NULL, NULL, NULL, NULL, NULL, 'M',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    'b875fe52-d449-403d-9f2b-f749a601f5a5', 'Cleber', NULL, NULL, NULL, NULL, NULL, 'M',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    '102fb837-b437-44ee-9aae-9652c3912285', 'Ila', NULL, NULL, NULL, NULL, NULL, 'F',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    '6b3bbaaf-6cee-4f03-9402-91b349686a5e', 'Gabriela', NULL, NULL, NULL, NULL, NULL, 'F',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    '2976bb62-dfea-4503-94d3-905924c15897', 'Neide', NULL, NULL, NULL, NULL, NULL, 'F',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    'c8337867-e346-4c71-8368-08266c55bcfc', 'Alexsandra', NULL, NULL, NULL, NULL, NULL, 'F',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    'c02eb7cd-4446-4d7a-90e8-545a98fd0cd2', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    '4dc530e8-8036-4780-8b0d-138290fd165e', 'Deise', NULL, NULL, NULL, NULL, NULL, 'F',
    '61b13068-059b-4fbe-a47b-246096c8a75a', true, false, false, false, false,
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
    'f7d6b730-0eed-4faf-813e-be3d957a14db', 'Thiago Van Petten', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '4b6206c5-3c01-4680-8a2f-945a3368b1d4', 'Nara', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    'c0ae842e-8d55-4a77-bd4a-f34ce93d89e5', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '64720955-91e5-4cd5-ac48-e5ca6713a748', 'Augusto', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '481551ce-e6a4-48a9-a531-f1259ca64cd8', 'Ismar', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '8384dd06-1479-4f29-b60c-ab869f854f39', 'João Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '27892ce8-d581-4f85-8f30-5625cefccdfd', 'Sara', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    'a775bc4d-5466-42bc-a064-eeec978fa2b5', 'Denise', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '5d147d91-eb43-44b4-912b-00d298f15b8b', 'Madalena (Madá)', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '3f821bad-d438-4479-962b-fb9a6f465c24', 'Leonardo', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '8c512c31-a3d0-4253-b13f-cc471f1b0b3e', 'Tiago (Tiaguinho)', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '5b724a4f-b8da-4a3e-a05d-067b6690ead0', 'Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '78d9680b-3c8c-41ba-b799-e20732a7918c', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '3b884b6c-2405-47a7-983e-8cde14f0ba83', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    'da472999-6685-4cc5-8699-a40b231ca2b5', 'Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '948f0b08-9fcf-42b5-831c-f05cd18bfc0a', 'Elisa', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '050cea61-2ddc-4199-979f-2b0087987404', 'Mauro', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    'a48cf32c-4400-4f31-9a3c-887e067cfe0f', 'Marlene', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    'b71bf3b7-6d84-4767-89d3-7e0a588d3357', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5038d7f-60f4-4d00-9fa7-d282cfabc00f', true, false, false, false, false,
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
    '2f3cb7bb-8d85-466e-ba0e-a0196e39db8c', 'Jardir', NULL, NULL, NULL, NULL, NULL, 'M',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '95b2c2a2-c216-4f0e-9e6c-84aa0c93298d', 'Cida', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '1f353a29-151b-47a8-b60d-5cd70b713223', 'Warlei', NULL, NULL, NULL, NULL, NULL, 'M',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '2bde2a35-ff1a-4533-8269-d3b6f40aa398', 'Alba', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '08ef9000-1c52-4793-bd87-0c167488b3aa', 'Afrânio', NULL, NULL, NULL, NULL, NULL, 'M',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    'bd7e2fed-f2fe-455f-907a-906ef39fdfe9', 'Helen', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '14de28e4-dd68-45a7-aab6-ae7b94b5ff4d', 'Helena', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '205bf3f7-8bd7-428d-ba87-72eb13a6245a', 'Kátia', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '74b3a4db-a837-4e5b-9cda-ddaa87449f91', 'Cassinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    'f34fcabd-bd78-4c69-af15-ef2a84eef54b', 'Clemência', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '6c7b7318-fe3a-4667-9f64-9b7cce479e4c', 'Bárbara', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '7cc75202-bde7-4e15-81e6-e3738bf9304c', 'Perpétua', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '3a6fd9d7-0dad-4de2-9fa6-0ea02155910f', 'Ágatha', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '8f088c53-4de2-4273-93bf-90e0a8888455', 'Maria Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    'd004266d-1ecf-42f9-99e9-6b2cb17ee529', 'Claudinha', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '5113744e-dcd5-4bd9-a5ac-d4d4a29103d2', 'Saulo', NULL, NULL, NULL, NULL, NULL, 'M',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    'a960f688-772a-4901-aee9-874351caf622', 'Kioko', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '681747ed-c251-467a-b5a2-789d50d7fe19', 'Denise', NULL, NULL, NULL, NULL, NULL, 'F',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '5176ecaf-9e55-4470-af72-878c37dd696d', 'Wellington Ferreira (Shibas)', NULL, NULL, NULL, NULL, NULL, 'M',
    '94aa7979-5892-41e2-b8eb-bc711d9fb4dd', true, false, false, false, false,
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
    '6fc3fd3d-fa8f-4047-87b0-222b4bb9a55f', 'Luiz Henrique', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '1a4e50c4-5477-4cec-8658-26312515e0ad', 'Charles Pascoal', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '8bd5f869-cee2-4a71-9d8b-bb0567852f18', 'Lorena de Freitas', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    'e20afd91-0738-4109-b438-acd66c81b002', 'Ana Raquel', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    'ddcf226a-697a-458d-b113-ecc12e8d8200', 'Davi Ribeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '3b8cf2da-e1b0-4f71-8209-bd7897d7d13b', 'Jehanne', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '22cd4f2a-2dd0-4183-85d7-69e7de6f9b62', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '6f4c1d6d-16c6-469f-9c59-072f3db54d28', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    'e502b376-813e-435b-8bff-1bf8a8d9b659', 'Tiago Ribeiro', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '4e1a9e77-49a4-4e7b-9821-7bed1e7fb2f6', 'Edmilson', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '9f3741ea-5dbf-41e2-8eb7-aebd063b57db', 'Lídia', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    'cc6c1ced-7711-459e-a8d5-967b19ab23af', 'Letícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '14f3b34a-e342-4671-9361-cf94df252307', 'Flávio', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '9897c43c-b42c-41bd-8aac-c9d7421ee709', 'Darlene', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '5fbd6110-c37c-4b70-9266-9e09aaf4480b', 'Davi de Oliveira', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '4f6f32ea-1a00-4ad0-849d-44554999f7ee', 'Jonatas', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '57f1ac15-5134-47ca-9391-b5d2e92ed1a2', 'Marisa', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '88de95c3-14d7-4dc7-b352-8731636ee646', 'Raphael', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    'b7d8fdb9-0dec-4003-9217-ab813b1cb202', 'Sophia', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '78ea7139-0198-4e15-ae8c-66fbbb02223f', 'Emerson Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '4fdb878a-77fa-4c84-8592-8bf62e14926c', 'Caroline Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    'd1cdfe38-757c-4f1e-aa28-0971170b1dd9', 'Ana Clara', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '56a15252-929e-443f-b381-812f2430753b', 'Tiago Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '0853ab00-2c98-4acd-9683-4e6949baf7ac', 'Samuel Heleno', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '2f8e1196-6cfe-4645-8e6a-6d4ff6145a6f', 'Isabela Heleno', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '5ccfdeb7-6e2a-4ee7-af03-d9332ce2babb', 'Ilia Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    'c5444ebd-7625-474a-be16-752a99b92547', 'Glaydson José', NULL, NULL, NULL, NULL, NULL, 'M',
    '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb', true, false, false, false, false,
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
    '93463416-9acf-4f4e-a207-1749c61bb6df', 'Alexandre', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '092dc14f-d240-44ba-9003-d73153529ea8', 'Érica', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    'db88a238-017e-4c19-9eba-8dd543600b9c', 'Pedro', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '40b44977-84ba-4abf-a8ab-e824ec99ada8', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    'a22ce02d-c4a5-4aff-a3bb-f328213cf6a4', 'Heloísa', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '40133761-8eed-4725-be4f-81855655d743', 'Tames', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '0f70a77f-c13e-42e2-a983-d285cf37ab17', 'Michelle', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '961ca175-7d3f-4580-b4ea-6dabcd95d0bd', 'Helisa', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '75fc919f-348f-4e89-a320-fe3cbdab4cd8', 'Adelmo', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '516fd14d-d306-4ed3-a223-9b87680539d0', 'Júnia', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    'a992df26-67db-4308-808c-774a4ab38a4a', 'Neuza', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    'de00ff1f-eabb-4593-a857-6b78bb2228fb', 'Rosa', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '873d4980-4e53-46f5-a03e-44d9dbdfdd2e', 'Juan', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '7f83e971-59c3-4e51-934c-b2de7ba5f9e0', 'Ximena', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    'c7e0ccfa-72e2-4641-b9b5-458a2286c514', 'Valentina', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    'c5c25dd8-dcc3-4d2b-a337-0334db5c97d5', 'Victória', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '52db9144-a9cc-4371-b5de-4eb9c53c6608', 'Antonella', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '3794c3ce-3837-4385-95be-d9752b952b8c', 'Júnior', NULL, NULL, NULL, NULL, NULL, 'M',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '956dc23c-6e49-4603-95ac-0ed7bbec1c3d', 'Silvana', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    '7a096c0e-0db8-4d95-af54-49cb8ea1c559', 'Emanuelle', NULL, NULL, NULL, NULL, NULL, 'F',
    'd5225343-ca7c-4212-8423-ee298e2e4255', true, false, false, false, false,
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
    'e42990d9-221d-4f6a-a0ca-56876b1a60cc', 'Jairo', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'f31522a7-2b18-422d-a6c7-bc48080aa05d', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '7b718d3a-8438-4551-a9a9-569a1b9747fd', 'Camila', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '1726a709-7ac4-4ee5-9354-92a4a51e94dc', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '036b3af9-a904-47f2-997c-2dccd58f7241', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '3ea7012f-7343-418d-9c90-143f5e33a442', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'dca8e36f-1bd4-4d52-ab39-470badcc7370', 'Emanuele', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '6c80b073-c492-4b0a-8dca-805405508524', 'Geovana', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '2a3d6176-4538-4daf-b1ab-7b44f0264f10', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '22fec886-6757-4c6c-ad27-ffc82323b05a', 'Warley', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'b930850a-f8ed-40fc-afd1-4464468428d8', 'Deise', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '7a2b4e50-c557-4633-b572-213f3adabf2d', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'f15eaf56-a583-4688-9b7d-ea55083e17e1', 'Jetro', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '2978482f-65e5-4b56-bd58-b8188fe34702', 'Olício', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'be4a7b12-50be-4973-a1e2-8afe22640313', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'b88d5be8-1469-4a92-8351-97d69dd1d503', 'Noah', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '9cd33887-5109-4879-ac3e-d07a7f1c4f07', 'Maria Alice', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'b2d681b9-36e3-404c-a558-dc438e05439c', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'de432b3f-0888-465f-8b2a-3b69cd87d8ef', 'Jéssica', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'f5a3e244-73ac-443a-bf04-5bd4b088c933', 'Marcos', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'b42b967a-1d6b-4413-9698-fda2bd6c1bba', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'f4dac543-85c1-484a-affb-a729a14d31bf', 'Emilly', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'd303c068-9de1-4048-a1d0-fd369183af60', 'José Maurício', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '82cd8693-3470-4046-a9ad-2a73f2032112', 'Gutemberg', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'e0a9c953-cba2-4adf-bb5a-b4ebcf8d42e8', 'Mizael', NULL, NULL, NULL, NULL, NULL, 'M',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'f3798b01-979d-4e8a-ba6c-64a2646b15f3', 'Helen', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '80f59c68-7b84-4b4f-aa65-b01c39e54c51', 'Luana', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    'b5bfce9c-183e-481f-b165-543dd175932c', 'Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    '6874331a-31dd-404f-b983-1e669a58ded7', true, false, false, false, false,
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
    '261a3038-4320-4697-8823-40fbe1b5af09', 'William', NULL, NULL, NULL, NULL, NULL, 'M',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '191ff051-4398-4bdf-b188-c014f05a6846', 'Simara', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '88f06b75-1453-4692-922a-5d4df40e81c8', 'Wenderson', NULL, NULL, NULL, NULL, NULL, 'M',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '4320f7b2-5640-43d7-bf5d-729f5018b583', 'Renata', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '806da840-e6a0-47d0-9c48-73bdde32fba6', 'Fátima', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '47cab605-b882-48b1-bdd5-242a94e5b48d', 'Fernando', NULL, NULL, NULL, NULL, NULL, 'M',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    'ebb40e70-f04f-4b6b-93d6-fa1b4b675e86', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '69c1caf9-a674-4e61-b66a-a873997d6dc2', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    'f88957e2-40ff-44bf-8462-f926d1863713', 'Bianca', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    'a8c96559-474f-486d-9c82-63e9f3e90e4c', 'Gláucia', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '6fda41bb-d790-477a-817f-781f4882fbf7', 'Fernanda', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '15a74521-77fd-4113-a175-865599cac9a4', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    '593ed824-0634-47b5-bcd5-22c28de664a3', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '4b46a123-8af6-4ede-841b-e89e82f87390', true, false, false, false, false,
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
    'f1b9627a-24e2-4db5-82e3-0aada5b6603f', 'Cléber', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'a72db742-5299-48fb-99c1-add56acbaadd', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '29a42522-97c5-4c52-901d-39fdd3867830', 'Camilla', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'c584a8b3-562f-4b18-b994-5574a69ef2f0', 'Caio Vitor', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '4744e9ec-a15f-4f96-a81b-0e360a418891', 'Marina', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '7071838f-2bfe-4c05-b585-5ccca33e77e9', 'Marcelo', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'e71b6dba-a1a1-4166-a749-2a32ee049a8f', 'Simone', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '81b2e92b-2f53-4aa3-9fc9-0ae8b1a81c60', 'Beatriz', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'f4dcb992-67e6-4d8d-a6d9-c150bc6423b5', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'cace5470-4861-446c-9dce-c5cabc130666', 'Bruno', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '94a1b3ce-ce44-4a5f-8c99-34113f73178a', 'Vanusa', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '036b14a5-5007-4d96-91f8-5f2437c041b2', 'Abner', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'abea98a8-bc87-42f1-9d41-318bc3669b51', 'Fabiana', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'a0795e67-7133-4808-b2ec-811a9dced93d', 'Levi', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '6e060b39-e021-46fb-b669-74185758dfa6', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'da05827b-bf58-4f97-bb6e-3b4760382dc0', 'Nely', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '7c066979-3f86-4c20-b7f9-4c3f9e3fc489', 'Rafaela', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '15ef2c09-3052-4b0f-8be1-86b27befdba5', 'Luís', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '37973a6a-7872-4033-8ff0-faf0f9790202', 'João', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '885dcff6-6dfa-463e-90f8-1b329afe34c9', 'Lourdes', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '4c8540ba-a101-4fee-9b5d-1c8a1276486e', 'Denim', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '6949ca7e-ad93-4433-942b-fd5b2e90d2e3', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '503856ac-edcb-4084-b667-0d1fe8b21bd8', 'Ismael', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '9ffaccdb-de15-4c85-98a9-ebd116452557', 'Isac', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '3a0adc98-e550-4e23-b615-d2b43e63d257', 'Daniel', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '2d16b539-bfdb-4251-a2a8-53bb57d0bc10', 'José Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '881d7ba0-b789-421d-9ee4-40fcac933cdf', 'Fagner', NULL, NULL, NULL, NULL, NULL, 'M',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    '45c8769a-a68b-418d-929f-d7cdf8ef39ea', 'Lauren', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'b4b5a2d4-1d4f-44a0-9eec-3f528de5f948', 'Rosângela', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'a13147eb-afdb-4d50-be88-0e24c941b307', 'Suzi', NULL, NULL, NULL, NULL, NULL, 'F',
    '0dab1ca8-74b8-4131-8d21-b05bbf13f12b', true, false, false, false, false,
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
    'bbc02073-1866-45b1-9fb8-6fe7c61ca0be', 'Marilson', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '210bab9b-dbb9-4db3-a407-9c9ddb9bd2dc', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '905e94e4-4237-4c2a-a6f6-3dfee2cae6a7', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '326a0e58-1db7-4d6f-baec-9605aaf6e89f', 'Gilson', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '5917a61a-2bf8-4bd8-9ba2-f35d5bf56324', 'Nislândia', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'ba61eeab-3733-4b81-a513-32197be98b4a', 'Izabela', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'd2ae9184-194a-4e33-9fb6-3fdc6b0a3a62', 'Ana Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '3767ccc8-65fd-4473-a986-f69d772708ef', 'Rafael', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'ea29d78e-2d40-4662-97ff-b3e218cb7ac3', 'Wanderluz', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '464f8926-9a3f-44a9-9a75-44a5b8865c5f', 'Janete', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '6b541f6a-987e-47d6-8896-98f5d9c95a45', 'Eduarda', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '0dc42ae5-d60b-4e60-a3f7-0cfa83420c72', 'Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'dc8037ee-f406-477d-b28c-6fb6f9afbff7', 'Dilvano', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '42ea1e02-457a-41c6-b0c0-e3025593bd34', 'Edilene', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'a10eac0a-c9dd-4828-96e5-9ede89d724a0', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '2ff70477-42b4-4ea3-a2c0-ccc751fb1a45', 'Josué', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '5568cae3-c3b2-453f-8f9d-8d3fd2edf1b1', 'Lorena', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '4d0a61d7-0b72-47e5-84a7-db4ab453535b', 'Miguel', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'd74f145d-940a-48e9-8536-0c9b5d7e4ed1', 'Emanuel', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '850a789d-a1ed-4714-a07d-4ed671f48ec2', 'Guilherme', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '4480ebec-ce3e-4acd-870b-3abc8b618be1', 'Priscila', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '22db93b8-3614-47ab-ae95-d00ea06a918f', 'Suely', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '8e0f5221-e0b6-4c94-ae6f-6d6b603c35b6', 'Filipe', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '7b4d3c67-be95-4f03-a309-b14d0d991f47', 'Talita', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'cccca244-cd48-4d7c-896e-a8768568c4c4', 'Benjamin', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'f2d55038-d517-4255-bb30-fb7fc41111cc', 'Luciano', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '45f8b398-205a-49ab-82ad-ea77c09dac9e', 'Joana', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '0b7e15b7-aab1-427f-9e66-cc41493312bb', 'Raíssa', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '57492e9b-2578-4fc9-98c9-9aba2c0ef92b', 'Luciana', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'ce4cbb2c-5a96-4cc6-8d73-555e1c57338c', 'Abner', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'a201aab3-50a2-414a-9c2d-395c3100a76c', 'Ranma', NULL, NULL, NULL, NULL, NULL, 'F',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '56dd7459-d8e2-401f-b9e4-58a8cd568b81', 'Jonata', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    'ed40c26f-fe97-4102-8231-5ce38bad3f4e', 'Isac', NULL, NULL, NULL, NULL, NULL, 'M',
    'd1355e55-6c25-4d6f-ba5a-ad32daec0de7', true, false, false, false, false,
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
    '452eb67a-5995-4510-97a6-5544f7efa153', 'Artur Cunha', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '1b52b8d2-ccd1-4507-bed0-bb6b74c7bf67', 'Thaís Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'ede370be-a8b1-4fd3-a5d4-4c45097c49b0', 'Isabela Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'e60bb5bf-da6d-4814-a46e-e22b7e110477', 'Júlia Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'bb3dfbc4-3cbc-4df5-960e-7de375efffdc', 'Sofia Cunha', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '7b8b10dc-c378-4c75-9a81-737f77eb2cc4', 'Douglas Macaúba', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '0a5a333c-97f7-4951-80f0-ee95c9eaab1a', 'Carol', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '5b54f84a-63c0-42d0-85f0-951641871d32', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '7e116062-a746-42b8-be49-04c155e81074', 'Thiago', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '3fa054a5-0dd0-444c-a4d9-913e4a9dd8c3', 'Carine', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '4bdb4f32-c0e1-4256-96ef-042237d23b56', 'Melina', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '0e8c00fa-80b6-431d-bac3-9ad74c6bd0d5', 'Maria', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'bd95dcbd-5132-41f5-863a-249d8f71ddbc', 'Diego', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '8aafef63-ece5-4d6f-8e43-5fa47d2bda7a', 'Gisele', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '87a72534-b5cd-4f95-b458-dd8c65b757d9', 'Samuel', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'e000754d-6c73-4a36-9cc2-b9469234f687', 'Graziele', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '03edb61e-13db-4d86-9b1a-2bb1cf057c06', 'Imaculada', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '1c67a8c5-c463-4db0-a07c-953ad28e8923', 'Carlos', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '2da55b2a-63c8-48bc-9296-19db1b203e42', 'Vinícios', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '5baffafa-dde2-45f5-bd4a-964fd5c71fd8', 'Sônia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '8ca499b3-18ca-48c5-a832-9a66dcc41655', 'Ana Eloísa', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '63781cec-1f3f-4a35-86c3-e6238adf113f', 'Maria Júlia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '4b09cbdb-fb99-4d31-aea4-2a7f7c1f3e45', 'Heitor', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'c2133747-544d-4787-a3bd-0f473e9248ea', 'Martim', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '6c6a73e0-86b6-44f8-910a-7f50b0bfc502', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'db7b8332-44d7-49e7-bee9-c3dfd51d5ee7', 'Laura', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'a429ce81-8ce4-455b-b111-3c2263483abc', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '3f0b7fd5-fdd5-4437-816c-a5a251bff674', 'Gabriel', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '23c39bf5-81dc-4f6f-a2a0-98322f692b35', 'Isaque', NULL, NULL, NULL, NULL, NULL, 'M',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    '5394e221-5f8c-4ca2-a626-c641b469118c', 'Zélia', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'f2cef581-a9f2-4ce4-9230-8f6cfd641721', 'Keila', NULL, NULL, NULL, NULL, NULL, 'F',
    'ab7255d8-21f0-40e9-9834-6d59c57662ad', true, false, false, false, false,
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
    'b5b7bb42-7e19-4bde-96c3-55783807b875', 'Lucas', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '34460ba9-08c2-446f-a28c-1b4e26d3d085', 'Leila', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'f31e7da5-b706-4d96-b3ae-c658d24c7ac9', 'Ivan', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '538b1ab0-3027-4264-a1b5-c19d1bcbecbc', 'Ester', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '301313cb-9edf-4df9-880c-861d0bdf8684', 'Eliel', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '77535d8c-a688-4192-888d-99456c03d219', 'Fabíola', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '8a434afa-8709-4e7a-a201-3e0518ca6033', 'Davi', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'bad3f0d4-29b5-499b-8a82-70ce9dcae94e', 'Ana', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '7daaa1ca-a3b2-4234-945f-f6c2e4bd1741', 'Ramon', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'c41ab840-a4a1-46f8-910b-b89458465c50', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '06973d28-aa7e-4c2e-ae1b-6efcb1bf11ab', 'Ravi', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '65d0f5a0-56bc-44e1-aad6-dae19638a5b6', 'Melissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'f0144a74-2985-4ec5-b933-e7473a503419', 'Rodrigo', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'b82ac044-4e47-4425-9dc3-5bcf3e303069', 'Cláudia', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '172fee5f-4fd4-4824-a0f9-da400af0ea5b', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '0c3d6b39-e4b4-43e0-84ed-645651f95a95', 'Antônio', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'd5a73f79-50e8-4a15-ba86-a31278f3be6f', 'Jaqueline', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '9ac50c57-89af-4d08-ba18-266f2b6ac8f3', 'Verônica', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'd680f938-5386-40d0-bf9d-9de567ab4d22', 'Nileide', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'ff3860fa-07b0-49ff-b045-8dc21b761c9a', 'Fábio', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'b0ec4c8e-d920-4c8a-9139-7a65d546ed25', 'Larissa', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'c7f9f1d8-67c4-4c2e-bd28-2dd3324961f0', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '85611862-60ff-4126-9f56-20c089b8f1a9', 'Suzana', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '41884764-c095-48ed-815e-a929857df671', 'Lorena', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '26a40082-8ea7-407d-80e7-8abaadcd4dd0', 'Asaph', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    'bac793b5-2770-4659-a5c2-dac9bfcc55c5', 'Leandro', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '8c252007-45c9-4ba7-a90a-8f6c6032f9ba', 'Tainara', NULL, NULL, NULL, NULL, NULL, 'F',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '126e5cbd-2717-4bee-9e8c-4950a7768a72', 'Théo', NULL, NULL, NULL, NULL, NULL, 'M',
    '945ec463-4cf1-48f2-a20f-f21d9003e0e8', true, false, false, false, false,
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
    '58898f09-f0cb-433c-9f15-d1ecee59d3b2', 'Cláudio Lopes', NULL, NULL, NULL, NULL, NULL, 'M',
    'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa', true, false, false, false, false,
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
    '0cefc313-23b1-43cc-85e7-8b97db1a9b99', 'Zulmira Lopes', NULL, NULL, NULL, NULL, NULL, 'F',
    'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa', true, false, false, false, false,
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
    'd1f54d17-19a3-4896-a5ad-bc4dfcfc0be0', 'Cristina Barbosa', NULL, NULL, NULL, NULL, NULL, 'F',
    'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa', true, false, false, false, false,
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
    '5105d1bd-7228-4abe-8b89-9d6545760034', 'Ismênia Ferreira Rezende', NULL, NULL, NULL, NULL, NULL, 'F',
    'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa', true, false, false, false, false,
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
    '565a3846-51e7-42e2-aba4-85db60bbd30a', 'Maria das Graças', NULL, NULL, NULL, NULL, NULL, 'F',
    'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa', true, false, false, false, false,
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
    'c2756a74-66b5-4464-b6dc-fb5cb58378c5', 'Samuel Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, 'M',
    'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa', true, false, false, false, false,
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
    '5f26e08a-d4a1-47d2-811a-60e183911ee2', 'Kamila Rabelo Guimarães', NULL, NULL, NULL, NULL, NULL, 'F',
    'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa', true, false, false, false, false,
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
    '74d1cdaf-2b3c-4ff9-af30-b25d39486fcb', 'José Antônio', NULL, NULL, NULL, NULL, NULL, 'M',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    'fc1fb7a7-afdc-4999-9eb2-fb016bb98f87', 'Eliane', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    'c835a872-b07f-48d4-89dd-3acbf0a8b842', 'Geraldo', NULL, NULL, NULL, NULL, NULL, 'M',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    '508f5fc2-76ea-48b1-8e0e-098d522fb046', 'Adriana', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    '28670730-f375-46ba-919c-8853b7903946', 'Uyara', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    '6ac5e9c4-075e-4ef4-8244-30537a83235f', 'Uyrlan', NULL, NULL, NULL, NULL, NULL, 'M',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    'fcd20f02-61ee-487f-b082-37216166fa75', 'Luíza', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    'c0a16c6d-1f2a-4df1-9582-1a4bb4bea225', 'Suzana', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    '11865c14-2321-4b46-acd4-b6bc2c95ca97', 'Welington', NULL, NULL, NULL, NULL, NULL, 'M',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    'a929879f-0a52-4a74-bc30-e8a2e7d77a87', 'Patrícia', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    '29d87c7d-228a-40a9-b4d3-9da2d4176eca', 'Nicole', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    'a52355c1-10f2-48d2-b0b9-7a9443ddb268', 'Ariane', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    '3c592361-4399-4dd4-a539-94833869c91b', 'Hebert', NULL, NULL, NULL, NULL, NULL, 'M',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
    'e649e829-dc55-4ce9-9403-ecd87c28ecf9', 'Natália', NULL, NULL, NULL, NULL, NULL, 'F',
    '8ed09a5c-1503-465b-ab3c-3d0501551f86', true, false, false, false, false,
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
      jsonb_build_object('full_name', 'Gabriel Góes Braga', 'cpf', '132.507.246-02'),
      now(), now(), 'authenticated', 'authenticated', '', '', '', ''
    ),
    (
      fernando_auth_id, '00000000-0000-0000-0000-000000000000', 'fgb80@yahoo.com', pwd_hash, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('full_name', 'Fernando Gomes Braga', 'cpf', '103.821.540-52'),
      now(), now(), 'authenticated', 'authenticated', '', '', '', ''
    ),
    (
      clara_auth_id, '00000000-0000-0000-0000-000000000000', 'claradiscipula@gmail.com', pwd_hash, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('full_name', 'Clara Góes Braga', 'cpf', '167.370.473-66'),
      now(), now(), 'authenticated', 'authenticated', '', '', '', ''
    );

  -- Vinculação explícita de user_id nos perfis principais
  UPDATE public.profiles SET user_id = gabriel_auth_id WHERE id = gabriel_id;
  UPDATE public.profiles SET user_id = fernando_auth_id WHERE id = fernando_id;
  UPDATE public.profiles SET user_id = clara_auth_id WHERE id = clara_id;


  -- ==========================================================================
  -- 5. ATUALIZAR LÍDERES DOS GCs (35 Grupos)
  -- ==========================================================================

  UPDATE public.home_groups SET leader_1_id = '219a120e-ff58-405f-83ba-933279e08896', leader_2_id = NULL WHERE id = '2d4b6762-5fae-40ad-8bfb-fd6edebd44d8';
  UPDATE public.home_groups SET leader_1_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1', leader_2_id = '7e4e09e8-1878-4ea2-9355-30e55ddab65b' WHERE id = 'b5ea8c19-2d35-48a2-b2bf-824e59968519';
  UPDATE public.home_groups SET leader_1_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7', leader_2_id = '7c3a7310-e6ce-4794-a8d6-99fab6ec20ed' WHERE id = '5e1312d6-51b1-422f-9db2-fd75f9dd03a6';
  UPDATE public.home_groups SET leader_1_id = 'bcd9ffb6-aa46-4c19-9a88-41989cfe0598', leader_2_id = NULL WHERE id = 'e939abea-3ef0-4514-b26c-1ee7cf1c438c';
  UPDATE public.home_groups SET leader_1_id = 'f9ca51cb-1d30-43a0-8192-37b27725defb', leader_2_id = NULL WHERE id = 'c38d4e1a-15fc-41df-9091-9cf5c3604cde';
  UPDATE public.home_groups SET leader_1_id = '9d212800-0ba6-40d8-8715-bf2e250999f9', leader_2_id = NULL WHERE id = '88a5824a-d469-42d4-9eca-4e36f795deba';
  UPDATE public.home_groups SET leader_1_id = '2ce6c9f2-9ce9-4ab0-8495-ae6e43ed1e8f', leader_2_id = NULL WHERE id = 'e7a2e9d4-513f-4d09-a4dd-45a2d20e9fc5';
  UPDATE public.home_groups SET leader_1_id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3', leader_2_id = NULL WHERE id = 'f10f3ae3-fc50-4966-ad78-101e43dc7bc6';
  UPDATE public.home_groups SET leader_1_id = 'ad24591c-02e7-4a8e-9d21-bb38c8449793', leader_2_id = NULL WHERE id = 'a9fc7ec3-8c0f-4638-86c4-2407b4f95f71';
  UPDATE public.home_groups SET leader_1_id = 'e24a1b13-3acf-4c22-9726-7a263ebb9902', leader_2_id = NULL WHERE id = '8dc501c9-06de-441d-bf78-cb2269559fb2';
  UPDATE public.home_groups SET leader_1_id = 'af590c9f-12d7-457d-8b43-39fbbaf2e5db', leader_2_id = 'f48ae622-64c2-4b0d-af76-ad4a8208d098' WHERE id = '7f07285a-f15d-441a-af8f-b9a1f3f87081';
  UPDATE public.home_groups SET leader_1_id = 'ab5c3b50-070e-42c4-ba65-a73f2b3768db', leader_2_id = '7d5a8f77-6d3e-4e9d-b5da-ca58a7af12a1' WHERE id = '57fcb51d-1716-40e9-ada8-93b422f3e066';
  UPDATE public.home_groups SET leader_1_id = 'd4dfc0ac-2e23-4805-9b63-02ba2d4bc4d7', leader_2_id = NULL WHERE id = 'b229c98c-6d81-4fa1-bb7b-ba53f274fd94';
  UPDATE public.home_groups SET leader_1_id = '56f6889f-ba1d-4ff5-b31d-933bd4b10105', leader_2_id = NULL WHERE id = '0ea5a8e6-f7dc-49fb-8e9c-0a9e293cd5b2';
  UPDATE public.home_groups SET leader_1_id = 'd5009d58-dd2a-41dd-889e-ffcd27ae4034', leader_2_id = NULL WHERE id = 'dc45ef9d-4bc6-4a13-ac6e-2665ec6b7d08';
  UPDATE public.home_groups SET leader_1_id = '1d6f2814-903c-4f37-9212-728078805f44', leader_2_id = '768e2171-752d-4fb3-be67-dc7e40ab9ae0' WHERE id = '5714b151-16c5-4509-a7f7-1431768130c9';
  UPDATE public.home_groups SET leader_1_id = 'a2cbca82-b7f2-4634-af7c-851ae58b9265', leader_2_id = 'ccd0ea9f-27ee-4b51-baf9-91dde838fc74' WHERE id = '3a0ecbfe-05a7-4595-b824-2f0299d71d2d';
  UPDATE public.home_groups SET leader_1_id = '0078dfb7-a8a2-4b4a-9289-d966af4a0a37', leader_2_id = 'efdd1777-2471-4c0e-b45b-b225c581dc7b' WHERE id = 'b3bdadc6-5400-4e3f-8ac2-73351974f4c3';
  UPDATE public.home_groups SET leader_1_id = '3b8b379e-487b-42b4-9c3e-4db8f476bcf6', leader_2_id = NULL WHERE id = 'e33d7058-96e5-48d5-a7f8-a1301f1f1821';
  UPDATE public.home_groups SET leader_1_id = '1b61df57-60e3-43d1-b202-94778723bc75', leader_2_id = NULL WHERE id = '730f6bed-ef15-44b8-b8f8-d808c9739131';
  UPDATE public.home_groups SET leader_1_id = '83009bc4-07d9-4e12-8023-d142333013fc', leader_2_id = '79c3061a-ab1c-4323-95c0-0ddd57363136' WHERE id = '724fd5b5-9e80-42f3-9b4e-63f2ec5f47aa';
  UPDATE public.home_groups SET leader_1_id = 'b526bab6-c753-4970-93f7-e3481115816e', leader_2_id = NULL WHERE id = 'f10b3c41-de40-4526-8aa0-76e00a268b08';
  UPDATE public.home_groups SET leader_1_id = 'b3e686c7-d8b2-44ba-85e6-0d6799516e05', leader_2_id = NULL WHERE id = '61b13068-059b-4fbe-a47b-246096c8a75a';
  UPDATE public.home_groups SET leader_1_id = '8384dd06-1479-4f29-b60c-ab869f854f39', leader_2_id = 'f7d6b730-0eed-4faf-813e-be3d957a14db' WHERE id = 'd5038d7f-60f4-4d00-9fa7-d282cfabc00f';
  UPDATE public.home_groups SET leader_1_id = '2f3cb7bb-8d85-466e-ba0e-a0196e39db8c', leader_2_id = NULL WHERE id = '94aa7979-5892-41e2-b8eb-bc711d9fb4dd';
  UPDATE public.home_groups SET leader_1_id = '78ea7139-0198-4e15-ae8c-66fbbb02223f', leader_2_id = NULL WHERE id = '08ba3cf2-ab22-4ad9-b3a9-6c81f23ef3eb';
  UPDATE public.home_groups SET leader_1_id = '873d4980-4e53-46f5-a03e-44d9dbdfdd2e', leader_2_id = '93463416-9acf-4f4e-a207-1749c61bb6df' WHERE id = 'd5225343-ca7c-4212-8423-ee298e2e4255';
  UPDATE public.home_groups SET leader_1_id = 'e42990d9-221d-4f6a-a0ca-56876b1a60cc', leader_2_id = NULL WHERE id = '6874331a-31dd-404f-b983-1e669a58ded7';
  UPDATE public.home_groups SET leader_1_id = '261a3038-4320-4697-8823-40fbe1b5af09', leader_2_id = NULL WHERE id = '4b46a123-8af6-4ede-841b-e89e82f87390';
  UPDATE public.home_groups SET leader_1_id = 'f1b9627a-24e2-4db5-82e3-0aada5b6603f', leader_2_id = 'c584a8b3-562f-4b18-b994-5574a69ef2f0' WHERE id = '0dab1ca8-74b8-4131-8d21-b05bbf13f12b';
  UPDATE public.home_groups SET leader_1_id = 'bbc02073-1866-45b1-9fb8-6fe7c61ca0be', leader_2_id = NULL WHERE id = 'd1355e55-6c25-4d6f-ba5a-ad32daec0de7';
  UPDATE public.home_groups SET leader_1_id = '452eb67a-5995-4510-97a6-5544f7efa153', leader_2_id = NULL WHERE id = 'ab7255d8-21f0-40e9-9834-6d59c57662ad';
  UPDATE public.home_groups SET leader_1_id = 'b5b7bb42-7e19-4bde-96c3-55783807b875', leader_2_id = NULL WHERE id = '945ec463-4cf1-48f2-a20f-f21d9003e0e8';
  UPDATE public.home_groups SET leader_1_id = '58898f09-f0cb-433c-9f15-d1ecee59d3b2', leader_2_id = NULL WHERE id = 'ddd6d2bc-ed91-4cf6-adca-a0ffad10a9fa';
  UPDATE public.home_groups SET leader_1_id = '74d1cdaf-2b3c-4ff9-af30-b25d39486fcb', leader_2_id = NULL WHERE id = '8ed09a5c-1503-465b-ab3c-3d0501551f86';

  -- ==========================================================================
  -- 6. ATUALIZAR CASAMENTOS (spouse_id) E FILIAÇÃO (father_id, mother_id)
  -- ==========================================================================

  UPDATE public.profiles SET spouse_id = 'e81475a5-a09d-4269-bae2-4b5f9009b7e8' WHERE id = '219a120e-ff58-405f-83ba-933279e08896';
  UPDATE public.profiles SET spouse_id = '219a120e-ff58-405f-83ba-933279e08896' WHERE id = 'e81475a5-a09d-4269-bae2-4b5f9009b7e8';
  UPDATE public.profiles SET spouse_id = '2c1a15d7-517a-4b42-b5ac-54230fe4769e' WHERE id = '044a0d94-2dc6-40e1-bf37-1812bcae79aa';
  UPDATE public.profiles SET spouse_id = '044a0d94-2dc6-40e1-bf37-1812bcae79aa' WHERE id = '2c1a15d7-517a-4b42-b5ac-54230fe4769e';
  UPDATE public.profiles SET spouse_id = '28e97996-fd77-4f65-80f7-c1aeaf0e4e28' WHERE id = '9396e709-343e-4ed7-888f-a74fa83910ef';
  UPDATE public.profiles SET spouse_id = '9396e709-343e-4ed7-888f-a74fa83910ef' WHERE id = '28e97996-fd77-4f65-80f7-c1aeaf0e4e28';
  UPDATE public.profiles SET spouse_id = '843dcf1e-fddb-48a1-8985-182fed900093' WHERE id = '2ba3cd78-bb32-497c-bb99-6e4711657460';
  UPDATE public.profiles SET spouse_id = '2ba3cd78-bb32-497c-bb99-6e4711657460' WHERE id = '843dcf1e-fddb-48a1-8985-182fed900093';
  UPDATE public.profiles SET spouse_id = '425e5c0e-79da-41a5-b2c6-f930bd6eb23e' WHERE id = '6b7b1503-8f48-409c-a0d9-d6ccf021d6c2';
  UPDATE public.profiles SET spouse_id = '6b7b1503-8f48-409c-a0d9-d6ccf021d6c2' WHERE id = '425e5c0e-79da-41a5-b2c6-f930bd6eb23e';
  UPDATE public.profiles SET spouse_id = '3215a739-9748-4ded-bf1b-60e7a15dcf3a' WHERE id = 'c217d85b-3422-4198-86f8-2ca90b6ca039';
  UPDATE public.profiles SET spouse_id = 'c217d85b-3422-4198-86f8-2ca90b6ca039' WHERE id = '3215a739-9748-4ded-bf1b-60e7a15dcf3a';
  UPDATE public.profiles SET spouse_id = 'd5b0c069-8cae-4bd3-9fb3-2b862e55f9b3' WHERE id = 'eaf52b9c-d7d1-48dd-ad19-a287a6807df0';
  UPDATE public.profiles SET spouse_id = 'eaf52b9c-d7d1-48dd-ad19-a287a6807df0' WHERE id = 'd5b0c069-8cae-4bd3-9fb3-2b862e55f9b3';
  UPDATE public.profiles SET spouse_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1';
  UPDATE public.profiles SET spouse_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1' WHERE id = '0173059d-1312-42d5-834f-d5025499ee10';
  UPDATE public.profiles SET spouse_id = '89dfdb4e-b84c-49f0-91b3-b26f4811a90a' WHERE id = 'cc8ca953-c753-4781-b6ac-d9585c236831';
  UPDATE public.profiles SET spouse_id = 'cc8ca953-c753-4781-b6ac-d9585c236831' WHERE id = '89dfdb4e-b84c-49f0-91b3-b26f4811a90a';
  UPDATE public.profiles SET spouse_id = 'cde1c6ad-2f8b-4543-859a-defd8b5d50e9' WHERE id = '45658447-a13b-4a51-9ec3-0a9e584043bf';
  UPDATE public.profiles SET spouse_id = '45658447-a13b-4a51-9ec3-0a9e584043bf' WHERE id = 'cde1c6ad-2f8b-4543-859a-defd8b5d50e9';
  UPDATE public.profiles SET spouse_id = '6baed437-e3fe-4de6-b86f-049c801dce3c' WHERE id = '8ca46ee3-feb4-48de-b7ff-07717d68e3fe';
  UPDATE public.profiles SET spouse_id = '8ca46ee3-feb4-48de-b7ff-07717d68e3fe' WHERE id = '6baed437-e3fe-4de6-b86f-049c801dce3c';
  UPDATE public.profiles SET spouse_id = '4477f189-e461-4d08-b3c9-caf05f98c772' WHERE id = 'ec051e64-ffce-4f37-bfb7-c2f6e29bfdd1';
  UPDATE public.profiles SET spouse_id = 'ec051e64-ffce-4f37-bfb7-c2f6e29bfdd1' WHERE id = '4477f189-e461-4d08-b3c9-caf05f98c772';
  UPDATE public.profiles SET spouse_id = '337bdc08-6b2c-41f1-ac84-937e2c960b8e' WHERE id = 'afd19ec0-75da-4df1-8b60-d9402e912d46';
  UPDATE public.profiles SET spouse_id = 'afd19ec0-75da-4df1-8b60-d9402e912d46' WHERE id = '337bdc08-6b2c-41f1-ac84-937e2c960b8e';
  UPDATE public.profiles SET spouse_id = 'dc0ba837-ab0f-4d73-ad6f-484cab57b496' WHERE id = '7e4e09e8-1878-4ea2-9355-30e55ddab65b';
  UPDATE public.profiles SET spouse_id = '7e4e09e8-1878-4ea2-9355-30e55ddab65b' WHERE id = 'dc0ba837-ab0f-4d73-ad6f-484cab57b496';
  UPDATE public.profiles SET spouse_id = 'e050cb39-15bb-4fac-bc7c-0ddb41541a66' WHERE id = '31dd4142-d016-460e-a53a-a074387887ba';
  UPDATE public.profiles SET spouse_id = '31dd4142-d016-460e-a53a-a074387887ba' WHERE id = 'e050cb39-15bb-4fac-bc7c-0ddb41541a66';
  UPDATE public.profiles SET spouse_id = 'f91068e8-62ed-46ec-bb69-2bf6287f9300' WHERE id = '0f37069a-c847-441d-8700-503df3a5eb80';
  UPDATE public.profiles SET spouse_id = '0f37069a-c847-441d-8700-503df3a5eb80' WHERE id = 'f91068e8-62ed-46ec-bb69-2bf6287f9300';
  UPDATE public.profiles SET spouse_id = 'b3f5b24c-5db8-49b4-ac05-aa9a6a738d74' WHERE id = 'ee5e2ce1-8e47-4830-ab8d-f653905488e7';
  UPDATE public.profiles SET spouse_id = 'ee5e2ce1-8e47-4830-ab8d-f653905488e7' WHERE id = 'b3f5b24c-5db8-49b4-ac05-aa9a6a738d74';
  UPDATE public.profiles SET spouse_id = '11f14cf7-7af8-46d4-8a33-f7f4143ee2a6' WHERE id = '576a3f90-bbd1-4fda-9f3a-92ad190cbf86';
  UPDATE public.profiles SET spouse_id = '576a3f90-bbd1-4fda-9f3a-92ad190cbf86' WHERE id = '11f14cf7-7af8-46d4-8a33-f7f4143ee2a6';
  UPDATE public.profiles SET spouse_id = 'd2f9b13f-b958-42e3-827c-b76c25be11c4' WHERE id = 'a1946d29-22e6-41d0-9da8-bebc95854689';
  UPDATE public.profiles SET spouse_id = 'a1946d29-22e6-41d0-9da8-bebc95854689' WHERE id = 'd2f9b13f-b958-42e3-827c-b76c25be11c4';
  UPDATE public.profiles SET spouse_id = '5d89236b-d7c7-491b-b8e6-cb2ceb8ec689' WHERE id = '7c3a7310-e6ce-4794-a8d6-99fab6ec20ed';
  UPDATE public.profiles SET spouse_id = '7c3a7310-e6ce-4794-a8d6-99fab6ec20ed' WHERE id = '5d89236b-d7c7-491b-b8e6-cb2ceb8ec689';
  UPDATE public.profiles SET spouse_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7';
  UPDATE public.profiles SET spouse_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = '7ee41141-243b-4aea-986a-6492efe1b957';
  UPDATE public.profiles SET spouse_id = '45b5215a-e43e-40ee-bd5e-e31cace3b45a' WHERE id = 'a721678f-add7-4f85-bcff-c64d77a072b6';
  UPDATE public.profiles SET spouse_id = 'a721678f-add7-4f85-bcff-c64d77a072b6' WHERE id = '45b5215a-e43e-40ee-bd5e-e31cace3b45a';
  UPDATE public.profiles SET spouse_id = 'cb35fefc-3ec0-4a04-a645-abd3ca790a41' WHERE id = 'a984e0dc-5082-401c-a77f-44b4146e15a2';
  UPDATE public.profiles SET spouse_id = 'a984e0dc-5082-401c-a77f-44b4146e15a2' WHERE id = 'cb35fefc-3ec0-4a04-a645-abd3ca790a41';
  UPDATE public.profiles SET spouse_id = 'e633481b-f0a6-40c8-a1f1-07a884356d21' WHERE id = 'b3e96f4c-be3b-49c3-abe5-7e21fa7762fb';
  UPDATE public.profiles SET spouse_id = 'b3e96f4c-be3b-49c3-abe5-7e21fa7762fb' WHERE id = 'e633481b-f0a6-40c8-a1f1-07a884356d21';
  UPDATE public.profiles SET spouse_id = 'ecb2345b-6190-4a59-aadc-3c1e04805a20' WHERE id = '4c4a5960-daaf-489c-827c-d7cd17df72e9';
  UPDATE public.profiles SET spouse_id = '4c4a5960-daaf-489c-827c-d7cd17df72e9' WHERE id = 'ecb2345b-6190-4a59-aadc-3c1e04805a20';
  UPDATE public.profiles SET spouse_id = '9b2410e1-37f9-4576-bc72-db72777f4f72' WHERE id = '75f53908-d6f5-42cc-b6e4-4a2d18b013e7';
  UPDATE public.profiles SET spouse_id = '75f53908-d6f5-42cc-b6e4-4a2d18b013e7' WHERE id = '9b2410e1-37f9-4576-bc72-db72777f4f72';
  UPDATE public.profiles SET spouse_id = '10e831c3-be52-4828-8e7c-788b72ab0bbb' WHERE id = '22994182-ebda-4aa6-b715-9c3296957181';
  UPDATE public.profiles SET spouse_id = '22994182-ebda-4aa6-b715-9c3296957181' WHERE id = '10e831c3-be52-4828-8e7c-788b72ab0bbb';
  UPDATE public.profiles SET spouse_id = '45f23409-8e1b-440a-91de-a42e11c4f9ce' WHERE id = 'bcd9ffb6-aa46-4c19-9a88-41989cfe0598';
  UPDATE public.profiles SET spouse_id = 'bcd9ffb6-aa46-4c19-9a88-41989cfe0598' WHERE id = '45f23409-8e1b-440a-91de-a42e11c4f9ce';
  UPDATE public.profiles SET spouse_id = '67b3c127-3dda-43af-a332-c2d16ce03e11' WHERE id = '6a75a407-4dad-4333-8469-1d96d00926d3';
  UPDATE public.profiles SET spouse_id = '6a75a407-4dad-4333-8469-1d96d00926d3' WHERE id = '67b3c127-3dda-43af-a332-c2d16ce03e11';
  UPDATE public.profiles SET spouse_id = 'f9efb3e4-a627-4c5b-bc28-125132334751' WHERE id = 'c87b8712-cf05-48b5-b820-dc172460fe5d';
  UPDATE public.profiles SET spouse_id = 'c87b8712-cf05-48b5-b820-dc172460fe5d' WHERE id = 'f9efb3e4-a627-4c5b-bc28-125132334751';
  UPDATE public.profiles SET spouse_id = '959c3df3-ecac-4b76-bc20-c3e105828c6f' WHERE id = '3774929f-208a-47a5-b41c-41b5c4a255fd';
  UPDATE public.profiles SET spouse_id = '3774929f-208a-47a5-b41c-41b5c4a255fd' WHERE id = '959c3df3-ecac-4b76-bc20-c3e105828c6f';
  UPDATE public.profiles SET spouse_id = 'a7d7345b-6d89-40b8-8a34-0b1d61003ee9' WHERE id = '748e38bd-6b77-47c7-9ed7-2a2e0c6a46dc';
  UPDATE public.profiles SET spouse_id = '748e38bd-6b77-47c7-9ed7-2a2e0c6a46dc' WHERE id = 'a7d7345b-6d89-40b8-8a34-0b1d61003ee9';
  UPDATE public.profiles SET spouse_id = 'ee7ffe41-3b01-4d16-9567-75262b0e7990' WHERE id = 'bf6d306e-8652-41fa-aca5-ed1674fdc41a';
  UPDATE public.profiles SET spouse_id = 'bf6d306e-8652-41fa-aca5-ed1674fdc41a' WHERE id = 'ee7ffe41-3b01-4d16-9567-75262b0e7990';
  UPDATE public.profiles SET spouse_id = '52fb29b0-20b5-444f-bf5f-ee5147f7493c' WHERE id = '5c74e216-d02f-44d2-afbd-280317b14dfe';
  UPDATE public.profiles SET spouse_id = '5c74e216-d02f-44d2-afbd-280317b14dfe' WHERE id = '52fb29b0-20b5-444f-bf5f-ee5147f7493c';
  UPDATE public.profiles SET spouse_id = 'e7535c45-7b6e-4e8b-ab0b-4780a6ccc870' WHERE id = '10b4ab73-c235-4186-8bb2-46ba811b6da7';
  UPDATE public.profiles SET spouse_id = '10b4ab73-c235-4186-8bb2-46ba811b6da7' WHERE id = 'e7535c45-7b6e-4e8b-ab0b-4780a6ccc870';
  UPDATE public.profiles SET spouse_id = '53b9206b-4c8e-4542-a793-4af98b167ba5' WHERE id = 'f9ca51cb-1d30-43a0-8192-37b27725defb';
  UPDATE public.profiles SET spouse_id = 'f9ca51cb-1d30-43a0-8192-37b27725defb' WHERE id = '53b9206b-4c8e-4542-a793-4af98b167ba5';
  UPDATE public.profiles SET spouse_id = '3124f4de-c749-4c7c-bbbb-9b933d3b76d4' WHERE id = '510e50aa-1eac-4369-9fc1-0acea761a7dd';
  UPDATE public.profiles SET spouse_id = '510e50aa-1eac-4369-9fc1-0acea761a7dd' WHERE id = '3124f4de-c749-4c7c-bbbb-9b933d3b76d4';
  UPDATE public.profiles SET spouse_id = 'f85b3167-d444-4bea-a5d0-e23e1da8e0a9' WHERE id = '14812dc2-691f-405b-ad00-535168d6e7ec';
  UPDATE public.profiles SET spouse_id = '14812dc2-691f-405b-ad00-535168d6e7ec' WHERE id = 'f85b3167-d444-4bea-a5d0-e23e1da8e0a9';
  UPDATE public.profiles SET spouse_id = '0c134eb5-6e9a-4a73-b493-e1da8b1cb629' WHERE id = '9d1a9f2b-5088-4ffe-b971-c35dd5945c4f';
  UPDATE public.profiles SET spouse_id = '9d1a9f2b-5088-4ffe-b971-c35dd5945c4f' WHERE id = '0c134eb5-6e9a-4a73-b493-e1da8b1cb629';
  UPDATE public.profiles SET spouse_id = '0371190b-b3b3-4f59-85a6-84172bb89374' WHERE id = '6e28c646-978d-4e2f-abb5-6bf42f2e712e';
  UPDATE public.profiles SET spouse_id = '6e28c646-978d-4e2f-abb5-6bf42f2e712e' WHERE id = '0371190b-b3b3-4f59-85a6-84172bb89374';
  UPDATE public.profiles SET spouse_id = 'c042552c-7c37-4300-b155-2537254f67d4' WHERE id = '9d212800-0ba6-40d8-8715-bf2e250999f9';
  UPDATE public.profiles SET spouse_id = '9d212800-0ba6-40d8-8715-bf2e250999f9' WHERE id = 'c042552c-7c37-4300-b155-2537254f67d4';
  UPDATE public.profiles SET spouse_id = 'bf38cf2c-549a-4302-bd12-acd8269da97a' WHERE id = '0bf4b5bb-11e1-49ef-88d0-35af77e4b305';
  UPDATE public.profiles SET spouse_id = '0bf4b5bb-11e1-49ef-88d0-35af77e4b305' WHERE id = 'bf38cf2c-549a-4302-bd12-acd8269da97a';
  UPDATE public.profiles SET spouse_id = 'f85ee4f7-a4de-4c09-ac6a-ca254c7da320' WHERE id = '532ef45e-1e86-4242-a724-49dfdd6b2e1a';
  UPDATE public.profiles SET spouse_id = '532ef45e-1e86-4242-a724-49dfdd6b2e1a' WHERE id = 'f85ee4f7-a4de-4c09-ac6a-ca254c7da320';
  UPDATE public.profiles SET spouse_id = '538e20b8-bdeb-458c-a1e2-1f4b79fcf06d' WHERE id = '2ee9bb29-09ec-4196-b408-737f7978ab86';
  UPDATE public.profiles SET spouse_id = '2ee9bb29-09ec-4196-b408-737f7978ab86' WHERE id = '538e20b8-bdeb-458c-a1e2-1f4b79fcf06d';
  UPDATE public.profiles SET spouse_id = '08a80ea0-da91-4e92-bf1b-dc4ef2348e9d' WHERE id = '8b813c87-6a0a-4434-9ff3-a2ef5f60bd0c';
  UPDATE public.profiles SET spouse_id = '8b813c87-6a0a-4434-9ff3-a2ef5f60bd0c' WHERE id = '08a80ea0-da91-4e92-bf1b-dc4ef2348e9d';
  UPDATE public.profiles SET spouse_id = '30ea4413-d4f4-4086-8969-dca1df9637d4' WHERE id = '2ce6c9f2-9ce9-4ab0-8495-ae6e43ed1e8f';
  UPDATE public.profiles SET spouse_id = '2ce6c9f2-9ce9-4ab0-8495-ae6e43ed1e8f' WHERE id = '30ea4413-d4f4-4086-8969-dca1df9637d4';
  UPDATE public.profiles SET spouse_id = 'bc4d8561-453f-403f-9dc1-c146708c4a8e' WHERE id = '1b14354d-62df-4363-a9c4-0cca112a026b';
  UPDATE public.profiles SET spouse_id = '1b14354d-62df-4363-a9c4-0cca112a026b' WHERE id = 'bc4d8561-453f-403f-9dc1-c146708c4a8e';
  UPDATE public.profiles SET spouse_id = '3c8388af-9675-4a38-86eb-c422bab96cbe' WHERE id = '4ba9b8f3-7122-486d-a43d-b34922b7a04a';
  UPDATE public.profiles SET spouse_id = '4ba9b8f3-7122-486d-a43d-b34922b7a04a' WHERE id = '3c8388af-9675-4a38-86eb-c422bab96cbe';
  UPDATE public.profiles SET spouse_id = '6368f6bc-9be9-4f1b-9d49-77a2fa9b0edc' WHERE id = '44695239-d982-4146-8cd2-f4cdedfe326b';
  UPDATE public.profiles SET spouse_id = '44695239-d982-4146-8cd2-f4cdedfe326b' WHERE id = '6368f6bc-9be9-4f1b-9d49-77a2fa9b0edc';
  UPDATE public.profiles SET spouse_id = '5daef673-ca71-477d-a3f8-5f9a1fa22947' WHERE id = '1163426c-e620-48a9-86fb-5500f8d19506';
  UPDATE public.profiles SET spouse_id = '1163426c-e620-48a9-86fb-5500f8d19506' WHERE id = '5daef673-ca71-477d-a3f8-5f9a1fa22947';
  UPDATE public.profiles SET spouse_id = '76de4596-1505-4ec0-99cf-f7360d6d79a8' WHERE id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3';
  UPDATE public.profiles SET spouse_id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3' WHERE id = '76de4596-1505-4ec0-99cf-f7360d6d79a8';
  UPDATE public.profiles SET spouse_id = '76f9712f-c596-4ae1-b2fc-48933a7ee2db' WHERE id = 'caadae9c-21e3-4152-9989-1e5a6017743c';
  UPDATE public.profiles SET spouse_id = 'caadae9c-21e3-4152-9989-1e5a6017743c' WHERE id = '76f9712f-c596-4ae1-b2fc-48933a7ee2db';
  UPDATE public.profiles SET spouse_id = '74cbfa30-1257-42d5-91bc-9e595de6d067' WHERE id = 'ef14a065-d5fb-4e13-9779-bc9b5c267a52';
  UPDATE public.profiles SET spouse_id = 'ef14a065-d5fb-4e13-9779-bc9b5c267a52' WHERE id = '74cbfa30-1257-42d5-91bc-9e595de6d067';
  UPDATE public.profiles SET spouse_id = 'c8998cef-df63-4419-adb3-206f5d89d54d' WHERE id = '07366db0-2e6c-49f4-86f9-b349088bb253';
  UPDATE public.profiles SET spouse_id = '07366db0-2e6c-49f4-86f9-b349088bb253' WHERE id = 'c8998cef-df63-4419-adb3-206f5d89d54d';
  UPDATE public.profiles SET spouse_id = '3833e775-9e8c-48db-a798-d50650bef65d' WHERE id = 'b12c63df-b43b-4b7a-88a3-2807e1386001';
  UPDATE public.profiles SET spouse_id = 'b12c63df-b43b-4b7a-88a3-2807e1386001' WHERE id = '3833e775-9e8c-48db-a798-d50650bef65d';
  UPDATE public.profiles SET spouse_id = '93f65414-b584-49e3-a8b5-3503ce23ec79' WHERE id = '7c2b1a5d-bcba-4922-af98-183f9472b70c';
  UPDATE public.profiles SET spouse_id = '7c2b1a5d-bcba-4922-af98-183f9472b70c' WHERE id = '93f65414-b584-49e3-a8b5-3503ce23ec79';
  UPDATE public.profiles SET spouse_id = 'a0ce886c-0937-412d-aeb6-c8be08a15b50' WHERE id = 'f72b6443-c2de-42d2-b3c9-b0212f0a67dd';
  UPDATE public.profiles SET spouse_id = 'f72b6443-c2de-42d2-b3c9-b0212f0a67dd' WHERE id = 'a0ce886c-0937-412d-aeb6-c8be08a15b50';
  UPDATE public.profiles SET spouse_id = 'fbd774c1-a520-4eca-bcb1-906a3be33b90' WHERE id = 'b748780e-0227-4eea-93f3-9e5ffd582187';
  UPDATE public.profiles SET spouse_id = 'b748780e-0227-4eea-93f3-9e5ffd582187' WHERE id = 'fbd774c1-a520-4eca-bcb1-906a3be33b90';
  UPDATE public.profiles SET spouse_id = '91e1fb4f-feb0-43f0-a71e-30b942d66319' WHERE id = '139288c5-11cc-4712-9239-4e5775f33243';
  UPDATE public.profiles SET spouse_id = '139288c5-11cc-4712-9239-4e5775f33243' WHERE id = '91e1fb4f-feb0-43f0-a71e-30b942d66319';
  UPDATE public.profiles SET spouse_id = '93e6ef9b-2a12-4779-9372-0a91e6cd3809' WHERE id = 'ad24591c-02e7-4a8e-9d21-bb38c8449793';
  UPDATE public.profiles SET spouse_id = 'ad24591c-02e7-4a8e-9d21-bb38c8449793' WHERE id = '93e6ef9b-2a12-4779-9372-0a91e6cd3809';
  UPDATE public.profiles SET spouse_id = '1e0d092f-ad3a-4be3-8c43-1b8be389d6ce' WHERE id = 'a8ad3f52-edf2-40f1-ae61-5aab86a7abd5';
  UPDATE public.profiles SET spouse_id = 'a8ad3f52-edf2-40f1-ae61-5aab86a7abd5' WHERE id = '1e0d092f-ad3a-4be3-8c43-1b8be389d6ce';
  UPDATE public.profiles SET spouse_id = 'b29b07bb-fc08-4a83-80d1-ce1b9666b976' WHERE id = 'c270668d-456a-4669-b183-c3cb65434c79';
  UPDATE public.profiles SET spouse_id = 'c270668d-456a-4669-b183-c3cb65434c79' WHERE id = 'b29b07bb-fc08-4a83-80d1-ce1b9666b976';
  UPDATE public.profiles SET spouse_id = 'dd92baa3-d81f-4ecb-ac90-26bf6dd93cb9' WHERE id = 'e0e5ac4b-b5ac-4d20-a0fa-74bbe8dcce67';
  UPDATE public.profiles SET spouse_id = 'e0e5ac4b-b5ac-4d20-a0fa-74bbe8dcce67' WHERE id = 'dd92baa3-d81f-4ecb-ac90-26bf6dd93cb9';
  UPDATE public.profiles SET spouse_id = '3aeb8cf2-c7db-4e05-99d9-08b9f8ec85c9' WHERE id = 'e454e77c-01af-4a81-acd8-1c5ee3bc2fb1';
  UPDATE public.profiles SET spouse_id = 'e454e77c-01af-4a81-acd8-1c5ee3bc2fb1' WHERE id = '3aeb8cf2-c7db-4e05-99d9-08b9f8ec85c9';
  UPDATE public.profiles SET spouse_id = '37aed401-1fca-43b4-8396-6a3209429260' WHERE id = '71134040-e519-4cb6-a859-4f5266f229f5';
  UPDATE public.profiles SET spouse_id = '71134040-e519-4cb6-a859-4f5266f229f5' WHERE id = '37aed401-1fca-43b4-8396-6a3209429260';
  UPDATE public.profiles SET spouse_id = '6714c279-8029-4e46-a287-efee9888fdee' WHERE id = 'e24a1b13-3acf-4c22-9726-7a263ebb9902';
  UPDATE public.profiles SET spouse_id = 'e24a1b13-3acf-4c22-9726-7a263ebb9902' WHERE id = '6714c279-8029-4e46-a287-efee9888fdee';
  UPDATE public.profiles SET spouse_id = '8b11fd5b-f5f8-4492-bac2-7e38baab49fd' WHERE id = '27cda7e9-8f51-4a8b-8eef-303c3d126c0d';
  UPDATE public.profiles SET spouse_id = '27cda7e9-8f51-4a8b-8eef-303c3d126c0d' WHERE id = '8b11fd5b-f5f8-4492-bac2-7e38baab49fd';
  UPDATE public.profiles SET spouse_id = '476e6248-4b9a-462f-9f59-e65288d34c1d' WHERE id = 'a8345812-7114-4e6f-be56-ffabc3601680';
  UPDATE public.profiles SET spouse_id = 'a8345812-7114-4e6f-be56-ffabc3601680' WHERE id = '476e6248-4b9a-462f-9f59-e65288d34c1d';
  UPDATE public.profiles SET spouse_id = 'b1be76b7-b9d3-436e-bf42-82ac78196baf' WHERE id = '33ba0ab1-dc22-4a72-8765-81abb06454d3';
  UPDATE public.profiles SET spouse_id = '33ba0ab1-dc22-4a72-8765-81abb06454d3' WHERE id = 'b1be76b7-b9d3-436e-bf42-82ac78196baf';
  UPDATE public.profiles SET spouse_id = '9aa58a8b-b179-49b4-a3b4-3d6aa0f4b079' WHERE id = '005b1789-b9a4-4922-8c70-0629ce4c7fff';
  UPDATE public.profiles SET spouse_id = '005b1789-b9a4-4922-8c70-0629ce4c7fff' WHERE id = '9aa58a8b-b179-49b4-a3b4-3d6aa0f4b079';
  UPDATE public.profiles SET spouse_id = 'bf4ed3e3-57e7-46a4-8597-24d812a263c4' WHERE id = '4aab6a0a-73a0-4c77-81ec-24b15494637a';
  UPDATE public.profiles SET spouse_id = '4aab6a0a-73a0-4c77-81ec-24b15494637a' WHERE id = 'bf4ed3e3-57e7-46a4-8597-24d812a263c4';
  UPDATE public.profiles SET spouse_id = 'd513b617-28cb-4050-83b2-ff801f763f63' WHERE id = 'f48ae622-64c2-4b0d-af76-ad4a8208d098';
  UPDATE public.profiles SET spouse_id = 'f48ae622-64c2-4b0d-af76-ad4a8208d098' WHERE id = 'd513b617-28cb-4050-83b2-ff801f763f63';
  UPDATE public.profiles SET spouse_id = 'fe50fdcc-c384-4029-8b57-d45b48b99c80' WHERE id = 'af590c9f-12d7-457d-8b43-39fbbaf2e5db';
  UPDATE public.profiles SET spouse_id = 'af590c9f-12d7-457d-8b43-39fbbaf2e5db' WHERE id = 'fe50fdcc-c384-4029-8b57-d45b48b99c80';
  UPDATE public.profiles SET spouse_id = 'a33cd689-65d9-4b4c-b3e9-5e2e31b7107b' WHERE id = 'c4e92cc2-ca10-4c97-aeea-df69d15b4651';
  UPDATE public.profiles SET spouse_id = 'c4e92cc2-ca10-4c97-aeea-df69d15b4651' WHERE id = 'a33cd689-65d9-4b4c-b3e9-5e2e31b7107b';
  UPDATE public.profiles SET spouse_id = '095c9ea3-8ab0-4dee-90d9-b6035d060b2c' WHERE id = 'ae96fac5-7df5-4161-abcc-87065e91c504';
  UPDATE public.profiles SET spouse_id = 'ae96fac5-7df5-4161-abcc-87065e91c504' WHERE id = '095c9ea3-8ab0-4dee-90d9-b6035d060b2c';
  UPDATE public.profiles SET spouse_id = 'd379fedb-0c55-4916-8888-e2ad5f8532ea' WHERE id = '8a4e3479-1da9-4e4b-9773-393fd3626764';
  UPDATE public.profiles SET spouse_id = '8a4e3479-1da9-4e4b-9773-393fd3626764' WHERE id = 'd379fedb-0c55-4916-8888-e2ad5f8532ea';
  UPDATE public.profiles SET spouse_id = '8f2a3de7-729c-463d-8196-9801767d7bb9' WHERE id = '31e3288c-aff8-4f77-b1b7-c3e429f6e446';
  UPDATE public.profiles SET spouse_id = '31e3288c-aff8-4f77-b1b7-c3e429f6e446' WHERE id = '8f2a3de7-729c-463d-8196-9801767d7bb9';
  UPDATE public.profiles SET spouse_id = '0b168797-56ef-4826-9b98-8ae3aa27f5ee' WHERE id = '06cd38c9-6c2f-462c-8c4e-f77722d85429';
  UPDATE public.profiles SET spouse_id = '06cd38c9-6c2f-462c-8c4e-f77722d85429' WHERE id = '0b168797-56ef-4826-9b98-8ae3aa27f5ee';
  UPDATE public.profiles SET spouse_id = '2bbebb46-5b7d-464e-93f4-6f784fa55b7b' WHERE id = '59a3a433-74ca-4a11-a2eb-8dc9e4e157a3';
  UPDATE public.profiles SET spouse_id = '59a3a433-74ca-4a11-a2eb-8dc9e4e157a3' WHERE id = '2bbebb46-5b7d-464e-93f4-6f784fa55b7b';
  UPDATE public.profiles SET spouse_id = '20924b51-51d0-4464-8a3b-60fb353d5d0a' WHERE id = '5bf8019f-94f6-4d14-958c-543bdf48198c';
  UPDATE public.profiles SET spouse_id = '5bf8019f-94f6-4d14-958c-543bdf48198c' WHERE id = '20924b51-51d0-4464-8a3b-60fb353d5d0a';
  UPDATE public.profiles SET spouse_id = '577ea67c-06f1-45ba-9e36-9d114b2e565a' WHERE id = 'ab5c3b50-070e-42c4-ba65-a73f2b3768db';
  UPDATE public.profiles SET spouse_id = 'ab5c3b50-070e-42c4-ba65-a73f2b3768db' WHERE id = '577ea67c-06f1-45ba-9e36-9d114b2e565a';
  UPDATE public.profiles SET spouse_id = 'c945aaf0-f082-4152-a6ab-c753986e89c7' WHERE id = '7d5a8f77-6d3e-4e9d-b5da-ca58a7af12a1';
  UPDATE public.profiles SET spouse_id = '7d5a8f77-6d3e-4e9d-b5da-ca58a7af12a1' WHERE id = 'c945aaf0-f082-4152-a6ab-c753986e89c7';
  UPDATE public.profiles SET spouse_id = 'bd10408c-bcb6-4e4c-a418-72a3e68ecd58' WHERE id = '3099f6f9-a7a3-4b5c-8b32-c37429ec1504';
  UPDATE public.profiles SET spouse_id = '3099f6f9-a7a3-4b5c-8b32-c37429ec1504' WHERE id = 'bd10408c-bcb6-4e4c-a418-72a3e68ecd58';
  UPDATE public.profiles SET spouse_id = 'ad0f2b65-1246-4288-9e78-653d2c377626' WHERE id = '2c2a4c9f-4ae6-4ece-9287-cf1301b28615';
  UPDATE public.profiles SET spouse_id = '2c2a4c9f-4ae6-4ece-9287-cf1301b28615' WHERE id = 'ad0f2b65-1246-4288-9e78-653d2c377626';
  UPDATE public.profiles SET spouse_id = 'af85f349-a7af-4d46-9daf-ae1f2eabc375' WHERE id = '66c1eee5-2c5d-4405-b680-ab83f0429724';
  UPDATE public.profiles SET spouse_id = '66c1eee5-2c5d-4405-b680-ab83f0429724' WHERE id = 'af85f349-a7af-4d46-9daf-ae1f2eabc375';
  UPDATE public.profiles SET spouse_id = 'f9358d2f-e6cc-4c57-bf33-3da48bb30b39' WHERE id = '1bc80eba-2bd9-45ac-9729-923f9d750e36';
  UPDATE public.profiles SET spouse_id = '1bc80eba-2bd9-45ac-9729-923f9d750e36' WHERE id = 'f9358d2f-e6cc-4c57-bf33-3da48bb30b39';
  UPDATE public.profiles SET spouse_id = '9b1c7842-0ef3-4441-b672-ddc8c3349528' WHERE id = 'd4dfc0ac-2e23-4805-9b63-02ba2d4bc4d7';
  UPDATE public.profiles SET spouse_id = 'd4dfc0ac-2e23-4805-9b63-02ba2d4bc4d7' WHERE id = '9b1c7842-0ef3-4441-b672-ddc8c3349528';
  UPDATE public.profiles SET spouse_id = '7873ec8d-e43a-4513-9a9c-013b09107834' WHERE id = '12d805ce-183c-4f2e-92bb-1830ef7778d8';
  UPDATE public.profiles SET spouse_id = '12d805ce-183c-4f2e-92bb-1830ef7778d8' WHERE id = '7873ec8d-e43a-4513-9a9c-013b09107834';
  UPDATE public.profiles SET spouse_id = '8bc2b23b-2991-4d8d-8029-76eb0d6222fd' WHERE id = 'c41d69f8-43f9-43be-9d34-0c4a79e357fd';
  UPDATE public.profiles SET spouse_id = 'c41d69f8-43f9-43be-9d34-0c4a79e357fd' WHERE id = '8bc2b23b-2991-4d8d-8029-76eb0d6222fd';
  UPDATE public.profiles SET spouse_id = '3edf5bc9-db9b-4039-bcc5-430eaea8fd9c' WHERE id = '737e26d8-52c0-4a18-98d6-b4821650b691';
  UPDATE public.profiles SET spouse_id = '737e26d8-52c0-4a18-98d6-b4821650b691' WHERE id = '3edf5bc9-db9b-4039-bcc5-430eaea8fd9c';
  UPDATE public.profiles SET spouse_id = 'a7585340-04b8-463e-98e0-950ea4d52906' WHERE id = '8e4e872f-e93b-498d-a6b9-551d06fa082a';
  UPDATE public.profiles SET spouse_id = '8e4e872f-e93b-498d-a6b9-551d06fa082a' WHERE id = 'a7585340-04b8-463e-98e0-950ea4d52906';
  UPDATE public.profiles SET spouse_id = '675e4992-d9b1-4da1-b147-f02eceed7e30' WHERE id = '4068d892-8d90-4a1a-b8d9-9b1809c0af61';
  UPDATE public.profiles SET spouse_id = '4068d892-8d90-4a1a-b8d9-9b1809c0af61' WHERE id = '675e4992-d9b1-4da1-b147-f02eceed7e30';
  UPDATE public.profiles SET spouse_id = 'c9f1a974-b158-4e3f-9760-5b687cab0919' WHERE id = 'd0952ba5-945a-4479-94f1-9926b1a2fac9';
  UPDATE public.profiles SET spouse_id = 'd0952ba5-945a-4479-94f1-9926b1a2fac9' WHERE id = 'c9f1a974-b158-4e3f-9760-5b687cab0919';
  UPDATE public.profiles SET spouse_id = 'e0625d12-06b9-4fe4-b461-524a33fbef24' WHERE id = '8ff1f030-ad11-4cd3-9d2f-a8c178a48104';
  UPDATE public.profiles SET spouse_id = '8ff1f030-ad11-4cd3-9d2f-a8c178a48104' WHERE id = 'e0625d12-06b9-4fe4-b461-524a33fbef24';
  UPDATE public.profiles SET spouse_id = 'a444b048-3e7a-4186-b33c-c0ee40fc96c3' WHERE id = '56f6889f-ba1d-4ff5-b31d-933bd4b10105';
  UPDATE public.profiles SET spouse_id = '56f6889f-ba1d-4ff5-b31d-933bd4b10105' WHERE id = 'a444b048-3e7a-4186-b33c-c0ee40fc96c3';
  UPDATE public.profiles SET spouse_id = 'e6d99983-4f42-4516-80f3-4acb7e274016' WHERE id = '742a5e06-ce24-4721-9aec-a7a26e96cdcc';
  UPDATE public.profiles SET spouse_id = '742a5e06-ce24-4721-9aec-a7a26e96cdcc' WHERE id = 'e6d99983-4f42-4516-80f3-4acb7e274016';
  UPDATE public.profiles SET spouse_id = '83570457-a654-428c-bb45-2b0d991cc017' WHERE id = 'd5009d58-dd2a-41dd-889e-ffcd27ae4034';
  UPDATE public.profiles SET spouse_id = 'd5009d58-dd2a-41dd-889e-ffcd27ae4034' WHERE id = '83570457-a654-428c-bb45-2b0d991cc017';
  UPDATE public.profiles SET spouse_id = 'ff9e9dec-8dc7-42b3-a3b2-f95a0660288d' WHERE id = '12afa679-3de9-40c3-8d57-99416899151c';
  UPDATE public.profiles SET spouse_id = '12afa679-3de9-40c3-8d57-99416899151c' WHERE id = 'ff9e9dec-8dc7-42b3-a3b2-f95a0660288d';
  UPDATE public.profiles SET spouse_id = '7e3e92b1-efa0-46c8-9f23-79bd76a59ff8' WHERE id = '22857b4e-a9ab-4e91-bf23-008de0da1fcb';
  UPDATE public.profiles SET spouse_id = '22857b4e-a9ab-4e91-bf23-008de0da1fcb' WHERE id = '7e3e92b1-efa0-46c8-9f23-79bd76a59ff8';
  UPDATE public.profiles SET spouse_id = 'a0bbf386-f10b-4010-9fbf-ccabc5ac0623' WHERE id = '8a7d81b0-4e85-43d0-b62e-4cc2eb6f68ce';
  UPDATE public.profiles SET spouse_id = '8a7d81b0-4e85-43d0-b62e-4cc2eb6f68ce' WHERE id = 'a0bbf386-f10b-4010-9fbf-ccabc5ac0623';
  UPDATE public.profiles SET spouse_id = '806ee593-66c1-49fa-a1f1-52e74cdcc6a8' WHERE id = 'a99713c1-3ed8-45d0-921e-65cc2b6c4eb4';
  UPDATE public.profiles SET spouse_id = 'a99713c1-3ed8-45d0-921e-65cc2b6c4eb4' WHERE id = '806ee593-66c1-49fa-a1f1-52e74cdcc6a8';
  UPDATE public.profiles SET spouse_id = '9de8161a-5d57-4c0c-a11e-aebe2bc2c2ea' WHERE id = '3e46f68d-5d33-4373-9832-b979cab7e285';
  UPDATE public.profiles SET spouse_id = '3e46f68d-5d33-4373-9832-b979cab7e285' WHERE id = '9de8161a-5d57-4c0c-a11e-aebe2bc2c2ea';
  UPDATE public.profiles SET spouse_id = '766ebb63-6afb-4bdd-a61a-596863b91c8b' WHERE id = '1d6f2814-903c-4f37-9212-728078805f44';
  UPDATE public.profiles SET spouse_id = '1d6f2814-903c-4f37-9212-728078805f44' WHERE id = '766ebb63-6afb-4bdd-a61a-596863b91c8b';
  UPDATE public.profiles SET spouse_id = '83823064-630a-40f0-bb8b-21149eb99747' WHERE id = '768e2171-752d-4fb3-be67-dc7e40ab9ae0';
  UPDATE public.profiles SET spouse_id = '768e2171-752d-4fb3-be67-dc7e40ab9ae0' WHERE id = '83823064-630a-40f0-bb8b-21149eb99747';
  UPDATE public.profiles SET spouse_id = 'edb28b68-420a-44ee-aecc-b48a5f6f7c79' WHERE id = 'e26d46fc-586a-464c-8a60-63b8a237780c';
  UPDATE public.profiles SET spouse_id = 'e26d46fc-586a-464c-8a60-63b8a237780c' WHERE id = 'edb28b68-420a-44ee-aecc-b48a5f6f7c79';
  UPDATE public.profiles SET spouse_id = 'c58269ca-fca9-4254-b0ea-c8791fe2c99e' WHERE id = 'a2cbca82-b7f2-4634-af7c-851ae58b9265';
  UPDATE public.profiles SET spouse_id = 'a2cbca82-b7f2-4634-af7c-851ae58b9265' WHERE id = 'c58269ca-fca9-4254-b0ea-c8791fe2c99e';
  UPDATE public.profiles SET spouse_id = '04188ea7-29c7-4dfc-a7f2-a745a110b1cb' WHERE id = '12e061aa-fb55-4165-86c8-c06c7d5381c1';
  UPDATE public.profiles SET spouse_id = '12e061aa-fb55-4165-86c8-c06c7d5381c1' WHERE id = '04188ea7-29c7-4dfc-a7f2-a745a110b1cb';
  UPDATE public.profiles SET spouse_id = '0d9e6cb8-2762-43e7-9484-e95f0c805c00' WHERE id = '561b3acf-c189-42df-a043-a71b23a66db6';
  UPDATE public.profiles SET spouse_id = '561b3acf-c189-42df-a043-a71b23a66db6' WHERE id = '0d9e6cb8-2762-43e7-9484-e95f0c805c00';
  UPDATE public.profiles SET spouse_id = '7af0aea9-b5db-45c6-895e-9be45d23d912' WHERE id = '8f88e49a-ec0f-4dc3-b3f7-7df78812a179';
  UPDATE public.profiles SET spouse_id = '8f88e49a-ec0f-4dc3-b3f7-7df78812a179' WHERE id = '7af0aea9-b5db-45c6-895e-9be45d23d912';
  UPDATE public.profiles SET spouse_id = '5a68b362-ec39-4f09-bad6-f3979df4f26f' WHERE id = 'ccd0ea9f-27ee-4b51-baf9-91dde838fc74';
  UPDATE public.profiles SET spouse_id = 'ccd0ea9f-27ee-4b51-baf9-91dde838fc74' WHERE id = '5a68b362-ec39-4f09-bad6-f3979df4f26f';
  UPDATE public.profiles SET spouse_id = '7f54c921-8de5-457e-8b6e-955c8f4c7b06' WHERE id = 'e3b5dbc1-ba42-47a8-b5fd-ca26aceece4a';
  UPDATE public.profiles SET spouse_id = 'e3b5dbc1-ba42-47a8-b5fd-ca26aceece4a' WHERE id = '7f54c921-8de5-457e-8b6e-955c8f4c7b06';
  UPDATE public.profiles SET spouse_id = '785563b6-74d5-4c88-bea8-956732262d2f' WHERE id = '440de73e-1357-420f-a788-5abc2e1a8962';
  UPDATE public.profiles SET spouse_id = '440de73e-1357-420f-a788-5abc2e1a8962' WHERE id = '785563b6-74d5-4c88-bea8-956732262d2f';
  UPDATE public.profiles SET spouse_id = '073d41aa-5378-4485-951b-416f1d95ca00' WHERE id = 'c6c48ae8-5e93-48f0-9c6c-78cff50af3fc';
  UPDATE public.profiles SET spouse_id = 'c6c48ae8-5e93-48f0-9c6c-78cff50af3fc' WHERE id = '073d41aa-5378-4485-951b-416f1d95ca00';
  UPDATE public.profiles SET spouse_id = 'ae81097f-1774-4183-9372-99830fa09204' WHERE id = '3b8b379e-487b-42b4-9c3e-4db8f476bcf6';
  UPDATE public.profiles SET spouse_id = '3b8b379e-487b-42b4-9c3e-4db8f476bcf6' WHERE id = 'ae81097f-1774-4183-9372-99830fa09204';
  UPDATE public.profiles SET spouse_id = 'ab815076-e42a-4a1c-83e9-f8eddee086b2' WHERE id = 'b45df520-0f02-452d-bf5b-1748c8b34029';
  UPDATE public.profiles SET spouse_id = 'b45df520-0f02-452d-bf5b-1748c8b34029' WHERE id = 'ab815076-e42a-4a1c-83e9-f8eddee086b2';
  UPDATE public.profiles SET spouse_id = '430f3eaf-1cc6-4153-b8ee-ae9a663c9850' WHERE id = '662f5324-14e5-45c5-9fa4-64347433563e';
  UPDATE public.profiles SET spouse_id = '662f5324-14e5-45c5-9fa4-64347433563e' WHERE id = '430f3eaf-1cc6-4153-b8ee-ae9a663c9850';
  UPDATE public.profiles SET spouse_id = 'f572d8ab-1f32-4b4b-85f4-27bdaa9776f7' WHERE id = 'a5c52b21-66a6-4555-9ef2-70223ef1d1e9';
  UPDATE public.profiles SET spouse_id = 'a5c52b21-66a6-4555-9ef2-70223ef1d1e9' WHERE id = 'f572d8ab-1f32-4b4b-85f4-27bdaa9776f7';
  UPDATE public.profiles SET spouse_id = '3b4832e5-05c3-47b3-850f-43f06473160e' WHERE id = '1338e785-b944-4a37-a88e-0ed03c28dec7';
  UPDATE public.profiles SET spouse_id = '1338e785-b944-4a37-a88e-0ed03c28dec7' WHERE id = '3b4832e5-05c3-47b3-850f-43f06473160e';
  UPDATE public.profiles SET spouse_id = 'f0f4de22-c116-4874-94ca-6db167b69d9f' WHERE id = '410ddbc6-ffe3-4e9b-b708-f956d5375fc6';
  UPDATE public.profiles SET spouse_id = '410ddbc6-ffe3-4e9b-b708-f956d5375fc6' WHERE id = 'f0f4de22-c116-4874-94ca-6db167b69d9f';
  UPDATE public.profiles SET spouse_id = 'c9e1f999-1e73-4084-bc36-03864ca1e0ce' WHERE id = '0a1e1143-c924-44df-941a-c9a474409e39';
  UPDATE public.profiles SET spouse_id = '0a1e1143-c924-44df-941a-c9a474409e39' WHERE id = 'c9e1f999-1e73-4084-bc36-03864ca1e0ce';
  UPDATE public.profiles SET spouse_id = 'cd534814-f2bd-4073-9b98-32d5178bdecf' WHERE id = 'b3549442-1c49-4e45-b52e-ad3267f7dce7';
  UPDATE public.profiles SET spouse_id = 'b3549442-1c49-4e45-b52e-ad3267f7dce7' WHERE id = 'cd534814-f2bd-4073-9b98-32d5178bdecf';
  UPDATE public.profiles SET spouse_id = 'e972d21a-bc51-46e7-99f3-7cc44f1f1c4e' WHERE id = '3a26e266-ea78-4a86-8175-c8962302d4af';
  UPDATE public.profiles SET spouse_id = '3a26e266-ea78-4a86-8175-c8962302d4af' WHERE id = 'e972d21a-bc51-46e7-99f3-7cc44f1f1c4e';
  UPDATE public.profiles SET spouse_id = 'fdcf0ae3-7f3a-47b3-8d1a-fc06da14c839' WHERE id = '1b61df57-60e3-43d1-b202-94778723bc75';
  UPDATE public.profiles SET spouse_id = '1b61df57-60e3-43d1-b202-94778723bc75' WHERE id = 'fdcf0ae3-7f3a-47b3-8d1a-fc06da14c839';
  UPDATE public.profiles SET spouse_id = '919218ab-64be-4915-a4f3-7d9e4eaeff39' WHERE id = '10ab12fa-8fc7-4294-a322-335969c49acb';
  UPDATE public.profiles SET spouse_id = '10ab12fa-8fc7-4294-a322-335969c49acb' WHERE id = '919218ab-64be-4915-a4f3-7d9e4eaeff39';
  UPDATE public.profiles SET spouse_id = '4202b35a-8f03-4c20-bd0a-90700dd51a94' WHERE id = 'd16b2349-9b5c-48e7-8dd1-9067484ec681';
  UPDATE public.profiles SET spouse_id = 'd16b2349-9b5c-48e7-8dd1-9067484ec681' WHERE id = '4202b35a-8f03-4c20-bd0a-90700dd51a94';
  UPDATE public.profiles SET spouse_id = 'f4d10dc6-ebc9-4b00-807b-f4cc2892c2f7' WHERE id = '9a490b28-fc1e-48ff-a3bd-4992e140d86e';
  UPDATE public.profiles SET spouse_id = '9a490b28-fc1e-48ff-a3bd-4992e140d86e' WHERE id = 'f4d10dc6-ebc9-4b00-807b-f4cc2892c2f7';
  UPDATE public.profiles SET spouse_id = '4e01c8ec-ff7e-4a71-8534-09ea34b79cf5' WHERE id = '66a1c186-e3f7-4abe-9e2f-1eaa595e9957';
  UPDATE public.profiles SET spouse_id = '66a1c186-e3f7-4abe-9e2f-1eaa595e9957' WHERE id = '4e01c8ec-ff7e-4a71-8534-09ea34b79cf5';
  UPDATE public.profiles SET spouse_id = 'c6dfddb2-7f21-46d5-8c61-5c17837bcee9' WHERE id = '83009bc4-07d9-4e12-8023-d142333013fc';
  UPDATE public.profiles SET spouse_id = '83009bc4-07d9-4e12-8023-d142333013fc' WHERE id = 'c6dfddb2-7f21-46d5-8c61-5c17837bcee9';
  UPDATE public.profiles SET spouse_id = '7f0ba630-de60-48a2-9790-eb49c3cbb491' WHERE id = '79c3061a-ab1c-4323-95c0-0ddd57363136';
  UPDATE public.profiles SET spouse_id = '79c3061a-ab1c-4323-95c0-0ddd57363136' WHERE id = '7f0ba630-de60-48a2-9790-eb49c3cbb491';
  UPDATE public.profiles SET spouse_id = '3d388ff0-fdc3-41c0-82be-1e049ecf3243' WHERE id = '015ab95a-a385-4946-a881-ca4b90535a56';
  UPDATE public.profiles SET spouse_id = '015ab95a-a385-4946-a881-ca4b90535a56' WHERE id = '3d388ff0-fdc3-41c0-82be-1e049ecf3243';
  UPDATE public.profiles SET spouse_id = '2d5db83a-d8ff-4022-9d7d-417727f96f5a' WHERE id = '0f71fdaf-2abd-49a3-97b4-17ec0ef1f0cc';
  UPDATE public.profiles SET spouse_id = '0f71fdaf-2abd-49a3-97b4-17ec0ef1f0cc' WHERE id = '2d5db83a-d8ff-4022-9d7d-417727f96f5a';
  UPDATE public.profiles SET spouse_id = '4c05247c-b11f-4983-9092-ad0a68510888' WHERE id = '76d842bf-b99d-42ee-8ac0-20c3953c1494';
  UPDATE public.profiles SET spouse_id = '76d842bf-b99d-42ee-8ac0-20c3953c1494' WHERE id = '4c05247c-b11f-4983-9092-ad0a68510888';
  UPDATE public.profiles SET spouse_id = '6249eeec-4306-434c-8063-fd04a9169f02' WHERE id = 'b526bab6-c753-4970-93f7-e3481115816e';
  UPDATE public.profiles SET spouse_id = 'b526bab6-c753-4970-93f7-e3481115816e' WHERE id = '6249eeec-4306-434c-8063-fd04a9169f02';
  UPDATE public.profiles SET spouse_id = '8f790441-e0b2-4a4c-a720-1c81eee1f95f' WHERE id = '001a6eea-64de-4793-a39d-d10ece61b525';
  UPDATE public.profiles SET spouse_id = '001a6eea-64de-4793-a39d-d10ece61b525' WHERE id = '8f790441-e0b2-4a4c-a720-1c81eee1f95f';
  UPDATE public.profiles SET spouse_id = 'd82bcff9-d5ab-49c0-86e8-f4ced747056b' WHERE id = '8f17a7cd-8753-4251-a652-480990b1dc1a';
  UPDATE public.profiles SET spouse_id = '8f17a7cd-8753-4251-a652-480990b1dc1a' WHERE id = 'd82bcff9-d5ab-49c0-86e8-f4ced747056b';
  UPDATE public.profiles SET spouse_id = '54d57870-a9bb-45f6-ac5c-aea9d2066260' WHERE id = 'a6599d0b-cce5-4c5d-9d73-e7d89d995247';
  UPDATE public.profiles SET spouse_id = 'a6599d0b-cce5-4c5d-9d73-e7d89d995247' WHERE id = '54d57870-a9bb-45f6-ac5c-aea9d2066260';
  UPDATE public.profiles SET spouse_id = '50b820e6-22d8-4e42-a464-2f08961ff281' WHERE id = 'b3e686c7-d8b2-44ba-85e6-0d6799516e05';
  UPDATE public.profiles SET spouse_id = 'b3e686c7-d8b2-44ba-85e6-0d6799516e05' WHERE id = '50b820e6-22d8-4e42-a464-2f08961ff281';
  UPDATE public.profiles SET spouse_id = '102fb837-b437-44ee-9aae-9652c3912285' WHERE id = 'b875fe52-d449-403d-9f2b-f749a601f5a5';
  UPDATE public.profiles SET spouse_id = 'b875fe52-d449-403d-9f2b-f749a601f5a5' WHERE id = '102fb837-b437-44ee-9aae-9652c3912285';
  UPDATE public.profiles SET spouse_id = '4dc530e8-8036-4780-8b0d-138290fd165e' WHERE id = 'c02eb7cd-4446-4d7a-90e8-545a98fd0cd2';
  UPDATE public.profiles SET spouse_id = 'c02eb7cd-4446-4d7a-90e8-545a98fd0cd2' WHERE id = '4dc530e8-8036-4780-8b0d-138290fd165e';
  UPDATE public.profiles SET spouse_id = '4b6206c5-3c01-4680-8a2f-945a3368b1d4' WHERE id = 'f7d6b730-0eed-4faf-813e-be3d957a14db';
  UPDATE public.profiles SET spouse_id = 'f7d6b730-0eed-4faf-813e-be3d957a14db' WHERE id = '4b6206c5-3c01-4680-8a2f-945a3368b1d4';
  UPDATE public.profiles SET spouse_id = '27892ce8-d581-4f85-8f30-5625cefccdfd' WHERE id = '8384dd06-1479-4f29-b60c-ab869f854f39';
  UPDATE public.profiles SET spouse_id = '8384dd06-1479-4f29-b60c-ab869f854f39' WHERE id = '27892ce8-d581-4f85-8f30-5625cefccdfd';
  UPDATE public.profiles SET spouse_id = '3b884b6c-2405-47a7-983e-8cde14f0ba83' WHERE id = '78d9680b-3c8c-41ba-b799-e20732a7918c';
  UPDATE public.profiles SET spouse_id = '78d9680b-3c8c-41ba-b799-e20732a7918c' WHERE id = '3b884b6c-2405-47a7-983e-8cde14f0ba83';
  UPDATE public.profiles SET spouse_id = 'a48cf32c-4400-4f31-9a3c-887e067cfe0f' WHERE id = '050cea61-2ddc-4199-979f-2b0087987404';
  UPDATE public.profiles SET spouse_id = '050cea61-2ddc-4199-979f-2b0087987404' WHERE id = 'a48cf32c-4400-4f31-9a3c-887e067cfe0f';
  UPDATE public.profiles SET spouse_id = '95b2c2a2-c216-4f0e-9e6c-84aa0c93298d' WHERE id = '2f3cb7bb-8d85-466e-ba0e-a0196e39db8c';
  UPDATE public.profiles SET spouse_id = '2f3cb7bb-8d85-466e-ba0e-a0196e39db8c' WHERE id = '95b2c2a2-c216-4f0e-9e6c-84aa0c93298d';
  UPDATE public.profiles SET spouse_id = '2bde2a35-ff1a-4533-8269-d3b6f40aa398' WHERE id = '1f353a29-151b-47a8-b60d-5cd70b713223';
  UPDATE public.profiles SET spouse_id = '1f353a29-151b-47a8-b60d-5cd70b713223' WHERE id = '2bde2a35-ff1a-4533-8269-d3b6f40aa398';
  UPDATE public.profiles SET spouse_id = 'bd7e2fed-f2fe-455f-907a-906ef39fdfe9' WHERE id = '08ef9000-1c52-4793-bd87-0c167488b3aa';
  UPDATE public.profiles SET spouse_id = '08ef9000-1c52-4793-bd87-0c167488b3aa' WHERE id = 'bd7e2fed-f2fe-455f-907a-906ef39fdfe9';
  UPDATE public.profiles SET spouse_id = 'a960f688-772a-4901-aee9-874351caf622' WHERE id = '5113744e-dcd5-4bd9-a5ac-d4d4a29103d2';
  UPDATE public.profiles SET spouse_id = '5113744e-dcd5-4bd9-a5ac-d4d4a29103d2' WHERE id = 'a960f688-772a-4901-aee9-874351caf622';
  UPDATE public.profiles SET spouse_id = '8bd5f869-cee2-4a71-9d8b-bb0567852f18' WHERE id = '1a4e50c4-5477-4cec-8658-26312515e0ad';
  UPDATE public.profiles SET spouse_id = '1a4e50c4-5477-4cec-8658-26312515e0ad' WHERE id = '8bd5f869-cee2-4a71-9d8b-bb0567852f18';
  UPDATE public.profiles SET spouse_id = '3b8cf2da-e1b0-4f71-8209-bd7897d7d13b' WHERE id = 'ddcf226a-697a-458d-b113-ecc12e8d8200';
  UPDATE public.profiles SET spouse_id = 'ddcf226a-697a-458d-b113-ecc12e8d8200' WHERE id = '3b8cf2da-e1b0-4f71-8209-bd7897d7d13b';
  UPDATE public.profiles SET spouse_id = '9f3741ea-5dbf-41e2-8eb7-aebd063b57db' WHERE id = '4e1a9e77-49a4-4e7b-9821-7bed1e7fb2f6';
  UPDATE public.profiles SET spouse_id = '4e1a9e77-49a4-4e7b-9821-7bed1e7fb2f6' WHERE id = '9f3741ea-5dbf-41e2-8eb7-aebd063b57db';
  UPDATE public.profiles SET spouse_id = '9897c43c-b42c-41bd-8aac-c9d7421ee709' WHERE id = '14f3b34a-e342-4671-9361-cf94df252307';
  UPDATE public.profiles SET spouse_id = '14f3b34a-e342-4671-9361-cf94df252307' WHERE id = '9897c43c-b42c-41bd-8aac-c9d7421ee709';
  UPDATE public.profiles SET spouse_id = '4fdb878a-77fa-4c84-8592-8bf62e14926c' WHERE id = '78ea7139-0198-4e15-ae8c-66fbbb02223f';
  UPDATE public.profiles SET spouse_id = '78ea7139-0198-4e15-ae8c-66fbbb02223f' WHERE id = '4fdb878a-77fa-4c84-8592-8bf62e14926c';
  UPDATE public.profiles SET spouse_id = '092dc14f-d240-44ba-9003-d73153529ea8' WHERE id = '93463416-9acf-4f4e-a207-1749c61bb6df';
  UPDATE public.profiles SET spouse_id = '93463416-9acf-4f4e-a207-1749c61bb6df' WHERE id = '092dc14f-d240-44ba-9003-d73153529ea8';
  UPDATE public.profiles SET spouse_id = '0f70a77f-c13e-42e2-a983-d285cf37ab17' WHERE id = '40133761-8eed-4725-be4f-81855655d743';
  UPDATE public.profiles SET spouse_id = '40133761-8eed-4725-be4f-81855655d743' WHERE id = '0f70a77f-c13e-42e2-a983-d285cf37ab17';
  UPDATE public.profiles SET spouse_id = '516fd14d-d306-4ed3-a223-9b87680539d0' WHERE id = '75fc919f-348f-4e89-a320-fe3cbdab4cd8';
  UPDATE public.profiles SET spouse_id = '75fc919f-348f-4e89-a320-fe3cbdab4cd8' WHERE id = '516fd14d-d306-4ed3-a223-9b87680539d0';
  UPDATE public.profiles SET spouse_id = '7f83e971-59c3-4e51-934c-b2de7ba5f9e0' WHERE id = '873d4980-4e53-46f5-a03e-44d9dbdfdd2e';
  UPDATE public.profiles SET spouse_id = '873d4980-4e53-46f5-a03e-44d9dbdfdd2e' WHERE id = '7f83e971-59c3-4e51-934c-b2de7ba5f9e0';
  UPDATE public.profiles SET spouse_id = '956dc23c-6e49-4603-95ac-0ed7bbec1c3d' WHERE id = '3794c3ce-3837-4385-95be-d9752b952b8c';
  UPDATE public.profiles SET spouse_id = '3794c3ce-3837-4385-95be-d9752b952b8c' WHERE id = '956dc23c-6e49-4603-95ac-0ed7bbec1c3d';
  UPDATE public.profiles SET spouse_id = 'f31522a7-2b18-422d-a6c7-bc48080aa05d' WHERE id = 'e42990d9-221d-4f6a-a0ca-56876b1a60cc';
  UPDATE public.profiles SET spouse_id = 'e42990d9-221d-4f6a-a0ca-56876b1a60cc' WHERE id = 'f31522a7-2b18-422d-a6c7-bc48080aa05d';
  UPDATE public.profiles SET spouse_id = '3ea7012f-7343-418d-9c90-143f5e33a442' WHERE id = '036b3af9-a904-47f2-997c-2dccd58f7241';
  UPDATE public.profiles SET spouse_id = '036b3af9-a904-47f2-997c-2dccd58f7241' WHERE id = '3ea7012f-7343-418d-9c90-143f5e33a442';
  UPDATE public.profiles SET spouse_id = 'b930850a-f8ed-40fc-afd1-4464468428d8' WHERE id = '22fec886-6757-4c6c-ad27-ffc82323b05a';
  UPDATE public.profiles SET spouse_id = '22fec886-6757-4c6c-ad27-ffc82323b05a' WHERE id = 'b930850a-f8ed-40fc-afd1-4464468428d8';
  UPDATE public.profiles SET spouse_id = 'be4a7b12-50be-4973-a1e2-8afe22640313' WHERE id = '2978482f-65e5-4b56-bd58-b8188fe34702';
  UPDATE public.profiles SET spouse_id = '2978482f-65e5-4b56-bd58-b8188fe34702' WHERE id = 'be4a7b12-50be-4973-a1e2-8afe22640313';
  UPDATE public.profiles SET spouse_id = 'de432b3f-0888-465f-8b2a-3b69cd87d8ef' WHERE id = 'b2d681b9-36e3-404c-a558-dc438e05439c';
  UPDATE public.profiles SET spouse_id = 'b2d681b9-36e3-404c-a558-dc438e05439c' WHERE id = 'de432b3f-0888-465f-8b2a-3b69cd87d8ef';
  UPDATE public.profiles SET spouse_id = 'b42b967a-1d6b-4413-9698-fda2bd6c1bba' WHERE id = 'f5a3e244-73ac-443a-bf04-5bd4b088c933';
  UPDATE public.profiles SET spouse_id = 'f5a3e244-73ac-443a-bf04-5bd4b088c933' WHERE id = 'b42b967a-1d6b-4413-9698-fda2bd6c1bba';
  UPDATE public.profiles SET spouse_id = '191ff051-4398-4bdf-b188-c014f05a6846' WHERE id = '261a3038-4320-4697-8823-40fbe1b5af09';
  UPDATE public.profiles SET spouse_id = '261a3038-4320-4697-8823-40fbe1b5af09' WHERE id = '191ff051-4398-4bdf-b188-c014f05a6846';
  UPDATE public.profiles SET spouse_id = '4320f7b2-5640-43d7-bf5d-729f5018b583' WHERE id = '88f06b75-1453-4692-922a-5d4df40e81c8';
  UPDATE public.profiles SET spouse_id = '88f06b75-1453-4692-922a-5d4df40e81c8' WHERE id = '4320f7b2-5640-43d7-bf5d-729f5018b583';
  UPDATE public.profiles SET spouse_id = 'ebb40e70-f04f-4b6b-93d6-fa1b4b675e86' WHERE id = '47cab605-b882-48b1-bdd5-242a94e5b48d';
  UPDATE public.profiles SET spouse_id = '47cab605-b882-48b1-bdd5-242a94e5b48d' WHERE id = 'ebb40e70-f04f-4b6b-93d6-fa1b4b675e86';
  UPDATE public.profiles SET spouse_id = 'a72db742-5299-48fb-99c1-add56acbaadd' WHERE id = 'f1b9627a-24e2-4db5-82e3-0aada5b6603f';
  UPDATE public.profiles SET spouse_id = 'f1b9627a-24e2-4db5-82e3-0aada5b6603f' WHERE id = 'a72db742-5299-48fb-99c1-add56acbaadd';
  UPDATE public.profiles SET spouse_id = '4744e9ec-a15f-4f96-a81b-0e360a418891' WHERE id = 'c584a8b3-562f-4b18-b994-5574a69ef2f0';
  UPDATE public.profiles SET spouse_id = 'c584a8b3-562f-4b18-b994-5574a69ef2f0' WHERE id = '4744e9ec-a15f-4f96-a81b-0e360a418891';
  UPDATE public.profiles SET spouse_id = 'e71b6dba-a1a1-4166-a749-2a32ee049a8f' WHERE id = '7071838f-2bfe-4c05-b585-5ccca33e77e9';
  UPDATE public.profiles SET spouse_id = '7071838f-2bfe-4c05-b585-5ccca33e77e9' WHERE id = 'e71b6dba-a1a1-4166-a749-2a32ee049a8f';
  UPDATE public.profiles SET spouse_id = '94a1b3ce-ce44-4a5f-8c99-34113f73178a' WHERE id = 'cace5470-4861-446c-9dce-c5cabc130666';
  UPDATE public.profiles SET spouse_id = 'cace5470-4861-446c-9dce-c5cabc130666' WHERE id = '94a1b3ce-ce44-4a5f-8c99-34113f73178a';
  UPDATE public.profiles SET spouse_id = 'abea98a8-bc87-42f1-9d41-318bc3669b51' WHERE id = '036b14a5-5007-4d96-91f8-5f2437c041b2';
  UPDATE public.profiles SET spouse_id = '036b14a5-5007-4d96-91f8-5f2437c041b2' WHERE id = 'abea98a8-bc87-42f1-9d41-318bc3669b51';
  UPDATE public.profiles SET spouse_id = '885dcff6-6dfa-463e-90f8-1b329afe34c9' WHERE id = '37973a6a-7872-4033-8ff0-faf0f9790202';
  UPDATE public.profiles SET spouse_id = '37973a6a-7872-4033-8ff0-faf0f9790202' WHERE id = '885dcff6-6dfa-463e-90f8-1b329afe34c9';
  UPDATE public.profiles SET spouse_id = '6949ca7e-ad93-4433-942b-fd5b2e90d2e3' WHERE id = '4c8540ba-a101-4fee-9b5d-1c8a1276486e';
  UPDATE public.profiles SET spouse_id = '4c8540ba-a101-4fee-9b5d-1c8a1276486e' WHERE id = '6949ca7e-ad93-4433-942b-fd5b2e90d2e3';
  UPDATE public.profiles SET spouse_id = '210bab9b-dbb9-4db3-a407-9c9ddb9bd2dc' WHERE id = 'bbc02073-1866-45b1-9fb8-6fe7c61ca0be';
  UPDATE public.profiles SET spouse_id = 'bbc02073-1866-45b1-9fb8-6fe7c61ca0be' WHERE id = '210bab9b-dbb9-4db3-a407-9c9ddb9bd2dc';
  UPDATE public.profiles SET spouse_id = '5917a61a-2bf8-4bd8-9ba2-f35d5bf56324' WHERE id = '326a0e58-1db7-4d6f-baec-9605aaf6e89f';
  UPDATE public.profiles SET spouse_id = '326a0e58-1db7-4d6f-baec-9605aaf6e89f' WHERE id = '5917a61a-2bf8-4bd8-9ba2-f35d5bf56324';
  UPDATE public.profiles SET spouse_id = '464f8926-9a3f-44a9-9a75-44a5b8865c5f' WHERE id = 'ea29d78e-2d40-4662-97ff-b3e218cb7ac3';
  UPDATE public.profiles SET spouse_id = 'ea29d78e-2d40-4662-97ff-b3e218cb7ac3' WHERE id = '464f8926-9a3f-44a9-9a75-44a5b8865c5f';
  UPDATE public.profiles SET spouse_id = '42ea1e02-457a-41c6-b0c0-e3025593bd34' WHERE id = 'dc8037ee-f406-477d-b28c-6fb6f9afbff7';
  UPDATE public.profiles SET spouse_id = 'dc8037ee-f406-477d-b28c-6fb6f9afbff7' WHERE id = '42ea1e02-457a-41c6-b0c0-e3025593bd34';
  UPDATE public.profiles SET spouse_id = '5568cae3-c3b2-453f-8f9d-8d3fd2edf1b1' WHERE id = '2ff70477-42b4-4ea3-a2c0-ccc751fb1a45';
  UPDATE public.profiles SET spouse_id = '2ff70477-42b4-4ea3-a2c0-ccc751fb1a45' WHERE id = '5568cae3-c3b2-453f-8f9d-8d3fd2edf1b1';
  UPDATE public.profiles SET spouse_id = '4480ebec-ce3e-4acd-870b-3abc8b618be1' WHERE id = '850a789d-a1ed-4714-a07d-4ed671f48ec2';
  UPDATE public.profiles SET spouse_id = '850a789d-a1ed-4714-a07d-4ed671f48ec2' WHERE id = '4480ebec-ce3e-4acd-870b-3abc8b618be1';
  UPDATE public.profiles SET spouse_id = '7b4d3c67-be95-4f03-a309-b14d0d991f47' WHERE id = '8e0f5221-e0b6-4c94-ae6f-6d6b603c35b6';
  UPDATE public.profiles SET spouse_id = '8e0f5221-e0b6-4c94-ae6f-6d6b603c35b6' WHERE id = '7b4d3c67-be95-4f03-a309-b14d0d991f47';
  UPDATE public.profiles SET spouse_id = '45f8b398-205a-49ab-82ad-ea77c09dac9e' WHERE id = 'f2d55038-d517-4255-bb30-fb7fc41111cc';
  UPDATE public.profiles SET spouse_id = 'f2d55038-d517-4255-bb30-fb7fc41111cc' WHERE id = '45f8b398-205a-49ab-82ad-ea77c09dac9e';
  UPDATE public.profiles SET spouse_id = '1b52b8d2-ccd1-4507-bed0-bb6b74c7bf67' WHERE id = '452eb67a-5995-4510-97a6-5544f7efa153';
  UPDATE public.profiles SET spouse_id = '452eb67a-5995-4510-97a6-5544f7efa153' WHERE id = '1b52b8d2-ccd1-4507-bed0-bb6b74c7bf67';
  UPDATE public.profiles SET spouse_id = '0a5a333c-97f7-4951-80f0-ee95c9eaab1a' WHERE id = '7b8b10dc-c378-4c75-9a81-737f77eb2cc4';
  UPDATE public.profiles SET spouse_id = '7b8b10dc-c378-4c75-9a81-737f77eb2cc4' WHERE id = '0a5a333c-97f7-4951-80f0-ee95c9eaab1a';
  UPDATE public.profiles SET spouse_id = '3fa054a5-0dd0-444c-a4d9-913e4a9dd8c3' WHERE id = '7e116062-a746-42b8-be49-04c155e81074';
  UPDATE public.profiles SET spouse_id = '7e116062-a746-42b8-be49-04c155e81074' WHERE id = '3fa054a5-0dd0-444c-a4d9-913e4a9dd8c3';
  UPDATE public.profiles SET spouse_id = '8aafef63-ece5-4d6f-8e43-5fa47d2bda7a' WHERE id = 'bd95dcbd-5132-41f5-863a-249d8f71ddbc';
  UPDATE public.profiles SET spouse_id = 'bd95dcbd-5132-41f5-863a-249d8f71ddbc' WHERE id = '8aafef63-ece5-4d6f-8e43-5fa47d2bda7a';
  UPDATE public.profiles SET spouse_id = '5baffafa-dde2-45f5-bd4a-964fd5c71fd8' WHERE id = '2da55b2a-63c8-48bc-9296-19db1b203e42';
  UPDATE public.profiles SET spouse_id = '2da55b2a-63c8-48bc-9296-19db1b203e42' WHERE id = '5baffafa-dde2-45f5-bd4a-964fd5c71fd8';
  UPDATE public.profiles SET spouse_id = '6c6a73e0-86b6-44f8-910a-7f50b0bfc502' WHERE id = 'c2133747-544d-4787-a3bd-0f473e9248ea';
  UPDATE public.profiles SET spouse_id = 'c2133747-544d-4787-a3bd-0f473e9248ea' WHERE id = '6c6a73e0-86b6-44f8-910a-7f50b0bfc502';
  UPDATE public.profiles SET spouse_id = '34460ba9-08c2-446f-a28c-1b4e26d3d085' WHERE id = 'b5b7bb42-7e19-4bde-96c3-55783807b875';
  UPDATE public.profiles SET spouse_id = 'b5b7bb42-7e19-4bde-96c3-55783807b875' WHERE id = '34460ba9-08c2-446f-a28c-1b4e26d3d085';
  UPDATE public.profiles SET spouse_id = '77535d8c-a688-4192-888d-99456c03d219' WHERE id = '301313cb-9edf-4df9-880c-861d0bdf8684';
  UPDATE public.profiles SET spouse_id = '301313cb-9edf-4df9-880c-861d0bdf8684' WHERE id = '77535d8c-a688-4192-888d-99456c03d219';
  UPDATE public.profiles SET spouse_id = 'c41ab840-a4a1-46f8-910b-b89458465c50' WHERE id = '7daaa1ca-a3b2-4234-945f-f6c2e4bd1741';
  UPDATE public.profiles SET spouse_id = '7daaa1ca-a3b2-4234-945f-f6c2e4bd1741' WHERE id = 'c41ab840-a4a1-46f8-910b-b89458465c50';
  UPDATE public.profiles SET spouse_id = 'b82ac044-4e47-4425-9dc3-5bcf3e303069' WHERE id = 'f0144a74-2985-4ec5-b933-e7473a503419';
  UPDATE public.profiles SET spouse_id = 'f0144a74-2985-4ec5-b933-e7473a503419' WHERE id = 'b82ac044-4e47-4425-9dc3-5bcf3e303069';
  UPDATE public.profiles SET spouse_id = 'd5a73f79-50e8-4a15-ba86-a31278f3be6f' WHERE id = '0c3d6b39-e4b4-43e0-84ed-645651f95a95';
  UPDATE public.profiles SET spouse_id = '0c3d6b39-e4b4-43e0-84ed-645651f95a95' WHERE id = 'd5a73f79-50e8-4a15-ba86-a31278f3be6f';
  UPDATE public.profiles SET spouse_id = 'b0ec4c8e-d920-4c8a-9139-7a65d546ed25' WHERE id = 'ff3860fa-07b0-49ff-b045-8dc21b761c9a';
  UPDATE public.profiles SET spouse_id = 'ff3860fa-07b0-49ff-b045-8dc21b761c9a' WHERE id = 'b0ec4c8e-d920-4c8a-9139-7a65d546ed25';
  UPDATE public.profiles SET spouse_id = '8c252007-45c9-4ba7-a90a-8f6c6032f9ba' WHERE id = 'bac793b5-2770-4659-a5c2-dac9bfcc55c5';
  UPDATE public.profiles SET spouse_id = 'bac793b5-2770-4659-a5c2-dac9bfcc55c5' WHERE id = '8c252007-45c9-4ba7-a90a-8f6c6032f9ba';
  UPDATE public.profiles SET spouse_id = '0cefc313-23b1-43cc-85e7-8b97db1a9b99' WHERE id = '58898f09-f0cb-433c-9f15-d1ecee59d3b2';
  UPDATE public.profiles SET spouse_id = '58898f09-f0cb-433c-9f15-d1ecee59d3b2' WHERE id = '0cefc313-23b1-43cc-85e7-8b97db1a9b99';
  UPDATE public.profiles SET spouse_id = '5f26e08a-d4a1-47d2-811a-60e183911ee2' WHERE id = 'c2756a74-66b5-4464-b6dc-fb5cb58378c5';
  UPDATE public.profiles SET spouse_id = 'c2756a74-66b5-4464-b6dc-fb5cb58378c5' WHERE id = '5f26e08a-d4a1-47d2-811a-60e183911ee2';
  UPDATE public.profiles SET spouse_id = 'fc1fb7a7-afdc-4999-9eb2-fb016bb98f87' WHERE id = '74d1cdaf-2b3c-4ff9-af30-b25d39486fcb';
  UPDATE public.profiles SET spouse_id = '74d1cdaf-2b3c-4ff9-af30-b25d39486fcb' WHERE id = 'fc1fb7a7-afdc-4999-9eb2-fb016bb98f87';
  UPDATE public.profiles SET spouse_id = '508f5fc2-76ea-48b1-8e0e-098d522fb046' WHERE id = 'c835a872-b07f-48d4-89dd-3acbf0a8b842';
  UPDATE public.profiles SET spouse_id = 'c835a872-b07f-48d4-89dd-3acbf0a8b842' WHERE id = '508f5fc2-76ea-48b1-8e0e-098d522fb046';
  UPDATE public.profiles SET spouse_id = 'fcd20f02-61ee-487f-b082-37216166fa75' WHERE id = '6ac5e9c4-075e-4ef4-8244-30537a83235f';
  UPDATE public.profiles SET spouse_id = '6ac5e9c4-075e-4ef4-8244-30537a83235f' WHERE id = 'fcd20f02-61ee-487f-b082-37216166fa75';
  UPDATE public.profiles SET spouse_id = 'a929879f-0a52-4a74-bc30-e8a2e7d77a87' WHERE id = '11865c14-2321-4b46-acd4-b6bc2c95ca97';
  UPDATE public.profiles SET spouse_id = '11865c14-2321-4b46-acd4-b6bc2c95ca97' WHERE id = 'a929879f-0a52-4a74-bc30-e8a2e7d77a87';
  UPDATE public.profiles SET spouse_id = 'e649e829-dc55-4ce9-9403-ecd87c28ecf9' WHERE id = '3c592361-4399-4dd4-a539-94833869c91b';
  UPDATE public.profiles SET spouse_id = '3c592361-4399-4dd4-a539-94833869c91b' WHERE id = 'e649e829-dc55-4ce9-9403-ecd87c28ecf9';
  UPDATE public.profiles SET father_id = '6b7b1503-8f48-409c-a0d9-d6ccf021d6c2', mother_id = '425e5c0e-79da-41a5-b2c6-f930bd6eb23e' WHERE id = 'dfa0577d-a152-4496-83d6-b93063bdd23f';
  UPDATE public.profiles SET father_id = 'eaf52b9c-d7d1-48dd-ad19-a287a6807df0', mother_id = 'd5b0c069-8cae-4bd3-9fb3-2b862e55f9b3' WHERE id = 'a3046d6c-5b69-4f1f-9522-ceee6211bbdf';
  UPDATE public.profiles SET father_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1', mother_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = 'b4687743-9b48-4fae-834e-5fe7fb19f05a';
  UPDATE public.profiles SET father_id = NULL, mother_id = '6000aaf3-1674-4418-aa81-29543143fe6a' WHERE id = '99c5c33b-a17d-4e1d-b362-dc5baa9ace9d';
  UPDATE public.profiles SET father_id = NULL, mother_id = '6000aaf3-1674-4418-aa81-29543143fe6a' WHERE id = '8387b20b-ecd4-437c-9531-945b87659d85';
  UPDATE public.profiles SET father_id = 'ec051e64-ffce-4f37-bfb7-c2f6e29bfdd1', mother_id = '4477f189-e461-4d08-b3c9-caf05f98c772' WHERE id = 'efced203-7f62-463b-9437-a59270be23c4';
  UPDATE public.profiles SET father_id = 'ec051e64-ffce-4f37-bfb7-c2f6e29bfdd1', mother_id = '4477f189-e461-4d08-b3c9-caf05f98c772' WHERE id = 'e2adff93-2ee7-4f85-b203-ce9bc02c38ae';
  UPDATE public.profiles SET father_id = 'afd19ec0-75da-4df1-8b60-d9402e912d46', mother_id = '337bdc08-6b2c-41f1-ac84-937e2c960b8e' WHERE id = '9c60abd9-6ccc-41f6-94ed-2f012e15230d';
  UPDATE public.profiles SET father_id = 'afd19ec0-75da-4df1-8b60-d9402e912d46', mother_id = '337bdc08-6b2c-41f1-ac84-937e2c960b8e' WHERE id = 'ec8f440c-4d7f-4a24-8d21-2ece7b846522';
  UPDATE public.profiles SET father_id = 'a984e0dc-5082-401c-a77f-44b4146e15a2', mother_id = 'cb35fefc-3ec0-4a04-a645-abd3ca790a41' WHERE id = '4ff489d0-abf3-40ca-93f1-e5b0a988ef24';
  UPDATE public.profiles SET father_id = 'a984e0dc-5082-401c-a77f-44b4146e15a2', mother_id = 'cb35fefc-3ec0-4a04-a645-abd3ca790a41' WHERE id = '443f6bdf-da31-47a2-820d-5ce986245a81';
  UPDATE public.profiles SET father_id = '4c4a5960-daaf-489c-827c-d7cd17df72e9', mother_id = 'ecb2345b-6190-4a59-aadc-3c1e04805a20' WHERE id = 'bb8359a2-93d1-4834-9712-461705043c60';
  UPDATE public.profiles SET father_id = '4c4a5960-daaf-489c-827c-d7cd17df72e9', mother_id = 'ecb2345b-6190-4a59-aadc-3c1e04805a20' WHERE id = 'be5c59ab-d165-4922-93f7-69a86d0af96c';
  UPDATE public.profiles SET father_id = '22994182-ebda-4aa6-b715-9c3296957181', mother_id = '10e831c3-be52-4828-8e7c-788b72ab0bbb' WHERE id = '98304d55-8743-4783-abfd-4bfdd23942d3';
  UPDATE public.profiles SET father_id = '22994182-ebda-4aa6-b715-9c3296957181', mother_id = '10e831c3-be52-4828-8e7c-788b72ab0bbb' WHERE id = '50f9a13e-3ef8-4d19-8768-81a5f2b1cfbd';
  UPDATE public.profiles SET father_id = '22994182-ebda-4aa6-b715-9c3296957181', mother_id = '10e831c3-be52-4828-8e7c-788b72ab0bbb' WHERE id = '91519024-7c98-44b2-bdf6-3c1a96e22400';
  UPDATE public.profiles SET father_id = 'bcd9ffb6-aa46-4c19-9a88-41989cfe0598', mother_id = '45f23409-8e1b-440a-91de-a42e11c4f9ce' WHERE id = 'b84a0a95-4254-49b4-a504-9b6b0a3ddf4a';
  UPDATE public.profiles SET father_id = 'bcd9ffb6-aa46-4c19-9a88-41989cfe0598', mother_id = '45f23409-8e1b-440a-91de-a42e11c4f9ce' WHERE id = '4ed1da52-07ed-4021-9a42-fac4cbec7649';
  UPDATE public.profiles SET father_id = 'bcd9ffb6-aa46-4c19-9a88-41989cfe0598', mother_id = '45f23409-8e1b-440a-91de-a42e11c4f9ce' WHERE id = '2a35a5a3-3a1d-4356-b787-9ccbaefc3792';
  UPDATE public.profiles SET father_id = '6a75a407-4dad-4333-8469-1d96d00926d3', mother_id = '67b3c127-3dda-43af-a332-c2d16ce03e11' WHERE id = '4f31f085-2678-4be7-b7b6-d48c14983a9a';
  UPDATE public.profiles SET father_id = '6a75a407-4dad-4333-8469-1d96d00926d3', mother_id = '67b3c127-3dda-43af-a332-c2d16ce03e11' WHERE id = '25080b17-2896-455c-86ea-8bf7f076ad20';
  UPDATE public.profiles SET father_id = 'c87b8712-cf05-48b5-b820-dc172460fe5d', mother_id = 'f9efb3e4-a627-4c5b-bc28-125132334751' WHERE id = '2c465bea-a93b-466d-a333-084519bbdc89';
  UPDATE public.profiles SET father_id = 'c87b8712-cf05-48b5-b820-dc172460fe5d', mother_id = 'f9efb3e4-a627-4c5b-bc28-125132334751' WHERE id = 'dde3887e-f3ff-4594-b725-6396232601be';
  UPDATE public.profiles SET father_id = '3774929f-208a-47a5-b41c-41b5c4a255fd', mother_id = '959c3df3-ecac-4b76-bc20-c3e105828c6f' WHERE id = '252e78f2-8381-4fa3-aa09-58363bacea4c';
  UPDATE public.profiles SET father_id = '3774929f-208a-47a5-b41c-41b5c4a255fd', mother_id = '959c3df3-ecac-4b76-bc20-c3e105828c6f' WHERE id = '48858676-9ba0-46f0-8994-962755381b22';
  UPDATE public.profiles SET father_id = '748e38bd-6b77-47c7-9ed7-2a2e0c6a46dc', mother_id = 'a7d7345b-6d89-40b8-8a34-0b1d61003ee9' WHERE id = '62fde44b-201b-46c3-b412-d24ae1e8fb2c';
  UPDATE public.profiles SET father_id = 'bf6d306e-8652-41fa-aca5-ed1674fdc41a', mother_id = 'ee7ffe41-3b01-4d16-9567-75262b0e7990' WHERE id = '607be0a5-8135-46df-aee8-eb178a17de80';
  UPDATE public.profiles SET father_id = '5c74e216-d02f-44d2-afbd-280317b14dfe', mother_id = '52fb29b0-20b5-444f-bf5f-ee5147f7493c' WHERE id = 'c2285b61-56a3-41d6-9a6f-40aa68fc0d77';
  UPDATE public.profiles SET father_id = '510e50aa-1eac-4369-9fc1-0acea761a7dd', mother_id = '3124f4de-c749-4c7c-bbbb-9b933d3b76d4' WHERE id = '289ec264-77d5-4705-b91c-95c2186a32d4';
  UPDATE public.profiles SET father_id = '9d1a9f2b-5088-4ffe-b971-c35dd5945c4f', mother_id = '0c134eb5-6e9a-4a73-b493-e1da8b1cb629' WHERE id = 'd071713c-e7b0-4c3f-a1d0-afae372fbed6';
  UPDATE public.profiles SET father_id = NULL, mother_id = '1a86a28f-9c21-4d77-ba05-a83faff42a9c' WHERE id = '83714d72-e22e-463e-b936-088265db3f30';
  UPDATE public.profiles SET father_id = '4ba9b8f3-7122-486d-a43d-b34922b7a04a', mother_id = '3c8388af-9675-4a38-86eb-c422bab96cbe' WHERE id = '0597b054-8be5-467a-987f-c56308a28236';
  UPDATE public.profiles SET father_id = '4ba9b8f3-7122-486d-a43d-b34922b7a04a', mother_id = '3c8388af-9675-4a38-86eb-c422bab96cbe' WHERE id = 'fe375bb9-83e4-426c-b1cb-a287b289c278';
  UPDATE public.profiles SET father_id = 'ef14a065-d5fb-4e13-9779-bc9b5c267a52', mother_id = '74cbfa30-1257-42d5-91bc-9e595de6d067' WHERE id = '8c9a1b32-958d-4b44-a79a-f4671bbb3f6b';
  UPDATE public.profiles SET father_id = '07366db0-2e6c-49f4-86f9-b349088bb253', mother_id = 'c8998cef-df63-4419-adb3-206f5d89d54d' WHERE id = 'f3266092-c488-42ee-b586-af5fa006619d';
  UPDATE public.profiles SET father_id = 'b748780e-0227-4eea-93f3-9e5ffd582187', mother_id = 'fbd774c1-a520-4eca-bcb1-906a3be33b90' WHERE id = '43144135-0f3e-411f-9554-da3123fc7534';
  UPDATE public.profiles SET father_id = 'b748780e-0227-4eea-93f3-9e5ffd582187', mother_id = 'fbd774c1-a520-4eca-bcb1-906a3be33b90' WHERE id = '13170641-402a-40b2-8f6c-095ed40aed90';
  UPDATE public.profiles SET father_id = 'a8ad3f52-edf2-40f1-ae61-5aab86a7abd5', mother_id = '1e0d092f-ad3a-4be3-8c43-1b8be389d6ce' WHERE id = '04c8aacb-40f8-4b49-ae6a-98ccde19b13a';
  UPDATE public.profiles SET father_id = 'e0e5ac4b-b5ac-4d20-a0fa-74bbe8dcce67', mother_id = 'dd92baa3-d81f-4ecb-ac90-26bf6dd93cb9' WHERE id = '8e1b18db-d67c-48fb-86aa-8ba5d79da082';
  UPDATE public.profiles SET father_id = 'e454e77c-01af-4a81-acd8-1c5ee3bc2fb1', mother_id = '3aeb8cf2-c7db-4e05-99d9-08b9f8ec85c9' WHERE id = 'ab460d8b-c7eb-4d29-b6a7-a360fe392be4';
  UPDATE public.profiles SET father_id = 'e454e77c-01af-4a81-acd8-1c5ee3bc2fb1', mother_id = '3aeb8cf2-c7db-4e05-99d9-08b9f8ec85c9' WHERE id = '79808740-e212-4bab-9682-efe38718b6c3';
  UPDATE public.profiles SET father_id = '71134040-e519-4cb6-a859-4f5266f229f5', mother_id = '37aed401-1fca-43b4-8396-6a3209429260' WHERE id = '78addeb9-d21a-4ef2-a2ff-58e4949fe849';
  UPDATE public.profiles SET father_id = '27cda7e9-8f51-4a8b-8eef-303c3d126c0d', mother_id = '8b11fd5b-f5f8-4492-bac2-7e38baab49fd' WHERE id = 'dc2a8a5a-062d-4044-b2f0-0fa1b71ccbaa';
  UPDATE public.profiles SET father_id = '27cda7e9-8f51-4a8b-8eef-303c3d126c0d', mother_id = '8b11fd5b-f5f8-4492-bac2-7e38baab49fd' WHERE id = '7113daaa-fed1-41ab-9bb4-48c1e3f9f720';
  UPDATE public.profiles SET father_id = '33ba0ab1-dc22-4a72-8765-81abb06454d3', mother_id = 'b1be76b7-b9d3-436e-bf42-82ac78196baf' WHERE id = '80e3383a-c5e7-4788-814b-2fdb5b2e746b';
  UPDATE public.profiles SET father_id = '33ba0ab1-dc22-4a72-8765-81abb06454d3', mother_id = 'b1be76b7-b9d3-436e-bf42-82ac78196baf' WHERE id = '6fa9f817-254d-4f3b-a6bd-5be09c845b6c';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'f1215a6d-6ca1-4b40-8fc4-b19e5a45297f' WHERE id = '68567951-93b4-4b2b-a082-09273db7af17';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'f1215a6d-6ca1-4b40-8fc4-b19e5a45297f' WHERE id = '2591c830-ac34-4746-a450-af6c19594119';
  UPDATE public.profiles SET father_id = '005b1789-b9a4-4922-8c70-0629ce4c7fff', mother_id = '9aa58a8b-b179-49b4-a3b4-3d6aa0f4b079' WHERE id = '809dc61a-caeb-4af4-889b-2e5dc84be5cb';
  UPDATE public.profiles SET father_id = 'f48ae622-64c2-4b0d-af76-ad4a8208d098', mother_id = 'd513b617-28cb-4050-83b2-ff801f763f63' WHERE id = '83bacc2a-ffe5-42dd-82da-03c771eb48f7';
  UPDATE public.profiles SET father_id = 'af590c9f-12d7-457d-8b43-39fbbaf2e5db', mother_id = 'fe50fdcc-c384-4029-8b57-d45b48b99c80' WHERE id = '8784f447-db9b-4ac0-9ef9-ff7d2be34189';
  UPDATE public.profiles SET father_id = 'af590c9f-12d7-457d-8b43-39fbbaf2e5db', mother_id = 'fe50fdcc-c384-4029-8b57-d45b48b99c80' WHERE id = '321aec57-1ac2-4674-b885-76a0e45bdeb9';
  UPDATE public.profiles SET father_id = 'c4e92cc2-ca10-4c97-aeea-df69d15b4651', mother_id = 'a33cd689-65d9-4b4c-b3e9-5e2e31b7107b' WHERE id = '980b2f51-dabb-4c82-9d7a-16a238ffae49';
  UPDATE public.profiles SET father_id = '8a4e3479-1da9-4e4b-9773-393fd3626764', mother_id = 'd379fedb-0c55-4916-8888-e2ad5f8532ea' WHERE id = 'a7cf9642-7b29-4abb-854b-b5a04d35d05a';
  UPDATE public.profiles SET father_id = '8a4e3479-1da9-4e4b-9773-393fd3626764', mother_id = 'd379fedb-0c55-4916-8888-e2ad5f8532ea' WHERE id = '82f8bdb5-bbbf-4a32-9aa9-cf0e8e7ee203';
  UPDATE public.profiles SET father_id = '59a3a433-74ca-4a11-a2eb-8dc9e4e157a3', mother_id = '2bbebb46-5b7d-464e-93f4-6f784fa55b7b' WHERE id = '0b10f7b0-84ac-4277-8ac1-50f291f5ebfd';
  UPDATE public.profiles SET father_id = '5bf8019f-94f6-4d14-958c-543bdf48198c', mother_id = '20924b51-51d0-4464-8a3b-60fb353d5d0a' WHERE id = 'aa9d73cf-8c7d-4502-8124-6b31b53dcac5';
  UPDATE public.profiles SET father_id = '7d5a8f77-6d3e-4e9d-b5da-ca58a7af12a1', mother_id = 'c945aaf0-f082-4152-a6ab-c753986e89c7' WHERE id = 'e5cf66d9-4f17-4526-af19-9139ffe2d544';
  UPDATE public.profiles SET father_id = '7d5a8f77-6d3e-4e9d-b5da-ca58a7af12a1', mother_id = 'c945aaf0-f082-4152-a6ab-c753986e89c7' WHERE id = '58f22e43-3007-4007-9661-b267ab9d6832';
  UPDATE public.profiles SET father_id = '2c2a4c9f-4ae6-4ece-9287-cf1301b28615', mother_id = 'ad0f2b65-1246-4288-9e78-653d2c377626' WHERE id = '4b94b8bd-fa38-4b0c-899d-a73a79783e69';
  UPDATE public.profiles SET father_id = '2c2a4c9f-4ae6-4ece-9287-cf1301b28615', mother_id = 'ad0f2b65-1246-4288-9e78-653d2c377626' WHERE id = '29d1145e-6f97-46c3-bad0-1238285893ff';
  UPDATE public.profiles SET father_id = '66c1eee5-2c5d-4405-b680-ab83f0429724', mother_id = 'af85f349-a7af-4d46-9daf-ae1f2eabc375' WHERE id = '7aaab403-4f86-48ae-b62c-3148c09564dd';
  UPDATE public.profiles SET father_id = '12d805ce-183c-4f2e-92bb-1830ef7778d8', mother_id = '7873ec8d-e43a-4513-9a9c-013b09107834' WHERE id = '72443398-2053-454d-8167-eff7271c45bf';
  UPDATE public.profiles SET father_id = '8e4e872f-e93b-498d-a6b9-551d06fa082a', mother_id = 'a7585340-04b8-463e-98e0-950ea4d52906' WHERE id = '21592ff8-3e6d-4556-bdbc-2e6fc1391d2f';
  UPDATE public.profiles SET father_id = '8e4e872f-e93b-498d-a6b9-551d06fa082a', mother_id = 'a7585340-04b8-463e-98e0-950ea4d52906' WHERE id = '1a276854-f5f2-4b25-8487-411a7b5e977f';
  UPDATE public.profiles SET father_id = '4068d892-8d90-4a1a-b8d9-9b1809c0af61', mother_id = '675e4992-d9b1-4da1-b147-f02eceed7e30' WHERE id = '943ae2d9-b81d-4040-b674-b284a621bf7a';
  UPDATE public.profiles SET father_id = 'd0952ba5-945a-4479-94f1-9926b1a2fac9', mother_id = 'c9f1a974-b158-4e3f-9760-5b687cab0919' WHERE id = 'd099d36f-4485-433f-8da9-6e71bef1306d';
  UPDATE public.profiles SET father_id = '8ff1f030-ad11-4cd3-9d2f-a8c178a48104', mother_id = 'e0625d12-06b9-4fe4-b461-524a33fbef24' WHERE id = '1faa0611-feea-4982-9b33-3fba8b345c72';
  UPDATE public.profiles SET father_id = '8ff1f030-ad11-4cd3-9d2f-a8c178a48104', mother_id = 'e0625d12-06b9-4fe4-b461-524a33fbef24' WHERE id = '6680bc00-b442-4aad-aef0-120bf0235f8f';
  UPDATE public.profiles SET father_id = '742a5e06-ce24-4721-9aec-a7a26e96cdcc', mother_id = 'e6d99983-4f42-4516-80f3-4acb7e274016' WHERE id = 'a8ebca91-d777-4fc3-8c71-1bb0fb531d55';
  UPDATE public.profiles SET father_id = '742a5e06-ce24-4721-9aec-a7a26e96cdcc', mother_id = 'e6d99983-4f42-4516-80f3-4acb7e274016' WHERE id = '88bbbd9f-15ae-4a4e-9bf9-17b42a1c90c6';
  UPDATE public.profiles SET father_id = '22857b4e-a9ab-4e91-bf23-008de0da1fcb', mother_id = '7e3e92b1-efa0-46c8-9f23-79bd76a59ff8' WHERE id = '5e12b668-9279-4dbe-baaf-9dad3d67ef7b';
  UPDATE public.profiles SET father_id = '22857b4e-a9ab-4e91-bf23-008de0da1fcb', mother_id = '7e3e92b1-efa0-46c8-9f23-79bd76a59ff8' WHERE id = '7ea0145b-2a1f-40b4-9e8c-c7b642a1d351';
  UPDATE public.profiles SET father_id = NULL, mother_id = 'deca0afd-0996-4618-aa72-1c287d8e9f6e' WHERE id = 'dd531eda-d871-42d5-a193-4b796656f509';
  UPDATE public.profiles SET father_id = '12e061aa-fb55-4165-86c8-c06c7d5381c1', mother_id = '04188ea7-29c7-4dfc-a7f2-a745a110b1cb' WHERE id = 'd1142389-f970-44a9-92e8-7fbbf9299568';
  UPDATE public.profiles SET father_id = '561b3acf-c189-42df-a043-a71b23a66db6', mother_id = '0d9e6cb8-2762-43e7-9484-e95f0c805c00' WHERE id = 'f59d7efb-a78e-43c5-b8dd-a5e8f950e1c8';
  UPDATE public.profiles SET father_id = '8f88e49a-ec0f-4dc3-b3f7-7df78812a179', mother_id = '7af0aea9-b5db-45c6-895e-9be45d23d912' WHERE id = '5a43a07e-b919-46de-8323-ba86fedf4761';
  UPDATE public.profiles SET father_id = '8f88e49a-ec0f-4dc3-b3f7-7df78812a179', mother_id = '7af0aea9-b5db-45c6-895e-9be45d23d912' WHERE id = '74e44a10-188f-4bf3-b472-d6e7df3a8624';
  UPDATE public.profiles SET father_id = 'ccd0ea9f-27ee-4b51-baf9-91dde838fc74', mother_id = '5a68b362-ec39-4f09-bad6-f3979df4f26f' WHERE id = 'dbce97e9-87ec-4ad0-bf1b-3c9658e12a64';
  UPDATE public.profiles SET father_id = 'c6c48ae8-5e93-48f0-9c6c-78cff50af3fc', mother_id = '073d41aa-5378-4485-951b-416f1d95ca00' WHERE id = 'd6cd92cb-2f00-4a55-9d57-3728c97bd891';
  UPDATE public.profiles SET father_id = '662f5324-14e5-45c5-9fa4-64347433563e', mother_id = '430f3eaf-1cc6-4153-b8ee-ae9a663c9850' WHERE id = 'a4608825-a37c-4ae3-acc4-8858dc619445';
  UPDATE public.profiles SET father_id = '1b61df57-60e3-43d1-b202-94778723bc75', mother_id = 'fdcf0ae3-7f3a-47b3-8d1a-fc06da14c839' WHERE id = '17e5683d-f9cf-4140-b2fc-68de891bd73b';
  UPDATE public.profiles SET father_id = '1b61df57-60e3-43d1-b202-94778723bc75', mother_id = 'fdcf0ae3-7f3a-47b3-8d1a-fc06da14c839' WHERE id = '3a448701-8441-4d90-8e67-108fc015529a';
  UPDATE public.profiles SET father_id = '1b61df57-60e3-43d1-b202-94778723bc75', mother_id = 'fdcf0ae3-7f3a-47b3-8d1a-fc06da14c839' WHERE id = '022b9115-20a1-4caf-b681-c3a12ef2c7c7';
  UPDATE public.profiles SET father_id = '9a490b28-fc1e-48ff-a3bd-4992e140d86e', mother_id = 'f4d10dc6-ebc9-4b00-807b-f4cc2892c2f7' WHERE id = '866d8229-8c00-41f9-ba7b-4fd00815a269';
  UPDATE public.profiles SET father_id = '9a490b28-fc1e-48ff-a3bd-4992e140d86e', mother_id = 'f4d10dc6-ebc9-4b00-807b-f4cc2892c2f7' WHERE id = 'd784b85e-07ff-4d6f-854c-a6df449b89db';
  UPDATE public.profiles SET father_id = '9a490b28-fc1e-48ff-a3bd-4992e140d86e', mother_id = 'f4d10dc6-ebc9-4b00-807b-f4cc2892c2f7' WHERE id = 'adb66eff-e72a-49ff-a3dc-ed77e2402db8';
  UPDATE public.profiles SET father_id = '79c3061a-ab1c-4323-95c0-0ddd57363136', mother_id = '7f0ba630-de60-48a2-9790-eb49c3cbb491' WHERE id = 'ca99344f-fa39-4e49-8631-281be52d104f';
  UPDATE public.profiles SET father_id = '015ab95a-a385-4946-a881-ca4b90535a56', mother_id = '3d388ff0-fdc3-41c0-82be-1e049ecf3243' WHERE id = 'c1058965-4808-47b6-a086-aab424f8535d';
  UPDATE public.profiles SET father_id = '015ab95a-a385-4946-a881-ca4b90535a56', mother_id = '3d388ff0-fdc3-41c0-82be-1e049ecf3243' WHERE id = '03f19c42-e695-463b-a655-77d9e589ab66';
  UPDATE public.profiles SET father_id = 'b3e686c7-d8b2-44ba-85e6-0d6799516e05', mother_id = '50b820e6-22d8-4e42-a464-2f08961ff281' WHERE id = 'ad3c0fd5-eafa-4460-89a7-97d6df89f4ce';
  UPDATE public.profiles SET father_id = 'f7d6b730-0eed-4faf-813e-be3d957a14db', mother_id = '4b6206c5-3c01-4680-8a2f-945a3368b1d4' WHERE id = 'c0ae842e-8d55-4a77-bd4a-f34ce93d89e5';
  UPDATE public.profiles SET father_id = 'f7d6b730-0eed-4faf-813e-be3d957a14db', mother_id = '4b6206c5-3c01-4680-8a2f-945a3368b1d4' WHERE id = '64720955-91e5-4cd5-ac48-e5ca6713a748';
  UPDATE public.profiles SET father_id = '78d9680b-3c8c-41ba-b799-e20732a7918c', mother_id = '3b884b6c-2405-47a7-983e-8cde14f0ba83' WHERE id = 'da472999-6685-4cc5-8699-a40b231ca2b5';
  UPDATE public.profiles SET father_id = '78d9680b-3c8c-41ba-b799-e20732a7918c', mother_id = '3b884b6c-2405-47a7-983e-8cde14f0ba83' WHERE id = '948f0b08-9fcf-42b5-831c-f05cd18bfc0a';
  UPDATE public.profiles SET father_id = '08ef9000-1c52-4793-bd87-0c167488b3aa', mother_id = 'bd7e2fed-f2fe-455f-907a-906ef39fdfe9' WHERE id = '14de28e4-dd68-45a7-aab6-ae7b94b5ff4d';
  UPDATE public.profiles SET father_id = '1a4e50c4-5477-4cec-8658-26312515e0ad', mother_id = '8bd5f869-cee2-4a71-9d8b-bb0567852f18' WHERE id = 'e20afd91-0738-4109-b438-acd66c81b002';
  UPDATE public.profiles SET father_id = '4e1a9e77-49a4-4e7b-9821-7bed1e7fb2f6', mother_id = '9f3741ea-5dbf-41e2-8eb7-aebd063b57db' WHERE id = 'cc6c1ced-7711-459e-a8d5-967b19ab23af';
  UPDATE public.profiles SET father_id = '14f3b34a-e342-4671-9361-cf94df252307', mother_id = '9897c43c-b42c-41bd-8aac-c9d7421ee709' WHERE id = '4f6f32ea-1a00-4ad0-849d-44554999f7ee';
  UPDATE public.profiles SET father_id = NULL, mother_id = '57f1ac15-5134-47ca-9391-b5d2e92ed1a2' WHERE id = '88de95c3-14d7-4dc7-b352-8731636ee646';
  UPDATE public.profiles SET father_id = NULL, mother_id = '57f1ac15-5134-47ca-9391-b5d2e92ed1a2' WHERE id = 'b7d8fdb9-0dec-4003-9217-ab813b1cb202';
  UPDATE public.profiles SET father_id = '78ea7139-0198-4e15-ae8c-66fbbb02223f', mother_id = '4fdb878a-77fa-4c84-8592-8bf62e14926c' WHERE id = '0853ab00-2c98-4acd-9683-4e6949baf7ac';
  UPDATE public.profiles SET father_id = '78ea7139-0198-4e15-ae8c-66fbbb02223f', mother_id = '4fdb878a-77fa-4c84-8592-8bf62e14926c' WHERE id = '2f8e1196-6cfe-4645-8e6a-6d4ff6145a6f';
  UPDATE public.profiles SET father_id = '78ea7139-0198-4e15-ae8c-66fbbb02223f', mother_id = '4fdb878a-77fa-4c84-8592-8bf62e14926c' WHERE id = 'c5444ebd-7625-474a-be16-752a99b92547';
  UPDATE public.profiles SET father_id = '93463416-9acf-4f4e-a207-1749c61bb6df', mother_id = '092dc14f-d240-44ba-9003-d73153529ea8' WHERE id = '40b44977-84ba-4abf-a8ab-e824ec99ada8';
  UPDATE public.profiles SET father_id = '93463416-9acf-4f4e-a207-1749c61bb6df', mother_id = '092dc14f-d240-44ba-9003-d73153529ea8' WHERE id = 'a22ce02d-c4a5-4aff-a3bb-f328213cf6a4';
  UPDATE public.profiles SET father_id = '40133761-8eed-4725-be4f-81855655d743', mother_id = '0f70a77f-c13e-42e2-a983-d285cf37ab17' WHERE id = '961ca175-7d3f-4580-b4ea-6dabcd95d0bd';
  UPDATE public.profiles SET father_id = '873d4980-4e53-46f5-a03e-44d9dbdfdd2e', mother_id = '7f83e971-59c3-4e51-934c-b2de7ba5f9e0' WHERE id = '52db9144-a9cc-4371-b5de-4eb9c53c6608';
  UPDATE public.profiles SET father_id = '036b3af9-a904-47f2-997c-2dccd58f7241', mother_id = '3ea7012f-7343-418d-9c90-143f5e33a442' WHERE id = 'dca8e36f-1bd4-4d52-ab39-470badcc7370';
  UPDATE public.profiles SET father_id = '036b3af9-a904-47f2-997c-2dccd58f7241', mother_id = '3ea7012f-7343-418d-9c90-143f5e33a442' WHERE id = '6c80b073-c492-4b0a-8dca-805405508524';
  UPDATE public.profiles SET father_id = '036b3af9-a904-47f2-997c-2dccd58f7241', mother_id = '3ea7012f-7343-418d-9c90-143f5e33a442' WHERE id = '2a3d6176-4538-4daf-b1ab-7b44f0264f10';
  UPDATE public.profiles SET father_id = '22fec886-6757-4c6c-ad27-ffc82323b05a', mother_id = 'b930850a-f8ed-40fc-afd1-4464468428d8' WHERE id = 'f15eaf56-a583-4688-9b7d-ea55083e17e1';
  UPDATE public.profiles SET father_id = '2978482f-65e5-4b56-bd58-b8188fe34702', mother_id = 'be4a7b12-50be-4973-a1e2-8afe22640313' WHERE id = 'b88d5be8-1469-4a92-8351-97d69dd1d503';
  UPDATE public.profiles SET father_id = '2978482f-65e5-4b56-bd58-b8188fe34702', mother_id = 'be4a7b12-50be-4973-a1e2-8afe22640313' WHERE id = '9cd33887-5109-4879-ac3e-d07a7f1c4f07';
  UPDATE public.profiles SET father_id = '47cab605-b882-48b1-bdd5-242a94e5b48d', mother_id = 'ebb40e70-f04f-4b6b-93d6-fa1b4b675e86' WHERE id = 'f88957e2-40ff-44bf-8462-f926d1863713';
  UPDATE public.profiles SET father_id = NULL, mother_id = '6fda41bb-d790-477a-817f-781f4882fbf7' WHERE id = '15a74521-77fd-4113-a175-865599cac9a4';
  UPDATE public.profiles SET father_id = NULL, mother_id = '6fda41bb-d790-477a-817f-781f4882fbf7' WHERE id = '593ed824-0634-47b5-bcd5-22c28de664a3';
  UPDATE public.profiles SET father_id = '7071838f-2bfe-4c05-b585-5ccca33e77e9', mother_id = 'e71b6dba-a1a1-4166-a749-2a32ee049a8f' WHERE id = 'f4dcb992-67e6-4d8d-a6d9-c150bc6423b5';
  UPDATE public.profiles SET father_id = '036b14a5-5007-4d96-91f8-5f2437c041b2', mother_id = 'abea98a8-bc87-42f1-9d41-318bc3669b51' WHERE id = 'a0795e67-7133-4808-b2ec-811a9dced93d';
  UPDATE public.profiles SET father_id = '4c8540ba-a101-4fee-9b5d-1c8a1276486e', mother_id = '6949ca7e-ad93-4433-942b-fd5b2e90d2e3' WHERE id = '9ffaccdb-de15-4c85-98a9-ebd116452557';
  UPDATE public.profiles SET father_id = '4c8540ba-a101-4fee-9b5d-1c8a1276486e', mother_id = '6949ca7e-ad93-4433-942b-fd5b2e90d2e3' WHERE id = '3a0adc98-e550-4e23-b615-d2b43e63d257';
  UPDATE public.profiles SET father_id = 'bbc02073-1866-45b1-9fb8-6fe7c61ca0be', mother_id = '210bab9b-dbb9-4db3-a407-9c9ddb9bd2dc' WHERE id = '905e94e4-4237-4c2a-a6f6-3dfee2cae6a7';
  UPDATE public.profiles SET father_id = 'dc8037ee-f406-477d-b28c-6fb6f9afbff7', mother_id = '42ea1e02-457a-41c6-b0c0-e3025593bd34' WHERE id = 'a10eac0a-c9dd-4828-96e5-9ede89d724a0';
  UPDATE public.profiles SET father_id = '2ff70477-42b4-4ea3-a2c0-ccc751fb1a45', mother_id = '5568cae3-c3b2-453f-8f9d-8d3fd2edf1b1' WHERE id = '4d0a61d7-0b72-47e5-84a7-db4ab453535b';
  UPDATE public.profiles SET father_id = '2ff70477-42b4-4ea3-a2c0-ccc751fb1a45', mother_id = '5568cae3-c3b2-453f-8f9d-8d3fd2edf1b1' WHERE id = 'd74f145d-940a-48e9-8536-0c9b5d7e4ed1';
  UPDATE public.profiles SET father_id = '8e0f5221-e0b6-4c94-ae6f-6d6b603c35b6', mother_id = '7b4d3c67-be95-4f03-a309-b14d0d991f47' WHERE id = 'cccca244-cd48-4d7c-896e-a8768568c4c4';
  UPDATE public.profiles SET father_id = 'f2d55038-d517-4255-bb30-fb7fc41111cc', mother_id = '45f8b398-205a-49ab-82ad-ea77c09dac9e' WHERE id = '0b7e15b7-aab1-427f-9e66-cc41493312bb';
  UPDATE public.profiles SET father_id = 'ce4cbb2c-5a96-4cc6-8d73-555e1c57338c', mother_id = NULL WHERE id = 'a201aab3-50a2-414a-9c2d-395c3100a76c';
  UPDATE public.profiles SET father_id = 'ce4cbb2c-5a96-4cc6-8d73-555e1c57338c', mother_id = NULL WHERE id = '56dd7459-d8e2-401f-b9e4-58a8cd568b81';
  UPDATE public.profiles SET father_id = '452eb67a-5995-4510-97a6-5544f7efa153', mother_id = '1b52b8d2-ccd1-4507-bed0-bb6b74c7bf67' WHERE id = 'bb3dfbc4-3cbc-4df5-960e-7de375efffdc';
  UPDATE public.profiles SET father_id = '7b8b10dc-c378-4c75-9a81-737f77eb2cc4', mother_id = '0a5a333c-97f7-4951-80f0-ee95c9eaab1a' WHERE id = '5b54f84a-63c0-42d0-85f0-951641871d32';
  UPDATE public.profiles SET father_id = '7e116062-a746-42b8-be49-04c155e81074', mother_id = '3fa054a5-0dd0-444c-a4d9-913e4a9dd8c3' WHERE id = '4bdb4f32-c0e1-4256-96ef-042237d23b56';
  UPDATE public.profiles SET father_id = '7e116062-a746-42b8-be49-04c155e81074', mother_id = '3fa054a5-0dd0-444c-a4d9-913e4a9dd8c3' WHERE id = '0e8c00fa-80b6-431d-bac3-9ad74c6bd0d5';
  UPDATE public.profiles SET father_id = 'bd95dcbd-5132-41f5-863a-249d8f71ddbc', mother_id = '8aafef63-ece5-4d6f-8e43-5fa47d2bda7a' WHERE id = '87a72534-b5cd-4f95-b458-dd8c65b757d9';
  UPDATE public.profiles SET father_id = '2da55b2a-63c8-48bc-9296-19db1b203e42', mother_id = '5baffafa-dde2-45f5-bd4a-964fd5c71fd8' WHERE id = '63781cec-1f3f-4a35-86c3-e6238adf113f';
  UPDATE public.profiles SET father_id = '2da55b2a-63c8-48bc-9296-19db1b203e42', mother_id = '5baffafa-dde2-45f5-bd4a-964fd5c71fd8' WHERE id = '4b09cbdb-fb99-4d31-aea4-2a7f7c1f3e45';
  UPDATE public.profiles SET father_id = 'c2133747-544d-4787-a3bd-0f473e9248ea', mother_id = '6c6a73e0-86b6-44f8-910a-7f50b0bfc502' WHERE id = '3f0b7fd5-fdd5-4437-816c-a5a251bff674';
  UPDATE public.profiles SET father_id = 'b5b7bb42-7e19-4bde-96c3-55783807b875', mother_id = '34460ba9-08c2-446f-a28c-1b4e26d3d085' WHERE id = '538b1ab0-3027-4264-a1b5-c19d1bcbecbc';
  UPDATE public.profiles SET father_id = '301313cb-9edf-4df9-880c-861d0bdf8684', mother_id = '77535d8c-a688-4192-888d-99456c03d219' WHERE id = '8a434afa-8709-4e7a-a201-3e0518ca6033';
  UPDATE public.profiles SET father_id = '301313cb-9edf-4df9-880c-861d0bdf8684', mother_id = '77535d8c-a688-4192-888d-99456c03d219' WHERE id = 'bad3f0d4-29b5-499b-8a82-70ce9dcae94e';
  UPDATE public.profiles SET father_id = '7daaa1ca-a3b2-4234-945f-f6c2e4bd1741', mother_id = 'c41ab840-a4a1-46f8-910b-b89458465c50' WHERE id = '06973d28-aa7e-4c2e-ae1b-6efcb1bf11ab';
  UPDATE public.profiles SET father_id = '7daaa1ca-a3b2-4234-945f-f6c2e4bd1741', mother_id = 'c41ab840-a4a1-46f8-910b-b89458465c50' WHERE id = '65d0f5a0-56bc-44e1-aad6-dae19638a5b6';
  UPDATE public.profiles SET father_id = 'ff3860fa-07b0-49ff-b045-8dc21b761c9a', mother_id = 'b0ec4c8e-d920-4c8a-9139-7a65d546ed25' WHERE id = 'c7f9f1d8-67c4-4c2e-bd28-2dd3324961f0';
  UPDATE public.profiles SET father_id = 'ff3860fa-07b0-49ff-b045-8dc21b761c9a', mother_id = 'b0ec4c8e-d920-4c8a-9139-7a65d546ed25' WHERE id = '85611862-60ff-4126-9f56-20c089b8f1a9';
  UPDATE public.profiles SET father_id = 'ff3860fa-07b0-49ff-b045-8dc21b761c9a', mother_id = 'b0ec4c8e-d920-4c8a-9139-7a65d546ed25' WHERE id = '41884764-c095-48ed-815e-a929857df671';
  UPDATE public.profiles SET father_id = 'ff3860fa-07b0-49ff-b045-8dc21b761c9a', mother_id = 'b0ec4c8e-d920-4c8a-9139-7a65d546ed25' WHERE id = '26a40082-8ea7-407d-80e7-8abaadcd4dd0';
  UPDATE public.profiles SET father_id = 'bac793b5-2770-4659-a5c2-dac9bfcc55c5', mother_id = '8c252007-45c9-4ba7-a90a-8f6c6032f9ba' WHERE id = '126e5cbd-2717-4bee-9e8c-4950a7768a72';
  UPDATE public.profiles SET father_id = '6ac5e9c4-075e-4ef4-8244-30537a83235f', mother_id = 'fcd20f02-61ee-487f-b082-37216166fa75' WHERE id = 'c0a16c6d-1f2a-4df1-9582-1a4bb4bea225';

  -- ==========================================================================
  -- 7. ATUALIZAR DISCIPULADO (discipler_id)
  -- ==========================================================================

  UPDATE public.profiles SET discipler_id = 'dc7b515b-9d74-4d35-be95-4935bd244275' WHERE id = '72d015f6-7aa4-493d-a2de-960214f037db';
  UPDATE public.profiles SET discipler_id = '219a120e-ff58-405f-83ba-933279e08896' WHERE id = '044a0d94-2dc6-40e1-bf37-1812bcae79aa';
  UPDATE public.profiles SET discipler_id = 'e81475a5-a09d-4269-bae2-4b5f9009b7e8' WHERE id = '2c1a15d7-517a-4b42-b5ac-54230fe4769e';
  UPDATE public.profiles SET discipler_id = '219a120e-ff58-405f-83ba-933279e08896' WHERE id = '9396e709-343e-4ed7-888f-a74fa83910ef';
  UPDATE public.profiles SET discipler_id = 'e81475a5-a09d-4269-bae2-4b5f9009b7e8' WHERE id = '28e97996-fd77-4f65-80f7-c1aeaf0e4e28';
  UPDATE public.profiles SET discipler_id = '219a120e-ff58-405f-83ba-933279e08896' WHERE id = 'b6387dbd-5fa7-48de-a288-0fb583737dcf';
  UPDATE public.profiles SET discipler_id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3' WHERE id = '2ba3cd78-bb32-497c-bb99-6e4711657460';
  UPDATE public.profiles SET discipler_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1' WHERE id = 'c217d85b-3422-4198-86f8-2ca90b6ca039';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = '3215a739-9748-4ded-bf1b-60e7a15dcf3a';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = '6000aaf3-1674-4418-aa81-29543143fe6a';
  UPDATE public.profiles SET discipler_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1' WHERE id = '45658447-a13b-4a51-9ec3-0a9e584043bf';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = 'cde1c6ad-2f8b-4543-859a-defd8b5d50e9';
  UPDATE public.profiles SET discipler_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1' WHERE id = '8ca46ee3-feb4-48de-b7ff-07717d68e3fe';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = '6baed437-e3fe-4de6-b86f-049c801dce3c';
  UPDATE public.profiles SET discipler_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1' WHERE id = 'ec051e64-ffce-4f37-bfb7-c2f6e29bfdd1';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = '4477f189-e461-4d08-b3c9-caf05f98c772';
  UPDATE public.profiles SET discipler_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1' WHERE id = 'afd19ec0-75da-4df1-8b60-d9402e912d46';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = '337bdc08-6b2c-41f1-ac84-937e2c960b8e';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = 'de7548ca-68cd-4c33-b95d-70f29fc9b991';
  UPDATE public.profiles SET discipler_id = 'dc7b515b-9d74-4d35-be95-4935bd244275' WHERE id = '98a95ad8-74e8-49f0-a2d4-d4eb6df0e7b5';
  UPDATE public.profiles SET discipler_id = 'c217d85b-3422-4198-86f8-2ca90b6ca039' WHERE id = 'd8ca5b4e-0b42-40eb-aab8-e71a4f99f026';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = '649b0f27-ede0-445c-9afa-c39525fe13b1';
  UPDATE public.profiles SET discipler_id = 'c217d85b-3422-4198-86f8-2ca90b6ca039' WHERE id = '7e4e09e8-1878-4ea2-9355-30e55ddab65b';
  UPDATE public.profiles SET discipler_id = 'a721678f-add7-4f85-bcff-c64d77a072b6' WHERE id = '31dd4142-d016-460e-a53a-a074387887ba';
  UPDATE public.profiles SET discipler_id = '45b5215a-e43e-40ee-bd5e-e31cace3b45a' WHERE id = 'e050cb39-15bb-4fac-bc7c-0ddb41541a66';
  UPDATE public.profiles SET discipler_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = '0f37069a-c847-441d-8700-503df3a5eb80';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = 'f91068e8-62ed-46ec-bb69-2bf6287f9300';
  UPDATE public.profiles SET discipler_id = '5d89236b-d7c7-491b-b8e6-cb2ceb8ec689' WHERE id = '50c1ab08-4157-453f-802e-661a290d5997';
  UPDATE public.profiles SET discipler_id = '7e4e09e8-1878-4ea2-9355-30e55ddab65b' WHERE id = '3e424427-4092-4d0b-8629-dbca904a6a4c';
  UPDATE public.profiles SET discipler_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = 'ee5e2ce1-8e47-4830-ab8d-f653905488e7';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = 'b3f5b24c-5db8-49b4-ac05-aa9a6a738d74';
  UPDATE public.profiles SET discipler_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = '576a3f90-bbd1-4fda-9f3a-92ad190cbf86';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = '11f14cf7-7af8-46d4-8a33-f7f4143ee2a6';
  UPDATE public.profiles SET discipler_id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3' WHERE id = 'a1946d29-22e6-41d0-9da8-bebc95854689';
  UPDATE public.profiles SET discipler_id = '76de4596-1505-4ec0-99cf-f7360d6d79a8' WHERE id = 'd2f9b13f-b958-42e3-827c-b76c25be11c4';
  UPDATE public.profiles SET discipler_id = 'a1946d29-22e6-41d0-9da8-bebc95854689' WHERE id = '76355d35-0af6-42ea-9bd4-e07342c58922';
  UPDATE public.profiles SET discipler_id = 'd2f9b13f-b958-42e3-827c-b76c25be11c4' WHERE id = 'e2c87c25-7ce7-4300-bd4f-6603391e49c1';
  UPDATE public.profiles SET discipler_id = 'caadae9c-21e3-4152-9989-1e5a6017743c' WHERE id = '7c3a7310-e6ce-4794-a8d6-99fab6ec20ed';
  UPDATE public.profiles SET discipler_id = '76f9712f-c596-4ae1-b2fc-48933a7ee2db' WHERE id = '5d89236b-d7c7-491b-b8e6-cb2ceb8ec689';
  UPDATE public.profiles SET discipler_id = 'cefd05cc-83a1-4c99-bb65-288ef974baa1' WHERE id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7';
  UPDATE public.profiles SET discipler_id = '0173059d-1312-42d5-834f-d5025499ee10' WHERE id = '7ee41141-243b-4aea-986a-6492efe1b957';
  UPDATE public.profiles SET discipler_id = '7c3a7310-e6ce-4794-a8d6-99fab6ec20ed' WHERE id = 'd63ea523-0aca-4bd1-a435-670780e75811';
  UPDATE public.profiles SET discipler_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = '574acf7b-47ec-4bea-8723-c4840814f094';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = 'c5da543a-8a8d-4c3b-881c-f0bb7ad86226';
  UPDATE public.profiles SET discipler_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = 'a721678f-add7-4f85-bcff-c64d77a072b6';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = '45b5215a-e43e-40ee-bd5e-e31cace3b45a';
  UPDATE public.profiles SET discipler_id = 'd63ea523-0aca-4bd1-a435-670780e75811' WHERE id = '264b7595-02db-4384-9d8d-b48e0a58d243';
  UPDATE public.profiles SET discipler_id = '7c3a7310-e6ce-4794-a8d6-99fab6ec20ed' WHERE id = 'a984e0dc-5082-401c-a77f-44b4146e15a2';
  UPDATE public.profiles SET discipler_id = '5d89236b-d7c7-491b-b8e6-cb2ceb8ec689' WHERE id = 'cb35fefc-3ec0-4a04-a645-abd3ca790a41';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = '029184ea-f254-46c5-8fd3-c485453c419d';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = 'e633481b-f0a6-40c8-a1f1-07a884356d21';
  UPDATE public.profiles SET discipler_id = 'd63ea523-0aca-4bd1-a435-670780e75811' WHERE id = 'b3e96f4c-be3b-49c3-abe5-7e21fa7762fb';
  UPDATE public.profiles SET discipler_id = '66f5d3bf-5edb-465b-a05c-930ba66d2bf1' WHERE id = 'efa92820-2094-4a14-bfd1-6ac951ee17f9';
  UPDATE public.profiles SET discipler_id = '42ea1e02-457a-41c6-b0c0-e3025593bd34' WHERE id = '66f5d3bf-5edb-465b-a05c-930ba66d2bf1';
  UPDATE public.profiles SET discipler_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = '4c4a5960-daaf-489c-827c-d7cd17df72e9';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = 'ecb2345b-6190-4a59-aadc-3c1e04805a20';
  UPDATE public.profiles SET discipler_id = '7c3a7310-e6ce-4794-a8d6-99fab6ec20ed' WHERE id = '37960c1e-3656-4dd3-8af1-0e9a583c64cf';
  UPDATE public.profiles SET discipler_id = 'efa92820-2094-4a14-bfd1-6ac951ee17f9' WHERE id = '9c4a1f92-21f9-49a0-9179-8e49b42a8622';
  UPDATE public.profiles SET discipler_id = '45b5215a-e43e-40ee-bd5e-e31cace3b45a' WHERE id = '4c2012bc-398c-412b-a406-1f8fb4bca41d';
  UPDATE public.profiles SET discipler_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = '75f53908-d6f5-42cc-b6e4-4a2d18b013e7';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = '9b2410e1-37f9-4576-bc72-db72777f4f72';
  UPDATE public.profiles SET discipler_id = 'e7e9a6cf-790c-4ff2-a7eb-d1736b0127d7' WHERE id = '22994182-ebda-4aa6-b715-9c3296957181';
  UPDATE public.profiles SET discipler_id = '7ee41141-243b-4aea-986a-6492efe1b957' WHERE id = '10e831c3-be52-4828-8e7c-788b72ab0bbb';
  UPDATE public.profiles SET discipler_id = '219a120e-ff58-405f-83ba-933279e08896' WHERE id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3';
  UPDATE public.profiles SET discipler_id = 'e81475a5-a09d-4269-bae2-4b5f9009b7e8' WHERE id = '76de4596-1505-4ec0-99cf-f7360d6d79a8';
  UPDATE public.profiles SET discipler_id = '219a120e-ff58-405f-83ba-933279e08896' WHERE id = 'caadae9c-21e3-4152-9989-1e5a6017743c';
  UPDATE public.profiles SET discipler_id = 'e81475a5-a09d-4269-bae2-4b5f9009b7e8' WHERE id = '76f9712f-c596-4ae1-b2fc-48933a7ee2db';
  UPDATE public.profiles SET discipler_id = 'caadae9c-21e3-4152-9989-1e5a6017743c' WHERE id = '07366db0-2e6c-49f4-86f9-b349088bb253';
  UPDATE public.profiles SET discipler_id = '76f9712f-c596-4ae1-b2fc-48933a7ee2db' WHERE id = 'c8998cef-df63-4419-adb3-206f5d89d54d';
  UPDATE public.profiles SET discipler_id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3' WHERE id = 'b12c63df-b43b-4b7a-88a3-2807e1386001';
  UPDATE public.profiles SET discipler_id = '76de4596-1505-4ec0-99cf-f7360d6d79a8' WHERE id = '3833e775-9e8c-48db-a798-d50650bef65d';
  UPDATE public.profiles SET discipler_id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3' WHERE id = '7c2b1a5d-bcba-4922-af98-183f9472b70c';
  UPDATE public.profiles SET discipler_id = '76de4596-1505-4ec0-99cf-f7360d6d79a8' WHERE id = '93f65414-b584-49e3-a8b5-3503ce23ec79';
  UPDATE public.profiles SET discipler_id = '76de4596-1505-4ec0-99cf-f7360d6d79a8' WHERE id = '62adea3d-445c-4f03-9b68-bbdb001bff71';
  UPDATE public.profiles SET discipler_id = '76de4596-1505-4ec0-99cf-f7360d6d79a8' WHERE id = 'a0ce886c-0937-412d-aeb6-c8be08a15b50';
  UPDATE public.profiles SET discipler_id = '9eaf2bc6-45db-480f-b0ca-bc6a4c76f2e3' WHERE id = '139288c5-11cc-4712-9239-4e5775f33243';
  UPDATE public.profiles SET discipler_id = '76de4596-1505-4ec0-99cf-f7360d6d79a8' WHERE id = '91e1fb4f-feb0-43f0-a71e-30b942d66319';
  UPDATE public.profiles SET discipler_id = '56f6889f-ba1d-4ff5-b31d-933bd4b10105' WHERE id = '8e4e872f-e93b-498d-a6b9-551d06fa082a';
  UPDATE public.profiles SET discipler_id = 'a444b048-3e7a-4186-b33c-c0ee40fc96c3' WHERE id = 'a7585340-04b8-463e-98e0-950ea4d52906';
  UPDATE public.profiles SET discipler_id = 'a444b048-3e7a-4186-b33c-c0ee40fc96c3' WHERE id = '675e4992-d9b1-4da1-b147-f02eceed7e30';
  UPDATE public.profiles SET discipler_id = 'a444b048-3e7a-4186-b33c-c0ee40fc96c3' WHERE id = '68dc2482-0259-4b33-b20b-a2a338963033';
  UPDATE public.profiles SET discipler_id = '56f6889f-ba1d-4ff5-b31d-933bd4b10105' WHERE id = 'd0952ba5-945a-4479-94f1-9926b1a2fac9';
  UPDATE public.profiles SET discipler_id = '56f6889f-ba1d-4ff5-b31d-933bd4b10105' WHERE id = '8ff1f030-ad11-4cd3-9d2f-a8c178a48104';
  UPDATE public.profiles SET discipler_id = 'a444b048-3e7a-4186-b33c-c0ee40fc96c3' WHERE id = 'e0625d12-06b9-4fe4-b461-524a33fbef24';
  UPDATE public.profiles SET discipler_id = '56f6889f-ba1d-4ff5-b31d-933bd4b10105' WHERE id = '731f56d8-18f7-46da-b9f6-bc690b2ab426';
  UPDATE public.profiles SET discipler_id = '56f6889f-ba1d-4ff5-b31d-933bd4b10105' WHERE id = '742a5e06-ce24-4721-9aec-a7a26e96cdcc';
  UPDATE public.profiles SET discipler_id = 'a444b048-3e7a-4186-b33c-c0ee40fc96c3' WHERE id = 'e6d99983-4f42-4516-80f3-4acb7e274016';
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

  INSERT INTO public.event_waitlist (retreat_id, full_name, email, phone, travel_mode, notes, status)
  VALUES 
    (r_retreat_active, 'Tiago Guimarães Alencar', 'tiago.guimaraes@email.com', '(31) 98765-4321', 'carro_proprio', 'Disponível para dar carona a até 3 pessoas saindo do Barreiro', 'aguardando'),
    (r_retreat_active, 'Camila Rocha Viana', 'camila.rocha@email.com', '(31) 99123-4567', 'onibus_igreja', 'Depende de vaga no ônibus que sai do São Gabriel', 'chamado');


  -- ==========================================================================
  -- 14. INSCRIÇÕES OFICIAIS NOS RETIROS
  -- Nenhuma inscrição fictícia é gerada para discípulos das planilhas.
  -- Inscrição real de Gabriel Góes Braga no Retiro de Solteiros e Carnaval.
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
      'mandatory_birth_date', '1995-07-08',
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
      'birthDate', '1995-07-08'
    ),
    jsonb_build_object(
      'Nome Completo', 'Gabriel Góes Braga',
      'E-mail', 'ggoesbraga@gmail.com',
      'Telefone / WhatsApp', '(31) 99888-7777',
      'Sexo / Gênero', 'Masculino',
      'Cidade / Estado', 'Belo Horizonte / MG',
      'Data de Nascimento / Idade', '1995-07-08',
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
      'mandatory_birth_date', '1995-07-08'
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
      'birthDate', '1995-07-08'
    ),
    jsonb_build_object(
      'Nome Completo', 'Gabriel Góes Braga',
      'Sexo / Gênero', 'Masculino',
      'E-mail', 'ggoesbraga@gmail.com',
      'Telefone / WhatsApp', '(31) 99888-7777',
      'Data de Nascimento / Idade', '1995-07-08'
    )
  ) ON CONFLICT DO NOTHING;

END $$;
