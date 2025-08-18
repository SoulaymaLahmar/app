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

  static String? get _token => _storage.read('token');

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static List<T> _removeDuplicates<T>(
      List<T> items, String? Function(T) keySelector) {
    final seen = <String, T>{};
    for (var item in items) {
      final key = keySelector(item) ?? '';
      if (!seen.containsKey(key)) {
        seen[key] = item;
      }
    }
    return seen.values.toList();
  }

  static Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic> &&
            decoded.containsKey('vehicles')) {
          data = decoded['vehicles'];
        } else {
          throw Exception(
              'Unexpected response format: expected List or Map with vehicles key');
        }

        final vehicles = data
            .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
            .toList();

        return _removeDuplicates(vehicles, (v) => v.id);
      } else {
        throw Exception(
          'Failed to load vehicles (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  static Future<List<Entretien>> getMaintenanceRecords() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/costs/analysis'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('breakdown') &&
            data['breakdown'] is Map<String, dynamic> &&
            data['breakdown'].containsKey('entretien') &&
            data['breakdown']['entretien'] is Map<String, dynamic> &&
            data['breakdown']['entretien'].containsKey('records')) {
          final List<dynamic> recordsData =
          data['breakdown']['entretien']['records'];

          final entretiens = recordsData
              .map((json) => Entretien.fromJson(json as Map<String, dynamic>))
              .toList();

          return _removeDuplicates(entretiens, (e) => e.id);
        } else {
          return <Entretien>[];
        }
      } else {
        throw Exception(
          'Failed to load maintenance records (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching maintenance records: $e');
    }
  }

  static Future<List<Driver>> getDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/drivers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic> &&
            decoded.containsKey('drivers')) {
          data = decoded['drivers'];
        } else if (decoded is Map<String, dynamic>) {
          data = [decoded];
        } else {
          throw Exception('Unexpected response format: expected List or Map');
        }

        final drivers = data
            .map((json) => Driver.fromJson(json as Map<String, dynamic>))
            .toList();

        return _removeDuplicates(drivers, (d) => d.id);
      } else {
        throw Exception(
          'Failed to load drivers (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching drivers: $e');
    }
  }

  static Future<StatisticsSummary> getStatisticsSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/summary'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return StatisticsSummary.fromJson(decoded);
        } else {
          throw Exception(
              'Expected Map<String, dynamic> but got ${decoded.runtimeType}');
        }
      } else {
        throw Exception(
          'Failed to load statistics summary (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching statistics summary: $e');
    }
  }

  static Future<void> debugApiResponse(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );

    } catch (e) {
      print('Debug API Error: $e');
    }
  }
}
