import 'package:get/get.dart';

import '../../../../presentation/organigrama/controllers/organigrama.controller.dart';

class OrganigramaControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrganigramaController>(
      () => OrganigramaController(),
    );
  }
}
