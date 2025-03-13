const express = require('express');
const axios = require('axios');
const User = require('../models/User');
const Queue = require('../models/Queue');
const router = express.Router();

// Mock X and library API credentials (replace with real ones)
const X_API_URL = 'http://mock-x-api.example.com';

// Register user with libraries
router.post('/register', async (req, res) => {
  const { xUsername, libraryCard } = req.body;
  try {
    let user = await User.findOne({ xUsername });
    if (!user) {
      user = new User({
        xUsername,
        libraryCard,
        libraries: ['http://library1.example.com/api', 'http://library2.example.com/api'], // Mock
      });
      await user.save();
    }

    // Auto-register with libraries
    for (const library of user.libraries) {
      await axios.post(`${library}/register`, { username: xUsername, card: libraryCard });
    }
    res.json({ message: 'Registration successful', user });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get queue status
router.get('/queue/:xUsername', async (req, res) => {
  const { xUsername } = req.params;
  try {
    const user = await User.findOne({ xUsername });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const statuses = await Promise.all(user.libraries.map(async (library) => {
      const response = await axios.get(`${library}/queue?user=${user.libraryCard}`);
      return { library, status: response.data }; // Mock response
    }));

    // Save to DB and check for updates
    for (const { library, status } of statuses) {
      const book = status.book || 'Unknown'; // Mock parsing
      const currentStatus = status.position === 0 ? 'Available' : `Position: ${status.position}`;
      const existing = await Queue.findOne({ userId: user._id, book, library });
      if (!existing || existing.status !== currentStatus) {
        await new Queue({ userId: user._id, book, library, status: currentStatus }).save();
        if (currentStatus === 'Available') {
          postToX(`${xUsername}, your book '${book}' is available at ${library}!`);
        }
      }
    }

    const queueHistory = await Queue.find({ userId: user._id });
    res.json(queueHistory);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Mock X posting
async function postToX(message) {
  try {
    await axios.post(`${X_API_URL}/post`, { message });
    console.log(`Posted to X: ${message}`);
  } catch (error) {
    console.error('Failed to post to X:', error.message);
  }
}

module.exports = router;