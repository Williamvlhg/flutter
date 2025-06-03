const mongoose = require('mongoose');

const characterSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  nameFr: {
    type: String,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  biography: {
    type: String
  },
  imageUrl: String,
  thumbnailUrl: String,
  gallery: [String],
  episodes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Episode'
  }],
  episodeCount: {
    type: Number,
    default: 0
  },
  family: {
    type: String,
    trim: true
  },
  relatives: [{
    name: String,
    relationship: String,
    characterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Character'
    }
  }],
  job: {
    type: String,
    trim: true
  },
  workplace: String,
  age: Number,
  birthDate: Date,
  address: String,
  personality: [String],
  hobbies: [String],
  catchphrases: [String],
  voiceActor: {
    english: String,
    french: String
  },
  firstAppearance: {
    episode: String,
    season: Number,
    episodeNumber: Number,
    date: Date
  },
  isMajor: {
    type: Boolean,
    default: false
  },
  isRecurring: {
    type: Boolean,
    default: false
  },
  status: {
    type: String,
    enum: ['alive', 'dead', 'unknown'],
    default: 'alive'
  },
  popularityScore: {
    type: Number,
    default: 0
  },
  tags: [String],
  trivia: [{
    fact: String,
    source: String
  }],
  quotes: [{
    quote: String,
    episode: String,
    context: String
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

characterSchema.index({ name: 'text', nameFr: 'text', description: 'text' });

characterSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Character', characterSchema);