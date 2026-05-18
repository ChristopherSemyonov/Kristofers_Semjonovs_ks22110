const db = require('../database/db')

function createUser(req, res) {
  try {
    const { id, name } = req.body

    if (!id || !name) {
      return res.status(400).json({
        error: 'User id and name are required',
      })
    }

    const existingUser = db
      .prepare(
        `
      SELECT * FROM users WHERE id = ?
    `,
      )
      .get(id)

    if (existingUser) {
      return res.json(existingUser)
    }

    const user = {
      id,
      name,
      total_score: 0,
      total_distance_km: 0,
    }

    db.prepare(
      `
      INSERT INTO users (id, name, total_score, total_distance_km)
      VALUES (@id, @name, @total_score, @total_distance_km)
    `,
    ).run(user)

    res.status(201).json(user)
  } catch (error) {
    console.error(error)
    res.status(500).json({ error: 'Failed to create user' })
  }
}

function getUserById(req, res) {
  try {
    const { id } = req.params

    const user = db
      .prepare(
        `
      SELECT * FROM users WHERE id = ?
    `,
      )
      .get(id)

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
      })
    }

    res.json(user)
  } catch (error) {
    console.error(error)
    res.status(500).json({ error: 'Failed to fetch user' })
  }
}

async function updateUser(req, res) {
  try {
    const { id } = req.params
    const { name, total_score, total_distance_km } = req.body

    if (req.user.userId !== id) {
      return res.status(403).json({
        error: 'You can only update your own profile',
      })
    }

    const existingUserResult = await db.query(
      `
      SELECT * FROM users
      WHERE id = $1
      `,
      [id],
    )

    const existingUser = existingUserResult.rows[0]

    if (!existingUser) {
      return res.status(404).json({
        error: 'User not found',
      })
    }

    const updatedUser = {
      id,
      name: name ?? existingUser.name,
      total_score: total_score ?? existingUser.total_score,
      total_distance_km: total_distance_km ?? existingUser.total_distance_km,
    }

    const result = await db.query(
      `
      UPDATE users
      SET name = $1,
          total_score = $2,
          total_distance_km = $3
      WHERE id = $4
      RETURNING
        id,
        name,
        email,
        role,
        profile_image_url,
        total_score,
        total_distance_km,
        created_at
      `,
      [
        updatedUser.name,
        updatedUser.total_score,
        updatedUser.total_distance_km,
        updatedUser.id,
      ],
    )

    res.json(result.rows[0])
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to update user',
    })
  }
}

async function addSolvedPuzzle(req, res) {
  try {
    const { id } = req.params
    const { puzzle_id } = req.body

    if (req.user.userId !== id) {
      return res.status(403).json({
        error: 'You can only update your own solved puzzles',
      })
    }

    if (!puzzle_id) {
      return res.status(400).json({
        error: 'Puzzle id is required',
      })
    }

    const userResult = await db.query(
      `
      SELECT * FROM users
      WHERE id = $1
      `,
      [id],
    )

    const user = userResult.rows[0]

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
      })
    }

    const puzzleResult = await db.query(
      `
      SELECT * FROM puzzles
      WHERE id = $1
      `,
      [puzzle_id],
    )

    const puzzle = puzzleResult.rows[0]

    if (!puzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    const insertResult = await db.query(
      `
      INSERT INTO solved_puzzles (user_id, puzzle_id)
      VALUES ($1, $2)
      ON CONFLICT (user_id, puzzle_id) DO NOTHING
      RETURNING id
      `,
      [id, puzzle_id],
    )

    if (insertResult.rowCount > 0) {
      await db.query(
        `
        UPDATE users
        SET total_score = total_score + $1
        WHERE id = $2
        `,
        [puzzle.points, id],
      )
    }

    const solvedPuzzlesResult = await db.query(
      `
      SELECT p.*
      FROM solved_puzzles sp
      JOIN puzzles p ON p.id = sp.puzzle_id
      WHERE sp.user_id = $1
      `,
      [id],
    )

    res.status(201).json({
      message: 'Puzzle marked as solved',
      solved_puzzles: solvedPuzzlesResult.rows,
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to add solved puzzle',
    })
  }
}

async function getSolvedPuzzles(req, res) {
  try {
    const { id } = req.params

    if (req.user.userId !== id) {
      return res.status(403).json({
        error: 'You can only view your own solved puzzles',
      })
    }

    const userResult = await db.query(
      `
      SELECT * FROM users
      WHERE id = $1
      `,
      [id],
    )

    const user = userResult.rows[0]

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
      })
    }

    const solvedPuzzlesResult = await db.query(
      `
      SELECT p.*
      FROM solved_puzzles sp
      JOIN puzzles p ON p.id = sp.puzzle_id
      WHERE sp.user_id = $1
      `,
      [id],
    )

    res.json(solvedPuzzlesResult.rows)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to fetch solved puzzles',
    })
  }
}

async function getCurrentUser(req, res) {
  try {
    const userId = req.user.userId

    const result = await db.query(
      `
      SELECT
        id,
        name,
        email,
        role,
        profile_image_url,
        total_score,
        total_distance_km,
        created_at
      FROM users
      WHERE id = $1
      `,
      [userId],
    )

    const user = result.rows[0]

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
      })
    }

    res.json(user)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to fetch current user',
    })
  }
}

function addCurrentUserSolvedPuzzle(req, res) {
  req.params.id = req.user.userId
  return addSolvedPuzzle(req, res)
}

function getCurrentUserSolvedPuzzles(req, res) {
  req.params.id = req.user.userId
  return getSolvedPuzzles(req, res)
}

function updateCurrentUser(req, res) {
  req.params.id = req.user.userId
  return updateUser(req, res)
}

async function uploadProfileImage(req, res) {
  try {
    const userId = req.user.userId

    if (!req.file) {
      return res.status(400).json({
        error: 'Profile image is required',
      })
    }

    const imageUrl = `/users/${userId}/profile-image`

    const result = await db.query(
      `
      UPDATE users
      SET profile_image_url = $1,
          profile_image_data = $2,
          profile_image_mime_type = $3
      WHERE id = $4
      RETURNING
        id,
        name,
        email,
        role,
        profile_image_url,
        total_score,
        total_distance_km,
        created_at
      `,
      [imageUrl, req.file.buffer, req.file.mimetype, userId],
    )

    const user = result.rows[0]

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
      })
    }

    res.json({
      message: 'Profile image uploaded successfully',
      user,
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to upload profile image',
    })
  }
}

async function getUserProfileImage(req, res) {
  try {
    const { id } = req.params

    const result = await db.query(
      `
      SELECT profile_image_data, profile_image_mime_type
      FROM users
      WHERE id = $1
      `,
      [id],
    )

    const user = result.rows[0]

    if (!user || !user.profile_image_data) {
      return res.status(404).json({
        error: 'Profile image not found',
      })
    }

    res.set('Content-Type', user.profile_image_mime_type || 'image/jpeg')
    res.send(user.profile_image_data)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to fetch profile image',
    })
  }
}

module.exports = {
  createUser,
  getUserById,
  updateUser,
  addSolvedPuzzle,
  getSolvedPuzzles,
  getCurrentUser,
  addCurrentUserSolvedPuzzle,
  getCurrentUserSolvedPuzzles,
  updateCurrentUser,
  uploadProfileImage,
  getUserProfileImage,
}
