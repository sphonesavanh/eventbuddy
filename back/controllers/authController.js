const pool = require("../database/db");

exports.register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    const result = await pool.query(
      "INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING *",
      [name, email, password] // plain-text password
    );

    res.status(201).json({ user: result.rows[0] });
    console.log("User registered:", {
      user_id: result.rows[0].user_id,
      name: result.rows[0].name,
      email: result.rows[0].email,
    });
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const result = await pool.query("SELECT * FROM users WHERE email = $1", [
      email,
    ]);
    const user = result.rows[0];

    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    if (password !== user.password) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // Instead of JWT, return user details
    res.json({
      user_id: user.user_id,
      name: user.name,
      email: user.email,
    });
    console.log("User logged in:", {
      user_id: user.user_id,
      name: user.name,
      email: user.email,
    });
  } catch (err) {
    console.error("Login error:", err);
    next(err);
  }
};
