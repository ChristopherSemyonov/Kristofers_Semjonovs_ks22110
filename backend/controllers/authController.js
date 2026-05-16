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
      total_score: 0,
      total_distance_km: 0,
    }

    db.prepare(
      `
      INSERT INTO users (
        id, name, email, password_hash, total_score, total_distance_km
      )
      VALUES (
        @id, @name, @email, @password_hash, @total_score, @total_distance_km
      )
    `,
    ).run(user)

    const token = jwt.sign(
      {
        userId: user.id,
        email: user.email,
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

module.exports = {
  register,
  login,
}
