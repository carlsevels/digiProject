import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/storage/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        final miId = res.user!.id;

        // Consulta directa a Supabase con relación a la tabla roles
        final data = await Supabase.instance.client
            .from('datosPersonales')
            .select('nombre, roles:rolId(name)')
            .eq('userId', miId)
            .maybeSingle();

        if (data != null) {
          final rolData = data['roles'];
          String rolNombre = "Sin rol";
          
          if (rolData != null && rolData is Map) {
            rolNombre = rolData['name'] ?? "Sin rol";
          }

          await UserStorage.guardarRol(rolNombre);

          Get.back(); // Cierra el diálogo de carga
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