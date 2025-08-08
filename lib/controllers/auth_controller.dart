import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../view/main_screen.dart';
import '../view/signin_screen.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _storage = GetStorage();
  final String baseUrl = 'http://10.0.2.2:5000/api/auth';

  final RxBool _isFirstTime = true.obs;
  final RxBool _isLoggedIn = false.obs;

  bool get isFirstTime => _isFirstTime.value;
  bool get isLoggedIn => _isLoggedIn.value;

  final RxMap<String, dynamic> _user = <String, dynamic>{}.obs;
  Map<String, dynamic> get user => _user;
  String? get token => _storage.read('token');

  @override
  void onInit() {
    super.onInit();
    _loadInitialState();
  }

  void _loadInitialState() {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;
    _isLoggedIn.value = _storage.read('isLoggedIn') ?? false;

    final storedUser = _storage.read('user');
    if (storedUser != null) {
      _user.value = Map<String, dynamic>.from(storedUser);
    }
  }

  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  // login
  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _isLoggedIn.value = true;
        _user.value = data['user'];
        _storage.write('isLoggedIn', true);
        _storage.write('token', data['token']);
        _storage.write('user', data['user']);

        Get.offAll(() => MainScreen());
      } else {
        Get.snackbar("Erreur", data['message'] ?? "Email ou mot de passe incorrect");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Connexion impossible : $e");
    }
  }

  // register
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
        await Future.delayed(const Duration(seconds: 1));
        Get.offAll(() => SigninScreen());
      } else {
        Get.snackbar("Erreur", data['message'] ?? 'Inscription échouée');
      }
    } catch (e) {
      Get.snackbar("Erreur", "Erreur lors de l'inscription : $e");
    }
  }

  // logout
  void logout() {
    _user.clear();
    _isLoggedIn.value = false;
    _storage.erase();
    Get.offAll(() => SigninScreen());
  }

  // update profile (name, email, phone )
  Future<void> updateUserProfileOnServer({
    required String name,
    required String email,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/users/${user['id']}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        _user.value = body['user'];
        _storage.write('user', body['user']);
        update();
        Get.back();
        Get.snackbar('Succès', 'Profil mis à jour');
      } else {
        Get.snackbar('Erreur', 'Mise à jour impossible');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur réseau : $e');
    }
  }

  // pick image
  Future<void> pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      await uploadProfileImage(File(pickedFile.path));
    }
  }

  // upload profile image
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/profile-image');

      var request = http.MultipartRequest('PATCH', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        _user.value = data['user'];
        _storage.write('user', data['user']);
        update();
        Get.snackbar('Succès', 'Photo mise à jour');
      } else {
        Get.snackbar('Erreur', 'Échec du téléchargement de la photo');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur image : $e');
    }
  }
}