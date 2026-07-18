import 'package:get/get.dart';

import '../../../../presentation/archivados/controllers/archivados.controller.dart';

class ArchivadosControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArchivadosController>(
      () => ArchivadosController(),
    );
  }
}
