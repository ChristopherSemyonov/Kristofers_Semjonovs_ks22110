const express = require('express')

const router = express.Router()

const {
  register,
  login,
  seedAdmin,
  resetUsers,
} = require('../controllers/authController')

router.post('/register', register)
router.post('/login', login)
router.post('/seed-admin', seedAdmin)
router.post('/reset-users', resetUsers)

module.exports = router
