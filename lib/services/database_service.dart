// services/database_service.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/episode.dart';
import '../models/character.dart';
import '../models/news.dart';

class DatabaseService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000/api';
  
  List<Episode> _episodes = [];
  List<Character> _characters = [];
  List<News> _news = [];
  bool _isLoading = false;

  List<Episode> get episodes => _episodes;
  List<Character> get characters => _characters;
  List<News> get news => _news;
  bool get isLoading => _isLoading;

 Future<void> fetchEpisodes() async {
  _setLoading(true);
  try {
    final response = await http.get(Uri.parse('$baseUrl/episodes'));
    print('Episodes Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final dynamic jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse is List) {
        // Format direct : [...]
        print('✅ Format liste directe détecté pour les épisodes');
        _episodes = _parseEpisodesList(jsonResponse);
        print('✅ ${_episodes.length} épisodes chargés');
      } else if (jsonResponse is Map<String, dynamic>) {
        // Format API : {success: true, data: [...]}
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final dynamic data = jsonResponse['data'];
          if (data is List) {
            _episodes = _parseEpisodesList(data);
            print('✅ ${_episodes.length} épisodes chargés');
          } else {
            print('❌ Le champ "data" n\'est pas une liste');
            _episodes = [];
          }
        } else {
          print('❌ Format de réponse invalide pour les épisodes');
          print('Success: ${jsonResponse['success']}, Data: ${jsonResponse['data']}');
          _episodes = [];
        }
      } else {
        print('❌ Format de réponse non reconnu pour les épisodes');
        print('Type reçu: ${jsonResponse.runtimeType}');
        _episodes = [];
      }
    } else {
      print('❌ Erreur HTTP: ${response.statusCode}');
      _episodes = [];
    }
  } catch (e, stackTrace) {
    print('❌ Erreur lors du chargement des épisodes: $e');
    print('StackTrace: $stackTrace');
    _episodes = [];
  } finally {
    _setLoading(false);
  }
}

List<Episode> _parseEpisodesList(List<dynamic> episodesList) {
  List<Episode> episodes = [];
  
  for (int i = 0; i < episodesList.length; i++) {
    try {
      final dynamic item = episodesList[i];
      
      if (item is Map<String, dynamic>) {
        episodes.add(Episode.fromJson(item));
      } else {
        print('⚠️ Élément à l\'index $i n\'est pas un Map<String, dynamic>: ${item.runtimeType}');
      }
    } catch (e) {
      print('⚠️ Erreur lors du parsing de l\'épisode à l\'index $i: $e');
      print('Données problématiques: ${episodesList[i]}');
    }
  }
  
  return episodes;
}

  Future<void> fetchCharacters() async {
    _setLoading(true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/characters'));
      print('Characters Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse is List) {
          // Format direct : [...]
          print('✅ Format liste directe détecté pour les personnages');
          _characters = jsonResponse.map((json) {
            try {
              return Character.fromJson(json);
            } catch (e) {
              print('Erreur parsing personnage: $e');
              print('JSON problématique: $json');
              return null;
            }
          }).where((character) => character != null).cast<Character>().toList();
          print('✅ ${_characters.length} personnages chargés');
        } else if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final List<dynamic> data = jsonResponse['data'];
            _characters = data.map((json) {
              try {
                return Character.fromJson(json);
              } catch (e) {
                print('Erreur parsing personnage: $e');
                print('JSON problématique: $json');
                return null;
              }
            }).where((character) => character != null).cast<Character>().toList();
            print('✅ ${_characters.length} personnages chargés');
          } else {
            print('❌ Format de réponse invalide pour les personnages');
            _characters = [];
          }
        } else {
          print('❌ Format de réponse non reconnu pour les personnages');
          _characters = [];
        }
      }
    } catch (e, stackTrace) {
      print('Erreur lors du chargement des personnages: $e');
      print('StackTrace: $stackTrace');
      _characters = [];
    }
    _setLoading(false);
  }

  Future<void> fetchNews() async {
    _setLoading(true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/news'));
      print('News Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse is List) {
          // Format direct : [...]
          print('✅ Format liste directe détecté pour les actualités');
          _news = jsonResponse.map((json) => News.fromJson(json)).toList();
          _news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
          print('✅ ${_news.length} actualités chargées');
        } else if (jsonResponse is Map<String, dynamic>) {
          // Format API : {success: true, data: [...]}
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final List<dynamic> data = jsonResponse['data'];
            _news = data.map((json) => News.fromJson(json)).toList();
            _news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
            print('✅ ${_news.length} actualités chargées');
          } else {
            print('❌ Format de réponse invalide pour les actualités');
            _news = [];
          }
        } else {
          print('❌ Format de réponse non reconnu pour les actualités');
          _news = [];
        }
      }
    } catch (e, stackTrace) {
      print('Erreur lors du chargement des actualités: $e');
      print('StackTrace: $stackTrace');
      _news = [];
    }
    _setLoading(false);
  }

  Future<Episode?> getEpisode(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/episodes/$id'));
      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            return Episode.fromJson(jsonResponse['data']);
          }
        }
        
        return Episode.fromJson(jsonResponse);
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'épisode: $e');
    }
    return null;
  }

  Future<Character?> getCharacter(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/characters/$id'));
      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            return Character.fromJson(jsonResponse['data']);
          }
        }
        
        return Character.fromJson(jsonResponse);
      }
    } catch (e) {
      print('Erreur lors du chargement du personnage: $e');
    }
    return null;
  }

  Future<News?> getNews(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/news/$id'));
      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            return News.fromJson(jsonResponse['data']);
          }
        }
        
        return News.fromJson(jsonResponse);
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'actualité: $e');
    }
    return null;
  }

  List<Episode> getEpisodesBySeason(int season) {
    return _episodes.where((episode) => episode.season == season).toList()
      ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
  }

  List<int> getAvailableSeasons() {
    final seasons = _episodes.map((e) => e.season).toSet().toList();
    seasons.sort();
    return seasons;
  }

  List<Character> getMajorCharacters() {
    return _characters.where((character) => character.isMajor).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> createEpisode(Episode episode, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/episodes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(episode.toJson()),
      );
      if (response.statusCode == 201) {
        await fetchEpisodes();
        return true;
      }
    } catch (e) {
      print('Erreur lors de la création de l\'épisode: $e');
    }
    return false;
  }

  Future<bool> updateEpisode(String id, Episode episode, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/episodes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(episode.toJson()),
      );
      if (response.statusCode == 200) {
        await fetchEpisodes();
        return true;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'épisode: $e');
    }
    return false;
  }

  Future<bool> deleteEpisode(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/episodes/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        await fetchEpisodes();
        return true;
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'épisode: $e');
    }
    return false;
  }

  Future<bool> createCharacter(Character character, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/characters'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(character.toJson()),
      );
      if (response.statusCode == 201) {
        await fetchCharacters();
        return true;
      }
    } catch (e) {
      print('Erreur lors de la création du personnage: $e');
    }
    return false;
  }

  Future<bool> createNews(News news, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/news'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(news.toJson()),
      );
      if (response.statusCode == 201) {
        await fetchNews();
        return true;
      }
    } catch (e) {
      print('Erreur lors de la création de l\'actualité: $e');
    }
    return false;
  }

  List<Episode> searchEpisodes(String query) {
  final lowercaseQuery = query.toLowerCase();
  return _episodes.where((episode) =>
    episode.title.toLowerCase().contains(lowercaseQuery) ||
    (episode.titleFr?.toLowerCase().contains(lowercaseQuery) ?? false) ||
    (episode.summary?.toLowerCase().contains(lowercaseQuery) ?? false)
  ).toList();
}

  List<Character> searchCharacters(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _characters.where((character) =>
      character.name.toLowerCase().contains(lowercaseQuery) ||
      character.nameFr.toLowerCase().contains(lowercaseQuery) ||
      character.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Map<String, int> getEpisodesStats() {
    return {
      'total': _episodes.length,
      'seasons': getAvailableSeasons().length,
      'characters': _characters.length,
      'news': _news.length,
    };
  }
}