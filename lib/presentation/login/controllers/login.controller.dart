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
      const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      barrierDismissible: false,
    );

    print("1. Intentando login Supabase");

    final AuthResponse res =
        await Supabase.instance.client.auth.signInWithPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    print("2. Usuario Supabase: ${res.user?.id}");

    if (res.user != null) {

      print("3. Inicializando PowerSync");

      await AppDatabase.initialize();

      print("4. Esperando sincronización");

      await AppDatabase.db.waitForFirstSync();

      print("5. Buscando datos personales");

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

      print("6. Datos encontrados: $data");

      if (data != null) {
        await UserStorage.guardarRol(
          data['rol_nombre'] as String,
        );

        Get.back();
        Get.offAllNamed(Routes.FOLIOS);
      } else {
        Get.back();

        Get.snackbar(
          "Error",
          "Usuario autenticado pero sin datos personales",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    }

  } catch (e, stack) {

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    print("ERROR LOGIN: $e");
    print(stack);

    Get.snackbar(
      "Error",
      e.toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
  void increment() => count.value++;
}
