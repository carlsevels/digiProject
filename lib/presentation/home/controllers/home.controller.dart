import 'dart:async';

import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/storage/user.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController with StateMixin {
  //TODO: Implement HomeController
  StreamSubscription? _subscription;
  var rolName = "Cargando...".obs;

  final count = 0.obs;
  @override
  void onInit() {
    change(null, status: RxStatus.loading());
    getRol();
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

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    Get.toNamed(Routes.LOGIN);
  }

  Future<void> signOutAllDevices() async {
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
    Get.toNamed(Routes.LOGIN);
  }

  Future<Map<String, dynamic>?> getRol() async {
    final miId = Supabase.instance.client.auth.currentUser?.id;
    final status = AppDatabase.db.currentStatus;
    print("¿Ha terminado la sincronización inicial?: ${status.hasSynced}");

    if (status.hasSynced != true) {
      print("Esperando a que PowerSync sincronice...");
      await AppDatabase.db.statusStream.firstWhere((s) => s.hasSynced == true);
      print("¡Sincronización completada!");
    }

    final resultado = await AppDatabase.db.getOptional(
      '''
  SELECT dp."nombre", r."name" as "nombre_rol" 
  FROM "datosPersonales" dp
  INNER JOIN "roles" r ON dp."rolId" = r."id"
  WHERE dp."userId" = ?
  ''',
      [miId],
    );
    print("resultado: ${resultado!["nombre_rol"]}");
    rolName.value = resultado["nombre_rol"];
    return resultado;
  }

  void increment() => count.value++;
}
