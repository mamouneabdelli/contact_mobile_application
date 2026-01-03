import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Contact.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost/contacts_api/api_contacts.php';

  // For Android emulator
  // static const String baseUrl = 'http://10.0.2.2/contacts_api/api_contacts.php';

  // ==================== GET ALL CONTACTS ====================
  static Future<List<Contact>> getAllContacts(int accountId) async {
    try {
      print('📡 API Call: GET $baseUrl?accountId=$accountId');

      final response = await http
          .get(
            Uri.parse('$baseUrl?accountId=$accountId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ GET Response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          print('📱 ${data.length} contacts loaded');
          return data.map((json) => Contact.fromJson(json)).toList();
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ HTTP Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getAllContacts: $e');

      if (e is http.ClientException) {
        throw Exception(
          '❌ Cannot connect to server. Check if XAMPP is running.',
        );
      } else if (e is FormatException) {
        throw Exception('❌ Invalid server response. Check your PHP API.');
      } else {
        throw Exception('❌ Network error: $e');
      }
    }
  }

  // ==================== CREATE CONTACT ====================
  static Future<Contact> createContact(Contact contact, int accountId) async {
    try {
      final Map<String, dynamic> requestBody = {
        'action': 'create',
        'accountId': accountId,
        'contact': {
          'personne': {
            'nom': contact.personne.nom,
            'prenom': contact.personne.prenom,
            'telephone': contact.personne.telephone,
            'email': contact.personne.email,
            'imageUrl': contact.personne.imageUrl,
          },
        },
      };

      print('📡 API Call: POST $baseUrl');
      print('📦 Data: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ POST Response - Status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Contact created successfully');
          return Contact.fromJson(jsonResponse['data']);
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ HTTP Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in createContact: $e');
      throw Exception('❌ Error creating contact: $e');
    }
  }

  // ==================== UPDATE CONTACT ====================
  static Future<bool> updateContact(
    int id,
    Contact contact,
    int accountId,
  ) async {
    try {
      final Map<String, dynamic> requestBody = {
        'action': 'update',
        'id': id,
        'accountId': accountId,
        'contact': {
          'personne': {
            'nom': contact.personne.nom,
            'prenom': contact.personne.prenom,
            'telephone': contact.personne.telephone,
            'email': contact.personne.email,
            'imageUrl': contact.personne.imageUrl,
          },
          'dateAjout': contact.dateAjout.toIso8601String(),
        },
      };

      print('📡 API Call: PUT $baseUrl');
      print('📦 Data: ${jsonEncode(requestBody)}');

      final response = await http
          .put(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ PUT Response - Status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Contact updated successfully');
          return true;
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ HTTP Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in updateContact: $e');
      throw Exception('❌ Error updating contact: $e');
    }
  }

  // ==================== DELETE CONTACT ====================
  static Future<bool> deleteContact(int id, int accountId) async {
    try {
      final url = '$baseUrl?id=$id&accountId=$accountId';
      print('📡 API Call: DELETE $url');

      final response = await http
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ DELETE Response - Status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Contact deleted successfully');
          return true;
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ HTTP Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in deleteContact: $e');
      throw Exception('❌ Error deleting contact: $e');
    }
  }

  // ==================== GET CONTACT BY ID ====================
  static Future<Contact?> getContactById(int id, int accountId) async {
    try {
      final url = '$baseUrl?action=getById&id=$id&accountId=$accountId';
      print('📡 API Call: GET $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ GET BY ID Response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Contact found');
          return Contact.fromJson(jsonResponse['data']);
        } else {
          print('⚠️ Contact not found: ${jsonResponse['message']}');
          return null;
        }
      } else {
        throw Exception(
          '❌ HTTP Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getContactById: $e');
      throw Exception('❌ Error finding contact: $e');
    }
  }

  // ==================== SEARCH CONTACTS ====================
  static Future<List<Contact>> searchContacts(
    String query,
    int accountId,
  ) async {
    try {
      final url =
          '$baseUrl?action=search&q=${Uri.encodeComponent(query)}&accountId=$accountId';
      print('📡 API Call: SEARCH $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ SEARCH Response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          print('🔍 ${data.length} results found');
          return data.map((json) => Contact.fromJson(json)).toList();
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ HTTP Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in searchContacts: $e');
      throw Exception('❌ Error searching contacts: $e');
    }
  }

  // ==================== TEST CONNECTION ====================
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing connection to: $baseUrl');

      final response = await http
          .get(
            Uri.parse('$baseUrl?accountId=1'), // Test with dummy account ID
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 401) {
        print('✅ API connection successful!');
        return true;
      } else {
        print('⚠️ API accessible but returned ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Cannot connect to API: $e');

      print('\n💡 Troubleshooting suggestions:');
      print('1. Check that XAMPP is running (Apache & MySQL)');
      print(
        '2. Test in browser: http://localhost/contacts_api/api_contacts.php?accountId=1',
      );
      print(
        '3. For Android emulator, use: http://10.0.2.2/contacts_api/api_contacts.php',
      );
      print('4. Check AndroidManifest.xml permissions');

      return false;
    }
  }
}
