const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')
const db = require('../database/db')

const JWT_SECRET = process.env.JWT_SECRET || 'urban_quest_secret_key'

async function register(req, res) {
  try {
    const { name, email, password } = req.body

    if (!name || !email || !password) {
      return res.status(400).json({
        error: 'Name, email and password are required',
      })
    }

    if (password.length < 6) {
      return res.status(400).json({
        error: 'Password must be at least 6 characters long',
      })
    }

    const existingUserResult = await db.query(
      `
      SELECT * FROM users
      WHERE email = $1
      `,
      [email],
    )

    const existingUser = existingUserResult.rows[0]

    if (existingUser) {
      return res.status(409).json({
        error: 'User with this email already exists',
      })
    }

    const passwordHash = bcrypt.hashSync(password, 10)
    const userId = `user_${Date.now()}`

    const user = {
      id: userId,
      name,
      email,
      password_hash: passwordHash,
      role: 'user',
      total_score: 0,
      total_distance_km: 0,
    }

    await db.query(
      `
      INSERT INTO users (
        id, name, email, password_hash, role, total_score, total_distance_km
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      `,
      [
        user.id,
        user.name,
        user.email,
        user.password_hash,
        user.role,
        user.total_score,
        user.total_distance_km,
      ],
    )

    const token = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role,
      },
      JWT_SECRET,
      {
        expiresIn: '7d',
      },
    )

    res.status(201).json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        total_score: user.total_score,
        total_distance_km: user.total_distance_km,
      },
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to register user',
    })
  }
}

async function login(req, res) {
  try {
    const { email, password } = req.body

    if (!email || !password) {
      return res.status(400).json({
        error: 'Email and password are required',
      })
    }

    const userResult = await db.query(
      `
      SELECT * FROM users
      WHERE email = $1
      `,
      [email],
    )

    const user = userResult.rows[0]

    if (!user) {
      return res.status(401).json({
        error: 'Invalid email or password',
      })
    }

    const passwordIsValid = bcrypt.compareSync(password, user.password_hash)

    if (!passwordIsValid) {
      return res.status(401).json({
        error: 'Invalid email or password',
      })
    }

    const token = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role,
      },
      JWT_SECRET,
      {
        expiresIn: '7d',
      },
    )

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        profile_image_url: user.profile_image_url,
        total_score: user.total_score,
        total_distance_km: user.total_distance_km,
      },
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to login user',
    })
  }
}

async function seedAdmin(req, res) {
  try {
    const { secret } = req.body

    if (secret !== process.env.ADMIN_SEED_SECRET) {
      return res.status(403).json({
        error: 'Invalid seed secret',
      })
    }

    const adminEmail = process.env.ADMIN_EMAIL
    const adminPassword = process.env.ADMIN_PASSWORD
    const adminName = process.env.ADMIN_NAME || 'Admin User'

    if (!adminEmail || !adminPassword) {
      return res.status(500).json({
        error: 'Admin environment variables are missing',
      })
    }

    const passwordHash = bcrypt.hashSync(adminPassword, 10)
    const adminId = `admin_${Date.now()}`

    await db.query(
      `
      INSERT INTO users (
        id, name, email, password_hash, role, total_score, total_distance_km
      )
      VALUES ($1, $2, $3, $4, 'admin', 0, 0)
      ON CONFLICT (email)
      DO UPDATE SET
        role = 'admin',
        password_hash = EXCLUDED.password_hash,
        name = EXCLUDED.name
      `,
      [adminId, adminName, adminEmail, passwordHash],
    )

    res.json({
      message: 'Admin user created or promoted successfully',
      email: adminEmail,
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to seed admin user',
    })
  }
}

async function resetUsers(req, res) {
  try {
    const { secret } = req.body

    if (secret !== process.env.ADMIN_SEED_SECRET) {
      return res.status(403).json({
        error: 'Invalid seed secret',
      })
    }

    await db.query(`DELETE FROM solved_puzzles`)
    await db.query(`DELETE FROM users`)

    res.json({
      message: 'All users and solved puzzle records deleted successfully',
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to reset users',
    })
  }
}

module.exports = {
  register,
  login,
  seedAdmin,
  resetUsers,
}
