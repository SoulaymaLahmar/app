import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stage/view/widgets/custom_search_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_textstyles.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  List<Map<String, dynamic>> drivers = [];
  String searchQuery = '';
  bool isLoading = true;

  final baseUrl = 'http://10.0.2.2:5000/api/auth';
  final String driverBaseUrl = 'http://10.0.2.2:5000/api/drivers';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      _fetchDrivers();
    });
  }

  Future<void> _fetchDrivers() async {
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
        Uri.parse(driverBaseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          drivers = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
        debugPrint('Drivers loaded: ${drivers.length}');
      } else if (res.statusCode == 401) {
        debugPrint('Token expired or invalid');
        // Handle token expiration - redirect to login
        setState(() {
          isLoading = false;
        });
      } else {
        debugPrint('Erreur récupération chauffeurs: ${res.statusCode} ${res.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Exception lors de la récupération des chauffeurs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addDriver(Map<String, dynamic> driver) async {
    final box = GetStorage();
    final token = box.read('token');

    try {
      // Convert image to base64 if present
      if (driver['photo'] != null && driver['photo'].isNotEmpty) {
        final file = File(driver['photo']);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          driver['photo'] = base64Encode(bytes);
        } else {
          driver['photo'] = null;
        }
      }

      final res = await http.post(
        Uri.parse(driverBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(driver),
      );

      if (res.statusCode == 201) {
        final createdDriver = json.decode(res.body);
        setState(() {
          drivers.add(createdDriver);
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Chauffeur ajouté avec succès")),
        );
      } else {
        debugPrint('Erreur ${res.statusCode}: ${res.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout du chauffeur")),
        );
      }
    } catch (e) {
      debugPrint('Exception lors de l\'ajout du chauffeur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout du chauffeur")),
      );
    }
  }

  Future<void> _deleteDriver(String driverId) async {
    final box = GetStorage();
    final token = box.read('token');


    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez vous reconnecter")),
      );
      return;
    }

    try {
      final res = await http.delete(
        Uri.parse('$driverBaseUrl/$driverId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          drivers.removeWhere((d) => d['_id'] == driverId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chauffeur supprimé")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur suppression: ${res.body}")),
        );
      }
    } catch (e) {
      debugPrint('Erreur suppression chauffeur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression")),
      );
    }
  }


  void _openAddDriverForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddDriverForm(onSubmit: _addDriver),
      ),
    );
  }

  void _callDriver(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(' ', '');
    final Uri uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'appeler ce numéro")),
      );
    }
  }

  Widget _buildDriverPhoto(Map<String, dynamic> driver) {
    final photo = driver['photo'];

    if (photo != null && photo.isNotEmpty) {
      try {
        // If it's a file path
        if (photo.startsWith('/') || photo.startsWith('C:\\')) {
          final file = File(photo);
          if (file.existsSync()) {
            return CircleAvatar(
              backgroundImage: FileImage(file),
              radius: 24,
            );
          }
        }

        // Else assume it's base64
        final String base64Str = photo.contains(',')
            ? photo.split(',').last
            : photo;
        final bytes = base64Decode(base64Str);
        return CircleAvatar(
          backgroundImage: MemoryImage(bytes),
          radius: 24,
        );
      } catch (e) {
        debugPrint('Erreur lors du chargement de la photo: $e');
      }
    }

    return const CircleAvatar(
      child: Icon(Icons.person),
      radius: 24,
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

    final filteredDrivers = drivers.where((driver) {
      final fullName = '${driver['nom']} ${driver['prenom']}'.toLowerCase();
      return fullName.contains(searchQuery.toLowerCase()) ||
          driver['permis'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          driver['telephone'].toLowerCase().contains(searchQuery.toLowerCase());
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
              _fetchDrivers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          if (drivers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun chauffeur trouvé',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Appuyez sur + pour ajouter un chauffeur',
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
                onRefresh: _fetchDrivers,
                child: ListView.builder(
                  itemCount: filteredDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = filteredDrivers[index];
                    return Slidable(
                    key: ValueKey(driver['permis']),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _callDriver(driver['telephone']),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.phone,
                          label: 'Appeler',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Supprimer chauffeur"),
                                content: const Text("Voulez-vous vraiment supprimer ce chauffeur ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Annuler"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteDriver(driver['_id']);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text("Supprimer"),
                                  ),
                                ],
                              ),
                            );
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Supprimer',
                        ),
                      ],
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: _buildDriverPhoto(driver),
                        title: Text("${driver['nom']} ${driver['prenom']}"),
                        subtitle: Text(
                            "Permis: ${driver['permis']}\nTéléphone: ${driver['telephone']}"
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(driver['statut']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            driver['statut'],
                            style: TextStyle(
                              color: _statusColor(driver['statut']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    );

                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDriverForm,
        child: const Icon(Icons.add),
        tooltip: "Ajouter un chauffeur",
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Disponible":
        return Colors.green;
      case "Occupé":
        return Colors.orange;
      case "Inactif":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class AddDriverForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  const AddDriverForm({super.key, required this.onSubmit});

  @override
  State<AddDriverForm> createState() => _AddDriverFormState();
}

class _AddDriverFormState extends State<AddDriverForm> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  String prenom = '';
  String permis = '';
  String telephone = '';
  String statut = "Disponible";
  String? photoPath;
  bool isSubmitting = false;

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          photoPath = picked.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la sélection de l'image")),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && !isSubmitting) {
      _formKey.currentState!.save();
      setState(() {
        isSubmitting = true;
      });

      widget.onSubmit({
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'permis': permis.trim(),
        'telephone': telephone.trim(),
        'statut': statut,
        'photo': photoPath ?? '',
      });

      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ajouter un nouveau chauffeur',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
                  child: photoPath == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 24),
                      Text('Photo', style: TextStyle(fontSize: 10)),
                    ],
                  )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Nom",
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => nom = value!,
              validator: (value) => value?.trim().isEmpty == true ? "Champ requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Prénom",
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => prenom = value!,
              validator: (value) => value?.trim().isEmpty == true ? "Champ requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Numéro de permis",
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => permis = value!,
              validator: (value) => value?.trim().isEmpty == true ? "Champ requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Téléphone",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              onSaved: (value) => telephone = value!,
              validator: (value) => value?.trim().isEmpty == true ? "Champ requis" : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: statut,
              decoration: const InputDecoration(
                labelText: "Statut",
                border: OutlineInputBorder(),
              ),
              items: ["Disponible", "Occupé", "Inactif"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => statut = value!),
            ),
            const SizedBox(height: 24),
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
    );
  }
}