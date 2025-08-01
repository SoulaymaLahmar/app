import 'package:flutter/material.dart';

class AddMaintenanceForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final List<Map<String, dynamic>> vehicles;

  const AddMaintenanceForm({
    super.key,
    required this.onSubmit,
    required this.vehicles,
  });

  @override
  State<AddMaintenanceForm> createState() => _AddMaintenanceFormState();
}

class _AddMaintenanceFormState extends State<AddMaintenanceForm> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? selectedVehicle;
  String type = 'Vidange';
  double cout = 0.0;
  DateTime? date;
  String etat = 'En cours';

  void _submit() {
    if (_formKey.currentState!.validate() && selectedVehicle != null && date != null) {
      _formKey.currentState!.save();
      widget.onSubmit({
        'vehicule': "${selectedVehicle!['marque']} ${selectedVehicle!['modele']}",
        'numeroSerie': selectedVehicle!['numeroSerie'],
        'type': type,
        'cout': cout,
        'date': "${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        'etat': etat,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Wrap(
            runSpacing: 12,
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: const InputDecoration(labelText: "Véhicule"),
                items: widget.vehicles.map((vehicle) {
                  return DropdownMenuItem(
                    value: vehicle,
                    child: Text("${vehicle['marque']} ${vehicle['modele']} - ${vehicle['numeroSerie']}"),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedVehicle = value),
                validator: (value) => value == null ? "Veuillez sélectionner un véhicule" : null,
              ),


              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: "Type de maintenance"),
                items: ['Vidange', 'Révision', 'Freins', 'Pneus']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => type = value!),
              ),


              TextFormField(
                decoration: const InputDecoration(labelText: "Coût (TND)"),
                keyboardType: TextInputType.number,
                onSaved: (value) => cout = double.tryParse(value!) ?? 0.0,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),


              Row(
                children: [
                  Expanded(
                    child: Text(
                      date == null
                          ? "Sélectionner une date"
                          : "Date : ${date!.day}/${date!.month}/${date!.year}",
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => date = picked);
                      }
                    },
                    child: const Text("Choisir"),
                  ),
                ],
              ),


              DropdownButtonFormField<String>(
                value: etat,
                decoration: const InputDecoration(labelText: "État"),
                items: ['En cours', 'Terminée']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => etat = value!),
              ),


              ElevatedButton(
                onPressed: _submit,
                child: const Text("Ajouter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
