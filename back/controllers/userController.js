const pool = require("../database/db");

exports.getProfile = async (req, res, next) => {
  try {
    const { email } = req.params;
    const result = await pool.query(
      "SELECT name, email, created_at FROM users WHERE email = $1",
      [email]
    );
    res.json(result.rows[0]);
    console.log("User profile fetched:", result.rows[0]);
  } catch (err) {
    next(err);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const { email } = req.params; // find by email
    const { newEmail } = req.body;

    const result = await pool.query(
      "UPDATE users SET email = $1 WHERE email = $2 RETURNING *",
      [newEmail, email]
    );

    res.json(result.rows[0]);
    console.log("User profile updated:", {
      user_id: result.rows[0].user_id,
      name: result.rows[0].name,
      email: result.rows[0].email,
    });
  } catch (err) {
    next(err);
  }
};
