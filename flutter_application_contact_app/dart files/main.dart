import 'package:flutter/material.dart';
import 'package:flutter_application_2/Widgets/contact_widget.dart';
import 'package:flutter_application_2/models/Contact.dart';
import 'package:flutter_application_2/models/Personne.dart';
import 'package:flutter_application_2/services/api_service.dart';

void main() => runApp(const ContactApp());

class ContactApp extends StatelessWidget {
  const ContactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactHomePage(),
    );
  }
}

class ContactHomePage extends StatefulWidget {
  @override
  _ContactHomePageState createState() => _ContactHomePageState();
}

class _ContactHomePageState extends State<ContactHomePage> {
  List<Contact> contacts = [];
  bool isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Charger les contacts depuis l'API
  Future<void> _loadContacts() async {
    setState(() => isLoading = true);

    try {
      final loadedContacts = await ApiService.getAllContacts();
      setState(() {
        contacts = loadedContacts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Erreur de chargement: $e');
    }
  }

  void _showAddContactForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  hintText: '+213 555 0000',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_firstNameController.text.isNotEmpty &&
                  _lastNameController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty) {
                _addContact(
                  _firstNameController.text,
                  _lastNameController.text,
                  _phoneController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
  }

  // Ajouter un contact via l'API
  Future<void> _addContact(
    String firstName,
    String lastName,
    String phone,
  ) async {
    // Création d'un contact temporaire avec id = 0
    // L'API va remplacer cet id par le vrai id généré
    final newContact = Contact(
      id: 0, // ID temporaire, sera remplacé par l'API
      personne: Personne(
        nom: lastName,
        prenom: firstName,
        telephone: phone,
        email: "${firstName.toLowerCase()}.${lastName.toLowerCase()}@email.com",
      ),
      dateAjout: DateTime.now(),
    );

    try {
      final createdContact = await ApiService.createContact(newContact);

      setState(() {
        contacts.add(createdContact);
      });

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$firstName $lastName ajouté!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur d\'ajout: $e');
    }
  }

  // Modifier un contact
  void _showEditContactForm(Contact contact) {
    _firstNameController.text = contact.personne.prenom;
    _lastNameController.text = contact.personne.nom;
    _phoneController.text = contact.personne.telephone;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_firstNameController.text.isNotEmpty &&
                  _lastNameController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty) {
                _updateContact(
                  contact.id,
                  _firstNameController.text,
                  _lastNameController.text,
                  _phoneController.text,
                  contact.personne.email,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  // Mettre à jour un contact via l'API
  Future<void> _updateContact(
    int id,
    String firstName,
    String lastName,
    String phone,
    String email,
  ) async {
    final updatedContact = Contact(
      id: id,
      personne: Personne(
        nom: lastName,
        prenom: firstName,
        telephone: phone,
        email: email,
      ),
      dateAjout: DateTime.now(),
    );

    try {
      final success = await ApiService.updateContact(id, updatedContact);

      if (success) {
        await _loadContacts(); // Recharger la liste
        _clearForm();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact modifié avec succès!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de modification: $e');
    }
  }

  // Supprimer un contact
  Future<void> _deleteContact(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer $name ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ApiService.deleteContact(id);

        if (success) {
          setState(() {
            contacts.removeWhere((c) => c.id == id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name supprimé'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        _showErrorSnackbar('Erreur de suppression: $e');
      }
    }
  }

  void _makeCall(String name, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appeler'),
        content: Text('Appeler $name au $phone ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Appel de $name...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }

  void _viewContact(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contact.personne.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Téléphone: ${contact.personne.telephone}'),
            const SizedBox(height: 8),
            Text('Email: ${contact.personne.email}'),
            const SizedBox(height: 8),
            Text('Ajouté le: ${_formatDate(contact.dateAjout)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditContactForm(contact);
            },
            child: const Text('Modifier'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteContact(contact.id, contact.personne.fullName);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            : contacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.contacts_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Aucun contact',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Appuyez sur + pour ajouter un contact',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadContacts,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return ContactWidget(
                      contact: contacts[index],
                      onTap: () => _viewContact(contacts[index]),
                      onCallPressed: () => _makeCall(
                        contacts[index].personne.fullName,
                        contacts[index].personne.telephone,
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactForm,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
