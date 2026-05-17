const express = require('express')

const router = express.Router()

const authenticateToken = require('../middleware/authMiddleware')
const requireAdmin = require('../middleware/adminMiddleware')

const {
  getAllPuzzles,
  getPuzzleById,
  checkPuzzleAnswer,
  createPuzzle,
  updatePuzzle,
  deletePuzzle,
} = require('../controllers/puzzleController')

router.get('/', getAllPuzzles)
router.post('/', authenticateToken, requireAdmin, createPuzzle)
router.patch('/:id', authenticateToken, requireAdmin, updatePuzzle)
router.delete('/:id', authenticateToken, requireAdmin, deletePuzzle)
router.get('/:id', getPuzzleById)
router.post('/:id/check-answer', checkPuzzleAnswer)

module.exports = router
