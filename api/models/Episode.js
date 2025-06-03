const mongoose = require('mongoose');

const episodeSchema = new mongoose.Schema({
  season: {
    type: Number,
    required: true,
    min: 1
  },
  episodeNumber: {
    type: Number,
    required: true,
    min: 1
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  titleFr: {
    type: String,
    trim: true
  },
  summary: {
    type: String,
    required: true
  },
  plot: {
    type: String
  },
  characters: [{
    type: String,
    trim: true
  }],
  mainCharacters: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Character'
  }],
  airDate: {
    type: Date,
    required: true
  },
  duration: {
    type: Number, 
    default: 22
  },
  imageUrl: String,
  thumbnailUrl: String,
  videoUrl: String,
  trivia: [{
    fact: String,
    category: String
  }],
  guestStars: [{
    name: String,
    character: String,
    voice: String
  }],
  culturalReferences: [{
    reference: String,
    explanation: String
  }],
  quotes: [{
    character: String,
    quote: String,
    context: String
  }],
  ratings: {
    imdb: Number,
    audience: Number,
    critics: Number
  },
  views: {
    type: Number,
    default: 0
  },
  tags: [String],
  isSpecial: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

episodeSchema.index({ title: 'text', titleFr: 'text', summary: 'text' });
episodeSchema.index({ season: 1, episodeNumber: 1 }, { unique: true });

episodeSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Episode', episodeSchema);