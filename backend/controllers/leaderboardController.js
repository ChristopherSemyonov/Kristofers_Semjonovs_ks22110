const db = require('../database/db')

async function getLeaderboard(req, res) {
  try {
    const result = await db.query(
      `
      SELECT
        id,
        name,
        profile_image_url,
        total_score,
        total_distance_km,
        created_at
      FROM users
      ORDER BY total_score DESC, total_distance_km DESC
      LIMIT 20
      `,
    )

    res.json(result.rows)
  } catch (error) {
    console.error(error)

    res.status(500).json({
      error: 'Failed to fetch leaderboard',
    })
  }
}

module.exports = {
  getLeaderboard,
}
