const router = require("express").Router();

router.get("/leaderboard", (req, res) => {
  res.json({ success: true, leaderboard: [] });
});

module.exports = router;
