const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { adminAuth } = require('../middleware/auth');

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, '../uploads/');
    
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + extension);
  }
});

const imageFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Seules les images sont autorisées (JPEG, JPG, PNG, GIF, WebP)'));
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 
  },
  fileFilter: imageFilter
});

// @route   POST /api/upload/image
// @desc    Upload d'une image
// @access  Private (Admin only)
router.post('/image', adminAuth, upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Aucun fichier fourni'
      });
    }

    const fileUrl = `/uploads/${req.file.filename}`;
    
    res.json({
      success: true,
      message: 'Image uploadée avec succès',
      data: {
        filename: req.file.filename,
        originalName: req.file.originalname,
        size: req.file.size,
        url: fileUrl,
        fullUrl: `${req.protocol}://${req.get('host')}${fileUrl}`
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'upload de l\'image'
    });
  }
});

// @route   POST /api/upload/images
// @desc    Upload multiple d'images
// @access  Private (Admin only)
router.post('/images', adminAuth, upload.array('images', 10), (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Aucun fichier fourni'
      });
    }

    const uploadedFiles = req.files.map(file => ({
      filename: file.filename,
      originalName: file.originalname,
      size: file.size,
      url: `/uploads/${file.filename}`,
      fullUrl: `${req.protocol}://${req.get('host')}/uploads/${file.filename}`
    }));
    
    res.json({
      success: true,
      message: `${uploadedFiles.length} image(s) uploadée(s) avec succès`,
      data: uploadedFiles
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'upload des images'
    });
  }
});

// @route   DELETE /api/upload/:filename
// @desc    Supprimer une image
// @access  Private (Admin only)
router.delete('/:filename', adminAuth, (req, res) => {
  try {
    const filename = req.params.filename;
    const filePath = path.join(__dirname, '../uploads/', filename);
    
    // Vérifier si le fichier existe
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        message: 'Fichier non trouvé'
      });
    }
    
    // Supprimer le fichier
    fs.unlinkSync(filePath);
    
    res.json({
      success: true,
      message: 'Fichier supprimé avec succès'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression du fichier'
    });
  }
});

// Gestion des erreurs multer
router.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'Fichier trop volumineux (maximum 5MB)'
      });
    }
  }
  
  if (error.message.includes('Seules les images')) {
    return res.status(400).json({
      success: false,
      message: error.message
    });
  }
  
  next(error);
});

module.exports = router;