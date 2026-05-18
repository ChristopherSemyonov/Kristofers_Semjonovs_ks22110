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

function updateUser(req, res) {
  try {
    const { id } = req.params
    if (req.user.userId !== id) {
      return res.status(403).json({
        error: 'You can only update your own profile',
      })
    }
    const { name, total_score, total_distance_km } = req.body

    const existingUser = db
      .prepare(
        `
      SELECT * FROM users WHERE id = ?
    `,
      )
      .get(id)

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

    db.prepare(
      `
      UPDATE users
      SET name = @name,
          total_score = @total_score,
          total_distance_km = @total_distance_km
      WHERE id = @id
    `,
    ).run(updatedUser)

    res.json(updatedUser)
  } catch (error) {
    console.error(error)
    res.status(500).json({ error: 'Failed to update user' })
  }
}

function addSolvedPuzzle(req, res) {
  try {
    const { id } = req.params

    if (req.user.userId !== id) {
      return res.status(403).json({
        error: 'You can only update your own solved puzzles',
      })
    }

    const { puzzle_id } = req.body

    if (!puzzle_id) {
      return res.status(400).json({
        error: 'Puzzle id is required',
      })
    }

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

    const puzzle = db
      .prepare(
        `
      SELECT * FROM puzzles WHERE id = ?
    `,
      )
      .get(puzzle_id)

    if (!puzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    const result = db
      .prepare(
        `
  INSERT OR IGNORE INTO solved_puzzles (user_id, puzzle_id)
  VALUES (?, ?)
`,
      )
      .run(id, puzzle_id)

    if (result.changes > 0) {
      db.prepare(
        `
    UPDATE users
    SET total_score = total_score + ?
    WHERE id = ?
  `,
      ).run(puzzle.points, id)
    }

    const solvedPuzzles = db
      .prepare(
        `
      SELECT p.*
      FROM solved_puzzles sp
      JOIN puzzles p ON p.id = sp.puzzle_id
      WHERE sp.user_id = ?
    `,
      )
      .all(id)

    res.status(201).json({
      message: 'Puzzle marked as solved',
      solved_puzzles: solvedPuzzles,
    })
  } catch (error) {
    console.error(error)
    res.status(500).json({ error: 'Failed to add solved puzzle' })
  }
}

function getSolvedPuzzles(req, res) {
  try {
    const { id } = req.params

    if (req.user.userId !== id) {
      return res.status(403).json({
        error: 'You can only view your own solved puzzles',
      })
    }

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

    const solvedPuzzles = db
      .prepare(
        `
      SELECT p.*
      FROM solved_puzzles sp
      JOIN puzzles p ON p.id = sp.puzzle_id
      WHERE sp.user_id = ?
    `,
      )
      .all(id)

    res.json(solvedPuzzles)
  } catch (error) {
    console.error(error)
    res.status(500).json({ error: 'Failed to fetch solved puzzles' })
  }
}

function getCurrentUser(req, res) {
  try {
    const userId = req.user.userId

    const user = db
      .prepare(
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
      WHERE id = ?
    `,
      )
      .get(userId)

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

function uploadProfileImage(req, res) {
  try {
    const userId = req.user.userId

    if (!req.file) {
      return res.status(400).json({
        error: 'Profile image is required',
      })
    }

    const imageUrl = `/uploads/${req.file.filename}`

    db.prepare(
      `
      UPDATE users
      SET profile_image_url = ?
      WHERE id = ?
    `,
    ).run(imageUrl, userId)

    const user = db
      .prepare(
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
        WHERE id = ?
      `,
      )
      .get(userId)

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
}
