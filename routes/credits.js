const router = require("express").Router();

// Mock data for now
const mockLeaderboard = [
  {
    id: 1,
    firstName: "John",
    lastName: "Doe",
    classType: "engineering",
    totalCredits: 150,
  },
  {
    id: 2,
    firstName: "Jane",
    lastName: "Smith",
    classType: "land_use",
    totalCredits: 120,
  },
];

router.get("/leaderboard", (req, res) => {
  res.json({ success: true, leaderboard: mockLeaderboard });
});

router.get("/stats", (req, res) => {
  res.json({ success: true, stats: { totalUsers: 2, totalCredits: 270 } });
});

module.exports = router;
