import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/features/privacy%20policy/widgets/info_section.dart';
import 'package:stage/utils/app_textstyles.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
        ),
        title: Text(
          'Conditions de service',
          style: AppTextStyle.withColor(
              AppTextStyle.h3,
              isDark ? Colors.white : Colors.black,
          ),

        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoSection(
                  title: 'Bienvenue dans Gestion de Flotte',
                  content: "En utilisant cette application, vous acceptez nos conditions d'utilisation. Veuillez les lire attentivement pour comprendre vos droits et obligations.",
              ),
              InfoSection(
                title: 'Création de compte',
                content: "Pour utiliser toutes les fonctionnalités de l'application, vous devez créer un compte en fournissant des informations exactes et à jour.",
              ),
              InfoSection(
                title: 'Responsabilités de l’utilisateur',
                content: "En tant qu’utilisateur, vous êtes responsable de l’exactitude des informations fournies, du respect des conditions d’utilisation, et de l’usage approprié de l’application. ",
              ),
              InfoSection(
                title: ' Politique de confidentialité',
                content: "Nous nous engageons à protéger vos données personnelles et à respecter votre vie privée conformément aux lois en vigueur.",
              ),
              InfoSection(
                title: 'Propriété intellectuelle',
                content: "Tous les contenus, logos, images et éléments présents dans cette application sont protégés par les droits de propriété intellectuelle et ne peuvent être utilisés sans autorisation préalable.",
              ),
              InfoSection(
                title: 'Résiliation',
                content: "Nous nous réservons le droit de suspendre ou de résilier votre accès à l’application en cas de non-respect des conditions d’utilisation ou pour tout comportement abusif.",
              ),
              const SizedBox(height: 24),
              Text(
                'Dernière mise à jour : août 2025',
                style: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              )
            ],
          ),
        ),
      ),

    );
  }
}
