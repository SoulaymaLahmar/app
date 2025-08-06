import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stage/controllers/auth_controller.dart';
import 'package:stage/utils/app_textstyles.dart';
import 'package:stage/view/widgets/custom_textfield.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final AuthController authController = AuthController.to;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: authController.user['name'] ?? '');
    _emailController = TextEditingController(text: authController.user['email'] ?? '');
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildTextField(
            context,
            controller: _nameController,
            label: 'Nom complet',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            context,
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            context,
            controller: _phoneController,
            label: 'Numéro de téléphone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {

                authController.updateUserProfileOnServer(
                  name: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text,
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Enregistrer les modifications',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context,
      {required TextEditingController controller,
        required String label,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomTextfield(
        label: label,
        prefixIcon: icon,
        keyboardType: keyboardType,
        controller: controller,
      ),
    );
  }
}
