import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventbuddy_app/providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin();
    });
  }

  Future<void> _checkLogin() async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // Optional: show splash for at least 1 second
    await Future.delayed(const Duration(seconds: 5));

    await authProvider.loadToken();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // optional: set a background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Image.asset(
              'assets/logo.png', // <-- path to your PNG
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),

            // Spinner
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
