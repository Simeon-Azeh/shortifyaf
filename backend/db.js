const { Pool } = require('pg');

// Connection is read from DATABASE_URL env var, otherwise from individual PG_* vars
const connectionString = process.env.DATABASE_URL;

// Check if DATABASE_URL is valid by trying to parse it
let useConnectionString = false;
if (connectionString) {
  try {
    new URL(connectionString);
    useConnectionString = true;
  } catch (e) {
    console.log('DATABASE_URL is invalid, falling back to individual PG_* variables');
  }
}

const poolConfig = useConnectionString ? { connectionString } : {
  host: process.env.PGHOST || 'shortifyaf-pg-dev-spaincentral.postgres.database.azure.com',
  port: process.env.PGPORT || 5432,
  database: process.env.PGDATABASE || 'shortifyaf',
  user: process.env.PGUSER || 'shortify_user',
  password: process.env.PGPASSWORD || 'Testing123!',
  ssl: true // Required for Azure Postgres
};

console.log('DB.js loaded, checking environment...');
console.log('All environment variables:', Object.keys(process.env).filter(key => key.startsWith('PG') || key.includes('DATABASE')).reduce((obj, key) => {
  obj[key] = key.includes('PASSWORD') ? '[REDACTED]' : process.env[key];
  return obj;
}, {})); const pool = new Pool(poolConfig); async function init() {
  // Create urls table if it doesn't exist
  const sql = `
    CREATE TABLE IF NOT EXISTS urls (
      id SERIAL PRIMARY KEY,
      short_id VARCHAR(32) UNIQUE NOT NULL,
      original_url TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT now()
    );
  `;

  await pool.query(sql);
}

module.exports = {
  query: (text, params) => pool.query(text, params),
  init,
  pool,
};
