class Entretien {
  final String id;
  final String type;
  final double cout;
  final DateTime date;
  final String statut;
  final String? description;
  final String vehicule;
  final DateTime dateCreation;

  Entretien({
    required this.id,
    required this.type,
    required this.cout,
    required this.date,
    required this.statut,
    this.description,
    required this.vehicule,
    required this.dateCreation,
  });

  factory Entretien.fromJson(Map<String, dynamic> json) {
    return Entretien(
      id: _extractString(json['_id'] ?? json['id'], ''),
      type: _extractString(json['type'], ''),
      cout: _extractDouble(json['cout'], 0.0),
      date: _extractDateTime(json['date']),
      statut: _extractString(json['statut'], 'planifie'),
      description: _extractStringNullable(json['description']),
      vehicule: _extractString(json['vehicule'] ?? json['vehicle'], ''),
      dateCreation: _extractDateTime(json['dateCreation'] ?? json['createdAt']),
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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'cout': cout,
      'date': date.toIso8601String(),
      'statut': statut,
      'description': description,
      'vehicule': vehicule,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Entretien(id: $id, type: $type, cout: $cout, statut: $statut)';
  }
}