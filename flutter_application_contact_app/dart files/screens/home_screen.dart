import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Contact.dart';
import '../services/api_services.dart';
import '../services/simcard_service.dart';
import '../widgets/contact_widget.dart';
import '../screens/login_screen.dart';
import '../screens/contact_details_screen.dart';
import '../screens/add_contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> contacts = [];
  bool isLoading = false;
  int? currentAccountId;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentAccountId = prefs.getInt('accountId');
      currentUsername = prefs.getString('username');
    });

    if (currentAccountId != null) {
      _loadContacts();
    }
  }

  Future<void> _loadContacts() async {
    if (currentAccountId == null) return;

    setState(() => isLoading = true);

    try {
      final loadedContacts = await ApiService.getAllContacts(currentAccountId!);
      setState(() {
        contacts = loadedContacts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar('Erreur de chargement: $e', isError: true);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contacts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            if (currentUsername != null)
              Text(
                '@$currentUsername',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.deepPurpleAccent),
              onPressed: _loadContacts,
              tooltip: 'Actualiser',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: _logout,
              tooltip: 'Déconnexion',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF1D1E33)],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                  strokeWidth: 3,
                ),
              )
            : contacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.contacts_outlined,
                        size: 80,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Aucun contact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Appuyez sur + pour ajouter un contact',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: Colors.deepPurpleAccent,
                backgroundColor: const Color(0xFF1D1E33),
                onRefresh: _loadContacts,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return ContactWidget(
                      contact: contacts[index],
                      onTap: () async {
                        // Navigate to contact details
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactDetailsScreen(
                              contact: contacts[index],
                              accountId: currentAccountId!,
                            ),
                          ),
                        );

                        // Reload if contact was updated or deleted
                        if (result == true) {
                          _loadContacts();
                        }
                      },
                      onCallPressed: () {
                        // Show SIM card selection if multiple numbers
                        _showCallOptions(contacts[index]);
                      },
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddContactScreen(accountId: currentAccountId!),
              ),
            );

            if (result == true) {
              _loadContacts();
            }
          },
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  Future<void> _showCallOptions(Contact contact) async {
    try {
      final simCards = await SimCardService.getSimCardsByContact(contact.id);

      if (simCards.isEmpty) {
        _showSnackbar('Aucune carte SIM pour ce contact');
        return;
      }

      if (simCards.length == 1) {
        _makeCall(simCards.first.numero, simCards.first.operateur);
        return;
      }

      // Show dialog to select SIM card
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.sim_card, color: Colors.deepPurpleAccent),
              const SizedBox(width: 12),
              const Text(
                'Choisir un numéro',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: simCards.map((simCard) {
              return ListTile(
                leading: _getOperatorIcon(simCard.operateur),
                title: Text(
                  simCard.numero,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  simCard.operateur,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _makeCall(simCard.numero, simCard.operateur);
                },
              );
            }).toList(),
          ),
        ),
      );
    } catch (e) {
      _showSnackbar('Erreur: $e', isError: true);
    }
  }

  Widget _getOperatorIcon(String operateur) {
    Color color;
    switch (operateur) {
      case 'Ooredoo':
        color = Colors.redAccent;
        break;
      case 'Mobilis':
        color = Colors.blueAccent;
        break;
      case 'Djezzy':
        color = Colors.orangeAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.sim_card, color: color, size: 24),
    );
  }

  void _makeCall(String numero, String operateur) {
    _showSnackbar('Appel vers $numero ($operateur)');
    // In a real app, use url_launcher to make the call
  }
}
