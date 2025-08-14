import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stage/features/statistics/screens/models/driver.dart';
import 'package:stage/features/statistics/screens/models/entretien.dart';
import 'package:stage/features/statistics/screens/models/stats_summary.dart';
import 'package:stage/features/statistics/screens/models/vehicle.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static final GetStorage _storage = GetStorage();

  /// Token is fetched directly from GetStorage each time
  static String? get _token => _storage.read('token');

  /// Common headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Get all vehicles for statistics
  static Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> data = decoded['vehicles']; // extract the list
        return data.map((item) => Vehicle.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load vehicles (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }



  // Get maintenance records
  static Future<List<Entretien>> getMaintenanceRecords() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/costs/analysis'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> recordsData = data['breakdown']['entretien']['records'];

        return recordsData.map((json) => Entretien.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load maintenance records (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching maintenance records: $e');
    }
  }


  // Get drivers
  static Future<List<Driver>> getDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/drivers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Driver.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      throw Exception('Error fetching drivers: $e');
    }
  }

  // Get statistics summary
  static Future<StatisticsSummary> getStatisticsSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/summary'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return StatisticsSummary.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load statistics summary');
      }
    } catch (e) {
      throw Exception('Error fetching statistics summary: $e');
    }
  }
}
