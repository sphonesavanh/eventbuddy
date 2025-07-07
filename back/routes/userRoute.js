const express = require("express");
const router = express.Router();
const { getProfile, updateProfile } = require("../controllers/userController");

router.get("/profile/:email", getProfile);
router.put("/profile/:email", updateProfile);

module.exports = router;
