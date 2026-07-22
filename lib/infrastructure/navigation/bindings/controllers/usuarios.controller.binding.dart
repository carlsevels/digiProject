import 'package:get/get.dart';

import '../../../../presentation/usuarios/controllers/usuarios.controller.dart';

class UsuariosControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsuariosController>(
      () => UsuariosController(),
    );
  }
}
