import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/storage/user.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class LoginController extends GetxController with StateMixin {
  RxBool showPassword = false.obs;
  RxBool isLoading = false.obs; // Indicador de carga seguro

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  Future<void> signInWithEmail() async {
    try {
      isLoading.value = true;

      final AuthResponse res = await Supabase.instance.client.auth
          .signInWithPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (res.user != null) {
        final miId = res.user!.id;

        if (!kIsWeb) {
          await AppDatabase.initialize();
          await AppDatabase.db.waitForFirstSync();

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
          }
        } else {
          print("Ejecutando en Web: Omitiendo PowerSync.");

          final response = await Supabase.instance.client
              .from('datosPersonales')
              .select('nombre, roles(name)')
              .eq('userId', miId)
              .maybeSingle();

          if (response != null && response['roles'] != null) {
            final rolNombre = response['roles']['name'];
            await UserStorage.guardarRol(rolNombre);
          }
        }

        isLoading.value = false;
        Get.offAllNamed(Routes.FOLIOS);
      }
    } catch (e, stack) {
      isLoading.value = false;
      print(stack);
      print("Error en login: $e");

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void increment() => count.value++;
  final count = 0.obs;
}
