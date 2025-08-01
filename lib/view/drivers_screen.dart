import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stage/view/widgets/custom_search_bar.dart';
import 'dart:io';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';


import '../utils/app_textstyles.dart';

class DriversScreen extends StatefulWidget {

  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {

  List<Map<String, dynamic>> drivers = [
    {
      'nom': 'Ben Ali',
      'prenom': 'Mohamed',
      'permis': 'TN123456',
      'telephone': '+216 98 123 456',
      'statut': 'Disponible',
      'photo': null,
    },
    {
      'nom': 'Trabelsi',
      'prenom': 'Hichem',
      'permis': 'TN654321',
      'telephone': '+216 55 987 654',
      'statut': 'Occupé',
      'photo': null,
    },
    {
      'nom': 'Jouini',
      'prenom': 'Sami',
      'permis': 'TN111222',
      'telephone': '+216 20 000 111',
      'statut': 'Inactif',
      'photo': null,
    }
  ];

  String searchQuery = '';

  void _addDriver(Map<String, dynamic> driver) {
    setState(() {
      drivers.add(driver);
    });
    Navigator.of(context).pop();
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



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                      leading: driver['photo'] != null
                          ? CircleAvatar(
                        backgroundImage: FileImage(File(driver['photo'])),
                        radius: 24,
                      )
                          : const CircleAvatar(
                        child: Icon(Icons.person),
                        radius: 24,
                      ),
                      title: Text("${driver['nom']} ${driver['prenom']}"),
                      subtitle: Text("Permis: ${driver['permis']}\nTéléphone: ${driver['telephone']}"),
                      trailing: Text(
                        driver['statut'],
                        style: TextStyle(color: _statusColor(driver['statut'])),
                      ),
                    ),
                  ),
                );


              },
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        photoPath = picked.path;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit({
        'nom': nom,
        'prenom': prenom,
        'permis': permis,
        'telephone': telephone,
        'statut': statut,
        'photo': photoPath,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
                child: photoPath == null ? const Icon(Icons.camera_alt, size: 30) : null,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Nom"),
              onSaved: (value) => nom = value!,
              validator: (value) => value!.isEmpty ? "Champ requis" : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Prénom"),
              onSaved: (value) => prenom = value!,
              validator: (value) => value!.isEmpty ? "Champ requis" : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Numéro de permis"),
              onSaved: (value) => permis = value!,
              validator: (value) => value!.isEmpty ? "Champ requis" : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Téléphone"),
              keyboardType: TextInputType.phone,
              onSaved: (value) => telephone = value!,
              validator: (value) => value!.isEmpty ? "Champ requis" : null,
            ),
            DropdownButtonFormField<String>(
              value: statut,
              decoration: const InputDecoration(labelText: "Statut"),
              items: ["Disponible", "Occupé", "Inactif"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => statut = value!),
            ),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Ajouter"),
            )
          ],
        ),
      ),
    );
  }
}
