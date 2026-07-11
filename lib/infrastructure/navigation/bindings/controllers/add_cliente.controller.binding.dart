import 'package:get/get.dart';

import '../../../../presentation/addCliente/controllers/add_cliente.controller.dart';

class AddClienteControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddClienteController>(
      () => AddClienteController(),
    );
  }
}
