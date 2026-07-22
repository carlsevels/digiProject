import 'package:get/get.dart';

import '../../../../presentation/addUsuario/controllers/add_usuario.controller.dart';

class AddUsuarioControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddUsuarioController>(
      () => AddUsuarioController(),
    );
  }
}
