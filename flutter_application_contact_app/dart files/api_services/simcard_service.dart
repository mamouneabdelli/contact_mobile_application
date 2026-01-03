import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/SimCard.dart';

class SimCardService {
  static const String baseUrl = 'http://localhost/contacts_api/api_simcard.php';
  
  // For Android emulator
  // static const String baseUrl = 'http://10.0.2.2/contacts_api/api_simcard.php';

  // ==================== GET SIM CARDS BY CONTACT ====================
  static Future<List<SimCard>> getSimCardsByContact(int contactId) async {
    try {
      print('📞 Fetching SIM cards for contact: $contactId');

      final response = await http
          .get(
            Uri.parse('$baseUrl?action=getByContact&contactId=$contactId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ SIM cards response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          print('📱 ${data.length} SIM cards loaded');
          return data.map((json) => SimCard.fromJson(json)).toList();
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('❌ HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getSimCardsByContact: $e');
      throw Exception('❌ Network error: $e');
    }
  }

  // ==================== CREATE SIM CARD ====================
  static Future<SimCard> createSimCard(SimCard simCard) async {
    try {
      final Map<String, dynamic> requestBody = {
        'action': 'create',
        'simCard': {
          'contactId': simCard.contactId,
          'operateur': simCard.operateur,
          'numero': simCard.numero,
        },
      };

      print('📞 Creating SIM card');
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

      print('✅ Create SIM card response - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ SIM card created successfully');
          return SimCard.fromJson(jsonResponse['data']);
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('❌ HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in createSimCard: $e');
      throw Exception('❌ Error creating SIM card: $e');
    }
  }

  // ==================== UPDATE SIM CARD ====================
  static Future<bool> updateSimCard(int id, SimCard simCard) async {
    try {
      final Map<String, dynamic> requestBody = {
        'action': 'update',
        'id': id,
        'simCard': {
          'operateur': simCard.operateur,
          'numero': simCard.numero,
        },
      };

      print('📞 Updating SIM card: $id');

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

      print('✅ Update SIM card response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ SIM card updated successfully');
          return true;
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('❌ HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in updateSimCard: $e');
      throw Exception('❌ Error updating SIM card: $e');
    }
  }

  // ==================== DELETE SIM CARD ====================
  static Future<bool> deleteSimCard(int id) async {
    try {
      final url = '$baseUrl?id=$id';
      print('📞 Deleting SIM card: $url');

      final response = await http
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Delete SIM card response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ SIM card deleted successfully');
          return true;
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('❌ HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteSimCard: $e');
      throw Exception('❌ Error deleting SIM card: $e');
    }
  }

  // ==================== GET SIM CARDS BY OPERATOR ====================
  static Future<List<SimCard>> getSimCardsByOperator(String operateur) async {
    try {
      print('📞 Fetching SIM cards for operator: $operateur');

      final response = await http
          .get(
            Uri.parse('$baseUrl?action=getByOperator&operateur=$operateur'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ SIM cards by operator response - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          print('📱 ${data.length} SIM cards loaded for $operateur');
          return data.map((json) => SimCard.fromJson(json)).toList();
        } else {
          throw Exception('❌ API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('❌ HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getSimCardsByOperator: $e');
      throw Exception('❌ Network error: $e');
    }
  }
}
