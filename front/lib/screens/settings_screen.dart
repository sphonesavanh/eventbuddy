import 'package:flutter/material.dart';
import 'about_screen.dart'; // Import the AboutScreen file

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  builder: (context) => AboutScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'App preferences and configurations.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
