const authMiddleware = (req, res, next) => {
  // Basic auth middleware
  next();
};

module.exports = authMiddleware;
