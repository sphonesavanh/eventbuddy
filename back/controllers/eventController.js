const pool = require("../database/db");
const path = require("path");
const fs = require("fs");

// Multer setup for file uploads
const multer = require("multer");
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/"); // Folder where images will be stored
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

async function getAllEvents(req, res, next) {
  try {
    const result = await pool.query("SELECT * FROM events");
    const eventsWithFullImageUrl = result.rows.map((event) => {
      return {
        ...event,
        image: event.image
          ? `${req.protocol}://${req.get("host")}/${event.image}`
          : "", // Full URL if image exists
      };
    });
    res.json(eventsWithFullImageUrl);
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
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Event not found" });
    }
    const event = result.rows[0];
    event.image = event.image
      ? `${req.protocol}://${req.get("host")}/${event.image}`
      : "";
    res.json(event);
  } catch (err) {
    next(err);
  }
}

async function getEventsByUser(req, res, next) {
  try {
    const { email } = req.query;

    if (!email) {
      return res
        .status(400)
        .json({ error: "Email query parameter is required" });
    }

    const result = await pool.query(
      "SELECT * FROM events WHERE created_by = $1",
      [email]
    );

    const eventsWithFullImageUrl = result.rows.map((event) => {
      return {
        ...event,
        image: event.image
          ? `${req.protocol}://${req.get("host")}/${event.image}`
          : "",
      };
    });

    res.json(eventsWithFullImageUrl);
    console.log("Events fetched for user:", email);
  } catch (err) {
    console.error("Error in getEventsByUser:", err);
    res.status(500).json({ error: "Internal server error" });
  }
}

async function createEvent(req, res, next) {
  try {
    const { title, description, date, time, location, created_by } = req.body;

    // Normalize path for URL
    const imagePath = req.file ? req.file.path.replace(/\\/g, "/") : null;

    const result = await pool.query(
      `INSERT INTO events 
         (title, description, date, time, location, created_by, image)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [title, description, date, time, location, created_by, imagePath]
    );

    const event = result.rows[0];
    event.image = event.image
      ? `${req.protocol}://${req.get("host")}/${event.image}`
      : "";

    res.status(201).json(event);
  } catch (err) {
    next(err);
  }
}


async function updateEvent(req, res, next) {
  try {
    const { id } = req.params;
    const { title, description, date, time, location } = req.body;

    let imagePath;
    if (req.file) {
      // New image uploaded, replace the old one
      const oldEvent = await pool.query(
        "SELECT image FROM events WHERE event_id = $1",
        [id]
      );
      if (oldEvent.rows[0]?.image) {
        fs.unlinkSync(oldEvent.rows[0].image); // Delete old image file
      }
      imagePath = req.file.path;
    } else {
      imagePath = req.body.image; // Keep existing image if not updated
    }

    const result = await pool.query(
      `UPDATE events
       SET title = $1, description = $2, date = $3, time = $4, location = $5, image = $6
       WHERE event_id = $7
       RETURNING *`,
      [title, description, date, time, location, imagePath, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Event not found" });
    }

    const updatedEvent = result.rows[0];
    updatedEvent.image = updatedEvent.image
      ? `${req.protocol}://${req.get("host")}/${updatedEvent.image}`
      : "";

    res.json(updatedEvent);
  } catch (err) {
    console.error("Error in updateEvent:", err);
    res.status(500).json({ error: "Internal server error" });
  }
}

async function deleteEvent(req, res, next) {
  try {
    const { id } = req.params;

    // Delete the event and its image file
    const result = await pool.query(
      "DELETE FROM events WHERE event_id = $1 RETURNING *",
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Event not found" });
    }

    if (result.rows[0].image) {
      fs.unlinkSync(result.rows[0].image); // Delete the image file
    }

    res.json({ message: "Event deleted successfully" });
  } catch (err) {
    console.error("Error in deleteEvent:", err);
    res.status(500).json({ error: "Internal server error" });
  }
}

module.exports = {
  getAllEvents,
  getEventById,
  createEvent,
  updateEvent,
  deleteEvent,
  getEventsByUser,
  upload, 
};
