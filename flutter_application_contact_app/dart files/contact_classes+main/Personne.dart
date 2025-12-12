class Personne {
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final String? imageUrl;

  Personne({
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    this.imageUrl,
  });

  factory Personne.fromJson(Map<String, dynamic> json) {
    return Personne(
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      email: json['email'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'imageUrl': imageUrl,
    };
  }

  String get initials => '${prenom[0]}${nom[0]}'.toUpperCase();

  String get fullName => '$prenom $nom';
}
