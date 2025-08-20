import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/controllers/navigation_controller.dart';
import 'package:stage/controllers/theme_controller.dart';
import 'package:stage/view/vehicles_screen.dart';
import 'package:stage/view/account_screen.dart';
import 'package:stage/view/widgets/custom_bottom_navbar.dart';
import 'drivers_screen.dart';
import 'home_screen.dart';
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find<NavigationController>();
    return GetBuilder<ThemeController>(
        builder: (themeController)=> Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
        child: Obx(
            () => IndexedStack(
              key: ValueKey(navigationController.currentIndex.value),
              index: navigationController.currentIndex.value,
              children: [
                HomeScreen(),
                VehiclesScreen(),
                DriversScreen(),
                AccountScreen(),
              ],
            )
        ),
      ),
          bottomNavigationBar: const CustomBottomNavbar(),
    ));
  }
}
