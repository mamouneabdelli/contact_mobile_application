import 'package:flutter/material.dart';
import '../models/Contact.dart';
import '../models/Personne.dart';
import '../models/SimCard.dart';
import '../services/api_services.dart';
import '../services/simcard_service.dart';

class AddContactScreen extends StatefulWidget {
  final int accountId;

  const AddContactScreen({super.key, required this.accountId});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();

  final List<_SimCardInput> _simCards = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau contact'),
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF1D1E33)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Information Section
              _buildSectionTitle('Informations du contact'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _prenomController,
                label: 'Prénom *',
                icon: Icons.person_outline,
                hint: 'Ahmed',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nomController,
                label: 'Nom *',
                icon: Icons.badge_outlined,
                hint: 'Benali',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _telephoneController,
                label: 'Téléphone principal *',
                icon: Icons.phone_outlined,
                hint: '0555123456',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'Email (optionnel)',
                icon: Icons.email_outlined,
                hint: 'ahmed.benali@email.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),

              // SIM Cards Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Cartes SIM'),
                  ElevatedButton.icon(
                    onPressed: _addSimCardInput,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_simCards.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1E33),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.deepPurpleAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.sim_card_outlined,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune carte SIM ajoutée',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              else
                ..._simCards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final simCard = entry.value;
                  return _buildSimCardCard(index, simCard);
                }),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enregistrer le contact',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
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
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.deepPurpleAccent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSimCardCard(int index, _SimCardInput simCard) {
    Color operatorColor;
    switch (simCard.operateur) {
      case 'Ooredoo':
        operatorColor = Colors.redAccent;
        break;
      case 'Mobilis':
        operatorColor = Colors.blueAccent;
        break;
      case 'Djezzy':
        operatorColor = Colors.orangeAccent;
        break;
      default:
        operatorColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: operatorColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: operatorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.sim_card, color: operatorColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Carte SIM ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _removeSimCardInput(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: simCard.operateur.isEmpty ? null : simCard.operateur,
            dropdownColor: const Color(0xFF111328),
            decoration: InputDecoration(
              labelText: 'Opérateur',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF111328),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['Ooredoo', 'Mobilis', 'Djezzy']
                .map(
                  (op) => DropdownMenuItem(
                    value: op,
                    child: Text(
                      op,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _simCards[index].operateur = value ?? '';
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: simCard.numeroController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Numéro',
              hintText: '0555123456',
              labelStyle: const TextStyle(color: Colors.grey),
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFF111328),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.phone, color: operatorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _addSimCardInput() {
    setState(() {
      _simCards.add(_SimCardInput());
    });
  }

  void _removeSimCardInput(int index) {
    setState(() {
      _simCards[index].numeroController.dispose();
      _simCards.removeAt(index);
    });
  }

  Future<void> _saveContact() async {
    // Validation
    if (_prenomController.text.isEmpty ||
        _nomController.text.isEmpty ||
        _telephoneController.text.isEmpty) {
      _showSnackbar(
        'Veuillez remplir tous les champs obligatoires',
        isError: true,
      );
      return;
    }

    // Validate SIM cards
    for (var simCard in _simCards) {
      if (simCard.operateur.isEmpty || simCard.numeroController.text.isEmpty) {
        _showSnackbar(
          'Veuillez compléter toutes les cartes SIM',
          isError: true,
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Create contact
      final newContact = Contact(
        id: 0,
        personne: Personne(
          nom: _nomController.text,
          prenom: _prenomController.text,
          telephone: _telephoneController.text,
          email: _emailController.text.isEmpty
              ? '${_prenomController.text.toLowerCase()}.${_nomController.text.toLowerCase()}@email.com'
              : _emailController.text,
        ),
        dateAjout: DateTime.now(),
      );

      final createdContact = await ApiService.createContact(
        newContact,
        widget.accountId,
      );

      // Add SIM cards
      for (var simCard in _simCards) {
        final newSimCard = SimCard(
          id: 0,
          contactId: createdContact.id,
          operateur: simCard.operateur,
          numero: simCard.numeroController.text,
          dateAjout: DateTime.now(),
        );
        await SimCardService.createSimCard(newSimCard);
      }

      if (mounted) {
        _showSnackbar('Contact créé avec succès!');
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackbar('Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    for (var simCard in _simCards) {
      simCard.numeroController.dispose();
    }
    super.dispose();
  }
}

class _SimCardInput {
  String operateur = '';
  final TextEditingController numeroController = TextEditingController();
}
