const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
require('dotenv').config();

const User = require('../models/User');
const Episode = require('../models/Episode');
const Character = require('../models/Character');
const News = require('../models/News');

// Fonction pour générer un slug à partir d'un titre
const generateSlug = (title) => {
  return title
    .toLowerCase()
    .normalize('NFD') // Décomposer les caractères accentués
    .replace(/[\u0300-\u036f]/g, '') // Supprimer les accents
    .replace(/[^a-z0-9\s-]/g, '') // Garder seulement lettres, chiffres, espaces et tirets
    .trim()
    .replace(/\s+/g, '-') // Remplacer espaces par des tirets
    .replace(/-+/g, '-') // Éviter les tirets multiples
    .substring(0, 100); // Limiter la longueur
};

const seedDatabase = async () => {
  try {
    // Connexion à MongoDB Atlas
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://zaki:zaki@cluster0.r32uulx.mongodb.net/simpsons_park?retryWrites=true&w=majority&appName=Cluster0');
    console.log('📦 Connecté à MongoDB Atlas pour le seeding');

    // Nettoyer la base de données
    await Promise.all([
      User.deleteMany({}),
      Episode.deleteMany({}),
      Character.deleteMany({}),
      News.deleteMany({})
    ]);
    console.log('🧹 Base de données nettoyée');

    // CORRECTION: Supprimer l'index problématique s'il existe
    try {
      await News.collection.dropIndex('slug_1');
      console.log('🗑️ Index slug supprimé');
    } catch (error) {
      console.log('ℹ️ Index slug n\'existait pas ou déjà supprimé');
    }

    // Créer un utilisateur admin avec mot de passe hashé
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash('admin123', saltRounds);
    
    const adminUser = new User({
      email: 'admin@simpsonspark.com',
      username: 'admin',
      password: hashedPassword,
      isAdmin: true,
      isActive: true,
      profile: {
        firstName: 'Super',
        lastName: 'Admin'
      },
      isVerified: true,
      createdAt: new Date(),
      updatedAt: new Date()
    });
    
    await adminUser.save();
    console.log('👤 Utilisateur admin créé avec mot de passe sécurisé');

    // Créer un utilisateur de test normal
    const testUserPassword = await bcrypt.hash('test123', saltRounds);
    const testUser = new User({
      email: 'test@simpsonspark.com',
      username: 'testuser',
      password: testUserPassword,
      isAdmin: false,
      profile: {
        firstName: 'Test',
        lastName: 'User'
      },
      isVerified: true
    });
    
    await testUser.save();
    console.log('👤 Utilisateur de test créé');

    // Créer des personnages principaux
    const characters = [
      {
        name: 'Homer Simpson',
        nameFr: 'Homer Simpson',
        description: 'Père de famille paresseux et amateur de bière, travaille à la centrale nucléaire de Springfield.',
        family: 'Simpson',
        job: 'Inspecteur de sécurité nucléaire',
        isMajor: true,
        catchphrases: ['D\'oh!', 'Mmm... bière', 'Woohoo!'],
        voiceActor: {
          english: 'Dan Castellaneta',
          french: 'Philippe Peythieu'
        }
      },
      {
        name: 'Marge Simpson',
        nameFr: 'Marge Simpson',
        description: 'Mère de famille aimante et patiente, épouse d\'Homer et mère de Bart, Lisa et Maggie.',
        family: 'Simpson',
        job: 'Femme au foyer',
        isMajor: true,
        catchphrases: ['Mmm-hmm', 'Homer!'],
        voiceActor: {
          english: 'Julie Kavner',
          french: 'Véronique Augereau'
        }
      },
      {
        name: 'Bart Simpson',
        nameFr: 'Bart Simpson',
        description: 'Fils aîné de la famille Simpson, espiègle et rebelle.',
        family: 'Simpson',
        job: 'Écolier',
        age: 10,
        isMajor: true,
        catchphrases: ['Eat my shorts!', 'Don\'t have a cow, man!'],
        voiceActor: {
          english: 'Nancy Cartwright',
          french: 'Joëlle Guigui'
        }
      },
      {
        name: 'Lisa Simpson',
        nameFr: 'Lisa Simpson',
        description: 'Fille cadette très intelligente, joue du saxophone et défend ses convictions.',
        family: 'Simpson',
        job: 'Écolière',
        age: 8,
        isMajor: true,
        voiceActor: {
          english: 'Yeardley Smith',
          french: 'Aurélia Bruno'
        }
      },
      {
        name: 'Maggie Simpson',
        nameFr: 'Maggie Simpson',
        description: 'Bébé de la famille Simpson, toujours avec sa tétine.',
        family: 'Simpson',
        job: 'Bébé',
        age: 1,
        isMajor: true,
        voiceActor: {
          english: 'Diverses',
          french: 'Diverses'
        }
      },
      {
        name: 'Ned Flanders',
        nameFr: 'Ned Flanders',
        description: 'Voisin pieux et optimiste des Simpson.',
        family: 'Flanders',
        job: 'Propriétaire du Leftorium',
        isMajor: true,
        catchphrases: ['Okily dokily!', 'Diddly'],
        voiceActor: {
          english: 'Harry Shearer',
          french: 'Pierre Laurent'
        }
      },
      {
        name: 'Mr. Burns',
        nameFr: 'M. Burns',
        description: 'Propriétaire milliardaire et patron de la centrale nucléaire de Springfield.',
        family: 'Burns',
        job: 'PDG de la centrale nucléaire',
        isMajor: true,
        catchphrases: ['Excellent!', 'Release the hounds!'],
        voiceActor: {
          english: 'Harry Shearer',
          french: 'Alain Dorval'
        }
      },
      {
        name: 'Waylon Smithers',
        nameFr: 'Waylon Smithers',
        description: 'Assistant dévoué et fidèle de M. Burns.',
        family: 'Smithers',
        job: 'Assistant personnel',
        isMajor: false,
        voiceActor: {
          english: 'Harry Shearer',
          french: 'Didier Colfs'
        }
      }
    ];

    const createdCharacters = await Character.insertMany(characters);
    console.log(`👥 ${createdCharacters.length} personnages créés`);

    // Créer des épisodes de test
    const episodes = [
      {
        season: 1,
        episodeNumber: 1,
        title: 'Simpsons Roasting on an Open Fire',
        titleFr: 'Noël blanc',
        summary: 'Premier épisode des Simpson où Homer découvre qu\'il ne recevra pas de prime de Noël.',
        airDate: new Date('1989-12-17'),
        duration: 22,
        characters: ['Homer Simpson', 'Marge Simpson', 'Bart Simpson', 'Lisa Simpson', 'Maggie Simpson'],
        mainCharacters: createdCharacters.slice(0, 5).map(c => c._id),
        views: 1250000,
        tags: ['premier épisode', 'noël', 'famille'],
        isSpecial: true,
        trivia: [
          {
            fact: 'Premier épisode officiel des Simpson',
            category: 'Production'
          }
        ]
      },
      {
        season: 1,
        episodeNumber: 2,
        title: 'Bart the Genius',
        titleFr: 'Bart le génie',
        summary: 'Bart triche à un test et est considéré comme un génie.',
        airDate: new Date('1990-01-14'),
        duration: 22,
        characters: ['Homer Simpson', 'Marge Simpson', 'Bart Simpson', 'Lisa Simpson'],
        mainCharacters: [createdCharacters[0]._id, createdCharacters[1]._id, createdCharacters[2]._id, createdCharacters[3]._id],
        views: 890000,
        tags: ['école', 'génie', 'bart']
      },
      {
        season: 32,
        episodeNumber: 1,
        title: 'Undercover Burns',
        titleFr: 'Burns incognito',
        summary: 'M. Burns se fait passer pour un employé ordinaire.',
        airDate: new Date('2020-09-27'),
        duration: 22,
        characters: ['Homer Simpson', 'Mr. Burns'],
        mainCharacters: [createdCharacters[0]._id, createdCharacters[6]._id],
        views: 645000,
        tags: ['burns', 'incognito', 'travail']
      },
      {
        season: 2,
        episodeNumber: 1,
        title: 'Bart Gets an F',
        titleFr: 'Bart a une mauvaise note',
        summary: 'Bart risque de redoubler sa classe s\'il n\'améliore pas ses notes.',
        airDate: new Date('1990-10-11'),
        duration: 22,
        characters: ['Bart Simpson', 'Homer Simpson', 'Marge Simpson', 'Lisa Simpson'],
        mainCharacters: [createdCharacters[2]._id, createdCharacters[0]._id, createdCharacters[1]._id],
        views: 720000,
        tags: ['école', 'notes', 'bart']
      }
    ];

    const createdEpisodes = await Episode.insertMany(episodes);
    console.log(`📺 ${createdEpisodes.length} épisodes créés`);

    // Mettre à jour les personnages avec leurs épisodes
    for (const character of createdCharacters) {
      const characterEpisodes = createdEpisodes.filter(ep => 
        ep.characters.includes(character.name) || ep.characters.includes(character.nameFr)
      );
      
      character.episodes = characterEpisodes.map(ep => ep._id);
      character.episodeCount = characterEpisodes.length;
      await character.save();
    }

    // CORRECTION: Créer des actualités avec slugs uniques
    const newsItems = [
      {
        title: 'Les Simpson renouvelés pour 4 saisons supplémentaires',
        slug: generateSlug('Les Simpson renouvelés pour 4 saisons supplémentaires'),
        content: 'Fox a officiellement renouvelé Les Simpson pour quatre saisons supplémentaires, garantissant la diffusion de la série jusqu\'en 2029. Cette décision confirme le statut de série d\'animation la plus longue de l\'histoire de la télévision américaine.\n\nLa série, créée par Matt Groening, continue de captiver les audiences du monde entier avec son humour satirique et ses personnages iconiques.',
        author: adminUser._id,
        authorName: adminUser.username,
        category: 'actualité',
        status: 'published',
        isFeatured: true,
        tags: ['renouvellement', 'fox', 'saisons'],
        excerpt: 'Fox renouvelle Les Simpson pour quatre saisons supplémentaires jusqu\'en 2029.',
        publishedAt: new Date(),
        viewCount: 1500
      },
      {
        title: 'Hommage à Alf Clausen, compositeur légendaire',
        slug: generateSlug('Hommage à Alf Clausen compositeur légendaire'),
        content: 'La communauté des Simpson rend hommage à Alf Clausen, compositeur de plus de 600 épisodes de la série. Son travail musical a grandement contribué à l\'identité sonore unique des Simpson.\n\nDepuis les débuts de la série, Clausen a créé des mélodies mémorables qui accompagnent parfaitement l\'univers de Springfield.',
        author: adminUser._id,
        authorName: adminUser.username,
        category: 'actualité',
        status: 'published',
        tags: ['musique', 'hommage', 'alf clausen'],
        excerpt: 'Hommage au compositeur Alf Clausen qui a marqué l\'univers musical des Simpson.',
        publishedAt: new Date(Date.now() - 86400000),
        viewCount: 850
      },
      {
        title: 'Analyse : Springfield, miroir de l\'Amérique',
        slug: generateSlug('Analyse Springfield miroir de l Amérique'),
        content: 'Springfield représente l\'Amérique moyenne avec ses problèmes sociaux et politiques. Cette analyse explore comment la ville fictive reflète la société américaine contemporaine.\n\nÀ travers ses habitants variés et ses situations du quotidien, Springfield devient le laboratoire parfait pour observer et critiquer la société moderne.',
        author: adminUser._id,
        authorName: adminUser.username,
        category: 'analyse',
        status: 'published',
        tags: ['analyse', 'springfield', 'société'],
        excerpt: 'Comment Springfield reflète-t-elle la société américaine contemporaine ?',
        publishedAt: new Date(Date.now() - 172800000),
        viewCount: 1200
      },
      {
        title: 'Les Simpson célèbrent leur 35e anniversaire',
        slug: generateSlug('Les Simpson célèbrent leur 35e anniversaire'),
        content: 'Cette année marque le 35e anniversaire des Simpson depuis leur première apparition dans le Tracy Ullman Show. Un événement qui mérite d\'être célébré !\n\nDepuis 1987, la famille jaune la plus célèbre du monde n\'a cessé de nous divertir et de critiquer notre société avec finesse et humour.',
        author: testUser._id,
        authorName: testUser.username,
        category: 'actualité',
        status: 'published',
        isFeatured: false,
        tags: ['anniversaire', 'célébration', '35 ans'],
        excerpt: 'Les Simpson fêtent leurs 35 ans d\'existence.',
        publishedAt: new Date(Date.now() - 259200000),
        viewCount: 950
      },
      {
        title: 'Matt Groening dévoile ses inspirations pour créer Homer',
        slug: generateSlug('Matt Groening dévoile ses inspirations pour créer Homer'),
        content: 'Dans une interview exclusive, Matt Groening révèle comment il a créé le personnage d\'Homer Simpson, s\'inspirant notamment de son propre père et de Walter Matthau.',
        author: adminUser._id,
        authorName: adminUser.username,
        category: 'interview',
        status: 'published',
        tags: ['matt groening', 'homer', 'inspiration', 'création'],
        excerpt: 'Matt Groening révèle ses inspirations pour créer Homer Simpson.',
        publishedAt: new Date(Date.now() - 345600000),
        viewCount: 670
      }
    ];

    // CORRECTION: Insérer les actualités une par une pour éviter les conflits de slug
    const createdNews = [];
    for (const newsItem of newsItems) {
      try {
        const news = await News.create(newsItem);
        createdNews.push(news);
        console.log(`📰 Actualité créée: ${news.title}`);
      } catch (error) {
        if (error.code === 11000) {
          // Conflit de slug, générer un nouveau slug unique
          newsItem.slug = `${newsItem.slug}-${Date.now()}`;
          const news = await News.create(newsItem);
          createdNews.push(news);
          console.log(`📰 Actualité créée avec slug modifié: ${news.title}`);
        } else {
          console.error(`❌ Erreur création actualité "${newsItem.title}":`, error.message);
        }
      }
    }

    console.log(`📰 ${createdNews.length} actualités créées au total`);

    console.log('\n✅ Seeding terminé avec succès !');
    console.log('═══════════════════════════════════════');
    console.log('🔐 IDENTIFIANTS ADMINISTRATEUR');
    console.log('📧 Email: admin@simpsonspark.com');
    console.log('🔑 Password: admin123');
    console.log('👤 Rôle: Admin');
    console.log('═══════════════════════════════════════');
    console.log('🧪 IDENTIFIANTS UTILISATEUR TEST');
    console.log('📧 Email: test@simpsonspark.com');
    console.log('🔑 Password: test123');
    console.log('👤 Rôle: Utilisateur normal');
    console.log('═══════════════════════════════════════');
    console.log('📊 Statistiques:');
    console.log(`   - ${createdCharacters.length} personnages créés`);
    console.log(`   - ${createdEpisodes.length} épisodes créés`);
    console.log(`   - ${createdNews.length} actualités créées`);
    console.log(`   - 2 utilisateurs créés`);
    
  } catch (error) {
    console.error('❌ Erreur lors du seeding:', error);
    console.error('Stack trace:', error.stack);
  } finally {
    await mongoose.connection.close();
    console.log('📦 Connexion MongoDB fermée');
  }
};

// Exécuter le script si appelé directement
if (require.main === module) {
  seedDatabase();
}

module.exports = seedDatabase;