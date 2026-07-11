import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.controller.dart';
import 'package:get/get.dart';

class LayoutInternoControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LayoutInternoController>(() => LayoutInternoController());
  }
}
