// ClassProject Model - Stores sustainability projects for both classes
// Engineering projects track energy/carbon, Land Use tracks area/species

const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ClassProject = sequelize.define('ClassProject', {
  // Unique project ID
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  
  // Which class: 'engineering' or 'land_use'
  classType: {
    type: DataTypes.ENUM('engineering', 'land_use'),
    allowNull: false  // Must specify which class
  },
  
  // Project details
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT  // TEXT allows long descriptions
  },
  
  // === ENGINEERING CLASS METRICS ===
  // (These will be NULL for land_use projects)
  energySaved: {
    type: DataTypes.DECIMAL(10, 2),  // Up to 10 digits, 2 after decimal
    comment: 'kWh of energy saved'
  },
  carbonReduced: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'kg of CO2 reduced'
  },
  waterSaved: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'gallons of water saved'
  },
  
  // === LAND USE CLASS METRICS ===
  // (These will be NULL for engineering projects)
  areaConverted: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'square feet of area converted to green space'
  },
  speciesCount: {
    type: DataTypes.INTEGER,
    comment: 'number of species planted or observed'
  },
  soilQuality: {
    type: DataTypes.INTEGER,
    comment: 'soil quality score 0-100'
  },
  
  // === SHARED FIELDS ===
  creditsEarned: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'total credits earned from this project'
  },
  status: {
    type: DataTypes.ENUM('proposed', 'in_progress', 'completed', 'verified'),
    defaultValue: 'proposed'
  },
  
  // Who created the project (links to User table)
  createdBy: {
    type: DataTypes.UUID,
    references: {
      model: 'Users',
      key: 'id'
    }
  }
});

module.exports = ClassProject;
