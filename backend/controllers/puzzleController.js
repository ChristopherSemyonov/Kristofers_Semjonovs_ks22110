const db = require('../database/db')

function getAllPuzzles(req, res) {
  try {
    const puzzles = db
      .prepare(
        `
      SELECT * FROM puzzles
    `,
      )
      .all()

    res.json(puzzles)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to fetch puzzles',
    })
  }
}

function getPuzzleById(req, res) {
  try {
    const { id } = req.params

    const puzzle = db
      .prepare(
        `
      SELECT * FROM puzzles
      WHERE id = ?
    `,
      )
      .get(id)

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

function checkPuzzleAnswer(req, res) {
  try {
    const { id } = req.params
    const { answer } = req.body

    if (!answer) {
      return res.status(400).json({
        error: 'Answer is required',
      })
    }

    const puzzle = db
      .prepare(
        `
      SELECT * FROM puzzles
      WHERE id = ?
    `,
      )
      .get(id)

    if (!puzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
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

function createPuzzle(req, res) {
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

    const existingPuzzle = db
      .prepare(
        `
      SELECT * FROM puzzles WHERE id = ?
    `,
      )
      .get(id)

    if (existingPuzzle) {
      return res.status(409).json({
        error: 'Puzzle with this id already exists',
      })
    }

    const puzzle = {
      id,
      title,
      question,
      answer,
      points,
      difficulty,
      latitude,
      longitude,
    }

    db.prepare(
      `
      INSERT INTO puzzles (
        id, title, question, answer, points, difficulty, latitude, longitude
      )
      VALUES (
        @id, @title, @question, @answer, @points, @difficulty, @latitude, @longitude
      )
    `,
    ).run(puzzle)

    res.status(201).json(puzzle)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to create puzzle',
    })
  }
}

function updatePuzzle(req, res) {
  try {
    const { id } = req.params

    const existingPuzzle = db
      .prepare(
        `
      SELECT * FROM puzzles WHERE id = ?
    `,
      )
      .get(id)

    if (!existingPuzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    const updatedPuzzle = {
      id,
      title: req.body.title ?? existingPuzzle.title,
      question: req.body.question ?? existingPuzzle.question,
      answer: req.body.answer ?? existingPuzzle.answer,
      points: req.body.points ?? existingPuzzle.points,
      difficulty: req.body.difficulty ?? existingPuzzle.difficulty,
      latitude: req.body.latitude ?? existingPuzzle.latitude,
      longitude: req.body.longitude ?? existingPuzzle.longitude,
    }

    db.prepare(
      `
      UPDATE puzzles
      SET title = @title,
          question = @question,
          answer = @answer,
          points = @points,
          difficulty = @difficulty,
          latitude = @latitude,
          longitude = @longitude
      WHERE id = @id
    `,
    ).run(updatedPuzzle)

    res.json(updatedPuzzle)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to update puzzle',
    })
  }
}

function deletePuzzle(req, res) {
  try {
    const { id } = req.params

    const existingPuzzle = db
      .prepare(
        `
      SELECT * FROM puzzles WHERE id = ?
    `,
      )
      .get(id)

    if (!existingPuzzle) {
      return res.status(404).json({
        error: 'Puzzle not found',
      })
    }

    db.prepare(
      `
      DELETE FROM solved_puzzles
      WHERE puzzle_id = ?
    `,
    ).run(id)

    db.prepare(
      `
      DELETE FROM puzzles
      WHERE id = ?
    `,
    ).run(id)

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

module.exports = {
  getAllPuzzles,
  getPuzzleById,
  checkPuzzleAnswer,
  createPuzzle,
  updatePuzzle,
  deletePuzzle,
}
