import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitacora_frontend/infrastructure/layout/layoutExterno.dart';
import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';

// Asegúrate de importar el controlador creado arriba
class Layout extends StatelessWidget {
  final Widget? child;
  // Inicializamos el controlador una sola vez
  final AuthController authController = Get.put(AuthController());

  Layout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return authController.currentSession.value != null
          ? LayoutInterno(child: child!)
          : LayoutExterno(child: child!);
    });
  }
}

class AuthController extends GetxController {
  final Rxn<Session> currentSession = Rxn<Session>();

  @override
  void onInit() {
    super.onInit();
    // Obtener sesión inicial
    currentSession.value = Supabase.instance.client.auth.currentSession;

    // Escuchar cambios de sesión de forma segura
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      currentSession.value = data.session;

      if (data.session != null) {
        // Conectar PowerSync cuando hay sesión
        AppDatabase.db.connect(connector: MyBackendConnector(AppDatabase.db));
      } else {
        // Desconectar cuando no hay sesión
        AppDatabase.db.disconnect();
      }
    });
  }
}
