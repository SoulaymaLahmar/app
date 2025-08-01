import 'package:flutter/material.dart';
import 'package:stage/view/vehicle_details_screen.dart';
import 'package:stage/view/widgets/custom_search_bar.dart';
import '../utils/app_textstyles.dart';

class VehiclesScreen extends StatefulWidget {
  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Map<String, dynamic>> vehicles = [
    {
      'marque': 'Toyota',
      'modele': 'Corolla',
      'numeroSerie': 'ABC123456',
      'date': '01/05/2021',
      'etat': 'En service',
      'type': 'Voiture',
      'historique': [
      ]
    },
    {
      'marque': 'Renault',
      'modele': 'Clio',
      'numeroSerie': 'XYZ987654',
      'date': '15/03/2022',
      'etat': 'En maintenance',
      'type': 'Voiture',
      'historique': [
        {'description': 'Révision complète', 'date': '2025-06-01 14:45'},
      ]
    },
  ];

  String searchQuery = '';

  List<Map<String, dynamic>> get filteredVehicles {
    return vehicles.where((v) {
      final data = '${v['marque']} ${v['modele']} ${v['numeroSerie']}'.toLowerCase();
      return data.contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _addVehicle(Map<String, dynamic> vehicle) {
    setState(() {
      vehicle['historique'] = [];
      vehicles.add(vehicle);
    });
    Navigator.of(context).pop();
  }

  void _deleteVehicle(int index) {
    setState(() => vehicles.removeAt(index));
  }

  void _updateStatus(int index, String newStatus) {
    setState(() => vehicles[index]['etat'] = newStatus);
  }

  void _addHistorique(int index, String description) {
    setState(() {
      vehicles[index]['historique'].add({
        'description': description,
        'date': DateTime.now().toString(),
      });
    });
  }

  void _showStatusDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = vehicles[index]['etat'];
        return AlertDialog(
          title: Text('Modifier l\'état'),
          content: DropdownButton<String>(
            value: selectedStatus,
            items: ['En service', 'En maintenance', 'Hors service']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _updateStatus(index, value);
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
  }

  void _showHistoriqueDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Ajouter une réparation / entretien'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Description'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addHistorique(index, controller.text);
                }
                Navigator.of(context).pop();
              },
              child: Text('Ajouter'),
            )
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En service':
        return Colors.green;
      case 'En maintenance':
        return Colors.orange;
      case 'Hors service':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _openAddVehicleForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddVehicleForm(onSubmit: _addVehicle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des Véhicules',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          CustomSearchBar(
            onChanged: (value) {
              setState(() => searchQuery = value);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                var vehicle = filteredVehicles[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.directions_car),
                    title: Text('${vehicle['marque']} ${vehicle['modele']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('N° Série: ${vehicle['numeroSerie']}'),
                        Text('Date: ${vehicle['date']}'),
                        Row(
                          children: [
                            Text('État: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              vehicle['etat'],
                              style: TextStyle(color: _getStatusColor(vehicle['etat'])),
                            ),
                          ],
                        ),
                        if (vehicle['historique'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: vehicle['historique'].map<Widget>((entry) =>
                                  Text("- ${entry['date'].toString().substring(0, 16)}: ${entry['description']}")).toList(),
                            ),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        final realIndex = vehicles.indexOf(vehicle);
                        if (value == 'delete') _deleteVehicle(realIndex);
                        if (value == 'update_status') _showStatusDialog(realIndex);
                        if (value == 'add_historique') _showHistoriqueDialog(realIndex);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'update_status', child: Text('Modifier l\'état')),
                        PopupMenuItem(value: 'add_historique', child: Text('Ajouter historique')),
                        PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddVehicleForm,
        child: Icon(Icons.add),
        tooltip: "Ajouter un véhicule",
      ),
    );
  }
}
class AddVehicleForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddVehicleForm({super.key, required this.onSubmit});

  @override
  _AddVehicleFormState createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {
  final _formKey = GlobalKey<FormState>();

  String marque = '';
  String modele = '';
  String numeroSerie = '';
  String etat = 'En service';
  String type = 'Voiture';
  DateTime? dateAcquisition;
  String kilometrage = '';
  String carburant = 'Essence';
  String consommation = '';
  String? imageUrl;

  void _submit() {
    if (_formKey.currentState!.validate() && dateAcquisition != null) {
      _formKey.currentState!.save();
      widget.onSubmit({
        'marque': marque,
        'modele': modele,
        'numeroSerie': numeroSerie,
        'date':
        "${dateAcquisition!.day}/${dateAcquisition!.month}/${dateAcquisition!.year}",
        'etat': etat,
        'type': type,
        'kilometrage': kilometrage,
        'carburant': carburant,
        'consommation': consommation,
        'image': imageUrl,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ajouter un véhicule",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                decoration: InputDecoration(labelText: 'Marque'),
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => marque = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Modèle'),
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => modele = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Numéro de série'),
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => numeroSerie = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kilométrage (km)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => kilometrage = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Type de carburant"),
                value: carburant,
                items: ['Essence', 'Diesel', 'Électrique', 'Hybride']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => carburant = value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Consommation (L/100km)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => consommation = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "État"),
                value: etat,
                items: ['En service', 'En maintenance', 'Hors service']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => etat = value!),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Type de véhicule"),
                value: type,
                items: ['Voiture', 'Camion', 'Moto']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => type = value!),
              ),
              TextFormField(
                decoration:
                InputDecoration(labelText: 'Lien de l\'image (optionnel)'),
                keyboardType: TextInputType.url,
                onSaved: (value) =>
                imageUrl = value?.isNotEmpty == true ? value : null,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(dateAcquisition == null
                        ? "Sélectionner la date d'acquisition"
                        : "Date: ${dateAcquisition!.day}/${dateAcquisition!.month}/${dateAcquisition!.year}"),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => dateAcquisition = picked);
                      }
                    },
                    child: Text("Sélectionner"),
                  )
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
