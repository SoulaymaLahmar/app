import 'package:flutter/material.dart';
import 'package:stage/features/help%20center/widgets/question_card.dart';
import 'package:stage/utils/app_textstyles.dart';

class PopularQuestionSection extends StatelessWidget {
  const PopularQuestionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions fréquentes',
            style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodyLarge! .color!,
            ),
          ),
          const SizedBox(height: 16),
          const QuestionCard(
            title: 'Comment ajouter un nouveau véhicule à la flotte ?',
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 12),
          const QuestionCard(
            title: 'Puis-je recevoir des alertes pour l’entretien des véhicules ?',
            icon: Icons.local_shipping_outlined,
          ),
        ],
      ),
    );
  }
}
