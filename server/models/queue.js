// Queue.js
const mongoose = require('mongoose');

const queueSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  book: String,
  library: String,
  status: String,
  timestamp: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Queue', queueSchema);