import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:get/get.dart';

import '../../../../presentation/folios/controllers/folios.controller.dart';

class FoliosControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FoliosController>(
      () => FoliosController(),
    );
    Get.lazyPut(() => DetallesFolioController());
  }
}
