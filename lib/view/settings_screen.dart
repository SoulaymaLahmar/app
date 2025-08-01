import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/controllers/theme_controller.dart';
import 'package:stage/features/privacy%20policy/screens/privacy_policy_screen.dart';
import 'package:stage/features/terms%20of%20service/screens/terms_of_service_screen.dart';
import 'package:stage/utils/app_textstyles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () =>Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            )
        ),
        title: Text(
          'Paramètres',
          style: AppTextStyle.withColor(
              AppTextStyle.h3,
              isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Apparence',
              [
                _buildThemeToggle(context),
              ],
            ),
            _buildSection(
              context,
              'Notifications',
              [
              _buildSwitchTile(
                context,
                'Notifications push',
                'Recevoir des notifications push sur les entretiens et les alertes de véhicules.',
                true,
              ),
                _buildSwitchTile(
                  context,
                  'Notifications Email',
                  'Recevoir nos actualités par e-mail.',
                  false,
                ),
            ],
            ),
            _buildSection(
                context,
                'Confidentialité',
                [
              _buildNavigationTile(
                context,
                'Politique de confidentialité',
                'Voir notre politique de confidentialité',
                Icons.privacy_tip_outlined,
                onTap: () => Get.to(() => const PrivacyPolicyScreen()),

              ),
                  _buildNavigationTile(
                    context,
                    'Conditions de service',
                    "Consulter nos conditions d'utilisation",
                    Icons.description_outlined,
                    onTap: () => Get.to(() => const TermsOfServiceScreen()),
                  ),
            ],
            ),
            _buildSection(
                context,
                'À propos ',
                [
                  _buildNavigationTile(
                      context,
                      'Version de l’app',
                      '1.0.0',
                      Icons.info_outline,
                  ),
                ],
            ),
          ],
        ),
      ) ,
    );
  }
  Widget _buildSection(BuildContext context, String title, List<Widget> children){
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            title,
            style: AppTextStyle.withColor(
                AppTextStyle.h3,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
        ),
        ...children
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context){
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<ThemeController>(
      builder: (controller)=> Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          child: ListTile(
              leading : Icon(
                controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            title: Text(
              'Mode sombre',
              style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            trailing: Switch.adaptive(
                value: controller.isDarkMode,
                onChanged: (value) => controller.toggleTheme(),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
      ),
    );
  }

  Widget _buildSwitchTile(
      BuildContext context,
      String title,
      String subtile,
      bool initialValue,
      ){

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Theme.of(context).textTheme.bodyLarge! .color!,
          ),
        ),
        subtitle: Text(
          subtile,
          style: AppTextStyle.withColor(
            AppTextStyle.bodySmall,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
        ),
        trailing: Switch.adaptive(
            value: initialValue,
            onChanged: (value) {},
          activeColor: Theme.of(context).primaryColor,
        ),

      ),
    );
  }

  Widget _buildNavigationTile(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon, {
    VoidCallback? onTap,

  }) {

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            title,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyle.withColor(
              AppTextStyle.bodySmall,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
