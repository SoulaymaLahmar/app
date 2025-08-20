import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_textstyles.dart';
import 'signin_screen.dart';
import 'widgets/custom_textfield.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthController authController = Get.put(AuthController());

  // image file observable
  final Rxn<XFile> selectedImage = Rxn<XFile>();

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    Get.bottomSheet(
      Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choisir depuis la galerie"),
              onTap: () async {
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  selectedImage.value = picked;
                }
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Prendre une photo"),
              onTap: () async {
                final picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  selectedImage.value = picked;
                }
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //back button
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Créer un compte',
                style: AppTextStyle.withColor(
                  AppTextStyle.h1,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Inscrivez-vous pour commencer',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),

              const SizedBox(height: 30),

              // profile photo
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Obx(() {
                    return CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: selectedImage.value != null
                          ? FileImage(File(selectedImage.value!.path))
                          : null,
                      child: selectedImage.value == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                          : null,
                    );
                  }),
                ),
              ),

              const SizedBox(height: 30),

              // full name textfield
              CustomTextfield(
                label: 'Nom complet',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // email textfield
              CustomTextfield(
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Veuillez entrer une adresse e-mail valide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // password
              CustomTextfield(
                label: 'Mot de passe',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // confirm password
              CustomTextfield(
                label: 'Confirmer le mot de passe',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe';
                  }
                  if (value != _passwordController.text) {
                    return 'Mot de passe non identique';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // signup button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final photo = selectedImage.value;

                    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                      authController.register(name, email, password, photo);
                    } else {
                      Get.snackbar("Erreur", "Tous les champs sont requis");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Créer un compte',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              //signin textbutton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous avez déjà un compte ?',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.off(() => SigninScreen()),
                    child: Text(
                      'Se connecter',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
