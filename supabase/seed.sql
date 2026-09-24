-- ============================================================================
-- SCRIPT DE SEEDING: IGREJA EM BELO HORIZONTE (PORTAL DE VIDA COMUM)
-- Geração programática de 528 discípulos, 24 GCs, 6 setores, laços de juntas,
-- mural de avisos (posts), centro de ensinos/catequese, multi-eventos e formulários.
-- ============================================================================

DO $$
DECLARE
  -- Listas de Nomes e Sobrenomes Brasileiros realistas
  s_names text[] := ARRAY[
    'Gabriel', 'Lucas', 'Tiago', 'Felipe', 'Mateus', 'Marcos', 'André', 'Roberto', 
    'Cláudio', 'Carlos', 'João', 'Pedro', 'Antônio', 'Paulo', 'José', 'Francisco', 
    'Luiz', 'Geraldo', 'Sebastião', 'Raimundo', 'Walter', 'Rodrigo', 'Daniel', 
    'Renato', 'Julio', 'Ricardo', 'Eduardo', 'Arthur', 'Bruno', 'Marcelo', 
    'Breno', 'Hugo', 'Rafael', 'Vinícius', 'Gustavo', 'Diego', 'Leonardo', 'Thiago', 
    'Alexandre', 'Fernando', 'Guilherme', 'Samuel', 'Henrique', 'Vitor', 'Caio'
  ];
  
  s_fnames text[] := ARRAY[
    'Sandra', 'Carolina', 'Regina', 'Mariana', 'Patrícia', 'Laura', 'Juliana', 
    'Cláudia', 'Letícia', 'Camila', 'Amanda', 'Maria', 'Helena', 'Nair', 'Terezinha', 
    'Lourdes', 'Ana', 'Beatriz', 'Júlia', 'Cristina', 'Fernanda', 'Gabriela', 
    'Aline', 'Sofia', 'Renata', 'Sônia', 'Marta', 'Luciana', 'Clara', 'Luiza', 
    'Isadora', 'Larissa', 'Mariane', 'Priscila', 'Natália', 'Cecília', 'Olívia', 
    'Vanessa', 'Daniela', 'Tatiane', 'Débora', 'Raquel', 'Rebeca', 'Talita'
  ];
  
  s_surnames text[] := ARRAY[
    'Silva', 'Santos', 'Oliveira', 'Souza', 'Pereira', 'Lima', 'Costa', 'Alves', 
    'Nogueira', 'Martins', 'Pinto', 'Rocha', 'Mendes', 'Gomes', 'Freitas', 
    'Barbosa', 'Araújo', 'Cardoso', 'Carvalho', 'Teixeira', 'Ribeiro', 'Vieira', 
    'Monteiro', 'Borges', 'Moraes', 'Nunes', 'Castro', 'Coelho', 'Dantas', 
    'Ferreira', 'Batista', 'Miranda', 'Guimarães', 'Campos', 'Machado', 'Reis'
  ];
  
  -- Metadados profissionais e socioeconômicos para o painel diaconal
  s_occupations text[] := ARRAY[
    'Engenheiro Civil', 'Professora de Ensino Básico', 'Desenvolvedor de Software', 
    'Médica Pediatra', 'Advogado Trabalhista', 'Vendedor Comercial', 'Administrador', 
    'Mecânico Automotivo', 'Eletricista Predial', 'Designer Gráfico', 'Aposentado(a)', 
    'Estudante Universitário', 'Arquiteta', 'Contador', 'Auxiliar Administrativo', 
    'Motorista de Aplicativo', 'Enfermeira Chefe', 'Empresário', 'Zelador', 'Pedreiro', 
    'Nutricionista', 'Psicóloga', 'Farmacêutico', 'Analista Financeiro'
  ];
  s_housing text[] := ARRAY['Própria', 'Alugada', 'Financiada', 'Cedida'];
  s_income text[] := ARRAY['menos de 1 salário mínimo', '1 a 2 salários mínimos', '2 a 5 salários mínimos', 'mais de 5 salários mínimos'];
  s_education text[] := ARRAY['Ensino Fundamental', 'Ensino Médio', 'Ensino Superior', 'Pós-graduação'];
  s_employment text[] := ARRAY['CLT', 'Autônomo', 'Empresário', 'Servidor Público', 'Desempregado', 'Aposentado'];
  
  -- Curadoria de Avatares (Unsplash Portraits de Alta Definição)
  s_avatars_male text[] := ARRAY[
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1545167622-3a6ac756afa4?w=200&auto=format&fit=crop&q=80'
  ];
  
  s_avatars_female text[] := ARRAY[
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=200&auto=format&fit=crop&q=80'
  ];

  -- Setores metropolitanos solicitados
  sector_ids uuid[] := ARRAY[]::uuid[];
  sector_names text[] := ARRAY['Barreiro/Oeste', 'Pampulha/São Gabriel', 'Santa Luzia', 'Venda Nova', 'Betim', 'Contagem'];
  sector_lats float8[] := ARRAY[-19.9700, -19.8500, -19.7700, -19.8000, -19.9600, -19.9300];
  sector_lngs float8[] := ARRAY[-44.0200, -43.9600, -43.8500, -43.9900, -44.2000, -44.0500];
  
  -- Mapeamento de GCs por Setor (4 GCs por setor) com Bairros e Ruas reais da Grande BH
  gc_names text[][] := ARRAY[
    ARRAY['GC Buritis', 'GC Barreiro', 'GC Estoril', 'GC Gutierrez'],
    ARRAY['GC Ouro Preto', 'GC Castelo', 'GC São Gabriel', 'GC Dona Clara'],
    ARRAY['GC Cristina', 'GC Frimisa', 'GC São Benedito', 'GC Centro Santa Luzia'],
    ARRAY['GC Planalto', 'GC Letícia', 'GC Mantiqueira', 'GC Candelária'],
    ARRAY['GC Centro Betim', 'GC Alterosa', 'GC PTB', 'GC Imbiruçu'],
    ARRAY['GC Eldorado', 'GC Industrial', 'GC Novo Eldorado', 'GC Cabral']
  ];

  gc_streets text[][] := ARRAY[
    ARRAY['Av. Professor Mário Werneck', 'Av. Afonso Vaz de Melo', 'Av. Barão Homem de Melo', 'Rua André Cavalcanti'],
    ARRAY['Rua Monteiro Lobato', 'Av. Altamiro Avelino Soares', 'Rua Jacuí', 'Rua Ouro Fino'],
    ARRAY['Av. Joaquim Lourenço de Oliveira', 'Rua das Flores', 'Av. Brasília', 'Rua Direita'],
    ARRAY['Rua Cristiano Guimarães', 'Rua Padre Pedro Pinto', 'Rua José Félix Martins', 'Av. Vilarinho'],
    ARRAY['Av. Governador Valadares', 'Av. Campos de Ourique', 'Av. Rio Madeira', 'Av. São Caetano'],
    ARRAY['Av. José Faria da Rocha', 'Av. Cel. Benjamim Guimarães', 'Rua Dr. Cassiano', 'Alameda dos Sabiás']
  ];

  gc_neighborhoods text[][] := ARRAY[
    ARRAY['Buritis', 'Barreiro', 'Estoril', 'Gutierrez'],
    ARRAY['Ouro Preto', 'Castelo', 'São Gabriel', 'Dona Clara'],
    ARRAY['Cristina', 'Frimisa', 'São Benedito', 'Centro'],
    ARRAY['Planalto', 'Letícia', 'Mantiqueira', 'Candelária'],
    ARRAY['Centro', 'Jardim Alterosa', 'PTB', 'Imbiruçu'],
    ARRAY['Eldorado', 'Industrial', 'Novo Eldorado', 'Cabral']
  ];

  gc_cities text[] := ARRAY['Belo Horizonte', 'Belo Horizonte', 'Santa Luzia', 'Belo Horizonte', 'Betim', 'Contagem'];

  gc_ceps text[][] := ARRAY[
    ARRAY['30575-180', '30640-070', '30494-080', '30441-110'],
    ARRAY['31310-530', '31330-000', '31980-110', '31260-230'],
    ARRAY['33115-460', '33010-200', '33120-510', '33010-000'],
    ARRAY['31720-300', '31570-000', '31655-000', '31615-250'],
    ARRAY['32600-110', '32670-380', '32684-000', '32677-110'],
    ARRAY['32310-000', '32210-010', '32341-020', '32146-040']
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
  all_member_ids uuid[] := ARRAY[]::uuid[];
  
  -- Gabriel Braga ID
  gabriel_id uuid;

  -- Variáveis temporárias de laço
  i int;
  j int;
  k int;
  r_idx int;
  temp_profile_id uuid;
  temp_auth_id uuid;
  pwd_hash text;
  
  -- Sequenciadores globais para garantir unicidade estrita e formatos válidos
  email_seq int := 100;
  cpf_seq int := 100;
  phone_seq int := 100;
  domains text[] := ARRAY['igrejabh.org', 'gmail.com', 'outlook.com', 'yahoo.com.br'];
  
  -- Estruturas de casais e membros
  l_husband_id uuid;
  l_wife_id uuid;
  f_husband_id uuid;
  f_wife_id uuid;
  
  -- Atributos de discípulo
  m_first text;
  f_first text;
  l_surname text;
  full_nm text;
  email_addr text;
  phone_num text;
  cpf_val text;
  b_date date;
  bapt_date date;
  st_addr text;
  num_addr text;
  neigh_addr text;
  city_addr text;
  cep_addr text;
  avatar_val text;

  -- Cursores de pós-processamento de juntas
  rec RECORD;
  rec_comp RECORD;

  -- Variáveis de Retiros, Quartos, Estudos e Formulários
  r_retreat_active uuid := '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc';
  r_retreat_closed uuid := 'a1b2c3d4-e5f6-47a8-b9c0-112233445566';
  r_retreat_draft  uuid := 'b2c3d4e5-f6a7-48b9-c0d1-223344556677';
  
  -- IDs de Quartos
  r_act_chale_m1 uuid := extensions.uuid_generate_v4();
  r_act_chale_m2 uuid := extensions.uuid_generate_v4();
  r_act_dorm_m3  uuid := extensions.uuid_generate_v4();
  r_act_chale_f1 uuid := extensions.uuid_generate_v4();
  r_act_chale_f2 uuid := extensions.uuid_generate_v4();
  r_act_dorm_f3  uuid := extensions.uuid_generate_v4();
  r_act_suite_1  uuid := extensions.uuid_generate_v4();
  r_act_suite_2  uuid := extensions.uuid_generate_v4();

  r_cls_dorm_m1  uuid := extensions.uuid_generate_v4();
  r_cls_dorm_f1  uuid := extensions.uuid_generate_v4();
  r_cls_suite_1  uuid := extensions.uuid_generate_v4();
  r_cls_suite_2  uuid := extensions.uuid_generate_v4();
  r_cls_chale_m2 uuid := extensions.uuid_generate_v4();
  r_cls_chale_f2 uuid := extensions.uuid_generate_v4();

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

  -- IDs de Estudos
  study_id1 uuid := extensions.uuid_generate_v4();
  study_id2 uuid := extensions.uuid_generate_v4();
  study_id3 uuid := extensions.uuid_generate_v4();
  
  -- IDs de Steps
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
  -- 1. LIMPEZA TOTAL ATÔMICA DO BANCO DE DESENVOLVIMENTO
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
    public.forms, 
    public.form_submissions, 
    public.media_resources,
    public.studies,
    public.study_steps,
    public.user_study_progress 
  CASCADE;
  
  DELETE FROM auth.users;

  -- Senha padrão pré-calculada para "senha123" usando Blowfish bcrypt salt
  pwd_hash := '$2a$06$XqL/cRckHcXJ1xzAYPKQUORulnZ8gYmOlK1FwEvihHPa7trFLTl9.';

  -- ==========================================================================
  -- 2. CRIAÇÃO DOS SETORES GEOGRÁFICOS METROPOLITANOS
  -- ==========================================================================
  FOR i IN 1..6 LOOP
    sec_id := extensions.uuid_generate_v4();
    sector_ids := array_append(sector_ids, sec_id);
    INSERT INTO public.sectors (id, name, created_at)
    VALUES (sec_id, sector_names[i], now());
  END LOOP;

  -- ==========================================================================
  -- 3. CRIAÇÃO PROGRAMÁTICA DOS LÍDERES DE GRUPO CASEIRO (48 Homens Casados)
  -- ==========================================================================
  FOR i IN 1..6 LOOP -- Setores
    FOR j IN 1..4 LOOP -- GCs
      FOR k IN 1..2 LOOP -- 2 líderes por GC
        temp_profile_id := extensions.uuid_generate_v4();
        
        -- Configuração Oficial para Gabriel Góes Braga (Líder 1 do GC São Gabriel)
        -- GC São Gabriel é Setor 2 (Pampulha/SG), GC 3, Líder 1
        IF i = 2 AND j = 3 AND k = 1 THEN
          full_nm := 'Gabriel Góes Braga';
          email_addr := 'ggoesbraga@gmail.com';
          cpf_val := '132.507.246-02';
          b_date := '1995-07-08'::date;
          bapt_date := '2012-06-15'::date;
          phone_num := '(31) 99888-7777';
          gabriel_id := temp_profile_id;
          avatar_val := 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80';
        ELSE
          email_seq := email_seq + 1;
          cpf_seq := cpf_seq + 1;
          phone_seq := phone_seq + 1;
          
          r_idx := (i * 100 + j * 10 + k * 3) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          
          r_idx := (i * 50 + j * 13 + k * 7) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          
          full_nm := m_first || ' ' || l_surname;
          email_addr := lower(m_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
          cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');
          phone_num := '(31) 9' || ((8000 + phone_seq % 1900)::text) || '-' || lpad(((phone_seq * 37) % 8999 + 1000)::text, 4, '0');
          
          b_date := ('1965-01-01'::date + ((i * 450 + j * 210 + k * 80) % 8000) * '1 day'::interval)::date;
          bapt_date := (b_date + '18 years'::interval + ((i * 110 + j * 90 + k * 45) % 2500) * '1 day'::interval)::date;
          avatar_val := s_avatars_male[1 + ((i * 3 + j * 2 + k) % array_length(s_avatars_male, 1))];
        END IF;

        st_addr := gc_streets[i][j];
        num_addr := ((120 + i * 35 + j * 22 + k * 14)::text);
        neigh_addr := gc_neighborhoods[i][j];
        city_addr := gc_cities[i];
        cep_addr := gc_ceps[i][j];

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
            is_dev, is_presbyter, is_deacon, can_post, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code,
            occupation, education_level, employment_status, household_income, housing_status, marital_status,
            drivers_license, dependents_count, avatar_url
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'M',
            (i = 2 AND j = 3 AND k = 1),
            is_presb, is_deac, true,
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr,
            s_occupations[1 + ((i * 3 + j * 2 + k) % array_length(s_occupations, 1))],
            s_education[1 + ((i * 2 + j * 3 + k) % array_length(s_education, 1))],
            s_employment[1 + ((i * 4 + j + k) % array_length(s_employment, 1))],
            s_income[1 + ((i * 2 + j * 3 + k) % array_length(s_income, 1))],
            s_housing[1 + ((i + j * 2 + k) % array_length(s_housing, 1))],
            'Casado(a)', 'Sim (B)', 2, avatar_val
          );

          temp_auth_id := extensions.uuid_generate_v4();
          INSERT INTO auth.users (
            id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
            created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change
          ) VALUES (
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
            '', '', '', ''
          );

          leader_ids := array_append(leader_ids, temp_profile_id);
          all_member_ids := array_append(all_member_ids, temp_profile_id);

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
  -- 4. CRIAÇÃO DOS GCs E POVOAMENTO DOS DISCÍPULOS
  -- ==========================================================================
  FOR i IN 1..6 LOOP -- Setores
    FOR j IN 1..4 LOOP -- GCs
      l_husband_id := leader_ids[((i - 1) * 8 + (j - 1) * 2 + 1)];
      l_wife_id := leader_ids[((i - 1) * 8 + (j - 1) * 2 + 2)];
      
      gc_id := extensions.uuid_generate_v4();
      gc_lat := sector_lats[i] + (((i * 27 + j * 41) % 100)::float8 / 2500.0 - 0.02);
      gc_lng := sector_lngs[i] + (((i * 19 + j * 53) % 100)::float8 / 2500.0 - 0.02);
      
      INSERT INTO public.home_groups (
        id, meeting_day, location_text, leader_1_id, leader_2_id, lat, lng, start_time, sector_id, created_at
      ) VALUES (
        gc_id,
        ((i + j) % 5 + 2),
        gc_names[i][j] || ' - ' || gc_streets[i][j] || ', ' || (150 + i * j * 14) || ', ' || gc_neighborhoods[i][j] || ', ' || gc_cities[i] || ' - MG',
        l_husband_id,
        l_wife_id,
        gc_lat,
        gc_lng,
        '19:30:00',
        sector_ids[i],
        now()
      );

      UPDATE public.profiles SET home_group_id = gc_id WHERE id IN (l_husband_id, l_wife_id);

      -- ========================================================================
      -- 4A. ESPOSAS DOS LÍDERES (2 Mulheres Casadas por GC)
      -- ========================================================================
      FOR k IN 1..2 LOOP
        DECLARE
          m_id uuid := CASE WHEN k = 1 THEN l_husband_id ELSE l_wife_id END;
          m_profile RECORD;
        BEGIN
          SELECT * INTO m_profile FROM public.profiles WHERE id = m_id;
          
          email_seq := email_seq + 1;
          cpf_seq := cpf_seq + 1;
          phone_seq := phone_seq + 1;

          temp_profile_id := extensions.uuid_generate_v4();
          r_idx := (i * 45 + j * 21 + k * 19) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          
          l_surname := split_part(m_profile.full_name, ' ', 2);
          IF l_surname = '' THEN l_surname := s_surnames[(i*j+k)%array_length(s_surnames,1)+1]; END IF;
          
          full_nm := f_first || ' ' || l_surname;
          email_addr := lower(f_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
          cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');
          b_date := m_profile.birth_date + '1 year'::interval;
          bapt_date := ('2003-01-01'::date + ((i * 120 + j * 80 + k * 95) % 3800) * '1 day'::interval)::date;
          phone_num := '(31) 9' || ((8000 + phone_seq % 1900)::text) || '-' || lpad(((phone_seq * 37) % 8999 + 1000)::text, 4, '0');
          avatar_val := s_avatars_female[1 + ((i * 2 + j * 4 + k) % array_length(s_avatars_female, 1))];

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, spouse_id,
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code,
            occupation, education_level, employment_status, household_income, housing_status, marital_status,
            drivers_license, dependents_count, avatar_url
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'F', gc_id, m_id,
            m_profile.address_street, m_profile.address_number, m_profile.address_neighborhood, m_profile.address_city, 'MG', m_profile.address_zip_code,
            s_occupations[1 + ((i * 2 + j * 4 + k) % array_length(s_occupations, 1))],
            s_education[1 + ((i * 3 + j * 1 + k) % array_length(s_education, 1))],
            s_employment[1 + ((i * 2 + j * 3 + k) % array_length(s_employment, 1))],
            m_profile.household_income,
            m_profile.housing_status,
            'Casado(a)', 'Sim (B)', 2, avatar_val
          );

          UPDATE public.profiles SET spouse_id = temp_profile_id WHERE id = m_id;
          all_member_ids := array_append(all_member_ids, temp_profile_id);

          temp_auth_id := extensions.uuid_generate_v4();
          INSERT INTO auth.users (
            id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
            created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change
          ) VALUES (
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
            '', '', '', ''
          );
        END;
      END LOOP;

      -- ========================================================================
      -- 4B. FAMÍLIAS ORDINÁRIAS (2 Casais por GC)
      -- ========================================================================
      FOR k IN 1..2 LOOP
        email_seq := email_seq + 1;
        cpf_seq := cpf_seq + 1;
        phone_seq := phone_seq + 1;

        f_husband_id := extensions.uuid_generate_v4();
        r_idx := (i * 23 + j * 11 + k * 31) % array_length(s_names, 1) + 1;
        m_first := s_names[r_idx];
        r_idx := (i * 14 + j * 19 + k * 8) % array_length(s_surnames, 1) + 1;
        l_surname := s_surnames[r_idx];
        
        full_nm := m_first || ' ' || l_surname;
        email_addr := lower(m_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
        cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');
        b_date := ('1982-01-01'::date + ((i * 200 + j * 150 + k * 95) % 4500) * '1 day'::interval)::date;
        bapt_date := ('2009-01-01'::date + ((i * 80 + j * 60 + k * 110) % 2700) * '1 day'::interval)::date;
        phone_num := '(31) 9' || ((8000 + phone_seq % 1900)::text) || '-' || lpad(((phone_seq * 37) % 8999 + 1000)::text, 4, '0');
        avatar_val := s_avatars_male[1 + ((i * 1 + j * 3 + k) % array_length(s_avatars_male, 1))];

        st_addr := gc_streets[i][j];
        num_addr := ((200 + i * 30 + j * 15 + k * 18)::text);
        neigh_addr := gc_neighborhoods[i][j];
        city_addr := gc_cities[i];
        cep_addr := gc_ceps[i][j];

        INSERT INTO public.profiles (
          id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id,
          address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code,
          occupation, education_level, employment_status, household_income, housing_status, marital_status,
          drivers_license, dependents_count, avatar_url
        ) VALUES (
          f_husband_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'M', gc_id,
          st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr,
          s_occupations[1 + ((i * 1 + j * 3 + k) % array_length(s_occupations, 1))],
          s_education[1 + ((i * 2 + j * 2 + k) % array_length(s_education, 1))],
          s_employment[1 + ((i * 3 + j * 1 + k) % array_length(s_employment, 1))],
          s_income[1 + ((i * 2 + j * 3 + k) % array_length(s_income, 1))],
          s_housing[1 + ((i + j * 2 + k) % array_length(s_housing, 1))],
          'Casado(a)', 'Sim (B)', 2, avatar_val
        );
        all_member_ids := array_append(all_member_ids, f_husband_id);

        temp_auth_id := extensions.uuid_generate_v4();
        INSERT INTO auth.users (
          id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
          created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change
        ) VALUES (
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
          '', '', '', ''
        );

        -- Esposa ordinária
        email_seq := email_seq + 1;
        cpf_seq := cpf_seq + 1;
        phone_seq := phone_seq + 1;

        f_wife_id := extensions.uuid_generate_v4();
        r_idx := (i * 17 + j * 34 + k * 23) % array_length(s_fnames, 1) + 1;
        f_first := s_fnames[r_idx];
        
        full_nm := f_first || ' ' || l_surname;
        email_addr := lower(f_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
        cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');
        b_date := b_date + '18 months'::interval;
        bapt_date := ('2011-01-01'::date + ((i * 90 + j * 70 + k * 125) % 2600) * '1 day'::interval)::date;
        phone_num := '(31) 9' || ((8000 + phone_seq % 1900)::text) || '-' || lpad(((phone_seq * 37) % 8999 + 1000)::text, 4, '0');
        avatar_val := s_avatars_female[1 + ((i * 3 + j * 2 + k) % array_length(s_avatars_female, 1))];

        INSERT INTO public.profiles (
          id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, spouse_id,
          address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code,
          occupation, education_level, employment_status, household_income, housing_status, marital_status,
          drivers_license, dependents_count, avatar_url
        ) VALUES (
          f_wife_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'F', gc_id, f_husband_id,
          st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr,
          s_occupations[1 + ((i * 2 + j * 2 + k) % array_length(s_occupations, 1))],
          s_education[1 + ((i * 1 + j * 3 + k) % array_length(s_education, 1))],
          s_employment[1 + ((i * 2 + j * 2 + k) % array_length(s_employment, 1))],
          s_income[1 + ((i * 2 + j * 2 + k) % array_length(s_income, 1))],
          s_housing[1 + ((i + j * 2 + k) % array_length(s_housing, 1))],
          'Casado(a)', 'Sim (B)', 2, avatar_val
        );

        UPDATE public.profiles SET spouse_id = f_wife_id WHERE id = f_husband_id;
        all_member_ids := array_append(all_member_ids, f_wife_id);

        temp_auth_id := extensions.uuid_generate_v4();
        INSERT INTO auth.users (
          id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
          created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change
        ) VALUES (
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
          '', '', '', ''
        );

        -- ======================================================================
        -- 4C. FILHOS PEQUENOS (Não Batizados, 2 por GC, 1 em cada família)
        -- ======================================================================
        cpf_seq := cpf_seq + 1;
        temp_profile_id := extensions.uuid_generate_v4();
        IF k = 1 THEN
          r_idx := (i * 9 + j * 3 + k * 19) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          full_nm := m_first || ' ' || l_surname;
          cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');
          
          INSERT INTO public.profiles (
            id, full_name, cpf, birth_date, baptism_date, gender, home_group_id, father_id, mother_id, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code, marital_status,
            occupation, education_level, employment_status, household_income, housing_status, drivers_license, dependents_count
          ) VALUES (
            temp_profile_id, full_nm, cpf_val, (now() - ((5 + (i+j+k)%5)::text || ' years')::interval)::date, NULL, 'M', gc_id, f_husband_id, f_wife_id, 
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr, 'Solteiro(a)',
            'Estudante Infantil', 'Ensino Fundamental', 'Não se aplica', '2 a 5 salários mínimos', 'Própria', 'Não possui', 0
          );
        ELSE
          r_idx := (i * 12 + j * 9 + k * 23) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          full_nm := f_first || ' ' || l_surname;
          cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');

          INSERT INTO public.profiles (
            id, full_name, cpf, birth_date, baptism_date, gender, home_group_id, father_id, mother_id, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code, marital_status,
            occupation, education_level, employment_status, household_income, housing_status, drivers_license, dependents_count
          ) VALUES (
            temp_profile_id, full_nm, cpf_val, (now() - ((3 + (i+j)%6)::text || ' years')::interval)::date, NULL, 'F', gc_id, f_husband_id, f_wife_id, 
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr, 'Solteiro(a)',
            'Estudante Infantil', 'Ensino Fundamental', 'Não se aplica', '2 a 5 salários mínimos', 'Própria', 'Não possui', 0
          );
        END IF;
        all_member_ids := array_append(all_member_ids, temp_profile_id);

        -- ======================================================================
        -- 4D. FILHOS ADOLESCENTES/JOVENS (Batizados, 2 por GC, 1 em cada família)
        -- ======================================================================
        email_seq := email_seq + 1;
        cpf_seq := cpf_seq + 1;
        phone_seq := phone_seq + 1;
        temp_profile_id := extensions.uuid_generate_v4();

        IF k = 1 THEN
          r_idx := (i * 18 + j * 5 + k * 29) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          full_nm := m_first || ' ' || l_surname;
          email_addr := lower(m_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
          cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');
          b_date := (now() - ((15 + (i+j)%4)::text || ' years')::interval)::date;
          bapt_date := (b_date + '13 years'::interval + ((i*10 + j*3 + k)%200 * '1 day'::interval))::date;
          phone_num := '(31) 9' || ((8000 + phone_seq % 1900)::text) || '-' || lpad(((phone_seq * 37) % 8999 + 1000)::text, 4, '0');
          avatar_val := s_avatars_male[1 + ((i * 2 + j * 1 + k) % array_length(s_avatars_male, 1))];

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, father_id, mother_id, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code, marital_status,
            occupation, education_level, employment_status, household_income, housing_status, drivers_license, dependents_count, avatar_url
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'M', gc_id, f_husband_id, f_wife_id, 
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr, 'Solteiro(a)',
            'Estudante do Ensino Médio', 'Ensino Médio', 'Estudante', s_income[1+((i*2+j)%4)], 'Própria', 'Não possui', 0, avatar_val
          );
        ELSE
          r_idx := (i * 21 + j * 15 + k * 11) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          full_nm := f_first || ' ' || l_surname;
          email_addr := lower(f_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
          cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');
          b_date := (now() - ((16 + (i+j)%4)::text || ' years')::interval)::date;
          bapt_date := (b_date + '13 years'::interval + ((i*12 + j*2 + k)%200 * '1 day'::interval))::date;
          phone_num := '(31) 9' || ((8000 + phone_seq % 1900)::text) || '-' || lpad(((phone_seq * 37) % 8999 + 1000)::text, 4, '0');
          avatar_val := s_avatars_female[1 + ((i * 3 + j * 2 + k) % array_length(s_avatars_female, 1))];

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, father_id, mother_id, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code, marital_status,
            occupation, education_level, employment_status, household_income, housing_status, drivers_license, dependents_count, avatar_url
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'F', gc_id, f_husband_id, f_wife_id, 
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr, 'Solteiro(a)',
            'Estudante Universitária', 'Ensino Superior', 'Estudante', s_income[1+((i*2+j)%4)], 'Própria', 'Não possui', 0, avatar_val
          );
        END IF;

        all_member_ids := array_append(all_member_ids, temp_profile_id);

        temp_auth_id := extensions.uuid_generate_v4();
        INSERT INTO auth.users (
          id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
          created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change
        ) VALUES (
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
          '', '', '', ''
        );
      END LOOP;

      -- ========================================================================
      -- 4E. IDOSOS PHANTOM USERS (3 por GC, Sem Conta Auth)
      -- ========================================================================
      FOR k IN 1..3 LOOP
        email_seq := email_seq + 1;
        cpf_seq := cpf_seq + 1;
        phone_seq := phone_seq + 1;

        temp_profile_id := extensions.uuid_generate_v4();
        b_date := ('1942-01-01'::date + ((i * 170 + j * 90 + k * 230) % 5500) * '1 day'::interval)::date;
        bapt_date := (b_date + '20 years'::interval + ((i*50 + j*35 + k*20)%1800 * '1 day'::interval))::date;
        phone_num := '(31) 9' || ((8000 + phone_seq % 1900)::text) || '-' || lpad(((phone_seq * 37) % 8999 + 1000)::text, 4, '0');
        cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');

        st_addr := gc_streets[i][j];
        num_addr := ((350 + i * 20 + j * 10 + k * 12)::text);
        neigh_addr := gc_neighborhoods[i][j];
        city_addr := gc_cities[i];
        cep_addr := gc_ceps[i][j];

        IF k % 2 = 1 THEN
          r_idx := (i * 32 + j * 12 + k * 18) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          r_idx := (i * 24 + j * 8 + k * 22) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          full_nm := m_first || ' ' || l_surname;
          email_addr := lower(m_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
          avatar_val := s_avatars_male[1 + ((i + j + k) % array_length(s_avatars_male, 1))];

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code, marital_status,
            occupation, education_level, employment_status, household_income, housing_status, drivers_license, dependents_count, avatar_url
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val,
            phone_num, b_date, bapt_date, 'M', gc_id, 
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr, 'Casado(a)',
            'Aposentado', 'Ensino Médio', 'Aposentado', '1 a 2 salários mínimos', 'Própria', 'Não possui', 0, avatar_val
          );
        ELSE
          r_idx := (i * 28 + j * 15 + k * 11) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          r_idx := (i * 19 + j * 12 + k * 27) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          full_nm := f_first || ' ' || l_surname;
          email_addr := lower(f_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
          avatar_val := s_avatars_female[1 + ((i + j + k) % array_length(s_avatars_female, 1))];

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code, marital_status,
            occupation, education_level, employment_status, household_income, housing_status, drivers_license, dependents_count, avatar_url
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val,
            phone_num, b_date, bapt_date, 'F', gc_id, 
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr, 'Viúvo(a)',
            'Aposentada', 'Ensino Fundamental', 'Aposentado', 'menos de 1 salário mínimo', 'Própria', 'Não possui', 0, avatar_val
          );
        END IF;

        all_member_ids := array_append(all_member_ids, temp_profile_id);
      END LOOP;

      -- ========================================================================
      -- 4F. SOLTEIROS ORDINÁRIOS (7 por GC, Com Contas Auth)
      -- ========================================================================
      FOR k IN 1..7 LOOP
        email_seq := email_seq + 1;
        cpf_seq := cpf_seq + 1;
        phone_seq := phone_seq + 1;

        temp_profile_id := extensions.uuid_generate_v4();
        b_date := ('1994-01-01'::date + ((i * 300 + j * 200 + k * 120) % 3500) * '1 day'::interval)::date;
        bapt_date := ('2015-01-01'::date + ((i * 100 + j * 65 + k * 90) % 3200) * '1 day'::interval)::date;
        phone_num := '(31) 9' || ((8000 + phone_seq % 1900)::text) || '-' || lpad(((phone_seq * 37) % 8999 + 1000)::text, 4, '0');
        cpf_val := lpad(cpf_seq::text, 3, '0') || '.' || lpad(((cpf_seq * 7) % 899 + 100)::text, 3, '0') || '.' || lpad(((cpf_seq * 13) % 899 + 100)::text, 3, '0') || '-' || lpad(((cpf_seq * 3) % 89 + 10)::text, 2, '0');

        st_addr := gc_streets[i][j];
        num_addr := ((400 + i * 25 + j * 12 + k * 16)::text);
        neigh_addr := gc_neighborhoods[i][j];
        city_addr := gc_cities[i];
        cep_addr := gc_ceps[i][j];

        IF k % 2 = 1 THEN
          r_idx := (i * 37 + j * 14 + k * 23) % array_length(s_names, 1) + 1;
          m_first := s_names[r_idx];
          r_idx := (i * 12 + j * 27 + k * 19) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          full_nm := m_first || ' ' || l_surname;
          email_addr := lower(m_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
          avatar_val := s_avatars_male[1 + ((i * 2 + j * 1 + k * 3) % array_length(s_avatars_male, 1))];

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code, marital_status,
            occupation, education_level, employment_status, household_income, housing_status, drivers_license, dependents_count, avatar_url
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'M', gc_id, 
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr, 'Solteiro(a)',
            s_occupations[1 + ((i * 2 + j * 1 + k * 3) % array_length(s_occupations, 1))],
            s_education[1 + ((i * 1 + j * 2 + k * 2) % array_length(s_education, 1))],
            s_employment[1 + ((i * 3 + j * 1 + k) % array_length(s_employment, 1))],
            s_income[1 + ((i + j * 2 + k) % array_length(s_income, 1))],
            s_housing[1 + ((i * 2 + j * 2 + k) % array_length(s_housing, 1))],
            'Sim (B)', 0, avatar_val
          );
        ELSE
          r_idx := (i * 29 + j * 23 + k * 19) % array_length(s_fnames, 1) + 1;
          f_first := s_fnames[r_idx];
          r_idx := (i * 15 + j * 32 + k * 13) % array_length(s_surnames, 1) + 1;
          l_surname := s_surnames[r_idx];
          full_nm := f_first || ' ' || l_surname;
          email_addr := lower(f_first) || '.' || lower(l_surname) || email_seq::text || '@' || domains[1 + (email_seq % 4)];
          avatar_val := s_avatars_female[1 + ((i * 2 + j * 1 + k * 3) % array_length(s_avatars_female, 1))];

          INSERT INTO public.profiles (
            id, full_name, email, cpf, phone, birth_date, baptism_date, gender, home_group_id, 
            address_street, address_number, address_neighborhood, address_city, address_state, address_zip_code, marital_status,
            occupation, education_level, employment_status, household_income, housing_status, drivers_license, dependents_count, avatar_url
          ) VALUES (
            temp_profile_id, full_nm, email_addr, cpf_val, phone_num, b_date, bapt_date, 'F', gc_id, 
            st_addr, num_addr, neigh_addr, city_addr, 'MG', cep_addr, 'Solteiro(a)',
            s_occupations[1 + ((i * 2 + j * 1 + k * 3) % array_length(s_occupations, 1))],
            s_education[1 + ((i * 1 + j * 2 + k * 2) % array_length(s_education, 1))],
            s_employment[1 + ((i * 3 + j * 1 + k) % array_length(s_employment, 1))],
            s_income[1 + ((i + j * 2 + k) % array_length(s_income, 1))],
            s_housing[1 + ((i * 2 + j * 2 + k) % array_length(s_housing, 1))],
            'Sim (B)', 0, avatar_val
          );
        END IF;

        all_member_ids := array_append(all_member_ids, temp_profile_id);

        temp_auth_id := extensions.uuid_generate_v4();
        INSERT INTO auth.users (
          id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
          created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change
        ) VALUES (
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
          '', '', '', ''
        );
      END LOOP;

    END LOOP;
  END LOOP;

  -- ==========================================================================
  -- 5. RELACIONAMENTOS DE DISCIPULADO (Árvore Hierárquica por Maturidade)
  -- ==========================================================================
  
  -- 5A. Presbíteros e Esposas (Não têm discipuladores humanos acima, prestam contas mutuamente)
  UPDATE public.profiles SET discipler_id = NULL WHERE id = ANY(presbyters);
  UPDATE public.profiles SET discipler_id = NULL WHERE spouse_id = ANY(presbyters) AND gender = 'F';

  -- 5B. Diáconos (6 homens, incluindo Gabriel) e suas esposas
  -- Cada diácono é discipulado por um dos presbíteros; as esposas pelas esposas dos presbíteros
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
      
      UPDATE public.profiles SET discipler_id = v_presbyter_id WHERE id = v_deacon_id;
      IF v_presbyter_wife_id IS NOT NULL AND v_deacon_wife_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_presbyter_wife_id WHERE id = v_deacon_wife_id;
      END IF;
    END;
  END LOOP;

  -- 5C. Discipulado de Outros Líderes de GC (38 casais)
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
        v_parent_husband_id := presbyters[1];
        SELECT id INTO v_parent_wife_id FROM public.profiles WHERE spouse_id = v_parent_husband_id AND gender = 'F';
        IF v_parent_husband_id IS NOT NULL AND v_parent_wife_id IS NOT NULL THEN
          UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_leader_couple.husband_id;
          UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_leader_couple.wife_id;
        END IF;
      END IF;
    END LOOP;
  END;

  -- 5D. Discipulado de Casais Ordinários (48 casais)
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
        AND (SELECT count(*) FROM public.profiles WHERE discipler_id = parent_h.id) < 3
        AND (SELECT count(*) FROM public.profiles WHERE discipler_id = parent_w.id) < 3
      ORDER BY parent_h.baptism_date ASC, parent_h.id ASC
      LIMIT 1;

      IF v_parent_husband_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_member_couple.husband_id;
        UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_member_couple.wife_id;
      ELSE
        v_parent_husband_id := presbyters[1];
        SELECT id INTO v_parent_wife_id FROM public.profiles WHERE spouse_id = v_parent_husband_id AND gender = 'F';
        IF v_parent_husband_id IS NOT NULL AND v_parent_wife_id IS NOT NULL THEN
          UPDATE public.profiles SET discipler_id = v_parent_husband_id WHERE id = r_member_couple.husband_id;
          UPDATE public.profiles SET discipler_id = v_parent_wife_id WHERE id = r_member_couple.wife_id;
        END IF;
      END IF;
    END LOOP;
  END;

  -- 5E. Discipulado de Solteiros e Jovens (Homens e Mulheres)
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
        AND (SELECT count(*) FROM public.profiles WHERE discipler_id = parent.id) < 3
      ORDER BY parent.baptism_date ASC, parent.id ASC
      LIMIT 1;

      IF v_parent_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_man.id;
      ELSE
        v_parent_id := presbyters[1];
        IF v_parent_id IS NOT NULL THEN
          UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_man.id;
        END IF;
      END IF;
    END LOOP;
  END;

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
        AND (SELECT count(*) FROM public.profiles WHERE discipler_id = parent.id) < 3
      ORDER BY parent.baptism_date ASC, parent.id ASC
      LIMIT 1;

      IF v_parent_id IS NOT NULL THEN
        UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_woman.id;
      ELSE
        SELECT id INTO v_parent_id FROM public.profiles WHERE spouse_id = ANY(presbyters) AND gender = 'F' LIMIT 1;
        IF v_parent_id IS NOT NULL THEN
          UPDATE public.profiles SET discipler_id = v_parent_id WHERE id = r_single_woman.id;
        END IF;
      END IF;
    END LOOP;
  END;

  -- ==========================================================================
  -- 6. JUNTAS DE COMPANHEIRISMO (Tabela Fellowships)
  -- ==========================================================================
  
  -- 6A. Companheirismo Completo entre Presbíteros
  FOR i IN 1..4 LOOP
    FOR j IN (i+1)..4 LOOP
      IF i < j THEN
        INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
        VALUES (presbyters[i], presbyters[j], now())
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END LOOP;

  -- 6B. Companheirismo Completo entre Esposas de Presbíteros
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

  -- 6C. Juntas de Companheirismo para Casados (2 outros casados do mesmo gênero)
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

  -- 6D. Juntas de Companheirismo para Solteiros e Adolescentes
  FOR rec IN SELECT id, gender, baptism_date FROM public.profiles WHERE spouse_id IS NULL AND baptism_date IS NOT NULL LOOP
    FOR rec_comp IN 
      SELECT id FROM public.profiles
      WHERE spouse_id IS NULL AND baptism_date IS NOT NULL
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

  -- ==========================================================================
  -- 7. MURAL DE POSTS ORGÂNICO E VIBRANTE (15 Posts com Categorias e Datas)
  -- ==========================================================================
  INSERT INTO public.posts (author_id, category, title, content, is_published, event_start_date, event_end_date, image_urls, created_at)
  VALUES 
    -- 1. Notícia Central
    (presbyters[1], 'noticia', 'Início da Trilha de Formação Comum: O Propósito Eterno', 
     'Queridos irmãos, iniciamos nossa nova série de estudos sobre "Juntas e Ligamentos no Corpo de Cristo". Todos os materiais de leitura (Catequese) e vídeos de apoio já estão disponíveis na nossa central de Ensino. Incentivamos que os discipuladores estudem junto com seus discípulos ao longo das semanas.', 
     true, (now() - INTERVAL '2 days'), NULL, 
     ARRAY['https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '2 days'),
    
    -- 2. Diaconato - Mutirão
    (gabriel_id, 'diaconato', 'Mutirão Diaconal de Reforma na Região São Gabriel', 
     'Graça e paz, irmãos! No próximo sábado faremos um mutirão de pintura e reparos na residência de uma família assistida na região do São Gabriel. Quem tiver ferramentas simples (espátula, rolo de pintura, lixas) favor trazer. O almoço será comunitário preparado pelas irmãs no local.', 
     true, (now() + INTERVAL '3 days' + INTERVAL '8 hours'), (now() + INTERVAL '3 days' + INTERVAL '16 hours'), 
     ARRAY['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '1 day'),
    
    -- 3. Oração - Saúde e Enfermos
    (presbyters[2], 'oracao', 'Clamor pela Saúde dos Irmãos Idosos e Gestantes', 
     'Lembramos toda a igreja de sustentar em oração os nossos irmãos e irmãs mais idosos que têm enfrentado desafios de saúde neste período, assim como as três gestantes que se aproximam do parto. Orem em suas casas e nos encontros semanais dos Grupos Caseiros.', 
     true, (now() - INTERVAL '3 days'), NULL, 
     ARRAY['https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '3 days'),
     
    -- 4. Notícia - Novos Batismos
    (presbyters[3], 'noticia', 'Novo Nascimento e Batismo nas Águas na Região Oeste', 
     'Celebramos com júbilo a confissão pública de fé e batismo de 8 novos discípulos que desceram às águas no último fim de semana no Barreiro e Buritis! Que o Senhor fortaleça esses novos irmãos em sua caminhada de discipulado.', 
     true, (now() - INTERVAL '4 days'), NULL, 
     ARRAY['https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '4 days'),

    -- 5. Diaconato - Campanha de Inverno
    (deacons[1], 'diaconato', 'Campanha Metropolitana de Agasalhos e Cobertores', 
     'A diaconia das seis regiões está recolhendo cobertores novos e agasalhos em bom estado para as famílias em situação de vulnerabilidade em Contagem e Betim. As caixas de arrecadação estão localizadas nas residências onde os GCs se reúnem.', 
     true, (now() - INTERVAL '5 days'), (now() + INTERVAL '10 days'), 
     ARRAY['https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '5 days'),

    -- 6. Aviso - Reunião Coletiva
    (presbyters[1], 'aviso', 'Reunião Coletiva de Toda a Igreja no Parque Municipal', 
     'Neste domingo, a partir das 09h30, nos reuniremos ao ar livre no Parque Municipal de Belo Horizonte para um tempo especial de louvor, oração coletiva e partilha do pão. Cada família é encorajada a levar toalha de piquenique e frutas/lanches para compartilhar.', 
     true, (now() + INTERVAL '4 days' + INTERVAL '9 hours 30 minutes'), (now() + INTERVAL '4 days' + INTERVAL '13 hours'), 
     ARRAY['https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '6 hours'),

    -- 7. Obra - Manutenção
    (deacons[2], 'obra', 'Manutenção Preventiva de Equipamentos de Som e Cabos', 
     'A equipe de apoio técnico realizou a revisão de todas as caixas de som ativas, cabos de microfone e projetores utilizados nas reuniões maiores das regiões. Tudo limpo e devidamente identificado por setor.', 
     true, (now() - INTERVAL '6 days'), NULL, 
     ARRAY['https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '6 days'),

    -- 8. Evento - Retiro de Solteiros
    (gabriel_id, 'evento', 'Inscrições Abertas: Retiro de Solteiros e Jovens 2026', 
     'Estão abertas as inscrições para o nosso Retiro de Solteiros no Sítio das Palmeiras em Santa Luzia! Serão três dias de edificação profunda, palavra e comunhão intensa. As vagas nos chalés são limitadas. Inscrevam-se pelo portal!', 
     true, '2026-10-10 08:00:00+00', '2026-10-12 17:00:00+00', 
     ARRAY['https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '1 day'),

    -- 9. Oração - Famílias e Evangelismo
    (leader_ids[3], 'oracao', 'Intercessão pelo Evangelismo nas Universidades e Ruas', 
     'Pedimos a cobertura em oração para os jovens irmãos que têm saído aos sábados à tarde nas imediações da Praça da Liberdade e da UFMG para conversar naturalmente com as pessoas e compartilhar o Evangelho do Reino.', 
     true, (now() - INTERVAL '7 days'), NULL, 
     NULL, now() - INTERVAL '7 days'),

    -- 10. Obra - Espaço Comunitário em Betim
    (deacons[3], 'obra', 'Revisão Elétrica e Hidráulica na Casa Comum de Betim', 
     'Agradecemos a todos os irmãos que doaram tempo e materiais para a substituição da fiação e instalação das novas lâmpadas de LED no ponto de apoio comunitário em Betim. Trabalho concluído com excelência.', 
     true, (now() - INTERVAL '8 days'), NULL, 
     NULL, now() - INTERVAL '8 days'),

    -- 11. Aviso - Censo de Dons e Habilidades
    (deacons[4], 'aviso', 'Preenchimento do Censo de Dons e Recursos Práticos', 
     'Solicitamos a todos os irmãos que preencham a ficha de "Censo de Vida Comum e Talentos" disponível na aba de Formulários. O objetivo é mapear profissões e habilidades práticas para apoiar viúvas, enfermos e irmãos desempregados.', 
     true, (now() - INTERVAL '2 days'), (now() + INTERVAL '15 days'), 
     ARRAY['https://images.unsplash.com/photo-1450133064473-71024230f91b?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '2 days'),

    -- 12. Notícia - Testemunho nas Casas
    (leader_ids[5], 'noticia', 'Comunhão e Crescimento nos Grupos Caseiros de Venda Nova', 
     'Nesta última quinta-feira, os quatro GCs de Venda Nova se reuniram para uma ceia compartilhada. Foi marcante ver o carinho e o acolhimento com dois novos vizinhos que decidiram caminhar conosco rumo ao discipulado.', 
     true, (now() - INTERVAL '9 days'), NULL, 
     ARRAY['https://images.unsplash.com/photo-1543269865-cbf427effbad?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '9 days'),

    -- 13. Oração - Irmãos Enfermos
    (leader_ids[7], 'oracao', 'Pedido de Cura: Recuperação Pós-Cirúrgica', 
     'Irmãos, intercedamos pelo irmão Cláudio do GC Castelo, que passou por cirurgia no joelho ontem. O procedimento foi bem-sucedido e agora ele necessita de repouso e oração para plena recuperação funcional.', 
     true, (now() - INTERVAL '12 hours'), NULL, 
     NULL, now() - INTERVAL '12 hours'),

    -- 14. Evento - Encontro de Casais (Rascunho/Planejamento)
    (presbyters[4], 'evento', 'Planejamento: Encontro de Casais nas Casas 2026', 
     'O presbitério e diaconato estão alinhando a data e o programa do nosso Encontro Metropolitano de Casais. Em breve disponibilizaremos os detalhes e orientações para os pequenos grupos.', 
     true, '2026-11-20 19:30:00+00', '2026-11-22 16:00:00+00', 
     ARRAY['https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?w=800&auto=format&fit=crop&q=80'], now() - INTERVAL '10 hours');

  -- ==========================================================================
  -- 8. PLATAFORMA DE ENSINO & CATEQUESE (Media Resources, Studies, Steps, Progress)
  -- ==========================================================================
  
  -- 8A. Inserção de Recursos de Mídia (Vídeos, PDFs e Textos)
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

  -- 8B. Inserção das 3 Trilhas de Estudo Principais (Studies)
  INSERT INTO public.studies (id, title, description, created_by, created_at)
  VALUES 
    (study_id1, 'Trilha 1: O Propósito Eterno de Deus', 
     'Compreenda o plano eterno do Pai: formar uma grande família de muitos filhos que refletem o caráter santo e obediente de Jesus Cristo.', 
     presbyters[1], now() - INTERVAL '30 days'),
    
    (study_id2, 'Trilha 2: Juntas e Ligamentos — O Discipulado Prático', 
     'Aprenda como se conectar em relacionamentos intencionais de acompanhamento mútuo, oração contínua e modelagem de Cristo na vida real.', 
     presbyters[2], now() - INTERVAL '20 days'),

    (study_id3, 'Trilha 3: O Sacerdócio Universal e a Dinâmica nas Casas', 
     'Descubra a função de cada santo como sacerdote, eliminando a passividade e capacitando cada discípulo para o serviço no Corpo e na cidade.', 
     gabriel_id, now() - INTERVAL '15 days');

  -- 8C. Associação das Etapas de Estudo (Study Steps)
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

  -- 8D. Progresso de Estudo do Usuário (User Study Progress)
  -- Gabriel Góes Braga concluiu a Trilha 1 (Steps 1, 2, 3) e o Step 1 da Trilha 2
  INSERT INTO public.user_study_progress (profile_id, study_id, step_id, completed_at)
  VALUES 
    (gabriel_id, study_id1, step_id1, now() - INTERVAL '15 days'),
    (gabriel_id, study_id1, step_id2, now() - INTERVAL '10 days'),
    (gabriel_id, study_id1, step_id3, now() - INTERVAL '5 days'),
    (gabriel_id, study_id2, step_id4, now() - INTERVAL '2 days');

  -- Progresso de teste distribuído para outros 30 discípulos
  FOR i IN 1..30 LOOP
    INSERT INTO public.user_study_progress (profile_id, study_id, step_id, completed_at)
    VALUES 
      (all_member_ids[i], study_id1, step_id1, now() - (i * INTERVAL '6 hours'))
    ON CONFLICT DO NOTHING;

    IF i % 2 = 0 THEN
      INSERT INTO public.user_study_progress (profile_id, study_id, step_id, completed_at)
      VALUES 
        (all_member_ids[i], study_id1, step_id2, now() - (i * INTERVAL '3 hours'))
      ON CONFLICT DO NOTHING;
    END IF;
  END LOOP;

  -- ==========================================================================
  -- 9. FORMULÁRIOS DINÂMICOS & CENSO DA VIDA COMUM (Tabela Forms)
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

  -- Respostas de teste para o Censo de Dons (5 submissões)
  FOR i IN 1..5 LOOP
    INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
    VALUES (
      'sub-censo-' || i,
      'form-censo-dons',
      jsonb_build_object(
        'mandatory_full_name', (SELECT full_name FROM public.profiles WHERE id = all_member_ids[i]),
        'profissao_atual', (SELECT occupation FROM public.profiles WHERE id = all_member_ids[i]),
        'habilidades_apoio', 'Reparos Elétricos e Hidráulicos',
        'disponibilidade', 'Sábados pela manhã',
        'observacoes', 'Disponível com carro e ferramentas próprias.'
      ),
      (SELECT user_id FROM public.profiles WHERE id = all_member_ids[i]),
      now() - (i * INTERVAL '1 day')
    ) ON CONFLICT (id) DO NOTHING;
  END LOOP;

  -- ==========================================================================
  -- 10. CICLO COMPLETO DE EVENTOS & RETIROS (Ativo, Encerrado e Rascunho)
  -- ==========================================================================
  
  -- 10A. Evento 1: Retiro de Solteiros e Jovens 2026 (Ativo)
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
    '2026-09-30',
    'form-solteiros-2026'
  ) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status;

  -- Quartos do Evento Ativo
  INSERT INTO public.retreat_rooms (id, retreat_id, name, gender_type, capacity, notes) VALUES
    (r_act_chale_m1, r_retreat_active, 'Chalé Aliança 01', 'masculino', 10, 'Próximo ao campo de futebol'),
    (r_act_chale_m2, r_retreat_active, 'Chalé Aliança 02', 'masculino', 10, 'Próximo ao refeitório'),
    (r_act_dorm_m3,  r_retreat_active, 'Dormitório Varão 03', 'masculino', 12, 'Beliches duplos'),
    (r_act_chale_f1, r_retreat_active, 'Chalé Graciosa 01', 'feminino', 10, 'Com ar condicionado'),
    (r_act_chale_f2, r_retreat_active, 'Chalé Graciosa 02', 'feminino', 10, 'Próximo ao auditório principal'),
    (r_act_dorm_f3,  r_retreat_active, 'Dormitório Serva 03', 'feminino', 12, 'Próximo à piscina'),
    (r_act_suite_1,  r_retreat_active, 'Suíte Master 01', 'suite', 4, 'Banheiro privativo e frigobar'),
    (r_act_suite_2,  r_retreat_active, 'Suíte Master 02', 'suite', 4, 'Cama de casal e duas de solteiro');

  -- Despesas do Evento Ativo
  INSERT INTO public.retreat_expenses (retreat_id, description, category, amount, expense_date, notes) VALUES
    (r_retreat_active, 'Aluguel do Sítio das Palmeiras (3 dias)', 'local', 8500.00, '2026-09-01', 'Sinal de 50% já pago'),
    (r_retreat_active, 'Buffet & Alimentação Completa', 'alimentacao', 5200.00, '2026-09-05', 'Café, almoço e jantar para 120 pessoas'),
    (r_retreat_active, 'Fretamento de Ônibus Executivo (2 ônibus)', 'transporte', 1800.00, '2026-09-10', 'Empresa TransTurismo BH'),
    (r_retreat_active, 'Equipamento de Som e Iluminação', 'som_multimidia', 1200.00, '2026-09-12', 'Mesa de som, microfones e iluminação LED'),
    (r_retreat_active, 'Kits de Boas-Vindas & Canetas', 'outros', 600.00, '2026-09-15', 'Blocos de anotações e canetas gravadas'),
    (r_retreat_active, 'Materiais de Apoio & Crachás', 'material', 450.00, '2026-09-18', 'Impressão de pulseiras e crachás');

  -- 10B. Evento 2: Retiro de Carnaval 2026 (Encerrado / Realizado)
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
    'form-solteiros-2026'
  ) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status;

  -- Quartos do Evento Encerrado
  INSERT INTO public.retreat_rooms (id, retreat_id, name, gender_type, capacity, notes) VALUES
    (r_cls_dorm_m1,  r_retreat_closed, 'Alojamento Getsêmani', 'masculino', 25, 'Ala masculina'),
    (r_cls_dorm_f1,  r_retreat_closed, 'Alojamento Betânia', 'feminino', 25, 'Ala feminina'),
    (r_cls_chale_m2, r_retreat_closed, 'Chalé Oliveiras M', 'masculino', 15, 'Irmãos solteiros'),
    (r_cls_chale_f2, r_retreat_closed, 'Chalé Oliveiras F', 'feminino', 15, 'Irmãs solteiras'),
    (r_cls_suite_1,  r_retreat_closed, 'Suíte Família A', 'familia', 6, 'Família com crianças'),
    (r_cls_suite_2,  r_retreat_closed, 'Suíte Família B', 'suite', 4, 'Idosos e apoio');

  -- Despesas do Evento Encerrado (Fechamento Financeiro com Superávit)
  INSERT INTO public.retreat_expenses (retreat_id, description, category, amount, expense_date, notes) VALUES
    (r_retreat_closed, 'Locação do Recanto da Serra (4 diárias)', 'aluguel', 11000.00, '2026-02-01', 'Quitado integralmente'),
    (r_retreat_closed, 'Alimentação Completa (Café, Almoço e Jantar)', 'alimentacao', 7200.00, '2026-02-10', 'Buffet contratado'),
    (r_retreat_closed, 'Transporte Fretado 2 Vans e 1 Ônibus', 'transporte', 2400.00, '2026-02-12', 'Translado Betim e BH'),
    (r_retreat_closed, 'Apostilas Impressas e Crachás', 'material', 800.00, '2026-02-13', 'Gráfica Express'),
    (r_retreat_closed, 'Locação de Caixa Amplificada e Cabos', 'som', 1000.00, '2026-02-14', 'Equipamento extra de sonorização');

  -- 10C. Evento 3: Encontro Metropolitano de Casais nas Casas 2026 (Rascunho)
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
    'form-solteiros-2026'
  ) ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status;

  INSERT INTO public.retreat_rooms (retreat_id, name, gender_type, capacity, notes) VALUES
    (r_retreat_draft, 'Chalé Suíte das Flores 01', 'suite', 2, 'Casal'),
    (r_retreat_draft, 'Chalé Suíte das Flores 02', 'suite', 2, 'Casal'),
    (r_retreat_draft, 'Chalé Suíte das Flores 03', 'suite', 2, 'Casal'),
    (r_retreat_draft, 'Chalé Suíte das Flores 04', 'suite', 2, 'Casal');

  INSERT INTO public.retreat_expenses (retreat_id, description, category, amount, expense_date, notes) VALUES
    (r_retreat_draft, 'Sinal de Reserva da Pousada (30%)', 'aluguel', 2500.00, '2026-09-20', 'Pago via transferência bancária');

  -- ==========================================================================
  -- 11. INSCRIÇÕES COERENTES NOS RETIROS (Ativo e Encerrado)
  -- ==========================================================================
  
  -- 11A. Inscrições no Evento Ativo (Gabriel Góes Braga + 56 Solteiros e Jovens)
  DECLARE
    v_sub_id text;
    v_count int := 0;
    v_rec RECORD;
    v_is_paid boolean;
    v_method text;
    v_gender text;
    v_first_name text;
    v_tamanho text;
    v_transporte text;
    v_assigned_room_id uuid;
    v_assigned_room_name text;
    v_male_room_ids uuid[] := ARRAY[r_act_chale_m1, r_act_chale_m2, r_act_dorm_m3];
    v_male_room_names text[] := ARRAY['Chalé Aliança 01', 'Chalé Aliança 02', 'Dormitório Varão 03'];
    v_female_room_ids uuid[] := ARRAY[r_act_chale_f1, r_act_chale_f2, r_act_dorm_f3];
    v_female_room_names text[] := ARRAY['Chalé Graciosa 01', 'Chalé Graciosa 02', 'Dormitório Serva 03'];
    v_male_count int := 0;
    v_female_count int := 0;
    v_room_idx int;
  BEGIN
    -- Inscrição Oficial de Gabriel Góes Braga
    IF gabriel_id IS NOT NULL THEN
      v_sub_id := 'sub-gabriel-123';
      v_male_count := v_male_count + 1;
      
      INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
      VALUES (
        v_sub_id,
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
        (SELECT user_id FROM public.profiles WHERE id = gabriel_id),
        now() - INTERVAL '2 days'
      );

      INSERT INTO public.registrations (
        retreat_id, profile_id, paid, payment_method, payment_reference, created_at, form_submission_id,
        room_id, room_allocation, guest_data, custom_responses
      )
      VALUES (
        r_retreat_active,
        gabriel_id,
        true,
        'pix',
        'REF-GABRIEL-PIX-123',
        now() - INTERVAL '2 days',
        v_sub_id,
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
      );
    END IF;

    -- Inscrição de 28 rapazes e 28 moças
    FOR v_rec IN 
      (SELECT id, user_id, full_name, email, phone, cpf, birth_date, gender
       FROM public.profiles 
       WHERE spouse_id IS NULL AND baptism_date IS NOT NULL AND gender = 'M' AND (gabriel_id IS NULL OR id <> gabriel_id)
       LIMIT 28)
      UNION ALL
      (SELECT id, user_id, full_name, email, phone, cpf, birth_date, gender
       FROM public.profiles 
       WHERE spouse_id IS NULL AND baptism_date IS NOT NULL AND gender = 'F' AND (gabriel_id IS NULL OR id <> gabriel_id)
       LIMIT 28)
    LOOP
      v_count := v_count + 1;
      v_sub_id := 'sub-solteiro-' || v_count || '-' || substring((v_rec.id)::text from 1 for 6);
      v_gender := CASE WHEN v_rec.gender = 'M' THEN 'Masculino' ELSE 'Feminino' END;
      v_is_paid := (v_count % 4 <> 0); -- ~75% pagos
      v_method := CASE WHEN v_count % 2 = 0 THEN 'pix' ELSE 'card' END;
      v_tamanho := (ARRAY['P', 'M', 'G', 'GG'])[1 + (v_count % 4)];
      v_transporte := CASE WHEN v_count % 3 = 0 THEN 'Sim' ELSE 'Não' END;

      IF v_gender = 'Masculino' THEN
        v_male_count := v_male_count + 1;
        IF v_male_count <= 18 THEN
          v_room_idx := 1 + ((v_male_count - 1) % 3);
          v_assigned_room_id := v_male_room_ids[v_room_idx];
          v_assigned_room_name := v_male_room_names[v_room_idx];
        ELSE
          v_assigned_room_id := NULL;
          v_assigned_room_name := NULL;
        END IF;
      ELSE
        v_female_count := v_female_count + 1;
        IF v_female_count <= 18 THEN
          v_room_idx := 1 + ((v_female_count - 1) % 3);
          v_assigned_room_id := v_female_room_ids[v_room_idx];
          v_assigned_room_name := v_female_room_names[v_room_idx];
        ELSE
          v_assigned_room_id := NULL;
          v_assigned_room_name := NULL;
        END IF;
      END IF;

      INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
      VALUES (
        v_sub_id,
        'form-solteiros-2026',
        jsonb_build_object(
          'mandatory_full_name', v_rec.full_name,
          'mandatory_email', v_rec.email,
          'mandatory_phone', v_rec.phone,
          'mandatory_gender', v_gender,
          'mandatory_city_state', 'Belo Horizonte / MG',
          'mandatory_birth_date', v_rec.birth_date::text,
          'tamanho_camiseta', v_tamanho,
          'transporte', v_transporte,
          'restricoes_alimentares', 'Nenhuma'
        ),
        v_rec.user_id,
        now() - (v_count * INTERVAL '2 hours')
      );

      INSERT INTO public.registrations (
        retreat_id, profile_id, paid, payment_method, payment_reference, created_at, form_submission_id,
        room_id, room_allocation, guest_data, custom_responses
      )
      VALUES (
        r_retreat_active, 
        v_rec.id, 
        v_is_paid, 
        v_method, 
        'REF-SEED-' || upper(v_method) || '-' || substring((v_rec.id)::text from 1 for 6), 
        now() - (v_count * INTERVAL '2 hours'),
        v_sub_id,
        v_assigned_room_id,
        v_assigned_room_name,
        jsonb_build_object(
          'fullName', v_rec.full_name, 'full_name', v_rec.full_name,
          'email', v_rec.email, 'phone', v_rec.phone,
          'gender', v_gender, 'cityState', 'Belo Horizonte / MG', 'city_state', 'Belo Horizonte / MG',
          'birthDate', v_rec.birth_date::text
        ),
        jsonb_build_object(
          'Nome Completo', v_rec.full_name,
          'E-mail', v_rec.email,
          'Telefone / WhatsApp', v_rec.phone,
          'Sexo / Gênero', v_gender,
          'Cidade / Estado', 'Belo Horizonte / MG',
          'Data de Nascimento / Idade', v_rec.birth_date::text,
          'Tamanho da Camiseta', v_tamanho,
          'Precisa de Transporte?', v_transporte,
          'Restrições Alimentares', 'Nenhuma'
        )
      );
    END LOOP;
  END;

  -- 11B. Inscrições no Evento Encerrado (Retiro de Carnaval 2026 - 85 participantes 100% pagos)
  DECLARE
    v_sub_cls_id text;
    v_cls_count int := 0;
    v_rec_cls RECORD;
    v_gender_cls text;
    v_room_cls_id uuid;
    v_room_cls_name text;
  BEGIN
    -- Incluir Gabriel Góes Braga no evento encerrado também
    IF gabriel_id IS NOT NULL THEN
      v_sub_cls_id := 'sub-cls-gabriel';
      INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
      VALUES (
        v_sub_cls_id,
        'form-solteiros-2026',
        jsonb_build_object(
          'mandatory_full_name', 'Gabriel Góes Braga',
          'mandatory_email', 'ggoesbraga@gmail.com',
          'mandatory_phone', '(31) 99888-7777',
          'mandatory_gender', 'Masculino',
          'mandatory_city_state', 'Belo Horizonte / MG',
          'mandatory_birth_date', '1995-07-08'
        ),
        (SELECT user_id FROM public.profiles WHERE id = gabriel_id),
        '2026-02-01 10:00:00+00'::timestamptz
      );

      INSERT INTO public.registrations (
        retreat_id, profile_id, paid, payment_method, payment_reference, created_at, form_submission_id,
        room_id, room_allocation, guest_data, custom_responses
      )
      VALUES (
        r_retreat_closed,
        gabriel_id,
        true,
        'pix',
        'REF-CARNAVAL-PIX-GABRIEL',
        '2026-02-01 10:00:00+00'::timestamptz,
        v_sub_cls_id,
        r_cls_dorm_m1,
        'Alojamento Getsêmani',
        jsonb_build_object(
          'fullName', 'Gabriel Góes Braga', 'full_name', 'Gabriel Góes Braga',
          'email', 'ggoesbraga@gmail.com', 'phone', '(31) 99888-7777',
          'gender', 'Masculino', 'cityState', 'Belo Horizonte / MG', 'city_state', 'Belo Horizonte / MG',
          'birthDate', '1995-07-08'
        ),
        jsonb_build_object('Nome Completo', 'Gabriel Góes Braga', 'Sexo / Gênero', 'Masculino')
      );
    END IF;

    -- Outros 84 participantes (casais e solteiros)
    FOR v_rec_cls IN 
      (SELECT id, user_id, full_name, email, phone, cpf, birth_date, gender
       FROM public.profiles 
       WHERE baptism_date IS NOT NULL AND (gabriel_id IS NULL OR id <> gabriel_id)
       LIMIT 84)
    LOOP
      v_cls_count := v_cls_count + 1;
      v_sub_cls_id := 'sub-cls-' || v_cls_count;
      v_gender_cls := CASE WHEN v_rec_cls.gender = 'M' THEN 'Masculino' ELSE 'Feminino' END;
      
      IF v_gender_cls = 'Masculino' THEN
        v_room_cls_id := r_cls_dorm_m1;
        v_room_cls_name := 'Alojamento Getsêmani';
      ELSE
        v_room_cls_id := r_cls_dorm_f1;
        v_room_cls_name := 'Alojamento Betânia';
      END IF;

      INSERT INTO public.form_submissions (id, form_id, data, user_id, submitted_at)
      VALUES (
        v_sub_cls_id,
        'form-solteiros-2026',
        jsonb_build_object(
          'mandatory_full_name', v_rec_cls.full_name,
          'mandatory_email', v_rec_cls.email,
          'mandatory_phone', v_rec_cls.phone,
          'mandatory_gender', v_gender_cls,
          'mandatory_city_state', 'Belo Horizonte / MG',
          'mandatory_birth_date', v_rec_cls.birth_date::text
        ),
        v_rec_cls.user_id,
        '2026-02-02 14:00:00+00'::timestamptz - (v_cls_count * INTERVAL '1 hour')
      );

      INSERT INTO public.registrations (
        retreat_id, profile_id, paid, payment_method, payment_reference, created_at, form_submission_id,
        room_id, room_allocation, guest_data, custom_responses
      )
      VALUES (
        r_retreat_closed,
        v_rec_cls.id,
        true, -- 100% pagos no evento passado
        CASE WHEN v_cls_count % 2 = 0 THEN 'pix' ELSE 'card' END,
        'REF-CARNAVAL-' || v_cls_count,
        '2026-02-02 14:00:00+00'::timestamptz - (v_cls_count * INTERVAL '1 hour'),
        v_sub_cls_id,
        v_room_cls_id,
        v_room_cls_name,
        jsonb_build_object(
          'fullName', v_rec_cls.full_name, 'full_name', v_rec_cls.full_name,
          'email', v_rec_cls.email, 'phone', v_rec_cls.phone,
          'gender', v_gender_cls, 'cityState', 'Belo Horizonte / MG', 'city_state', 'Belo Horizonte / MG',
          'birthDate', v_rec_cls.birth_date::text
        ),
        jsonb_build_object('Nome Completo', v_rec_cls.full_name, 'Sexo / Gênero', v_gender_cls)
      );
    END LOOP;
  END;

END $$;
