const db = require('../database/db')

async function getAllPuzzles(req, res) {
  try {
    const result = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE is_active = 1
      ORDER BY id
      `,
    )

    res.json(result.rows)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to fetch puzzles',
    })
  }
}

async function getPuzzleById(req, res) {
  try {
    const { id } = req.params

    const result = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    const puzzle = result.rows[0]

    if (!puzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    res.json(puzzle)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to fetch puzzle',
    })
  }
}

function normalizeAnswer(value) {
  return value
    .trim()
    .toLowerCase()
    .replaceAll('ā', 'a')
    .replaceAll('ē', 'e')
    .replaceAll('ī', 'i')
    .replaceAll('ū', 'u')
    .replaceAll('ģ', 'g')
    .replaceAll('ķ', 'k')
    .replaceAll('ļ', 'l')
    .replaceAll('ņ', 'n')
    .replaceAll('š', 's')
    .replaceAll('č', 'c')
    .replaceAll('ž', 'z')
}

function calculateDistanceMeters(lat1, lon1, lat2, lon2) {
  const earthRadiusMeters = 6371000

  const dLat = ((lat2 - lat1) * Math.PI) / 180
  const dLon = ((lon2 - lon1) * Math.PI) / 180

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2)

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  return earthRadiusMeters * c
}

async function checkPuzzleAnswer(req, res) {
  try {
    const { id } = req.params
    const { answer, latitude, longitude } = req.body

    if (!answer) {
      return res.status(400).json({
        error: 'Answer is required',
      })
    }

    if (latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        error: 'User location is required',
      })
    }

    const result = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    const puzzle = result.rows[0]

    if (!puzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    const distance = calculateDistanceMeters(
      Number(latitude),
      Number(longitude),
      puzzle.latitude,
      puzzle.longitude,
    )

    const unlockRadiusMeters = 50

    if (distance > unlockRadiusMeters) {
      return res.status(403).json({
        error: 'User is outside puzzle zone',
        distance_meters: distance,
        remaining_meters: distance - unlockRadiusMeters,
      })
    }

    const isCorrect = normalizeAnswer(answer) === normalizeAnswer(puzzle.answer)

    res.json({
      correct: isCorrect,
      points: isCorrect ? puzzle.points : 0,
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to check answer',
    })
  }
}

async function createPuzzle(req, res) {
  try {
    const {
      id,
      title,
      question,
      answer,
      points,
      difficulty,
      latitude,
      longitude,
    } = req.body

    if (
      !id ||
      !title ||
      !question ||
      !answer ||
      points === undefined ||
      !difficulty ||
      latitude === undefined ||
      longitude === undefined
    ) {
      return res.status(400).json({
        error: 'All puzzle fields are required',
      })
    }

    const existingPuzzleResult = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    if (existingPuzzleResult.rows[0]) {
      return res.status(409).json({
        error: 'Puzzle with this id already exists',
      })
    }

    const result = await db.query(
      `
      INSERT INTO puzzles (
        id,
        title,
        question,
        answer,
        points,
        difficulty,
        latitude,
        longitude,
        is_active
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 1)
      RETURNING *
      `,
      [id, title, question, answer, points, difficulty, latitude, longitude],
    )

    res.status(201).json(result.rows[0])
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to create puzzle',
    })
  }
}

async function updatePuzzle(req, res) {
  try {
    const { id } = req.params

    const existingPuzzleResult = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    const existingPuzzle = existingPuzzleResult.rows[0]

    if (!existingPuzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    const updatedPuzzle = {
      title: req.body.title ?? existingPuzzle.title,
      question: req.body.question ?? existingPuzzle.question,
      answer: req.body.answer ?? existingPuzzle.answer,
      points: req.body.points ?? existingPuzzle.points,
      difficulty: req.body.difficulty ?? existingPuzzle.difficulty,
      latitude: req.body.latitude ?? existingPuzzle.latitude,
      longitude: req.body.longitude ?? existingPuzzle.longitude,
    }

    const result = await db.query(
      `
      UPDATE puzzles
      SET title = $1,
          question = $2,
          answer = $3,
          points = $4,
          difficulty = $5,
          latitude = $6,
          longitude = $7
      WHERE id = $8
      RETURNING *
      `,
      [
        updatedPuzzle.title,
        updatedPuzzle.question,
        updatedPuzzle.answer,
        updatedPuzzle.points,
        updatedPuzzle.difficulty,
        updatedPuzzle.latitude,
        updatedPuzzle.longitude,
        id,
      ],
    )

    res.json(result.rows[0])
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to update puzzle',
    })
  }
}

async function deletePuzzle(req, res) {
  try {
    const { id } = req.params

    const existingPuzzleResult = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    const existingPuzzle = existingPuzzleResult.rows[0]

    if (!existingPuzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    await db.query(
      `
      DELETE FROM solved_puzzles
      WHERE puzzle_id = $1
      `,
      [id],
    )

    await db.query(
      `
      DELETE FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    res.json({
      message: 'Puzzle deleted successfully',
      deletedPuzzle: existingPuzzle,
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to delete puzzle',
    })
  }
}

async function hidePuzzle(req, res) {
  try {
    const { id } = req.params

    const existingPuzzleResult = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    const existingPuzzle = existingPuzzleResult.rows[0]

    if (!existingPuzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    const result = await db.query(
      `
      UPDATE puzzles
      SET is_active = 0
      WHERE id = $1
      RETURNING *
      `,
      [id],
    )

    res.json({
      message: 'Puzzle hidden successfully',
      puzzle: result.rows[0],
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to hide puzzle',
    })
  }
}

async function getAllPuzzlesForAdmin(req, res) {
  try {
    const result = await db.query(
      `
      SELECT *
      FROM puzzles
      ORDER BY id
      `,
    )

    res.json(result.rows)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to fetch admin puzzles',
    })
  }
}

async function unhidePuzzle(req, res) {
  try {
    const { id } = req.params

    const existingPuzzleResult = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    const existingPuzzle = existingPuzzleResult.rows[0]

    if (!existingPuzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    const result = await db.query(
      `
      UPDATE puzzles
      SET is_active = 1
      WHERE id = $1
      RETURNING *
      `,
      [id],
    )

    res.json({
      message: 'Puzzle restored successfully',
      puzzle: result.rows[0],
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to restore puzzle',
    })
  }
}

async function solvePuzzle(req, res) {
  try {
    const { id } = req.params
    const { answer, latitude, longitude } = req.body
    const userId = req.user.userId

    if (!answer) {
      return res.status(400).json({
        error: 'Answer is required',
      })
    }

    if (latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        error: 'User location is required',
      })
    }

    const puzzleResult = await db.query(
      `
      SELECT *
      FROM puzzles
      WHERE id = $1
      `,
      [id],
    )

    const puzzle = puzzleResult.rows[0]

    if (!puzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    const distance = calculateDistanceMeters(
      Number(latitude),
      Number(longitude),
      puzzle.latitude,
      puzzle.longitude,
    )

    const unlockRadiusMeters = 50

    if (distance > unlockRadiusMeters) {
      return res.status(403).json({
        error: 'User is outside puzzle zone',
        distance_meters: distance,
        remaining_meters: distance - unlockRadiusMeters,
      })
    }

    const isCorrect = normalizeAnswer(answer) === normalizeAnswer(puzzle.answer)

    if (!isCorrect) {
      return res.json({
        correct: false,
        points: 0,
      })
    }

    const insertResult = await db.query(
      `
      INSERT INTO solved_puzzles (user_id, puzzle_id)
      VALUES ($1, $2)
      ON CONFLICT (user_id, puzzle_id) DO NOTHING
      RETURNING id
      `,
      [userId, id],
    )

    if (insertResult.rowCount > 0) {
      await db.query(
        `
        UPDATE users
        SET total_score = total_score + $1
        WHERE id = $2
        `,
        [puzzle.points, userId],
      )
    }

    const userResult = await db.query(
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

    const solvedPuzzlesResult = await db.query(
      `
      SELECT p.*
      FROM solved_puzzles sp
      JOIN puzzles p ON p.id = sp.puzzle_id
      WHERE sp.user_id = $1
      `,
      [userId],
    )

    res.json({
      correct: true,
      already_solved: insertResult.rowCount === 0,
      points: insertResult.rowCount > 0 ? puzzle.points : 0,
      user: userResult.rows[0],
      solved_puzzles: solvedPuzzlesResult.rows,
    })
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to solve puzzle',
    })
  }
}

module.exports = {
  getAllPuzzles,
  getPuzzleById,
  checkPuzzleAnswer,
  createPuzzle,
  updatePuzzle,
  deletePuzzle,
  hidePuzzle,
  getAllPuzzlesForAdmin,
  unhidePuzzle,
  solvePuzzle,
}
