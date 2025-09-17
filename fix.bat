#!/bin/bash
# Critical Fixes for CityTech Sustainability API
# Run this from your project root: C:\CityTech\sustainability-api

echo "🔧 Starting automated fixes..."

# 1. Create missing credit configuration
echo "Creating config/creditRates.js..."
cat > config/creditRates.js << 'EOF'
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
EOF

# 2. Fix empty credits.js route
echo "Fixing routes/credits.js..."
cat > routes/credits.js << 'EOF'
// Credit system routes - handles earning and tracking credits
const router = require('express').Router();
const { CreditTransaction, User } = require('../models');
const creditService = require('../services/creditService');
const authMiddleware = require('../middleware/auth');

// GET /api/credits/leaderboard - Top students by credits
router.get('/leaderboard', async (req, res) => {
  try {
    const { classType, timeframe } = req.query;
    const leaderboard = await creditService.getLeaderboard(classType, 10);
    res.json({ success: true, leaderboard });
  } catch (error) {
    console.error('Leaderboard error:', error);
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

// GET /api/credits/my-stats - Current user's credit statistics
router.get('/my-stats', authMiddleware, async (req, res) => {
  try {
    const stats = await creditService.getUserStats(req.user.id);
    res.json({ success: true, stats });
  } catch (error) {
    console.error('Stats error:', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

// POST /api/credits/award - Award credits to current user
router.post('/award', authMiddleware, async (req, res) => {
  try {
    const { activityType, details } = req.body;
    
    if (!activityType) {
      return res.status(400).json({ error: 'Activity type required' });
    }
    
    const result = await creditService.awardCredits(
      req.user.id,
      activityType,
      details || {}
    );
    
    res.json(result);
  } catch (error) {
    console.error('Award credits error:', error);
    res.status(500).json({ error: 'Failed to award credits' });
  }
});

// GET /api/credits/history - User's credit transaction history
router.get('/history', authMiddleware, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    
    const transactions = await CreditTransaction.findAndCountAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset),
      include: [{
        model: require('../models').ClassProject,
        attributes: ['title'],
        required: false
      }]
    });
    
    res.json({
      success: true,
      transactions: transactions.rows,
      total: transactions.count,
      page: parseInt(page),
      totalPages: Math.ceil(transactions.count / limit)
    });
  } catch (error) {
    console.error('History error:', error);
    res.status(500).json({ error: 'Failed to fetch history' });
  }
});

module.exports = router;
EOF

# 3. Fix empty projects.js route  
echo "Fixing routes/projects.js..."
cat > routes/projects.js << 'EOF'
// Project routes - handles creating and viewing sustainability projects
const router = require('express').Router();
const { ClassProject, User, CreditTransaction } = require('../models');
const authMiddleware = require('../middleware/auth');
const creditService = require('../services/creditService');

// GET /api/projects - Get all projects (with optional filters)
router.get('/', async (req, res) => {
  try {
    const { classType, status, limit = 50 } = req.query;
    
    const where = {};
    if (classType) where.classType = classType;
    if (status) where.status = status;
    
    const projects = await ClassProject.findAll({
      where,
      include: [{
        model: User,
        attributes: ['firstName', 'lastName', 'classType']
      }],
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit)
    });
    
    res.json({ success: true, projects });
  } catch (error) {
    console.error('Get projects error:', error);
    res.status(500).json({ error: 'Failed to fetch projects' });
  }
});

// GET /api/projects/engineering - Engineering class projects
router.get('/engineering', async (req, res) => {
  try {
    const projects = await ClassProject.findAll({
      where: { classType: 'engineering' },
      include: [{
        model: User,
        attributes: ['firstName', 'lastName']
      }],
      order: [['createdAt', 'DESC']],
      limit: 20
    });
    
    res.json({ success: true, projects });
  } catch (error) {
    console.error('Engineering projects error:', error);
    res.status(500).json({ error: 'Failed to fetch engineering projects' });
  }
});

// GET /api/projects/land-use - Land use class projects
router.get('/land-use', async (req, res) => {
  try {
    const projects = await ClassProject.findAll({
      where: { classType: 'land_use' },
      include: [{
        model: User,
        attributes: ['firstName', 'lastName']
      }],
      order: [['createdAt', 'DESC']],
      limit: 20
    });
    
    res.json({ success: true, projects });
  } catch (error) {
    console.error('Land use projects error:', error);
    res.status(500).json({ error: 'Failed to fetch land use projects' });
  }
});

// POST /api/projects - Create new project (requires authentication)
router.post('/', authMiddleware, async (req, res) => {
  try {
    const {
      classType,
      title,
      description,
      // Engineering metrics
      energySaved,
      carbonReduced,
      waterSaved,
      // Land use metrics
      areaConverted,
      speciesCount,
      soilQuality
    } = req.body;
    
    // Validate required fields
    if (!classType || !title) {
      return res.status(400).json({ error: 'Class type and title are required' });
    }
    
    // Create project
    const project = await ClassProject.create({
      classType,
      title,
      description,
      energySaved: energySaved || null,
      carbonReduced: carbonReduced || null,
      waterSaved: waterSaved || null,
      areaConverted: areaConverted || null,
      speciesCount: speciesCount || null,
      soilQuality: soilQuality || null,
      createdBy: req.user.id,
      status: 'proposed'
    });
    
    // Award credits for project creation
    let totalCredits = 0;
    
    if (classType === 'engineering') {
      if (energySaved) {
        const result = await creditService.awardCredits(
          req.user.id, 
          'energy_saved', 
          { value: energySaved, projectId: project.id }
        );
        totalCredits += result.creditsAwarded || 0;
      }
      if (carbonReduced) {
        const result = await creditService.awardCredits(
          req.user.id,
          'carbon_reduced',
          { value: carbonReduced, projectId: project.id }
        );
        totalCredits += result.creditsAwarded || 0;
      }
    }
    
    if (classType === 'land_use') {
      if (areaConverted) {
        const result = await creditService.awardCredits(
          req.user.id,
          'area_converted',
          { value: areaConverted, projectId: project.id }
        );
        totalCredits += result.creditsAwarded || 0;
      }
      if (speciesCount) {
        for (let i = 0; i < speciesCount; i++) {
          const result = await creditService.awardCredits(
            req.user.id,
            'species_documented',
            { speciesName: `Species ${i + 1}`, projectId: project.id }
          );
          totalCredits += result.creditsAwarded || 0;
        }
      }
    }
    
    // Update project with credits earned
    await project.update({ creditsEarned: totalCredits });
    
    res.status(201).json({
      success: true,
      project,
      creditsAwarded: totalCredits,
      message: `Project created! Earned ${totalCredits} credits.`
    });
    
  } catch (error) {
    console.error('Create project error:', error);
    res.status(500).json({ error: 'Failed to create project' });
  }
});

// GET /api/projects/:id - Get specific project
router.get('/:id', async (req, res) => {
  try {
    const project = await ClassProject.findByPk(req.params.id, {
      include: [{
        model: User,
        attributes: ['firstName', 'lastName', 'classType']
      }]
    });
    
    if (!project) {
      return res.status(404).json({ error: 'Project not found' });
    }
    
    res.json({ success: true, project });
  } catch (error) {
    console.error('Get project error:', error);
    res.status(500).json({ error: 'Failed to fetch project' });
  }
});

module.exports = router;
EOF

# 4. Fix empty admin.js route
echo "Fixing routes/admin.js..."
cat > routes/admin.js << 'EOF'
// Admin routes - for instructors to manage the system
const router = require('express').Router();
const { User, ClassProject, CreditTransaction } = require('../models');
const { Op } = require('sequelize');
const authMiddleware = require('../middleware/auth');

// Middleware to check if user is admin/instructor
const adminOnly = (req, res, next) => {
  if (req.user.role !== 'admin' && req.user.role !== 'instructor') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

// GET /api/admin/stats - System statistics
router.get('/stats', authMiddleware, adminOnly, async (req, res) => {
  try {
    const stats = {
      users: {
        total: await User.count(),
        active: await User.count({
          where: {
            lastLogin: { [Op.gte]: new Date(Date.now() - 24*60*60*1000) }
          }
        }),
        byClass: {
          engineering: await User.count({ where: { classType: 'engineering' } }),
          landUse: await User.count({ where: { classType: 'land_use' } }),
          both: await User.count({ where: { classType: 'both' } })
        }
      },
      projects: {
        total: await ClassProject.count(),
        byStatus: {
          proposed: await ClassProject.count({ where: { status: 'proposed' } }),
          inProgress: await ClassProject.count({ where: { status: 'in_progress' } }),
          completed: await ClassProject.count({ where: { status: 'completed' } })
        }
      },
      credits: {
        totalAwarded: await CreditTransaction.sum('amount') || 0,
        thisWeek: await CreditTransaction.sum('amount', {
          where: {
            createdAt: { [Op.gte]: new Date(Date.now() - 7*24*60*60*1000) }
          }
        }) || 0
      }
    };
    
    res.json({ success: true, stats });
  } catch (error) {
    console.error('Admin stats error:', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

// GET /api/admin/users - List all users
router.get('/users', authMiddleware, adminOnly, async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: ['id', 'email', 'firstName', 'lastName', 'classType', 'role', 'totalCredits', 'lastLogin'],
      order: [['createdAt', 'DESC']]
    });
    res.json({ success: true, users });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

module.exports = router;
EOF

# 5. Create basic dashboard
echo "Creating public/dashboard.html..."
mkdir -p public
cat > public/dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CityTech Sustainability DAO Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { text-align: center; color: #2c3e50; margin-bottom: 30px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stat-number { font-size: 2em; font-weight: bold; color: #27ae60; }
        .stat-label { color: #7f8c8d; }
        .leaderboard { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .user-row { padding: 10px; border-bottom: 1px solid #ecf0f1; display: flex; justify-content: space-between; }
        .error { color: #e74c3c; text-align: center; padding: 20px; }
        .loading { text-align: center; padding: 20px; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌱 CityTech Sustainability DAO</h1>
            <p>Real-time dashboard of student sustainability contributions</p>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number" id="totalUsers">-</div>
                <div class="stat-label">Total Students</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="totalProjects">-</div>
                <div class="stat-label">Projects Created</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="totalCredits">-</div>
                <div class="stat-label">Credits Awarded</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="activeToday">-</div>
                <div class="stat-label">Active Today</div>
            </div>
        </div>

        <div class="leaderboard">
            <h2>🏆 Credit Leaderboard</h2>
            <div id="leaderboardContent" class="loading">Loading leaderboard...</div>
        </div>
    </div>

    <script>
        const API_BASE = 'https://sustainabledao-api.onrender.com/api';
        
        async function loadStats() {
            try {
                // Load basic stats from projects and credits endpoints
                const [projectsRes, creditsRes] = await Promise.all([
                    fetch(`${API_BASE}/projects`).catch(() => ({ ok: false })),
                    fetch(`${API_BASE}/credits/leaderboard`).catch(() => ({ ok: false }))
                ]);

                if (projectsRes.ok) {
                    const projectsData = await projectsRes.json();
                    document.getElementById('totalProjects').textContent = projectsData.projects?.length || 0;
                }

                if (creditsRes.ok) {
                    const creditsData = await creditsRes.json();
                    const leaderboard = creditsData.leaderboard || [];
                    
                    document.getElementById('totalUsers').textContent = leaderboard.length;
                    
                    const totalCredits = leaderboard.reduce((sum, user) => sum + (user.totalCredits || 0), 0);
                    document.getElementById('totalCredits').textContent = totalCredits;
                    
                    // Display leaderboard
                    const leaderboardHtml = leaderboard.map((user, index) => `
                        <div class="user-row">
                            <span>#${index + 1} ${user.firstName} ${user.lastName} (${user.classType})</span>
                            <strong>${user.totalCredits} credits</strong>
                        </div>
                    `).join('');
                    
                    document.getElementById('leaderboardContent').innerHTML = leaderboardHtml || '<div class="loading">No users yet</div>';
                } else {
                    document.getElementById('leaderboardContent').innerHTML = '<div class="error">Unable to load leaderboard</div>';
                }

            } catch (error) {
                console.error('Dashboard error:', error);
                document.getElementById('leaderboardContent').innerHTML = '<div class="error">Dashboard temporarily unavailable</div>';
            }
        }

        // Load stats on page load
        loadStats();
        
        // Refresh every 30 seconds
        setInterval(loadStats, 30000);
        
        // Show API status
        fetch(`${API_BASE}/v1/health`)
            .then(res => res.json())
            .then(data => {
                console.log('API Status:', data);
                document.getElementById('activeToday').textContent = data.status === 'healthy' ? '✅' : '❌';
            })
            .catch(() => {
                document.getElementById('activeToday').textContent = '❌';
            });
    </script>
</body>
</html>
EOF

echo "✅ All critical fixes completed!"
echo ""
echo "🚀 Next steps:"
echo "1. Install missing dependency: npm install node-cron"
echo "2. Test locally: npm start"
echo "3. Deploy: git add . && git commit -m 'Fix critical issues' && git push"
echo ""
echo "🌐 Your API should now work at: https://sustainabledao-api.onrender.com"
