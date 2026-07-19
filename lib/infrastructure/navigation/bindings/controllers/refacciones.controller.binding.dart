import 'package:get/get.dart';

import '../../../../presentation/refacciones/controllers/refacciones.controller.dart';

class RefaccionesControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RefaccionesController>(
      () => RefaccionesController(),
    );
  }
}
