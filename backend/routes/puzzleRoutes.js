const express = require('express')

const router = express.Router()

const {
  getAllPuzzles,
  getPuzzleById,
  checkPuzzleAnswer,
} = require('../controllers/puzzleController')

router.get('/', getAllPuzzles)
router.get('/:id', getPuzzleById)
router.post('/:id/check-answer', checkPuzzleAnswer)

module.exports = router
