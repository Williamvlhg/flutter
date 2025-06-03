class Character {
  final String id;
  final String name;
  final String nameFr;
  final String description;
  final String? imageUrl;
  final List<EpisodeReference> episodes;
  final String family;
  final String job;
  final bool isMajor;

  Character({
    required this.id,
    required this.name,
    required this.nameFr,
    required this.description,
    this.imageUrl,
    required this.episodes,
    required this.family,
    required this.job,
    required this.isMajor,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      nameFr: json['nameFr'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      episodes: (json['episodes'] as List?)?.map((item) {
        if (item is String) {
          return EpisodeReference(id: item, title: '', titleFr: '', season: 0, episodeNumber: 0);
        } else if (item is Map<String, dynamic>) {
          return EpisodeReference.fromJson(item);
        }
        return EpisodeReference(id: '', title: '', titleFr: '', season: 0, episodeNumber: 0);
      }).toList() ?? [],
      family: json['family'] ?? '',
      job: json['job'] ?? '',
      isMajor: json['isMajor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameFr': nameFr,
      'description': description,
      'imageUrl': imageUrl,
      'episodes': episodes.map((e) => e.id).toList(),
      'family': family,
      'job': job,
      'isMajor': isMajor,
    };
  }
}

class EpisodeReference {
  final String id;
  final String title;
  final String titleFr;
  final int season;
  final int episodeNumber;

  EpisodeReference({
    required this.id,
    required this.title,
    required this.titleFr,
    required this.season,
    required this.episodeNumber,
  });

  factory EpisodeReference.fromJson(Map<String, dynamic> json) {
    return EpisodeReference(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      titleFr: json['titleFr'] ?? '',
      season: json['season'] ?? 0,
      episodeNumber: json['episodeNumber'] ?? 0,
    );
  }
}