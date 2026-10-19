import { createSequelize } from '../src/config/database.js';

// One-off reconciliation for the migration renumbering done when merging
// `main` into `feat/user-event-tracking`. Both branches had added migrations
// 007/008, so the `user_events` ones were renumbered to 009/010 to make the
// sequence unambiguous. Umzug keys on filename, so any database where the old
// names were already applied would otherwise see the renamed files as pending
// and try to run them again.
//
// This rewrites the already-applied names in `SequelizeMeta`. It is idempotent:
// running it again is a no-op because the old names no longer exist.
const RENAMES = [
  ['007-create-user-events.js', '009-create-user-events.js'],
  ['008-add-client-event-id-to-user-events.js', '010-add-client-event-id-to-user-events.js'],
];

async function main() {
  const sequelize = createSequelize();

  try {
    for (const [oldName, newName] of RENAMES) {
      // Only touch a row when the new name is not already present, so this can
      // never create a duplicate.
      const [, affected] = await sequelize.query(
        `UPDATE "SequelizeMeta" SET name = :newName
           WHERE name = :oldName
             AND NOT EXISTS (SELECT 1 FROM "SequelizeMeta" WHERE name = :newName)`,
        { replacements: { oldName, newName } }
      );

      const count = Array.isArray(affected) ? affected.length : affected;
      console.log(`  ${count ? '✅' : '⏭️ '} ${oldName} -> ${newName}`);
    }

    const [rows] = await sequelize.query(
      'SELECT name FROM "SequelizeMeta" ORDER BY name;'
    );
    console.log('\n=== SequelizeMeta ===');
    rows.forEach((row) => console.log(`  ${row.name}`));
  } finally {
    await sequelize.close();
  }
}

main().catch((error) => {
  console.error('Rename error:', error);
  process.exit(1);
});
