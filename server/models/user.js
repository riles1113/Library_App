// User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  xUsername: { type: String, required: true },
  libraryCard: { type: String, required: true },
  libraries: [{ type: String }], // Library API endpoints
});

module.exports = mongoose.model('User', userSchema);