const router = require("express").Router();

router.get("/stats", (req, res) => {
  res.json({
    success: true,
    stats: {
      totalUsers: 2,
      totalProjects: 2,
      totalCredits: 270,
      activeToday: 1,
    },
  });
});

module.exports = router;
