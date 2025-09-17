// Replace routes/projects.js with this:
const router = require("express").Router();

router.get("/", (req, res) => {
  res.json({ success: true, projects: [] });
});

router.get("/engineering", (req, res) => {
  res.json({ success: true, projects: [] });
});

module.exports = router;
