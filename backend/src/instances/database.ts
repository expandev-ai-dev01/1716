import sql, { ConnectionPool } from 'mssql';
import { config } from '@/config';

let pool: ConnectionPool;

const dbConfig = {
  server: config.database.server,
  port: config.database.port,
  user: config.database.user,
  password: config.database.password,
  database: config.database.database,
  options: {
    encrypt: config.database.options.encrypt,
    trustServerCertificate: config.database.options.trustServerCertificate,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

/**
 * @summary
 * Establishes and returns a singleton database connection pool.
 *
 * @returns A promise that resolves to the ConnectionPool instance.
 */
export async function getDbPool(): Promise<ConnectionPool> {
  if (pool && pool.connected) {
    return pool;
  }
  try {
    pool = await new ConnectionPool(dbConfig).connect();
    console.log('Database connection pool established.');
    pool.on('error', (err) => {
      console.error('Database Pool Error', err);
    });
    return pool;
  } catch (err) {
    console.error('Database connection failed:', err);
    throw err;
  }
}

/**
 * @summary
 * Closes the database connection pool.
 */
export async function closeDbPool(): Promise<void> {
  if (pool && pool.connected) {
    await pool.close();
    console.log('Database connection pool closed.');
  }
}
