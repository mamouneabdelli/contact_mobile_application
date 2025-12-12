import 'package:flutter_application_2/models/Personne.dart';

class Contact {
  final int id;
  final Personne personne;
  final DateTime dateAjout;

  Contact({required this.id, required this.personne, required this.dateAjout});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? 0,
      personne: Personne.fromJson(json['personne']),
      dateAjout: DateTime.parse(json['dateAjout']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personne': personne.toJson(),
      'dateAjout': dateAjout.toIso8601String(),
    };
  }
}
