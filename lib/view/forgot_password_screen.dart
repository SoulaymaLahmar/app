import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/utils/app_textstyles.dart';
import 'package:stage/view/widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start ,
              children: [
                // back button
                IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                ),

                const SizedBox(height: 20),

                // reset password text
                Text(
                  'Réinitialiser le mot de passe',
                  style: AppTextStyle.withColor(
                      AppTextStyle.h1,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Entrez votre adresse e-mail pour réinitialiser votre mot de passe',
                      style :AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
                ),

                const SizedBox(height: 40),

                //email textfield
                CustomTextfield(
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value){
                  if (value == null || value.isEmpty){
                  return 'Veuillez entrer votre adresse e-mail';
                  }
                  if (!GetUtils.isEmail(value)){
                  return 'Veuillez entrer une adresse e-mail valide';
                  }
                  return null;
                  },
                  ),

                const SizedBox(height: 24),

                // send reset link button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        showSuccessDialog(context);
                      },
                    style:  ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                        'Envoyer le lien de réinitialisation',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Colors.white,
                      ),

                    ),
                  ),
                )

              ],
            ),
          ),
      ),

    );
  }

  // show success dialog
  void showSuccessDialog(BuildContext context){
    Get.dialog(
      AlertDialog(
        title: Text(
            'Vérifiez votre boîte mail',
            style: AppTextStyle.h3,
        ),
        content: Text(
            'Les instructions de réinitialisation ont été envoyées à votre adresse e-mail',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'OK',
                style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Theme.of(context).primaryColor,
                ),
              ),
          ),
        ],

      ),
    );
  }
}
