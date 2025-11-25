const db = require('../db');

async function createTableIfNotExists() {
  await db.init();
}

async function findByShortId(shortId) {
  const { rows } = await db.query('SELECT * FROM urls WHERE short_id = $1 LIMIT 1', [shortId]);
  return rows[0] || null;
}

async function findRecent(limit = 10) {
  const { rows } = await db.query('SELECT short_id, original_url, created_at FROM urls ORDER BY created_at DESC LIMIT $1', [limit]);
  return rows;
}

async function insertUrl(shortId, originalUrl) {
  const { rows } = await db.query(
    'INSERT INTO urls (short_id, original_url) VALUES ($1, $2) RETURNING short_id, original_url, created_at',
    [shortId, originalUrl]
  );
  return rows[0];
}

async function existsShortId(shortId) {
  const { rows } = await db.query('SELECT 1 FROM urls WHERE short_id = $1 LIMIT 1', [shortId]);
  return rows.length > 0;
}

module.exports = {
  createTableIfNotExists,
  findByShortId,
  findRecent,
  insertUrl,
  existsShortId,
};
