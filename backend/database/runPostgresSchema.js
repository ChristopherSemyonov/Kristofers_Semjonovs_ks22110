require('dotenv').config()

const fs = require('fs')
const path = require('path')
const pool = require('./postgresDb')

async function runPostgresSchema() {
  try {
    const schemaPath = path.join(__dirname, 'postgresSchema.sql')
    const schemaSql = fs.readFileSync(schemaPath, 'utf8')

    await pool.query(schemaSql)

    console.log('PostgreSQL schema created successfully')
  } catch (error) {
    console.error('Failed to create PostgreSQL schema')
    console.error(error)
  } finally {
    await pool.end()
  }
}

runPostgresSchema()
