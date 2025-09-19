// EMERGENCY FIX - Replace routes/credits.js with this ONLY:
const router = require("express").Router();

router.get("/leaderboard", (req, res) => {
  res.json({ success: true, leaderboard: [] });
});

module.exports = router;
