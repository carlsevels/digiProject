import 'package:get/get.dart';

import '../../../../presentation/folios/controllers/folios.controller.dart';

class FoliosControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FoliosController>(
      () => FoliosController(),
    );
  }
}
