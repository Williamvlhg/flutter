const mongoose = require('mongoose');

const newsSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  slug: {
    type: String,
    unique: true,
    lowercase: true
  },
  excerpt: {
    type: String,
    maxlength: 200
  },
  content: {
    type: String,
    required: true
  },
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  authorName: {
    type: String,
    required: true
  },
  category: {
    type: String,
    enum: ['actualité', 'rumeur', 'critique', 'interview', 'analyse', 'évènement'],
    default: 'actualité'
  },
  tags: [String],
  imageUrl: String,
  thumbnailUrl: String,
  gallery: [String],
  source: {
    name: String,
    url: String
  },
  relatedEpisodes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Episode'
  }],
  relatedCharacters: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Character'
  }],
  status: {
    type: String,
    enum: ['draft', 'published', 'archived'],
    default: 'draft'
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  isPinned: {
    type: Boolean,
    default: false
  },
  views: {
    type: Number,
    default: 0
  },
  likes: {
    type: Number,
    default: 0
  },
  publishedAt: {
    type: Date,
    default: Date.now
  },
  scheduledFor: Date,
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

newsSchema.index({ title: 'text', content: 'text' });
newsSchema.index({ publishedAt: -1 });
newsSchema.index({ status: 1, publishedAt: -1 });

newsSchema.pre('save', function(next) {
  if (this.isModified('title')) {
    this.slug = this.title
      .toLowerCase()
      .replace(/[àáâãäå]/g, 'a')
      .replace(/[èéêë]/g, 'e')
      .replace(/[ìíîï]/g, 'i')
      .replace(/[òóôõö]/g, 'o')
      .replace(/[ùúûü]/g, 'u')
      .replace(/[ç]/g, 'c')
      .replace(/[^a-z0-9]/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-|-$/g, '');
  }
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('News', newsSchema);
