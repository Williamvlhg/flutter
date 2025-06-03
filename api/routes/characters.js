const express = require('express');
const { body, validationResult } = require('express-validator');
const Character = require('../models/Character');
const Episode = require('../models/Episode');
const { auth, adminAuth } = require('../middleware/auth');

const router = express.Router();

// Validation rules
const characterValidation = [
  body('name').notEmpty().trim().withMessage('Le nom est requis'),
  body('description').notEmpty().withMessage('La description est requise'),
  body('family').optional().trim(),
  body('job').optional().trim(),
  body('isMajor').optional().isBoolean(),
  body('age').optional().isInt({ min: 0, max: 150 }),
  body('catchphrases').optional().isArray(),
  body('personality').optional().isArray(),
  body('hobbies').optional().isArray()
];

// @route   GET /api/characters
// @desc    Obtenir tous les personnages avec pagination et filtres
// @access  Public
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      search,
      isMajor,
      family,
      job,
      status,
      sortBy = 'name',
      sortOrder = 'asc'
    } = req.query;

    const filter = {};
    
    if (search) {
      filter.$text = { $search: search };
    }
    
    if (isMajor !== undefined) {
      filter.isMajor = isMajor === 'true';
    }
    
    if (family) {
      filter.family = new RegExp(family, 'i');
    }
    
    if (job) {
      filter.job = new RegExp(job, 'i');
    }
    
    if (status) {
      filter.status = status;
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    const characters = await Character.find(filter)
      .populate('relatives.characterId', 'name nameFr imageUrl')
      .populate('episodes', 'season episodeNumber title titleFr', null, { limit: 5 })
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Character.countDocuments(filter);

    res.json({
      success: true,
      data: characters,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Erreur récupération personnages:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des personnages'
    });
  }
});

// @route   GET /api/characters/major
// @desc    Obtenir uniquement les personnages principaux
// @access  Public
router.get('/major', async (req, res) => {
  try {
    const characters = await Character.find({ isMajor: true })
      .populate('relatives.characterId', 'name nameFr imageUrl')
      .sort({ popularityScore: -1, name: 1 });

    res.json({
      success: true,
      data: characters
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des personnages principaux'
    });
  }
});

// @route   GET /api/characters/families
// @desc    Obtenir les personnages groupés par famille
// @access  Public
router.get('/families', async (req, res) => {
  try {
    const families = await Character.aggregate([
      {
        $match: {
          family: { $ne: null, $ne: '' }
        }
      },
      {
        $group: {
          _id: '$family',
          members: {
            $push: {
              _id: '$_id',
              name: '$name',
              nameFr: '$nameFr',
              imageUrl: '$imageUrl',
              job: '$job',
              isMajor: '$isMajor',
              status: '$status'
            }
          },
          count: { $sum: 1 },
          majorMembers: {
            $sum: { $cond: ['$isMajor', 1, 0] }
          }
        }
      },
      {
        $sort: { count: -1 }
      }
    ]);

    res.json({
      success: true,
      data: families
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des familles'
    });
  }
});

// @route   GET /api/characters/jobs
// @desc    Obtenir les personnages groupés par métier
// @access  Public
router.get('/jobs', async (req, res) => {
  try {
    const jobs = await Character.aggregate([
      {
        $match: {
          job: { $ne: null, $ne: '' }
        }
      },
      {
        $group: {
          _id: '$job',
          characters: {
            $push: {
              _id: '$_id',
              name: '$name',
              nameFr: '$nameFr',
              imageUrl: '$imageUrl',
              isMajor: '$isMajor'
            }
          },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { count: -1 }
      },
      {
        $limit: 20
      }
    ]);

    res.json({
      success: true,
      data: jobs
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des métiers'
    });
  }
});

// @route   GET /api/characters/:id
// @desc    Obtenir un personnage par ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const character = await Character.findById(req.params.id)
      .populate('episodes', 'season episodeNumber title titleFr airDate imageUrl')
      .populate('relatives.characterId', 'name nameFr imageUrl job family');

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Personnage non trouvé'
      });
    }

    res.json({
      success: true,
      data: character
    });
  } catch (error) {
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'ID de personnage invalide'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération du personnage'
    });
  }
});

// @route   GET /api/characters/:id/episodes
// @desc    Obtenir les épisodes d'un personnage avec pagination
// @access  Public
router.get('/:id/episodes', async (req, res) => {
  try {
    const { page = 1, limit = 20, season } = req.query;
    
    const character = await Character.findById(req.params.id);
    
    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Personnage non trouvé'
      });
    }

    const filter = {
      _id: { $in: character.episodes }
    };

    if (season) {
      filter.season = parseInt(season);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const episodes = await Episode.find(filter)
      .sort({ season: 1, episodeNumber: 1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Episode.countDocuments(filter);

    res.json({
      success: true,
      data: episodes,
      character: {
        _id: character._id,
        name: character.name,
        nameFr: character.nameFr,
        imageUrl: character.imageUrl
      },
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des épisodes du personnage'
    });
  }
});

// @route   GET /api/characters/:id/relatives
// @desc    Obtenir les membres de la famille d'un personnage
// @access  Public
router.get('/:id/relatives', async (req, res) => {
  try {
    const character = await Character.findById(req.params.id)
      .populate('relatives.characterId', 'name nameFr imageUrl job status');

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Personnage non trouvé'
      });
    }

    const familyMembers = await Character.find({
      family: character.family,
      _id: { $ne: character._id }
    }).select('name nameFr imageUrl job status');

    res.json({
      success: true,
      data: {
        directRelatives: character.relatives,
        familyMembers: familyMembers,
        family: character.family
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des proches'
    });
  }
});

// @route   POST /api/characters
// @desc    Créer un nouveau personnage
// @access  Private (Admin only)
router.post('/', adminAuth, characterValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Données invalides',
        errors: errors.array()
      });
    }

    const existingCharacter = await Character.findOne({
      $or: [
        { name: req.body.name },
        { nameFr: req.body.nameFr }
      ]
    });

    if (existingCharacter) {
      return res.status(400).json({
        success: false,
        message: 'Un personnage avec ce nom existe déjà'
      });
    }

    const character = new Character(req.body);
    await character.save();

    res.status(201).json({
      success: true,
      message: 'Personnage créé avec succès',
      data: character
    });
  } catch (error) {
    console.error('Erreur création personnage:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création du personnage'
    });
  }
});

// @route   PUT /api/characters/:id
// @desc    Mettre à jour un personnage
// @access  Private (Admin only)
router.put('/:id', adminAuth, async (req, res) => {
  try {
    const character = await Character.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: new Date() },
      { new: true, runValidators: true }
    )
    .populate('episodes', 'season episodeNumber title titleFr')
    .populate('relatives.characterId', 'name nameFr imageUrl');

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Personnage non trouvé'
      });
    }

    res.json({
      success: true,
      message: 'Personnage mis à jour avec succès',
      data: character
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour du personnage'
    });
  }
});

// @route   DELETE /api/characters/:id
// @desc    Supprimer un personnage
// @access  Private (Admin only)
router.delete('/:id', adminAuth, async (req, res) => {
  try {
    const character = await Character.findByIdAndDelete(req.params.id);

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Personnage non trouvé'
      });
    }

    await Episode.updateMany(
      { mainCharacters: req.params.id },
      { $pull: { mainCharacters: req.params.id } }
    );

    res.json({
      success: true,
      message: 'Personnage supprimé avec succès'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression du personnage'
    });
  }
});

// @route   POST /api/characters/:id/episodes
// @desc    Associer un personnage à des épisodes
// @access  Private (Admin only)
router.post('/:id/episodes', adminAuth, async (req, res) => {
  try {
    const { episodeIds } = req.body;

    if (!Array.isArray(episodeIds)) {
      return res.status(400).json({
        success: false,
        message: 'Un tableau d\'IDs d\'épisodes est requis'
      });
    }

    const character = await Character.findById(req.params.id);
    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Personnage non trouvé'
      });
    }

    const episodes = await Episode.find({ _id: { $in: episodeIds } });
    if (episodes.length !== episodeIds.length) {
      return res.status(400).json({
        success: false,
        message: 'Certains épisodes n\'existent pas'
      });
    }

    const newEpisodes = episodeIds.filter(id => !character.episodes.includes(id));
    character.episodes.push(...newEpisodes);
    character.episodeCount = character.episodes.length;
    await character.save();

    res.json({
      success: true,
      message: `${newEpisodes.length} épisode(s) associé(s) au personnage`,
      data: character.episodes
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'association des épisodes'
    });
  }
});

// @route   DELETE /api/characters/:id/episodes/:episodeId
// @desc    Dissocier un épisode d'un personnage
// @access  Private (Admin only)
router.delete('/:id/episodes/:episodeId', adminAuth, async (req, res) => {
  try {
    const character = await Character.findByIdAndUpdate(
      req.params.id,
      {
        $pull: { episodes: req.params.episodeId },
        $inc: { episodeCount: -1 }
      },
      { new: true }
    );

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Personnage non trouvé'
      });
    }

    res.json({
      success: true,
      message: 'Épisode dissocié du personnage',
      data: character.episodes
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la dissociation de l\'épisode'
    });
  }
});

// @route   PUT /api/characters/:id/popularity
// @desc    Mettre à jour le score de popularité
// @access  Private (Admin only)
router.put('/:id/popularity', adminAuth, async (req, res) => {
  try {
    const { score } = req.body;

    if (typeof score !== 'number' || score < 0 || score > 100) {
      return res.status(400).json({
        success: false,
        message: 'Le score doit être un nombre entre 0 et 100'
      });
    }

    const character = await Character.findByIdAndUpdate(
      req.params.id,
      { popularityScore: score },
      { new: true }
    );

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Personnage non trouvé'
      });
    }

    res.json({
      success: true,
      message: 'Score de popularité mis à jour',
      data: { popularityScore: character.popularityScore }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour du score'
    });
  }
});

// @route   GET /api/characters/search/advanced
// @desc    Recherche avancée de personnages
// @access  Public
router.get('/search/advanced', async (req, res) => {
  try {
    const {
      query,
      family,
      job,
      isMajor,
      status,
      minPopularity,
      hasEpisodes,
      ageRange
    } = req.query;

    const filter = {};

    if (query) {
      filter.$text = { $search: query };
    }

    if (family) {
      filter.family = new RegExp(family, 'i');
    }

    if (job) {
      filter.job = new RegExp(job, 'i');
    }

    if (isMajor !== undefined) {
      filter.isMajor = isMajor === 'true';
    }

    if (status) {
      filter.status = status;
    }

    if (minPopularity) {
      filter.popularityScore = { $gte: parseFloat(minPopularity) };
    }

    if (hasEpisodes === 'true') {
      filter.episodes = { $exists: true, $not: { $size: 0 } };
    }

    if (ageRange) {
      const [min, max] = ageRange.split('-').map(Number);
      if (min && max) {
        filter.age = { $gte: min, $lte: max };
      }
    }

    const characters = await Character.find(filter)
      .populate('relatives.characterId', 'name nameFr imageUrl')
      .sort({ popularityScore: -1, name: 1 })
      .limit(50);

    res.json({
      success: true,
      data: characters,
      count: characters.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la recherche avancée'
    });
  }
});

// @route   GET /api/characters/stats/overview
// @desc    Statistiques générales des personnages
// @access  Public
router.get('/stats/overview', async (req, res) => {
  try {
    const [
      totalCharacters,
      majorCharacters,
      familyStats,
      jobStats,
      statusStats
    ] = await Promise.all([
      Character.countDocuments(),
      Character.countDocuments({ isMajor: true }),
      Character.aggregate([
        { $match: { family: { $ne: null, $ne: '' } } },
        { $group: { _id: '$family', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 5 }
      ]),
      Character.aggregate([
        { $match: { job: { $ne: null, $ne: '' } } },
        { $group: { _id: '$job', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 5 }
      ]),
      Character.aggregate([
        { $group: { _id: '$status', count: { $sum: 1 } } }
      ])
    ]);

    res.json({
      success: true,
      data: {
        total: totalCharacters,
        major: majorCharacters,
        recurring: totalCharacters - majorCharacters,
        topFamilies: familyStats,
        topJobs: jobStats,
        statusDistribution: statusStats
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques'
    });
  }
});

module.exports = router;