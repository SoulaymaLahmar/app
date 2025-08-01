import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/utils/app_textstyles.dart';

class QuestionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const QuestionCard({
    super.key,
    required this.title,
    required this.icon,
});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          size: 16,
        ),
        onTap: () => _showAnswerBottomSheet(context, title, isDark),
      ),
    );
  }
  void _showAnswerBottomSheet(BuildContext context, String question, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppTextStyle.withColor(
                      AppTextStyle.h3,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _getAnswer(question),
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Compris',
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _getAnswer(String question){
    final answers = {
      'Comment ajouter un nouveau véhicule à la flotte ?' : "Accédez à la section « Véhicules », puis appuyez sur le bouton « Ajouter ». Remplissez les informations du véhicule (immatriculation, marque, modèle, etc.) et enregistrez.",
      'Puis-je recevoir des alertes pour l’entretien des véhicules ?' : "Oui. L'application envoie des notifications pour les entretiens programmés ou les révisions à venir en fonction du kilométrage ou de la date.",
      "Est-il possible de suivre la localisation des véhicules ?" : "Oui, si vos véhicules sont équipés de GPS compatibles, la localisation en temps réel s'affiche sur la carte dans l'application.",
      "Qui peut accéder aux données de la flotte ?" : "Seules les personnes autorisées (gestionnaires, superviseurs, etc.) ayant un compte avec les droits d’accès appropriés peuvent consulter ou modifier les données.",
      "L’application fonctionne-t-elle sans connexion Internet ?" : "Certaines fonctionnalités sont disponibles hors ligne, comme la consultation des données enregistrées. La synchronisation complète nécessite une connexion Internet."


    };
    return answers[question] ?? ' Information non disponible. Veuillez contacter le support pour obtenir de l’aide.' ;
  }
}
