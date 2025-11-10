import Database from "better-sqlite3";
import fs from "fs";
import path from "path";

const env = process.env.NODE_ENV || "development";

const DB_DIR = path.resolve("src", "db_data");
if (!fs.existsSync(DB_DIR)) fs.mkdirSync(DB_DIR, { recursive: true });

const DB_FILE = env === "production" ? "tasks_prod.db" : "tasks_dev.db";
const DB_PATH = path.join(DB_DIR, DB_FILE);

console.log(`💾 Conectando ao banco: ${DB_FILE} (${env})`);

const db = new Database(DB_PATH);

db.prepare(
  `
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
`
).run();

export default db;
