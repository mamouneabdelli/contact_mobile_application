class Account {
  final int id;
  final String username;
  final String password;
  final int personneId;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.username,
    required this.password,
    required this.personneId,
    required this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? 0,
      username: json['username'],
      password: json['password'],
      personneId: json['personneId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'personneId': personneId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
