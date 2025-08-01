import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/controllers/navigation_controller.dart';

class CustomBottomNavbar extends StatelessWidget {
  const CustomBottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find<NavigationController>();
    return Obx(
        ()=> BottomNavigationBar(
          currentIndex: navigationController.currentIndex.value,
            onTap: (index) => navigationController.changeIndex(index),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car_outlined),
                label: 'Véhicules',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                label: 'Conducteurs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Compte',
              ),
            ]
        ),
    );
  }
}
