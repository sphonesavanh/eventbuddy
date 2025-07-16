const pool = require("../database/db");
const multer = require("multer");
const path = require("path");

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, "../uploads")); // Save in /uploads
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

exports.upload = multer({ storage: storage });

exports.uploadProfilePicture = async (req, res, next) => {
  try {
    const { email } = req.params; // get user email from URL
    const profilePicturePath = req.file.filename; // no "profile/" prefix

    const result = await pool.query(
      "UPDATE users SET profile_picture = $1 WHERE email = $2 RETURNING *",
      [profilePicturePath, email]
    );

    res.json({
      success: true,
      message: "Profile picture updated",
      user: result.rows[0],
    });
    console.log("Profile picture updated:", result.rows[0]);
  } catch (err) {
    next(err);
  }
};

exports.getProfile = async (req, res, next) => {
  try {
    const { email } = req.params;
    const result = await pool.query(
      "SELECT name, email, created_at, profile_picture FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }
    
    res.json(result.rows[0]);
    console.log("User profile fetched:", result.rows[0]);
  } catch (err) {
    next(err);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const { email } = req.params; // current email
    const { newName, newEmail, newPassword, profilePicture } = req.body;

    let query = `
      UPDATE users 
      SET name = $1, email = $2
      WHERE email = $3
      RETURNING *`;
    let params = [newName, newEmail, email];

    // If password is provided, update it too
    if (newPassword && newPassword.trim() !== "") {
      query = `
        UPDATE users 
        SET name = $1, email = $2, password = $3
        WHERE email = $4
        RETURNING *`;
      params = [newName, newEmail, newPassword, email];
    }

    // If profile picture is provided, update it too
    if (profilePicture) {
      query = `
        UPDATE users 
        SET name = $1, email = $2, profile_picture = $3
        WHERE email = $4
        RETURNING *`;
      params = [newName, newEmail, profilePicture, email];
    }

    const result = await pool.query(query, params);

    res.json(result.rows[0]);
    console.log("User profile updated:", result.rows[0]);
  } catch (err) {
    next(err);
  }
};
