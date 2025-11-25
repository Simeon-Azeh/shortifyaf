const { Pool } = require('pg');

// Connection is read from DATABASE_URL env var, otherwise from individual PG_* vars
const connectionString = process.env.DATABASE_URL;

const pool = new Pool({
    connectionString,
    // SSL is required for Azure Postgres by default; rely on connection string param sslmode=require
});

async function init() {
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
