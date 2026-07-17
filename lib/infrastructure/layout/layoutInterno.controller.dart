import 'dart:async';

import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LayoutInternoController extends GetxController
    with StateMixin<Map<String, dynamic>> {
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;

  @override
  void onInit() async {
    super.onInit();
    getDatos();
  }

  Future<Map<String, dynamic>?> getDatos() async {
    change(null, status: RxStatus.loading());
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      final status = AppDatabase.db.currentStatus;
      print("¿Ha terminado la sincronización inicial?: ${status.hasSynced}");

      if (status.hasSynced != true) {
        print("Esperando a que PowerSync sincronice...");
        await AppDatabase.db.statusStream.firstWhere(
          (s) => s.hasSynced == true,
        );
        print("¡Sincronización completada!");
      }

      final resultado = await AppDatabase.db.getOptional(
        '''
  SELECT dp.*, r."name" as "nombre_rol" 
  FROM "datosPersonales" dp
  INNER JOIN "roles" r ON dp."rolId" = r."id"
  WHERE dp."userId" = ?
  ''',
        [miId],
      );
      print("resultado: $resultado");
      if (resultado != null) {
        rolName.value = resultado["nombre_rol"];
        nameUser.value = resultado["nombre"];
        change(resultado, status: RxStatus.success());
      } else {
        change(null, status: RxStatus.empty());
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();

    await AppDatabase.db.disconnect();

    await Get.delete<LayoutInternoController>(force: true);

    // 4. Redirigir limpiando toda la pila de rutas
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> signOutAllDevices() async {
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
    Get.toNamed(Routes.LOGIN);
  }
}
