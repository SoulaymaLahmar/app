import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stage/controllers/auth_controller.dart';
import 'package:stage/utils/app_textstyles.dart';
import 'package:stage/view/main_screen.dart';
import 'package:stage/view/sign_up_screen.dart';
import 'package:stage/view/widgets/custom_textfield.dart';

import 'forgot_password_screen.dart';

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                    'Bienvenue à nouveau !',
                    style: AppTextStyle.withColor(AppTextStyle.h1, Theme.of(context).textTheme.bodyLarge!.color!),
                ),
                const SizedBox(height: 8,),
                Text('Connectez-vous pour continuer',
                  style: AppTextStyle.withColor(
                      AppTextStyle.bodyLarge,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),

                // email textfield
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

                const SizedBox(height: 16),

                 //password textfield
                CustomTextfield(
                  label: 'Mot de passe',
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Veuillez entrer votre mot de passe';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // forgot password textbutton
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () => Get.to(()=> ForgotPasswordScreen()),
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTextStyle.withColor(
                          AppTextStyle.buttonMedium,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                  ),
                ),
                const SizedBox(height: 24),
                // sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSignIn,
                    style:  ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                      child: Text('Sign In',
                        style: AppTextStyle.withColor(
                          AppTextStyle.buttonMedium,
                          Colors.white,
                        ),
                      ),
                  ),
                ),

                const SizedBox(height: 24),

                // signup textbutton
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n’avez pas de compte ?",
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,

                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(()=>  SignUpScreen(), ),
                      child: Text(
                          'S’inscrire',
                        style: AppTextStyle.withColor(
                            AppTextStyle.buttonMedium,
                            Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }

  // sign in button onpressed
  void _handleSignIn(){
    final AuthController authController = Get.find<AuthController>();
    authController.login();
    Get.offAll(() => const MainScreen());
  }

}
