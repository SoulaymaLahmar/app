import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/features/privacy%20policy/widgets/info_section.dart';
import 'package:stage/utils/app_textstyles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: ()=> Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
        ),
        title: Text(
          'Politique de confidentialité',
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
              title: 'Informations que nous collectons' ,
              content: 'Nous collectons certaines informations personnelles et techniques afin d’assurer le bon fonctionnement de l’application, d’améliorer votre expérience utilisateur et de garantir la sécurité des données. ',
            ),
              InfoSection(
                title: 'Comment nous utilisons vos informations' ,
                content: 'Les informations collectées sont utilisées pour fournir nos services, améliorer les fonctionnalités de l’application. ',
              ),
              InfoSection(
                title: 'Partage des informations' ,
                content: 'Nous ne partageons vos informations personnelles qu’avec des partenaires ou prestataires de services de confiance, uniquement lorsque cela est nécessaire pour fournir ou améliorer les fonctionnalités de l’application. ',
              ),
              InfoSection(
                title: 'Sécurité des données' ,
                content: 'Nous appliquons des mesures de sécurité techniques et organisationnelles pour protéger vos données contre tout accès, modification ou suppression non autorisés. ',
              ),
              InfoSection(
                title: ' Vos droits' ,
                content: 'Vous disposez de droits concernant vos données personnelles, notamment le droit d’accéder à vos informations, de les corriger, de demander leur suppression ou de vous opposer à leur traitement. ',
              ),
              InfoSection(
                title: 'Politique relative aux cookies' ,
                content: 'Nous utilisons des cookies pour améliorer votre expérience utilisateur, analyser l’utilisation de l’application et personnaliser le contenu. ',
              ),
              const SizedBox(height: 24),
              Text(
                'Dernière mise à jour : août 2025',
                style: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }
}
