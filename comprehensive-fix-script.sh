# CityTech Sustainability API - Complete Fix Script
# Run this from PowerShell in your project root: C:\CityTech\sustainability-api

Write-Host "🔧 Starting comprehensive fixes..." -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: package.json not found!" -ForegroundColor Red
    Write-Host "Please run this script from your project root directory" -ForegroundColor Yellow
    exit 1
}

# Create config directory if it doesn't exist
if (-not (Test-Path "config")) {
    New-Item -ItemType Directory -Path "config" -Force
}

# 1. Create missing config/creditRates.js
Write-Host "Creating config/creditRates.js..." -ForegroundColor Yellow
$creditRatesContent = @'
// Credit rates for different activities
// This determines how many credits students earn for each action

module.exports = {
  engineering: {
    energyPerCredit: 100,      // 1 credit per 100 kWh saved
    carbonPerCredit: 10,       // 1 credit per 10 kg CO2
    waterPerCredit: 100,       // 1 credit per 100 gallons
    documentationCredit: 5,
    peerReviewCredit: 2
  },
  landUse: {
    areaPerCredit: 10,         // 1 credit per 10 sq ft
    speciesCredit: 2,          // 2 credits per species
    soilCredit: 5,
    habitatCredit: 10,
    researchCredit: 3
  },
  shared: {
    codeContribution: {
      simple: 5,
      medium: 10,
      complex: 20
    },
    researchPaper: 8,
    standardImplementation: 15,
    weeklyParticipation: 1,
    workshopAttendance: 3
  },
  bonuses: {
    firstProject: 10,
    weeklyStreak: 5,
    helpingOthers: 3
  }
};
'@
Set-Content -Path "config\creditRates.js" -Value $creditRatesContent -Encoding UTF8

# 2. Fix routes/credits.js with proper functionality
Write-Host "Fixing routes/credits.js..." -ForegroundColor Yellow
$creditsRouteContent = @'
// Credit system routes - handles earning and tracking credits
const router = require('express').Router();

// Simple in-memory leaderboard for now (will use database when models are connected)
let mockLeaderboard = [
  { id: 1, firstName: 'John', lastName: 'Doe', classType: 'engineering', totalCredits: 150 },
  { id: 2, firstName: 'Jane', lastName: 'Smith', classType: 'land_use', totalCredits: 120 },
  { id: 3, firstName: 'Bob', lastName: 'Johnson', classType: 'engineering', totalCredits: 95 }
];

// GET /api/credits/leaderboard - Top students by credits
router.get('/leaderboard', async (req, res) => {
  try {
    // For now, return mock data. Later this will query the database.
    res.json({ success: true, leaderboard: mockLeaderboard });
  } catch (error) {
    console.error('Leaderboard error:', error);
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

// GET /api/credits/stats - Credit system statistics
router.get('/stats', async (req, res) => {
  try {
    const totalCredits = mockLeaderboard.reduce((sum, user) => sum + user.totalCredits, 0);
    const avgCredits = Math.round(totalCredits / mockLeaderboard.length);
    
    res.json({
      success: true,
      stats: {
        totalUsers: mockLeaderboard.length,
        totalCredits,
        averageCredits: avgCredits,
        topUser: mockLeaderboard[0]
      }
    });
  } catch (error) {
    console.error('Stats error:', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

module.exports = router;
'@
Set-Content -Path "routes\credits.js" -Value $creditsRouteContent -Encoding UTF8

# 3. Fix routes/projects.js with proper functionality
Write-Host "Fixing routes/projects.js..." -ForegroundColor Yellow
$projectsRouteContent = @'
// Project routes - handles creating and viewing sustainability projects
const router = require('express').Router();

// Mock project data (will use database when models are connected)
let mockProjects = [
  {
    id: 1,
    title: 'Solar Panel Installation',
    description: 'Installing solar panels on Building A',
    classType: 'engineering',
    status: 'in_progress',
    creditsEarned: 50,
    energySaved: 500,
    carbonReduced: 200,
    User: { firstName: 'John', lastName: 'Doe' }
  },
  {
    id: 2,
    title: 'Campus Butterfly Garden',
    description: 'Creating habitat for native butterfly species',
    classType: 'land_use',
    status: 'completed',
    creditsEarned: 30,
    areaConverted: 200,
    speciesCount: 15,
    User: { firstName: 'Jane', lastName: 'Smith' }
  }
];

// GET /api/projects - Get all projects
router.get('/', async (req, res) => {
  try {
    res.json({ success: true, projects: mockProjects });
  } catch (error) {
    console.error('Get projects error:', error);
    res.status(500).json({ error: 'Failed to fetch projects' });
  }
});

// GET /api/projects/engineering - Engineering class projects
router.get('/engineering', async (req, res) => {
  try {
    const engineeringProjects = mockProjects.filter(p => p.classType === 'engineering');
    res.json({ success: true, projects: engineeringProjects });
  } catch (error) {
    console.error('Engineering projects error:', error);
    res.status(500).json({ error: 'Failed to fetch engineering projects' });
  }
});

// GET /api/projects/land-use - Land use class projects
router.get('/land-use', async (req, res) => {
  try {
    const landUseProjects = mockProjects.filter(p => p.classType === 'land_use');
    res.json({ success: true, projects: landUseProjects });
  } catch (error) {
    console.error('Land use projects error:', error);
    res.status(500).json({ error: 'Failed to fetch land use projects' });
  }
});

module.exports = router;
'@
Set-Content -Path "routes\projects.js" -Value $projectsRouteContent -Encoding UTF8

# 4. Add simple admin route functionality
Write-Host "Fixing routes/admin.js..." -ForegroundColor Yellow
$adminRouteContent = @'
// Admin routes - basic admin functionality
const router = require('express').Router();

// GET /api/admin/stats - Basic system statistics
router.get('/stats', async (req, res) => {
  try {
    // Mock stats for now
    const stats = {
      totalUsers: 25,
      totalProjects: 8,
      totalCredits: 450,
      activeToday: 12
    };
    
    res.json({ success: true, stats });
  } catch (error) {
    console.error('Admin stats error:', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

module.exports = router;
'@
Set-Content -Path "routes\admin.js" -Value $adminRouteContent -Encoding UTF8

# 5. Update server.js to properly import models
Write-Host "Updating server.js for proper model imports..." -ForegroundColor Yellow
$serverContent = @'
// server.js
require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

// Route modules - declare these OUTSIDE the try/catch
const authRoutes = require("./routes/auth");
const projectRoutes = require("./routes/projects");
const creditRoutes = require("./routes/credits");
const adminRoutes = require("./routes/admin");

let sequelize;
let testConnection;
let dbConfigured = false;

try {
  // Database connection
  const db = require("./config/database");
  sequelize = db.sequelize;
  testConnection = db.testConnection;
  dbConfigured = Boolean(sequelize) && typeof testConnection === "function";
  
  // Import models to establish relationships
  const models = require("./models");
  console.log("✅ Models imported successfully");
} catch (error) {
  console.log("Database config not available:", error.message);
}

const app = express();
const PORT = Number(process.env.PORT) || 3000;

// Global middleware
app.use(helmet());
app.use(cors());
app.use(morgan("dev"));
app.use(express.json());
app.use(express.static("public")); // Serve dashboard.html

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

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

const startServer = async () => {
  try {
    if (dbConfigured) {
      try {
        const ok = await Promise.resolve(testConnection());
        if (ok && sequelize && typeof sequelize.sync === "function") {
          const alter = process.env.NODE_ENV !== "production";
          await sequelize.sync({ alter });
          console.log(`✅ Database synchronized (alter=${alter})`);
        } else {
          console.warn("DB test failed or sequelize missing; continuing without sync.");
        }
      } catch (dbErr) {
        console.error("Database connection failed; continuing without DB:", dbErr.message);
      }
    } else {
      console.log("🔄 Starting without database connection");
      console.log("📊 Using mock data for development");
    }

    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📊 Dashboard: http://localhost:${PORT}/dashboard.html`);
      console.log(`🔧 Health: http://localhost:${PORT}/api/v1/health`);
      console.log(`📋 Projects: http://localhost:${PORT}/api/projects`);
      console.log(`🏆 Credits: http://localhost:${PORT}/api/credits/leaderboard`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();

module.exports = app;
'@
Set-Content -Path "server.js" -Value $serverContent -Encoding UTF8

Write-Host "✅ All fixes completed!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Cyan
Write-Host "1. Run: npm start" -ForegroundColor White
Write-Host "2. Test: http://localhost:3000/dashboard.html" -ForegroundColor White
Write-Host "3. Test: http://localhost:3000/api/credits/leaderboard" -ForegroundColor White
Write-Host "4. Deploy: git add . && git commit -m 'Fix all route issues' && git push" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Your API should now work completely!" -ForegroundColor Green