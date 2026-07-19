import 'package:get/get.dart';

import '../../../../presentation/addRefaccion/controllers/add_refaccion.controller.dart';

class AddRefaccionControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddRefaccionController>(
      () => AddRefaccionController(),
    );
  }
}
