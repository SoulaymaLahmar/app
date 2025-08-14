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
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      cout: (json['cout'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      statut: json['statut'] ?? 'planifie',
      description: json['description'],
      vehicule: json['vehicule'] ?? '',
      dateCreation: DateTime.parse(json['dateCreation'] ?? DateTime.now().toIso8601String()),
    );
  }
}
