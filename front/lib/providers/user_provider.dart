import 'package:flutter/material.dart';

class User {
  final String email;
  final String name;
  final int userId;

  User({
    required this.email,
    required this.name,
    required this.userId,
  });
}

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
