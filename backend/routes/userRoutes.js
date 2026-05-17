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
  addCurrentUserSolvedPuzzle,
  getCurrentUserSolvedPuzzles,
  updateCurrentUser,
} = require('../controllers/userController')

router.post('/', createUser)
router.get('/me', authenticateToken, getCurrentUser)
router.patch('/me', authenticateToken, updateCurrentUser)
router.get('/me/solved-puzzles', authenticateToken, getCurrentUserSolvedPuzzles)
router.post('/me/solved-puzzles', authenticateToken, addCurrentUserSolvedPuzzle)
router.get('/:id', getUserById)
router.patch('/:id', authenticateToken, updateUser)

router.post('/:id/solved-puzzles', authenticateToken, addSolvedPuzzle)

router.get('/:id/solved-puzzles', authenticateToken, getSolvedPuzzles)

module.exports = router
