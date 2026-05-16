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

module.exports = {
  getAllPuzzles,
  getPuzzleById,
  checkPuzzleAnswer,
}
