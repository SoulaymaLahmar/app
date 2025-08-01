import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/controllers/auth_controller.dart';
import 'package:stage/utils/app_textstyles.dart';
import 'package:stage/view/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
        description:'Surveillez l’état de vos véhicules, les entretiens, et les trajets à tout moment, où que vous soyez.',
        title: 'Gérez votre flotte en temps réel',
        image: 'assets/images/fleet-tracking.webp',
    ),
    OnboardingItem(
      description:'Recevez des rappels automatiques pour les vidanges, contrôles techniques, et réparations importantes.',
      title: 'Ne ratez plus aucun entretien',
      image: 'assets/images/car_maintenance.jpg',
    ),
    OnboardingItem(
      description:"Accédez à des rapports clairs sur les coûts, l'utilisation, et les performances de chaque véhicule.",
      title: 'Prenez des décisions éclairées',
      image: 'assets/images/Fleet-Management.webp',
    ),
  ];

  // handle get started button pressed
   void _handleGetStarted(){
     final AuthController authController = Get.find<AuthController>();
     authController.setFirstTimeDone();
     Get.off(() => SigninScreen());

   }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index){
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _items[index].image,
                    height: MediaQuery.of(context).size.height *0.4,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _items[index].title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.withColor(
                      AppTextStyle.h1,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _items[index].description,
                      textAlign: TextAlign.center,
                        style: AppTextStyle.withColor(
                        AppTextStyle.bodyLarge,
                        isDark? Colors.grey[400]! : Colors.grey[600]! ,
                      ),
                    ) ,
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_items.length, (index)=> AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).primaryColor
                      : (isDark ? Colors.grey[700] : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _handleGetStarted(),
                  child: Text(
                    "Ignorer",
                    style: AppTextStyle.withColor(AppTextStyle.buttonMedium,
                      isDark? Colors.grey[400]!: Colors.grey[600]!,
                ),
                ),
                ),
                ElevatedButton(onPressed: (){
                  if(_currentPage < _items.length - 1){
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                    );
                  }else{
                    _handleGetStarted();
                  }
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage < _items.length -1 ? 'Suivant' : "Commencer",
                  style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.white),

                ),
                ),


              ],
            ),
          ),
        ],
      ),

    );
  }
}

class OnboardingItem{
  final String image;
  final String title;
  final String description;

  OnboardingItem({
   required this.description,
   required this.title,
   required this.image,
});
}