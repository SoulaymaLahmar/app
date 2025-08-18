import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = Get.find<DashboardService>();
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> dashboardData = <String, dynamic>{}.obs;
  final RxList<dynamic> recentVehicles = <dynamic>[].obs;
  final RxList<dynamic> recentActivities = <dynamic>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final user = AuthController.to.user;
      final String? userId = user != null ? user['_id']?.toString() : null;

      if (userId == null || userId.isEmpty) {
        throw Exception('Utilisateur non connecté');
      }

      final data = await _dashboardService.getDashboardData(userId, selectedDate.value);

      dashboardData.value = data;
      recentVehicles.value = data['recentVehicles'] ?? [];
      recentActivities.value = data['recentActivities'] ?? [];

    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchDashboardData();
  }

  Future<void> updateSelectedMonth(DateTime date) async {
    selectedDate.value = date;

    try {
      final user = AuthController.to.user;
      final String? userId = user != null ? user['_id']?.toString() : null;

      if (userId == null || userId.isEmpty) return;

      final monthlyStats = await _dashboardService.getMonthlyStats(userId, date);

      final currentData = Map<String, dynamic>.from(dashboardData.value);
      currentData['monthlyStats'] = monthlyStats;
      dashboardData.value = currentData;

    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du chargement des statistiques mensuelles: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int get totalVehicles => dashboardData['vehicleStats']?['total'] as int? ?? 0;
  int get vehiclesEnService => dashboardData['vehicleStats']?['enService'] as int? ?? 0;
  int get vehiclesEnPanne => dashboardData['vehicleStats']?['enMaintenance'] as int? ?? 0;

  double get monthlyCost =>
      (dashboardData['monthlyStats']?['totalCost'] as num?)?.toDouble() ?? 0.0;
  int get monthlyDistance => dashboardData['monthlyStats']?['totalDistance'] as int? ?? 0;
  int get monthlyMaintenance => dashboardData['monthlyStats']?['maintenanceCount'] as int? ?? 0;
  double get monthlyFuel =>
      (dashboardData['monthlyStats']?['fuelConsumption'] as num?)?.toDouble() ?? 0.0;
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardService>(() => DashboardService());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
