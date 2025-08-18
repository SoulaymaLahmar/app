import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api_service.dart';
import '../screens/models/driver.dart';
import '../screens/models/entretien.dart';
import '../screens/models/stats_summary.dart';
import '../screens/models/vehicle.dart';

class StatisticsController extends GetxController {
  var isLoading = true.obs;
  var vehicles = <Vehicle>[].obs;
  var maintenanceRecords = <Entretien>[].obs;
  var drivers = <Driver>[].obs;
  var statisticsSummary = Rx<StatisticsSummary?>(null);

  var selectedPeriod = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  Future<void> loadData() async {
    try {
      isLoading(true);
      await Future.wait([
        loadVehicles(),
        loadMaintenanceRecords(),
        loadDrivers(),
        loadStatisticsSummary(),
      ]);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les données: $e');
      print(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadVehicles() async {
    vehicles.value = await ApiService.getVehicles();
  }

  Future<void> loadMaintenanceRecords() async {
    maintenanceRecords.value = await ApiService.getMaintenanceRecords();
  }

  Future<void> loadDrivers() async {
    drivers.value = await ApiService.getDrivers();
  }

  Future<void> loadStatisticsSummary() async {
    statisticsSummary.value = await ApiService.getStatisticsSummary();
  }

  // Computed properties for statistics
  double get totalCost {
    if (statisticsSummary.value != null) {
      return statisticsSummary.value!.totalCost;
    }
    return vehicles.fold(0.0, (sum, vehicle) => sum + vehicle.coutVehicle) +
        maintenanceRecords.fold(0.0, (sum, entretien) => sum + entretien.cout);
  }

  double get totalDistance {
    if (statisticsSummary.value != null) {
      return statisticsSummary.value!.totalDistance;
    }
    return vehicles.fold(0.0, (sum, vehicle) => sum + vehicle.kilometrage);
  }

  int get activeVehiclesCount {
    if (statisticsSummary.value != null) {
      return statisticsSummary.value!.activeVehicles;
    }
    return vehicles.where((v) => v.etat == 'En service').length;
  }

  double get averageEfficiency {
    if (statisticsSummary.value != null) {
      return statisticsSummary.value!.averageEfficiency;
    }
    if (vehicles.isEmpty) return 0;
    return vehicles.fold(0.0, (sum, vehicle) => sum + vehicle.efficiency) / vehicles.length;
  }

  List<Map<String, dynamic>> get costSummary {
    final fuelCost = maintenanceRecords
        .where((e) => e.type.toLowerCase().contains('carburant'))
        .fold(0.0, (sum, e) => sum + e.cout);

    final maintenanceCost = maintenanceRecords
        .where((e) => !e.type.toLowerCase().contains('carburant') &&
        !e.type.toLowerCase().contains('assurance') &&
        !e.type.toLowerCase().contains('réparation'))
        .fold(0.0, (sum, e) => sum + e.cout);

    final insuranceCost = maintenanceRecords
        .where((e) => e.type.toLowerCase().contains('assurance'))
        .fold(0.0, (sum, e) => sum + e.cout);

    final repairCost = maintenanceRecords
        .where((e) => e.type.toLowerCase().contains('réparation'))
        .fold(0.0, (sum, e) => sum + e.cout);

    return [
      {"label": "Carburant", "value": fuelCost, "color": Color(0xFFFF6B6B), "icon": Icons.local_gas_station},
      {"label": "Entretien", "value": maintenanceCost, "color": Color(0xFF4ECDC4), "icon": Icons.build},
      {"label": "Assurance", "value": insuranceCost, "color": Color(0xFF45B7D1), "icon": Icons.security},
      {"label": "Réparation", "value": repairCost, "color": Color(0xFFFFA726), "icon": Icons.build_circle},
    ];
  }

  List<Map<String, dynamic>> get vehiclePerformance {
    return vehicles.map((vehicle) => {
      "vehicle": "${vehicle.marque} ${vehicle.modele}",
      "km": vehicle.kilometrage.toInt(),
      "conso": vehicle.consommation,
      "efficiency": vehicle.efficiency.toInt(),
      "status": vehicle.status,
    }).toList();
  }

  List<Map<String, dynamic>> get driverStats {
    return drivers.map((driver) => {
      "name": driver.fullName,
      "km": driver.totalKm,
      "note": driver.drivingScore.toInt(),
      "trips": driver.totalTrips,
      "eco_score": driver.ecoScore.toInt(),
    }).toList();
  }

  List<Map<String, dynamic>> get monthlyTrends {
    if (statisticsSummary.value?.monthlyTrends.isNotEmpty == true) {
      return statisticsSummary.value!.monthlyTrends.map((trend) => {
        "month": trend.month,
        "cost": trend.cost,
        "km": trend.km,
      }).toList();
    }

    // Fallback with calculated data or mock data
    return [
      {"month": "Jan", "cost": 800.0, "km": 2100},
      {"month": "Fév", "cost": 950.0, "km": 2300},
      {"month": "Mar", "cost": 1100.0, "km": 2800},
      {"month": "Avr", "cost": 870.0, "km": 2200},
      {"month": "Mai", "cost": 1200.0, "km": 3100},
      {"month": "Jun", "cost": 1050.0, "km": 2700},
    ];
  }

  void changePeriod(int period) {
    selectedPeriod(period);
    // You can implement period-specific data filtering here
    loadData(); // Reload data for the new period
  }
}