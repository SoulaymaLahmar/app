import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/utils/app_textstyles.dart';
import 'package:stage/view/signin_screen.dart';
import 'package:stage/view/widgets/custom_textfield.dart';

import '../utils/app_textstyles.dart';
import 'main_screen.dart';
class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
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
                //back button
                IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: isDark ? Colors.white: Colors.black,
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

                const SizedBox(height: 40),

                // full name textfield
                CustomTextfield(
                  label: 'Nom complet',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  controller: _nameController,
                  validator: (value){
                    if (value == null || value.isEmpty){
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
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Veuillez entrer votre email';
                    } if (! GetUtils.isEmail(value)){
                      return 'Veuillez entrer une adresse e-mail valide';
                    }

                    return null;
                  },
                ),

                const SizedBox(height:16 ),

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

                const SizedBox(height: 16),

                //confirm password textfield
                CustomTextfield(
                  label: 'Confirmer le mot de passe',
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Veuillez confirmer votre mot de passe';
                    }if(value != _passwordController.text){
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
                      onPressed: ()=> Get.off(()=> const MainScreen()),
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
                        ) ,
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
                        onPressed:() => Get.off(()=> SigninScreen(),),
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
