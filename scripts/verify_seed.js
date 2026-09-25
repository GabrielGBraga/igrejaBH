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

  const client = new pg.Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });

  await client.connect();

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

  // Verify Gabriel
  const gabrielRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.is_deacon, p.is_dev, p.discipler_id,
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

  // Verify Fernando Gomes Braga (Presbyter) & Clara Góes Braga
  const fernandoRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.is_presbyter,
           (SELECT full_name FROM public.profiles WHERE id = p.spouse_id) as spouse_name,
           (SELECT count(*) FROM public.profiles WHERE father_id = p.id) as children_count
    FROM public.profiles p
    WHERE p.full_name = 'Fernando Gomes Braga'
  `);
  console.log('\nFernando Gomes Braga data:');
  console.log(fernandoRes.rows[0]);

  const claraRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.gender,
           (SELECT full_name FROM public.profiles WHERE id = p.spouse_id) as spouse_name,
           (SELECT count(*) FROM public.profiles WHERE mother_id = p.id) as children_count
    FROM public.profiles p
    WHERE p.full_name = 'Clara Góes Braga'
  `);
  console.log('\nClara Góes Braga data:');
  console.log(claraRes.rows[0]);

  // Verify Rafael Moraes & Family
  const rafaelRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.is_deacon, p.dependents_count,
           (SELECT full_name FROM public.profiles WHERE id = p.spouse_id) as spouse_name,
           (SELECT full_name FROM public.profiles WHERE id = p.discipler_id) as discipler_name,
           (SELECT count(*) FROM public.profiles WHERE father_id = p.id) as children_count
    FROM public.profiles p
    WHERE p.full_name = 'Rafael Moraes'
  `);
  console.log('\nRafael Moraes data:');
  console.log(rafaelRes.rows[0]);

  const isabeleRes = await client.query(`
    SELECT p.id, p.full_name, p.email, p.phone, p.gender, p.dependents_count,
           (SELECT full_name FROM public.profiles WHERE id = p.spouse_id) as spouse_name,
           (SELECT full_name FROM public.profiles WHERE id = p.discipler_id) as discipler_name
    FROM public.profiles p
    WHERE p.full_name = 'Isabele Moraes'
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

  // Check post categories
  const postsRes = await client.query(`SELECT category, count(*) FROM public.posts GROUP BY category`);
  console.log('\nPosts by Category:');
  console.table(postsRes.rows);

  // Check phone length
  const invalidPhones = await client.query(`
    SELECT count(*) FROM public.profiles 
    WHERE phone IS NOT NULL AND length(regexp_replace(phone, '[^0-9]', '', 'g')) <> 11
  `);
  console.log(`\nProfiles with invalid phone length (<> 11 digits): ${invalidPhones.rows[0].count}`);

  // Check "Seu / Dona"
  const seuDona = await client.query(`
    SELECT count(*) FROM public.profiles 
    WHERE full_name LIKE 'Seu %' OR full_name LIKE 'Dona %'
  `);
  console.log(`Profiles with 'Seu / Dona' in legal name: ${seuDona.rows[0].count}`);

  // Check distinct addresses
  const addresses = await client.query(`
    SELECT count(DISTINCT address_street) as distinct_streets, count(DISTINCT address_neighborhood) as distinct_neighborhoods
    FROM public.profiles
  `);
  console.log(`Distinct streets: ${addresses.rows[0].distinct_streets}, distinct neighborhoods: ${addresses.rows[0].distinct_neighborhoods}`);

  // Check avatars populated
  const avatars = await client.query(`
    SELECT count(*) as populated_avatars FROM public.profiles WHERE avatar_url IS NOT NULL
  `);
  console.log(`Populated avatars: ${avatars.rows[0].populated_avatars}`);

  await client.end();
}

verify().catch(console.error);
