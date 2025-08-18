import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class DashboardService extends GetxService {
  static const String BASE_URL = 'http://10.0.2.2:5000/api';

  Map<String, String> get _headers {
    final token = AuthController.to.token;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        AuthController.to.logout();
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      case 403:
        throw Exception('Accès non autorisé');
      case 404:
        throw Exception('Ressource non trouvée');
      case 500:
        throw Exception('Erreur serveur. Veuillez réessayer plus tard.');
      default:
        throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getVehicleStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/dashboard/vehicles/stats/$userId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as Map<String, dynamic>?) ?? {};
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connexion timeout. Vérifiez votre connexion internet.');
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getRecentVehicles(String userId, {int limit = 3}) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/dashboard/vehicles/recent/$userId?limit=$limit'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>?;
        return data?['vehicles'] as List<dynamic>? ?? [];
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connexion timeout. Vérifiez votre connexion internet.');
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getRecentActivities(String userId, {int limit = 3}) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/dashboard/activities/recent/$userId?limit=$limit'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>?;
        return data?['activities'] as List<dynamic>? ?? [];
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connexion timeout. Vérifiez votre connexion internet.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMonthlyStats(String userId, DateTime date) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/dashboard/stats/monthly/$userId?year=${date.year}&month=${date.month}'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as Map<String, dynamic>?) ?? {};
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connexion timeout. Vérifiez votre connexion internet.');
      }
      rethrow;
    }
  }
  Future<Map<String, dynamic>> getDashboardData(String userId, DateTime selectedDate) async {
    try {
      final results = await Future.wait([
        getVehicleStats(userId),
        getRecentVehicles(userId),
        getRecentActivities(userId),
        getMonthlyStats(userId, selectedDate),
      ]);

      return {
        'vehicleStats': results[0],
        'recentVehicles': results[1],
        'recentActivities': results[2],
        'monthlyStats': results[3],
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardSummary(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/dashboard/summary/$userId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as Map<String, dynamic>?) ?? {};
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connexion timeout. Vérifiez votre connexion internet.');
      }
      rethrow;
    }
  }
}
