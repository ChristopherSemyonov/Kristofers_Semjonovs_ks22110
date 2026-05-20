const express = require('express')

const router = express.Router()

const authenticateToken = require('../middleware/authMiddleware')
const requireAdmin = require('../middleware/adminMiddleware')
const upload = require('../middleware/uploadMiddleware')

const {
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
  uploadPuzzleImage,
  getPuzzleImage,
} = require('../controllers/puzzleController')

router.get('/', getAllPuzzles)
router.post('/', authenticateToken, requireAdmin, createPuzzle)
router.patch('/:id', authenticateToken, requireAdmin, updatePuzzle)
router.patch('/:id/hide', authenticateToken, requireAdmin, hidePuzzle)
router.patch('/:id/unhide', authenticateToken, requireAdmin, unhidePuzzle)
router.delete('/:id', authenticateToken, requireAdmin, deletePuzzle)
router.get('/admin/all', authenticateToken, requireAdmin, getAllPuzzlesForAdmin)
router.post('/:id/solve', authenticateToken, solvePuzzle)

router.post(
  '/:id/image',
  authenticateToken,
  upload.single('puzzleImage'),
  uploadPuzzleImage,
)

router.get('/:id/image', getPuzzleImage)
router.get('/:id', getPuzzleById)
router.post('/:id/check-answer', checkPuzzleAnswer)

module.exports = router
