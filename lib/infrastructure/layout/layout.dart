import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitacora_frontend/infrastructure/layout/layoutExterno.dart';
import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Layout extends StatelessWidget {
  final Widget? child;
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
    currentSession.value = Supabase.instance.client.auth.currentSession;

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      currentSession.value = data.session;

      if (kIsWeb) {
        print("Ejecutando en Web: Omitiendo lógica de PowerSync.");
        return;
      }
    });
  }
}
