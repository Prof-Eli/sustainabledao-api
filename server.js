// server.js
require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

// Route modules (assumes these files exist and export an Express router)
const authRoutes = require("./routes/auth");
const projectRoutes = require("./routes/projects");
const creditRoutes = require("./routes/credits");
const adminRoutes = require("./routes/admin");

let sequelize;
let testConnection;
let dbConfigured = false;

try {
  // Assumes ./config/database exports: { sequelize, testConnection }
  const db = require("./config/database");
  sequelize = db.sequelize;
  testConnection = db.testConnection;
  dbConfigured = Boolean(sequelize) && typeof testConnection === "function";
} catch (error) {
  console.log("Database config not available:", error.message);
}

const app = express();
const PORT = Number(process.env.PORT) || 3000;

// Global middleware
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        scriptSrc: ["'self'", "'unsafe-inline'"],
      },
    },
  })
);
app.use(cors());
app.use(morgan("dev"));
app.use(express.json());
app.use(express.static("public"));

// Health check
app.get("/", (req, res) => {
  res.send("CityTech Sustainability API is running! Visit /dashboard.html");
});

app.get("/api/v1/health", (req, res) => {
  res.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || "development",
  });
});

// API test + DB status
app.get("/api/v1/test", async (req, res) => {
  let dbStatus = "not configured";
  if (typeof testConnection === "function") {
    try {
      const ok = await Promise.resolve(testConnection());
      dbStatus = ok ? "available" : "unavailable";
    } catch {
      dbStatus = "unavailable";
    }
  }
  res.json({ message: "API is working!", database: dbStatus });
});

// Mount routes
app.use("/api/auth", authRoutes);
app.use("/api/projects", projectRoutes);
app.use("/api/credits", creditRoutes);
app.use("/api/admin", adminRoutes);

const startServer = async () => {
  try {
    if (dbConfigured) {
      try {
        const ok = await Promise.resolve(testConnection());
        if (ok && sequelize && typeof sequelize.sync === "function") {
          const alter = process.env.NODE_ENV !== "production";
          await sequelize.sync({ alter });
          console.log(`Database synchronized (alter=${alter})`);
        } else {
          console.warn(
            "DB test failed or sequelize missing; continuing without sync."
          );
        }
      } catch (dbErr) {
        console.error(
          "Database connection failed; continuing without DB:",
          dbErr.message
        );
      }
    } else {
      console.log("Starting without database connection");
    }

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();

// Export app for testing
module.exports = app;
