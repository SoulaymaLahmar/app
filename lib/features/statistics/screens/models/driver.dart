class Driver {
  final String id;
  final String nom;
  final String prenom;
  final String permis;
  final String telephone;
  final String statut;
  final String? photo;

  Driver({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.permis,
    required this.telephone,
    required this.statut,
    this.photo,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: _extractString(json['_id'] ?? json['id'], ''),
      nom: _extractString(json['nom'] ?? json['lastName'], ''),
      prenom: _extractString(json['prenom'] ?? json['firstName'], ''),
      permis: _extractString(json['permis'] ?? json['license'], ''),
      telephone: _extractString(json['telephone'] ?? json['phone'], ''),
      statut: _extractString(json['statut'] ?? json['status'], 'Disponible'),
      photo: _extractStringNullable(json['photo'] ?? json['image']),
    );
  }

  // Helper methods to safely extract values from JSON
  static String _extractString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is Map && value.containsKey('nom')) return value['nom']?.toString() ?? defaultValue;
    if (value is Map && value.containsKey('name')) return value['name']?.toString() ?? defaultValue;
    if (value is Map && value.containsKey('_id')) return value['_id']?.toString() ?? defaultValue;
    return value.toString();
  }

  static String? _extractStringNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value.containsKey('nom')) return value['nom']?.toString();
    if (value is Map && value.containsKey('name')) return value['name']?.toString();
    return value.toString();
  }

  String get fullName => '$nom $prenom';

  // Mock data for statistics (you can enhance this based on actual trip data)
  double get drivingScore => 75 + (id.hashCode % 25).toDouble(); // Mock score 75-100
  double get ecoScore => 70 + (id.hashCode % 30).toDouble(); // Mock eco score 70-100
  int get totalKm => 8000 + (id.hashCode % 12000); // Mock km 8000-20000
  int get totalTrips => 25 + (id.hashCode % 35); // Mock trips 25-60

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nom': nom,
      'prenom': prenom,
      'permis': permis,
      'telephone': telephone,
      'statut': statut,
      'photo': photo,
    };
  }

  @override
  String toString() {
    return 'Driver(id: $id, fullName: $fullName, statut: $statut)';
  }
}