const express = require('express')

const router = express.Router()

const authenticateToken = require('../middleware/authMiddleware')

const {
  createUser,
  getUserById,
  updateUser,
  addSolvedPuzzle,
  getSolvedPuzzles,
  getCurrentUser,
} = require('../controllers/userController')

router.post('/', createUser)
router.get('/me', authenticateToken, getCurrentUser)
router.get('/:id', getUserById)
router.patch('/:id', updateUser)
router.post('/:id/solved-puzzles', addSolvedPuzzle)
router.get('/:id/solved-puzzles', getSolvedPuzzles)

module.exports = router
