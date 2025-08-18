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
      id: _extractString(json['_id'] ?? json['id'], ''),
      marque: _extractString(json['marque'], ''),
      modele: _extractString(json['modele'], ''),
      numeroSerie: _extractString(json['numeroSerie'], ''),
      etat: _extractString(json['etat'], 'En service'),
      type: _extractString(json['type'], ''),
      kilometrage: _extractDouble(json['kilometrage'], 0.0),
      carburant: _extractString(json['carburant'], ''),
      consommation: _extractDouble(json['consommation'], 0.0),
      image: _extractStringNullable(json['image']),
      responsable: _extractStringNullable(json['responsable']),
      date: _extractDateTime(json['date']),
      coutVehicle: _extractDouble(json['coutVehicle'], 0.0),
    );
  }

  // Helper methods to safely extract values from JSON
  static String _extractString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is Map && value.containsKey('nom')) return value['nom']?.toString() ?? defaultValue;
    if (value is Map && value.containsKey('name')) return value['name']?.toString() ?? defaultValue;
    return value.toString();
  }

  static String? _extractStringNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map && value.containsKey('nom')) return value['nom']?.toString();
    if (value is Map && value.containsKey('name')) return value['name']?.toString();
    return value.toString();
  }

  static double _extractDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static DateTime _extractDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (value is Map && value.containsKey('\$date')) {
      // Handle MongoDB date format
      try {
        return DateTime.parse(value['\$date']);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'marque': marque,
      'modele': modele,
      'numeroSerie': numeroSerie,
      'etat': etat,
      'type': type,
      'kilometrage': kilometrage,
      'carburant': carburant,
      'consommation': consommation,
      'image': image,
      'responsable': responsable,
      'date': date.toIso8601String(),
      'coutVehicle': coutVehicle,
    };
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, marque: $marque, modele: $modele, etat: $etat)';
  }
}