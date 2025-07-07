const express = require("express");
const router = express.Router();
const {
  getAllEvents,
  getEventById,
  createEvent,
} = require("../controllers/eventController");

router.get("/", getAllEvents);
router.get("/:id", getEventById);
router.post("/", createEvent);

module.exports = router;
