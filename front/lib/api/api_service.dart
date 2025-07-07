import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.1.12:2000/api';

  // existing auth & profile calls (login, signup, etc.)
  static Future<bool> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return response.statusCode == 200;
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
    if (response.statusCode == 200) {
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
      Uri.parse('$baseUrl/users/$oldEmail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    return response.statusCode == 200;
  }

  /// Fetch a list of events (with an optional limit to avoid massive payloads)
  static Future<List<dynamic>> getEvents({
    int limit = 10,
  }) async {
    final response = await http
        .get(Uri.parse('$baseUrl/events?limit=$limit'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Failed to load events (${response.statusCode})',
      );
    }
  }

  /// Fetch a single event by its ID
  static Future<Map<String, dynamic>> getEventById(
    int eventId,
  ) async {
    final response = await http
        .get(Uri.parse('$baseUrl/events/$eventId'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return json.decode(response.body)
          as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load event #$eventId');
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

  static Future<bool> createEvent({
    required String title,
    required String description,
    required String date,
    required String time,
    required String location,
    required String createdBy,
  }) async {
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
    return response.statusCode == 201;
  }
}
