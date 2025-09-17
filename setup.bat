@echo off
echo =====================================================
echo CityTech Sustainability API Setup
echo =====================================================
echo.

REM Check if we're in the right directory
if not exist package.json (
    echo ❌ Error: package.json not found!
    echo Please run this script from your project root directory
    pause
    exit /b 1
)

echo 📁 Creating directories...
if not exist models mkdir models
if not exist routes mkdir routes
if not exist middleware mkdir middleware
if not exist config mkdir config
if not exist public mkdir public

echo 📦 Installing dependencies...
call npm install express dotenv cors bcryptjs jsonwebtoken sequelize pg pg-hstore --save
call npm install --save-dev nodemon

echo.
echo 📝 Creating files...

echo    Creating server.js...
(
echo const express = require^('express'^);
echo const cors = require^('cors'^);
echo const path = require^('path'^);
echo require^('dotenv'^).config^(^);
echo.
echo const app = express^(^);
echo const PORT = process.env.PORT ^|^| 3000;
echo.
echo app.use^(cors^(^^)^);
echo app.use^(express.json^(^^)^);
echo app.use^(express.static^('public'^)^);
echo.
echo // Import routes
echo const authRoutes = require^('./routes/auth'^);
echo const projectRoutes = require^('./routes/projects'^);
echo const creditRoutes = require^('./routes/credits'^);
echo const adminRoutes = require^('./routes/admin'^);
echo.
echo // Database connection
echo const { sequelize } = require^('./config/database'^);
echo.
echo // Health check endpoint
echo app.get^('/api/v1/health', ^(req, res^) =^> {
echo   res.json^({
echo     status: 'healthy',
echo     timestamp: new Date^(^),
echo     environment: process.env.NODE_ENV ^|^| 'development'
echo   }^);
echo }^);
echo.
echo // API Routes
echo app.use^('/api/auth', authRoutes^);
echo app.use^('/api/projects', projectRoutes^);
echo app.use^('/api/credits', creditRoutes^);
echo app.use^('/api/admin', adminRoutes^);
echo.
echo // Error handling
echo app.use^(^(err, req, res, next^) =^> {
echo   console.error^(err.stack^);
echo   res.status^(500^).json^({ error: 'Something went wrong!' }^);
echo }^);
echo.
echo // Start server
echo const startServer = async ^(^) =^> {
echo   try {
echo     await sequelize.authenticate^(^);
echo     console.log^('✅ Database connected'^);
echo     
echo     await sequelize.sync^({ alter: true }^);
echo     console.log^('✅ Database models synchronized'^);
echo     
echo     app.listen^(PORT, ^(^) =^> {
echo       console.log^(`🚀 Server running on port ${PORT}`^);
echo       console.log^(`📊 Dashboard: http://localhost:${PORT}/dashboard.html`^);
echo     }^);
echo   } catch ^(error^) {
echo     console.error^('❌ Server start failed:', error^);
echo   }
echo };
echo.
echo startServer^(^);
) > server.js

echo    Creating config/database.js...
(
echo const { Sequelize } = require^('sequelize'^);
echo.
echo const sequelize = new Sequelize^(process.env.DATABASE_URL ^|^| 'postgresql://localhost:5432/sustainability_db', {
echo   dialect: 'postgres',
echo   logging: process.env.NODE_ENV === 'development' ? console.log : false,
echo   dialectOptions: {
echo     ssl: process.env.NODE_ENV === 'production' ? {
echo       require: true,
echo       rejectUnauthorized: false
echo     } : false
echo   }
echo }^);
echo.
echo module.exports = { sequelize };
) > config/database.js

echo    Creating models/User.js...
(
echo const { DataTypes } = require^('sequelize'^);
echo const { sequelize } = require^('../config/database'^);
echo const bcrypt = require^('bcryptjs'^);
echo.
echo const User = sequelize.define^('User', {
echo   id: {
echo     type: DataTypes.UUID,
echo     defaultValue: DataTypes.UUIDV4,
echo     primaryKey: true
echo   },
echo   email: {
echo     type: DataTypes.STRING,
echo     allowNull: false,
echo     unique: true,
echo     validate: { isEmail: true }
echo   },
echo   password: {
echo     type: DataTypes.STRING,
echo     allowNull: false
echo   },
echo   firstName: {
echo     type: DataTypes.STRING,
echo     allowNull: false
echo   },
echo   lastName: {
echo     type: DataTypes.STRING,
echo     allowNull: false
echo   },
echo   classSection: {
echo     type: DataTypes.STRING,
echo     allowNull: false
echo   },
echo   role: {
echo     type: DataTypes.ENUM^('student', 'instructor', 'admin'^),
echo     defaultValue: 'student'
echo   },
echo   totalCredits: {
echo     type: DataTypes.INTEGER,
echo     defaultValue: 0
echo   },
echo   isActive: {
echo     type: DataTypes.BOOLEAN,
echo     defaultValue: true
echo   }
echo }, {
echo   hooks: {
echo     beforeCreate: async ^(user^) =^> {
echo       if ^(user.password^) {
echo         const salt = await bcrypt.genSalt^(10^);
echo         user.password = await bcrypt.hash^(user.password, salt^);
echo       }
echo     }
echo   }
echo }^);
echo.
echo User.prototype.verifyPassword = async function^(password^) {
echo   return await bcrypt.compare^(password, this.password^);
echo };
echo.
echo module.exports = User;
) > models/User.js

echo    Creating models/Project.js...
(
echo const { DataTypes } = require^('sequelize'^);
echo const { sequelize } = require^('../config/database'^);
echo.
echo const Project = sequelize.define^('Project', {
echo   id: {
echo     type: DataTypes.UUID,
echo     defaultValue: DataTypes.UUIDV4,
echo     primaryKey: true
echo   },
echo   title: {
echo     type: DataTypes.STRING,
echo     allowNull: false
echo   },
echo   description: {
echo     type: DataTypes.TEXT
echo   },
echo   category: {
echo     type: DataTypes.ENUM^('renewable_energy', 'waste_reduction', 'water_conservation', 'transportation', 'green_building'^),
echo     allowNull: false
echo   },
echo   creditValue: {
echo     type: DataTypes.INTEGER,
echo     allowNull: false,
echo     defaultValue: 10
echo   },
echo   difficulty: {
echo     type: DataTypes.ENUM^('beginner', 'intermediate', 'advanced'^),
echo     defaultValue: 'beginner'
echo   },
echo   isActive: {
echo     type: DataTypes.BOOLEAN,
echo     defaultValue: true
echo   }
echo }^);
echo.
echo module.exports = Project;
) > models/Project.js

echo    Creating models/CreditTransaction.js...
(
echo const { DataTypes } = require^('sequelize'^);
echo const { sequelize } = require^('../config/database'^);
echo.
echo const CreditTransaction = sequelize.define^('CreditTransaction', {
echo   id: {
echo     type: DataTypes.UUID,
echo     defaultValue: DataTypes.UUIDV4,
echo     primaryKey: true
echo   },
echo   userId: {
echo     type: DataTypes.UUID,
echo     allowNull: false
echo   },
echo   amount: {
echo     type: DataTypes.INTEGER,
echo     allowNull: false
echo   },
echo   type: {
echo     type: DataTypes.ENUM^('earned', 'spent', 'transferred'^),
echo     allowNull: false
echo   },
echo   description: {
echo     type: DataTypes.STRING,
echo     allowNull: false
echo   },
echo   projectId: {
echo     type: DataTypes.UUID,
echo     allowNull: true
echo   }
echo }^);
echo.
echo module.exports = CreditTransaction;
) > models/CreditTransaction.js

echo    Creating routes/auth.js...
(
echo const express = require^('express'^);
echo const jwt = require^('jsonwebtoken'^);
echo const User = require^('../models/User'^);
echo const router = express.Router^(^);
echo.
echo router.post^('/register', async ^(req, res^) =^> {
echo   try {
echo     const { email, password, firstName, lastName, classSection } = req.body;
echo     
echo     const existingUser = await User.findOne^({ where: { email } }^);
echo     if ^(existingUser^) {
echo       return res.status^(400^).json^({ error: 'User already exists' }^);
echo     }
echo     
echo     const user = await User.create^({
echo       email, password, firstName, lastName, classSection
echo     }^);
echo     
echo     const token = jwt.sign^(
echo       { id: user.id, email: user.email },
echo       process.env.JWT_SECRET ^|^| 'dev-secret',
echo       { expiresIn: '7d' }
echo     ^);
echo     
echo     res.status^(201^).json^({
echo       message: 'User created successfully',
echo       token,
echo       user: {
echo         id: user.id,
echo         email: user.email,
echo         firstName: user.firstName,
echo         lastName: user.lastName,
echo         classSection: user.classSection,
echo         totalCredits: user.totalCredits
echo       }
echo     }^);
echo   } catch ^(error^) {
echo     console.error^('Registration error:', error^);
echo     res.status^(500^).json^({ error: 'Registration failed' }^);
echo   }
echo }^);
echo.
echo router.post^('/login', async ^(req, res^) =^> {
echo   try {
echo     const { email, password } = req.body;
echo     
echo     const user = await User.findOne^({ where: { email } }^);
echo     if ^(!user^) {
echo       return res.status^(401^).json^({ error: 'Invalid credentials' }^);
echo     }
echo     
echo     const isValidPassword = await user.verifyPassword^(password^);
echo     if ^(!isValidPassword^) {
echo       return res.status^(401^).json^({ error: 'Invalid credentials' }^);
echo     }
echo     
echo     const token = jwt.sign^(
echo       { id: user.id, email: user.email },
echo       process.env.JWT_SECRET ^|^| 'dev-secret',
echo       { expiresIn: '7d' }
echo     ^);
echo     
echo     res.json^({
echo       message: 'Login successful',
echo       token,
echo       user: {
echo         id: user.id,
echo         email: user.email,
echo         firstName: user.firstName,
echo         lastName: user.lastName,
echo         classSection: user.classSection,
echo         totalCredits: user.totalCredits
echo       }
echo     }^);
echo   } catch ^(error^) {
echo     console.error^('Login error:', error^);
echo     res.status^(500^).json^({ error: 'Login failed' }^);
echo   }
echo }^);
echo.
echo module.exports = router;
) > routes/auth.js

echo    Creating routes/projects.js...
(
echo const express = require^('express'^);
echo const Project = require^('../models/Project'^);
echo const router = express.Router^(^);
echo.
echo router.get^('/', async ^(req, res^) =^> {
echo   try {
echo     const projects = await Project.findAll^({
echo       where: { isActive: true },
echo       order: [['createdAt', 'DESC']]
echo     }^);
echo     res.json^(projects^);
echo   } catch ^(error^) {
echo     console.error^('Error fetching projects:', error^);
echo     res.status^(500^).json^({ error: 'Failed to fetch projects' }^);
echo   }
echo }^);
echo.
echo router.get^('/:id', async ^(req, res^) =^> {
echo   try {
echo     const project = await Project.findByPk^(req.params.id^);
echo     if ^(!project^) {
echo       return res.status^(404^).json^({ error: 'Project not found' }^);
echo     }
echo     res.json^(project^);
echo   } catch ^(error^) {
echo     console.error^('Error fetching project:', error^);
echo     res.status^(500^).json^({ error: 'Failed to fetch project' }^);
echo   }
echo }^);
echo.
echo router.post^('/', async ^(req, res^) =^> {
echo   try {
echo     const project = await Project.create^(req.body^);
echo     res.status^(201^).json^(project^);
echo   } catch ^(error^) {
echo     console.error^('Error creating project:', error^);
echo     res.status^(500^).json^({ error: 'Failed to create project' }^);
echo   }
echo }^);
echo.
echo module.exports = router;
) > routes/projects.js

echo    Creating routes/credits.js...
(
echo const express = require^('express'^);
echo const CreditTransaction = require^('../models/CreditTransaction'^);
echo const User = require^('../models/User'^);
echo const router = express.Router^(^);
echo.
echo router.get^('/transactions/:userId', async ^(req, res^) =^> {
echo   try {
echo     const transactions = await CreditTransaction.findAll^({
echo       where: { userId: req.params.userId },
echo       order: [['createdAt', 'DESC']]
echo     }^);
echo     res.json^(transactions^);
echo   } catch ^(error^) {
echo     console.error^('Error fetching transactions:', error^);
echo     res.status^(500^).json^({ error: 'Failed to fetch transactions' }^);
echo   }
echo }^);
echo.
echo router.post^('/award', async ^(req, res^) =^> {
echo   try {
echo     const { userId, amount, description, projectId } = req.body;
echo     
echo     const transaction = await CreditTransaction.create^({
echo       userId, amount, type: 'earned', description, projectId
echo     }^);
echo     
echo     const user = await User.findByPk^(userId^);
echo     if ^(user^) {
echo       await user.update^({ totalCredits: user.totalCredits + amount }^);
echo     }
echo     
echo     res.status^(201^).json^({
echo       message: 'Credits awarded successfully',
echo       transaction
echo     }^);
echo   } catch ^(error^) {
echo     console.error^('Error awarding credits:', error^);
echo     res.status^(500^).json^({ error: 'Failed to award credits' }^);
echo   }
echo }^);
echo.
echo module.exports = router;
) > routes/credits.js

echo    Creating routes/admin.js...
(
echo const express = require^('express'^);
echo const User = require^('../models/User'^);
echo const Project = require^('../models/Project'^);
echo const CreditTransaction = require^('../models/CreditTransaction'^);
echo const router = express.Router^(^);
echo.
echo router.get^('/users', async ^(req, res^) =^> {
echo   try {
echo     const users = await User.findAll^({
echo       attributes: { exclude: ['password'] },
echo       order: [['createdAt', 'DESC']]
echo     }^);
echo     res.json^(users^);
echo   } catch ^(error^) {
echo     console.error^('Error fetching users:', error^);
echo     res.status^(500^).json^({ error: 'Failed to fetch users' }^);
echo   }
echo }^);
echo.
echo router.get^('/stats', async ^(req, res^) =^> {
echo   try {
echo     const userCount = await User.count^(^);
echo     const projectCount = await Project.count^(^);
echo     const totalCredits = await CreditTransaction.sum^('amount', { 
echo       where: { type: 'earned' } 
echo     }^) ^|^| 0;
echo     
echo     res.json^({
echo       totalUsers: userCount,
echo       totalProjects: projectCount,
echo       totalCreditsAwarded: totalCredits
echo     }^);
echo   } catch ^(error^) {
echo     console.error^('Error fetching stats:', error^);
echo     res.status^(500^).json^({ error: 'Failed to fetch stats' }^);
echo   }
echo }^);
echo.
echo module.exports = router;
) > routes/admin.js

echo    Creating middleware/auth.js...
(
echo const jwt = require^('jsonwebtoken'^);
echo const User = require^('../models/User'^);
echo.
echo const authMiddleware = async ^(req, res, next^) =^> {
echo   try {
echo     const authHeader = req.header^('Authorization'^);
echo     
echo     if ^(!authHeader^) {
echo       throw new Error^('No token provided'^);
echo     }
echo     
echo     const token = authHeader.replace^('Bearer ', ''^);
echo     const decoded = jwt.verify^(token, process.env.JWT_SECRET ^|^| 'dev-secret'^);
echo     const user = await User.findByPk^(decoded.id^);
echo     
echo     if ^(!user^) {
echo       throw new Error^('User not found'^);
echo     }
echo     
echo     req.user = user;
echo     req.token = token;
echo     next^(^);
echo   } catch ^(error^) {
echo     res.status^(401^).json^({ error: 'Please authenticate' }^);
echo   }
echo };
echo.
echo module.exports = authMiddleware;
) > middleware/auth.js

echo    Creating public/dashboard.html...
(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo ^<title^>Sustainability API Dashboard^</title^>
echo ^<style^>
echo body{font-family:Arial;margin:20px;background:#f5f5f5}
echo .card{background:white;padding:20px;margin:10px;border-radius:5px}
echo .btn{background:#007bff;color:white;border:none;padding:10px 20px;margin:5px;cursor:pointer}
echo ^</style^>
echo ^</head^>
echo ^<body^>
echo ^<h1^>🌱 CityTech Sustainability API Dashboard^</h1^>
echo ^<div class='card'^>
echo ^<h3^>System Status^</h3^>
echo ^<div id='status'^>Checking...^</div^>
echo ^<button class='btn' onclick='checkHealth()'^>Check Health^</button^>
echo ^</div^>
echo ^<div class='card'^>
echo ^<h3^>API Endpoints^</h3^>
echo ^<p^>GET /api/v1/health^</p^>
echo ^<p^>POST /api/auth/register^</p^>
echo ^<p^>POST /api/auth/login^</p^>
echo ^<p^>GET /api/projects^</p^>
echo ^</div^>
echo ^<script^>
echo async function checkHealth(){
echo try{
echo const r=await fetch('/api/v1/health'^);
echo const d=await r.json();
echo document.getElementById('status'^).innerHTML='✅ Server: '+d.status;
echo }catch(e^){
echo document.getElementById('status'^).innerHTML='❌ Server offline';
echo }}
echo checkHealth();
echo ^</script^>
echo ^</body^>
echo ^</html^>
) > public/dashboard.html

echo    Creating .env.example...
(
echo # Database Configuration
echo DATABASE_URL=postgresql://sustainabledao_db_user:YOUR_PASSWORD_HERE@dpg-ct82pk5svqrc73fokfb0-a.oregon-postgres.render.com/sustainabledao_db
echo.
echo # JWT Secret
echo JWT_SECRET=your-secret-key-change-this-immediately
echo.
echo # Server Configuration
echo PORT=3000
echo NODE_ENV=development
) > .env.example

echo.
echo ✅ Setup Complete!
echo ==================
echo.
echo 📋 NEXT STEPS:
echo.
echo 1. Create your .env file:
echo    copy .env.example .env
echo.
echo 2. Edit .env and add:
echo    - Your database password from Render
echo    - A random JWT_SECRET
echo.
echo 3. Start the server:
echo    npm start
echo.
echo 4. Open dashboard:
echo    http://localhost:3000/dashboard.html
echo.
echo 🚀 Your API is ready!
echo.
pause