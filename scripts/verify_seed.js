import fs from 'fs';
import path from 'path';
import pg from 'pg';

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

async function verify() {
  const env = parseEnv(path.join(process.cwd(), '.env'));
  const envLocal = parseEnv(path.join(process.cwd(), '.env.local'));
  const password = envLocal.DEV_DB_PASSWORD || env.DEV_DB_PASSWORD;
  const supabaseUrl = envLocal.VITE_SUPABASE_URL || env.VITE_SUPABASE_URL;
  const match = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.(co|net)/);
  const projectRef = match[1];
  const host = `db.${projectRef}.supabase.co`;
  const connectionString = `postgresql://postgres:${encodeURIComponent(password)}@${host}:5432/postgres`;
  let client;
  let connected = false;

  console.log(`Tentando conexão direta (IPv6) ao host: ${host}...`);
  client = new pg.Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });

  try {
    const connectPromise = client.connect();
    const timeoutPromise = new Promise((_, reject) => 
      setTimeout(() => reject(new Error('timeout')), 5000)
    );
    await Promise.race([connectPromise, timeoutPromise]);
    connected = true;
    console.log('Conectado via conexão direta com sucesso.');
  } catch (err) {
    console.log(`Conexão direta indisponível ou expirou. Erro: ${err.message}`);
    await client.end().catch(() => {});

    const poolerHosts = [
      `aws-0-sa-east-1.pooler.supabase.com`,
      `aws-1-sa-east-1.pooler.supabase.com`
    ];

    for (const poolerHost of poolerHosts) {
      const poolerUser = `postgres.${projectRef}`;
      const poolerConnectionString = `postgresql://${poolerUser}:${encodeURIComponent(password)}@${poolerHost}:6543/postgres`;
      console.log(`Tentando conexão via Pooler (IPv4) ao host: ${poolerHost}...`);

      client = new pg.Client({
        connectionString: poolerConnectionString,
        ssl: { rejectUnauthorized: false }
      });

      try {
        await client.connect();
        connected = true;
        console.log(`Conectado via Pooler (IPv4) ao host ${poolerHost} com sucesso.`);
        break;
      } catch (poolerErr) {
        console.log(`Falha ao conectar via Pooler ao host ${poolerHost}: ${poolerErr.message}`);
        await client.end().catch(() => {});
      }
    }
  }

  if (!connected) {
    console.error('ERRO CRÍTICO: Não foi possível conectar ao banco de dados via conexão direta ou pooler.');
    process.exit(1);
  }

  console.log('\n=== VERIFICAÇÃO DO NOVO SEEDING (DADOS REAIS DOS 35 GCs) ===\n');

  // 1. Contagens gerais
  const tables = [
    'sectors', 'home_groups', 'profiles', 'fellowships',
    'posts', 'media_resources', 'studies', 'study_steps',
    'user_study_progress', 'forms', 'form_submissions',
    'retreats', 'retreat_rooms', 'retreat_expenses', 'registrations'
  ];

  for (const table of tables) {
    const res = await client.query(`SELECT count(*) FROM public.${table}`);
    console.log(`Tabela ${table.padEnd(22)}: ${res.rows[0].count} registros`);
  }

  const authUsers = await client.query(`SELECT count(*) FROM auth.users`);
  console.log(`Tabela ${'auth.users'.padEnd(22)}: ${authUsers.rows[0].count} contas de acesso`);

  // 2. Validação dos Setores
  const sectorsRes = await client.query(`SELECT id, name FROM public.sectors ORDER BY name`);
  console.log('\n--- Setores Cadastrados (Esperado: 6) ---');
  console.table(sectorsRes.rows);
  if (sectorsRes.rows.length !== 6) {
    console.error(`❌ ERRO: Esperado 6 setores, encontrados ${sectorsRes.rows.length}`);
    process.exitCode = 1;
  }

  // 3. Validação dos Grupos Caseiros
  const hgRes = await client.query(`
    SELECT count(*) as total,
           count(leader_1_id) as with_leader_1,
           count(leader_2_id) as with_leader_2,
           count(lat) as with_lat,
           count(lng) as with_lng
    FROM public.home_groups
  `);
  console.log('\n--- Integridade dos Grupos Caseiros (Esperado: 35) ---');
  console.table(hgRes.rows);
  if (parseInt(hgRes.rows[0].total, 10) !== 35) {
    console.error(`❌ ERRO: Esperado 35 Grupos Caseiros, encontrados ${hgRes.rows[0].total}`);
    process.exitCode = 1;
  }

  // 4. Validação de Gabriel Góes Braga
  const gabrielRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.gender, p.is_dev, p.is_presbyter, p.is_deacon, p.can_post,
           p.home_group_id, hg.location_text as home_group_name,
           (SELECT count(*) FROM auth.users WHERE email = p.email) as auth_users_count
    FROM public.profiles p
    LEFT JOIN public.home_groups hg ON hg.id = p.home_group_id
    WHERE p.email = 'ggoesbraga@gmail.com'
  `);
  console.log('\n--- Perfil do Desenvolvedor (Gabriel Góes Braga) ---');
  console.table(gabrielRes.rows);

  if (gabrielRes.rows.length !== 1) {
    console.error('❌ ERRO: Perfil de Gabriel Góes Braga não encontrado com ggoesbraga@gmail.com');
    process.exitCode = 1;
  } else {
    const g = gabrielRes.rows[0];
    if (!g.is_dev) {
      console.error('❌ ERRO: Gabriel Góes Braga deve ter is_dev = true');
      process.exitCode = 1;
    }
    if (g.is_presbyter || g.is_deacon) {
      console.error('❌ ERRO: Gabriel Góes Braga deve ser "dev somente" (is_presbyter = false, is_deacon = false)');
      process.exitCode = 1;
    }
    if (!g.home_group_name || !g.home_group_name.includes('102')) {
      console.error(`❌ AVISO: Gabriel Góes Braga deveria estar vinculado ao GC 102 (Heliópolis). Vinculado a: ${g.home_group_name}`);
    }
    if (parseInt(g.auth_users_count, 10) !== 1) {
      console.error('❌ ERRO: Gabriel Góes Braga não possui conta em auth.users');
      process.exitCode = 1;
    }
  }

  // 5. Validação de Ausência de Emails Fictícios
  const fakeEmailsRes = await client.query(`
    SELECT count(*) as count
    FROM public.profiles
    WHERE email IS NOT NULL AND email <> 'ggoesbraga@gmail.com'
  `);
  console.log(`\nPerfis com e-mail além do Dev: ${fakeEmailsRes.rows[0].count} (Esperado: 0)`);
  if (parseInt(fakeEmailsRes.rows[0].count, 10) > 0) {
    console.error('❌ ERRO: Existem perfis com e-mail além de Gabriel Góes Braga.');
    process.exitCode = 1;
  }

  // 6. Validação de Limpeza de Dados de Teste
  const testPosts = await client.query(`SELECT count(*) FROM public.posts`);
  const testRetreats = await client.query(`SELECT count(*) FROM public.retreats`);
  const testRegs = await client.query(`SELECT count(*) FROM public.registrations`);
  if (parseInt(testPosts.rows[0].count, 10) !== 0 || parseInt(testRetreats.rows[0].count, 10) !== 0 || parseInt(testRegs.rows[0].count, 10) !== 0) {
    console.error('❌ ERRO: Posts, retiros ou inscrições de teste não foram limpos completamente.');
    process.exitCode = 1;
  } else {
    console.log('✅ Dados de movimentação (posts, retiros, inscrições) 100% limpos.');
  }

  // 7. Validação de Catálogo de Ensinos e Formulários
  const studiesCount = await client.query(`SELECT count(*) FROM public.studies`);
  const mediaCount = await client.query(`SELECT count(*) FROM public.media_resources`);
  const formsCount = await client.query(`SELECT count(*) FROM public.forms`);
  console.log(`\nCatálogo de Ensinos: ${studiesCount.rows[0].count} trilhas, ${mediaCount.rows[0].count} recursos de mídia.`);
  console.log(`Modelos de Formulários: ${formsCount.rows[0].count} formulários ativos.`);

  if (parseInt(studiesCount.rows[0].count, 10) < 3 || parseInt(mediaCount.rows[0].count, 10) < 10 || parseInt(formsCount.rows[0].count, 10) < 5) {
    console.error('❌ ERRO: Catálogo base de ensinos ou formulários incompleto.');
    process.exitCode = 1;
  } else {
    console.log('✅ Catálogo base de Ensinos e Formulários íntegro.');
  }

  console.log('\n======================================================');
  if (process.exitCode === 1) {
    console.log('❌ FALHA NA VERIFICAÇÃO DO BANCO DE DADOS.');
  } else {
    console.log('🎉 TODOS OS TESTES DE VALIDAÇÃO PASSARAM COM SUCESSO!');
  }
  console.log('======================================================\n');

  await client.end();
}

verify().catch((err) => {
  console.error('Erro na execução da verificação:', err);
  process.exit(1);
});
