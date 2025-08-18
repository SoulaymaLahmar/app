import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stage/controllers/auth_controller.dart';
import 'package:stage/controllers/navigation_controller.dart';
import 'package:stage/controllers/theme_controller.dart';
import 'package:stage/utils/app_themes.dart';
import 'package:stage/view/splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/statistics/controllers/statistics_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await GetStorage().write('isFirstTime', true);
  await initializeDateFormatting('fr_FR', null);

  // Register controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(NavigationController());
  Get.lazyPut(() => StatisticsController(), fenix: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion Véhicules',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
      home: SplashScreen(),
    );
  }
}
