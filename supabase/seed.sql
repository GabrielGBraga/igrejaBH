-- ============================================================================
-- SCRIPT DE SEEDING: IGREJA EM BELO HORIZONTE (PORTAL DE VIDA COMUM)
-- Geração programática de 528 discípulos, 24 GCs, 6 setores e laços de juntas.
-- ============================================================================

DO $$
DECLARE
  -- Listas de Nomes e Sobrenomes Brasileiros para geração realista
  s_names text[] := ARRAY['Gabriel', 'Lucas', 'Tiago', 'Felipe', 'Mateus', 'Marcos', 'André', 'Roberto', 'Cláudio', 'Carlos', 'João', 'Pedro', 'Antônio', 'Paulo', 'José', 'Francisco', 'Luiz', 'Geraldo', 'Sebastião', 'Raimundo', 'Walter', 'Rodrigo', 'Daniel', 'Renato', 'Julio', 'Ricardo', 'Eduardo', 'Arthur', 'Bruno', 'Marcelo', 'Daniel', 'Rodrigo', 'Breno', 'Hugo', 'Rafael', 'Vinícius', 'Gustavo', 'Diego', 'Leonardo', 'Thiago'];
  s_fnames text[] := ARRAY['Sandra', 'Carolina', 'Regina', 'Mariana', 'Patrícia', 'Laura', 'Juliana', 'Cláudia', 'Letícia', 'Camila', 'Amanda', 'Maria', 'Helena', 'Nair', 'Terezinha', 'Lourdes', 'Ana', 'Beatriz', 'Júlia', 'Cristina', 'Fernanda', 'Gabriela', 'Aline', 'Sofia', 'Renata', 'Sônia', 'Marta', 'Luciana', 'Clara', 'Luiza', 'Isadora', 'Larissa', 'Mariane', 'Priscila', 'Natália', 'Cecília', 'Letícia', 'Cláudia', 'Marta', 'Olívia'];
  s_surnames text[] := ARRAY['Silva', 'Santos', 'Oliveira', 'Souza', 'Pereira', 'Lima', 'Costa', 'Alves', 'Nogueira', 'Martins', 'Pinto', 'Rocha', 'Mendes', 'Gomes', 'Freitas', 'Barbosa', 'Araújo', 'Cardoso', 'Carvalho', 'Teixeira', 'Cardoso', 'Ribeiro', 'Vieira', 'Monteiro', 'Borges', 'Moraes', 'Nunes', 'Castro', 'Coelho', 'Dantas'];
  
  -- Listas de metadados para painel do diaconato
  s_occupations text[] := ARRAY['Engenheiro', 'Professor', 'Autônomo', 'Médico', 'Advogado', 'Vendedor', 'Administrador', 'Mecânico', 'Eletricista', 'Programador', 'Aposentado', 'Estudante', 'Arquiteto', 'Contador', 'Auxiliar Administrativo', 'Motorista', 'Enfermeiro', 'Empresário', 'Zelador', 'Pedreiro'];
  s_housing text[] := ARRAY['Própria', 'Alugada', 'Financiada', 'Cedida'];
  s_income text[] := ARRAY['menos de 1 salário mínimo', '1 a 2 salários mínimos', '2 a 5 salários mínimos', 'mais de 5 salários mínimos'];
  s_education text[] := ARRAY['Ensino Fundamental', 'Ensino Médio', 'Ensino Superior', 'Pós-graduação'];
  s_employment text[] := ARRAY['CLT', 'Autônomo', 'Empresário', 'Desempregado', 'Aposentado'];
  
  -- Setores solicitados
  sector_ids uuid[] := ARRAY[]::uuid[];
  sector_names text[] := ARRAY['Barreiro/Oeste', 'Pampulha/São Gabriel', 'Santa Luzia', 'Venda Nova', 'Betim', 'Contagem'];
  -- Coordenadas centrais aproximadas de cada setor
  sector_lats float8[] := ARRAY[-19.9700, -19.8500, -19.7700, -19.8000, -19.9600, -19.9300];
  sector_lngs float8[] := ARRAY[-44.0200, -43.9600, -43.8500, -43.9900, -44.2000, -44.0500];
  
  -- Mapeamento de GCs por Setor (4 GCs por setor)
  gc_names text[][] := ARRAY[
    ARRAY['GC Buritis', 'GC Barreiro', 'GC Estoril', 'GC Gutierrez'],
    ARRAY['GC Ouro Preto', 'GC Castelo', 'GC São Gabriel', 'GC Dona Clara'],
    ARRAY['GC Cristina', 'GC Frimisa', 'GC São Benedito', 'GC Centro Santa Luzia'],
    ARRAY['GC Planalto', 'GC Letícia', 'GC Mantiqueira', 'GC Candelária'],
    ARRAY['GC Centro Betim', 'GC Alterosa', 'GC PTB', 'GC Imbiruçu'],
    ARRAY['GC Eldorado', 'GC Industrial', 'GC Novo Eldorado', 'GC Cabral']
  ];
  
  -- Variáveis auxiliares para criação
  sec_id uuid;
  gc_id uuid;
  gc_lat float8;
  gc_lng float8;
  
  -- Arrays para rastrear IDs para ligamentos posteriores
  leader_ids uuid[] := ARRAY[]::uuid[]; -- 48 líderes
  presbyters uuid[] := ARRAY[]::uuid[]; -- 4 presbíteros
  deacons uuid[] := ARRAY[]::uuid[];    -- 6 diáconos (incluindo Gabriel)
  
  -- Variáveis de laço e temporárias
  i int;
  j int;
  k int;
  c_loop int;
  r_idx int;
  
  temp_profile_id uuid;
  temp_auth_id uuid;
  pwd_hash text;
  
  -- Estruturas de famílias (marido e esposa temporários)
  l_husband_id uuid;
  l_wife_id uuid;
  f_husband_id uuid;
  f_wife_id uuid;
  
  -- Dados gerados
  m_first text;
  f_first text;
  l_surname text;
  full_nm text;
  email_addr text;
  phone_num text;
  cpf_val text;
  b_date date;
  bapt_date date;
  
  -- Cursores e registros para pós-processamento de juntas
  rec RECORD;
  rec_comp RECORD;
  comp_count int;
  
  -- Gabriel Braga ID
  gabriel_id uuid;
BEGIN
  -- ==========================================================================
  -- 1. LIMPEZA TOTAL DO BANCO
  -- ==========================================================================
  TRUNCATE public.profiles, public.home_groups, public.sectors, public.posts, public.fellowships, public.retreats, public.registrations, public.forms, public.form_submissions, public.user_study_progress CASCADE;
  DELETE FROM auth.users;

  -- Senha padrão pré-calculada para "senha123" usando Blowfish bcrypt salt
  pwd_hash := '$2a$06$XqL/cRckHcXJ1xzAYPKQUORulnZ8gYmOlK1FwEvihHPa7trFLTl9.';

  -- ==========================================================================
  -- 2. CRIAÇÃO DOS SETORES
  -- ==========================================================================
  FOR i IN 1..6 LOOP
    sec_id := extensions.uuid_generate_v4();
    sector_ids := array_append(sector_ids, sec_id);
    INSERT INTO public.sectors (id, name, created_at)
    VALUES (sec_id, sector_names[i], now());
  END LOOP;

  -- ==========================================================================
  -- 3. CRIAÇÃO PROGRAMÁTICA DE PERFIS DE LÍDERES (48 Homens Casados)
  -- ==========================================================================
  -- Criamos os líderes primeiro para que eles existam antes dos GCs e possamos vinculá-los
  FOR i IN 1..6 LOOP -- Setores
    FOR j IN 1..4 LOOP -- GCs
      FOR k IN 1..2 LOOP -- 2 líderes por GC
        temp_profile_id := extensions.uuid_generate_v4();
        
        -- Configuração Especial para Gabriel Góes Braga (Líder 1 do GC São Gabriel)
        -- GC São Gabriel é Setor 2 (Pampulha/SG), GC 3, Líder 1
        IF i = 2 AND j = 3 AND k = 1 THEN
          full_nm := 'Gabriel Góes Braga';
          email_addr := 'ggoesbraga@gmail.com';
          cpf_val := '132.507.246-02';
          b_date := '1995-07-08'::date;
          bapt_date := '2012-06-15'::date; -- Batizado em 2012 (diácono jovem)
          gabriel_id := temp_profile_id;
        ELSE
          -- Gerar dados aleatórios baseados nos índices para consistência
          r_idx := (i * 100 + j * 10 + k * 3) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          
          r_idx := (i * 50 + j * 13 + k * 7) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          
          full_nm := m_first || ' ' || l_surname;
          email_addr := lower(m_first) || '.' || lower(l_surname) || '_l' || (i*10+j*2+k) || '@igrejabh.org';
          cpf_val := ((200 + i * 15 + j * 4 + k)::text) || '.' || ((300 + i * 8 + j * 9)::text) || '.' || ((400 + i * 6 + k * 14)::text) || '-99';
          
          -- Líderes nascidos entre 1960 e 1985
          b_date := ('1960-01-01'::date + ((i * 500 + j * 200 + k * 70) % 9000) * '1 day'::interval)::date;
          -- Batizados entre 1985 e 2012
          bapt_date := (b_date + '18 years'::interval + ((i * 110 + j * 90 + k * 45) % 3000) * '1 day'::interval)::date;
        END IF;

        phone_num := '(31) 99' || ((1000 + i * 100 + j * 20 + k)::text);

        -- Classificação de Cargos:
        -- Presbíteros: exatamente 4 presbíteros (líderes de GC do Setor 1, k=1)
        -- Diáconos: exatamente 6 diáconos (líderes de GCs do Setor 2, incluindo Gabriel)
        -- Demais líderes: sem cargos
        DECLARE
          is_presb boolean := false;
          is_deac boolean := false;
        BEGIN
          IF i = 1 AND k = 1 THEN
            is_presb := true;
          ELSIF (i = 2 AND j = 3 AND k = 1) OR
                (i = 2 AND j = 3 AND k = 2) OR
                (i = 2 AND j = 1 AND k = 1) OR
                (i = 2 AND j = 1 AND k = 2) OR
                (i = 2 AND j = 2 AND k = 1) OR
                (i = 2 AND j = 2 AND k = 2)
          THEN
            is_deac := true;
          END IF;

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, 
            is_dev, is_presbyter, is_deacon, can_post, address_city, address_state,
            occupation, education_level, employment_status, household_income, housing_status, marital_status
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'M',
            (i = 2 AND j = 3 AND k = 1), -- is_dev para Gabriel
            is_presb, is_deac, true, 'Belo Horizonte', 'MG',
            s_occupations[1 + ((i * 3 + j * 2 + k) % array_length(s_occupations, 1))],
            s_education[1 + ((i * 2 + j * 3 + k) % array_length(s_education, 1))],
            s_employment[1 + ((i * 4 + j + k) % array_length(s_employment, 1))],
            s_income[1 + ((i * 2 + j * 3 + k) % array_length(s_income, 1))],
            s_housing[1 + ((i + j * 2 + k) % array_length(s_housing, 1))],
            'Casado(a)'
          );

          -- Criar registro correspondente em auth.users (sem confirmed_at)
          temp_auth_id := extensions.uuid_generate_v4();
          INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change)
          VALUES (
            temp_auth_id,
            '00000000-0000-0000-0000-000000000000',
            email_addr,
            pwd_hash,
            now(),
            '{"provider":"email","providers":["email"]}'::jsonb,
            jsonb_build_object('full_name', full_nm, 'cpf', cpf_val),
            now(),
            now(),
            'authenticated',
            'authenticated',
            '',
            '',
            '',
            ''
          );

          leader_ids := array_append(leader_ids, temp_profile_id);

          IF is_presb THEN
            presbyters := array_append(presbyters, temp_profile_id);
          ELSIF is_deac THEN
            deacons := array_append(deacons, temp_profile_id);
          END IF;
        END;
      END LOOP;
    END LOOP;
  END LOOP;

  -- ==========================================================================
  -- 4. CRIAÇÃO DOS GCs E POVOAMENTO DOS MEMBROS
  -- ==========================================================================
  FOR i IN 1..6 LOOP -- Setores
    FOR j IN 1..4 LOOP -- GCs
      -- Puxa os líderes previamente criados para este GC específico
      -- Lider 1 e Lider 2
      l_husband_id := leader_ids[((i - 1) * 8 + (j - 1) * 2 + 1)];
      l_wife_id := leader_ids[((i - 1) * 8 + (j - 1) * 2 + 2)]; -- Esse na verdade é o Líder 2 (homem) que chamamos temporariamente de l_wife_id para o setup da liderança do GC
      
      -- GC Setup
      gc_id := extensions.uuid_generate_v4();
      gc_lat := sector_lats[i] + (((i * 27 + j * 41) % 100)::float8 / 2500.0 - 0.02);
      gc_lng := sector_lngs[i] + (((i * 19 + j * 53) % 100)::float8 / 2500.0 - 0.02);
      
      INSERT INTO public.home_groups (id, meeting_day, location_text, leader_1_id, leader_2_id, lat, lng, start_time, sector_id, created_at)
      VALUES (
        gc_id,
        ((i + j) % 6 + 1), -- Dia de reunião (1 a 6 = Segunda a Sábado)
        gc_names[i][j] || ' - Rua dos Discípulos, ' || (200 + i * j * 12) || ', ' || sector_names[i] || ', MG',
        l_husband_id,
        l_wife_id, -- Lider 2
        gc_lat,
        gc_lng,
        '19:30:00',
        sector_ids[i],
        now()
      );

      -- Associa os dois líderes homens a este GC
      UPDATE public.profiles SET home_group_id = gc_id WHERE id IN (l_husband_id, l_wife_id);

      -- ========================================================================
      -- 4A. CRIAÇÃO DAS ESPOSAS DOS LÍDERES (2 Mulheres Casadas por GC)
      -- ========================================================================
      FOR k IN 1..2 LOOP
        -- O marido correspondente é o Leader 1 (k=1) ou o Leader 2 (k=2)
        DECLARE
          m_id uuid := CASE WHEN k = 1 THEN l_husband_id ELSE l_wife_id END;
          m_profile RECORD;
        BEGIN
          SELECT * INTO m_profile FROM public.profiles WHERE id = m_id;
          
          temp_profile_id := extensions.uuid_generate_v4();
          r_idx := (i * 45 + j * 21 + k * 19) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          
          -- Sobrenome do marido
          l_surname := split_part(m_profile.full_name, ' ', 2);
          IF l_surname = '' THEN l_surname := s_surnames[(i*j+k)%array_length(s_surnames,1)+1]; END IF;
          
          full_nm := f_first || ' ' || l_surname;
          email_addr := lower(f_first) || '.' || lower(l_surname) || '_wl' || (i*10+j*2+k) || '@igrejabh.org';
          cpf_val := ((500 + i * 14 + j * 5 + k)::text) || '.' || ((600 + i * 3 + j * 8)::text) || '.' || ((700 + i * 2 + k * 19)::text) || '-99';
          b_date := m_profile.birth_date + '1 year'::interval;
          
          -- Batizadas entre 2002 e 2014 (esposas de líderes)
          bapt_date := ('2002-01-01'::date + ((i * 120 + j * 80 + k * 95) % 4000) * '1 day'::interval)::date;
          phone_num := '(31) 99' || ((6000 + i * 100 + j * 20 + k)::text);

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, spouse_id, address_city, address_state,
            occupation, education_level, employment_status, household_income, housing_status, marital_status
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'F', gc_id, m_id, 'Belo Horizonte', 'MG',
            s_occupations[1 + ((i * 2 + j * 4 + k) % array_length(s_occupations, 1))],
            s_education[1 + ((i * 3 + j * 1 + k) % array_length(s_education, 1))],
            s_employment[1 + ((i * 2 + j * 3 + k) % array_length(s_employment, 1))],
            m_profile.household_income,
            m_profile.housing_status,
            'Casado(a)'
          );

          -- Vincula de volta o líder (marido) à esposa
          UPDATE public.profiles SET spouse_id = temp_profile_id WHERE id = m_id;

          -- Criar conta auth para esposa do líder (sem confirmed_at)
          temp_auth_id := extensions.uuid_generate_v4();
          INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change)
          VALUES (
            temp_auth_id,
            '00000000-0000-0000-0000-000000000000',
            email_addr,
            pwd_hash,
            now(),
            '{"provider":"email","providers":["email"]}'::jsonb,
            jsonb_build_object('full_name', full_nm, 'cpf', cpf_val),
            now(),
            now(),
            'authenticated',
            'authenticated',
            '',
            '',
            '',
            ''
          );
        END;
      END LOOP;

      -- ========================================================================
      -- 4B. CRIAÇÃO DOS CASAIS ORDINÁRIOS (2 Famílias por GC)
      -- ========================================================================
      FOR k IN 1..2 LOOP
        -- 1. Marido ordinário
        f_husband_id := extensions.uuid_generate_v4();
        r_idx := (i * 23 + j * 11 + k * 31) % array_length(s_names, 1) + 1;
        m_first := s_names[r_idx];
        r_idx := (i * 14 + j * 19 + k * 8) % array_length(s_surnames, 1) + 1;
        l_surname := s_surnames[r_idx];
        
        full_nm := m_first || ' ' || l_surname;
        email_addr := lower(m_first) || '.' || lower(l_surname) || '_h' || (i*100+j*10+k) || '@igrejabh.org';
        cpf_val := ((300 + i * 11 + j * 2 + k)::text) || '.' || ((400 + i * 9 + j * 3)::text) || '.' || ((500 + i * 4 + k * 17)::text) || '-99';
        
        -- Nascidos entre 1980 e 1995
        b_date := ('1980-01-01'::date + ((i * 200 + j * 150 + k * 95) % 5000) * '1 day'::interval)::date;
        -- Batizados entre 2008 e 2016
        bapt_date := ('2008-01-01'::date + ((i * 80 + j * 60 + k * 110) % 2900) * '1 day'::interval)::date;
        phone_num := '(31) 99' || ((7000 + i * 100 + j * 20 + k)::text);

        INSERT INTO public.profiles (
          id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, address_city, address_state,
          occupation, education_level, employment_status, household_income, housing_status, marital_status
        ) VALUES (
          f_husband_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'M', gc_id, 'Belo Horizonte', 'MG',
          s_occupations[1 + ((i * 1 + j * 3 + k) % array_length(s_occupations, 1))],
          s_education[1 + ((i * 2 + j * 2 + k) % array_length(s_education, 1))],
          s_employment[1 + ((i * 3 + j * 1 + k) % array_length(s_employment, 1))],
          s_income[1 + ((i * 2 + j * 3 + k) % array_length(s_income, 1))],
          s_housing[1 + ((i + j * 2 + k) % array_length(s_housing, 1))],
          'Casado(a)'
        );

        -- Auth para marido ordinário (sem confirmed_at)
        temp_auth_id := extensions.uuid_generate_v4();
        INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change)
        VALUES (
          temp_auth_id,
          '00000000-0000-0000-0000-000000000000',
          email_addr,
          pwd_hash,
          now(),
          '{"provider":"email","providers":["email"]}'::jsonb,
          jsonb_build_object('full_name', full_nm, 'cpf', cpf_val),
          now(),
          now(),
          'authenticated',
          'authenticated',
          '',
          '',
          '',
          ''
        );

        -- 2. Esposa ordinária
        f_wife_id := extensions.uuid_generate_v4();
        r_idx := (i * 17 + j * 34 + k * 23) % array_length(s_fnames, 1) + 1;
        f_first := s_fnames[r_idx];
        
        full_nm := f_first || ' ' || l_surname;
        email_addr := lower(f_first) || '.' || lower(l_surname) || '_w' || (i*100+j*10+k) || '@igrejabh.org';
        cpf_val := ((600 + i * 8 + j * 4 + k)::text) || '.' || ((700 + i * 11 + j * 5)::text) || '.' || ((800 + i * 2 + k * 13)::text) || '-99';
        b_date := b_date + '2 years'::interval;
        
        -- Batizadas entre 2010 e 2018
        bapt_date := ('2010-01-01'::date + ((i * 90 + j * 70 + k * 125) % 2900) * '1 day'::interval)::date;
        phone_num := '(31) 99' || ((8000 + i * 100 + j * 20 + k)::text);

        INSERT INTO public.profiles (
          id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, spouse_id, address_city, address_state,
          occupation, education_level, employment_status, household_income, housing_status, marital_status
        ) VALUES (
          f_wife_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'F', gc_id, f_husband_id, 'Belo Horizonte', 'MG',
          s_occupations[1 + ((i * 2 + j * 2 + k) % array_length(s_occupations, 1))],
          s_education[1 + ((i * 1 + j * 3 + k) % array_length(s_education, 1))],
          s_employment[1 + ((i * 2 + j * 2 + k) % array_length(s_employment, 1))],
          s_income[1 + ((i * 2 + j * 2 + k) % array_length(s_income, 1))],
          s_housing[1 + ((i + j * 2 + k) % array_length(s_housing, 1))],
          'Casado(a)'
        );

        -- Vincula marido de volta à esposa
        UPDATE public.profiles SET spouse_id = f_wife_id WHERE id = f_husband_id;

        -- Auth para esposa ordinária (sem confirmed_at)
        temp_auth_id := extensions.uuid_generate_v4();
        INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change)
        VALUES (
          temp_auth_id,
          '00000000-0000-0000-0000-000000000000',
          email_addr,
          pwd_hash,
          now(),
          '{"provider":"email","providers":["email"]}'::jsonb,
          jsonb_build_object('full_name', full_nm, 'cpf', cpf_val),
          now(),
          now(),
          'authenticated',
          'authenticated',
          '',
          '',
          '',
          ''
        );

        -- ======================================================================
        -- 4C. FILHOS PEQUENOS (Não Batizados, 2 por GC, 1 em cada família ordinária)
        -- ======================================================================
        -- Criamos um CPF único e não-nulo para os filhos pequenos
        temp_profile_id := extensions.uuid_generate_v4();
        IF k = 1 THEN
          r_idx := (i * 9 + j * 3 + k * 19) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          full_nm := m_first || ' ' || l_surname;
          cpf_val := ((700 + i * 15 + j * 3 + k)::text) || '.' || ((800 + i * 2 + j * 7)::text) || '.' || ((900 + i * 1 + k * 18)::text) || '-99';
          
          INSERT INTO public.profiles (
            id, full_name, cpf, birth_date, baptism_date, gender, home_group_id, father_id, mother_id, address_city, address_state, marital_status
          ) VALUES (
            temp_profile_id, full_nm, cpf_val, (now() - ((4 + (i+j+k)%5)::text || ' years')::interval)::date, NULL, 'M', gc_id, f_husband_id, f_wife_id, 'Belo Horizonte', 'MG', 'Solteiro(a)'
          );
        ELSE
          r_idx := (i * 12 + j * 9 + k * 23) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          full_nm := f_first || ' ' || l_surname;
          cpf_val := ((750 + i * 15 + j * 3 + k)::text) || '.' || ((850 + i * 2 + j * 7)::text) || '.' || ((950 + i * 1 + k * 18)::text) || '-99';

          INSERT INTO public.profiles (
            id, full_name, cpf, birth_date, baptism_date, gender, home_group_id, father_id, mother_id, address_city, address_state, marital_status
          ) VALUES (
            temp_profile_id, full_nm, cpf_val, (now() - ((2 + (i+j)%6)::text || ' years')::interval)::date, NULL, 'F', gc_id, f_husband_id, f_wife_id, 'Belo Horizonte', 'MG', 'Solteiro(a)'
          );
        END IF;

        -- ======================================================================
        -- 4D. FILHOS ADOLESCENTES/JOVENS (Batizados, 2 por GC, 1 em cada família)
        -- ======================================================================
        temp_profile_id := extensions.uuid_generate_v4();
        IF k = 1 THEN
          r_idx := (i * 18 + j * 5 + k * 29) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          full_nm := m_first || ' ' || l_surname;
          email_addr := lower(m_first) || '.' || lower(l_surname) || '_child' || (i*100+j*10+k) || '@igrejabh.org';
          cpf_val := ((400 + i * 15 + j * 3 + k)::text) || '.' || ((500 + i * 2 + j * 7)::text) || '.' || ((600 + i * 1 + k * 18)::text) || '-99';
          b_date := (now() - ((14 + (i+j)%5)::text || ' years')::interval)::date;
          bapt_date := (b_date + '12 years'::interval + ((i*10 + j*3 + k)%300 * '1 day'::interval))::date;

          INSERT INTO public.profiles (
            id, full_name, email, cpf, birth_date, baptism_date, gender, home_group_id, father_id, mother_id, address_city, address_state, marital_status,
            occupation, education_level, employment_status, household_income, housing_status
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, b_date, bapt_date, 'M', gc_id, f_husband_id, f_wife_id, 'Belo Horizonte', 'MG', 'Solteiro(a)',
            'Estudante', 'Ensino Médio', 'Desempregado', s_income[1+((i*2+j)%4)], 'Própria'
          );
        ELSE
          r_idx := (i * 21 + j * 15 + k * 11) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          full_nm := f_first || ' ' || l_surname;
          email_addr := lower(f_first) || '.' || lower(l_surname) || '_child' || (i*100+j*10+k) || '@igrejabh.org';
          cpf_val := ((450 + i * 15 + j * 3 + k)::text) || '.' || ((550 + i * 2 + j * 7)::text) || '.' || ((650 + i * 1 + k * 18)::text) || '-99';
          b_date := (now() - ((16 + (i+j)%6)::text || ' years')::interval)::date;
          bapt_date := (b_date + '13 years'::interval + ((i*12 + j*2 + k)%350 * '1 day'::interval))::date;

          INSERT INTO public.profiles (
            id, full_name, email, cpf, birth_date, baptism_date, gender, home_group_id, father_id, mother_id, address_city, address_state, marital_status,
            occupation, education_level, employment_status, household_income, housing_status
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, b_date, bapt_date, 'F', gc_id, f_husband_id, f_wife_id, 'Belo Horizonte', 'MG', 'Solteiro(a)',
            'Estudante', 'Ensino Superior', 'Desempregado', s_income[1+((i*2+j)%4)], 'Própria'
          );
        END IF;

        -- Auth para filho batizado (sem confirmed_at)
        temp_auth_id := extensions.uuid_generate_v4();
        INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change)
        VALUES (
          temp_auth_id,
          '00000000-0000-0000-0000-000000000000',
          email_addr,
          pwd_hash,
          now(),
          '{"provider":"email","providers":["email"]}'::jsonb,
          jsonb_build_object('full_name', full_nm, 'cpf', cpf_val),
          now(),
          now(),
          'authenticated',
          'authenticated',
          '',
          '',
          '',
          ''
        );
      END LOOP;

      -- ========================================================================
      -- 4E. IDOSOS PHANTOM USERS (3 por GC, Sem Conta Auth)
      -- ========================================================================
      FOR k IN 1..3 LOOP
        temp_profile_id := extensions.uuid_generate_v4();
        b_date := ('1940-01-01'::date + ((i * 170 + j * 90 + k * 230) % 5500) * '1 day'::interval)::date;
        bapt_date := (b_date + '18 years'::interval + ((i*50 + j*35 + k*20)%1800 * '1 day'::interval))::date;
        
        IF k % 2 = 1 THEN
          r_idx := (i * 32 + j * 12 + k * 18) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          r_idx := (i * 24 + j * 8 + k * 22) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          
          full_nm := 'Seu ' || m_first || ' ' || l_surname;
          email_addr := lower(m_first) || '.' || lower(l_surname) || '_elder' || (i*10+j*3+k) || '@igrejabh.org';
          cpf_val := ((800 + i * 2 + j * 6 + k)::text) || '.' || ((100 + i * 9 + j * 11)::text) || '.' || ((200 + i * 3 + k * 18)::text) || '-99';

          INSERT INTO public.profiles (
            id, full_name, email, cpf, birth_date, baptism_date, gender, home_group_id, address_city, address_state, marital_status,
            occupation, education_level, employment_status, household_income, housing_status
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, b_date, bapt_date, 'M', gc_id, 'Belo Horizonte', 'MG', 'Casado(a)',
            'Aposentado', 'Ensino Médio', 'Aposentado', '1 a 2 salários mínimos', 'Própria'
          );
        ELSE
          r_idx := (i * 28 + j * 15 + k * 11) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          r_idx := (i * 19 + j * 12 + k * 27) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          
          full_nm := 'Dona ' || f_first || ' ' || l_surname;
          email_addr := lower(f_first) || '.' || lower(l_surname) || '_elder' || (i*10+j*3+k) || '@igrejabh.org';
          cpf_val := ((850 + i * 2 + j * 6 + k)::text) || '.' || ((150 + i * 9 + j * 11)::text) || '.' || ((250 + i * 3 + k * 18)::text) || '-99';

          INSERT INTO public.profiles (
            id, full_name, email, cpf, birth_date, baptism_date, gender, home_group_id, address_city, address_state, marital_status,
            occupation, education_level, employment_status, household_income, housing_status
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, b_date, bapt_date, 'F', gc_id, 'Belo Horizonte', 'MG', 'Viúvo(a)',
            'Aposentada', 'Ensino Fundamental', 'Aposentado', 'menos de 1 salário mínimo', 'Própria'
          );
        END IF;
      END LOOP;

      -- ========================================================================
      -- 4F. SOLTEIROS ORDINÁRIOS (7 por GC, Com Contas Auth)
      -- ========================================================================
      FOR k IN 1..7 LOOP
        temp_profile_id := extensions.uuid_generate_v4();
        b_date := ('1995-01-01'::date + ((i * 300 + j * 200 + k * 120) % 4000) * '1 day'::interval)::date;
        bapt_date := ('2014-01-01'::date + ((i * 100 + j * 65 + k * 90) % 3600) * '1 day'::interval)::date;
        phone_num := '(31) 99' || ((9000 + i * 100 + j * 20 + k)::text);

        IF k % 2 = 1 THEN
          r_idx := (i * 37 + j * 14 + k * 23) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          r_idx := (i * 12 + j * 27 + k * 19) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          
          full_nm := m_first || ' ' || l_surname;
          email_addr := lower(m_first) || '.' || lower(l_surname) || '_s' || (i*100+j*10+k) || '@igrejabh.org';
          cpf_val := ((450 + i * 13 + j * 4 + k)::text) || '.' || ((550 + i * 7 + j * 2)::text) || '.' || ((650 + i * 5 + k * 12)::text) || '-99';

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, address_city, address_state, marital_status,
            occupation, education_level, employment_status, household_income, housing_status
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'M', gc_id, 'Belo Horizonte', 'MG', 'Solteiro(a)',
            s_occupations[1 + ((i * 2 + j * 1 + k * 3) % array_length(s_occupations, 1))],
            s_education[1 + ((i * 1 + j * 2 + k * 2) % array_length(s_education, 1))],
            s_employment[1 + ((i * 3 + j * 1 + k) % array_length(s_employment, 1))],
            s_income[1 + ((i + j * 2 + k) % array_length(s_income, 1))],
            s_housing[1 + ((i * 2 + j * 2 + k) % array_length(s_housing, 1))]
          );
        ELSE
          r_idx := (i * 29 + j * 23 + k * 19) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          r_idx := (i * 15 + j * 32 + k * 13) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          
          full_nm := f_first || ' ' || l_surname;
          email_addr := lower(f_first) || '.' || lower(l_surname) || '_s' || (i*100+j*10+k) || '@igrejabh.org';
          cpf_val := ((550 + i * 11 + j * 3 + k)::text) || '.' || ((650 + i * 14 + j * 1)::text) || '.' || ((750 + i * 8 + k * 15)::text) || '-99';

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, address_city, address_state, marital_status,
            occupation, education_level, employment_status, household_income, housing_status
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'F', gc_id, 'Belo Horizonte', 'MG', 'Solteiro(a)',
            s_occupations[1 + ((i * 2 + j * 1 + k * 3) % array_length(s_occupations, 1))],
            s_education[1 + ((i * 1 + j * 2 + k * 2) % array_length(s_education, 1))],
            s_employment[1 + ((i * 3 + j * 1 + k) % array_length(s_employment, 1))],
            s_income[1 + ((i + j * 2 + k) % array_length(s_income, 1))],
            s_housing[1 + ((i * 2 + j * 2 + k) % array_length(s_housing, 1))]
          );
        END IF;

        -- Auth para solteiro ordinário (sem confirmed_at)
        temp_auth_id := extensions.uuid_generate_v4();
        INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change)
        VALUES (
          temp_auth_id,
          '00000000-0000-0000-0000-000000000000',
          email_addr,
          pwd_hash,
          now(),
          '{"provider":"email","providers":["email"]}'::jsonb,
          jsonb_build_object('full_name', full_nm, 'cpf', cpf_val),
          now(),
          now(),
          'authenticated',
          'authenticated',
          '',
          '',
          '',
          ''
        );
      END LOOP;

    END LOOP;
  END LOOP;

  -- ==========================================================================
  -- 5. CONFIGURAÇÃO DE RELACIONAMENTOS DE DISCIPULADO (Árvore Hierárquica)
  -- ==========================================================================
  
  -- 5A. Discipulado de Presbíteros (4 homens)
  UPDATE public.profiles SET discipler_id = presbyters[1] WHERE id IN (presbyters[2], presbyters[3], presbyters[4]);

  -- 5B. Discipulado de Diáconos (6 homens, incluindo Gabriel)
  FOR i IN 1..array_length(deacons, 1) LOOP
    r_idx := (i % 4) + 1;
    UPDATE public.profiles SET discipler_id = presbyters[r_idx] WHERE id = deacons[i];
  END LOOP;

  -- 5C. Discipulado de Outros Líderes de GC (38 homens restantes)
  FOR i IN 1..array_length(leader_ids, 1) LOOP
    temp_profile_id := leader_ids[i];
    IF NOT (temp_profile_id = ANY(presbyters)) AND NOT (temp_profile_id = ANY(deacons)) THEN
      UPDATE public.profiles p
      SET discipler_id = (
        SELECT id FROM public.profiles
        WHERE gender = 'M' 
          AND id <> p.id 
          AND id = ANY(leader_ids)
          AND baptism_date < p.baptism_date
        ORDER BY baptism_date DESC
        LIMIT 1
      )
      WHERE id = temp_profile_id;
    END IF;
  END LOOP;

  -- 5D. Discipulado Geral de Discípulos e Membros Comuns (Homens)
  UPDATE public.profiles p
  SET discipler_id = COALESCE(
    (
      SELECT id FROM public.profiles
      WHERE gender = 'M'
        AND id <> p.id
        AND id = ANY(leader_ids)
        AND baptism_date < p.baptism_date
      ORDER BY baptism_date DESC
      LIMIT 1
    ),
    (
      SELECT id FROM public.profiles
      WHERE gender = 'M'
        AND id <> p.id
        AND baptism_date < p.baptism_date
      ORDER BY baptism_date DESC
      LIMIT 1
    )
  )
  WHERE gender = 'M' 
    AND NOT (id = ANY(leader_ids)) 
    AND NOT (id = ANY(presbyters)) 
    AND NOT (id = ANY(deacons))
    AND baptism_date IS NOT NULL;

  -- 5E. Discipulado de Mulheres
  UPDATE public.profiles p
  SET discipler_id = COALESCE(
    (
      SELECT id FROM public.profiles
      WHERE gender = 'F'
        AND id <> p.id
        AND spouse_id = ANY(leader_ids)
        AND baptism_date < p.baptism_date
      ORDER BY baptism_date DESC
      LIMIT 1
    ),
    (
      SELECT id FROM public.profiles
      WHERE gender = 'F'
        AND id <> p.id
        AND baptism_date < p.baptism_date
      ORDER BY baptism_date DESC
      LIMIT 1
    )
  )
  WHERE gender = 'F'
    AND baptism_date IS NOT NULL;

  -- ==========================================================================
  -- 6. CONFIGURAÇÃO DE COMPANHEIRISMO (Tabela Fellowships)
  -- ==========================================================================

  -- 6A. Companheirismo Completo entre Presbíteros (4 homens)
  FOR i IN 1..4 LOOP
    FOR j IN (i+1)..4 LOOP
      IF i < j THEN
        INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
        VALUES (presbyters[i], presbyters[j], now())
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END LOOP;

  -- 6B. Juntas de Companheirismo para Membros Casados (Homens e Mulheres)
  FOR rec IN SELECT id, gender, baptism_date FROM public.profiles WHERE spouse_id IS NOT NULL LOOP
    FOR rec_comp IN 
      SELECT id FROM public.profiles
      WHERE spouse_id IS NOT NULL 
        AND id <> rec.id 
        AND gender = rec.gender
        AND abs(baptism_date - rec.baptism_date) / 365.25 <= 6.0
      ORDER BY abs(baptism_date - rec.baptism_date) ASC
      LIMIT 2
    LOOP
      IF rec.id < rec_comp.id THEN
        INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
        VALUES (rec.id, rec_comp.id, now())
        ON CONFLICT DO NOTHING;
      ELSE
        INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
        VALUES (rec_comp.id, rec.id, now())
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END LOOP;

  -- 6C. Juntas de Companheirismo para Solteiros e Adolescentes Batizados
  FOR rec IN SELECT id, gender, baptism_date FROM public.profiles WHERE spouse_id IS NULL AND baptism_date IS NOT NULL AND (birth_date >= '1956-01-01' OR user_id IS NOT NULL) LOOP
    FOR rec_comp IN 
      SELECT id FROM public.profiles
      WHERE spouse_id IS NULL AND baptism_date IS NOT NULL AND (birth_date >= '1956-01-01' OR user_id IS NOT NULL)
        AND id <> rec.id 
        AND gender = rec.gender
        AND abs(baptism_date - rec.baptism_date) / 365.25 <= 6.0
      ORDER BY abs(baptism_date - rec.baptism_date) ASC
      LIMIT 2
    LOOP
      IF rec.id < rec_comp.id THEN
        INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
        VALUES (rec.id, rec_comp.id, now())
        ON CONFLICT DO NOTHING;
      ELSE
        INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
        VALUES (rec_comp.id, rec.id, now())
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END LOOP;

  -- 6D. Juntas de Companheirismo para Idosos Fantasmas
  FOR rec IN SELECT id, gender, baptism_date FROM public.profiles WHERE (birth_date < '1956-01-01' AND user_id IS NULL) LOOP
    FOR rec_comp IN 
      SELECT id FROM public.profiles
      WHERE (birth_date < '1956-01-01' AND user_id IS NULL)
        AND id <> rec.id 
        AND gender = rec.gender
        AND abs(baptism_date - rec.baptism_date) / 365.25 <= 10.0
      ORDER BY abs(baptism_date - rec.baptism_date) ASC
      LIMIT 2
    LOOP
      IF rec.id < rec_comp.id THEN
        INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
        VALUES (rec.id, rec_comp.id, now())
        ON CONFLICT DO NOTHING;
      ELSE
        INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
        VALUES (rec_comp.id, rec.id, now())
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END LOOP;

  -- ==========================================================================
  -- 7. DADOS ADICIONAIS: MURAL DE POSTS DE TESTE
  -- ==========================================================================
  INSERT INTO public.posts (author_id, category, title, content, is_published, created_at)
  VALUES 
    (presbyters[1], 'noticia', 'Início da Trilha de Formação Comum', 'Queridos irmãos, iniciamos nossa nova série de estudos sobre "Juntas e Ligamentos no Corpo de Cristo". Os materiais de estudo (Catequese) e vídeos de apoio já estão disponíveis na nossa central de recursos. Participem nos GCs!', true, now() - INTERVAL '1 day'),
    (deacons[1], 'aviso', 'Mutirão de Apoio Diaconal na Pampulha', 'A diaconia está organizando um mutirão para apoio na reforma da casa de um de nossos irmãos no São Gabriel. Será neste próximo sábado às 8h. Tragam ferramentas simples. Quem puder vir, favor confirmar no formulário.', true, now() - INTERVAL '2 days'),
    (presbyters[2], 'oracao', 'Pedido de Oração: Saúde dos Enfermos', 'Irmãos, pedimos orações pela recuperação dos idosos enfermos da nossa comunidade na cidade. Lembramos de orar especialmente nas nossas reuniões de oração aos domingos.', true, now() - INTERVAL '3 days'),
    (deacons[2], 'diaconato', 'Campanha de Arrecadação de Inverno', 'O diaconato inicia hoje a campanha de coleta de cobertores e agasalhos para assistência social das famílias assistidas. As caixas de coleta estão em cada Grupo Caseiro. Agradecemos a generosidade comum.', true, now() - INTERVAL '4 days');

  -- ==========================================================================
  -- 8. DADOS ADICIONAIS: RETIRO E INSCRIÇÕES DE TESTE
  -- ==========================================================================
  INSERT INTO public.retreats (id, title, price, start_date, end_date, description, location_text, max_participants, status, registration_deadline)
  VALUES (
    '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc',
    'Retiro de Solteiros 2026',
    350.00,
    '2026-10-10',
    '2026-10-12',
    'Um tempo precioso de reflexão, palavra e comunhão para todos os jovens e adultos solteiros das nossas comunidades na cidade de Belo Horizonte, Contagem e Betim.',
    'Sítio das Palmeiras, Santa Luzia, MG',
    150,
    'ativo',
    '2026-09-30'
  ) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;

  -- Inscreve Gabriel Góes Braga no Retiro
  IF gabriel_id IS NOT NULL THEN
    INSERT INTO public.registrations (retreat_id, profile_id, paid, payment_method, payment_reference, created_at)
    VALUES ('4faf45cb-c431-48f6-9d3f-598fbe9e5bcc', gabriel_id, true, 'pix', 'REF-SEED-GABRIEL-123', now());
  END IF;

  -- Inscreve alguns solteiros aleatórios
  FOR rec IN SELECT id FROM public.profiles WHERE spouse_id IS NULL AND baptism_date IS NOT NULL AND id <> gabriel_id LIMIT 10 LOOP
    INSERT INTO public.registrations (retreat_id, profile_id, paid, payment_method, payment_reference, created_at)
    VALUES (
      '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc', 
      rec.id, 
      ((random() > 0.4)), -- 60% pago
      'pix', 
      'REF-SEED-SOLTEIRO-' || substring((rec.id)::text from 1 for 6), 
      now() - (random() * 5 * INTERVAL '1 day')
    );
  END LOOP;

  -- ==========================================================================
  -- 9. HIGIENE DE CAMPOS OBRIGATÓRIOS (Para passar no ProfileCompletionBlocker)
  -- ==========================================================================
  UPDATE public.profiles
  SET
    address_street = COALESCE(NULLIF(address_street, ''), 'Rua dos Discípulos'),
    address_number = COALESCE(NULLIF(address_number, ''), '120'),
    address_neighborhood = COALESCE(NULLIF(address_neighborhood, ''), 'Centro'),
    address_zip_code = COALESCE(NULLIF(address_zip_code, ''), '30123-456'),
    drivers_license = COALESCE(NULLIF(drivers_license, ''), 'Não possui'),
    phone = COALESCE(NULLIF(phone, ''), '(31) 99000-0000'),
    occupation = COALESCE(NULLIF(occupation, ''), 'Estudante'),
    education_level = COALESCE(NULLIF(education_level, ''), 'Ensino Médio'),
    employment_status = COALESCE(NULLIF(employment_status, ''), 'Outro'),
    household_income = COALESCE(NULLIF(household_income, ''), '1 a 2 salários mínimos'),
    housing_status = COALESCE(NULLIF(housing_status, ''), 'Própria'),
    dependents_count = COALESCE(dependents_count, 0)
  WHERE user_id IS NOT NULL;

END $$;
