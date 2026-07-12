import 'package:get/get.dart';

import '../../../../presentation/detallesFolio/controllers/detalles_folio.controller.dart';

class DetallesFolioControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetallesFolioController>(
      () => DetallesFolioController(),
    );
  }
}
