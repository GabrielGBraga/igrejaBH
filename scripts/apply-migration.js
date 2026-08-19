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

async function run() {
  console.log('=== APLICANDO MIGRAÇÕES SQL NO SUPABASE ===');

  const env = parseEnv(path.join(process.cwd(), '.env'));
  const envLocal = parseEnv(path.join(process.cwd(), '.env.local'));

  const password = envLocal.DEV_DB_PASSWORD || env.DEV_DB_PASSWORD || envLocal.PRD_DB_PASSWORD || env.PRD_DB_PASSWORD;
  const supabaseUrl = envLocal.VITE_SUPABASE_URL || env.VITE_SUPABASE_URL;

  if (!password) {
    console.error('ERRO: Senha do banco não encontrada em .env');
    process.exit(1);
  }

  if (!supabaseUrl) {
    console.error('ERRO: VITE_SUPABASE_URL não encontrada em .env');
    process.exit(1);
  }

  const match = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.(co|net)/);
  if (!match) {
    console.error('ERRO: Formato inválido de VITE_SUPABASE_URL:', supabaseUrl);
    process.exit(1);
  }
  const projectRef = match[1];
  const host = `db.${projectRef}.supabase.co`;

  const migrationsDir = path.join(process.cwd(), 'supabase', 'migrations');
  if (!fs.existsSync(migrationsDir)) {
    console.error(`ERRO: Diretório de migrações não encontrado: ${migrationsDir}`);
    process.exit(1);
  }

  const migrationFiles = fs.readdirSync(migrationsDir)
    .filter(f => f.endsWith('.sql'))
    .sort();

  console.log(`Encontradas ${migrationFiles.length} migrações SQL:`, migrationFiles);

  let client;
  let connected = false;

  console.log(`Conectando ao banco Supabase (${projectRef})...`);

  // Tentativa 1: Conexão Direta (IPv6)
  client = new pg.Client({
    connectionString: `postgresql://postgres:${encodeURIComponent(password)}@${host}:5432/postgres`,
    ssl: { rejectUnauthorized: false }
  });

  try {
    const connectPromise = client.connect();
    const timeoutPromise = new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), 5000));
    await Promise.race([connectPromise, timeoutPromise]);
    connected = true;
    console.log('Conectado via conexão direta com sucesso.');
  } catch (err) {
    console.log(`Conexão direta indisponível. Tentando via Pooler IPv4...`);
    await client.end().catch(() => {});

    const poolerHosts = [
      `aws-0-sa-east-1.pooler.supabase.com`,
      `aws-1-sa-east-1.pooler.supabase.com`
    ];

    for (const poolerHost of poolerHosts) {
      const poolerUser = `postgres.${projectRef}`;
      const poolerConnectionString = `postgresql://${poolerUser}:${encodeURIComponent(password)}@${poolerHost}:6543/postgres`;
      client = new pg.Client({
        connectionString: poolerConnectionString,
        ssl: { rejectUnauthorized: false }
      });
      try {
        await client.connect();
        connected = true;
        console.log(`Conectado via Pooler ao host ${poolerHost} com sucesso.`);
        break;
      } catch (poolerErr) {
        await client.end().catch(() => {});
      }
    }
  }

  if (!connected) {
    console.error('❌ Falha ao conectar ao banco de dados Supabase.');
    process.exit(1);
  }

  try {
    const targetFiles = process.argv[2] ? [process.argv[2]] : migrationFiles;

    for (const file of targetFiles) {
      const filePath = path.join(migrationsDir, file);
      if (!fs.existsSync(filePath)) continue;
      const sql = fs.readFileSync(filePath, 'utf8');
      console.log(`Executando migração ${file}...`);
      try {
        await client.query(sql);
        console.log(`✅ ${file} executada com sucesso!`);
      } catch (fileErr) {
        console.log(`⚠️ ${file} ignorada/já aplicada (${fileErr.message})`);
      }
    }

    console.log('Solicitando recarga do schema do PostgREST (NOTIFY pgrst, \'reload schema\')...');
    await client.query("NOTIFY pgrst, 'reload schema';");
    console.log('✅ Cache do schema PostgREST atualizada!');
  } catch (err) {
    console.error('❌ Erro ao conectar/aplicar migrações:', err.message);
    process.exit(1);
  } finally {
    await client.end();
    console.log('Conexão encerrada.');
  }
}

run();
