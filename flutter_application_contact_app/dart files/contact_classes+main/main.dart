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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: ContactHomePage(),
    );
  }
}

class ContactHomePage extends StatefulWidget {
  const ContactHomePage({super.key});

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
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_add,
                color: Colors.deepPurpleAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ajouter un Contact',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyledTextField(
                controller: _firstNameController,
                label: 'Prénom',
                icon: Icons.person_outline,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              _buildStyledTextField(
                controller: _lastNameController,
                label: 'Nom',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              _buildStyledTextField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
                hint: '+213 555 0000',
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
            style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Ajouter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: const Color(0xFF111328),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.deepPurpleAccent,
            width: 2,
          ),
        ),
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
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('$firstName $lastName ajouté!'),
            ],
          ),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit, color: Colors.blueAccent, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              'Modifier le Contact',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyledTextField(
                controller: _firstNameController,
                label: 'Prénom',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildStyledTextField(
                controller: _lastNameController,
                label: 'Nom',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              _buildStyledTextField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
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
            style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Modifier',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Contact modifié avec succès!'),
              ],
            ),
            backgroundColor: Colors.blueAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
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
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirmer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous vraiment supprimer $name ?',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
              content: Row(
                children: [
                  const Icon(Icons.delete_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('$name supprimé'),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.phone,
                color: Color(0xFF00C853),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Appeler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Appeler $name au $phone ?',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.phone_in_talk, color: Colors.white),
                      const SizedBox(width: 12),
                      Text('Appel de $name...'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF00C853),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Appeler',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _viewContact(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurpleAccent,
              child: Text(
                contact.personne.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                contact.personne.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.phone, 'Téléphone', contact.personne.telephone),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', contact.personne.email),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Ajouté le',
              _formatDate(contact.dateAjout),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditContactForm(contact);
            },
            icon: const Icon(Icons.edit, size: 20),
            label: const Text('Modifier'),
            style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _deleteContact(contact.id, contact.personne.fullName);
            },
            icon: const Icon(Icons.delete, size: 20),
            label: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111328),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurpleAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
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
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: const Text(
          'Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
          onPressed: _showAddContactForm,
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }
}
