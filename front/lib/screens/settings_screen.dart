import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'about_screen.dart';
import 'login_screen.dart';
import '../api/api_service.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService().logout(); // Clear SharedPreferences
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).clearUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Colors.deepPurple,
            ),
            title: const Text('About Us'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text('Logout'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap:
                () => _logout(context), // Fixed logout call
          ),
          const Divider(),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('EventBuddy © 2025'),
            ),
          ),
        ],
      ),
    );
  }
}
