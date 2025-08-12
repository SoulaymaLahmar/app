import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:stage/controllers/auth_controller.dart';
import '../models/notification_type.dart';

class NotificationRepository {
  final String baseUrl = "http://10.0.2.2:5000/api/notifications";

  Future<List<NotificationItem>> getNotifications() async {
    final token = Get.find<AuthController>().token;

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markAllAsRead() async {
    final token = Get.find<AuthController>().token;
    await http.put(
      Uri.parse('$baseUrl/mark-all-read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> addNotification(String title, String message, String type) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'message': message,
        'type': type,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add notification');
    }
  }

}

