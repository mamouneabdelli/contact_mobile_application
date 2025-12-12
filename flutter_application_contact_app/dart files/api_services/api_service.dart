// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/models/Contact.dart';

class ApiService {
  // Pour XAMPP standard (port 80) - Windows/Mac
  static const String baseUrl =
      'http://localhost/contacts_api/api_contacts.php';

  // Pour Android emulator
  // static const String baseUrl = 'http://10.0.2.2/contacts_api/api_contacts.php';

  // ==================== GET ALL CONTACTS ====================
  static Future<List<Contact>> getAllContacts() async {
    try {
      print('📡 Appel API: GET $baseUrl');

      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Réponse GET - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          print('📱 ${data.length} contacts chargés avec succès');
          return data.map((json) => Contact.fromJson(json)).toList();
        } else {
          throw Exception('❌ Erreur API: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ Erreur HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur dans getAllContacts: $e');

      // Messages d'erreur plus précis
      if (e is http.ClientException) {
        throw Exception(
          '❌ Impossible de se connecter au serveur. Vérifiez que XAMPP est démarré.',
        );
      } else if (e is FormatException) {
        throw Exception(
          '❌ Réponse invalide du serveur. Vérifiez votre API PHP.',
        );
      } else {
        throw Exception('❌ Erreur réseau: $e');
      }
    }
  }

  // ==================== CREATE CONTACT ====================
  static Future<Contact> createContact(Contact contact) async {
    try {
      // Préparer les données pour l'API
      final Map<String, dynamic> requestBody = {
        'action': 'create',
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

      print('📡 Appel API: POST $baseUrl');
      print('📦 Données envoyées: ${jsonEncode(requestBody)}');

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

      print('✅ Réponse POST - Status: ${response.statusCode}');
      print('📄 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Contact créé avec succès');
          return Contact.fromJson(jsonResponse['data']);
        } else {
          throw Exception('❌ Erreur API: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ Erreur HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur dans createContact: $e');
      throw Exception('❌ Erreur lors de la création: $e');
    }
  }

  // ==================== UPDATE CONTACT ====================
  static Future<bool> updateContact(int id, Contact contact) async {
    try {
      // Préparer les données pour l'API
      final Map<String, dynamic> requestBody = {
        'action': 'update',
        'id': id,
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

      print('📡 Appel API: PUT $baseUrl');
      print('📦 Données envoyées: ${jsonEncode(requestBody)}');

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

      print('✅ Réponse PUT - Status: ${response.statusCode}');
      print('📄 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Contact mis à jour avec succès');
          return true;
        } else {
          throw Exception('❌ Erreur API: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ Erreur HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur dans updateContact: $e');
      throw Exception('❌ Erreur lors de la mise à jour: $e');
    }
  }

  // ==================== DELETE CONTACT ====================
  static Future<bool> deleteContact(int id) async {
    try {
      final url = '$baseUrl?id=$id';
      print('📡 Appel API: DELETE $url');

      final response = await http
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Réponse DELETE - Status: ${response.statusCode}');
      print('📄 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Contact supprimé avec succès');
          return true;
        } else {
          throw Exception('❌ Erreur API: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ Erreur HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur dans deleteContact: $e');
      throw Exception('❌ Erreur lors de la suppression: $e');
    }
  }

  // ==================== GET CONTACT BY ID ====================
  static Future<Contact?> getContactById(int id) async {
    try {
      final url = '$baseUrl?action=getById&id=$id';
      print('📡 Appel API: GET $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Réponse GET BY ID - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Contact trouvé');
          return Contact.fromJson(jsonResponse['data']);
        } else {
          print('⚠️ Contact non trouvé: ${jsonResponse['message']}');
          return null;
        }
      } else {
        throw Exception(
          '❌ Erreur HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur dans getContactById: $e');
      throw Exception('❌ Erreur lors de la recherche: $e');
    }
  }

  // ==================== SEARCH CONTACTS ====================
  static Future<List<Contact>> searchContacts(String query) async {
    try {
      final url = '$baseUrl?action=search&q=${Uri.encodeComponent(query)}';
      print('📡 Appel API: SEARCH $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Réponse SEARCH - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          print('🔍 ${data.length} résultats trouvés');
          return data.map((json) => Contact.fromJson(json)).toList();
        } else {
          throw Exception('❌ Erreur API: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          '❌ Erreur HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur dans searchContacts: $e');
      throw Exception('❌ Erreur lors de la recherche: $e');
    }
  }

  // ==================== TEST CONNEXION ====================
  static Future<bool> testConnection() async {
    try {
      print('🔍 Test de connexion à: $baseUrl');

      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✅ Connexion API réussie!');
        return true;
      } else {
        print('❌ API accessible mais erreur ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Impossible de se connecter à l\'API: $e');

      // Suggestions de dépannage
      print('\n💡 Suggestions de dépannage:');
      print('1. Vérifiez que XAMPP est démarré (Apache & MySQL)');
      print(
        '2. Testez dans le navigateur: http://localhost/contacts_api/api_contacts.php',
      );
      print(
        '3. Pour Android emulator, utilisez: http://10.0.2.2/contacts_api/api_contacts.php',
      );
      print('4. Vérifiez les permissions dans AndroidManifest.xml');

      return false;
    }
  }
}
