import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/controllers/auth_controller.dart';
import 'package:stage/features/edit%20profile/screens/edit_profile_screen.dart';
import 'package:stage/features/help%20center/screens/help_center_screen.dart';
import 'package:stage/utils/app_textstyles.dart';
import 'package:stage/view/settings_screen.dart';
import 'package:stage/view/signin_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Compte',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () => Get.to(() => const SettingsScreen()),
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildMenuSection(context),

        ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: authController.user['profileImage'] != null
                    ? NetworkImage(authController.user['profileImage'])
                    : const AssetImage('assets/images/ff0436d36131c01b6c504901b407dcf3.jpg') as ImageProvider,

              ),

              const SizedBox(height: 16),
              Text(
                authController.user['name'] ?? '',
                style: AppTextStyle.withColor(
                  AppTextStyle.h2,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authController.user['email'] ?? '',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Get.to(() => const EditProfileScreen()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  side: BorderSide(
                    color: isDark ? Colors.white70 : Colors.black12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Éditer le profil',
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildMenuSection(BuildContext context ){
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuItems = [
      {'icon': Icons.directions_car_outlined, 'title': 'Véhicules'},
      {'icon': Icons.person_outline, 'title': 'Conducteurs'},
      {'icon': Icons.help_outline, 'title': 'Centre d\'aide'},
      {'icon': Icons.logout_outlined, 'title': 'Se déconnecter'},
    ];
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: menuItems.map((item){
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.2):
                      Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                item['title'] as String,
                style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                   Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ) ,
              onTap: (){
                if (item['title'] == 'Se déconnecter'){
                  _showLogoutDialog(context);
                }else if (item['title'] == 'Mes véhicules'){
                  // navigation to my vehicles screen
                }else if (item['title'] == 'Mes conducteurs'){
                  // navigation to drivers screen
                }else if (item['title'] == 'Centre d\'aide'){
                  Get.to(() => const HelpCenterScreen());
                }
              },
            ),
          );

        }).toList(),

      ),
    );
  }
  void _showLogoutDialog(BuildContext context){
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),

        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Voulez-vous vraiment vous déconnecter',
              style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )

                        ),
                        child: Text(
                          'Annuler',
                          style: AppTextStyle.withColor(
                              AppTextStyle.buttonMedium,
                              Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                        ),
                    ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final AuthController authController = Get.find<AuthController>();
                      authController.logout();
                      Get.offAll(()=> SigninScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )

                    ),
                    child: Text(
                      'Se déconnecter',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )

          ],
        ),
      )
    );
  }



}




