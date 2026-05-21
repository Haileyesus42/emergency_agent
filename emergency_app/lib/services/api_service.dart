import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/contact_model.dart';

class ApiService extends ChangeNotifier {
  final http.Client _client = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  String get _baseUrl => ApiConfig.baseUrl;
  
  ApiService();

  // Get auth token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Remove token
  Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: ApiConfig.connectTimeout),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        await _storage.write(
            key: 'current_username', value: data['user']['username']);
        await _storage.write(
            key: 'current_fullname',
            value: data['user']['full_name'] ?? data['user']['username']);

        return {
          'success': true,
          'data': data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['detail'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await _client
            .post(
              Uri.parse('$_baseUrl/auth/logout?token=$token'),
            )
            .timeout(
              const Duration(seconds: ApiConfig.connectTimeout),
            );
      } catch (e) {
        print('Logout error: $e');
      }
    }
    await removeToken();
  }

  // Get user profile
  Future<UserModel> getProfile() async {
    final token = await getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please login again.');
    }
    
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/user/profile?token=$token'),
      ).timeout(
        const Duration(seconds: ApiConfig.receiveTimeout),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to load profile');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(UserModel user) async {
    final token = await getToken();

    final response = await _client
        .put(
          Uri.parse('$_baseUrl/user/profile?token=$token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(user.toJson()),
        )
        .timeout(
          const Duration(seconds: ApiConfig.receiveTimeout),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'error': data['detail'] ?? 'Update failed'};
    }
  }

  // Get emergency contacts
  Future<List<ContactModel>> getEmergencyContacts() async {
    final token = await getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please login again.');
    }
    
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/user/emergency-contacts/?token=$token'),
      ).timeout(
        const Duration(seconds: ApiConfig.receiveTimeout),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ContactModel.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to load contacts');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update emergency contacts
  Future<Map<String, dynamic>> updateEmergencyContacts(
      List<ContactModel> contacts) async {
    final token = await getToken();

    final response = await _client
        .put(
          Uri.parse('$_baseUrl/user/emergency-contacts/?token=$token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contacts': contacts.map((c) => c.toJson()).toList(),
          }),
        )
        .timeout(
          const Duration(seconds: ApiConfig.receiveTimeout),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'error': data['detail'] ?? 'Update failed'};
    }
  }

  // Trigger emergency SOS
  Future<Map<String, dynamic>> triggerEmergencySOS() async {
    final token = await getToken();

    // Try to get username from storage first
    String? storedUsername = await _storage.read(key: 'current_username');
    String userName = storedUsername ?? 'unknown';

    // If not available, fetch from profile
    if (userName == 'unknown') {
      try {
        final profile = await getProfile();
        userName = profile.username;
        await _storage.write(key: 'current_username', value: userName);
      } catch (e) {
        return {
          'success': false,
          'error': 'Could not determine user info',
        };
      }
    }

    final payload = {
      'type': 'emergency',
      'user_name': userName,
      'signal': 'SOS_BUTTON',
    };

    final response = await _client
        .post(
          Uri.parse('$_baseUrl/emergency/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(
          const Duration(seconds: ApiConfig.receiveTimeout),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'error': 'Failed to trigger emergency'};
    }
  }

  // Alias for triggerEmergencySOS - used by EmergencyButton widget
  Future<Map<String, dynamic>> triggerEmergency() async {
    return await triggerEmergencySOS();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
