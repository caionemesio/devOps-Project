import pg from 'pg';
import Database from 'better-sqlite3';
import fs from 'fs';
import path from 'path';

const { Pool } = pg;

const env = process.env.NODE_ENV || 'development';
const databaseUrl = process.env.DATABASE_URL;

let db;

// ========================================
// PRODUÇÃO: PostgreSQL
// ========================================
if (env === 'production' && databaseUrl) {
  console.log('💾 Conectando ao PostgreSQL (produção)...');

  db = new Pool({
    connectionString: databaseUrl,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  });

  // Criar tabela se não existir
  const initDB = async () => {
    try {
      await db.query(`
        CREATE TABLE IF NOT EXISTS tasks (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);
      console.log('✅ Tabela "tasks" verificada/criada no PostgreSQL');
    } catch (err) {
      console.error('❌ Erro ao criar tabela:', err);
      process.exit(1);
    }
  };

  initDB();
}
// ========================================
// DESENVOLVIMENTO: SQLite
// ========================================
else {
  console.log('💾 Conectando ao SQLite (desenvolvimento)...');

  const DB_DIR = path.resolve('src', 'db_data');
  if (!fs.existsSync(DB_DIR)) fs.mkdirSync(DB_DIR, { recursive: true });

  const DB_FILE = 'tasks_dev.db';
  const DB_PATH = path.join(DB_DIR, DB_FILE);

  db = new Database(DB_PATH);

  db.prepare(
    `
    CREATE TABLE IF NOT EXISTS tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `
  ).run();

  console.log(`✅ SQLite conectado: ${DB_FILE}`);
}

export default db;
