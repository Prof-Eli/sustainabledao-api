const { Sequelize } = require("sequelize");
require("dotenv").config();

// Use DATABASE_URL from Render, fallback to local settings
const sequelize = process.env.DATABASE_URL
  ? new Sequelize(process.env.DATABASE_URL, {
      dialectOptions: {
        ssl: {
          require: true,
          rejectUnauthorized: false,
        },
      },
    })
  : new Sequelize({
      dialect: "postgres",
      host: process.env.DB_HOST || "localhost",
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || "sustainability_api",
      username: process.env.DB_USER || "postgres",
      password: process.env.DB_PASS || "password",
    });

// Test connection function
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ Database connection successful");
    return true;
  } catch (error) {
    console.log("⚠️ Database connection failed:", error.message);
    return false;
  }
};

// Export both sequelize and testConnection
module.exports = { sequelize, testConnection };
