// Updated VehicleDetailsScreen with proper historique and backend delete

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:stage/controllers/auth_controller.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  late Map<String, dynamic> vehicleData;
  Map<String, dynamic>? selectedDriver;
  List<Map<String, dynamic>> drivers = [];
  bool loadingDrivers = false;
  bool loadingVehicle = false;

  final String driverBaseUrl = 'http://10.0.2.2:5000/api/drivers';
  final String vehicleBaseUrl = 'http://10.0.2.2:5000/api/vehicles';

  @override
  void initState() {
    super.initState();
    vehicleData = Map<String, dynamic>.from(widget.vehicle);
    selectedDriver = vehicleData['responsable'];
    fetchDrivers();
  }

  // Helper method to safely convert values to String
  String _safeToString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Helper method to safely get string value
  String _safeGetString(Map<String, dynamic>? map, String key, [String defaultValue = '']) {
    if (map == null) return defaultValue;
    final value = map[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  Future<void> fetchVehicle() async {
    setState(() => loadingVehicle = true);
    try {
      final token = Get.find<AuthController>().token;
      final response = await http.get(
        Uri.parse('$vehicleBaseUrl/${vehicleData['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          vehicleData = Map<String, dynamic>.from(data);
          selectedDriver = vehicleData['responsable'];
        });
      } else {
        print('Erreur fetchVehicle: ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau fetchVehicle: $e');
    } finally {
      setState(() => loadingVehicle = false);
    }
  }

  Future<void> fetchDrivers() async {
    setState(() => loadingDrivers = true);
    try {
      final token = Get.find<AuthController>().token;
      final response = await http.get(
        Uri.parse(driverBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          drivers = data.map((d) => {
            '_id': _safeToString(d['_id']),
            'nom': _safeToString(d['nom']),
            'prenom': _safeToString(d['prenom']),
            'permis': _safeToString(d['permis']),
            'statut': _safeToString(d['statut']),
          }).toList();
        });
      } else {
        print('Erreur de chargement des conducteurs: ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau fetchDrivers: $e');
    } finally {
      setState(() => loadingDrivers = false);
    }
  }

  Future<void> assignDriver(String driverId) async {
    try {
      final token = Get.find<AuthController>().token;
      final response = await http.put(
        Uri.parse('$vehicleBaseUrl/${vehicleData['_id']}/assign-driver'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'driverId': driverId}),
      );

      if (response.statusCode == 200) {
        await fetchVehicle();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conducteur assigné avec succès')),
        );
      } else {
        print('Erreur assignation: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur assignation: ${response.body}')),
        );
      }
    } catch (e) {
      print('Erreur réseau assignDriver: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
  }

  Future<void> addEntretien(String type, String cout, DateTime date) async {
    try {
      final token = Get.find<AuthController>().token;

      // Determine status based on date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entretienDate = DateTime(date.year, date.month, date.day);

      String statut;
      if (entretienDate.isBefore(today)) {
        statut = 'termine'; // Past date = completed (historique)
      } else if (entretienDate.isAtSameMomentAs(today)) {
        statut = 'en_cours'; // Today = in progress
      } else {
        statut = 'planifie'; // Future date = planned (prochains entretiens)
      }

      final body = {
        'type': type,
        'cout': double.tryParse(cout) ?? 0.0,
        'date': date.toIso8601String().split('T')[0],
        'statut': statut,
      };

      final response = await http.post(
        Uri.parse('$vehicleBaseUrl/${vehicleData['_id']}/entretiens'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh vehicle data to get updated entretiens
        await fetchVehicle();

        String message;
        switch (statut) {
          case 'termine':
            message = 'Entretien ajouté à l\'historique';
            break;
          case 'en_cours':
            message = 'Entretien en cours ajouté';
            break;
          default:
            message = 'Entretien planifié avec succès';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        print('Erreur addEntretien: ${response.body}');
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${errorData['message'] ?? 'Erreur inconnue'}')),
        );
      }
    } catch (e) {
      print('Erreur réseau addEntretien: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
  }

  Future<void> deleteEntretien(Map<String, dynamic> entretien) async {
    try {
      final token = Get.find<AuthController>().token;
      final entretienId = entretien['_id'];

      if (entretienId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: ID de l\'entretien non trouvé')),
        );
        return;
      }

      // Use DELETE method with entretien ID in the URL
      final response = await http.delete(
        Uri.parse('$vehicleBaseUrl/${vehicleData['_id']}/entretiens/$entretienId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchVehicle();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entretien supprimé avec succès')),
        );
      } else {
        print('Erreur deleteEntretien: ${response.statusCode} - ${response.body}');
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${errorData['message'] ?? 'Impossible de supprimer l\'entretien'}')),
        );
      }
    } catch (e) {
      print('Erreur réseau deleteEntretien: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
  }


  Future<void> markEntretienAsCompleted(Map<String, dynamic> entretien) async {
    try {
      final token = Get.find<AuthController>().token;
      final entretienId = entretien['_id'];

      if (entretienId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: ID de l\'entretien non trouvé')),
        );
        return;
      }

      final body = {
        'statut': 'termine',
        'dateRealisation': DateTime.now().toIso8601String().split('T')[0],
      };

      final response = await http.put(
        Uri.parse('$vehicleBaseUrl/${vehicleData['_id']}/entretiens/$entretienId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await fetchVehicle();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entretien marqué comme terminé')),
        );
      } else {
        print('Erreur markCompleted: ${response.body}');
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${errorData['message'] ?? 'Erreur inconnue'}')),
        );
      }
    } catch (e) {
      print('Erreur réseau markCompleted: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
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
        if (loadingDrivers) {
          return const Center(child: CircularProgressIndicator());
        }
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
                    Navigator.of(context).pop();
                    assignDriver(driver['_id']);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicleImage = vehicleData['image'];
    final imageWidget = (vehicleImage != null && vehicleImage.toString().startsWith('http'))
        ? Image.network(vehicleImage, height: 180, fit: BoxFit.cover)
        : Image.asset(vehicleImage ?? 'assets/images/d73af822e7ae484561635ad1550fd784.jpg', height: 180);

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
                  GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: theme.colorScheme.primary)),
                  Text(_safeGetString(vehicleData, 'numeroSerie', "Numéro inconnu"),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: theme.colorScheme.primary,
                    onPressed: fetchVehicle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(borderRadius: BorderRadius.circular(16), child: imageWidget),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
                ),
                child: loadingVehicle
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${_safeGetString(vehicleData, 'marque')} ${_safeGetString(vehicleData, 'modele')}",
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoLine("Type", _safeGetString(vehicleData, 'type', "Inconnu"), theme),
                          _infoLine("État", _safeGetString(vehicleData, 'etat', "Non défini"), theme),
                          _infoLine("Date", _safeGetString(vehicleData, 'date', "Non spécifiée"), theme),
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
                                      ? "${_safeGetString(selectedDriver!, 'prenom')} ${_safeGetString(selectedDriver!, 'nom')}"
                                      : (vehicleData['responsable'] != null
                                      ? "${_safeGetString(vehicleData['responsable'], 'prenom')} ${_safeGetString(vehicleData['responsable'], 'nom')}"
                                      : "Aucun"),
                                  theme),
                              ElevatedButton.icon(
                                onPressed: _selectDriverDialog,
                                icon: const Icon(Icons.person_search),
                                label: const Text("Assigner"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          _circleIconInfo(Icons.speed, _safeGetString(vehicleData, 'kilometrage', "0"), "km", theme),
                          _circleIconInfo(Icons.local_gas_station, _safeGetString(vehicleData, 'carburant', "N/A"), "Carburant", theme),
                          _circleIconInfo(Icons.local_fire_department, _safeGetString(vehicleData, 'consommation', "0.0"), "L/100km", theme),
                        ],
                      ),
                      const SizedBox(height: 25),
                      EntretiensSection(
                        entretiensAVenir: List<Map<String, dynamic>>.from(vehicleData['entretiensAVenir'] ?? []),
                        historique: List<Map<String, dynamic>>.from(vehicleData['historiqueEntretiens'] ?? []),
                        onAdd: (type, cout, date) => addEntretien(type, cout, date),
                        onDelete: (entretien) => deleteEntretien(entretien),
                        onMarkCompleted: (entretien) => markEntretienAsCompleted(entretien),
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
}

// Updated EntretiensSection widget
class EntretiensSection extends StatefulWidget {
  final List<Map<String, dynamic>> entretiensAVenir;
  final List<Map<String, dynamic>> historique;
  final Future<void> Function(String type, String cout, DateTime date) onAdd;
  final Future<void> Function(Map<String, dynamic> entretien) onDelete;
  final Future<void> Function(Map<String, dynamic> entretien) onMarkCompleted;

  const EntretiensSection({
    super.key,
    required this.entretiensAVenir,
    required this.historique,
    required this.onAdd,
    required this.onDelete,
    required this.onMarkCompleted,
  });

  @override
  State<EntretiensSection> createState() => _EntretiensSectionState();
}

class _EntretiensSectionState extends State<EntretiensSection> {
  // Helper method to safely get string value
  String _safeGetString(Map<String, dynamic>? map, String key, [String defaultValue = '']) {
    if (map == null) return defaultValue;
    final value = map[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  // Helper method to format date
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Date inconnue';
    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return dateValue.toString();
      }
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateValue.toString();
    }
  }

  // Helper method to format cost
  String _formatCost(dynamic costValue) {
    if (costValue == null) return '0';
    if (costValue is num) {
      return costValue.toStringAsFixed(2);
    }
    try {
      final parsed = double.parse(costValue.toString());
      return parsed.toStringAsFixed(2);
    } catch (e) {
      return costValue.toString();
    }
  }

  // Helper method to determine if date is in the past
  bool _isDateInPast(dynamic dateValue) {
    if (dateValue == null) return false;
    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return false;
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entretienDate = DateTime(date.year, date.month, date.day);
      return entretienDate.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  // Helper method to determine if date is today
  bool _isDateToday(dynamic dateValue) {
    if (dateValue == null) return false;
    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return false;
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entretienDate = DateTime(date.year, date.month, date.day);
      return entretienDate.isAtSameMomentAs(today);
    } catch (e) {
      return false;
    }
  }

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
                    decoration: const InputDecoration(
                        labelText: 'Type / Description',
                        hintText: 'ex: Vidange, Révision, Pneus...'
                    ),
                    onSaved: (val) => type = val ?? '',
                    validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Coût (TND)',
                        hintText: 'ex: 150.50'
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (val) => cout = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Champ requis";
                      if (double.tryParse(val) == null) return "Montant invalide";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  StatefulBuilder(builder: (context, setStateSB) {
                    return Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(date == null ? "Choisir une date" : "Date: ${_formatDate(date)}"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12)
                        ),
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (selected != null) {
                            setStateSB(() => date = selected);
                          }
                        },
                      ),
                    );
                  }),
                  if (date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _isDateToday(date)
                            ? "📅 Entretien prévu pour aujourd'hui"
                            : _isDateInPast(date)
                            ? "⚠️ Cette date est dans le passé - sera ajoutée à l'historique"
                            : "✅ Entretien planifié pour le futur",
                        style: TextStyle(
                            fontSize: 12,
                            color: _isDateToday(date)
                                ? Colors.blue
                                : _isDateInPast(date)
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Annuler", style: TextStyle(color: actionColor))
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && date != null) {
                  _formKey.currentState!.save();
                  Navigator.of(context).pop();
                  await widget.onAdd(type, cout, date!);
                } else {
                  if (date == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez choisir une date'))
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white
              ),
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEntretienTile(Map<String, dynamic> entretien, bool isUpcoming) {
    final theme = Theme.of(context);
    final statut = _safeGetString(entretien, 'statut', 'planifie');

    // Determine colors and icons based on status and type
    IconData leadingIcon;
    Color iconColor;
    String statusText;

    if (isUpcoming) {
      if (_isDateToday(entretien['date'])) {
        leadingIcon = Icons.today;
        iconColor = Colors.orange;
        statusText = "Aujourd'hui";
      } else {
        leadingIcon = Icons.schedule;
        iconColor = Colors.blue;
        statusText = "Prévu le";
      }
    } else {
      leadingIcon = Icons.check_circle;
      iconColor = Colors.green;
      statusText = "Terminé le";
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(leadingIcon, color: iconColor),
        title: Text(
          _safeGetString(entretien, 'type', 'Type inconnu'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$statusText : ${_formatDate(entretien['date'])}"),
            Text(
              "Coût : ${_formatCost(entretien['cout'])} TND",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            if (!isUpcoming && entretien['dateRealisation'] != null)
              Text(
                "Réalisé le : ${_formatDate(entretien['dateRealisation'])}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUpcoming && !_isDateToday(entretien['date']))
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _showMarkCompletedDialog(entretien),
                tooltip: "Marquer comme terminé",
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(entretien),
              tooltip: "Supprimer",
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showMarkCompletedDialog(Map<String, dynamic> entretien) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Marquer comme terminé"),
        content: Text(
          "Voulez-vous marquer cet entretien comme terminé ?\n\n${_safeGetString(entretien, 'type', 'Type inconnu')}\n\nIl sera déplacé vers l'historique.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onMarkCompleted(entretien);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Marquer terminé", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> entretien) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer cet entretien ?\n\n${_safeGetString(entretien, 'type', 'Type inconnu')}\nCoût: ${_formatCost(entretien['cout'])} TND\nDate: ${_formatDate(entretien['date'])}\n\nCette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete(entretien);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final actionColor = isDark ? Colors.green : Colors.blue;

    // Filter and sort entretiens
    final upcomingEntretiens = widget.entretiensAVenir.where((e) {
      final statut = _safeGetString(e, 'statut', 'planifie');
      return statut == 'planifie' || statut == 'en_cours';
    }).toList();

    final historiqueEntretiens = widget.historique.where((e) {
      final statut = _safeGetString(e, 'statut', 'planifie');
      return statut == 'termine';
    }).toList();

    // Sort upcoming by date (ascending - nearest first)
    upcomingEntretiens.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['date'].toString());
        final dateB = DateTime.parse(b['date'].toString());
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    // Sort historique by date (descending - most recent first)
    historiqueEntretiens.sort((a, b) {
      try {
        final dateA = DateTime.parse((a['dateRealisation'] ?? a['date']).toString());
        final dateB = DateTime.parse((b['dateRealisation'] ?? b['date']).toString());
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "Gestion des Entretiens",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: actionColor, size: 28),
              onPressed: _ajouterEntretienDialog,
              tooltip: "Ajouter un entretien",
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Summary cards
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Icon(Icons.schedule, color: Colors.blue, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        '${upcomingEntretiens.length}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const Text('À venir', style: TextStyle(fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        '${historiqueEntretiens.length}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const Text('Terminés', style: TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Prochains entretiens
        ExpansionTile(
          initiallyExpanded: upcomingEntretiens.isNotEmpty,
          title: Row(
            children: [
              const Text("Prochains entretiens"),
              const SizedBox(width: 8),
              if (upcomingEntretiens.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: actionColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${upcomingEntretiens.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          leading: Icon(Icons.notifications_active, color: actionColor),
          children: upcomingEntretiens.isEmpty
              ? [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, color: Colors.grey[400], size: 48),
                  const SizedBox(width: 12),
                  Text(
                    "Aucun entretien planifié",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          ]
              : upcomingEntretiens
              .map((entretien) => _buildEntretienTile(entretien, true))
              .toList(),
        ),

        // Historique
        ExpansionTile(
          title: Row(
            children: [
              const Text("Historique"),
              const SizedBox(width: 8),
              if (historiqueEntretiens.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.lightGreen : Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${historiqueEntretiens.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          leading: Icon(Icons.history, color: isDark ? Colors.lightGreen : Colors.indigo),
          children: historiqueEntretiens.isEmpty
              ? [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, color: Colors.grey[400], size: 48),
                  const SizedBox(width: 12),
                  Text(
                    "Aucun entretien dans l'historique",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          ]
              : historiqueEntretiens
              .map((entretien) => _buildEntretienTile(entretien, false))
              .toList(),
        ),

        // Total cost summary
        if (historiqueEntretiens.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 16),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Coût total des entretiens:', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Text(
                    '${_calculateTotalCost(historiqueEntretiens)} TND',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _calculateTotalCost(List<Map<String, dynamic>> entretiens) {
    double total = 0.0;
    for (final entretien in entretiens) {
      try {
        final cost = entretien['cout'];
        if (cost != null) {
          if (cost is num) {
            total += cost.toDouble();
          } else {
            total += double.parse(cost.toString());
          }
        }
      } catch (e) {
        // Skip invalid cost values
      }
    }
    return total.toStringAsFixed(2);
  }
}