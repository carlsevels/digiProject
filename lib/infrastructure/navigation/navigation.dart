import 'package:bitacora_frontend/infrastructure/layout/layout.dart';
import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.dart';
import 'package:bitacora_frontend/infrastructure/navigation/bindings/controllers/layoutInterno.controller.binding.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  EnvironmentsBadge({required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.HOME,
      page: () => Layout(child: const HomeScreen()),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),
    GetPage(
      name: Routes.FOLIOS,
      page: () => const FoliosScreen(),
      binding: FoliosControllerBinding(),
    ),
    GetPage(
      name: Routes.ADD_FOLIOS,
      page: () => const AddFoliosScreen(),
      binding: AddFoliosControllerBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      binding: ProfileControllerBinding(),
    ),
  ];
}
