const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

mongoose.connect('mongodb+srv://zaki:zaki@cluster0.r32uulx.mongodb.net/simpsons_park?retryWrites=true&w=majority&appName=Cluster0')
.then(() => console.log('📦 Connecté à MongoDB Atlas'))
.catch(err => console.error('❌ Erreur de connexion MongoDB:', err));

const episodeRoutes = require('./routes/episodes');
const characterRoutes = require('./routes/characters');
const newsRoutes = require('./routes/news');
const statsRoutes = require('./routes/stats');
const uploadRoutes = require('./routes/upload');

app.use('/api/auth', authRoutes);
app.use('/api/episodes', episodeRoutes);
app.use('/api/characters', characterRoutes);
app.use('/api/news', newsRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/upload', uploadRoutes);

app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    cors: 'Enabled for all origins'
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'API Simpsons Park',
    version: '1.0.0',
    cors: 'Open'
  });
});

app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée'
  });
});

app.use((err, req, res, next) => {
  console.error('❌ Erreur:', err.message);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Erreur interne du serveur'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
  console.log(`🔗 API disponible sur: http://localhost:${PORT}/api`);
});

module.exports = app;