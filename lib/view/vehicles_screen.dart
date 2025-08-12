import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stage/view/vehicle_details_screen.dart';
import 'package:stage/view/widgets/custom_search_bar.dart';
import '../utils/app_textstyles.dart';

class VehiclesScreen extends StatefulWidget {
  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Map<String, dynamic>> vehicles = [];
  String searchQuery = '';
  bool isLoading = true;

  final baseUrl = 'http://10.0.2.2:5000/api/auth';
  final String vehicleBaseUrl = 'http://10.0.2.2:5000/api/vehicles';


  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      _fetchVehicles();
    });
  }

  Future<void> _fetchVehicles() async {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      debugPrint('Token introuvable, réessayez après connexion.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final res = await http.get(
        Uri.parse(vehicleBaseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          vehicles = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
        debugPrint('vehicles loaded: ${vehicles.length}');
      } else if (res.statusCode == 401) {
        debugPrint('Token expired or invalid');
        // token expiration - redirect to login
        setState(() {
          isLoading = false;
        });
      } else {
        debugPrint('Erreur récupération vehicules: ${res.statusCode} ${res.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Exception lors de la récupération des vehicules: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addVehicle(Map<String, dynamic> vehicle) async {
    final box = GetStorage();
    final token = box.read('token');
    final res = await http.post(
      Uri.parse(vehicleBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(vehicle),
    );

    if (res.statusCode == 201) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Véhicule ajouté avec succès")),
      );
      await _fetchVehicles(); // Always reload from backend
    } else {
      debugPrint('Erreur ${res.statusCode}: ${res.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout du véhicule")),
      );
    }
  }


  Future<void> _deleteVehicle(int index) async {
    final box = GetStorage();
    final token = box.read('token');
    final vehicleId = vehicles[index]['_id'];

    try {
      final res = await http.delete(
        Uri.parse('$vehicleBaseUrl/$vehicleId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          vehicles.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Véhicule supprimé avec succès')),
        );
      } else {
        debugPrint('Erreur suppression: ${res.statusCode} ${res.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression du véhicule')),
        );
      }
    } catch (e) {
      debugPrint('Exception suppression véhicule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau lors de la suppression')),
      );
    }
  }

  Future<void> _updateStatus(int index, String newStatus) async {
    final box = GetStorage();
    final token = box.read('token');
    final vehicleId = vehicles[index]['_id'];

    try {
      final res = await http.patch(
        Uri.parse('$vehicleBaseUrl/$vehicleId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'etat': newStatus}),
      );

      if (res.statusCode == 200) {
        setState(() {
          vehicles[index]['etat'] = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('État mis à jour')),
        );
      } else {
        debugPrint('Erreur mise à jour état: ${res.statusCode} ${res.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour de l\'état')),
        );
      }
    } catch (e) {
      debugPrint('Exception mise à jour état: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau lors de la mise à jour de l\'état')),
      );
    }
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
            onChanged: (value) async {
            if (value != null) {
            await _updateStatus(index, value);
            Navigator.of(context).pop();
            }
            },

          ),
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

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Gestion des Chauffeurs',
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );

    }

    final filteredVehicles = vehicles.where((vehicle) {
      final data = '${vehicle['marque']} ${vehicle['modele']} ${vehicle['numeroSerie']}'.toLowerCase();
      return data.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des Chauffeurs',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _fetchVehicles();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          if (vehicles.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun véhicule trouvé',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Appuyez sur + pour ajouter un véhicule',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchVehicles,
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
                          Text('Type: ${vehicle['type']}'),
                          Row(
                            children: [
                              Text('État: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                vehicle['etat'],
                                style: TextStyle(color: _getStatusColor(vehicle['etat'])),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          final realIndex = vehicles.indexOf(vehicle);
                          if (value == 'delete') _deleteVehicle(realIndex);
                          if (value == 'update_status') _showStatusDialog(realIndex);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'update_status', child: Text('Modifier l\'état')),
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
              )
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
  bool isSubmitting = false;

  void _submit() {
    if (_formKey.currentState!.validate() && !isSubmitting) {
      _formKey.currentState!.save();
      setState(() {
        isSubmitting = true;
      });
      widget.onSubmit({
        'marque': marque.trim(),
        'modele': modele.trim(),
        'numeroSerie': numeroSerie.trim(),
        'date':
        "${dateAcquisition!.day}/${dateAcquisition!.month}/${dateAcquisition!.year}",
        'etat': etat,
        'type': type,
        'kilometrage': kilometrage.trim(),
        'carburant': carburant.trim(),
        'consommation': consommation.trim(),
        'image': imageUrl,
      });

      setState(() {
        isSubmitting = false;
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
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Marque', border: OutlineInputBorder(),),
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => marque = value!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Modèle', border: OutlineInputBorder()),
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => modele = value!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Numéro de série', border: OutlineInputBorder()),
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => numeroSerie = value!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kilométrage (km)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => kilometrage = value!,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Type de carburant", border: OutlineInputBorder()),
                value: carburant,
                items: ['Essence', 'Diesel', 'Électrique', 'Hybride']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => carburant = value!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Consommation (L/100km)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => consommation = value!,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "État", border: OutlineInputBorder()),
                value: etat,
                items: ['En service', 'En maintenance', 'Hors service']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => etat = value!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Type de véhicule", border: OutlineInputBorder()),
                value: type,
                items: ['Voiture', 'Camion', 'Moto']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => type = value!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration:
                InputDecoration(labelText: 'Lien de l\'image (optionnel)', border: OutlineInputBorder()),
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
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      child: isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text("Ajouter"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
