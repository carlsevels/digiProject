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
        final miId = Supabase.instance.client.auth.currentUser?.id;
        final data = await AppDatabase.db.getOptional(
          '''
        SELECT dp."nombre", r."name" as "rol_nombre" 
        FROM "datosPersonales" dp
        INNER JOIN "roles" r ON dp."rolId" = r."id"
        WHERE dp."userId" = ?
      ''',
          [miId],
        );

        if (data != null) {
          final String rol = data['rol_nombre'] as String;

          await UserStorage.guardarRol(rol);
          print("Rol guardado: $rol");

          if (rol == "Admin") {
            Get.toNamed(Routes.HOME);
          } else {
            Get.toNamed(Routes.FOLIOS);
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void increment() => count.value++;
}
