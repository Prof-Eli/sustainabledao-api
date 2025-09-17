// CreditTransaction Model - Records every credit earning activity
// This creates an audit trail of how students earned their credits

const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const CreditTransaction = sequelize.define('CreditTransaction', {
  // Transaction ID
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  
  // Who earned the credits (links to User)
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  
  // Which project (optional - some credits aren't project-based)
  projectId: {
    type: DataTypes.UUID,
    references: {
      model: 'ClassProjects',
      key: 'id'
    },
    allowNull: true
  },
  
  // Type of activity that earned credits
  activityType: {
    type: DataTypes.ENUM(
      'project_completion',     // Finished a project
      'peer_review',           // Reviewed another student's work
      'research_contribution', // Added research/documentation
      'data_collection',       // Collected sustainability data
      'documentation',         // Wrote guides/tutorials
      'code_contribution',     // Contributed code
      'weekly_participation',  // Weekly active bonus
      'streak_bonus'          // Consecutive days active
    ),
    allowNull: false
  },
  
  // Number of credits earned
  amount: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1  // Must be at least 1 credit
    }
  },
  
  // Description of what was done
  description: {
    type: DataTypes.TEXT
  },
  
  // Verification status
  verifiedBy: {
    type: DataTypes.UUID,  // Instructor who verified
    allowNull: true
  },
  isVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false  // Starts unverified
  }
});

module.exports = CreditTransaction;
