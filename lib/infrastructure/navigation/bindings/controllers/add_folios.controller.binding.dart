import 'package:get/get.dart';

import '../../../../presentation/add_folios/controllers/add_folios.controller.dart';

class AddFoliosControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddFoliosController>(
      () => AddFoliosController(),
    );
  }
}
