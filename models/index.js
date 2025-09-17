// Model Index - Sets up relationships between tables
// This is like defining how tables connect to each other

const User = require('./User');
const ClassProject = require('./ClassProject');
const CreditTransaction = require('./CreditTransaction');

// === DEFINE RELATIONSHIPS ===

// A user can create many projects
User.hasMany(ClassProject, { foreignKey: 'createdBy' });
// A project belongs to one user
ClassProject.belongsTo(User, { foreignKey: 'createdBy' });

// A user can have many credit transactions
User.hasMany(CreditTransaction, { foreignKey: 'userId' });
// A transaction belongs to one user
CreditTransaction.belongsTo(User, { foreignKey: 'userId' });

// A project can generate many credit transactions
ClassProject.hasMany(CreditTransaction, { foreignKey: 'projectId' });
// A transaction might belong to a project
CreditTransaction.belongsTo(ClassProject, { foreignKey: 'projectId' });

// Export all models
module.exports = {
  User,
  ClassProject,
  CreditTransaction
};
