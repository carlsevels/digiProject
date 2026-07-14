import 'package:bitacora_frontend/infrastructure/layout/layoutExterno.dart';
import 'package:bitacora_frontend/infrastructure/layout/layoutInterno.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Layout extends StatelessWidget {
  final Widget? child;
  Layout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    // 1. Inicializar la sesión
    final Rxn<Session> currentSession = Rxn<Session>(
      Supabase.instance.client.auth.currentSession,
    );

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      currentSession.value = session;

      if (session != null) {
        AppDatabase.db.connect(connector: MyBackendConnector(AppDatabase.db));
      } else {
        AppDatabase.db.disconnect();
      }
    });
    return Obx(() {
      return currentSession.value != null
          ? LayoutInterno(child: child!)
          : LayoutExterno(child: child!);
    });
  }
}
