import 'dart:convert';
import 'package:eventbuddy_app/models/event_model.dart';
import 'package:eventbuddy_app/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class ApiService {
  static const String baseUrl =
      'http://192.168.1.14:2000/api';

  static Future<User?> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User(
        email: data['email'],
        name: data['name'],
        userId: int.parse(data['user_id'].toString()),
      );
    } else if (response.statusCode == 401) {
      return null; // Login failed
    } else {
      throw Exception(
        'Login failed: ${response.statusCode}',
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> signup(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>> getUserProfile(
    String email,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile/$email'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return json.decode(response.body)
          as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load profile for $email');
    }
  }

  static Future<bool> updateUserProfile(
    String oldEmail,
    String name,
    String email,
    String password,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile/$oldEmail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'newName': name,
        'newEmail': email,
        'newPassword': password,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> uploadProfilePicture(
    String email,
    File imageFile,
  ) async {
    try {
      var uri = Uri.parse(
        "$baseUrl/users/profile/$email/picture",
      );
      var request = http.MultipartRequest('POST', uri);

      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePicture',
          imageFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Profile picture uploaded successfully");
        return true;
      } else {
        print(
          "Failed to upload profile picture. Status: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error uploading profile picture: $e");
      return false;
    }
  }

  /// Fetch all events (limit optional)
  static Future<List<Event>> getEvents({
    int limit = 10,
  }) async {
    final response = await http
        .get(Uri.parse('$baseUrl/events?limit=$limit'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(
        response.body,
      );
      return jsonList
          .map((json) => Event.fromJson(_fixImageUrl(json)))
          .toList();
    } else {
      throw Exception(
        'Failed to load events (${response.statusCode})',
      );
    }
  }

  /// Fetch a single event by ID
  static Future<Event> getEventById(int eventId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/events/$eventId'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(
        response.body,
      );
      return Event.fromJson(_fixImageUrl(json));
    } else {
      throw Exception(
        'Failed to load event (${response.statusCode})',
      );
    }
  }

  /// Fetch events created by a specific user
  static Future<List<Event>> getEventsByUser(
    String email,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/byUser?email=$email'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        response.body,
      );
      return jsonList
          .map((json) => Event.fromJson(_fixImageUrl(json)))
          .toList();
    } else {
      throw Exception('Failed to load user events');
    }
  }

  /// Create a new event (supports optional image upload)
  static Future<bool> createEvent({
    required String title,
    required String description,
    required String date,
    required String time,
    required String location,
    String? imagePath, // Path to image file (nullable)
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final createdBy =
        prefs.getString('user_email') ?? 'unknown';

    try {
      if (imagePath != null) {
        // Multipart request for image upload
        var uri = Uri.parse('$baseUrl/events');
        var request = http.MultipartRequest('POST', uri);

        // Add fields
        request.fields['title'] = title;
        request.fields['description'] = description;
        request.fields['date'] = date;
        request.fields['time'] = time;
        request.fields['location'] = location;
        request.fields['created_by'] = createdBy;

        // Add image file
        var file = await http.MultipartFile.fromPath(
          'image', // backend field name
          imagePath,
          filename: path.basename(imagePath),
        );
        request.files.add(file);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(
          streamedResponse,
        );

        if (response.statusCode == 201) {
          return true;
        } else {
          debugPrint(
            'Failed to create event: ${response.body}',
          );
          return false;
        }
      } else {
        // Fallback to JSON-only request
        final response = await http.post(
          Uri.parse('$baseUrl/events'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': title,
            'description': description,
            'date': date,
            'time': time,
            'location': location,
            'created_by': createdBy,
          }),
        );

        if (response.statusCode == 201) {
          return true;
        } else {
          debugPrint(
            'Failed to create event: ${response.body}',
          );
          return false;
        }
      }
    } catch (e) {
      debugPrint('Error creating event: $e');
      return false;
    }
  }

  static Future<bool> updateEventWithImage(
    int eventId,
    Map<String, dynamic> updatedData,
    File? imageFile,
  ) async {
    try {
      var uri = Uri.parse("$baseUrl/events/$eventId");
      var request = http.MultipartRequest('PUT', uri);

      // Add text fields
      updatedData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add image file if user picked a new one
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Backend expects field name 'image'
            imageFile.path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Event updated successfully!");
        return true;
      } else {
        print(
          "Failed to update event. Status: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error updating event: $e");
      return false;
    }
  }


  static Future<bool> deleteEvent(int eventId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$eventId'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
        'Failed to delete event: ${response.body}',
      );
      return false;
    }
  }

  static Future<List<dynamic>> getUserTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null || email.isEmpty) {
      throw Exception(
        'No user email found in SharedPreferences.',
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/tickets'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Failed to load tickets (${response.statusCode})',
      );
    }
  }

  static Map<String, dynamic> _fixImageUrl(
    Map<String, dynamic> json,
  ) {
    if (json['image'] != null && json['image'].isNotEmpty) {
      if (!json['image'].startsWith('http')) {
        json['image'] =
            '$baseUrl/${json['image'].replaceAll("\\", "/")}';
      }
    }
    return json;
  }
}
