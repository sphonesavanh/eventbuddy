// 🎨 Global ThemeData for your app
import 'dart:io';
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.deepPurple,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Color(0xFFF5F5F5),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);

// 🧠 Login Screen
Widget styledLoginScreen(
  BuildContext context,
  TextEditingController emailCtrl,
  TextEditingController passCtrl,
  VoidCallback onLogin,
  VoidCallback onNavigateToSignUp,
) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onLogin, child: const Text("Login")),
            TextButton(
              onPressed: onNavigateToSignUp,
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    ),
  );
}

// 🧠 Signup Screen
Widget styledSignupScreen(
  BuildContext context,
  TextEditingController emailCtrl,
  TextEditingController passCtrl,
  VoidCallback onSignup,
) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onSignup, child: const Text("Sign Up")),
          ],
        ),
      ),
    ),
  );
}

// 🧠 Event Card Widget
class StyledEventCard extends StatelessWidget {
  final String title, description, imageUrl;
  final VoidCallback onTap;
  const StyledEventCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

// 🏠 Home Screen
Widget styledHomeScreen(
  BuildContext context,
  List<Widget> eventCards,
  VoidCallback onAddEvent,
  VoidCallback onLogout,
) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("EventBuddy"),
      actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: ListView(children: eventCards),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: onAddEvent,
      child: const Icon(Icons.add),
    ),
  );
}

// 📝 Create Event Screen
Widget styledCreateEventScreen(
  BuildContext context,
  TextEditingController titleCtrl,
  TextEditingController descCtrl,
  DateTime? date,
  VoidCallback onPickDate,
  File? image,
  VoidCallback onPickImage,
  VoidCallback onSubmit,
  bool loading,
) {
  return Scaffold(
    appBar: AppBar(title: const Text("Create Event")),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descCtrl,
            decoration: const InputDecoration(labelText: "Description"),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                "Date: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                date != null
                    ? date.toLocal().toString().split(' ')[0]
                    : "No date selected",
              ),
              IconButton(
                onPressed: onPickDate,
                icon: const Icon(Icons.calendar_today),
              ),
            ],
          ),
          const SizedBox(height: 12),
          image != null
              ? Image.file(image, height: 150)
              : const Text("No image selected"),
          TextButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.image),
            label: const Text("Pick Image"),
          ),
          const SizedBox(height: 20),
          loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                onPressed: onSubmit,
                child: const Text("Create Event"),
              ),
        ],
      ),
    ),
  );
}

// 📄 Event Detail Screen
Widget styledEventDetailScreen(
  BuildContext context,
  String title,
  String desc,
  String imageUrl,
  DateTime date,
) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Image.network(imageUrl, height: 200, fit: BoxFit.cover),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(desc),
          const SizedBox(height: 8),
          Text("Date: ${date.toLocal().toString().split(' ')[0]}"),
        ],
      ),
    ),
  );
}

// 🙋 Profile Screen
Widget styledProfileScreen(
  BuildContext context,
  String? email,
  VoidCallback onSignOut,
) {
  return Scaffold(
    appBar: AppBar(title: const Text("Profile")),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100),
            const SizedBox(height: 16),
            Text(email ?? "No Email", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onSignOut, child: const Text("Sign Out")),
          ],
        ),
      ),
    ),
  );
}

// ⚙ Settings Screen
Widget styledSettingsScreen(BuildContext context, VoidCallback onSignOut) {
  return Scaffold(
    appBar: AppBar(title: const Text("Settings")),
    body: Center(
      child: ElevatedButton(
        onPressed: onSignOut,
        child: const Text("Sign Out"),
      ),
    ),
  );
}
