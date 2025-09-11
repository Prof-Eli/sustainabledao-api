const router = require("express").Router();

router.get("/test", (req, res) => {
  res.json({ message: "Routes working!" });
});

module.exports = router;
