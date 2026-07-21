import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/storage/user.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController with StateMixin {
  //TODO: Implement LoginController
  RxBool showPassword = false.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final count = 0.obs;
  @override
  void onInit() {
    change(null, status: RxStatus.success());
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

  Future<void> signInWithEmail() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final AuthResponse res = await Supabase.instance.client.auth
          .signInWithPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (res.user != null) {
        await AppDatabase.initialize();

        await AppDatabase.db.waitForFirstSync();

        final miId = res.user!.id;

        final data = await AppDatabase.db.getOptional(
          '''
        SELECT 
          dp."nombre",
          r."name" as "rol_nombre"
        FROM "datosPersonales" dp
        INNER JOIN "roles" r 
          ON dp."rolId" = r."id"
        WHERE dp."userId" = ?
        ''',
          [miId],
        );

        if (data != null) {
          await UserStorage.guardarRol(data['rol_nombre'] as String);

          Get.back(); // cerrar cargando

          Get.offAllNamed(Routes.FOLIOS);
        } else {
          Get.back(); // cerrar cargando
          Get.snackbar(
            "Error",
            "No se encontraron datos del usuario",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back(); // cerrar cargando si hay error
      }

      print("Error crítico: $e");

      Get.snackbar(
        "Error",
        "Usuario o contraseña incorrectos",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void increment() => count.value++;
}
