const fs = require('fs');

const csvContent = fs.readFileSync('c:/Users/ggoes/Downloads/Igreja em BH - Grupos.csv', 'utf8');

function parseCSV(text) {
  const lines = text.split(/\r?\n/).filter(l => l.trim().length > 0);
  const rows = [];
  for (const line of lines) {
    const row = [];
    let inQuotes = false;
    let field = '';
    for (let i = 0; i < line.length; i++) {
      const char = line[i];
      if (char === '"') inQuotes = !inQuotes;
      else if (char === ',' && !inQuotes) {
        row.push(field.trim());
        field = '';
      } else {
        field += char;
      }
    }
    row.push(field.trim());
    rows.push(row);
  }
  return rows;
}

const rows = parseCSV(csvContent);

const femaleNames = new Set(['Lora', 'Mércia', 'Fernanda']);

const groups = [];
for (let i = 2; i < rows.length; i++) {
  const r = rows[i];
  const id = r[0];
  const sector = r[1];
  const lideresRaw = r[2] || '';
  const nucleoRaw = r[3] || '';
  const endereco = r[9] || '';
  const bairroCidade = r[10] || '';
  const lat = parseFloat((r[11] || '').replace('"', '').replace(',', '.'));
  const lng = parseFloat((r[12] || '').replace('"', '').replace(',', '.'));

  const lideres = lideresRaw.split(/ e |, /).map(s => s.trim()).filter(Boolean);
  let nucleo = (nucleoRaw === 'Não tem' || !nucleoRaw) ? [] : nucleoRaw.split(/ e |, /).map(s => s.trim()).filter(Boolean);

  // Flatten any slashes in nucleo like "Eliel / Ramon"
  const flatNucleo = [];
  nucleo.forEach(n => {
    if (n.includes('/')) {
      n.split('/').map(s => s.trim()).filter(Boolean).forEach(sn => flatNucleo.push(sn));
    } else {
      flatNucleo.push(n);
    }
  });

  // If GC 302, remove "Gabriel" from nucleo because Gabriel Góes Braga belongs to GC 102
  if (id === '302') {
    const idx = flatNucleo.indexOf('Gabriel');
    if (idx !== -1) flatNucleo.splice(idx, 1);
  }

  // If GC 102, mark dev presence
  const isDevInThisGroup = (id === '102');

  groups.push({
    id,
    sector,
    lideres,
    nucleo: flatNucleo,
    isDevInThisGroup,
    endereco,
    bairroCidade,
    lat,
    lng
  });
}

function escapeSql(str) {
  return str.replace(/'/g, "''");
}

let sql = `-- ============================================================================
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
`;

groups.forEach(g => {
  const secVar = g.sector === 'São Gabriel/Pampulha' ? 'sec_sg_id' :
                 g.sector === 'Venda Nova/Neves' ? 'sec_vn_id' :
                 g.sector === 'Santa Luzia' ? 'sec_sl_id' :
                 g.sector === 'Oeste' ? 'sec_oe_id' :
                 g.sector === 'Betim/Contagem' ? 'sec_bc_id' : 'sec_fl_id';

  const locationText = `GC ${g.id} - ${g.bairroCidade}${g.endereco ? ' (' + g.endereco + ')' : ''}`;

  sql += `\n  -- ------------------------------------------------------------------------\n`;
  sql += `  -- GC ${g.id}: ${escapeSql(g.bairroCidade)} (Setor: ${escapeSql(g.sector)})\n`;
  sql += `  -- ------------------------------------------------------------------------\n`;
  sql += `  cur_gc_id := extensions.uuid_generate_v4();\n`;
  sql += `  cur_sec_id := ${secVar};\n`;
  sql += `  cur_l1_id := NULL;\n`;
  sql += `  cur_l2_id := NULL;\n\n`;

  // Step 1: Insert home_group first with NULL leaders to satisfy foreign keys
  sql += `  INSERT INTO public.home_groups (\n`;
  sql += `    id, sector_id, location_text, leader_1_id, leader_2_id, lat, lng, meeting_day, start_time, created_at\n`;
  sql += `  ) VALUES (\n`;
  sql += `    cur_gc_id, cur_sec_id, '${escapeSql(locationText)}', NULL, NULL, ${g.lat}, ${g.lng}, 3, '19:30:00', now()\n`;
  sql += `  );\n\n`;

  // Step 2: Insert leaders
  g.lideres.forEach((lName, idx) => {
    const isL1 = idx === 0;
    const isL2 = idx === 1;
    const gen = femaleNames.has(lName) ? 'F' : 'M';
    sql += `  -- Líder ${idx + 1}: ${escapeSql(lName)}\n`;
    sql += `  temp_p_id := extensions.uuid_generate_v4();\n`;
    if (isL1) sql += `  cur_l1_id := temp_p_id;\n`;
    if (isL2) sql += `  cur_l2_id := temp_p_id;\n`;
    sql += `  INSERT INTO public.profiles (\n`;
    sql += `    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city\n`;
    sql += `  ) VALUES (\n`;
    sql += `    temp_p_id, '${escapeSql(lName)}', NULL, NULL, '${gen}', true, false, false, false, true, cur_gc_id, '${escapeSql(g.bairroCidade.split('-')[0].trim())}', '${escapeSql(g.bairroCidade.includes('-') ? g.bairroCidade.split('-')[1].trim() : 'Belo Horizonte')}'\n`;
    sql += `  );\n\n`;
  });

  // Step 3: Insert nucleo members
  g.nucleo.forEach(nName => {
    const gen = femaleNames.has(nName) ? 'F' : 'M';
    sql += `  -- Núcleo: ${escapeSql(nName)}\n`;
    sql += `  temp_p_id := extensions.uuid_generate_v4();\n`;
    sql += `  INSERT INTO public.profiles (\n`;
    sql += `    id, full_name, email, user_id, gender, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city\n`;
    sql += `  ) VALUES (\n`;
    sql += `    temp_p_id, '${escapeSql(nName)}', NULL, NULL, '${gen}', true, false, false, false, false, cur_gc_id, '${escapeSql(g.bairroCidade.split('-')[0].trim())}', '${escapeSql(g.bairroCidade.includes('-') ? g.bairroCidade.split('-')[1].trim() : 'Belo Horizonte')}'\n`;
    sql += `  );\n\n`;
  });

  // Step 4: If this group is GC 102, insert Gabriel Góes Braga
  if (g.isDevInThisGroup) {
    sql += `  -- Perfil Oficial do Desenvolvedor: Gabriel Góes Braga (GC 102)\n`;
    sql += `  INSERT INTO public.profiles (\n`;
    sql += `    id, full_name, email, user_id, gender, cpf, phone, is_church_linked, is_dev, is_presbyter, is_deacon, can_post, home_group_id, address_neighborhood, address_city\n`;
    sql += `  ) VALUES (\n`;
    sql += `    gabriel_id, 'Gabriel Góes Braga', 'ggoesbraga@gmail.com', gabriel_auth_id, 'M', '132.507.246-02', '(31) 99888-7777', true, true, false, false, true, cur_gc_id, 'Heliópolis', 'BH'\n`;
    sql += `  );\n\n`;
    sql += `  INSERT INTO auth.users (\n`;
    sql += `    id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,\n`;
    sql += `    created_at, updated_at, role, aud, confirmation_token, recovery_token, email_change_token_new, email_change\n`;
    sql += `  ) VALUES (\n`;
    sql += `    gabriel_auth_id,\n`;
    sql += `    '00000000-0000-0000-0000-000000000000',\n`;
    sql += `    'ggoesbraga@gmail.com',\n`;
    sql += `    pwd_hash,\n`;
    sql += `    now(),\n`;
    sql += `    '{"provider":"email","providers":["email"]}'::jsonb,\n`;
    sql += `    jsonb_build_object('full_name', 'Gabriel Góes Braga', 'cpf', '132.507.246-02'),\n`;
    sql += `    now(),\n`;
    sql += `    now(),\n`;
    sql += `    'authenticated',\n`;
    sql += `    'authenticated',\n`;
    sql += `    '', '', '', ''\n`;
    sql += `  );\n\n`;
  }

  // Step 5: Update the Home Group with leaders
  sql += `  UPDATE public.home_groups SET leader_1_id = cur_l1_id, leader_2_id = cur_l2_id WHERE id = cur_gc_id;\n`;
});

sql += `
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
`;

fs.writeFileSync('supabase/seed.sql', sql, 'utf8');
console.log('✅ Generated supabase/seed.sql successfully with non-circular FK order! Total length:', sql.length);
