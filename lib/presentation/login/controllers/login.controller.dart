import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/storage/user.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController with StateMixin {
  //TODO: Implement LoginController

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
      final AuthResponse res = await Supabase.instance.client.auth
          .signInWithPassword(
            email: emailController.text,
            password: passwordController.text,
          );

      if (res.user != null) {
        // AQUÍ ESTÁ EL TRUCO:
        // Si borraste el archivo en signOut, debes asegurarte de que
        // la conexión se vuelva a abrir antes de esperar el sync.
        await AppDatabase.initialize(); // Asegúrate de tener este método en AppDatabase

        await AppDatabase.db.waitForFirstSync();

        final miId = res.user!.id;
        final data = await AppDatabase.db.getOptional(
          'SELECT dp."nombre", r."name" as "rol_nombre" FROM "datosPersonales" dp INNER JOIN "roles" r ON dp."rolId" = r."id" WHERE dp."userId" = ?',
          [miId],
        );

        if (data != null) {
          await UserStorage.guardarRol(data['rol_nombre'] as String);
          Get.offAllNamed(Routes.FOLIOS);
        }
      }
    } catch (e) {
      print("Error crítico: $e");
      // Si falla aquí es porque la BD no pudo abrirse tras el borrado
    }
  }

  void increment() => count.value++;
}
