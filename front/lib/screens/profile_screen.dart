import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String firstjoined = '';
  String? profilePictureUrl; // Network image URL

  File? _localProfileImage; // Local picked image
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('user_email');

    if (savedEmail != null) {
      final user = await ApiService.getUserProfile(
        savedEmail,
      );
      setState(() {
        name = user['name'] ?? '';
        email = user['email'] ?? '';
        if (user['created_at'] != null) {
          final joinedDate = DateTime.parse(
            user['created_at'],
          );
          firstjoined =
              '${joinedDate.year}-${joinedDate.month.toString().padLeft(2, '0')}-${joinedDate.day.toString().padLeft(2, '0')}';
        } else {
          firstjoined = '';
        }

        // Load profile picture URL
        if (user['profile_picture'] != null &&
            user['profile_picture'].isNotEmpty) {
          profilePictureUrl =
              "${ApiService.baseUrl.replaceAll("/api", "")}/uploads/${user['profile_picture']}";
        } else {
          profilePictureUrl = null;
        }

        // Clear local image when reloading from backend
        _localProfileImage = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _localProfileImage = imageFile;
      });

      bool success = await ApiService.uploadProfilePicture(
        email,
        imageFile,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile picture updated successfully',
            ),
          ),
        );
        await _loadUserProfile(); // reload to get updated URL
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to upload profile picture',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showUpdateDialog() async {
    _nameController.text = name;
    _emailController.text = email;
    _passwordController.clear();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    String newName = _nameController.text.trim();
    String newEmail = _emailController.text.trim();
    String newPassword = _passwordController.text.trim();

    bool success = await ApiService.updateUserProfile(
      email,
      newName,
      newEmail,
      newPassword,
    );

    Navigator.pop(context); // Close dialog

    if (success) {
      setState(() {
        name = newName;
        email = newEmail;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed:
                          () => Navigator.pop(context),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Profile picture with edit icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        _localProfileImage != null
                            ? FileImage(_localProfileImage!)
                            : (profilePictureUrl != null
                                    ? NetworkImage(
                                      profilePictureUrl!,
                                    )
                                    : null)
                                as ImageProvider?,
                    child:
                        (_localProfileImage == null &&
                                profilePictureUrl == null)
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF4A90E2),
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              // Joined date
              Text(
                'Joined: $firstjoined',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              // Update Profile button
              Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _showUpdateDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        25,
                      ),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            color: Color(0xFF4A90E2),
                          )
                          : const Text(
                            'Update Profile',
                            style: TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
