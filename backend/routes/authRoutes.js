const express = require('express')

const router = express.Router()

const authenticateToken = require('../middleware/authMiddleware')

const {
  register,
  login,
  seedAdmin,
  resetUsers,
  requestPasswordChange,
  confirmPasswordChange,
} = require('../controllers/authController')

router.post('/register', register)
router.post('/login', login)
router.post('/seed-admin', seedAdmin)
router.post('/reset-users', resetUsers)

router.post(
  '/request-password-change',
  authenticateToken,
  requestPasswordChange,
)

router.post(
  '/confirm-password-change',
  authenticateToken,
  confirmPasswordChange,
)

module.exports = router
