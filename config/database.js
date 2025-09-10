const { Sequelize } = require("sequelize");
require("dotenv").config();

// Database connection with retry logic
const sequelize = new Sequelize({
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || "sustainability_api",
  username: process.env.DB_USER || "apidev",
  password: process.env.DB_PASS || "DevPassword123!",
  dialect: "postgres",
  logging: process.env.NODE_ENV === "development" ? console.log : false,
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
  retry: {
    max: 3,
    timeout: 5000,
  },
});

// Test connection with proper error handling
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ Database connection established successfully.");
    return true;
  } catch (error) {
    console.error("❌ Unable to connect to database:", error.message);
    console.log("Troubleshooting steps:");
    console.log(
      "1. Check PostgreSQL service is running: Get-Service postgresql*"
    );
    console.log("2. Verify credentials in .env file");
    console.log('3. Ensure database exists: psql -U postgres -c "\\l"');
    return false;
  }
};

module.exports = { sequelize, testConnection };
