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
  
  -- 5A. Discipulado de Presbíteros (4 homens) e suas esposas (4 mulheres)
  -- Presbíteros e suas esposas não possuem discipuladores (discipler_id = NULL). Eles possuem apenas companheirismo mútuo.
  UPDATE public.profiles SET discipler_id = NULL WHERE id IN (presbyters[1], presbyters[2], presbyters[3], presbyters[4]);
  UPDATE public.profiles SET discipler_id = NULL WHERE spouse_id IN (presbyters[1], presbyters[2], presbyters[3], presbyters[4]) AND gender = 'F';

  -- 5B. Discipulado de Diáconos (6 homens, incluindo Gabriel) e suas esposas (6 mulheres)
  -- Distribuídos de forma equilibrada sob os 4 presbíteros e suas esposas.
  -- Ex: Diácono é discipulado por Presbítero, Esposa de Diácono é discipada por Esposa de Presbítero.
  FOR i IN 1..array_length(deacons, 1) LOOP
    r_idx := ((i - 1) % 4) + 1;
    DECLARE
      v_presbyter_id uuid := presbyters[r_idx];
      v_deacon_id uuid := deacons[i];
      v_presbyter_wife_id uuid;
      v_deacon_wife_id uuid;
    BEGIN
      SELECT id INTO v_presbyter_wife_id FROM public.profiles WHERE spouse_id = v_presbyter_id AND gender = 'F';
      SELECT id INTO v_deacon_wife_id FROM public.profiles WHERE spouse_id = v_deacon_id AND gender = 'F';
      
      -- Maridos
      UPDATE public.profiles SET discipler_id = v_presbyter_id WHERE id = v_deacon_id;
      -- Esposas
      IF v_presbyter_wife_id IS NOT NULL AND v_deacon_wife_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_presbyter_wife_id WHERE id = v_deacon_wife_id;
      END IF;
    END;
  END LOOP;

  -- 5C. Discipulado de Outros Líderes de GC (38 casais restantes)
  -- Processados por ordem de batismo do marido crescente. Casal é discipulado por outro Casal.
  DECLARE
    r_leader_couple RECORD;
    v_parent_husband_id uuid;
    v_parent_wife_id uuid;
  BEGIN
    FOR r_leader_couple IN 
      SELECT 
        h.id AS husband_id, 
        w.id AS wife_id, 
        h.baptism_date AS husband_bapt, 
        w.baptism_date AS wife_bapt
      FROM public.profiles h
      JOIN public.profiles w ON h.spouse_id = w.id
      WHERE h.gender = 'M' AND w.gender = 'F'
        AND h.id = ANY(leader_ids)
        AND NOT (h.id = ANY(presbyters)) 
        AND NOT (h.id = ANY(deacons))
      ORDER BY h.baptism_date ASC, h.id ASC
    LOOP
      SELECT 
        parent_h.id, parent_w.id INTO v_parent_husband_id, v_parent_wife_id
      FROM public.profiles parent_h
      JOIN public.profiles parent_w ON parent_h.spouse_id = parent_w.id
      WHERE parent_h.gender = 'M' AND parent_w.gender = 'F'
        AND parent_h.id = ANY(leader_ids)
        AND (parent_h.discipler_id IS NOT NULL OR parent_h.id = ANY(presbyters))
        AND parent_h.baptism_date < r_leader_couple.husband_bapt
        AND parent_w.baptism_date < r_leader_couple.wife_bapt
        AND (
          SELECT count(*) FROM public.profiles WHERE discipler_id = parent_h.id
        ) < 3
        AND (
          SELECT count(*) FROM public.profiles WHERE discipler_id = parent_w.id
        ) < 3
      ORDER BY parent_h.baptism_date ASC, parent_h.id ASC
      LIMIT 1;

      IF v_parent_husband_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_leader_couple.husband_id;
        UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_leader_couple.wife_id;
      ELSE
        -- Fallback: ignora maturidade da esposa e ajusta se necessário
        SELECT 
          parent_h.id, parent_w.id INTO v_parent_husband_id, v_parent_wife_id
        FROM public.profiles parent_h
        JOIN public.profiles parent_w ON parent_h.spouse_id = parent_w.id
        WHERE parent_h.gender = 'M' AND parent_w.gender = 'F'
          AND parent_h.id = ANY(leader_ids)
          AND (parent_h.discipler_id IS NOT NULL OR parent_h.id = ANY(presbyters))
          AND parent_h.baptism_date < r_leader_couple.husband_bapt
        ORDER BY parent_h.baptism_date ASC, parent_h.id ASC
        LIMIT 1;

        IF v_parent_husband_id IS NOT NULL THEN
          UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_leader_couple.husband_id;
          UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_leader_couple.wife_id;
          
          -- Ajustar data de batismo
          DECLARE
            v_parent_wife_bapt date;
          BEGIN
            SELECT baptism_date INTO v_parent_wife_bapt FROM public.profiles WHERE id = v_parent_wife_id;
            IF v_parent_wife_bapt >= r_leader_couple.wife_bapt THEN
              UPDATE public.profiles 
              SET baptism_date = (r_leader_couple.wife_bapt - INTERVAL '1 day')::date 
              WHERE id = v_parent_wife_id;
            END IF;
          END;
        ELSE
          -- Fallback 2: Se nenhum casal líder com batismo mais antigo for encontrado, associa ao primeiro presbítero e esposa
          v_parent_husband_id := presbyters[1];
          SELECT id INTO v_parent_wife_id FROM public.profiles WHERE spouse_id = v_parent_husband_id AND gender = 'F';
          
          IF v_parent_husband_id IS NOT NULL AND v_parent_wife_id IS NOT NULL THEN
            UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_leader_couple.husband_id;
            UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_leader_couple.wife_id;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END;

  -- 5D. Discipulado Geral de Casais Comuns (48 casais)
  -- Processados por ordem de batismo do marido crescente. Casal é discipulado por outro Casal.
  DECLARE
    r_member_couple RECORD;
    v_parent_husband_id uuid;
    v_parent_wife_id uuid;
  BEGIN
    FOR r_member_couple IN 
      SELECT 
        h.id AS husband_id, 
        w.id AS wife_id, 
        h.baptism_date AS husband_bapt, 
        w.baptism_date AS wife_bapt
      FROM public.profiles h
      JOIN public.profiles w ON h.spouse_id = w.id
      WHERE h.gender = 'M' AND w.gender = 'F'
        AND NOT (h.id = ANY(leader_ids))
        AND h.baptism_date IS NOT NULL AND w.baptism_date IS NOT NULL
      ORDER BY h.baptism_date ASC, h.id ASC
    LOOP
      SELECT 
        parent_h.id, parent_w.id INTO v_parent_husband_id, v_parent_wife_id
      FROM public.profiles parent_h
      JOIN public.profiles parent_w ON parent_h.spouse_id = parent_w.id
      WHERE parent_h.gender = 'M' AND parent_w.gender = 'F'
        AND (parent_h.discipler_id IS NOT NULL OR parent_h.id = ANY(presbyters))
        AND parent_h.baptism_date < r_member_couple.husband_bapt
        AND parent_w.baptism_date < r_member_couple.wife_bapt
        AND (
          SELECT count(*) FROM public.profiles WHERE discipler_id = parent_h.id
        ) < 3
        AND (
          SELECT count(*) FROM public.profiles WHERE discipler_id = parent_w.id
        ) < 3
      ORDER BY parent_h.baptism_date ASC, parent_h.id ASC
      LIMIT 1;

      IF v_parent_husband_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_member_couple.husband_id;
        UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_member_couple.wife_id;
      ELSE
        -- Fallback
        SELECT 
          parent_h.id, parent_w.id INTO v_parent_husband_id, v_parent_wife_id
        FROM public.profiles parent_h
        JOIN public.profiles parent_w ON parent_h.spouse_id = parent_w.id
        WHERE parent_h.gender = 'M' AND parent_w.gender = 'F'
          AND (parent_h.discipler_id IS NOT NULL OR parent_h.id = ANY(presbyters))
          AND parent_h.baptism_date < r_member_couple.husband_bapt
        ORDER BY parent_h.baptism_date ASC, parent_h.id ASC
        LIMIT 1;

        IF v_parent_husband_id IS NOT NULL THEN
          UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_member_couple.husband_id;
          UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_member_couple.wife_id;
          
          -- Ajustar data de batismo
          DECLARE
            v_parent_wife_bapt date;
          BEGIN
            SELECT baptism_date INTO v_parent_wife_bapt FROM public.profiles WHERE id = v_parent_wife_id;
            IF v_parent_wife_bapt >= r_member_couple.wife_bapt THEN
              UPDATE public.profiles 
              SET baptism_date = (r_member_couple.wife_bapt - INTERVAL '1 day')::date 
              WHERE id = v_parent_wife_id;
            END IF;
          END;
        ELSE
          -- Fallback 2: Se nenhum casal com batismo mais antigo for encontrado, associa ao primeiro presbítero e esposa
          v_parent_husband_id := presbyters[1];
          SELECT id INTO v_parent_wife_id FROM public.profiles WHERE spouse_id = v_parent_husband_id AND gender = 'F';
          
          IF v_parent_husband_id IS NOT NULL AND v_parent_wife_id IS NOT NULL THEN
            UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_member_couple.husband_id;
            UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_member_couple.wife_id;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END;

  -- 5E. Discipulado de Membros Solteiros (Homens e Mulheres Individuais)
  -- Processados individualmente por ordem de batismo crescente.
  
  -- 5E.1 Solteiros Homens
  DECLARE
    r_single_man RECORD;
    v_parent_id uuid;
  BEGIN
    FOR r_single_man IN 
      SELECT id, baptism_date 
      FROM public.profiles 
      WHERE gender = 'M' AND spouse_id IS NULL AND baptism_date IS NOT NULL
      ORDER BY baptism_date ASC, id ASC
    LOOP
      SELECT id INTO v_parent_id
      FROM public.profiles parent
      WHERE parent.gender = 'M'
        AND parent.baptism_date < r_single_man.baptism_date
        AND (
          SELECT count(*) FROM public.profiles WHERE discipler_id = parent.id
        ) < 3
      ORDER BY parent.baptism_date ASC, parent.id ASC
      LIMIT 1;

      IF v_parent_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_man.id;
      ELSE
        -- Fallback 1: ignora o limite de 3 discipulandos
        SELECT id INTO v_parent_id
        FROM public.profiles parent
        WHERE parent.gender = 'M'
          AND parent.baptism_date < r_single_man.baptism_date
        ORDER BY parent.baptism_date ASC, parent.id ASC
        LIMIT 1;
        
        IF v_parent_id IS NOT NULL THEN
          UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_man.id;
        ELSE
          -- Fallback 2: Se for o homem mais antigo em batismo, associa ao primeiro presbítero
          v_parent_id := presbyters[1];
          IF v_parent_id IS NOT NULL THEN
            UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_man.id;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END;

  -- 5E.2 Solteiras Mulheres
  DECLARE
    r_single_woman RECORD;
    v_parent_id uuid;
  BEGIN
    FOR r_single_woman IN 
      SELECT id, baptism_date 
      FROM public.profiles 
      WHERE gender = 'F' AND spouse_id IS NULL AND baptism_date IS NOT NULL
      ORDER BY baptism_date ASC, id ASC
    LOOP
      SELECT id INTO v_parent_id
      FROM public.profiles parent
      WHERE parent.gender = 'F'
        AND parent.baptism_date < r_single_woman.baptism_date
        AND (
          SELECT count(*) FROM public.profiles WHERE discipler_id = parent.id
        ) < 3
      ORDER BY parent.baptism_date ASC, parent.id ASC
      LIMIT 1;

      IF v_parent_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_woman.id;
      ELSE
        -- Fallback 1: ignora o limite de 3 discipulandos
        SELECT id INTO v_parent_id
        FROM public.profiles parent
        WHERE parent.gender = 'F'
          AND parent.baptism_date < r_single_woman.baptism_date
        ORDER BY parent.baptism_date ASC, parent.id ASC
        LIMIT 1;
        
        IF v_parent_id IS NOT NULL THEN
          UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_woman.id;
        ELSE
          -- Fallback 2: Se for a mulher mais antiga em batismo, associa à esposa de um dos presbíteros
          SELECT id INTO v_parent_id
          FROM public.profiles
          WHERE spouse_id = ANY(presbyters) AND gender = 'F'
          LIMIT 1;
          
          IF v_parent_id IS NOT NULL THEN
            UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_woman.id;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END;

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

  -- 6A_Wives. Companheirismo Completo entre Esposas de Presbíteros (4 mulheres)
  DECLARE
    v_presbyter_wives uuid[] := ARRAY[]::uuid[];
  BEGIN
    SELECT array_agg(id) INTO v_presbyter_wives
    FROM public.profiles
    WHERE spouse_id = ANY(presbyters) AND gender = 'F';

    FOR i IN 1..4 LOOP
      FOR j IN (i+1)..4 LOOP
        IF i < j THEN
          INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
          VALUES (v_presbyter_wives[i], v_presbyter_wives[j], now())
          ON CONFLICT DO NOTHING;
        END IF;
      END LOOP;
    END LOOP;
  END;

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
  
  -- 8A. Criar formulário de inscrição do retiro
  INSERT INTO public.forms (id, name, description, fields, is_public, created_at, is_active)
  VALUES (
    'form-solteiros-2026',
    'Ficha de Inscrição Complementar - Retiro de Solteiros 2026',
    'Por favor, responda às perguntas adicionais para a logística do retiro.',
    '[
      {
        "id": "tamanho_camiseta",
        "type": "select",
        "label": "Tamanho da Camiseta",
        "placeholder": "Selecione o tamanho",
        "required": true,
        "helpText": "Camiseta oficial do retiro",
        "options": ["P", "M", "G", "GG"]
      },
      {
        "id": "restricoes_alimentares",
        "type": "text",
        "label": "Restrições Alimentares",
        "placeholder": "Descreva se houver restrições (ex: alergias, vegetariano)",
        "required": false,
        "helpText": "Para a logística da cozinha",
        "options": []
      },
      {
        "id": "transporte",
        "type": "radio",
        "label": "Precisa de Transporte?",
        "placeholder": "",
        "required": true,
        "helpText": "Teremos ônibus saindo da igreja na cidade",
        "options": ["Sim", "Não"]
      }
    ]'::jsonb,
    true,
    now(),
    true
  ) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, fields = EXCLUDED.fields;

  -- 8B. Criar Retiro de Solteiros 2026
  INSERT INTO public.retreats (id, title, price, start_date, end_date, description, location_text, max_participants, status, registration_deadline, form_id)
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
    '2026-09-30',
    'form-solteiros-2026'
  ) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, form_id = EXCLUDED.form_id;

  -- 8C. Inscreve Gabriel Góes Braga no Retiro
  IF gabriel_id IS NOT NULL THEN
    DECLARE
      v_sub_id text := 'sub-gabriel-123';
      v_user_id uuid;
    BEGIN
      SELECT user_id INTO v_user_id FROM public.profiles WHERE id = gabriel_id;
      
      -- Criar a submissão do formulário
      INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
      VALUES (
        v_sub_id,
        'form-solteiros-2026',
        '{"tamanho_camiseta": "G", "restricoes_alimentares": "Nenhuma", "transporte": "Não"}'::jsonb,
        v_user_id,
        now()
      );

      -- Criar a inscrição apontando para a submissão
      INSERT INTO public.registrations (
        retreat_id, profile_id, paid, payment_method, payment_reference, created_at, form_submission_id, custom_responses
      )
      VALUES (
        '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc', 
        gabriel_id, 
        true, 
        'pix', 
        'REF-SEED-GABRIEL-123', 
        now(), 
        v_sub_id,
        '{"Tamanho da Camiseta": "G", "Restrições Alimentares": "Nenhuma", "Precisa de Transporte?": "Não"}'::jsonb
      );
    END;
  END IF;

  -- 8D. Inscreve alguns solteiros aleatórios com suas respectivas submissões
  DECLARE
    v_sub_id text;
    v_user_id uuid;
    v_tamanho text;
    v_transporte text;
    v_count int := 0;
    v_rec RECORD;
  BEGIN
    FOR v_rec IN 
      SELECT id, user_id 
      FROM public.profiles 
      WHERE spouse_id IS NULL AND baptism_date IS NOT NULL AND id <> gabriel_id 
      LIMIT 10 
    LOOP
      v_count := v_count + 1;
      v_sub_id := 'sub-solteiro-' || v_count || '-' || substring((v_rec.id)::text from 1 for 6);
      
      -- Respostas aleatórias
      v_tamanho := (ARRAY['P', 'M', 'G', 'GG'])[1 + (v_count % 4)];
      v_transporte := CASE WHEN v_count % 3 = 0 THEN 'Sim' ELSE 'Não' END;

      -- Inserir submissão do formulário
      INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
      VALUES (
        v_sub_id,
        'form-solteiros-2026',
        jsonb_build_object('tamanho_camiseta', v_tamanho, 'restricoes_alimentares', 'Nenhuma', 'transporte', v_transporte),
        v_rec.user_id,
        now() - (v_count * INTERVAL '12 hours')
      );

      -- Inserir inscrição
      INSERT INTO public.registrations (
        retreat_id, profile_id, paid, payment_method, payment_reference, created_at, form_submission_id, custom_responses
      )
      VALUES (
        '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc', 
        v_rec.id, 
        ((random() > 0.4)), -- 60% pago
        'pix', 
        'REF-SEED-SOLTEIRO-' || substring((v_rec.id)::text from 1 for 6), 
        now() - (v_count * INTERVAL '12 hours'),
        v_sub_id,
        jsonb_build_object('Tamanho da Camiseta', v_tamanho, 'Restrições Alimentares', 'Nenhuma', 'Precisa de Transporte?', v_transporte)
      );
    END LOOP;
  END;

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
