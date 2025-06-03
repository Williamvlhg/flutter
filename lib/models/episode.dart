class Episode {
  final String id;
  final int season;
  final int episodeNumber;
  final String title;
  final String? titleFr;
  final String? summary;
  final List<String> characters;
  final List<MainCharacter> mainCharacters; 
  final DateTime? airDate;
  final int duration;
  final int views;
  final List<String> tags;
  final bool isSpecial;
  final List<String> trivia;
  final List<String> guestStars;
  final List<String> culturalReferences;
  final List<String> quotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Episode({
    required this.id,
    required this.season,
    required this.episodeNumber,
    required this.title,
    this.titleFr,
    this.summary,
    required this.characters,
    required this.mainCharacters,
    this.airDate,
    required this.duration,
    required this.views,
    required this.tags,
    required this.isSpecial,
    required this.trivia,
    required this.guestStars,
    required this.culturalReferences,
    required this.quotes,
    this.createdAt,
    this.updatedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    try {
      return Episode(
        id: json['_id']?.toString() ?? '',
        season: json['season'] ?? 0,
        episodeNumber: json['episodeNumber'] ?? 0,
        title: json['title']?.toString() ?? '',
        titleFr: json['titleFr']?.toString(),
        summary: json['summary']?.toString(),
        
        characters: _parseStringList(json['characters']),
        
        mainCharacters: _parseMainCharacters(json['mainCharacters']),
        
        airDate: _parseDateTime(json['airDate']),
        
        duration: json['duration'] ?? 0,
        views: json['views'] ?? 0,
        
        tags: _parseStringList(json['tags']),
        trivia: _parseStringList(json['trivia']),
        guestStars: _parseStringList(json['guestStars']),
        culturalReferences: _parseStringList(json['culturalReferences']),
        quotes: _parseStringList(json['quotes']),
        
        isSpecial: json['isSpecial'] ?? false,
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('❌ Erreur dans Episode.fromJson: $e');
      print('JSON problématique: $json');
      rethrow;
    }
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item?.toString() ?? '').toList();
    }
    return [];
  }

  static List<MainCharacter> _parseMainCharacters(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((item) => item is Map<String, dynamic>)
          .map((item) => MainCharacter.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      print('⚠️ Erreur parsing date: $value');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'season': season,
      'episodeNumber': episodeNumber,
      'title': title,
      'titleFr': titleFr,
      'summary': summary,
      'characters': characters,
      'mainCharacters': mainCharacters.map((c) => c.toJson()).toList(),
      'airDate': airDate?.toIso8601String(),
      'duration': duration,
      'views': views,
      'tags': tags,
      'isSpecial': isSpecial,
      'trivia': trivia,
      'guestStars': guestStars,
      'culturalReferences': culturalReferences,
      'quotes': quotes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class MainCharacter {
  final String id;
  final String name;
  final String? nameFr;

  MainCharacter({
    required this.id,
    required this.name,
    this.nameFr,
  });

  factory MainCharacter.fromJson(Map<String, dynamic> json) {
    return MainCharacter(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameFr: json['nameFr']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'nameFr': nameFr,
    };
  }
  
}

