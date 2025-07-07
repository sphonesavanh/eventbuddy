// back/controllers/eventController.js
const pool = require("../database/db");

async function getAllEvents(req, res, next) {
  try {
    const result = await pool.query("SELECT * FROM events");
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
}

async function getEventById(req, res, next) {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "SELECT * FROM events WHERE event_id = $1",
      [id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
}

async function createEvent(req, res, next) {
  try {
    const { title, description, date, time, location, image_url, created_by } =
      req.body;

    const result = await pool.query(
      `INSERT INTO events 
         (title, description, date, time, location, created_by)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [title, description, date, time, location, created_by]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getAllEvents,
  getEventById,
  createEvent,
};
