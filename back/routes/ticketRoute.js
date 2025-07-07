const express = require("express");
const router = express.Router();
const {
  bookTicket,
  getUserTickets,
} = require("../controllers/ticketController");

router.post("/book", bookTicket);
router.get("/my", getUserTickets);

module.exports = router;
