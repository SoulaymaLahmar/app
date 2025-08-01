import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stage/features/help%20center/widgets/category_card.dart';
import 'package:stage/utils/app_textstyles.dart';

class HelpCategoriesSection extends StatelessWidget {
  const HelpCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon' : Icons.directions_car_outlined, 'title': 'Véhicules' },
      {'icon' : Icons.build_circle_outlined, 'title': 'Entretiens' },
      {'icon' : Icons.location_on_outlined, 'title': 'Localisation GPS' },
      {'icon' : Icons.person_outline, 'title': 'Conducteurs' },
    ];
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Catégories d’aide',
            style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: categories.length ,
              itemBuilder: (context, index){
              return CategoryCard(
                title: categories[index]['title'] as String,
                icon: categories[index]['icon'] as IconData,
              );
              },
          )
        ],
      ),
    );
  }
}
