// Authentication Middleware - Checks if user is logged in
// This protects routes that require login

const jwt = require('jsonwebtoken');
const { User } = require('../models');

const authMiddleware = async (req, res, next) => {
  try {
    // Get token from Authorization header
    // Format: "Bearer eyJhbGciOiJIUzI1NiIs..."
    const authHeader = req.header('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new Error('No valid token provided');
    }
    
    // Extract token (remove "Bearer " prefix)
    const token = authHeader.replace('Bearer ', '');
    
    // Verify token is valid and not expired
    const decoded = jwt.verify(
      token, 
      process.env.JWT_SECRET || 'development-secret'
    );
    
    // Find user from token
    const user = await User.findByPk(decoded.id);
    
    if (!user || !user.isActive) {
      throw new Error('User not found or inactive');
    }
    
    // Attach user to request for use in routes
    req.user = user;
    req.token = token;
    
    // Continue to the route
    next();
    
  } catch (error) {
    console.error('Auth error:', error.message);
    res.status(401).json({ 
      error: 'Please authenticate. Login required.' 
    });
  }
};

module.exports = authMiddleware;
