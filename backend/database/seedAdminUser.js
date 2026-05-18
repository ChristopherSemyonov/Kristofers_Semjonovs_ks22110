require('dotenv').config()

const bcrypt = require('bcryptjs')
const pool = require('./postgresDb')

async function seedAdminUser() {
  try {
    const adminEmail = process.env.ADMIN_EMAIL
    const adminPassword = process.env.ADMIN_PASSWORD
    const adminName = process.env.ADMIN_NAME || 'Admin User'

    if (!adminEmail || !adminPassword) {
      throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD are required')
    }

    const passwordHash = bcrypt.hashSync(adminPassword, 10)
    const adminId = `admin_${Date.now()}`

    await pool.query(
      `
      INSERT INTO users (
        id, name, email, password_hash, role,
        total_score, total_distance_km
      )
      VALUES ($1, $2, $3, $4, 'admin', 0, 0)
      ON CONFLICT (email)
      DO UPDATE SET role = 'admin'
      `,
      [adminId, adminName, adminEmail, passwordHash],
    )

    console.log('Admin user seeded successfully')
  } catch (error) {
    console.error('Failed to seed admin user')
    console.error(error)
  } finally {
    await pool.end()
  }
}

seedAdminUser()
