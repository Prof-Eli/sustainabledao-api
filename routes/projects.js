const router = require("express").Router();

router.get("/engineering", (req, res) => {
  res.json([]);
});

router.get("/", (req, res) => {
  res.json([]);
});

module.exports = router;
