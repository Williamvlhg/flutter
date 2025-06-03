class User {
  final String id;
  final String email;
  final String username;
  final bool isAdmin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isAdmin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}