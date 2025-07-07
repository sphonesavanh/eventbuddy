class User {
  final int userId;
  final String name;
  final String email;

  User({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
    );
  }
}