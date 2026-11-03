import fs from 'fs';
import path from 'path';
import pg from 'pg';
import { buildFamiliesForProfiles, getFamilyForProfile } from '../src/lib/familyUtils.ts';

function parseEnv(filePath) {
  if (!fs.existsSync(filePath)) return {};
  const content = fs.readFileSync(filePath, 'utf8');
  const env = {};
  content.split(/\r?\n/).forEach((line) => {
    line = line.trim();
    if (!line || line.startsWith('#')) return;
    const index = line.indexOf('=');
    if (index !== -1) {
      const key = line.substring(0, index).trim();
      let value = line.substring(index + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      env[key] = value;
    }
  });
  return env;
}

// -------------------------------------------------------------
// TESTE 1: CASOS DE BORDA UNITÁRIOS (ISOLADOS)
// -------------------------------------------------------------
console.log('=== TESTE 1: CENÁRIOS UNITÁRIOS DE REGRAS DE NEGÓCIO ===');

const mockProfiles = [
  // Família 1: Pais (Fernando e Clara) com filho solteiro (Artur)
  {
    id: 'p-fernando',
    full_name: 'Fernando',
    gender: 'M',
    marital_status: 'casado',
    spouse_id: 'p-clara',
    father_id: null,
    mother_id: null,
    home_group_id: 'gc-1',
  },
  {
    id: 'p-clara',
    full_name: 'Clara',
    gender: 'F',
    marital_status: 'casado',
    spouse_id: 'p-fernando',
    father_id: null,
    mother_id: null,
    home_group_id: 'gc-1',
  },
  {
    id: 'p-artur',
    full_name: 'Artur',
    gender: 'M',
    marital_status: 'solteiro',
    spouse_id: null,
    father_id: 'p-fernando',
    mother_id: 'p-clara',
    home_group_id: 'gc-1',
  },

  // Filho casado de Fernando e Clara: Gabriel (casado com Luísa, tem filho Neto)
  // DEVE fundar automaticamente uma família própria!
  {
    id: 'p-gabriel',
    full_name: 'Gabriel',
    gender: 'M',
    marital_status: 'casado',
    spouse_id: 'p-luisa',
    father_id: 'p-fernando',
    mother_id: 'p-clara',
    home_group_id: 'gc-1',
  },
  {
    id: 'p-luisa',
    full_name: 'Luísa',
    gender: 'F',
    marital_status: 'casado',
    spouse_id: 'p-gabriel',
    father_id: null,
    mother_id: null,
    home_group_id: 'gc-1',
  },
  {
    id: 'p-neto',
    full_name: 'Neto',
    gender: 'M',
    marital_status: 'solteiro',
    spouse_id: null,
    father_id: 'p-gabriel',
    mother_id: 'p-luisa',
    home_group_id: 'gc-1',
  },

  // Família Monoparental Feminina: Marina (mãe solteira/viúva) e filha Sofia
  {
    id: 'p-marina',
    full_name: 'Marina',
    gender: 'F',
    marital_status: 'solteira',
    spouse_id: null,
    father_id: null,
    mother_id: null,
    home_group_id: 'gc-1',
  },
  {
    id: 'p-sofia',
    full_name: 'Sofia',
    gender: 'F',
    marital_status: 'solteira',
    spouse_id: null,
    father_id: null,
    mother_id: 'p-marina',
    home_group_id: 'gc-1',
  },

  // Irmão Solteiro sem conexões (Família própria)
  {
    id: 'p-ismael',
    full_name: 'Ismael',
    gender: 'M',
    marital_status: 'solteiro',
    spouse_id: null,
    father_id: null,
    mother_id: null,
    home_group_id: 'gc-1',
  },
];

const mockFamilies = buildFamiliesForProfiles(mockProfiles);
console.log(`Total de famílias geradas no mock: ${mockFamilies.length}`);

// Validação A: Fernando é chefe de sua família com Clara e Artur (tamanho 3)
const fernandoFam = mockFamilies.find(f => f.head.id === 'p-fernando');
if (!fernandoFam || fernandoFam.size !== 3) {
  throw new Error(`Falha na família de Fernando: esperado 3 membros, obtido ${fernandoFam?.size}`);
}
if (!fernandoFam.members.some(m => m.id === 'p-artur')) {
  throw new Error('Artur (filho solteiro) deveria estar na família de Fernando!');
}
if (fernandoFam.members.some(m => m.id === 'p-gabriel')) {
  throw new Error('Gabriel (filho CASADO) NÃO deveria estar na família de Fernando!');
}
console.log('✅ Validação A aprovada: Filho solteiro fica com os pais; filho casado sai.');

// Validação B: Gabriel é chefe da sua família com Luísa e Neto (tamanho 3)
const gabrielFam = mockFamilies.find(f => f.head.id === 'p-gabriel');
if (!gabrielFam || gabrielFam.size !== 3) {
  throw new Error(`Falha na família de Gabriel: esperado 3 membros, obtido ${gabrielFam?.size}`);
}
if (gabrielFam.head.id !== 'p-gabriel') {
  throw new Error('Gabriel deve ser o chefe de sua família!');
}
console.log('✅ Validação B aprovada: Filho casado é chefe da sua nova família independente.');

// Validação C: Marina (mãe) é chefe da sua família monoparental
const marinaFam = mockFamilies.find(f => f.head.id === 'p-marina');
if (!marinaFam || marinaFam.size !== 2) {
  throw new Error(`Falha na família de Marina: esperado 2 membros, obtido ${marinaFam?.size}`);
}
console.log('✅ Validação C aprovada: Família monoparental feminina chefiada pela mãe.');

// Validação D: Ismael tem família própria (tamanho 1)
const ismaelFam = mockFamilies.find(f => f.head.id === 'p-ismael');
if (!ismaelFam || !ismaelFam.isIndividual || ismaelFam.size !== 1) {
  throw new Error(`Falha na família de Ismael: esperado individual de tamanho 1`);
}
console.log('✅ Validação D aprovada: Irmão sem vínculos constitui família própria.');


// -------------------------------------------------------------
// TESTE 2: INTEGRAÇÃO COM CENSO REAL DO SUPABASE (35 GCs / 821 Perfis)
// -------------------------------------------------------------
async function runRealCensusValidation() {
  console.log('\n=== TESTE 2: VALIDAÇÃO CONTRA O CENSO REAL (821 DISCÍPULOS) ===');
  const env = parseEnv(path.join(process.cwd(), '.env'));
  const envLocal = parseEnv(path.join(process.cwd(), '.env.local'));
  const password = envLocal.DEV_DB_PASSWORD || env.DEV_DB_PASSWORD;
  const supabaseUrl = envLocal.VITE_SUPABASE_URL || env.VITE_SUPABASE_URL;
  const match = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.(co|net)/);
  const projectRef = match[1];
  const host = `db.${projectRef}.supabase.co`;
  const connectionString = `postgresql://postgres:${encodeURIComponent(password)}@${host}:5432/postgres`;

  const client = new pg.Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });
  await client.connect();

  const { rows: profiles } = await client.query(`
    SELECT id, full_name, gender, marital_status, spouse_id, father_id, mother_id, home_group_id, baptism_date, is_church_linked
    FROM profiles;
  `);

  const { rows: homeGroups } = await client.query(`SELECT id, location_text FROM home_groups;`);

  console.log(`Carregados ${profiles.length} perfis reais e ${homeGroups.length} grupos.`);

  let totalAllocatedProfiles = 0;
  let totalFamilies = 0;

  homeGroups.forEach(g => {
    const groupProfiles = profiles.filter(p => p.home_group_id === g.id);
    const families = buildFamiliesForProfiles(groupProfiles);

    totalFamilies += families.length;
    families.forEach(f => {
      totalAllocatedProfiles += f.size;

      // Todo chefe de família deve estar presente nos membros
      if (!f.members.some(m => m.id === f.head.id)) {
        throw new Error(`Chefe ${f.head.full_name} não está entre os membros da família ${f.id}`);
      }

      // Se tamanho for 1, deve ser isIndividual
      if (f.size === 1 && !f.isIndividual) {
        throw new Error(`Família ${f.name} de tamanho 1 não está marcada como isIndividual`);
      }
    });
  });

  if (totalAllocatedProfiles !== profiles.length) {
    throw new Error(`Inconsistência de partição: total alocado (${totalAllocatedProfiles}) !== total de perfis (${profiles.length})`);
  }

  console.log(`✅ 100% dos ${profiles.length} discípulos foram perfeitamente particionados em ${totalFamilies} famílias.`);
  console.log(`✅ Nenhuma duplicidade ou perda de dados.`);

  await client.end();
}

runRealCensusValidation().then(() => {
  console.log('\n🎉 TODOS OS TESTES DE RESOLUÇÃO DE FAMÍLIAS PASSARAM COM SUCESSO!\n');
  process.exit(0);
}).catch(err => {
  console.error('❌ Erro no teste:', err);
  process.exit(1);
});
