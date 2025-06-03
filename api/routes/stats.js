const express = require('express');
const Episode = require('../models/Episode');
const Character = require('../models/Character');
const News = require('../models/News');
const User = require('../models/User');
const { adminAuth } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/stats/overview
// @desc    Obtenir les statistiques générales
// @access  Public
router.get('/overview', async (req, res) => {
  try {
    const [
      totalEpisodes,
      totalSeasons,
      totalCharacters,
      majorCharacters,
      totalNews,
      totalUsers
    ] = await Promise.all([
      Episode.countDocuments(),
      Episode.distinct('season').then(seasons => seasons.length),
      Character.countDocuments(),
      Character.countDocuments({ isMajor: true }),
      News.countDocuments({ status: 'published' }),
      User.countDocuments({ isActive: true })
    ]);

    res.json({
      success: true,
      data: {
        episodes: {
          total: totalEpisodes,
          seasons: totalSeasons
        },
        characters: {
          total: totalCharacters,
          major: majorCharacters
        },
        news: totalNews,
        users: totalUsers
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques'
    });
  }
});

// @route   GET /api/stats/episodes
// @desc    Statistiques détaillées des épisodes
// @access  Public
router.get('/episodes', async (req, res) => {
  try {
    const [
      episodesBySeasonStats,
      mostViewedEpisodes,
      recentEpisodes,
      episodesByYear
    ] = await Promise.all([
      // Episodes par saison
      Episode.aggregate([
        {
          $group: {
            _id: '$season',
            count: { $sum: 1 },
            avgRating: { $avg: '$ratings.imdb' },
            totalViews: { $sum: '$views' }
          }
        },
        { $sort: { _id: 1 } }
      ]),
      
      // Episodes les plus vus
      Episode.find()
        .sort({ views: -1 })
        .limit(10)
        .select('title titleFr season episodeNumber views'),
      
      // Episodes récents
      Episode.find()
        .sort({ airDate: -1 })
        .limit(5)
        .select('title titleFr season episodeNumber airDate'),
      
      // Episodes par année
      Episode.aggregate([
        {
          $group: {
            _id: { $year: '$airDate' },
            count: { $sum: 1 }
          }
        },
        { $sort: { _id: 1 } }
      ])
    ]);

    res.json({
      success: true,
      data: {
        episodesBySeason: episodesBySeasonStats,
        mostViewed: mostViewedEpisodes,
        recent: recentEpisodes,
        episodesByYear
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques d\'épisodes'
    });
  }
});

// @route   GET /api/stats/characters
// @desc    Statistiques des personnages
// @access  Public
router.get('/characters', async (req, res) => {
  try {
    const [
      charactersByFamily,
      mostPopularCharacters,
      charactersByJob,
      characterAppearances
    ] = await Promise.all([
      // Personnages par famille
      Character.aggregate([
        {
          $match: { family: { $ne: null, $ne: '' } }
        },
        {
          $group: {
            _id: '$family',
            count: { $sum: 1 },
            members: {
              $push: {
                name: '$name',
                nameFr: '$nameFr',
                isMajor: '$isMajor'
              }
            }
          }
        },
        { $sort: { count: -1 } }
      ]),
      
      // Personnages les plus populaires
      Character.find()
        .sort({ popularityScore: -1, episodeCount: -1 })
        .limit(10)
        .select('name nameFr popularityScore episodeCount isMajor'),
      
      // Personnages par métier
      Character.aggregate([
        {
          $match: { job: { $ne: null, $ne: '' } }
        },
        {
          $group: {
            _id: '$job',
            count: { $sum: 1 }
          }
        },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]),
      
      // Apparitions par personnage
      Character.aggregate([
        {
          $project: {
            name: 1,
            nameFr: 1,
            episodeCount: { $size: '$episodes' }
          }
        },
        { $sort: { episodeCount: -1 } },
        { $limit: 15 }
      ])
    ]);

    res.json({
      success: true,
      data: {
        charactersByFamily,
        mostPopular: mostPopularCharacters,
        charactersByJob,
        characterAppearances
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques de personnages'
    });
  }
});

// @route   GET /api/stats/admin
// @desc    Statistiques pour l'administration
// @access  Private (Admin only)
router.get('/admin', adminAuth, async (req, res) => {
  try {
    const [
      userStats,
      contentStats,
      activityStats,
      popularContent
    ] = await Promise.all([
      // Statistiques utilisateurs
      User.aggregate([
        {
          $group: {
            _id: null,
            totalUsers: { $sum: 1 },
            activeUsers: {
              $sum: {
                $cond: [{ $eq: ['$isActive', true] }, 1, 0]
              }
            },
            admins: {
              $sum: {
                $cond: [{ $eq: ['$isAdmin', true] }, 1, 0]
              }
            },
            recentUsers: {
              $sum: {
                $cond: [
                  { $gte: ['$createdAt', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)] },
                  1,
                  0
                ]
              }
            }
          }
        }
      ]),
      
      // Statistiques de contenu
      {
        episodes: await Episode.countDocuments(),
        characters: await Character.countDocuments(),
        publishedNews: await News.countDocuments({ status: 'published' }),
        draftNews: await News.countDocuments({ status: 'draft' }),
        featuredNews: await News.countDocuments({ isFeatured: true })
      },
      
      // Activité récente
      {
        recentEpisodes: await Episode.find()
          .sort({ createdAt: -1 })
          .limit(5)
          .select('title season episodeNumber createdAt'),
        recentCharacters: await Character.find()
          .sort({ createdAt: -1 })
          .limit(5)
          .select('name nameFr createdAt'),
        recentNews: await News.find()
          .sort({ createdAt: -1 })
          .limit(5)
          .select('title authorName createdAt status')
          .populate('author', 'username')
      },
      
      // Contenu populaire
      {
        mostViewedEpisodes: await Episode.find()
          .sort({ views: -1 })
          .limit(5)
          .select('title season episodeNumber views'),
        mostViewedNews: await News.find({ status: 'published' })
          .sort({ views: -1 })
          .limit(5)
          .select('title views publishedAt'),
        mostLikedNews: await News.find({ status: 'published' })
          .sort({ likes: -1 })
          .limit(5)
          .select('title likes publishedAt')
      }
    ]);

    res.json({
      success: true,
      data: {
        users: userStats[0] || {
          totalUsers: 0,
          activeUsers: 0,
          admins: 0,
          recentUsers: 0
        },
        content: contentStats,
        activity: activityStats,
        popular: popularContent
      }
    });
  } catch (error) {
    console.error('Erreur statistiques admin:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques d\'administration'
    });
  }
});

module.exports = router;