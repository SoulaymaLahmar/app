class Vehicle {
  final String id;
  final String marque;
  final String modele;
  final String numeroSerie;
  final String etat;
  final String type;
  final double kilometrage;
  final String carburant;
  final double consommation;
  final String? image;
  final String? responsable;
  final DateTime date;
  final double coutVehicle;

  Vehicle({
    required this.id,
    required this.marque,
    required this.modele,
    required this.numeroSerie,
    required this.etat,
    required this.type,
    required this.kilometrage,
    required this.carburant,
    required this.consommation,
    this.image,
    this.responsable,
    required this.date,
    required this.coutVehicle,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? '',
      marque: json['marque'] ?? '',
      modele: json['modele'] ?? '',
      numeroSerie: json['numeroSerie'] ?? '',
      etat: json['etat'] ?? 'En service',
      type: json['type'] ?? '',
      kilometrage: (json['kilometrage'] ?? 0).toDouble(),
      carburant: json['carburant'] ?? '',
      consommation: (json['consommation'] ?? 0).toDouble(),
      image: json['image'],
      responsable: json['responsable'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      coutVehicle: (json['coutVehicle'] ?? 0).toDouble(),
    );
  }

  double get efficiency {
    // Calculate efficiency based on consumption (lower consumption = higher efficiency)
    if (consommation <= 0) return 0;
    final maxEfficiency = 100.0;
    final baseConsumption = 10.0; // Base consumption for 0% efficiency
    return ((baseConsumption - consommation) / baseConsumption * maxEfficiency).clamp(0, 100);
  }

  String get status {
    if (efficiency >= 85) return 'Excellent';
    if (efficiency >= 70) return 'Bon';
    if (efficiency >= 50) return 'Moyen';
    return 'Faible';
  }
}
