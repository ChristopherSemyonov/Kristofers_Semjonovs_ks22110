const express = require('express')

const router = express.Router()

const { register, login, seedAdmin } = require('../controllers/authController')

router.post('/register', register)
router.post('/login', login)
router.post('/seed-admin', seedAdmin)

module.exports = router
