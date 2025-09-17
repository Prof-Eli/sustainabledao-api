const router = require('express').Router();
const { User } = require('../models');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

router.post('/register', async (req, res) => {
  try {
    const { email, password, firstName, lastName, classType } = req.body;
    const user = await User.create({ email, password, firstName, lastName, classType: classType || 'engineering' });
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'dev-secret', { expiresIn: '7d' });
    res.status(201).json({ success: true, token, user: { id: user.id, email: user.email, firstName: user.firstName } });
  } catch (error) {
    res.status(500).json({ error: 'Registration failed' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user || !(await user.verifyPassword(password))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'dev-secret', { expiresIn: '7d' });
    res.json({ success: true, token, user: { id: user.id, email: user.email } });
  } catch (error) {
    res.status(500).json({ error: 'Login failed' });
  }
});

module.exports = router;
