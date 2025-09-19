const router = require("express").Router();

const mockProjects = [
  {
    id: 1,
    title: "Solar Panel Installation",
    classType: "engineering",
    creditsEarned: 50,
    User: { firstName: "John", lastName: "Doe" },
  },
  {
    id: 2,
    title: "Campus Garden",
    classType: "land_use",
    creditsEarned: 30,
    User: { firstName: "Jane", lastName: "Smith" },
  },
];

router.get("/", (req, res) => {
  res.json({ success: true, projects: mockProjects });
});

router.get("/engineering", (req, res) => {
  const eng = mockProjects.filter((p) => p.classType === "engineering");
  res.json({ success: true, projects: eng });
});

router.get("/land-use", (req, res) => {
  const land = mockProjects.filter((p) => p.classType === "land_use");
  res.json({ success: true, projects: land });
});

module.exports = router;
