import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutInterno extends StatelessWidget {
  final Widget? child;
  LayoutInterno({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final LayoutInternoController controller = Get.put(
      LayoutInternoController(),
    );
    return controller.obx(
      (state) => Scaffold(body: child ?? const SizedBox.shrink()),
    );
  }
}
