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

  console.log('=== VERIFYING DATABASE SEED DATA ===\n');

  const tables = [
    'profiles', 'home_groups', 'sectors', 'fellowships',
    'posts', 'media_resources', 'studies', 'study_steps',
    'user_study_progress', 'forms', 'form_submissions',
    'retreats', 'retreat_rooms', 'retreat_expenses', 'registrations'
  ];

  for (const table of tables) {
    const res = await client.query(`SELECT count(*) FROM public.${table}`);
    console.log(`Table ${table.padEnd(20)}: ${res.rows[0].count} rows`);
  }

  const authUsers = await client.query(`SELECT count(*) FROM auth.users`);
  console.log(`Table ${'auth.users'.padEnd(20)}: ${authUsers.rows[0].count} rows`);

  const phantomStats = await client.query(`
    SELECT 
      count(*) FILTER (WHERE user_id IS NULL) as phantom_count,
      count(*) FILTER (WHERE user_id IS NOT NULL) as active_auth_count,
      count(*) FILTER (WHERE email IS NULL) as no_email_count,
      count(*) FILTER (WHERE email IS NOT NULL) as with_email_count,
      count(*) FILTER (WHERE cpf IS NULL) as no_cpf_count,
      count(*) FILTER (WHERE cpf IS NOT NULL) as with_cpf_count,
      count(*) FILTER (WHERE avatar_url IS NOT NULL) as avatar_count
    FROM public.profiles;
  `);
  console.log('\nPerfis Fantasmas vs Autenticados:');
  console.table(phantomStats.rows);

  const discStats = await client.query(`
    SELECT 
      count(*) FILTER (WHERE discipler_id IS NOT NULL) as linked_discipler_count,
      count(*) FILTER (WHERE custom_discipler_name IS NOT NULL) as custom_discipler_count,
      count(*) FILTER (WHERE discipler_id IS NULL AND custom_discipler_name IS NULL) as no_discipler_count
    FROM public.profiles;
  `);
  console.log('\nEstatísticas de Discipulado (ID Vinculado vs Nome Livre):');
  console.table(discStats.rows);

  // Sample with custom discipler name
  const sampleCustomDisc = await client.query(`
    SELECT full_name, discipler_id, custom_discipler_name
    FROM public.profiles
    WHERE custom_discipler_name IS NOT NULL
    LIMIT 5;
  `);
  console.log('\nAmostra de Discípulos com Discipulador por Nome Livre (Sem ID):');
  console.table(sampleCustomDisc.rows);

  // Verify Gabriel
  const gabrielRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.gender, p.avatar_url, p.is_deacon, p.is_dev, p.discipler_id, p.custom_discipler_name,
           (SELECT full_name FROM public.profiles WHERE id = p.father_id) as father_name,
           (SELECT full_name FROM public.profiles WHERE id = p.mother_id) as mother_name,
           (SELECT full_name FROM public.profiles WHERE id = p.discipler_id) as discipler_name,
           (SELECT count(*) FROM public.registrations WHERE profile_id = p.id) as registrations_count,
           (SELECT count(*) FROM public.user_study_progress WHERE profile_id = p.id) as studies_completed
    FROM public.profiles p
    WHERE p.email = 'ggoesbraga@gmail.com'
  `);
  console.log('\nGabriel Góes Braga data:');
  console.log(gabrielRes.rows[0]);

  // Verify Fernando (Presbyter) & Clara
  const fernandoRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.avatar_url, p.is_presbyter,
           (SELECT full_name FROM public.profiles WHERE id = p.spouse_id) as spouse_name,
           (SELECT count(*) FROM public.profiles WHERE father_id = p.id) as children_count
    FROM public.profiles p
    WHERE p.email = 'fgb80@yahoo.com'
    LIMIT 1
  `);
  console.log('\nFernando (Presbítero) data:');
  console.log(fernandoRes.rows[0]);

  const claraRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.gender, p.avatar_url,
           (SELECT full_name FROM public.profiles WHERE id = p.spouse_id) as spouse_name,
           (SELECT count(*) FROM public.profiles WHERE mother_id = p.id) as children_count
    FROM public.profiles p
    WHERE p.email = 'claradiscipula@gmail.com'
    LIMIT 1
  `);
  console.log('\nClara data:');
  console.log(claraRes.rows[0]);

  // Verify Rafael Moraes & Family
  const rafaelRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.is_deacon, p.dependents_count,
           (SELECT full_name FROM public.profiles WHERE id = p.spouse_id) as spouse_name,
           (SELECT full_name FROM public.profiles WHERE id = p.discipler_id) as discipler_name,
           (SELECT count(*) FROM public.profiles WHERE father_id = p.id) as children_count
    FROM public.profiles p
    WHERE p.full_name ILIKE 'Rafael%Moraes%'
    LIMIT 1
  `);
  console.log('\nRafael Moraes data:');
  console.log(rafaelRes.rows[0]);

  const isabeleRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.gender, p.dependents_count,
           (SELECT full_name FROM public.profiles WHERE id = p.spouse_id) as spouse_name,
           (SELECT full_name FROM public.profiles WHERE id = p.discipler_id) as discipler_name
    FROM public.profiles p
    WHERE p.full_name ILIKE 'Isabel%Moraes%'
    LIMIT 1
  `);
  console.log('\nIsabele Moraes data:');
  console.log(isabeleRes.rows[0]);

  if (rafaelRes.rows[0]?.id) {
    const familyRes = await client.query(`
      SELECT p.id, p.full_name, p.gender, p.birth_date, p.baptism_date, p.occupation,
             (SELECT full_name FROM public.profiles WHERE id = p.father_id) as father_name,
             (SELECT full_name FROM public.profiles WHERE id = p.mother_id) as mother_name
      FROM public.profiles p
      WHERE p.father_id = $1
      ORDER BY p.birth_date ASC
    `, [rafaelRes.rows[0].id]);
    console.log('\nFilhos de Rafael e Isabele:');
    console.table(familyRes.rows);
  }

  // Check retreat statuses
  const retreatRes = await client.query(`SELECT id, title, status, price, max_participants FROM public.retreats ORDER BY start_date`);
  console.log('\nRetreats:');
  console.table(retreatRes.rows);

  // Check retreat forms
  const retreatFormsRes = await client.query(`
    SELECT r.id, r.title, r.status, r.form_id, f.name as form_name,
           (SELECT count(*) FROM public.form_submissions fs WHERE fs.form_id = r.form_id) as submissions_count
    FROM public.retreats r
    LEFT JOIN public.forms f ON f.id = r.form_id
    ORDER BY r.start_date
  `);
  console.log('\nRetreat Forms & Submissions:');
  console.table(retreatFormsRes.rows);

  // Check 1-to-1 uniqueness: no form_id shared across multiple retreats
  const duplicateFormsRes = await client.query(`
    SELECT form_id, count(*) as count
    FROM public.retreats
    WHERE form_id IS NOT NULL
    GROUP BY form_id
    HAVING count(*) > 1
  `);
  if (duplicateFormsRes.rows.length > 0) {
    console.error('❌ ERRO: Existem formulários vinculados a mais de um evento:', duplicateFormsRes.rows);
    process.exitCode = 1;
  } else {
    console.log('✅ Validação 1-para-1: Cada evento possui formulário único e exclusivo.');
  }

  // Check studies progress
  const studiesRes = await client.query(`
    SELECT s.id, s.title,
           (SELECT count(*) FROM public.study_steps ss WHERE ss.study_id = s.id) as steps_count
    FROM public.studies s
    ORDER BY s.title
  `);
  console.log('\nStudies:');
  console.table(studiesRes.rows);

  // Check study accounts (unlinked users)
  const unlinkedRes = await client.query(`
    SELECT count(*) as unlinked_count
    FROM public.profiles
    WHERE is_church_linked = false
  `);
  console.log(`\nPerfis não vinculados à igreja (contas de estudo): ${unlinkedRes.rows[0].unlinked_count}`);

  await client.end();
  console.log('\nDiagnóstico concluído.');
}

verify();
