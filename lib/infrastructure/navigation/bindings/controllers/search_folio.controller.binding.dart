import 'package:bitacora_frontend/presentation/detallesFolio/controllers/detalles_folio.controller.dart';
import 'package:bitacora_frontend/presentation/folios/controllers/folios.controller.dart';
import 'package:get/get.dart';

import '../../../../presentation/searchFolio/controllers/search_folio.controller.dart';

class SearchFolioControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchFolioController>(
      () => SearchFolioController(),
    );
    Get.lazyPut(() => DetallesFolioController());
    Get.lazyPut(() => FoliosController());
  }
}
