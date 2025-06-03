// routes/episodes.js
const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Episode = require('../models/Episode');
const Character = require('../models/Character');
const { auth, adminAuth } = require('../middleware/auth');

const router = express.Router();

// Validation rules
const episodeValidation = [
  body('season').isInt({ min: 1 }),
  body('episodeNumber').isInt({ min: 1 }),
  body('title').notEmpty().trim(),
  body('summary').notEmpty(),
  body('airDate').isISO8601()
];

// @route   GET /api/episodes
// @desc    Obtenir tous les épisodes avec pagination et filtres
// @access  Public
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      season,
      search,
      sortBy = 'season',
      sortOrder = 'asc'
    } = req.query;

    const filter = {};
    if (season) filter.season = parseInt(season);
    if (search) {
      filter.$text = { $search: search };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    if (sortBy !== 'episodeNumber') {
      sort.episodeNumber = 1;
    }

    const episodes = await Episode.find(filter)
      .populate('mainCharacters', 'name nameFr imageUrl')
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Episode.countDocuments(filter);

    res.json({
      success: true,
      data: episodes,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Erreur récupération épisodes:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des épisodes'
    });
  }
});

// @route   GET /api/episodes/seasons
// @desc    Obtenir la liste des saisons disponibles
// @access  Public
router.get('/seasons', async (req, res) => {
  try {
    const seasons = await Episode.distinct('season').sort();
    
    const seasonsWithCounts = await Promise.all(
      seasons.map(async (season) => {
        const count = await Episode.countDocuments({ season });
        return { season, episodeCount: count };
      })
    );

    res.json({
      success: true,
      data: seasonsWithCounts
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des saisons'
    });
  }
});

// @route   GET /api/episodes/:id
// @desc    Obtenir un épisode par ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const episode = await Episode.findById(req.params.id)
      .populate('mainCharacters', 'name nameFr imageUrl job family');

    if (!episode) {
      return res.status(404).json({
        success: false,
        message: 'Épisode non trouvé'
      });
    }

    episode.views += 1;
    await episode.save();

    res.json({
      success: true,
      data: episode
    });
  } catch (error) {
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'ID d\'épisode invalide'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération de l\'épisode'
    });
  }
});

// @route   GET /api/episodes/season/:season
// @desc    Obtenir tous les épisodes d'une saison
// @access  Public
router.get('/season/:season', async (req, res) => {
  try {
    const season = parseInt(req.params.season);
    
    if (!season || season < 1) {
      return res.status(400).json({
        success: false,
        message: 'Numéro de saison invalide'
      });
    }

    const episodes = await Episode.find({ season })
      .populate('mainCharacters', 'name nameFr imageUrl')
      .sort({ episodeNumber: 1 });

    res.json({
      success: true,
      data: episodes,
      season,
      count: episodes.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des épisodes de la saison'
    });
  }
});

// @route   POST /api/episodes
// @desc    Créer un nouvel épisode
// @access  Private (Admin only)
router.post('/', adminAuth, episodeValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Données invalides',
        errors: errors.array()
      });
    }

    const existingEpisode = await Episode.findOne({
      season: req.body.season,
      episodeNumber: req.body.episodeNumber
    });

    if (existingEpisode) {
      return res.status(400).json({
        success: false,
        message: 'Un épisode avec ce numéro existe déjà pour cette saison'
      });
    }

    const episode = new Episode(req.body);
    await episode.save();

    await episode.populate('mainCharacters', 'name nameFr imageUrl');

    res.status(201).json({
      success: true,
      message: 'Épisode créé avec succès',
      data: episode
    });
  } catch (error) {
    console.error('Erreur création épisode:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création de l\'épisode'
    });
  }
});

// @route   PUT /api/episodes/:id
// @desc    Mettre à jour un épisode
// @access  Private (Admin only)
router.put('/:id', adminAuth, async (req, res) => {
  try {
    const episode = await Episode.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: new Date() },
      { new: true, runValidators: true }
    ).populate('mainCharacters', 'name nameFr imageUrl');

    if (!episode) {
      return res.status(404).json({
        success: false,
        message: 'Épisode non trouvé'
      });
    }

    res.json({
      success: true,
      message: 'Épisode mis à jour avec succès',
      data: episode
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour de l\'épisode'
    });
  }
});

// @route   DELETE /api/episodes/:id
// @desc    Supprimer un épisode
// @access  Private (Admin only)
router.delete('/:id', adminAuth, async (req, res) => {
  try {
    const episode = await Episode.findByIdAndDelete(req.params.id);

    if (!episode) {
      return res.status(404).json({
        success: false,
        message: 'Épisode non trouvé'
      });
    }

    res.json({
      success: true,
      message: 'Épisode supprimé avec succès'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression de l\'épisode'
    });
  }
});
    
router.put('/:id/rating', adminAuth, async (req, res) => {
  try {
    const { imdb, audience, critics } = req.body;
    
    const updateData = {};
    if (imdb !== undefined) updateData['ratings.imdb'] = imdb;
    if (audience !== undefined) updateData['ratings.audience'] = audience;
    if (critics !== undefined) updateData['ratings.critics'] = critics;

    const episode = await Episode.findByIdAndUpdate(
      req.params.id,
      { $set: updateData },
      { new: true }
    );

    if (!episode) {
      return res.status(404).json({
        success: false,
        message: 'Épisode non trouvé'
      });
    }

    res.json({
      success: true,
      message: 'Notes mises à jour avec succès',
      data: episode.ratings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour des notes'
    });
  }
});

module.exports = router;