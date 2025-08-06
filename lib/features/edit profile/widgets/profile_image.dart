import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stage/utils/app_textstyles.dart';

import '../../../controllers/auth_controller.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userController = Get.find<AuthController>();

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              image: DecorationImage(
                image: userController.user['profileImage'] != null
                    ? NetworkImage(userController.user['profileImage'])
                    : const AssetImage('assets/images/ff0436d36131c01b6c504901b407dcf3.jpg') as ImageProvider,

        fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImagePickerBottomSheet(context, isDark),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  )
              ),
            ),

          )
        ],
      ),
    );
  }

  void _showImagePickerBottomSheet(BuildContext context, bool isDark) {
    final userController = Get.find<AuthController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Changer la photo de profil',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              context,
              'Prendre une photo',
              Icons.camera_alt_outlined,
                  () {
                Get.back();
                userController.pickImage(source: ImageSource.camera);
              },
              isDark,
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              'Sélectionner depuis la galerie',
              Icons.photo_library_outlined,
                  () {
                Get.back();
                userController.pickImage(source: ImageSource.gallery);
              },
              isDark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      bool isDark,
      ){
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ?
                  Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[400] : Colors.grey[600],

            )
          ],
        ),
      ),
    );
  }
}
