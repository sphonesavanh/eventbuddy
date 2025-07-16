const express = require("express");
const router = express.Router();
const {
  getProfile,
  updateProfile,
  upload,
  uploadProfilePicture,
} = require("../controllers/userController");

router.get("/profile/:email", getProfile);
router.put("/profile/:email", updateProfile);
router.post(
  "/profile/:email/picture",
  upload.single("profilePicture"),
  uploadProfilePicture
);


module.exports = router;
