import { Sequelize } from 'sequelize';
import { buildSequelizeOptions, createSequelize } from '../src/config/database.js';

const baseDbConfig = {
  databaseUrl: undefined,
  ssl: true,
  dialect: 'postgres',
  pool: { min: 2, max: 10 },
  logging: false,
  host: 'localhost',
  port: 5432,
  name: 'miajudai_dev',
  username: 'postgres',
  password: 'postgres',
};

describe('buildSequelizeOptions', () => {
  test('with DATABASE_URL + default SSL → uses the URL and enables SSL', () => {
    const databaseUrl = 'postgresql://user:pass@db.supabase.co:5432/postgres';
    const result = buildSequelizeOptions({ ...baseDbConfig, databaseUrl });

    expect(result.useUrl).toBe(true);
    expect(result.connectionString).toBe(databaseUrl);
    expect(result.options.dialectOptions.ssl).toEqual({
      require: true,
      rejectUnauthorized: false,
    });
  });

  test('with POSTGRES_SSL=false → produces options without dialectOptions.ssl', () => {
    const result = buildSequelizeOptions({ ...baseDbConfig, ssl: false });

    expect(result.useUrl).toBe(false);
    expect(result.options.host).toBe('localhost');
    expect(result.options.port).toBe(5432);
    expect(result.options.dialectOptions).toBeUndefined();
  });

  test('with DATABASE_URL present → the URL takes priority over POSTGRES_* fields', () => {
    const databaseUrl = 'postgresql://url-user:url-pass@url-host:5432/url-db';
    const result = buildSequelizeOptions({
      ...baseDbConfig,
      databaseUrl,
      host: 'ignored-host',
      port: 9999,
      name: 'ignored-db',
      username: 'ignored-user',
      password: 'ignored-pass',
    });

    expect(result.useUrl).toBe(true);
    expect(result.connectionString).toBe(databaseUrl);
    expect(result.database).toBeUndefined();
    expect(result.username).toBeUndefined();
    expect(result.password).toBeUndefined();
  });
});

describe('createSequelize', () => {
  test('returns a postgres Sequelize instance with SSL enabled from DATABASE_URL', () => {
    const sequelize = createSequelize({
      ...baseDbConfig,
      databaseUrl: 'postgresql://user:pass@db.supabase.co:5432/postgres',
    });

    expect(sequelize).toBeInstanceOf(Sequelize);
    expect(sequelize.getDialect()).toBe('postgres');
    expect(sequelize.config.dialectOptions.ssl).toEqual({
      require: true,
      rejectUnauthorized: false,
    });

    sequelize.close();
  });

  test('returns a postgres Sequelize instance without SSL when ssl=false', () => {
    const sequelize = createSequelize({ ...baseDbConfig, ssl: false });

    expect(sequelize).toBeInstanceOf(Sequelize);
    expect(sequelize.getDialect()).toBe('postgres');
    expect(sequelize.config.dialectOptions).toBeUndefined();

    sequelize.close();
  });
});
