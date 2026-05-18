const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')
const db = require('../database/db')

const JWT_SECRET = process.env.JWT_SECRET || 'urban_quest_secret_key'

function register(req, res) {
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

    const existingUser = db
      .prepare(
        `
      SELECT * FROM users WHERE email = ?
    `,
      )
      .get(email)

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

    db.prepare(
      `
      INSERT INTO users (
        id, name, email, password_hash, role, total_score, total_distance_km
      )
      VALUES (
        @id, @name, @email, @password_hash, @role, @total_score, @total_distance_km
      )
    `,
    ).run(user)

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
        total_score: user.total_score,
        total_distance_km: user.total_distance_km,
        role: user.role,
      },
    })
  } catch (error) {
    console.error(error)
    res.status(500).json({
      error: 'Failed to register user',
    })
  }
}

function login(req, res) {
  try {
    const { email, password } = req.body

    if (!email || !password) {
      return res.status(400).json({
        error: 'Email and password are required',
      })
    }

    const user = db
      .prepare(
        `
      SELECT * FROM users WHERE email = ?
    `,
      )
      .get(email)

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

function seedAdmin(req, res) {
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

    const existingAdmin = db
      .prepare(
        `
        SELECT * FROM users
        WHERE email = ?
      `,
      )
      .get(adminEmail)

    const passwordHash = bcrypt.hashSync(adminPassword, 10)

    if (existingAdmin) {
      db.prepare(
        `
        UPDATE users
        SET role = 'admin',
            password_hash = ?
        WHERE email = ?
      `,
      ).run(passwordHash, adminEmail)

      return res.json({
        message: 'Existing user promoted to admin',
        email: adminEmail,
      })
    }

    const adminId = `admin_${Date.now()}`

    db.prepare(
      `
      INSERT INTO users (
        id, name, email, password_hash, role, total_score, total_distance_km
      )
      VALUES (?, ?, ?, ?, 'admin', 0, 0)
    `,
    ).run(adminId, adminName, adminEmail, passwordHash)

    res.status(201).json({
      message: 'Admin user created successfully',
      email: adminEmail,
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to seed admin user',
    })
  }
}

function resetUsers(req, res) {
  try {
    const { secret } = req.body

    if (secret !== process.env.ADMIN_SEED_SECRET) {
      return res.status(403).json({
        error: 'Invalid seed secret',
      })
    }

    db.prepare(`DELETE FROM solved_puzzles`).run()
    db.prepare(`DELETE FROM users`).run()

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
