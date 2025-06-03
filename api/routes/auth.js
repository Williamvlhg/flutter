const express = require('express');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Validation rules
const registerValidation = [
  body('email').isEmail().normalizeEmail(),
  body('username').isLength({ min: 3, max: 30 }).trim(),
  body('password').isLength({ min: 6 })
];

const loginValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').exists()
];

// @route   POST /api/auth/register
// @desc    Inscription utilisateur
// @access  Public
router.post('/register', registerValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Données invalides',
        errors: errors.array()
      });
    }

    const { email, username, password } = req.body;

    const existingUser = await User.findOne({
      $or: [{ email }, { username }]
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Un utilisateur avec cet email ou nom d\'utilisateur existe déjà'
      });
    }

    const user = new User({ email, username, password });
    await user.save();

    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || 'simpsons_secret_key',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      success: true,
      message: 'Utilisateur créé avec succès',
      token,
      user: user.toPublicJSON()
    });
  } catch (error) {
    console.error('Erreur inscription:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'inscription'
    });
  }
});

// @route   POST /api/auth/login
// @desc    Connexion utilisateur
// @access  Public
router.post('/login', loginValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Données invalides',
        errors: errors.array()
      });
    }

    const { email, password } = req.body;
    
    console.log('🔍 Tentative de connexion:', email);

    const user = await User.findOne({ email });
    console.log('👤 Utilisateur trouvé:', user ? 'Oui' : 'Non');
    
    if (!user) {
      console.log('❌ Utilisateur non trouvé pour:', email);
      return res.status(400).json({
        success: false,
        message: 'Identifiants invalides'
      });
    }

    console.log('✅ IsActive:', user.isActive);
    if (user.isActive === false) {
      console.log('❌ Compte désactivé pour:', email);
      return res.status(400).json({
        success: false,
        message: 'Compte désactivé'
      });
    }

    console.log('🔑 Vérification du mot de passe...');
    const isMatch = await user.comparePassword(password);
    console.log('🔐 Mot de passe valide:', isMatch);
    
    if (!isMatch) {
      console.log('❌ Mot de passe incorrect pour:', email);
      return res.status(400).json({
        success: false,
        message: 'Identifiants invalides'
      });
    }

    user.lastLogin = new Date();
    await user.save();

    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || 'simpsons_secret_key',
      { expiresIn: '7d' }
    );

    console.log('✅ Connexion réussie pour:', user.email);

    res.json({
      success: true,
      message: 'Connexion réussie',
      token,
      user: user.toPublicJSON()
    });
  } catch (error) {
    console.error('❌ Erreur connexion:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la connexion'
    });
  }
});
// @route   GET /api/auth/me
// @desc    Obtenir les infos de l'utilisateur connecté
// @access  Private
router.get('/me', auth, async (req, res) => {
  res.json({
    success: true,
    user: req.user.toPublicJSON()
  });
});

// @route   PUT /api/auth/profile
// @desc    Mettre à jour le profil
// @access  Private
router.put('/profile', auth, async (req, res) => {
  try {
    const { firstName, lastName, bio } = req.body;
    
    req.user.profile = {
      ...req.user.profile,
      firstName,
      lastName,
      bio
    };
    
    await req.user.save();
    
    res.json({
      success: true,
      message: 'Profil mis à jour',
      user: req.user.toPublicJSON()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour du profil'
    });
  }
});

module.exports = router;