import 'package:flutter/material.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  Map<String, dynamic>? selectedDriver;

  final List<Map<String, dynamic>> drivers = [
    {
      'nom': 'Ben Ali',
      'prenom': 'Mohamed',
      'permis': 'TN123456',
      'statut': 'Disponible',
    },
    {
      'nom': 'Trabelsi',
      'prenom': 'Hichem',
      'permis': 'TN654321',
      'statut': 'Occupé',
    },
    {
      'nom': 'Jouini',
      'prenom': 'Sami',
      'permis': 'TN111222',
      'statut': 'Inactif',
    }
  ];

  @override
  void initState() {
    super.initState();
    selectedDriver = widget.vehicle['responsable'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicleImage = widget.vehicle['image'];
    final imageWidget = (vehicleImage != null && vehicleImage.toString().startsWith('http'))
        ? Image.network(vehicleImage, height: 180, fit: BoxFit.cover)
        : Image.asset(vehicleImage ?? 'assets/images/Toyota_Corolla_1.8_VVT-i_Hybrid_Team_Deutschland_(XII)_–_f_03012021 (1).jpg', height: 180);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: theme.colorScheme.primary),
                  ),
                  Text(widget.vehicle['numeroSerie'] ?? "Numéro inconnu",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Icon(Icons.file_copy_outlined, color: theme.colorScheme.primary),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${widget.vehicle['marque']} ${widget.vehicle['modele']}",
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoLine("Type", widget.vehicle['type'] ?? "Inconnu", theme),
                          _infoLine("État", widget.vehicle['etat'] ?? "Non défini", theme),
                          _infoLine("Date", widget.vehicle['date'] ?? "Non spécifiée", theme),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _infoLine(
                                  "Conducteur",
                                  selectedDriver != null
                                      ? "${selectedDriver!['prenom']} ${selectedDriver!['nom']}"
                                      : "Aucun",
                                  theme),
                              ElevatedButton.icon(
                                onPressed: _selectDriverDialog,
                                icon: const Icon(Icons.person_search),
                                label: const Text("Assigner"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _circleIconInfo(Icons.speed, widget.vehicle['kilometrage'] ?? "0", "km", theme),
                          _circleIconInfo(Icons.local_gas_station, widget.vehicle['carburant'] ?? "N/A", "Carburant", theme),
                          _circleIconInfo(Icons.local_fire_department,
                              widget.vehicle['consommation'] ?? "0.0", "L/100km", theme),
                        ],
                      ),
                      const SizedBox(height: 25),
                      EntretiensSection(
                        entretiensAVenir: List<Map<String, String>>.from(widget.vehicle['entretiensAVenir'] ?? []),
                        historique: List<Map<String, String>>.from(widget.vehicle['historiqueEntretiens'] ?? []),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _circleIconInfo(IconData icon, String value, String unit, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.secondary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(unit, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _selectDriverDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choisir un conducteur"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("${driver['prenom']} ${driver['nom']}"),
                  subtitle: Text("Permis: ${driver['permis']}"),
                  trailing: Text(
                    driver['statut'],
                    style: TextStyle(color: _statusColor(driver['statut'], theme)),
                  ),
                  onTap: () {
                    setState(() {
                      selectedDriver = driver;
                      widget.vehicle['responsable'] = driver;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status) {
      case "Disponible":
        return Colors.green;
      case "Occupé":
        return Colors.orange;
      case "Inactif":
        return Colors.red;
      default:
        return theme.colorScheme.onSurface;
    }
  }
}


class EntretiensSection extends StatefulWidget {
  final List<Map<String, String>> entretiensAVenir;
  final List<Map<String, String>> historique;

  const EntretiensSection({
    super.key,
    required this.entretiensAVenir,
    required this.historique,
  });

  @override
  State<EntretiensSection> createState() => _EntretiensSectionState();
}

class _EntretiensSectionState extends State<EntretiensSection> {
  void _ajouterEntretienDialog() {
    final _formKey = GlobalKey<FormState>();
    String type = '';
    String cout = '';
    DateTime? date;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final actionColor = isDark ? Colors.green : Colors.blue;

        return AlertDialog(
          title: const Text("Ajouter un entretien"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Type / Description'),
                    onSaved: (val) => type = val ?? '',
                    validator: (val) => val!.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Coût'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => cout = val ?? '',
                    validator: (val) => val!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(date == null ? "Choisir une date" : "Date: ${date!.toLocal()}".split(' ')[0]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selected != null) {
                        setState(() {
                          date = selected;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Annuler", style: TextStyle(color: actionColor)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && date != null) {
                  _formKey.currentState!.save();
                  final newEntry = {
                    'type': '$type - ${cout} TND',
                    'date': date!.toIso8601String().split('T')[0],
                  };

                  setState(() {
                    if (date!.isAfter(DateTime.now())) {
                      widget.entretiensAVenir.add(newEntry);
                    } else {
                      widget.historique.add(newEntry);
                    }
                  });

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final actionColor = isDark ? Colors.green : Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Planification des Entretiens",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: actionColor),
              onPressed: _ajouterEntretienDialog,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ExpansionTile(
          title: const Text("Prochains entretiens"),
          leading: Icon(Icons.notifications_active, color: actionColor),
          children: widget.entretiensAVenir
              .map((e) => ListTile(
            title: Text(e['type'] ?? ''),
            subtitle: Text("Prévu le : ${e['date'] ?? ''}"),
          ))
              .toList(),
        ),
        ExpansionTile(
          title: const Text("Historique"),
          leading: Icon(Icons.history, color: isDark ? Colors.lightGreen : Colors.indigo),
          children: widget.historique
              .map((e) => ListTile(
            title: Text(e['type'] ?? ''),
            subtitle: Text("Effectué le : ${e['date'] ?? ''}"),
          ))
              .toList(),
        ),
      ],
    );
  }
}


