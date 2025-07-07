const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/authRoute");
const eventRoutes = require("./routes/eventRoute");
const ticketRoutes = require("./routes/ticketRoute");
const userRoutes = require("./routes/userRoute");
const errorHandler = require("./middleware/errorHandler");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/tickets", ticketRoutes);
app.use("/api/users", userRoutes);

// Global error handler
app.use(errorHandler);

const PORT = 2000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
