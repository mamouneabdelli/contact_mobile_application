class SimCard {
  final int id;
  final int contactId;
  final String operateur; // Ooredoo, Mobilis, Djezzy
  final String numero;
  final DateTime dateAjout;

  SimCard({
    required this.id,
    required this.contactId,
    required this.operateur,
    required this.numero,
    required this.dateAjout,
  });

  factory SimCard.fromJson(Map<String, dynamic> json) {
    return SimCard(
      id: json['id'] ?? 0,
      contactId: json['contactId'],
      operateur: json['operateur'],
      numero: json['numero'],
      dateAjout: DateTime.parse(json['dateAjout']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'operateur': operateur,
      'numero': numero,
      'dateAjout': dateAjout.toIso8601String(),
    };
  }
}
