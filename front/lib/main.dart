// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const EventBuddyApp(),
    ),
  );
}

class EventBuddyApp extends StatefulWidget {
  const EventBuddyApp({super.key});
  @override
  State<EventBuddyApp> createState() =>
      _EventBuddyAppState();
}

class _EventBuddyAppState extends State<EventBuddyApp> {
  // ignore: unused_field
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // adjust the key name to whatever you’re using
    final logged = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = logged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EventBuddy',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: SplashScreen(), // now SplashScreen can read AuthProvider!
    );
  }
}
