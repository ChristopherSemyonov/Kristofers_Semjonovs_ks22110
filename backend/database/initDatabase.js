const db = require('./db')

function initDatabase() {
  db.prepare(
    `
    CREATE TABLE IF NOT EXISTS puzzles (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      question TEXT NOT NULL,
      answer TEXT NOT NULL,
      points INTEGER NOT NULL,
      difficulty TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL
    )
  `,
  ).run()

  db.prepare(
    `
  CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    total_score INTEGER NOT NULL DEFAULT 0,
    total_distance_km REAL NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
`,
  ).run()

  db.prepare(
    `
  CREATE TABLE IF NOT EXISTS solved_puzzles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    puzzle_id TEXT NOT NULL,
    solved_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, puzzle_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (puzzle_id) REFERENCES puzzles(id)
  )
`,
  ).run()

  const existingPuzzles = db
    .prepare(
      `
    SELECT COUNT(*) AS count FROM puzzles
  `,
    )
    .get()

  if (existingPuzzles.count === 0) {
    const insertPuzzle = db.prepare(`
      INSERT INTO puzzles (
        id, title, question, answer, points, difficulty, latitude, longitude
      ) VALUES (
        @id, @title, @question, @answer, @points, @difficulty, @latitude, @longitude
      )
    `)

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
      },
    ]

    const insertMany = db.transaction((puzzleList) => {
      for (const puzzle of puzzleList) {
        insertPuzzle.run(puzzle)
      }
    })

    insertMany(puzzles)

    console.log('Demo puzzles inserted')
  }

  console.log('Database initialized')
}

module.exports = initDatabase
