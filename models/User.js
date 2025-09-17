// User Model - Stores student and instructor accounts
// Every student gets an account to track their sustainability contributions

const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const bcrypt = require('bcryptjs'); // For password hashing (security)

const User = sequelize.define('User', {
  // Unique ID for each user (like a student ID but random)
  id: {
    type: DataTypes.UUID,            // UUID = Universally Unique Identifier
    defaultValue: DataTypes.UUIDV4,  // Auto-generate random ID
    primaryKey: true                 // This is the main identifier
  },
  
  // Email for login (must be unique)
  email: {
    type: DataTypes.STRING,
    allowNull: false,        // Required field
    unique: true,           // No duplicate emails
    validate: {
      isEmail: true         // Must be valid email format
    }
  },
  
  // Encrypted password (never stored as plain text!)
  password: {
    type: DataTypes.STRING,
    allowNull: false
  },
  
  // Student's name
  firstName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  lastName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  
  // Which class track: 'engineering', 'land_use', or 'both'
  classType: {
    type: DataTypes.ENUM('engineering', 'land_use', 'both'),
    defaultValue: 'engineering'
  },
  
  // User type: 'student', 'instructor', or 'admin'
  role: {
    type: DataTypes.ENUM('student', 'instructor', 'admin'),
    defaultValue: 'student'
  },
  
  // Total sustainability credits earned
  totalCredits: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  
  // Account status
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  
  // Track last login time
  lastLogin: {
    type: DataTypes.DATE,
    allowNull: true
  },
  
  // Future DAO features (not used yet)
  walletAddress: {
    type: DataTypes.STRING(42),
    unique: true,
    allowNull: true
  },
  reputationScore: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  // Hooks run automatically at certain times
  hooks: {
    // Before saving a new user, hash their password
    beforeCreate: async (user) => {
      if (user.password) {
        const salt = await bcrypt.genSalt(10);  // Add randomness
        user.password = await bcrypt.hash(user.password, salt);  // Encrypt
      }
    },
    // Before updating a user, hash new password if changed
    beforeUpdate: async (user) => {
      if (user.changed('password')) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    }
  }
});

// Function to check if password is correct
User.prototype.verifyPassword = async function(password) {
  return await bcrypt.compare(password, this.password);
};

module.exports = User;
