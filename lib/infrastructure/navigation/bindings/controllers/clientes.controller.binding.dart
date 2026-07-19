import 'package:get/get.dart';

import '../../../../presentation/clientes/controllers/clientes.controller.dart';

class ClientesControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientesController>(
      () => ClientesController(),
    );
  }
}
