const express = require('express')
const cors = require('cors')
const initDatabase = require('./database/initDatabase')

const userRoutes = require('./routes/userRoutes')
const puzzleRoutes = require('./routes/puzzleRoutes')
const leaderboardRoutes = require('./routes/leaderboardRoutes')
const authRoutes = require('./routes/authRoutes')

const app = express()
const PORT = 3000

app.use(cors())
app.use(express.json())
app.use('/uploads', express.static('uploads'))
app.use('/puzzles', puzzleRoutes)
app.use('/users', userRoutes)
app.use('/leaderboard', leaderboardRoutes)
app.use('/auth', authRoutes)

app.get('/', (req, res) => {
  res.json({
    message: 'Urban Quest backend is running',
  })
})

initDatabase()

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`)
})
