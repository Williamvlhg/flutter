class News {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime publishedAt;
  final String? imageUrl;
  final List<String> tags;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.publishedAt,
    this.imageUrl,
    required this.tags,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }
}