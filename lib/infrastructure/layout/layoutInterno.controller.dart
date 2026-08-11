import 'dart:async';
import 'package:bitacora_frontend/infrastructure/navigation/routes.dart';
import 'package:bitacora_frontend/infrastructure/supabase/db_web.dart'; // O tu archivo de base de datos
import 'package:flutter/foundation.dart'; // Necesario para kIsWeb
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LayoutInternoController extends GetxController
    with StateMixin<Map<String, dynamic>> {
  RxInt rolUsuario = 1.obs;
  var rolName = "Cargando...".obs;
  var nameUser = "Cargando...".obs;
  var currentRoute = Get.currentRoute.obs;

  // Controla si el rail menu está visible
  RxBool isWebMenuVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.routing.current.obs, (_) {
      update();
    });
    getDatos();
  }

  void toggleMenu() {
    isWebMenuVisible.value = !isWebMenuVisible.value;
    update();
  }

  void cambiarRuta(String route, int index) {
    if (Get.currentRoute != route) {
      if (index == 0) {
        Get.offAllNamed(route);
      } else {
        Get.toNamed(route);
      }

      update();
    }
  }

 Future<void> getDatos() async {
    change(null, status: RxStatus.loading());
    try {
      final miId = Supabase.instance.client.auth.currentUser?.id;
      Map<String, dynamic>? resultado;

      if (kIsWeb) {
        print("--- DIAGNÓSTICO TOTAL (WEB) ---");

        final response = await Supabase.instance.client
            .from('datosPersonales')
            .select('*')
            .eq('userId', miId!)
            .maybeSingle();

        if (response != null) {
          final dynamic rolIdVal = response['rolId'];
          String rolNameVal = 'Sin rol';

          try {
            final List<dynamic> allRoles = await Supabase.instance.client
                .from('roles')
                .select('*');

            for (var r in allRoles) {
              if (r['id'].toString() == rolIdVal.toString()) {
                rolNameVal = r['name']?.toString() ?? 'Sin nombre en columna';
                break;
              }
            }
          } catch (e) {
            print("ERROR FATAL AL LEER ROLES: $e");
          }

          resultado = {...response, "nombre_rol": rolNameVal};
        }
      } else {
        print("--- DIAGNÓSTICO TOTAL (MÓVIL) ---");
        final status = AppDatabase.db.currentStatus;
        if (status.hasSynced != true) {
          await AppDatabase.db.statusStream.firstWhere(
            (s) => s.hasSynced == true,
          );
        }

        resultado = await AppDatabase.db.getOptional(
          '''
          SELECT dp.*, r."name" as "nombre_rol" 
          FROM "datosPersonales" dp
          INNER JOIN "roles" r ON dp."rolId" = r."id"
          WHERE dp."userId" = ?
          ''',
          [miId],
        );
      }

      // ESTA PARTE AHORA SE EJECUTA SIEMPRE (Tanto en Web como en Móvil)
      if (resultado != null) {
        rolName.value = resultado["nombre_rol"]?.toString() ?? "Sin rol";
        nameUser.value = resultado["nombre"]?.toString() ?? "Usuario";
        
        final dynamic rolIdVal = resultado["rolId"];
        rolUsuario.value = (rolIdVal is int)
            ? rolIdVal
            : int.tryParse(rolIdVal.toString()) ?? 1;

        print("rolName.value: ${rolName.value}");
        print("nameUser.value: ${nameUser.value}");
        
        change(resultado, status: RxStatus.success());
      } else {
        print("Resultado nulo en la consulta.");
        change(null, status: RxStatus.success());
      }
    } catch (e) {
      print("ERROR EN getDatos: $e");
      change(null, status: RxStatus.error(e.toString()));
    }
  }
  Future<void> signOutAllDevices() async {
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
    Get.toNamed(Routes.LOGIN);
  }
}
