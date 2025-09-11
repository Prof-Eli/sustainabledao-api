@'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

let sequelize, testConnection;
try {
  const db = require('./config/database');
  sequelize = db.sequelize;
  testConnection = db.testConnection;
} catch (error) {
  console.log('Database config not available:', error.message);
}

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

app.get('/api/v1/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/api/v1/test', (req, res) => {
  res.json({
    message: 'API is working!',
    database: testConnection ? 'available' : 'not configured'
  });
});

const startServer = async () => {
  try {
    if (testConnection) {
      const dbConnected = await testConnection();
      if (dbConnected && sequelize) {
        await sequelize.sync({ alter: true });
        console.log('Database synchronized');
      }
    } else {
      console.log('Starting without database connection');
    }

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
'@ | Out-File -FilePath "server.js" -Encoding UTF8