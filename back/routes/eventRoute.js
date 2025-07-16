const express = require("express");
const router = express.Router();
const {
  getAllEvents,
  getEventById,
  createEvent,
  updateEvent,
  deleteEvent,
  getEventsByUser,
  upload, // 👈 import multer upload middleware
} = require("../controllers/eventController");

// Get all events
router.get("/", getAllEvents);

// Get events by user
router.get("/byUser", getEventsByUser);

// Get event by ID
router.get("/:id", getEventById);

// Create event (with optional image upload)
router.post(
  "/",
  upload.single("image"), 
  createEvent
);

// Update event (with optional image upload)
router.put(
  "/:id",
  upload.single("image"), 
  updateEvent
);

// Delete event
router.delete("/:id", deleteEvent);

module.exports = router;
