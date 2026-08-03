import fs from 'fs';
import path from 'path';
import pg from 'pg';

// Função para parsear arquivos .env de forma manual e simples
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
  console.log('=== SEEDING DATABASE ===');

  // Carregar variáveis de .env e .env.local
  const env = parseEnv(path.join(process.cwd(), '.env'));
  const envLocal = parseEnv(path.join(process.cwd(), '.env.local'));

  // Obter senha e URL
  const password = envLocal.DEV_DB_PASSWORD || env.DEV_DB_PASSWORD;
  const supabaseUrl = envLocal.VITE_SUPABASE_URL || env.VITE_SUPABASE_URL;

  if (!password) {
    console.error('ERRO: DEV_DB_PASSWORD não encontrada em .env ou .env.local');
    process.exit(1);
  }

  if (!supabaseUrl) {
    console.error('ERRO: VITE_SUPABASE_URL não encontrada em .env ou .env.local');
    process.exit(1);
  }

  // Extrair o project ref da URL do Supabase (ex: https://ref.supabase.co)
  const match = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.(co|net)/);
  if (!match) {
    console.error('ERRO: Formato inválido de VITE_SUPABASE_URL:', supabaseUrl);
    process.exit(1);
  }
  const projectRef = match[1];
  const host = `db.${projectRef}.supabase.co`;

  // Construir a string de conexão postgres
  const connectionString = `postgresql://postgres:${encodeURIComponent(password)}@${host}:5432/postgres`;

  // Ler o seed.sql
  const seedFilePath = path.join(process.cwd(), 'supabase', 'seed.sql');
  if (!fs.existsSync(seedFilePath)) {
    console.error('ERRO: Arquivo supabase/seed.sql não encontrado.');
    process.exit(1);
  }
  const seedSql = fs.readFileSync(seedFilePath, 'utf8');

  let client;
  let connected = false;

  // Tentativa 1: Conexão Direta (IPv6)
  console.log(`Tentando conexão direta (IPv6) ao host: ${host}...`);
  client = new pg.Client({
    connectionString: connectionString,
    ssl: {
      rejectUnauthorized: false
    }
  });

  try {
    // Configurar um timeout curto para a tentativa inicial (ex: 5 segundos)
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
    
    // Tentativa 2: Conexão via Pooler (IPv4)
    const poolerHosts = [
      `aws-0-sa-east-1.pooler.supabase.com`,
      `aws-1-sa-east-1.pooler.supabase.com`
    ];
    
    let poolerConnected = false;
    for (const poolerHost of poolerHosts) {
      const poolerUser = `postgres.${projectRef}`;
      const poolerConnectionString = `postgresql://${poolerUser}:${encodeURIComponent(password)}@${poolerHost}:6543/postgres`;
      console.log(`Tentando conexão via Pooler (IPv4) ao host: ${poolerHost}...`);
      
      client = new pg.Client({
        connectionString: poolerConnectionString,
        ssl: {
          rejectUnauthorized: false
        }
      });
      
      try {
        await client.connect();
        connected = true;
        poolerConnected = true;
        console.log(`Conectado via Pooler (IPv4) ao host ${poolerHost} com sucesso.`);
        break;
      } catch (poolerErr) {
        console.log(`Falha ao conectar via Pooler ao host ${poolerHost}: ${poolerErr.message}`);
        await client.end().catch(() => {});
      }
    }
    
    if (!poolerConnected) {
      console.error('\n❌ Erro em todas as tentativas de conexão com o banco.');
      process.exit(1);
    }
  }

  try {
    console.log('Executando o script SQL (isso pode levar alguns segundos devido ao volume)...');
    
    const startTime = Date.now();
    await client.query(seedSql);
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    
    console.log(`\n✅ Banco popular com sucesso em ${duration} segundos!`);
  } catch (err) {
    console.error('\n❌ Erro durante a execução do seeding:', err.message);
    process.exit(1);
  } finally {
    await client.end();
    console.log('Conexão encerrada.');
  }
}

run();
