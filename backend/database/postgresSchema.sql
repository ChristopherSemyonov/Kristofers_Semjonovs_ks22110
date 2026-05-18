CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  password_hash TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  profile_image_url TEXT,
  total_score INTEGER NOT NULL DEFAULT 0,
  total_distance_km DOUBLE PRECISION NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS puzzles (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  points INTEGER NOT NULL,
  difficulty TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS solved_puzzles (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  puzzle_id TEXT NOT NULL,
  solved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, puzzle_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (puzzle_id) REFERENCES puzzles(id)
);