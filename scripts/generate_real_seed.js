import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

const churchCsvPath = path.join(process.cwd(), 'supabase', 'data', 'Igreja em BH.csv');
const groupsCsvPath = path.join(process.cwd(), 'supabase', 'data', 'Grupos.csv');
const outputPath = path.join(process.cwd(), 'supabase', 'seed-real.sql');

function parseCSV(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = [];
  let currentLine = [];
  let currentField = '';
  let insideQuotes = false;

  for (let i = 0; i < content.length; i++) {
    const char = content[i];
    const nextChar = content[i + 1];

    if (char === '"') {
      if (insideQuotes && nextChar === '"') {
        currentField += '"';
        i++;
      } else {
        insideQuotes = !insideQuotes;
      }
    } else if (char === ',' && !insideQuotes) {
      currentLine.push(currentField.trim());
      currentField = '';
    } else if ((char === '\r' || char === '\n') && !insideQuotes) {
      if (char === '\r' && nextChar === '\n') i++;
      currentLine.push(currentField.trim());
      currentField = '';
      if (currentLine.length > 1 || (currentLine.length === 1 && currentLine[0] !== '')) {
        lines.push(currentLine);
      }
      currentLine = [];
    } else {
      currentField += char;
    }
  }
  if (currentField || currentLine.length > 0) {
    currentLine.push(currentField.trim());
    lines.push(currentLine);
  }

  const headers = lines[0];
  const rows = lines.slice(1).map(line => {
    const row = {};
    headers.forEach((h, idx) => {
      row[h] = line[idx] !== undefined ? line[idx] : '';
    });
    return row;
  });

  return { headers, rows };
}

function escapeSql(str) {
  if (str === null || str === undefined) return 'NULL';
  return "'" + String(str).replace(/'/g, "''") + "'";
}

function cleanString(str) {
  return (str || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '');
}

function cleanStr(s) {
  return (s || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

function nameMatches(personName, targetName) {
  const p = cleanStr(personName);
  const t = cleanStr(targetName);
  if (!p || !t) return false;
  if (p === t) return true;
  const pFirst = p.split(/\s+/)[0];
  const tFirst = t.split(/\s+/)[0];
  return pFirst === tFirst || p.startsWith(t) || t.startsWith(p);
}

console.log('Reading CSV files...');
const churchData = parseCSV(churchCsvPath);
const groupsData = parseCSV(groupsCsvPath);

// Filter out 'Mudou de Grupo' to keep only active records
const activeDisciples = churchData.rows.filter(r => r.Situação !== 'Mudou de Grupo');
const validGroups = groupsData.rows.filter(r => r.ID && r.ID !== 'TOTAL');

console.log(`Loaded ${activeDisciples.length} active disciples and ${validGroups.length} groups.`);

// 1. Sectors: Assign pure random UUIDs
const sectorNames = [...new Set(validGroups.map(g => g.Setor))];
const sectorIdMap = {};
sectorNames.forEach(s => {
  sectorIdMap[s] = crypto.randomUUID();
});

// 2. Groups: Use example row ID only as transient mapping key, assign genuine random UUIDs
const groupRowToUuid = {};
validGroups.forEach(g => {
  groupRowToUuid[g.ID] = crypto.randomUUID();
});

// 3. Disciples: Use example member row ID only as transient mapping key, assign genuine random UUIDs
const memberRowToProfileUuid = {};
const memberByRowId = new Map();
const membersByNameAndGroup = new Map();
const membersByName = new Map();

activeDisciples.forEach((d) => {
  const rowId = d['ID Membro'];
  const pUuid = crypto.randomUUID();

  memberRowToProfileUuid[rowId] = pUuid;
  memberByRowId.set(rowId, d);

  const cleanName = d.Nome.toLowerCase().trim();
  if (!membersByName.has(cleanName)) membersByName.set(cleanName, []);
  membersByName.get(cleanName).push(d);

  const groupKey = `${d['ID Grupo']}_${cleanName}`;
  membersByNameAndGroup.set(groupKey, d);
});

// 4. Group Leaders Resolution
const groupLeaders = {};
validGroups.forEach(g => {
  const gRowId = g.ID;
  const lStr = g['Lider(es)'];
  const leaderNames = lStr.split(/\s*,\s*|\s+e\s+/).map(s => s.trim()).filter(Boolean);
  const matchedLeaderIds = [];

  const inGrp = activeDisciples.filter(d => d['ID Grupo'] === gRowId);

  leaderNames.forEach(lname => {
    const lLower = lname.toLowerCase();
    let found = membersByNameAndGroup.get(`${gRowId}_${lLower}`);
    if (!found) {
      const firstWord = lLower.split(' ')[0].replace(/ll/g, 'l');
      found = inGrp.find(d => {
        const dLower = d.Nome.toLowerCase();
        const dFirst = dLower.split(' ')[0].replace(/ll/g, 'l');
        return dFirst === firstWord || dLower.includes(firstWord) || lLower.includes(dFirst);
      });
    }
    if (!found && lname === 'Jesus') {
      found = inGrp.find(d => d.Nome.toLowerCase().includes('jésius'));
    }
    if (!found && lname === 'Shibas') {
      found = inGrp.find(d => d.Nome.toLowerCase().includes('shibas'));
    }
    if (!found) {
      const glob = membersByName.get(lLower);
      if (glob && glob.length > 0) found = glob[0];
    }
    if (!found) {
      found = activeDisciples.find(d => d.Nome.toLowerCase().startsWith(lLower));
    }

    if (found) {
      matchedLeaderIds.push(memberRowToProfileUuid[found['ID Membro']]);
    }
  });

  groupLeaders[gRowId] = {
    leader1: matchedLeaderIds[0] || null,
    leader2: matchedLeaderIds[1] || null
  };
});

// 5. Spouses & Parents Resolution
const spouseMap = new Map();
const childrenMap = new Map();

const families = new Map();
activeDisciples.forEach(d => {
  const famKey = `${d['ID Grupo']}_${d.Família}`;
  if (!families.has(famKey)) families.set(famKey, []);
  families.get(famKey).push(d);
});

let singlePersonCount = 0;
let couplesWithoutKids = 0;
let couplesWithKids = 0;
let singleMothersCount = 0;
let singleFathersCount = 0;

families.forEach((members) => {
  const famName = members[0].Família.trim();

  if (members.length === 1) {
    singlePersonCount++;
    return;
  }

  const womenMatchingFam = members.filter(m => m.Sexo === 'Feminino' && nameMatches(m.Nome, famName));
  const menMatchingFam = members.filter(m => m.Sexo === 'Masculino' && nameMatches(m.Nome, famName));

  let husband = null;
  let wife = null;
  let motherOnly = null;
  let fatherOnly = null;

  if (menMatchingFam.length > 0) {
    husband = menMatchingFam[0];
  } else if (members[0].Sexo === 'Masculino') {
    husband = members[0];
  }

  if (husband) {
    // Only a 'Vinculado' woman can be a wife, never a child ('Filho de discípulo')
    const eligibleWives = members.filter(m => m !== husband && m.Sexo === 'Feminino' && m.Situação === 'Vinculado');
    if (eligibleWives.length > 0) {
      wife = eligibleWives[0];
    }

    if (wife) {
      const hId = memberRowToProfileUuid[husband['ID Membro']];
      const wId = memberRowToProfileUuid[wife['ID Membro']];
      spouseMap.set(hId, wId);
      spouseMap.set(wId, hId);

      const children = members.filter(m => m !== husband && m !== wife);
      if (children.length > 0) couplesWithKids++;
      else couplesWithoutKids++;

      children.forEach(c => {
        const cId = memberRowToProfileUuid[c['ID Membro']];
        childrenMap.set(cId, { fatherId: hId, motherId: wId });
      });
    } else {
      fatherOnly = husband;
      singleFathersCount++;
      const fId = memberRowToProfileUuid[fatherOnly['ID Membro']];
      const children = members.filter(m => m !== fatherOnly);
      children.forEach(c => {
        const cId = memberRowToProfileUuid[c['ID Membro']];
        childrenMap.set(cId, { fatherId: fId, motherId: null });
      });
    }
  } else if (womenMatchingFam.length > 0 || members[0].Sexo === 'Feminino') {
    motherOnly = womenMatchingFam.length > 0 ? womenMatchingFam[0] : members[0];
    singleMothersCount++;
    const mId = memberRowToProfileUuid[motherOnly['ID Membro']];
    const children = members.filter(m => m !== motherOnly);
    children.forEach(c => {
      const cId = memberRowToProfileUuid[c['ID Membro']];
      childrenMap.set(cId, { fatherId: null, motherId: mId });
    });
  }
});

console.log(`Famílias resolvidas: ${families.size} totais.`);
console.log(`- Solteiros/Individuais: ${singlePersonCount}`);
console.log(`- Casais sem filhos: ${couplesWithoutKids}`);
console.log(`- Casais com filhos: ${couplesWithKids}`);
console.log(`- Total de casais: ${couplesWithoutKids + couplesWithKids} (${spouseMap.size / 2} pares)`);
console.log(`- Mães solteiras com filhos: ${singleMothersCount}`);
console.log(`- Pais solteiros com filhos: ${singleFathersCount}`);
console.log(`- Total de filhos vinculados: ${childrenMap.size}`);

// Dependents count per parent
const dependentsCountMap = new Map();
childrenMap.forEach(p => {
  if (p.fatherId) {
    dependentsCountMap.set(p.fatherId, (dependentsCountMap.get(p.fatherId) || 0) + 1);
  }
  if (p.motherId) {
    dependentsCountMap.set(p.motherId, (dependentsCountMap.get(p.motherId) || 0) + 1);
  }
});

// 6. Discipleship Resolution
const disciplerMap = new Map();
const customDisciplerMap = new Map();

activeDisciples.forEach(d => {
  const discName = d.Discipulador ? d.Discipulador.trim() : '';
  const discRowId = d['ID Discipulador'] ? d['ID Discipulador'].trim() : '';
  const discipleUuid = memberRowToProfileUuid[d['ID Membro']];

  if (!discName || discName === '-') return;

  // Se tiver ID explícito e válido de membro na planilha:
  if (discRowId && memberRowToProfileUuid[discRowId]) {
    const foundId = memberRowToProfileUuid[discRowId];
    if (foundId !== discipleUuid) {
      disciplerMap.set(discipleUuid, foundId);
    }
  } else {
    // Vínculo em que o ID está faltando: NÃO tentar adivinhar!
    // Colocar somente o nome (custom_discipler_name) e deixar sem ID (discipler_id = NULL)
    customDisciplerMap.set(discipleUuid, discName);
  }
});

console.log(`Discipulado resolvido: ${disciplerMap.size} com ID explícito, ${customDisciplerMap.size} sem ID (salvos somente com o nome).`);

// 7. Fellowships Resolution
const fellowshipPairs = new Set();
activeDisciples.forEach(d => {
  const compName = d.Companheiro ? d.Companheiro.trim() : '';
  const compRowId = d['ID Companheiro'] ? d['ID Companheiro'].trim() : '';
  const dUuid = memberRowToProfileUuid[d['ID Membro']];

  if (!compName || compName === '-' || compName.toLowerCase().includes('presbit') || compName.toLowerCase().includes('diaconato')) return;

  // Apenas registrar se houver ID explícito e válido de membro na planilha (sem adivinhar)
  if (compRowId && memberRowToProfileUuid[compRowId]) {
    const targetUuid = memberRowToProfileUuid[compRowId];
    if (targetUuid && targetUuid !== dUuid) {
      const pair = [dUuid, targetUuid].sort().join('___');
      fellowshipPairs.add(pair);
    }
  }
});

console.log(`Companheirismo resolvido: ${fellowshipPairs.size} pares com ID explícito.`);

console.log('Resolving key profiles for Gabriel, Fernando, and Clara...');

// Identify key profiles
let gabrielProfileId = null;
let fernandoProfileId = null;
let claraProfileId = null;
let flavioProfileId = null;
let marleideProfileId = null;

activeDisciples.forEach(d => {
  const pId = memberRowToProfileUuid[d['ID Membro']];
  const nameClean = cleanString(d.Nome);
  const famClean = cleanString(d.Família);

  if (nameClean.includes('gabrielgoesbraga') || (nameClean === 'gabriel' && d['ID Grupo'] === '102')) {
    gabrielProfileId = pId;
  } else if (nameClean === 'fernando' && d['ID Grupo'] === '102') {
    fernandoProfileId = pId;
  } else if (nameClean === 'clara' && d['ID Grupo'] === '102') {
    claraProfileId = pId;
  } else if (nameClean === 'flavio' && famClean === 'flavio') {
    flavioProfileId = pId;
  } else if (nameClean === 'marleide' && famClean === 'flavio') {
    marleideProfileId = pId;
  }
});

// Deterministic auth UUIDs for the 3 authenticated accounts
const gabrielAuthId = '00000000-0000-0000-0000-000000000001';
const fernandoAuthId = '00000000-0000-0000-0000-000000000002';
const claraAuthId = '00000000-0000-0000-0000-000000000003';

const sqlChunks = [];

sqlChunks.push(`-- ============================================================================
-- SCRIPT DE SEEDING REAL (CENSO): IGREJA EM BELO HORIZONTE
-- Dados oficiais das planilhas importados com fidelidade estrita.
-- Sem criação de emails, telefones, CPFs ou dados socioeconômicos falsos/inventados.
-- Os discípulos reais (exceto as 3 contas indicadas) tornam-se phantom users e crianças.
-- Contas autenticadas (auth.users): exatamente 3 (Gabriel, Fernando e Clara).
-- ============================================================================

DO $$
DECLARE
  pwd_hash text := '$2a$06$XqL/cRckHcXJ1xzAYPKQUORulnZ8gYmOlK1FwEvihHPa7trFLTl9.'; -- 'senha123'
  gabriel_id   uuid := '${gabrielProfileId}';
  fernando_id  uuid := '${fernandoProfileId}';
  clara_id     uuid := '${claraProfileId}';
  flavio_id    uuid := '${flavioProfileId}';
  marleide_id  uuid := '${marleideProfileId}';

  gabriel_auth_id  uuid := '${gabrielAuthId}';
  fernando_auth_id uuid := '${fernandoAuthId}';
  clara_auth_id    uuid := '${claraAuthId}';

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
`);

sectorNames.forEach(sName => {
  const sId = sectorIdMap[sName];
  sqlChunks.push(`  INSERT INTO public.sectors (id, name, created_at) VALUES ('${sId}', ${escapeSql(sName)}, now());`);
});

sqlChunks.push(`
  -- ==========================================================================
  -- 3. CRIAÇÃO DOS GRUPOS CASEIROS (35 Grupos Reais das Planilhas)
  -- ==========================================================================
`);

validGroups.forEach((g, idx) => {
  const gId = groupRowToUuid[g.ID];
  const sId = sectorIdMap[g.Setor];
  const lat = parseFloat(g.Latitude.replace(',', '.'));
  const lng = parseFloat(g.Longitude.replace(',', '.'));
  const meetingDay = (idx % 5) + 2; // Segunda a Sexta (2 a 6)
  const locText = `${g['Bairro / Cidade']} - ${g['Endereço'] || 'Belo Horizonte'}`;

  sqlChunks.push(`  INSERT INTO public.home_groups (
    id, sector_id, location_text, meeting_day, start_time, lat, lng, created_at
  ) VALUES (
    '${gId}', '${sId}', ${escapeSql(locText)}, ${meetingDay}, '19:30:00', ${lat}, ${lng}, now()
  );`);
});

sqlChunks.push(`
  -- ==========================================================================
  -- 4. POVOAMENTO DOS DISCÍPULOS (821 Perfis Reais das Planilhas)
  -- Somente Gabriel, Fernando e Clara recebem dados de contato/autenticação.
  -- Os demais 818 discípulos são armazenados puramente como phantom users / crianças.
  -- ==========================================================================
`);

activeDisciples.forEach((d) => {
  const rowId = d['ID Membro'];
  const pId = memberRowToProfileUuid[rowId];
  const gId = groupRowToUuid[d['ID Grupo']];
  const isKid = d.Situação === 'Filho de discípulo';
  const isMale = d.Sexo === 'Masculino';
  const genderCode = isMale ? 'M' : 'F';

  let fullName = d.Nome.trim();
  const isGabriel = cleanString(fullName).includes('gabrielgoesbraga') || pId === gabrielProfileId;
  const isFernando = pId === fernandoProfileId;
  const isClara = pId === claraProfileId;

  let email = null;
  let phoneVal = null;
  let cpfVal = null;
  let avatarUrl = null;
  let bDate = null;
  let baptDate = null;
  const isBaptized = d.Batizado === 'Sim' || d.Situação === 'Vinculado';

  let isDev = false;
  let isPresbyter = false;
  let isDeacon = false;
  let canPost = false;

  let occ = null;
  let edu = null;
  let emp = null;
  let inc = null;
  let hous = null;
  let mar = isKid ? 'Solteiro(a)' : (spouseMap.has(pId) ? 'Casado(a)' : 'Solteiro(a)');
  let neigh = d.Bairro && d.Bairro.trim() ? d.Bairro.trim() : null;

  // Fidelidade estrita ao CSV: data de nascimento somente quando preenchida na planilha
  if (d['Data de Nascimento'] && d['Data de Nascimento'].includes('/')) {
    const parts = d['Data de Nascimento'].split('/');
    if (parts.length === 3) {
      bDate = `${parts[2]}-${parts[1].padStart(2, '0')}-${parts[0].padStart(2, '0')}`;
    }
  }

  // Configuração exclusiva das 3 contas de autenticação solicitadas pelo usuário:
  // 1. Gabriel Góes Braga: email ggoesbraga@gmail.com, permissão de dev SOMENTE (is_dev = true).
  // 2. Fernando Gomes Braga: email fgb80@yahoo.com, permissão de presbítero (is_presbyter = true).
  // 3. Clara Góes Braga: email claradiscipula@gmail.com, sem permissões administrativas.
  // SEM fotos de perfil (avatar_url = NULL para todos) e SEM invenção de dados fictícios.
  if (isGabriel) {
    fullName = 'Gabriel Góes Braga';
    email = 'ggoesbraga@gmail.com';
    isDev = true;
    isPresbyter = false;
    isDeacon = false;
    canPost = true;
  } else if (isFernando) {
    fullName = 'Fernando Gomes Braga';
    email = 'fgb80@yahoo.com';
    isPresbyter = true;
    isDev = false;
    isDeacon = false;
    canPost = true;
  } else if (isClara) {
    fullName = 'Clara Góes Braga';
    email = 'claradiscipula@gmail.com';
    isPresbyter = false;
    isDev = false;
    isDeacon = false;
    canPost = false;
  }

  const emailSql = email ? escapeSql(email) : 'NULL';
  const phoneSql = phoneVal ? escapeSql(phoneVal) : 'NULL';
  const cpfSql = cpfVal ? escapeSql(cpfVal) : 'NULL';
  const avatarSql = avatarUrl ? escapeSql(avatarUrl) : 'NULL';
  const bDateSql = bDate ? `'${bDate}'::date` : 'NULL';
  const baptSql = baptDate ? `'${baptDate}'::date` : 'NULL';
  const occSql = occ ? escapeSql(occ) : 'NULL';
  const eduSql = edu ? escapeSql(edu) : 'NULL';
  const empSql = emp ? escapeSql(emp) : 'NULL';
  const incSql = inc ? escapeSql(inc) : 'NULL';
  const housSql = hous ? escapeSql(hous) : 'NULL';
  const neighSql = neigh ? escapeSql(neigh) : 'NULL';

  let customDiscName = customDisciplerMap.get(pId) || null;
  if (isGabriel) {
    customDiscName = null; // Gabriel é discipulado por Fernando (discipler_id = fernando_id)
  }
  const customDiscSql = customDiscName ? escapeSql(customDiscName) : 'NULL';

  sqlChunks.push(`  INSERT INTO public.profiles (
    id, full_name, email, cpf, phone, birth_date, baptism_date, is_baptized, gender,
    home_group_id, is_church_linked, is_presbyter, is_deacon, is_dev, can_post,
    marital_status, address_neighborhood, address_city, address_state,
    occupation, education_level, employment_status, household_income, housing_status,
    avatar_url, custom_discipler_name, created_at
  ) VALUES (
    '${pId}', ${escapeSql(fullName)}, ${emailSql}, ${cpfSql}, ${phoneSql}, ${bDateSql}, ${baptSql}, ${isBaptized}, '${genderCode}',
    '${gId}', true, ${isPresbyter}, ${isDeacon}, ${isDev}, ${canPost},
    ${escapeSql(mar)}, ${neighSql}, 'Belo Horizonte', 'MG',
    ${occSql}, ${eduSql}, ${empSql}, ${incSql}, ${housSql},
    ${avatarSql}, ${customDiscSql}, now()
  );`);
});

sqlChunks.push(`
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
`);

sqlChunks.push(`
  -- ==========================================================================
  -- 5. ATUALIZAR LÍDERES DOS GCs (35 Grupos)
  -- ==========================================================================
`);

Object.entries(groupLeaders).forEach(([gRowId, l]) => {
  const gUuid = groupRowToUuid[gRowId];
  const l1Sql = l.leader1 ? `'${l.leader1}'` : 'NULL';
  const l2Sql = l.leader2 ? `'${l.leader2}'` : 'NULL';
  sqlChunks.push(`  UPDATE public.home_groups SET leader_1_id = ${l1Sql}, leader_2_id = ${l2Sql} WHERE id = '${gUuid}';`);
});

sqlChunks.push(`
  -- ==========================================================================
  -- 6. ATUALIZAR CASAMENTOS (spouse_id) E FILIAÇÃO (father_id, mother_id)
  -- ==========================================================================
`);

// Spouses
spouseMap.forEach((spId, pId) => {
  sqlChunks.push(`  UPDATE public.profiles SET spouse_id = '${spId}' WHERE id = '${pId}';`);
});

// Children
childrenMap.forEach((p, kidId) => {
  const fSql = p.fatherId ? `'${p.fatherId}'` : 'NULL';
  const mSql = p.motherId ? `'${p.motherId}'` : 'NULL';
  sqlChunks.push(`  UPDATE public.profiles SET father_id = ${fSql}, mother_id = ${mSql} WHERE id = '${kidId}';`);
});

// Dependents count per parent
dependentsCountMap.forEach((cnt, parentId) => {
  sqlChunks.push(`  UPDATE public.profiles SET dependents_count = ${cnt} WHERE id = '${parentId}';`);
});

sqlChunks.push(`
  -- ==========================================================================
  -- 7. ATUALIZAR DISCIPULADO (discipler_id)
  -- ==========================================================================
`);

disciplerMap.forEach((discId, pId) => {
  sqlChunks.push(`  UPDATE public.profiles SET discipler_id = '${discId}' WHERE id = '${pId}';`);
});

// Special: Fernando is father & discipler of Gabriel, Clara is mother of Gabriel
sqlChunks.push(`  -- Gabriel Góes Braga discipulado por Fernando (Presbítero) e filho de Fernando e Clara
  UPDATE public.profiles 
  SET discipler_id = fernando_id, father_id = fernando_id, mother_id = clara_id 
  WHERE id = gabriel_id;
`);

sqlChunks.push(`
  -- ==========================================================================
  -- 8. JUNTAS DE COMPANHEIRISMO (fellowships)
  -- ==========================================================================
`);

fellowshipPairs.forEach(pair => {
  const [idA, idB] = pair.split('___');
  sqlChunks.push(`  INSERT INTO public.fellowships (member_a_id, member_b_id, created_at) VALUES ('${idA}', '${idB}', now()) ON CONFLICT DO NOTHING;`);
});

// Mutual presbytery fellowship
sqlChunks.push(`  -- Juntas mútuas do presbitério e esposas
  INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
  VALUES (LEAST(fernando_id, flavio_id), GREATEST(fernando_id, flavio_id), now())
  ON CONFLICT DO NOTHING;

  INSERT INTO public.fellowships (member_a_id, member_b_id, created_at)
  VALUES (LEAST(clara_id, marleide_id), GREATEST(clara_id, marleide_id), now())
  ON CONFLICT DO NOTHING;
`);

// Studies & Catechesis
sqlChunks.push(`
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
`);

// Forms extracted cleanly from seed.sql
const baseSeed = fs.readFileSync(path.join(process.cwd(), 'supabase', 'seed.sql'), 'utf8');
const formsSection = baseSeed.substring(
  baseSeed.indexOf('-- 9A. Formulário 1'),
  baseSeed.indexOf('-- Respostas de teste para o Censo de Dons')
);

sqlChunks.push(`
  -- ==========================================================================
  -- 10. FORMULÁRIOS DINÂMICOS & SUBMISSÃO REAL
  -- ==========================================================================
  ${formsSection.trim()}

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
`);

// Retreats, Rooms, Expenses
sqlChunks.push(`
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
`);

// Posts: Autores Fernando e Gabriel (ambos com can_post = true)
sqlChunks.push(`
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
`);

// Event coupons & waitlist
sqlChunks.push(`
  -- ==========================================================================
  -- 13. CUPONS DE DESCONTO E LISTA DE ESPERA
  -- ==========================================================================
  INSERT INTO public.event_coupons (retreat_id, code, discount_percent, target_service_team, is_used, notes)
  VALUES 
    (r_retreat_active, 'LOUVOR100', 100, 'louvor', false, 'Isenção integral para equipe de louvor e instrumentos'),
    (r_retreat_active, 'DIACONIA50', 50, 'cozinha', false, 'Desconto especial para equipe voluntária da cozinha e apoio'),
    (r_retreat_active, 'JOVEM20', 20, 'geral', false, 'Cupom de incentivo aos jovens estudantes');
`);

// Inscrições nos retiros: APENAS a inscrição real de Gabriel Góes Braga
sqlChunks.push(`
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
`);

fs.writeFileSync(outputPath, sqlChunks.join('\n'), 'utf8');
console.log(`\n✅ Generated clean seed-real.sql successfully at: ${outputPath}`);
