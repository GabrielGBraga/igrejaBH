-- ============================================================================
-- SCRIPT DE SEEDING OFICIAL: IGREJA EM BELO HORIZONTE
-- Mapeamento Real de 35 Grupos Caseiros em 6 Setores Metropolitanos
-- Baseado em 'Igreja em BH - Grupos.csv'
-- ============================================================================

DO $$
DECLARE
  pwd_hash text := '$2a$06$XqL/cRckHcXJ1xzAYPKQUORulnZ8gYmOlK1FwEvihHPa7trFLTl9.'; -- 'senha123'
  gabriel_id uuid := extensions.uuid_generate_v4();
  gabriel_auth_id uuid := extensions.uuid_generate_v4();

  -- IDs de Setores
  sec_sg_id uuid := extensions.uuid_generate_v4();
  sec_vn_id uuid := extensions.uuid_generate_v4();
  sec_sl_id uuid := extensions.uuid_generate_v4();
  sec_oe_id uuid := extensions.uuid_generate_v4();
  sec_bc_id uuid := extensions.uuid_generate_v4();
  sec_fl_id uuid := extensions.uuid_generate_v4();

  -- Variáveis auxiliares de grupos e membros
  cur_gc_id uuid;
  cur_sec_id uuid;
  cur_l1_id uuid;
  cur_l2_id uuid;
  temp_p_id uuid;

  -- IDs de Recursos de Estudo
  m_res_id1 uuid := extensions.uuid_generate_v4();
  m_res_id2 uuid := extensions.uuid_generate_v4();
  m_res_id3 uuid := extensions.uuid_generate_v4();
  m_res_id4 uuid := extensions.uuid_generate_v4();
  m_res_id5 uuid := extensions.uuid_generate_v4();
  m_res_id6 uuid := extensions.uuid_generate_v4();
  m_res_id7 uuid := extensions.uuid_generate_v4();
  m_res_id8 uuid := extensions.uuid_generate_v4();
  m_res_id9 uuid := extensions.uuid_generate_v4();
  m_res_id10 uuid := extensions.uuid_generate_v4();

  -- IDs de Trilhas de Estudo
  study_id1 uuid := extensions.uuid_generate_v4();
  study_id2 uuid := extensions.uuid_generate_v4();
  study_id3 uuid := extensions.uuid_generate_v4();

  -- IDs de Passos de Estudo
  step_id1 uuid := extensions.uuid_generate_v4();
  step_id2 uuid := extensions.uuid_generate_v4();
  step_id3 uuid := extensions.uuid_generate_v4();
  step_id4 uuid := extensions.uuid_generate_v4();
  step_id5 uuid := extensions.uuid_generate_v4();
  step_id6 uuid := extensions.uuid_generate_v4();
  step_id7 uuid := extensions.uuid_generate_v4();
  step_id8 uuid := extensions.uuid_generate_v4();

BEGIN
  -- ==========================================================================
  -- 1. LIMPEZA TOTAL ATÔMICA DAS TABELAS PÚBLICAS E DE AUTENTICAÇÃO
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
    public.form_submissions, 
    public.user_study_progress,
    public.study_notes,
    public.event_coupons,
    public.event_waitlist
  CASCADE;

  DELETE FROM auth.users;

  -- ==========================================================================
  -- 2. CRIAÇÃO DOS 6 SETORES OFICIAIS
  -- ==========================================================================
  INSERT INTO public.sectors (id, name, created_at) VALUES 
    (sec_sg_id, 'São Gabriel/Pampulha', now()),
    (sec_vn_id, 'Venda Nova/Neves', now()),
    (sec_sl_id, 'Santa Luzia', now()),
    (sec_oe_id, 'Oeste', now()),
    (sec_bc_id, 'Betim/Contagem', now()),
    (sec_fl_id, 'Fora da Localidade', now());

  -- ==========================================================================
  -- 3. CRIAÇÃO DOS 35 GRUPOS CASEIROS E DOS PERFIS DE LÍDERES E NÚCLEOS
  -- ==========================================================================

  -- ------------------------------------------------------------------------
  -- GC 101: Solimões - BH (Setor: São Gabriel/Pampulha)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sg_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 101 - Solimões - BH (Bairro Solimões)', NULL, NULL, -19.8392, -43.9185, 3, '19:30:00', now()
  );

  -- Líder 1: Flávio
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Flávio', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Solimões', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 102: Heliópolis - BH (Setor: São Gabriel/Pampulha)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sg_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 102 - Heliópolis - BH (Bairro Heliópolis)', NULL, NULL, -19.8425, -43.9482, 3, '19:30:00', now()
  );

  -- Líder 1: Fernando
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Fernando', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Heliópolis', 'BH'
  );

  -- Líder 2: Samuel
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Samuel', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Heliópolis', 'BH'
  );

  -- Núcleo: André
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'André', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Heliópolis', 'BH'
  );

  -- Núcleo: Daniel
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Daniel', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Heliópolis', 'BH'
  );

  -- Núcleo: Ricardo
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Ricardo', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Heliópolis', 'BH'
  );

  -- Núcleo: Rodrigo
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Rodrigo', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Heliópolis', 'BH'
  );

  -- Perfil Oficial do Desenvolvedor: Gabriel Góes Braga (GC 102)
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, cpf, phone, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    gabriel_id, 'Gabriel Góes Braga', 'ggoesbraga@gmail.com', gabriel_auth_id, 'M', '132.507.246-02', '(31) 99888-7777', true, true, false, false, true, cur_gc_id, 'Heliópolis', 'BH'
  );

  INSERT INTO auth.users (
    id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change
  ) VALUES (
    gabriel_auth_id,
    '00000000-0000-0000-0000-000000000000',
    'ggoesbraga@gmail.com',
    pwd_hash,
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', 'Gabriel Góes Braga', 'cpf', '132.507.246-02'),
    now(),
    now(),
    'authenticated',
    'authenticated',
    '', '', '', ''
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 103: São Gabriel - BH (Setor: São Gabriel/Pampulha)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sg_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 103 - São Gabriel - BH (Região São Gabriel / Pampulha)', NULL, NULL, -19.858, -43.916, 3, '19:30:00', now()
  );

  -- Líder 1: Carlos Eduardo
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Carlos Eduardo', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'São Gabriel', 'BH'
  );

  -- Líder 2: Guilherme
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Guilherme', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'São Gabriel', 'BH'
  );

  -- Núcleo: Bruno
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Bruno', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'São Gabriel', 'BH'
  );

  -- Núcleo: Flávio
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Flávio', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'São Gabriel', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 104: Santa Amélia - BH (Setor: São Gabriel/Pampulha)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sg_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 104 - Santa Amélia - BH (Rua Pioneiros da Paz, Santa Amélia / Rua Hildebrando de Oliveira 65, Copacabana)', NULL, NULL, -19.8361, -43.9724, 3, '19:30:00', now()
  );

  -- Líder 1: Eduardo Lopes
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Eduardo Lopes', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Santa Amélia', 'BH'
  );

  -- Núcleo: Paulo Henrique
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Paulo Henrique', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Santa Amélia', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 105: Jardim Vitória - BH (Setor: São Gabriel/Pampulha)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sg_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 105 - Jardim Vitória - BH (Bairro Vitória / Jardim Vitória)', NULL, NULL, -19.8456, -43.8891, 3, '19:30:00', now()
  );

  -- Líder 1: Ademir
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Ademir', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Jardim Vitória', 'BH'
  );

  -- Núcleo: Julião
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Julião', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Jardim Vitória', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 201: Santa Branca - BH (Setor: Venda Nova/Neves)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_vn_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 201 - Santa Branca - BH (Rua Norte, 42, Santa Branca - BH)', NULL, NULL, -19.8268, -43.9685, 3, '19:30:00', now()
  );

  -- Líder 1: Helder
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Helder', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Santa Branca', 'BH'
  );

  -- Núcleo: Francérgio
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Francérgio', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Santa Branca', 'BH'
  );

  -- Núcleo: Jonata
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Jonata', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Santa Branca', 'BH'
  );

  -- Núcleo: Kennedy
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Kennedy', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Santa Branca', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 202: Santa Branca - BH (Setor: Venda Nova/Neves)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_vn_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 202 - Santa Branca - BH (Rua São José do Jacuri, 135, B. Santa Branca)', NULL, NULL, -19.8245, -43.966, 3, '19:30:00', now()
  );

  -- Líder 1: Juarez
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Juarez', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Santa Branca', 'BH'
  );

  -- Núcleo: Argeu
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Argeu', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Santa Branca', 'BH'
  );

  -- Núcleo: Lora
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Lora', NULL, NULL, 'F', true, false, false, false, false, cur_gc_id, 'Santa Branca', 'BH'
  );

  -- Núcleo: Magela
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Magela', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Santa Branca', 'BH'
  );

  -- Núcleo: Mércia
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Mércia', NULL, NULL, 'F', true, false, false, false, false, cur_gc_id, 'Santa Branca', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 203: Maria Helena - Ribeirão das Neves (Setor: Venda Nova/Neves)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_vn_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 203 - Maria Helena - Ribeirão das Neves (Rua Lagoinhas, 64 (Casa do Marinho) - Maria Helena)', NULL, NULL, -19.7985, -44.0092, 3, '19:30:00', now()
  );

  -- Líder 1: Marinho
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Marinho', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Maria Helena', 'Ribeirão das Neves'
  );

  -- Núcleo: Marcone
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Marcone', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Maria Helena', 'Ribeirão das Neves'
  );

  -- Núcleo: Carlinho
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Carlinho', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Maria Helena', 'Ribeirão das Neves'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 204: Maria Helena - Ribeirão das Neves (Setor: Venda Nova/Neves)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_vn_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 204 - Maria Helena - Ribeirão das Neves (Rua Lagoinhas, 64 - Maria Helena)', NULL, NULL, -19.7992, -44.0105, 3, '19:30:00', now()
  );

  -- Líder 1: Luís
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Luís', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Maria Helena', 'Ribeirão das Neves'
  );

  -- Núcleo: Winter
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Winter', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Maria Helena', 'Ribeirão das Neves'
  );

  -- Núcleo: Fernanda
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Fernanda', NULL, NULL, 'F', true, false, false, false, false, cur_gc_id, 'Maria Helena', 'Ribeirão das Neves'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 205: Leblon - BH (Setor: Venda Nova/Neves)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_vn_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 205 - Leblon - BH (Rua Olga Pimenta Guimarães, 204 - Leblon)', NULL, NULL, -19.8115, -43.988, 3, '19:30:00', now()
  );

  -- Líder 1: Cleber
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Cleber', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Leblon', 'BH'
  );

  -- Núcleo: Sidney
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Sidney', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Leblon', 'BH'
  );

  -- Núcleo: Pedro
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Pedro', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Leblon', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 206: Sevilha B - Ribeirão das Neves (Setor: Venda Nova/Neves)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_vn_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 206 - Sevilha B - Ribeirão das Neves (Rua São João Del Rei, 270, Sevilha B)', NULL, NULL, -19.7695, -44.0812, 3, '19:30:00', now()
  );

  -- Líder 1: Douglas
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Douglas', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Sevilha B', 'Ribeirão das Neves'
  );

  -- Líder 2: Dimas
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Dimas', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Sevilha B', 'Ribeirão das Neves'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 207: Areias - Ribeirão das Neves (Setor: Venda Nova/Neves)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_vn_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 207 - Areias - Ribeirão das Neves (Rodízio (Areias / Morro Alto))', NULL, NULL, -19.782, -43.985, 3, '19:30:00', now()
  );

  -- Líder 1: Jaime
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Jaime', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Areias', 'Ribeirão das Neves'
  );

  -- Líder 2: Wagner
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Wagner', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Areias', 'Ribeirão das Neves'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 301: Santa Matilde - Santa Luzia (Setor: Santa Luzia)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sl_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 301 - Santa Matilde - Santa Luzia (Rua Geraldo Ferreira Rabelo, 169, Santa Matilde)', NULL, NULL, -19.7668, -43.8582, 3, '19:30:00', now()
  );

  -- Líder 1: Davi Cunha
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Davi Cunha', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Santa Matilde', 'Santa Luzia'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 302: Lagoa Santa (Setor: Santa Luzia)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sl_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 302 - Lagoa Santa (Lagoa Santa)', NULL, NULL, -19.6328, -43.8906, 3, '19:30:00', now()
  );

  -- Líder 1: Neto
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Neto', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Lagoa Santa', 'Belo Horizonte'
  );

  -- Núcleo: Lincon
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Lincon', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Lagoa Santa', 'Belo Horizonte'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 303: São Benedito - Santa Luzia (Setor: Santa Luzia)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sl_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 303 - São Benedito - Santa Luzia (Bairro São Benedito)', NULL, NULL, -19.7825, -43.9145, 3, '19:30:00', now()
  );

  -- Líder 1: Fernando
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Fernando', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'São Benedito', 'Santa Luzia'
  );

  -- Núcleo: Paulo
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Paulo', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'São Benedito', 'Santa Luzia'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 304: Fazendinha do Baú - Santa Luzia (Setor: Santa Luzia)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sl_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 304 - Fazendinha do Baú - Santa Luzia (Rua Presidente Roosevelt, 1107 - Fazendinha do Baú - Santa Luzia)', NULL, NULL, -19.7755, -43.872, 3, '19:30:00', now()
  );

  -- Líder 1: Ricardo
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Ricardo', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Fazendinha do Baú', 'Santa Luzia'
  );

  -- Líder 2: Jesus
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Jesus', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Fazendinha do Baú', 'Santa Luzia'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 305: Córrego das Calçadas - Santa Luzia (Setor: Santa Luzia)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sl_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 305 - Córrego das Calçadas - Santa Luzia (Av. Engenheiro Felipe Gabrich, nº 734, Córrego das Calçadas, Santa Luzia)', NULL, NULL, -19.759, -43.851, 3, '19:30:00', now()
  );

  -- Líder 1: Roberto
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Roberto', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Córrego das Calçadas', 'Santa Luzia'
  );

  -- Líder 2: Álvaro
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Álvaro', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Córrego das Calçadas', 'Santa Luzia'
  );

  -- Líder 3: Rodrigo
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Rodrigo', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Córrego das Calçadas', 'Santa Luzia'
  );

  -- Núcleo: Álvaro
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Álvaro', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Córrego das Calçadas', 'Santa Luzia'
  );

  -- Núcleo: Rodrigo
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Rodrigo', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Córrego das Calçadas', 'Santa Luzia'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 306: Cristina B - Santa Luzia (Setor: Santa Luzia)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_sl_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 306 - Cristina B - Santa Luzia (Rua Mila Bernardina da Rocha, 85, Cristina B, Santa Luzia/MG)', NULL, NULL, -19.7762, -43.9248, 3, '19:30:00', now()
  );

  -- Líder 1: Maurício
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Maurício', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Cristina B', 'Santa Luzia'
  );

  -- Líder 2: Diogo
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Diogo', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Cristina B', 'Santa Luzia'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 401: Novo Tirol - BH (Setor: Oeste)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_oe_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 401 - Novo Tirol - BH (Rua Macadâmia, 168, Novo Tirol - BH)', NULL, NULL, -19.9985, -44.0315, 3, '19:30:00', now()
  );

  -- Líder 1: Júlio
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Júlio', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Novo Tirol', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 402: Milionários - BH (Setor: Oeste)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_oe_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 402 - Milionários - BH (Rua dos Atleticanos - Milionários)', NULL, NULL, -19.981, -43.9965, 3, '19:30:00', now()
  );

  -- Líder 1: Rafael
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Rafael', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Milionários', 'BH'
  );

  -- Líder 2: Shibas
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Shibas', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Milionários', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 403: Tropical / Quintas do Jacuba - Contagem (Setor: Oeste)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_oe_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 403 - Tropical / Quintas do Jacuba - Contagem (Estrada Chico Mendes, 900 - Quintas do Jacuba - Contagem)', NULL, NULL, -19.9265, -44.115, 3, '19:30:00', now()
  );

  -- Líder 1: Claudio
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Claudio', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Tropical / Quintas do Jacuba', 'Contagem'
  );

  -- Líder 2: Davi
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Davi', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Tropical / Quintas do Jacuba', 'Contagem'
  );

  -- Líder 3: Lúcio
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Lúcio', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Tropical / Quintas do Jacuba', 'Contagem'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 404: Novo Progresso - Contagem (Setor: Oeste)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_oe_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 404 - Novo Progresso - Contagem (Rua Paraopeba, 184, Novo Progresso)', NULL, NULL, -19.898, -44.039, 3, '19:30:00', now()
  );

  -- Líder 1: Willian Batista
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Willian Batista', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Novo Progresso', 'Contagem'
  );

  -- Núcleo: Eduardo Coutinho
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Eduardo Coutinho', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Novo Progresso', 'Contagem'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 405: Bela Vista / Barreiro - Ibirité (Setor: Oeste)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_oe_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 405 - Bela Vista / Barreiro - Ibirité (Rua Melo de Souza Maia, 101, Bela Vista)', NULL, NULL, -20.008, -44.052, 3, '19:30:00', now()
  );

  -- Líder 1: José Alfredo
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'José Alfredo', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Bela Vista / Barreiro', 'Ibirité'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 406: Salgado Filho - BH (Setor: Oeste)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_oe_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 406 - Salgado Filho - BH (Rua Ibiraci, 250 - Bairro Salgado Filho - BH)', NULL, NULL, -19.9412, -43.9825, 3, '19:30:00', now()
  );

  -- Líder 1: João Pedro
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'João Pedro', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Salgado Filho', 'BH'
  );

  -- Líder 2: Thiago
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Thiago', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Salgado Filho', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 407: Nova Suíça - BH (Setor: Oeste)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_oe_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 407 - Nova Suíça - BH (Rua Lindolfo de Azevedo, 608, Nova Suíça - BH)', NULL, NULL, -19.9445, -43.9734, 3, '19:30:00', now()
  );

  -- Líder 1: Jardir
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Jardir', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Nova Suíça', 'BH'
  );

  -- Núcleo: Saulo
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Saulo', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Nova Suíça', 'BH'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 501: São José - Esmeraldas (Setor: Betim/Contagem)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_bc_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 501 - São José - Esmeraldas (Rua Américo França Abreu, 257, São José, Esmeraldas)', NULL, NULL, -19.7615, -44.314, 3, '19:30:00', now()
  );

  -- Líder 1: Emerson
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Emerson', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'São José', 'Esmeraldas'
  );

  -- Núcleo: Davi Ribeiro
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Davi Ribeiro', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'São José', 'Esmeraldas'
  );

  -- Núcleo: Charles
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Charles', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'São José', 'Esmeraldas'
  );

  -- Núcleo: Luiz
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Luiz', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'São José', 'Esmeraldas'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 502: Jardim Riacho das Pedras - Contagem (Setor: Betim/Contagem)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_bc_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 502 - Jardim Riacho das Pedras - Contagem (Rua Urânio, 114, Jardim Riacho das Pedras - Contagem)', NULL, NULL, -19.9565, -44.041, 3, '19:30:00', now()
  );

  -- Líder 1: Juan
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Juan', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Jardim Riacho das Pedras', 'Contagem'
  );

  -- Líder 2: Alexandre
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Alexandre', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Jardim Riacho das Pedras', 'Contagem'
  );

  -- Núcleo: Alexandre de Jesus
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Alexandre de Jesus', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Jardim Riacho das Pedras', 'Contagem'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 503: Marimbá - Betim (Setor: Betim/Contagem)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_bc_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 503 - Marimbá - Betim (Sítio da Igreja (Marimbá / Juatuba))', NULL, NULL, -19.932, -44.275, 3, '19:30:00', now()
  );

  -- Líder 1: Jairo
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Jairo', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Marimbá', 'Betim'
  );

  -- Núcleo: Leandro
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Leandro', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Marimbá', 'Betim'
  );

  -- Núcleo: Warley
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Warley', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Marimbá', 'Betim'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 504: Resplendor - Igarapé (Setor: Betim/Contagem)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_bc_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 504 - Resplendor - Igarapé (Rua Bahia, 131, Resplendor - Igarapé)', NULL, NULL, -20.068, -44.298, 3, '19:30:00', now()
  );

  -- Líder 1: Wiliam Pereira
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Wiliam Pereira', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Resplendor', 'Igarapé'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 505: Jardim Alterosa / Santo Antônio - Betim (Setor: Betim/Contagem)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_bc_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 505 - Jardim Alterosa / Santo Antônio - Betim (Rua Limoeiro, 337, Santo Antônio - Betim)', NULL, NULL, -19.961, -44.172, 3, '19:30:00', now()
  );

  -- Líder 1: Cléber
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Cléber', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Jardim Alterosa / Santo Antônio', 'Betim'
  );

  -- Líder 2: Caio
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Caio', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Jardim Alterosa / Santo Antônio', 'Betim'
  );

  -- Líder 3: Marcelo
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Marcelo', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Jardim Alterosa / Santo Antônio', 'Betim'
  );

  -- Núcleo: Caio Vitor
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Caio Vitor', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Jardim Alterosa / Santo Antônio', 'Betim'
  );

  -- Núcleo: Marcelo
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Marcelo', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Jardim Alterosa / Santo Antônio', 'Betim'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 506: Três Barras - Contagem (Setor: Betim/Contagem)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_bc_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 506 - Três Barras - Contagem (Rua Gentil Diniz, 441 - Três Barras - Contagem)', NULL, NULL, -19.9145, -44.0885, 3, '19:30:00', now()
  );

  -- Líder 1: Marilson
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Marilson', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Três Barras', 'Contagem'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 507: Eldorado - Contagem (Setor: Betim/Contagem)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_bc_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 507 - Eldorado - Contagem (Rua José Barra do Nascimento, 1971, Eldorado - Contagem)', NULL, NULL, -19.938, -44.0395, 3, '19:30:00', now()
  );

  -- Líder 1: Artur
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Artur', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Eldorado', 'Contagem'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 508: Ponte Alta - Betim (Setor: Betim/Contagem)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_bc_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 508 - Ponte Alta - Betim (Condomínio Ouro Verde, Bairro Ponte Alta - Betim)', NULL, NULL, -19.896, -44.203, 3, '19:30:00', now()
  );

  -- Líder 1: Lucas Augusto Santos
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Lucas Augusto Santos', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Ponte Alta', 'Betim'
  );

  -- Núcleo: Eliel
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Eliel', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Ponte Alta', 'Betim'
  );

  -- Núcleo: Ramon
  temp_p_id := extensions.uuid_generate_v4();
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Ramon', NULL, NULL, 'M', true, false, false, false, false, cur_gc_id, 'Ponte Alta', 'Betim'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 901: Interlagos - Sete Lagoas (Setor: Fora da Localidade)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_fl_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 901 - Interlagos - Sete Lagoas (Rua Antônio Domingos da Silva Filho, 307, B. Interlagos - Sete Lagoas)', NULL, NULL, -19.4752, -44.2368, 3, '19:30:00', now()
  );

  -- Líder 1: Douglas Martins
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Douglas Martins', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Interlagos', 'Sete Lagoas'
  );

  -- Líder 2: Cláudio Lopes
  temp_p_id := extensions.uuid_generate_v4();
  cur_l2_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'Cláudio Lopes', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Interlagos', 'Sete Lagoas'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ------------------------------------------------------------------------
  -- GC 902: Santa Bárbara (Setor: Fora da Localidade)
  -- ------------------------------------------------------------------------
  cur_gc_id := extensions.uuid_generate_v4();
  cur_sec_id := sec_fl_id;
  cur_l1_id := NULL;
  cur_l2_id := NULL;

  INSERT INTO public.home_groups (
    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at
  ) VALUES (
    cur_gc_id, cur_sec_id, 'GC 902 - Santa Bárbara (Santa Bárbara / Barão de Cocais)', NULL, NULL, -19.9595, -43.415, 3, '19:30:00', now()
  );

  -- Líder 1: José Antônio
  temp_p_id := extensions.uuid_generate_v4();
  cur_l1_id := temp_p_id;
  INSERT INTO public.profiles (
    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city
  ) VALUES (
    temp_p_id, 'José Antônio', NULL, NULL, 'M', true, false, false, false, true, cur_gc_id, 'Santa Bárbara', 'Belo Horizonte'
  );

  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;

  -- ==========================================================================
  -- 4. PLATAFORMA DE ENSINO & CATEQUESE (Media Resources, Studies, Steps)
  -- ==========================================================================
  
  -- 4A. Recursos Multimídia (Vídeos, PDFs e Textos)
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

    (m_res_id7, 'Artigo: Nenhum Discípulo Ocioso na Igreja na Cidade', 
     'Artigo sobre como cada membro do Corpo possui um serviço prático na edificação mútua e no amor fraternal.', 
     'markdown', 'https://raw.githubusercontent.com/markdown-it/markdown-it/master/README.md', 'Sacerdócio Universal', 'Artigo Teológico', now() - INTERVAL '12 days'),

    (m_res_id8, 'A Igreja nas Casas: Oikos e a Vida Cotidiana', 
     'A dinâmica prática de orar, partir o pão e acolher os necessitados nas residências familiares.', 
     'video', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'Vida nas Casas', 'Grupos Caseiros', now() - INTERVAL '10 days'),

    (m_res_id9, 'Caderno de Apoio: Evangelismo Natural e Fazendo Discípulos', 
     'Roteiro simples para compartilhar o testemunho de transformação de vida nas ruas e ambientes de trabalho.', 
     'pdf', 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', 'Evangelismo do Reino', 'Prática', now() - INTERVAL '8 days'),

    (m_res_id10, 'Apostila Completa: Panorama de Atos dos Apóstolos', 
     'Estudo verso a verso sobre como a igreja primitiva vivia em unanimidade e comum partilha de bens.', 
     'pdf', 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', 'Panorama Bíblico', 'Estudo Bíblico', now() - INTERVAL '5 days');

  -- 4B. Inserção das 3 Trilhas de Estudo Principais (Studies)
  INSERT INTO public.studies (id, title, description, created_by, created_at)
  VALUES 
    (study_id1, 'Trilha 1: O Propósito Eterno de Deus', 
     'Compreenda o plano eterno do Pai: formar uma grande família de muitos filhos que refletem o caráter santo e obediente de Jesus Cristo.', 
     gabriel_id, now() - INTERVAL '30 days'),
    
    (study_id2, 'Trilha 2: Juntas e Ligamentos — O Discipulado Prático', 
     'Aprenda como se conectar em relacionamentos intencionais de acompanhamento mútuo, oração contínua e modelagem de Cristo na vida real.', 
     gabriel_id, now() - INTERVAL '20 days'),

    (study_id3, 'Trilha 3: O Sacerdócio Universal e a Dinâmica nas Casas', 
     'Descubra a função de cada santo como sacerdote, eliminando a passividade e capacitando cada discípulo para o serviço no Corpo e na cidade.', 
     gabriel_id, now() - INTERVAL '15 days');

  -- 4C. Associação das Etapas de Estudo (Study Steps)
  INSERT INTO public.study_steps (id, study_id, media_resource_id, sort_order, created_at)
  VALUES 
    -- Trilha 1
    (step_id1, study_id1, m_res_id1, 1, now() - INTERVAL '30 days'),
    (step_id2, study_id1, m_res_id2, 2, now() - INTERVAL '29 days'),
    (step_id3, study_id1, m_res_id3, 3, now() - INTERVAL '28 days'),
    
    -- Trilha 2
    (step_id4, study_id2, m_res_id4, 1, now() - INTERVAL '20 days'),
    (step_id5, study_id2, m_res_id5, 2, now() - INTERVAL '19 days'),
    
    -- Trilha 3
    (step_id6, study_id3, m_res_id6, 1, now() - INTERVAL '15 days'),
    (step_id7, study_id3, m_res_id7, 2, now() - INTERVAL '14 days'),
    (step_id8, study_id3, m_res_id8, 3, now() - INTERVAL '13 days');

  -- ==========================================================================
  -- 5. MODELOS OFICIAIS DE FORMULÁRIOS DINÂMICOS (Tabela Forms)
  -- ==========================================================================
  INSERT INTO public.forms (id, name, description, fields, is_public, created_at, is_active)
  VALUES 
    (
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
    ),
    (
      'form-censo-dons',
      'Censo da Vida Comum: Dons, Habilidades e Apoio Mútuo',
      'Pesquisa comunitária para identificar talentos, áreas de atuação e ministérios práticos na cidade.',
      '[
        {
          "id": "area_atuacao",
          "type": "select",
          "label": "Área de Formação / Ocupação",
          "placeholder": "Selecione sua área profissional",
          "required": true,
          "helpText": "Sua ocupação principal",
          "options": ["Saúde", "Educação", "Tecnologia", "Construção Civil", "Comércio", "Jurídico", "Serviços Gerais", "Outro"]
        },
        {
          "id": "dons_servico",
          "type": "checkbox",
          "label": "Disponibilidade de Serviço no Corpo",
          "placeholder": "",
          "required": true,
          "helpText": "Em quais áreas você sente alegria em servir os irmãos?",
          "options": ["Diaconia & Ação Social", "Ensino & Catequese", "Acolhimento & Hospitalidade", "Música & Louvor", "Logística de Eventos", "Visitação & Consolação"]
        },
        {
          "id": "habilidade_especifica",
          "type": "text",
          "label": "Habilidade ou Conhecimento Específico",
          "placeholder": "Ex: Eletricista, Cozinha para grandes grupos, Cuidados de enfermagem...",
          "required": false,
          "helpText": "Descreva talentos práticos que podem apoiar famílias da igreja",
          "options": []
        }
      ]'::jsonb,
      false, now(), true
    ),
    (
      'form-apoio-diaconal',
      'Solicitação de Apoio Fraternal & Diaconia',
      'Formulário confidencial para registro de demandas emergenciais de saúde, alimentação ou suporte.',
      '[
        {
          "id": "tipo_apoio",
          "type": "select",
          "label": "Natureza da Necessidade",
          "placeholder": "Selecione o tipo de suporte necessário",
          "required": true,
          "helpText": "Ajuda emergencial",
          "options": ["Cesta Básica / Alimentação", "Apoio com Medicamentos", "Auxílio Moradia Emergencial", "Transporte para Tratamento de Saúde", "Outro"]
        },
        {
          "id": "descricao_situacao",
          "type": "textarea",
          "label": "Relato da Situação Atual",
          "placeholder": "Descreva brevemente a dificuldade enfrentada...",
          "required": true,
          "helpText": "Apenas os diáconos e presbíteros terão acesso a este relato",
          "options": []
        },
        {
          "id": "urgencia",
          "type": "radio",
          "label": "Nível de Urgência",
          "placeholder": "",
          "required": true,
          "helpText": "Prazo para atendimento da demanda",
          "options": ["Imediato (até 48h)", "Curto Prazo (nesta semana)", "Acompanhamento Contínuo"]
        }
      ]'::jsonb,
      false, now(), true
    ),
    (
      'form-carnaval-2026',
      'Ficha de Inscrição Oficial - Retiro de Carnaval 2026',
      'Ficha de inscrição padrão para o retiro geral da igreja em Belo Horizonte.',
      '[
        {
          "id": "mandatory_full_name",
          "type": "text",
          "label": "Nome Completo",
          "placeholder": "Seu nome",
          "required": true,
          "helpText": "Nome completo do participante",
          "options": []
        },
        {
          "id": "tipo_participante",
          "type": "select",
          "label": "Categoria de Inscrição",
          "placeholder": "Selecione a categoria",
          "required": true,
          "helpText": "Faixa etária / Modalidade",
          "options": ["Adulto (Acima de 12 anos)", "Criança (5 a 11 anos)", "Criança de Colo (0 a 4 anos)"]
        }
      ]'::jsonb,
      true, now(), true
    ),
    (
      'form-casais-2026',
      'Ficha de Inscrição - Encontro Metropolitano de Casais 2026',
      'Inscrições para o final de semana de edificação das famílias e casais nas casas.',
      '[
        {
          "id": "nome_esposo",
          "type": "text",
          "label": "Nome do Esposo",
          "placeholder": "Nome completo do esposo",
          "required": true,
          "helpText": "Participante 1",
          "options": []
        },
        {
          "id": "nome_esposa",
          "type": "text",
          "label": "Nome da Esposa",
          "placeholder": "Nome completo da esposa",
          "required": true,
          "helpText": "Participante 2",
          "options": []
        },
        {
          "id": "tempo_casados",
          "type": "text",
          "label": "Tempo de Casados (anos)",
          "placeholder": "Ex: 12 anos",
          "required": true,
          "helpText": "Para dinâmicas dos grupos",
          "options": []
        }
      ]'::jsonb,
      true, now(), true
    )
  ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, fields = EXCLUDED.fields;

END $$;
