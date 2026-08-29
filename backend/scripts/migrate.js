import path from 'path';
import { fileURLToPath } from 'url';
import { Umzug, SequelizeStorage } from 'umzug';
import { createSequelize } from '../src/config/database.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const COMMANDS = ['up', 'down', 'status'];

async function main() {
  const command = process.argv[2] || 'up';

  if (!COMMANDS.includes(command)) {
    console.error(`Unknown command: ${command}`);
    console.error(`Usage: node scripts/migrate.js [${COMMANDS.join('|')}]`);
    process.exitCode = 1;
    return;
  }

  const sequelize = createSequelize();

  const umzug = new Umzug({
    migrations: { glob: path.join(__dirname, '../migrations/*.js') },
    context: sequelize,
    storage: new SequelizeStorage({ sequelize, tableName: 'SequelizeMeta' }),
  });

  try {
    if (command === 'up') {
      const applied = await umzug.up();
      if (applied.length === 0) {
        console.log('No pending migrations.');
      } else {
        console.log(`Applied ${applied.length} migration(s):`);
        applied.forEach((migration) => console.log(`  ✅ ${migration.name}`));
      }
      return;
    }

    if (command === 'down') {
      const reverted = await umzug.down();
      if (reverted.length === 0) {
        console.log('No migrations to revert.');
      } else {
        console.log(`Reverted ${reverted.length} migration(s):`);
        reverted.forEach((migration) => console.log(`  ⏪ ${migration.name}`));
      }
      return;
    }

    if (command === 'status') {
      const [executed, pending] = await Promise.all([
        umzug.executed(),
        umzug.pending(),
      ]);

      console.log('\n=== Executed migrations ===');
      if (executed.length === 0) {
        console.log('  (none)');
      } else {
        executed.forEach((migration) => console.log(`  ✅ ${migration.name}`));
      }

      console.log('\n=== Pending migrations ===');
      if (pending.length === 0) {
        console.log('  (none)');
      } else {
        pending.forEach((migration) => console.log(`  ⏳ ${migration.name}`));
      }
    }
  } finally {
    await sequelize.close();
  }
}

main().catch((error) => {
  console.error('Migration error:', error);
  process.exit(1);
});
