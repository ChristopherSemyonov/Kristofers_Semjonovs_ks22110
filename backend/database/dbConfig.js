const databaseType = process.env.DATABASE_TYPE || 'sqlite'

function isPostgres() {
  return databaseType === 'postgres'
}

function isSqlite() {
  return databaseType === 'sqlite'
}

module.exports = {
  databaseType,
  isPostgres,
  isSqlite,
}
