export async function up({ context: sequelize }) {
  // Add a client-generated idempotency key so retries can't insert the same
  // event twice. Existing rows are backfilled with a fresh UUID first.
  await sequelize.query(
    'ALTER TABLE user_events ADD COLUMN IF NOT EXISTS client_event_id UUID;'
  );
  await sequelize.query(
    'UPDATE user_events SET client_event_id = gen_random_uuid() WHERE client_event_id IS NULL;'
  );
  await sequelize.query(
    'ALTER TABLE user_events ALTER COLUMN client_event_id SET NOT NULL;'
  );
  await sequelize.query(
    'ALTER TABLE user_events ADD CONSTRAINT user_events_client_event_id_key UNIQUE (client_event_id);'
  );
}

export async function down({ context: sequelize }) {
  await sequelize.query(
    'ALTER TABLE user_events DROP CONSTRAINT IF EXISTS user_events_client_event_id_key;'
  );
  await sequelize.query(
    'ALTER TABLE user_events DROP COLUMN IF EXISTS client_event_id;'
  );
}
