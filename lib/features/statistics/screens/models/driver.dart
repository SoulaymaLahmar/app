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
      id: json['_id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      permis: json['permis'] ?? '',
      telephone: json['telephone'] ?? '',
      statut: json['statut'] ?? 'Disponible',
      photo: json['photo'],
    );
  }

  String get fullName => '$nom $prenom';

  // Mock data for statistics (you can enhance this based on actual trip data)
  double get drivingScore => 75 + (id.hashCode % 25).toDouble(); // Mock score 75-100
  double get ecoScore => 70 + (id.hashCode % 30).toDouble(); // Mock eco score 70-100
  int get totalKm => 8000 + (id.hashCode % 12000); // Mock km 8000-20000
  int get totalTrips => 25 + (id.hashCode % 35); // Mock trips 25-60
}