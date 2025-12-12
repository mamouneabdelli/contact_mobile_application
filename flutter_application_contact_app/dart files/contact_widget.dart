import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/Contact.dart';

class ContactWidget extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onCallPressed;

  const ContactWidget({
    super.key,
    required this.contact,
    this.onTap,
    this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.blueGrey[800],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber,
          child: Text(
            contact.personne.initials,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.personne.fullName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          contact.personne.telephone,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: onCallPressed,
        ),
        onTap: onTap,
      ),
    );
  }
}
