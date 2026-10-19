// Runs before every test file (jest setupFiles). Sets values that `env.js`
// would otherwise read from .env, so tests don't depend on a real .env or DB.
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-jwt-secret-for-unit-tests-0123456789abcdef';
