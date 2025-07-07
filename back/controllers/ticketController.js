const pool = require("../database/db");

exports.bookTicket = async (req, res, next) => {
  try {
    const userId = req.user.user_id;
    const { event_id } = req.body;

    const result = await pool.query(
      "INSERT INTO tickets (user_id, event_id) VALUES ($1, $2) RETURNING *",
      [userId, event_id]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    next(err);
  }
};

exports.getUserTickets = async (req, res, next) => {
  try {
    const userId = req.user.user_id;

    const result = await pool.query(
      `SELECT t.ticket_id, e.title, e.date, e.location, t.status
       FROM tickets t
       JOIN events e ON t.event_id = e.event_id
       WHERE t.user_id = $1`,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    next(err);
  }
};
