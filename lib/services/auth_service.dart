import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _token;
  
  static const String baseUrl = 'http://localhost:3000/api';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String? get token => _token;

  static const String DEFAULT_ADMIN_EMAIL = "admin@simpsonspark.com";
  static const String DEFAULT_ADMIN_PASSWORD = "admin123";

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    
    print('🔍 Tentative de connexion avec: $email');
    print('🌐 URL API: $baseUrl/auth/login');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Code de réponse: ${response.statusCode}');
      print('📝 Corps de réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Données décodées: $data');
        
        if (data['success'] == true) {
          _token = data['token'];
          _currentUser = User.fromJson(data['user']);
          print('✅ Utilisateur connecté: ${_currentUser?.username}');
          _setLoading(false);
          return true;
        }
      } else {
        print('❌ Échec API - Code: ${response.statusCode}');
        print('❌ Message: ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] == 'Identifiants invalides') {
            print('🔄 Utilisation du fallback admin...');
            return _tryDefaultLogin(email, password);
          }
        } catch (e) {
          return _tryDefaultLogin(email, password);
        }
        
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de la connexion: $e');
      print('🔄 Tentative avec identifiants par défaut...');
      
      return _tryDefaultLogin(email, password);
    }
    
    _setLoading(false);
    return false;
  }

  Future<bool> register(String email, String username, String password) async {
    _setLoading(true);
    
    print('🔍 Tentative d\'inscription avec: $email');
    print('🌐 URL API: $baseUrl/auth/register');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Code de réponse inscription: ${response.statusCode}');
      print('📝 Corps de réponse: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Données inscription: $data');
        
        if (data['success'] == true) {
          _token = data['token'];
          _currentUser = User.fromJson(data['user']);
          print('✅ Utilisateur inscrit et connecté: ${_currentUser?.username}');
          _setLoading(false);
          return true;
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Erreur inscription: ${errorData['message']}');
          
          if (errorData['errors'] != null) {
            for (var error in errorData['errors']) {
              print('  - ${error['msg']} (${error['param']})');
            }
          }
        } catch (e) {
          print('❌ Erreur parsing réponse: $e');
        }
        
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'inscription: $e');
      _setLoading(false);
      return false;
    }
    
    _setLoading(false);
    return false;
  }

  Future<Map<String, dynamic>> registerWithDetails(String email, String username, String password) async {
    _setLoading(true);
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _setLoading(false);
        
        return {
          'success': true,
          'message': data['message'] ?? 'Inscription réussie',
        };
      } else {
        _setLoading(false);
        
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription',
          'errors': data['errors'] ?? [],
        };
      }
    } catch (e) {
      _setLoading(false);
      
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
        'error': e.toString(),
      };
    }
  }

  // Méthode pour tester les identifiants par défaut
  bool _tryDefaultLogin(String email, String password) {
    if (email == DEFAULT_ADMIN_EMAIL && password == DEFAULT_ADMIN_PASSWORD) {
      print('✅ Connexion admin par défaut réussie');
      _currentUser = User(
        id: "admin_default",
        username: "admin",
        email: email,
        isAdmin: true,
        createdAt: DateTime.now(),
      );
      _token = 'mock_admin_token';
      _setLoading(false);
      return true;
    }
    
    print('❌ Identifiants non reconnus');
    _setLoading(false);
    return false;
  }

  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  String? validateEmail(String email) {
    if (email.isEmpty) return 'Email requis';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Email invalide';
    }
    return null;
  }

  String? validateUsername(String username) {
    if (username.isEmpty) return 'Nom d\'utilisateur requis';
    if (username.length < 3) return 'Nom d\'utilisateur trop court (min 3 caractères)';
    if (username.length > 30) return 'Nom d\'utilisateur trop long (max 30 caractères)';
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Mot de passe requis';
    if (password.length < 6) return 'Mot de passe trop court (min 6 caractères)';
    return null;
  }
}