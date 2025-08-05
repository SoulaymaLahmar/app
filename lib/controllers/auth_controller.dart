import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../view/main_screen.dart';
import '../view/signin_screen.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();

  final RxBool _isFirstTime = true.obs;
  final RxBool _isLoggedIn = false.obs;

  bool get isFirstTime => _isFirstTime.value;
  bool get isLoggedIn => _isLoggedIn.value;

  final String baseUrl = 'http://10.0.2.2:5000/api/auth';

  @override
  void onInit() {
    super.onInit();
    _loadInitialState();
  }

  void _loadInitialState() {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;
    _isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
  }

  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Login Success: ${data['token']}');

        _isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);
        _storage.write('token', data['token']);
        _storage.write('user', data['user']);

        Get.offAll(() => MainScreen());

      } else {
        print('Login Failed: ${data['message']}');
        Get.snackbar("Login Failed", data['message'] ?? "Email ou mot de passe incorrect");
      }
    } catch (e) {
      print('ERROR: $e');
      Get.snackbar("Erreur", "Impossible de se connecter au serveur");
    }
  }


  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Get.snackbar("Succès", data['message']);
        login(email, password); // auto login after register
      } else {
        Get.snackbar("Erreur", data['message'] ?? 'Inscription échouée');
      }
    } catch (e) {
      Get.snackbar("Erreur", "Une erreur s’est produite");
    }
  }

  void logout() {
    _isLoggedIn.value = false;
    _storage.remove('isLoggedIn');
    _storage.remove('token');
    _storage.remove('user');
    Get.offAll(() => SigninScreen());
  }

  String? get token => _storage.read('token');
  Map<String, dynamic>? get user => _storage.read('user');
}
