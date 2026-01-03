import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Base URL - adjust for your environment
  static const String baseUrl = 'http://localhost/contacts_api/api_auth.php';
  
  // For Android emulator
  // static const String baseUrl = 'http://10.0.2.2/contacts_api/api_auth.php';

  // ==================== LOGIN ====================
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      print('🔐 Attempting login for: $username');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'action': 'login',
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Login response - Status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // ==================== REGISTER ====================
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    String? email,
  }) async {
    try {
      print('📝 Attempting registration for: $username');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'action': 'register',
              'username': username,
              'password': password,
              'personne': {
                'nom': nom,
                'prenom': prenom,
                'telephone': telephone,
                'email': email,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Register response - Status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 409) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Register error: $e');
      return {
        'success': false,
        'message': 'Erreur lors de l\'inscription: $e',
      };
    }
  }

  // ==================== GET USER PROFILE ====================
  static Future<Map<String, dynamic>> getUserProfile(int accountId) async {
    try {
      print('👤 Fetching profile for account: $accountId');

      final response = await http
          .get(
            Uri.parse('$baseUrl?action=profile&accountId=$accountId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Profile response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Get profile error: $e');
      return {
        'success': false,
        'message': 'Erreur lors de la récupération du profil: $e',
      };
    }
  }

  // ==================== UPDATE PASSWORD ====================
  static Future<Map<String, dynamic>> updatePassword({
    required int accountId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      print('🔑 Updating password for account: $accountId');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'action': 'updatePassword',
              'accountId': accountId,
              'oldPassword': oldPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Update password response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Update password error: $e');
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour: $e',
      };
    }
  }

  // ==================== TEST CONNECTION ====================
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing auth API connection...');

      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 400) {
        print('✅ Auth API connection successful!');
        return true;
      } else {
        print('⚠️ Auth API accessible but returned ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Cannot connect to Auth API: $e');
      return false;
    }
  }
}
