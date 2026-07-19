import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRefaccionController extends GetxController {
  //TODO: Implement AddRefaccionController
  final TextEditingController nombreController = TextEditingController();

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> postRefaccion() async {
    if (nombreController.text.isEmpty) return;

    try {
      final String nuevoId = DateTime.now().microsecondsSinceEpoch.toString();

      await AppDatabase.db.writeTransaction((txn) async {
        await txn.execute(
          '''INSERT INTO tipos (id, nombre) VALUES (?, ?)''',
          [nuevoId, nombreController.text],
        );
      });

      nombreController.clear();
      FocusManager.instance.primaryFocus?.unfocus();

      Get.snackbar(
        "Éxito",
        "Refacción agregada correctamente",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        padding: EdgeInsets.only(bottom: 16.0),
      );
      Get.toNamed(Routes.REFACCIONES);
    } catch (e) {
      print("Error detallado al insertar: $e");
      Get.snackbar(
        "Error",
        "No se pudo guardar la refacción",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void increment() => count.value++;
}
