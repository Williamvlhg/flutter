// test-password.js
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
require('dotenv').config();

const User = require('./../models/User'); // Assurez-vous que le chemin est correct

const testPassword = async () => {
  try {
    await mongoose.connect("mongodb+srv://zaki:zaki@cluster0.r32uulx.mongodb.net/simpsons_park?retryWrites=true&w=majority&appName=Cluster0");
    console.log('📦 Connecté à MongoDB');

    const user = await User.findOne({ email: 'admin@simpsonspark.com' });
    
    if (!user) {
      console.log('❌ Utilisateur non trouvé');
      return;
    }

    console.log('✅ Utilisateur trouvé');
    console.log('🔑 Hash du mot de passe:', user.password);
    console.log('📏 Longueur du hash:', user.password.length);
    
    // Test 1: Méthode du modèle
    console.log('\n🧪 Test 1: Méthode comparePassword du modèle');
    try {
      if (user.comparePassword) {
        const result1 = await user.comparePassword('admin123');
        console.log('user.comparePassword("admin123"):', result1);
      } else {
        console.log('❌ Méthode comparePassword non trouvée');
      }
    } catch (error) {
      console.log('❌ Erreur comparePassword:', error.message);
    }

    // Test 2: bcrypt direct
    console.log('\n🧪 Test 2: bcrypt.compare direct');
    try {
      const result2 = await bcrypt.compare('admin123', user.password);
      console.log('bcrypt.compare("admin123", hash):', result2);
    } catch (error) {
      console.log('❌ Erreur bcrypt.compare:', error.message);
    }

    // Test 3: Vérifier si le hash est valide
    console.log('\n🧪 Test 3: Validation du format hash');
    const hashPattern = /^\$2[aby]?\$\d+\$/;
    const isValidHash = hashPattern.test(user.password);
    console.log('Format hash valide:', isValidHash);

    // Test 4: Créer un nouveau hash et le tester
    console.log('\n🧪 Test 4: Création nouveau hash');
    const newHash = await bcrypt.hash('admin123', 12);
    console.log('Nouveau hash:', newHash);
    const testNewHash = await bcrypt.compare('admin123', newHash);
    console.log('Test nouveau hash:', testNewHash);

    // Test 5: Comparer avec d'autres mots de passe
    console.log('\n🧪 Test 5: Autres mots de passe');
    const testPasswords = ['admin', 'password', '123456', 'Admin123'];
    for (const testPass of testPasswords) {
      const result = await bcrypt.compare(testPass, user.password);
      console.log(`"${testPass}":`, result);
    }

    // SOLUTION: Mettre à jour avec un nouveau hash
    console.log('\n🔧 Solution: Mise à jour du mot de passe');
    const correctHash = await bcrypt.hash('admin123', 12);
    await User.updateOne(
      { email: 'admin@simpsonspark.com' },
      { password: correctHash }
    );
    console.log('✅ Mot de passe mis à jour avec un nouveau hash');

    // Vérifier la mise à jour
    const updatedUser = await User.findOne({ email: 'admin@simpsonspark.com' });
    const finalTest = await bcrypt.compare('admin123', updatedUser.password);
    console.log('🎯 Test final après mise à jour:', finalTest);

  } catch (error) {
    console.error('❌ Erreur:', error);
  } finally {
    await mongoose.connection.close();
  }
};

testPassword();