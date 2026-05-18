require('dotenv').config()

const pool = require('./postgresDb')

const puzzles = [
  {
    id: 'puzzle_1',
    title: 'Vecrīgas sirds',
    question:
      'Kā sauc Rīgas vēsturisko centru, kas ir iekļauts UNESCO pasaules mantojuma sarakstā?',
    answer: 'vecrīga',
    points: 250,
    difficulty: 'HARD',
    latitude: 56.9496,
    longitude: 24.1052,
    is_active: 1,
  },
  {
    id: 'puzzle_2',
    title: 'Doma laukums',
    question: 'Kā sauc vienu no lielākajiem laukumiem Vecrīgā?',
    answer: 'doma laukums',
    points: 120,
    difficulty: 'MEDIUM',
    latitude: 56.9491,
    longitude: 24.104,
    is_active: 1,
  },
  {
    id: 'puzzle_3',
    title: 'Daugavas tuvumā',
    question: 'Pie kuras upes atrodas Rīga?',
    answer: 'daugava',
    points: 150,
    difficulty: 'EASY',
    latitude: 56.9478,
    longitude: 24.1016,
    is_active: 1,
  },
]

async function seedPuzzles() {
  try {
    for (const puzzle of puzzles) {
      await pool.query(
        `
        INSERT INTO puzzles (
          id, title, question, answer, points, difficulty,
          latitude, longitude, is_active
        )
        VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9
        )
        ON CONFLICT (id) DO NOTHING
        `,
        [
          puzzle.id,
          puzzle.title,
          puzzle.question,
          puzzle.answer,
          puzzle.points,
          puzzle.difficulty,
          puzzle.latitude,
          puzzle.longitude,
          puzzle.is_active,
        ],
      )
    }

    console.log('PostgreSQL puzzles seeded successfully')
  } catch (error) {
    console.error('Failed to seed PostgreSQL puzzles')
    console.error(error)
  } finally {
    await pool.end()
  }
}

seedPuzzles()
